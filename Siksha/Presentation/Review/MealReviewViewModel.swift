//
//  MealReviewViewModel.swift
//  Siksha
//
//  Created by 박종석 on 2021/03/08.
//

import Combine
import Foundation
import SwiftUI

@MainActor
class MealReviewViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    private let fetchReviewCommentRecommendationUseCase: FetchReviewCommentRecommendationUseCase
    private let submitMealReviewUseCase: SubmitMealReviewUseCase
    private let editMealReviewUseCase: EditMealReviewUseCase
    private let orderedImageDataLoader: OrderedImageDataLoading
    private let uploadImagePreparer: UploadImagePreparing

    @Published var meal: MenuItemDisplayModel?
    @Published var scoreToSubmit: Int = 0
    @Published var commentToSubmit: String = ""
    @Published var commentRecommended: Bool = false
    @Published var canSubmit: Bool = false

    @Published var postReviewSucceeded = true
    @Published var errorCode: ReviewErrorCode? = nil
    @Published var requireLogin: Bool = false
    @Published var showAlert: Bool = false

    @Published var selectedKeywords: [KeywordRateType: String] = [:]

    @Published private(set) var imageAttachments: [UploadImageAttachment] = []
    @Published private(set) var existingImageLoadState: ExistingImageLoadState = .ready

    private var recommendedComment = ""
    private var recommendationTask: Task<Void, Never>?
    private var existingImageLoadTask: Task<Void, Never>?
    private var imageLoadGeneration = 0
    private var existingImageURLStrings: [String] = []

    init(
        meal: MenuItemDisplayModel? = nil,
        fetchReviewCommentRecommendationUseCase: FetchReviewCommentRecommendationUseCase,
        submitMealReviewUseCase: SubmitMealReviewUseCase,
        editMealReviewUseCase: EditMealReviewUseCase,
        orderedImageDataLoader: OrderedImageDataLoading,
        uploadImagePreparer: UploadImagePreparing
    ) {
        self.meal = meal
        self.fetchReviewCommentRecommendationUseCase = fetchReviewCommentRecommendationUseCase
        self.submitMealReviewUseCase = submitMealReviewUseCase
        self.editMealReviewUseCase = editMealReviewUseCase
        self.orderedImageDataLoader = orderedImageDataLoader
        self.uploadImagePreparer = uploadImagePreparer

        $postReviewSucceeded
            .dropFirst()
            .sink { [weak self] status in
                guard let self = self else { return }
                self.showAlert = true
            }
            .store(in: &cancellables)

        $commentRecommended
            .dropFirst()
            .filter { !$0 }
            .map { _ in "" }
            .assign(to: \.commentToSubmit, on: self)
            .store(in: &cancellables)

        $scoreToSubmit
            .debounce(for: 0.3, scheduler: RunLoop.main)
            .sink { [weak self] score in
                guard let self = self else { return }

                if score == 0 {
                    self.recommendationTask?.cancel()
                    self.commentRecommended = false
                } else {
                    if commentToSubmit.isEmpty || commentToSubmit == recommendedComment {
                        self.getRecommendedComment(Int(score))
                    }
                }
            }
            .store(in: &cancellables)

        $commentToSubmit
            .combineLatest($scoreToSubmit, $selectedKeywords, $existingImageLoadState)
            .map {
                !$0.isEmpty && $1 > 0 && $2[KeywordRateType.taste]?.isEmpty == false
                    && $2[KeywordRateType.composition]?.isEmpty == false && $2[KeywordRateType.price]?.isEmpty == false
                    && $3 == .ready
            }
            .assign(to: \.canSubmit, on: self)
            .store(in: &cancellables)
    }

    deinit {
        recommendationTask?.cancel()
        existingImageLoadTask?.cancel()
    }

    var remainingImageCount: Int {
        max(0, 5 - imageAttachments.count)
    }

    private func getRecommendedComment(_ score: Int) {
        recommendationTask?.cancel()
        recommendationTask = Task { [weak self] in
            guard let self else { return }

            do {
                let comment = try await fetchReviewCommentRecommendationUseCase.execute(score: score)
                try Task.checkCancellation()
                guard !comment.isEmpty,
                    self.scoreToSubmit == score,
                    self.commentToSubmit.isEmpty || self.commentToSubmit == self.recommendedComment
                else { return }

                self.commentRecommended = true
                self.recommendedComment = comment
                self.commentToSubmit = comment
            } catch {
                return
            }
        }
    }

    func submitReview() {
        guard let meal = meal else {
            self.postReviewSucceeded = false
            return
        }

        guard existingImageLoadState == .ready else { return }

        let images = imageAttachments.map(\.uploadData)
        let submission = makeSubmission(menuId: meal.id, images: images.isEmpty ? nil : images)

        Task { [weak self] in
            guard let self else { return }

            do {
                try await submitMealReviewUseCase.execute(submission)
                self.errorCode = nil
                self.postReviewSucceeded = true
                self.meal = meal.updatingAfterReviewSubmission(score: self.scoreToSubmit)
            } catch {
                self.errorCode = self.reviewErrorCode(from: error)
                self.postReviewSucceeded = false
            }
        }
    }

    // MARK: - 리뷰 수정 관련 메소드

    func loadExistingReview(_ review: RestaurantReview) {
        self.scoreToSubmit = review.rating
        self.commentToSubmit = review.reviewText

        if review.tags.count >= 1 {
            self.selectedKeywords[.taste] = review.tags[0]
        }
        if review.tags.count >= 2 {
            self.selectedKeywords[.price] = review.tags[1]
        }
        if review.tags.count >= 3 {
            self.selectedKeywords[.composition] = review.tags[2]
        }

        if !review.imageUrls.isEmpty {
            loadExistingImages(from: review.imageUrls)
        }
    }

    private func loadExistingImages(from urlStrings: [String]) {
        existingImageURLStrings = urlStrings
        imageLoadGeneration += 1
        let generation = imageLoadGeneration
        existingImageLoadTask?.cancel()
        existingImageLoadState = .loading

        let urls = urlStrings.compactMap(URL.init(string:))
        guard urls.count == urlStrings.count else {
            existingImageLoadState = .failed
            return
        }
        guard !urls.isEmpty else {
            imageAttachments.removeAll { $0.origin == .downloaded }
            existingImageLoadState = .ready
            return
        }

        let orderedImageDataLoader = orderedImageDataLoader
        existingImageLoadTask = Task { @concurrent [weak self] in
            do {
                let loadedData = try await orderedImageDataLoader.loadImageData(from: urls)
                try Task.checkCancellation()
                await self?.applyLoadedImageData(loadedData, generation: generation)
            } catch is CancellationError {
                return
            } catch {
                await self?.applyImageLoadFailure(generation: generation)
            }
        }
    }

    func editReview(reviewId: Int) {
        guard let meal = meal else {
            self.postReviewSucceeded = false
            return
        }

        guard existingImageLoadState == .ready else { return }

        let images = imageAttachments.map(\.uploadData)
        let submission = makeSubmission(menuId: meal.id, images: images.isEmpty ? nil : images)

        Task { [weak self] in
            guard let self else { return }

            do {
                try await editMealReviewUseCase.execute(reviewId: reviewId, submission: submission)
                self.errorCode = nil
                self.postReviewSucceeded = true
            } catch {
                self.errorCode = self.reviewErrorCode(from: error)
                self.postReviewSucceeded = false
            }
        }
    }

    func addSelectedImages(_ images: [UIImage]) {
        let imagesToAdd = images.prefix(remainingImageCount)

        do {
            let attachments = try imagesToAdd.map(uploadImagePreparer.prepareSelectedImage)
            imageAttachments.append(contentsOf: attachments)
        } catch {
            errorCode = nil
            postReviewSucceeded = false
        }
    }

    func deleteImage(id: UUID) {
        imageAttachments.removeAll { $0.id == id }
    }

    func retryExistingImageLoad() {
        loadExistingImages(from: existingImageURLStrings)
    }

    private func makeSubmission(menuId: Int, images: [Data]?) -> MealReviewSubmissionModel {
        MealReviewSubmissionModel(
            menuId: menuId,
            score: scoreToSubmit,
            comment: commentToSubmit.count > 0 ? commentToSubmit : "",
            taste: selectedKeywords[.taste] ?? "",
            price: selectedKeywords[.price] ?? "",
            foodComposition: selectedKeywords[.composition] ?? "",
            images: images
        )
    }

    private func reviewErrorCode(from error: Error) -> ReviewErrorCode? {
        if case let MealReviewSubmissionError.statusCode(statusCode) = error {
            return ReviewErrorCode(rawValue: statusCode) ?? .noNetwork
        }
        return .noNetwork
    }

    private func applyLoadedImageData(_ loadedData: [Data], generation: Int) {
        guard imageLoadGeneration == generation else { return }

        do {
            let downloadedAttachments = try loadedData.map(uploadImagePreparer.prepareDownloadedImage)
            let selectedAttachments = imageAttachments.filter { $0.origin == .selected }
            imageAttachments = downloadedAttachments + selectedAttachments
            existingImageLoadState = .ready
        } catch {
            existingImageLoadState = .failed
        }
    }

    private func applyImageLoadFailure(generation: Int) {
        guard imageLoadGeneration == generation else { return }
        existingImageLoadState = .failed
    }
}
