//
//  MenuDisplayModels.swift
//  Siksha
//
//  Created by Codex on 6/7/26.
//

import Foundation

struct MenuItemDisplayModel: Identifiable {
    let id: Int
    let code: String
    let nameKr: String
    let nameEn: String
    let price: Int
    let score: Double
    let reviewCount: Int
    let isLiked: Bool
    let likeCount: Int
    let imageURLStrings: [String]
}

struct RestaurantMenusDisplayModel: Identifiable {
    let id: String
    let restaurantId: Int
    let code: String
    let nameKr: String
    let nameEn: String
    let address: String
    let coordinate: Coordinate?
    let operatingHours: [String]
    let menus: [MenuItemDisplayModel]
    let isFavorite: Bool
}

struct MealSectionDisplayModel: Identifiable {
    let id: Int
    let type: TypeSelection
    let restaurantMenus: [RestaurantMenusDisplayModel]
}

struct RestaurantInformationDisplayModel: Identifiable {
    let id: Int
    let nameKr: String
    let address: String
    let coordinate: Coordinate?
    let operatingHours: [String]
}

struct KakaoShareRestaurantModel {
    struct Menu {
        let nameKr: String
        let price: Int
    }

    let nameKr: String
    let menus: [Menu]
}

extension MenuItemDisplayModel {
    init(menu: MenuModel) {
        self.init(
            id: menu.id,
            code: menu.code,
            nameKr: menu.nameKr,
            nameEn: menu.nameEn,
            price: menu.price,
            score: menu.score,
            reviewCount: menu.reviewCount,
            isLiked: menu.isLiked,
            likeCount: menu.likeCount,
            imageURLStrings: menu.imageURLStrings
        )
    }

    var menuModel: MenuModel {
        MenuModel(
            id: id,
            code: code,
            nameKr: nameKr,
            nameEn: nameEn,
            price: price,
            score: score,
            reviewCount: reviewCount,
            isLiked: isLiked,
            likeCount: likeCount,
            imageURLStrings: imageURLStrings
        )
    }

    func updatingLike(isLiked: Bool, likeCount: Int) -> MenuItemDisplayModel {
        MenuItemDisplayModel(
            id: id,
            code: code,
            nameKr: nameKr,
            nameEn: nameEn,
            price: price,
            score: score,
            reviewCount: reviewCount,
            isLiked: isLiked,
            likeCount: likeCount,
            imageURLStrings: imageURLStrings
        )
    }

    func updatingAfterReviewSubmission(score submittedScore: Int) -> MenuItemDisplayModel {
        let newReviewCount = reviewCount + 1
        let newScore =
            newReviewCount > 0
            ? ((score * Double(reviewCount)) + Double(submittedScore)) / Double(newReviewCount)
            : score

        return MenuItemDisplayModel(
            id: id,
            code: code,
            nameKr: nameKr,
            nameEn: nameEn,
            price: price,
            score: newScore,
            reviewCount: newReviewCount,
            isLiked: isLiked,
            likeCount: likeCount,
            imageURLStrings: imageURLStrings
        )
    }
}

extension RestaurantMenusDisplayModel {
    var informationModel: RestaurantInformationDisplayModel {
        RestaurantInformationDisplayModel(
            id: restaurantId,
            nameKr: nameKr,
            address: address,
            coordinate: coordinate,
            operatingHours: operatingHours
        )
    }

    var kakaoShareModel: KakaoShareRestaurantModel {
        KakaoShareRestaurantModel(
            nameKr: nameKr,
            menus: menus.map {
                KakaoShareRestaurantModel.Menu(nameKr: $0.nameKr, price: $0.price)
            }
        )
    }
}
