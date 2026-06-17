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

    init(maxPrice: Int = 10_000) {
        self.maxPrice = maxPrice
    }

    func build(input: Input) -> [MealSectionDisplayModel] {
        [
            MealSectionDisplayModel(
                id: TypeSelection.breakfast.rawValue,
                type: .breakfast,
                restaurantMenus: makeRestaurantMenusDisplayModels(
                    type: .breakfast,
                    restaurants: input.menu.breakfast,
                    input: input
                )
            ),
            MealSectionDisplayModel(
                id: TypeSelection.lunch.rawValue,
                type: .lunch,
                restaurantMenus: makeRestaurantMenusDisplayModels(
                    type: .lunch,
                    restaurants: input.menu.lunch,
                    input: input
                )
            ),
            MealSectionDisplayModel(
                id: TypeSelection.dinner.rawValue,
                type: .dinner,
                restaurantMenus: makeRestaurantMenusDisplayModels(
                    type: .dinner,
                    restaurants: input.menu.dinner,
                    input: input
                )
            )
        ]
    }

    private func makeRestaurantMenusDisplayModels(
        type: TypeSelection,
        restaurants: [RestaurantModel],
        input: Input
    ) -> [RestaurantMenusDisplayModel] {
        restaurants.enumerated()
            .compactMap { index, restaurant -> (originalIndex: Int, displayModel: RestaurantMenusDisplayModel)? in
                let personalRestaurant = input.personalRestaurantById[restaurant.id]
                let isVisible = personalRestaurant?.visible ?? input.shouldUseDefaultRestaurantPreference
                let isLiked = personalRestaurant?.liked ?? false

                guard isVisible else {
                    return nil
                }

                if input.filters.isOpen == true && !isRestaurantOpen(restaurant, selectedDate: input.selectedDate) {
                    return nil
                }

                if input.filters.isFavorite == true && !isLiked {
                    return nil
                }

                if let distance = input.filters.distance {
                    guard let currentLocation = input.currentLocation,
                          let restaurantLocation = restaurant.coordinate?.location,
                          currentLocation.distance(from: restaurantLocation) <= Double(distance) else {
                        return nil
                    }
                }

                let filteredMenus = filterRestaurantMenus(restaurant.menus, filter: input.filters)
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

    private func filterRestaurantMenus(_ menus: [MenuModel], filter: MenuFilters) -> [MenuItemDisplayModel] {
        menus.filter { menu in
            var meetsPrice = true
            if let priceRange = filter.priceRange {
                let lower = priceRange.lowerBound
                let upper = priceRange.upperBound

                if upper < maxPrice {
                    meetsPrice = priceRange.contains(menu.price)
                } else {
                    meetsPrice = menu.price >= lower
                }
            }

            var meetsReview = true
            if filter.hasReview == true {
                meetsReview = menu.reviewCount > 0
            }

            var meetsRate = true
            if let minimumRating = filter.minimumRating {
                meetsRate = menu.score >= Double(minimumRating)
            }

            let meetsCategories = true

            return meetsPrice && meetsReview && meetsRate && meetsCategories
        }
        .map { MenuItemDisplayModel(menu: $0) }
    }

    private func isRestaurantOpen(_ restaurant: RestaurantModel, selectedDate: String) -> Bool {
        var koreanCalendar = Calendar(identifier: .gregorian)
        koreanCalendar.timeZone = TimeZone(identifier: "Asia/Seoul")!

        let selectedDateFormatter = DateFormatter()
        selectedDateFormatter.dateFormat = "yyyy-MM-dd"
        let selected = selectedDateFormatter.date(from: selectedDate) ?? Date()
        let weekday = koreanCalendar.component(.weekday, from: selected)

        let dayIndex: Int
        if weekday == 7 {
            dayIndex = 1
        } else if weekday == 1 {
            dayIndex = 2
        } else {
            dayIndex = 0
        }

        guard restaurant.operatingHours.count > dayIndex else { return false }
        let hoursString = restaurant.operatingHours[dayIndex]
        guard !hoursString.isEmpty else { return false }

        let intervals = hoursString.components(separatedBy: "\n")
        let timeFormatter = DateFormatter()
        timeFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        timeFormatter.dateFormat = "HH:mm"
        let nowTimeString = timeFormatter.string(from: Date())

        for interval in intervals {
            let times = interval.components(separatedBy: " - ")
            guard times.count == 2 else {
                continue
            }

            let startTime = times[0]
            let endTime = times[1]

            if nowTimeString >= startTime && nowTimeString <= endTime {
                return true
            }

            if startTime > endTime && nowTimeString <= endTime {
                return true
            }
        }
        return false
    }
}

private extension Coordinate {
    var location: CLLocation {
        CLLocation(latitude: latitude, longitude: longitude)
    }
}
