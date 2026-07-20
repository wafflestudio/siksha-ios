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

    @Published var selectedImages: [UIImage] = []

    private var imagesData = [Data]()
    private var recommendedComment = ""
    private var isEditMode = false
    private var recommendationTask: Task<Void, Never>?

    init(
        meal: MenuItemDisplayModel? = nil,
        fetchReviewCommentRecommendationUseCase: FetchReviewCommentRecommendationUseCase,
        submitMealReviewUseCase: SubmitMealReviewUseCase,
        editMealReviewUseCase: EditMealReviewUseCase
    ) {
        self.meal = meal
        self.fetchReviewCommentRecommendationUseCase = fetchReviewCommentRecommendationUseCase
        self.submitMealReviewUseCase = submitMealReviewUseCase
        self.editMealReviewUseCase = editMealReviewUseCase

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
            .combineLatest($scoreToSubmit, $selectedKeywords)
            .map {
                !$0.isEmpty && $1 > 0 && $2[KeywordRateType.taste]?.isEmpty == false
                    && $2[KeywordRateType.composition]?.isEmpty == false && $2[KeywordRateType.price]?.isEmpty == false
            }
            .assign(to: \.canSubmit, on: self)
            .store(in: &cancellables)
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

        let submission = makeSubmission(menuId: meal.id, images: nil)
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

    func submitReviewImages(images: [UIImage]) {
        guard let meal = meal else {
            self.postReviewSucceeded = false
            return
        }

        let imagesData = images.compactMap { $0.jpegData(compressionQuality: 0.5) }
        let submission = makeSubmission(menuId: meal.id, images: imagesData)

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
        self.isEditMode = true
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
            downloadExistingImages(from: review.imageUrls)
        }
    }

    private func downloadExistingImages(from urls: [String]) {
        let publishers = urls.compactMap { urlString -> AnyPublisher<UIImage?, Never>? in
            guard let url = URL(string: urlString) else { return nil }

            return URLSession.shared.dataTaskPublisher(for: url)
                .map { UIImage(data: $0.data) }
                .replaceError(with: nil)
                .eraseToAnyPublisher()
        }

        Publishers.MergeMany(publishers)
            .collect()
            .receive(on: RunLoop.main)
            .sink { [weak self] images in
                self?.selectedImages = images.compactMap { $0 }
            }
            .store(in: &cancellables)
    }

    func editReview(reviewId: Int) {
        guard let meal = meal else {
            self.postReviewSucceeded = false
            return
        }

        let allImagesData = selectedImages.compactMap { $0.jpegData(compressionQuality: 0.5) }
        let submission = makeSubmission(menuId: meal.id, images: allImagesData.isEmpty ? nil : allImagesData)

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

    func deleteImage(_ image: UIImage) {
        selectedImages.removeAll {
            $0 == image
        }
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
}
