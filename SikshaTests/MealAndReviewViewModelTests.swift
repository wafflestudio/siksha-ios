//
//  MealAndReviewViewModelTests.swift
//  SikshaTests
//

import UIKit
import XCTest

@testable import Siksha

@MainActor
final class MealAndReviewViewModelTests: XCTestCase {
    func testMealInfoLoadReviewsRejectsDuplicateRequestAndPublishesResponse() async {
        let reviews = ControlledReviewPageUseCase()
        let viewModel = makeMealInfoViewModel(reviews: reviews)

        viewModel.loadReviews()
        viewModel.loadReviews()
        await waitUntil { reviews.executionCount == 1 }

        guard case .loading = viewModel.getReviewStatus else {
            return XCTFail("Expected loading status")
        }

        reviews.completeNext(with: .fixture(reviews: [.fixture()]))
        await waitUntil {
            if case .succeeded = viewModel.getReviewStatus {
                return true
            }
            return false
        }

        XCTAssertEqual(viewModel.mealReviews.map(\.id), [1])
        XCTAssertFalse(viewModel.hasMorePages)
    }

    func testNewestMealRefreshWinsWhenOlderRequestFinishesLast() async {
        let fetchMenu = ControlledFetchMenuUseCase()
        let viewModel = makeMealInfoViewModel(fetchMenu: fetchMenu)

        viewModel.updateMealFromId()
        await waitUntil { fetchMenu.executionCount == 1 }
        viewModel.updateMealFromId()
        await waitUntil { fetchMenu.executionCount == 2 }

        fetchMenu.completeRequest(at: 1, with: .fixture(nameKr: "new meal"))
        await waitUntil { viewModel.meal.nameKr == "new meal" }
        fetchMenu.completeRequest(at: 0, with: .fixture(nameKr: "old meal"))
        await Task.yield()

        XCTAssertEqual(viewModel.meal.nameKr, "new meal")
    }

    func testReviewListRejectsDuplicatePageRequestAndAdvancesPage() async {
        let reviews = ControlledReviewPageUseCase()
        let viewModel = ReviewListViewModel(
            mealID: 1,
            fetchMealReviewsUseCase: reviews,
            fetchMealImageReviewsUseCase: reviews
        )

        viewModel.loadMoreReviewsIfNeeded()
        viewModel.loadMoreReviewsIfNeeded()
        await waitUntil { reviews.executionCount == 1 }
        reviews.completeNext(with: .fixture(reviews: [.fixture()]))
        await waitUntil { viewModel.reviews.count == 1 }

        XCTAssertEqual(viewModel.currentPage, 2)
        XCTAssertFalse(viewModel.hasMorePages)
        guard case .succeeded = viewModel.getReviewStatus else {
            return XCTFail("Expected succeeded status")
        }
    }

    func testReviewRowRejectsDuplicateLikeRequestAndUpdatesState() async {
        let updateLike = ControlledUpdateReviewLikeUseCase()
        let viewModel = ReviewRowViewModel(
            review: .fixture(likeCount: 2, isLiked: false),
            showImage: true,
            updateReviewLikeUseCase: updateLike
        )

        viewModel.toggleLike()
        viewModel.toggleLike()
        await waitUntil { updateLike.executionCount == 1 }
        updateLike.complete()
        await waitUntil { viewModel.isLiked }

        XCTAssertEqual(viewModel.likeCount, 3)
        XCTAssertNil(viewModel.error)
    }

    func testLatestScoreRecommendationWinsWhenOlderRequestFinishesLast() async {
        let recommendations = ControlledRecommendationUseCase()
        let viewModel = MealReviewViewModel(
            meal: .fixture(),
            fetchReviewCommentRecommendationUseCase: recommendations,
            submitMealReviewUseCase: SubmitMealReviewUseCaseStub(),
            editMealReviewUseCase: EditMealReviewUseCaseStub(),
            orderedImageDataLoader: OrderedImageDataLoaderStub(),
            uploadImagePreparer: JPEGUploadImagePreparer()
        )

        viewModel.scoreToSubmit = 1
        try? await Task.sleep(nanoseconds: 350_000_000)
        await waitUntil { recommendations.requestedScores == [1] }

        viewModel.scoreToSubmit = 2
        try? await Task.sleep(nanoseconds: 350_000_000)
        await waitUntil { recommendations.requestedScores == [1, 2] }

        recommendations.complete(score: 2, with: "new recommendation")
        await waitUntil { viewModel.commentToSubmit == "new recommendation" }
        recommendations.complete(score: 1, with: "old recommendation")
        await Task.yield()

        XCTAssertEqual(viewModel.commentToSubmit, "new recommendation")
        XCTAssertTrue(viewModel.commentRecommended)
    }

    func testEditingReviewReusesDownloadedBytesAndCompressesOnlySelectedImage() async throws {
        let downloadedImage = makeImage(size: CGSize(width: 6, height: 6))
        let selectedImage = makeImage(size: CGSize(width: 12, height: 12))
        let downloadedData = try XCTUnwrap(downloadedImage.pngData())
        let expectedSelectedData = try XCTUnwrap(selectedImage.jpegData(compressionQuality: 0.5))
        let editReview = EditMealReviewUseCaseSpy()
        let viewModel = MealReviewViewModel(
            meal: .fixture(),
            fetchReviewCommentRecommendationUseCase: ControlledRecommendationUseCase(),
            submitMealReviewUseCase: SubmitMealReviewUseCaseStub(),
            editMealReviewUseCase: editReview,
            orderedImageDataLoader: OrderedImageDataLoaderStub(data: [downloadedData]),
            uploadImagePreparer: JPEGUploadImagePreparer()
        )
        viewModel.loadExistingReview(
            RestaurantReview(
                id: 1,
                menuId: 1,
                menuName: "meal",
                rating: 4,
                date: "",
                reviewText: "review",
                imageUrls: ["https://example.com/existing.png"],
                tags: ["taste", "price", "composition"]
            )
        )
        await waitUntil {
            viewModel.existingImageLoadState == .ready && viewModel.imageAttachments.count == 1
        }

        viewModel.addSelectedImages([selectedImage])
        viewModel.editReview(reviewId: 1)
        let submission = await waitForSubmission(from: editReview)

        XCTAssertEqual(submission?.images, [downloadedData, expectedSelectedData])
        XCTAssertEqual(viewModel.imageAttachments.map(\.origin), [.downloaded, .selected])
    }

    private func makeMealInfoViewModel(
        fetchMenu: FetchMenuUseCase = ControlledFetchMenuUseCase(),
        reviews: ControlledReviewPageUseCase = ControlledReviewPageUseCase()
    ) -> MealInfoViewModel {
        MealInfoViewModel(
            meal: .fixture(),
            fetchMenuUseCase: fetchMenu,
            fetchMealReviewsUseCase: reviews,
            fetchMealImageReviewsUseCase: reviews,
            fetchMealReviewScoreDistributionUseCase: FetchScoreDistributionUseCaseStub(),
            fetchMealReviewKeywordDistributionUseCase: FetchKeywordDistributionUseCaseStub(),
            updateMenuLikeUseCase: UpdateMenuLikeUseCaseStub()
        )
    }

    private func waitUntil(
        _ condition: () -> Bool,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {
        for _ in 0..<1_000 {
            if condition() {
                return
            }
            await Task.yield()
        }
        XCTFail("Condition was not satisfied", file: file, line: line)
    }

    private func waitForSubmission(
        from useCase: EditMealReviewUseCaseSpy,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async -> MealReviewSubmissionModel? {
        for _ in 0..<1_000 {
            if let submission = await useCase.lastSubmission {
                return submission
            }
            await Task.yield()
        }
        XCTFail("Submission was not captured", file: file, line: line)
        return nil
    }

    private func makeImage(size: CGSize) -> UIImage {
        UIGraphicsImageRenderer(size: size).image { context in
            UIColor.orange.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
}

private final class ControlledFetchMenuUseCase: FetchMenuUseCase {
    private var continuations: [CheckedContinuation<MenuModel, Never>?] = []

    var executionCount: Int {
        continuations.count
    }

    func execute(menuId: Int) async throws -> MenuModel {
        await withCheckedContinuation { continuation in
            continuations.append(continuation)
        }
    }

    func completeRequest(at index: Int, with menu: MenuModel) {
        continuations[index]?.resume(returning: menu)
        continuations[index] = nil
    }
}

private final class ControlledReviewPageUseCase: FetchMealReviewsUseCase, FetchMealImageReviewsUseCase {
    private var continuations: [CheckedContinuation<ReviewPageModel, Never>] = []
    private(set) var executionCount = 0

    func execute(menuId: Int, page: Int, perPage: Int) async throws -> ReviewPageModel {
        executionCount += 1
        return await withCheckedContinuation { continuation in
            continuations.append(continuation)
        }
    }

    func completeNext(with response: ReviewPageModel) {
        continuations.removeFirst().resume(returning: response)
    }
}

private final class ControlledUpdateReviewLikeUseCase: UpdateReviewLikeUseCase {
    private var continuation: CheckedContinuation<Void, Never>?
    private(set) var executionCount = 0

    func execute(reviewId: Int, isLiked: Bool) async throws {
        executionCount += 1
        await withCheckedContinuation { continuation in
            self.continuation = continuation
        }
    }

    func complete() {
        continuation?.resume()
        continuation = nil
    }
}

private final class ControlledRecommendationUseCase: FetchReviewCommentRecommendationUseCase {
    private var continuations: [Int: CheckedContinuation<String, Never>] = [:]
    private(set) var requestedScores: [Int] = []

    func execute(score: Int) async throws -> String {
        requestedScores.append(score)
        return await withCheckedContinuation { continuation in
            continuations[score] = continuation
        }
    }

    func complete(score: Int, with comment: String) {
        continuations.removeValue(forKey: score)?.resume(returning: comment)
    }
}

private final class FetchScoreDistributionUseCaseStub: FetchMealReviewScoreDistributionUseCase {
    func execute(menuId: Int) async throws -> [Int] { [] }
}

private final class FetchKeywordDistributionUseCaseStub: FetchMealReviewKeywordDistributionUseCase {
    func execute(menuId: Int) async throws -> KeywordDistributionModel {
        KeywordDistributionModel(
            tasteKeyword: "",
            tasteCount: 0,
            tasteTotal: 0,
            priceKeyword: "",
            priceCount: 0,
            priceTotal: 0,
            foodCompositionKeyword: "",
            foodCompositionCount: 0,
            foodCompositionTotal: 0
        )
    }
}

private final class UpdateMenuLikeUseCaseStub: UpdateMenuLikeUseCase {
    func execute(menuId: Int, isLiked: Bool) async throws -> MenuLikeStatusModel {
        MenuLikeStatusModel(menuId: menuId, isLiked: isLiked, likeCount: 1)
    }
}

private final class SubmitMealReviewUseCaseStub: SubmitMealReviewUseCase {
    func execute(_ submission: MealReviewSubmissionModel) async throws {}
}

private final class EditMealReviewUseCaseStub: EditMealReviewUseCase {
    func execute(reviewId: Int, submission: MealReviewSubmissionModel) async throws {}
}

private actor EditMealReviewUseCaseSpy: EditMealReviewUseCase {
    private(set) var lastSubmission: MealReviewSubmissionModel?

    func execute(reviewId: Int, submission: MealReviewSubmissionModel) async throws {
        lastSubmission = submission
    }
}

private struct OrderedImageDataLoaderStub: OrderedImageDataLoading {
    let data: [Data]

    init(data: [Data] = []) {
        self.data = data
    }

    func loadImageData(from urls: [URL]) async throws -> [Data] {
        data
    }
}

private extension MenuItemDisplayModel {
    static func fixture(nameKr: String = "meal") -> MenuItemDisplayModel {
        MenuItemDisplayModel(
            id: 1,
            code: "menu",
            nameKr: nameKr,
            nameEn: "meal",
            price: 1_000,
            score: 4,
            reviewCount: 1,
            isLiked: false,
            likeCount: 0,
            imageURLStrings: []
        )
    }
}

private extension MenuModel {
    static func fixture(nameKr: String) -> MenuModel {
        MenuModel(
            id: 1,
            code: "menu",
            nameKr: nameKr,
            nameEn: "meal",
            price: 1_000,
            score: 4,
            reviewCount: 1,
            isLiked: false,
            likeCount: 0,
            imageURLStrings: []
        )
    }
}

private extension Review {
    static func fixture(likeCount: Int = 0, isLiked: Bool = false) -> Review {
        Review(
            id: 1,
            menuId: 1,
            userId: 1,
            score: 4,
            comment: "review",
            etc: nil,
            keywordReviews: [],
            likeCount: likeCount,
            isLiked: isLiked,
            createdAt: Date(timeIntervalSince1970: 0),
            updatedAt: Date(timeIntervalSince1970: 0)
        )
    }
}

private extension ReviewPageModel {
    static func fixture(reviews: [Review]) -> ReviewPageModel {
        ReviewPageModel(totalCount: reviews.count, hasNext: false, reviews: reviews)
    }
}
