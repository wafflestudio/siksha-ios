//
//  MyReviewViewModel.swift
//  Siksha
//
//  Created by 이수민 on 9/14/25.
//

import Foundation
import Combine

// MARK: - Protocol

protocol MyReviewViewModelType: ObservableObject {
    var restaurantSections: [RestaurantSection] { get }
    var isLoading: Bool { get }
    var expandedSections: [String: Bool] { get }
    
    func loadReviews()
    func toggleSection(_ sectionId: String, expanded: Bool)
}


// MARK: - Data Models

struct RestaurantSection: Identifiable {
    let id: String
    let name: String
    let reviews: [RestaurantReview]
}

struct RestaurantReview: Identifiable {
    let id: String
    let menuName: String
    let rating: Int
    let date: String
    let reviewText: String
    let imageUrls: [String]
    let tags: [String]
}


// MARK: - ViewModel

@MainActor
class MyReviewViewModel: MyReviewViewModelType {
    
    @Published var restaurantSections: [RestaurantSection] = []
    @Published var isLoading = false
    @Published var expandedSections: [String: Bool] = [:]
    
    func loadReviews() {
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let sections = duummyRestaurantSections
            self.restaurantSections = sections
            
            for (index, section) in sections.enumerated() {
                if self.expandedSections[section.id] == nil {
                    self.expandedSections[section.id] = (index == 0)
                }
            }
            
            self.isLoading = false
        }
    }
    
    func toggleSection(_ sectionId: String, expanded: Bool) {
        expandedSections[sectionId] = expanded
    }
    
}


// MARK: - 더미데이터

private var duummyRestaurantSections: [RestaurantSection] {
    [
        RestaurantSection(
            id: UUID().uuidString,
            name: "학생회관 식당",
            reviews: dummySchoolReviews
        ),
        RestaurantSection(
            id: UUID().uuidString,
            name: "기숙사식당 - 아워홈",
            reviews: mockDormitoryReviews
        ),
        RestaurantSection(
            id: UUID().uuidString,
            name: "교직원식당",
            reviews: mockCafeteriaReviews
        ),
        RestaurantSection(
            id: UUID().uuidString,
            name: "공학관 카페테리아",
            reviews: mockEngineeringReviews
        )
    ]
}

private let dummySchoolReviews: [RestaurantReview] = [
    RestaurantReview(
        id: "1",
        menuName: "최고키카레라이스",
        rating: 5,
        date: "2024년 4월 11일",
        reviewText: "학교 생활의 낙을 담당하는 맛!! 이거 먹으려고 학교 다닌다 ㅎㅎ",
        imageUrls: [
            "https://picsum.photos/200/200?random=1",
            "https://picsum.photos/200/200?random=2",
            "https://picsum.photos/200/200?random=3",
            "https://picsum.photos/200/200?random=4",
            "https://picsum.photos/200/200?random=5"
        ],
        tags: ["또 먹고 싶어요", "가성비 좋아요", "알찬 편이에요"]
    ),
    RestaurantReview(
        id: "2",
        menuName: "최고키카레라이스",
        rating: 5,
        date: "2024년 4월 11일",
        reviewText: "학교 생활의 낙을 담당하는 맛!! 이거 먹으려고 학교 다닌다 ㅎㅎ 학교 생활의 낙을 담당하는 맛!! 이거 먹으려고 학교 다닌다 ㅎㅎ 학교 생활의 낙을 담당하는 맛!! 이거 먹으려고 학교 다닌다 ㅎㅎ",
        imageUrls: [
            "https://picsum.photos/200/200?random=6",
            "https://picsum.photos/200/200?random=7",
            "https://picsum.photos/200/200?random=8"
        ],
        tags: ["맛있어요", "든든해요"]
    ),
    RestaurantReview(
        id: "3",
        menuName: "돈까스정식",
        rating: 4,
        date: "2024년 4월 8일",
        reviewText: "바삭하고 맛있어요! 양도 충분하고 가격도 합리적입니다.",
        imageUrls: [
            "https://picsum.photos/200/200?random=9",
            "https://picsum.photos/200/200?random=10"
        ],
        tags: ["바삭해요", "양이 많아요"]
    )
]

private let mockDormitoryReviews: [RestaurantReview] = [
    RestaurantReview(
        id: "4",
        menuName: "김치찌개",
        rating: 3,
        date: "2024년 4월 5일",
        reviewText: "그냥 평범한 맛이에요. 가격은 저렴해서 자주 먹게 됩니다.",
        imageUrls: [
            "https://picsum.photos/200/200?random=11"
        ],
        tags: ["저렴해요"]
    )
]

private let mockCafeteriaReviews: [RestaurantReview] = []

private let mockEngineeringReviews: [RestaurantReview] = [
    RestaurantReview(
        id: "5",
        menuName: "샌드위치&커피",
        rating: 4,
        date: "2024년 4월 3일",
        reviewText: "간단하게 먹기 좋아요. 커피도 괜찮고 샌드위치도 신선합니다.",
        imageUrls: [
            "https://picsum.photos/200/200?random=12",
            "https://picsum.photos/200/200?random=13"
        ],
        tags: ["간편해요", "신선해요"]
    )
]
