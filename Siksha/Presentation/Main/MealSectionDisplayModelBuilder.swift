//
//  MealSectionDisplayModelBuilder.swift
//  Siksha
//
//  Created by Codex on 6/17/26.
//

import CoreLocation
import Foundation

struct MealSectionDisplayModelBuilder {
    struct Input {
        let menu: DailyMenuModel
        let filters: MenuFilters
        let personalRestaurantById: [Int: PersonalRestaurantModel]
        let personalRestaurantOrder: [Int: Int]
        let shouldUseDefaultRestaurantPreference: Bool
        let noMenuHide: Bool
        let selectedDate: String
        let currentLocation: CLLocation?
    }

    private let maxPrice: Int
    private let menuSpecification: any MenuDisplaySpecification

    init(
        maxPrice: Int = 10_000,
        menuSpecification: any MenuDisplaySpecification = CompositeMenuDisplaySpecification(
            specifications: [
                PriceMenuSpecification(),
                ReviewedMenuSpecification(),
                RatingMenuSpecification()
            ]
        )
    ) {
        self.maxPrice = maxPrice
        self.menuSpecification = menuSpecification
    }

    func build(input: Input) -> [MealSectionDisplayModel] {
        let restaurantSpecification = makeRestaurantSpecification(selectedDate: input.selectedDate)
        let restaurantContext = RestaurantDisplaySpecificationContext(
            filters: input.filters,
            personalRestaurantById: input.personalRestaurantById,
            shouldUseDefaultRestaurantPreference: input.shouldUseDefaultRestaurantPreference,
            currentLocation: input.currentLocation
        )
        let menuContext = MenuDisplaySpecificationContext(
            filters: input.filters,
            maxPrice: maxPrice
        )

        return [
            MealSectionDisplayModel(
                id: TypeSelection.breakfast.rawValue,
                type: .breakfast,
                restaurantMenus: makeRestaurantMenusDisplayModels(
                    type: .breakfast,
                    restaurants: input.menu.breakfast,
                    input: input,
                    restaurantSpecification: restaurantSpecification,
                    restaurantContext: restaurantContext,
                    menuContext: menuContext
                )
            ),
            MealSectionDisplayModel(
                id: TypeSelection.lunch.rawValue,
                type: .lunch,
                restaurantMenus: makeRestaurantMenusDisplayModels(
                    type: .lunch,
                    restaurants: input.menu.lunch,
                    input: input,
                    restaurantSpecification: restaurantSpecification,
                    restaurantContext: restaurantContext,
                    menuContext: menuContext
                )
            ),
            MealSectionDisplayModel(
                id: TypeSelection.dinner.rawValue,
                type: .dinner,
                restaurantMenus: makeRestaurantMenusDisplayModels(
                    type: .dinner,
                    restaurants: input.menu.dinner,
                    input: input,
                    restaurantSpecification: restaurantSpecification,
                    restaurantContext: restaurantContext,
                    menuContext: menuContext
                )
            )
        ]
    }

    private func makeRestaurantMenusDisplayModels(
        type: TypeSelection,
        restaurants: [RestaurantModel],
        input: Input,
        restaurantSpecification: any RestaurantDisplaySpecification,
        restaurantContext: RestaurantDisplaySpecificationContext,
        menuContext: MenuDisplaySpecificationContext
    ) -> [RestaurantMenusDisplayModel] {
        restaurants.enumerated()
            .compactMap { index, restaurant -> (originalIndex: Int, displayModel: RestaurantMenusDisplayModel)? in
                let isLiked = restaurantContext.isLiked(restaurant)

                guard restaurantSpecification.isSatisfied(by: restaurant, context: restaurantContext) else {
                    return nil
                }

                let filteredMenus = filterRestaurantMenus(restaurant.menus, context: menuContext)
                if input.noMenuHide && filteredMenus.isEmpty {
                    return nil
                }

                return (
                    originalIndex: index,
                    displayModel: RestaurantMenusDisplayModel(
                        id: "\(type.rawValue)-\(restaurant.id)",
                        restaurantId: restaurant.id,
                        code: restaurant.code,
                        nameKr: restaurant.nameKr ?? "",
                        nameEn: restaurant.nameEn ?? "",
                        address: restaurant.address ?? "",
                        coordinate: restaurant.coordinate,
                        operatingHours: restaurant.operatingHours,
                        menus: filteredMenus,
                        isFavorite: isLiked
                    )
                )
            }
            .sorted {
                let lhsSortIndex = restaurantSortIndex($0.displayModel.restaurantId, input: input)
                let rhsSortIndex = restaurantSortIndex($1.displayModel.restaurantId, input: input)

                if lhsSortIndex == rhsSortIndex {
                    return $0.originalIndex < $1.originalIndex
                }
                return lhsSortIndex < rhsSortIndex
            }
            .map(\.displayModel)
    }

    private func restaurantSortIndex(_ restaurantId: Int, input: Input) -> Int {
        input.personalRestaurantOrder[restaurantId] ?? Int.max
    }

    private func filterRestaurantMenus(
        _ menus: [MenuModel],
        context: MenuDisplaySpecificationContext
    ) -> [MenuItemDisplayModel] {
        menus.filter { menu in
            menuSpecification.isSatisfied(by: menu, context: context)
        }
        .map { MenuItemDisplayModel(menu: $0) }
    }

    private func makeRestaurantSpecification(selectedDate: String) -> any RestaurantDisplaySpecification {
        CompositeRestaurantDisplaySpecification(
            specifications: [
                VisibleRestaurantSpecification(),
                OpenRestaurantSpecification(
                    operatingStatusPolicy: RestaurantOperatingStatusPolicy(selectedDate: selectedDate)
                ),
                FavoriteRestaurantSpecification(),
                DistanceRestaurantSpecification()
            ]
        )
    }
}
