//
//  MealSectionDisplaySpecifications.swift
//  Siksha
//
//  Created by Codex on 6/17/26.
//

import CoreLocation
import Foundation

struct RestaurantDisplaySpecificationContext {
    let filters: MenuFilters
    let personalRestaurantById: [Int: PersonalRestaurantModel]
    let shouldUseDefaultRestaurantPreference: Bool
    let currentLocation: CLLocation?

    func personalRestaurant(for restaurant: RestaurantModel) -> PersonalRestaurantModel? {
        personalRestaurantById[restaurant.id]
    }

    func isVisible(_ restaurant: RestaurantModel) -> Bool {
        personalRestaurant(for: restaurant)?.visible ?? shouldUseDefaultRestaurantPreference
    }

    func isLiked(_ restaurant: RestaurantModel) -> Bool {
        personalRestaurant(for: restaurant)?.liked ?? false
    }
}

protocol RestaurantDisplaySpecification {
    func isSatisfied(by restaurant: RestaurantModel, context: RestaurantDisplaySpecificationContext) -> Bool
}

struct CompositeRestaurantDisplaySpecification: RestaurantDisplaySpecification {
    private let specifications: [any RestaurantDisplaySpecification]

    init(specifications: [any RestaurantDisplaySpecification]) {
        self.specifications = specifications
    }

    func isSatisfied(by restaurant: RestaurantModel, context: RestaurantDisplaySpecificationContext) -> Bool {
        specifications.allSatisfy { $0.isSatisfied(by: restaurant, context: context) }
    }
}

struct VisibleRestaurantSpecification: RestaurantDisplaySpecification {
    func isSatisfied(by restaurant: RestaurantModel, context: RestaurantDisplaySpecificationContext) -> Bool {
        context.isVisible(restaurant)
    }
}

struct OpenRestaurantSpecification: RestaurantDisplaySpecification {
    private let operatingStatusPolicy: RestaurantOperatingStatusPolicy

    init(operatingStatusPolicy: RestaurantOperatingStatusPolicy) {
        self.operatingStatusPolicy = operatingStatusPolicy
    }

    func isSatisfied(by restaurant: RestaurantModel, context: RestaurantDisplaySpecificationContext) -> Bool {
        guard context.filters.isOpen == true else {
            return true
        }
        return operatingStatusPolicy.isOpen(restaurant)
    }
}

struct FavoriteRestaurantSpecification: RestaurantDisplaySpecification {
    func isSatisfied(by restaurant: RestaurantModel, context: RestaurantDisplaySpecificationContext) -> Bool {
        guard context.filters.isFavorite == true else {
            return true
        }
        return context.isLiked(restaurant)
    }
}

struct DistanceRestaurantSpecification: RestaurantDisplaySpecification {
    func isSatisfied(by restaurant: RestaurantModel, context: RestaurantDisplaySpecificationContext) -> Bool {
        guard let distance = context.filters.distance else {
            return true
        }

        guard let currentLocation = context.currentLocation,
              let restaurantLocation = restaurant.coordinate?.location else {
            return false
        }

        return currentLocation.distance(from: restaurantLocation) <= Double(distance)
    }
}

struct MenuDisplaySpecificationContext {
    let filters: MenuFilters
    let maxPrice: Int
}

protocol MenuDisplaySpecification {
    func isSatisfied(by menu: MenuModel, context: MenuDisplaySpecificationContext) -> Bool
}

struct CompositeMenuDisplaySpecification: MenuDisplaySpecification {
    private let specifications: [any MenuDisplaySpecification]

    init(specifications: [any MenuDisplaySpecification]) {
        self.specifications = specifications
    }

    func isSatisfied(by menu: MenuModel, context: MenuDisplaySpecificationContext) -> Bool {
        specifications.allSatisfy { $0.isSatisfied(by: menu, context: context) }
    }
}

struct PriceMenuSpecification: MenuDisplaySpecification {
    func isSatisfied(by menu: MenuModel, context: MenuDisplaySpecificationContext) -> Bool {
        guard let priceRange = context.filters.priceRange else {
            return true
        }

        if priceRange.upperBound < context.maxPrice {
            return priceRange.contains(menu.price)
        }
        return menu.price >= priceRange.lowerBound
    }
}

struct ReviewedMenuSpecification: MenuDisplaySpecification {
    func isSatisfied(by menu: MenuModel, context: MenuDisplaySpecificationContext) -> Bool {
        guard context.filters.hasReview == true else {
            return true
        }
        return menu.reviewCount > 0
    }
}

struct RatingMenuSpecification: MenuDisplaySpecification {
    func isSatisfied(by menu: MenuModel, context: MenuDisplaySpecificationContext) -> Bool {
        guard let minimumRating = context.filters.minimumRating else {
            return true
        }
        return menu.score >= Double(minimumRating)
    }
}

private extension Coordinate {
    var location: CLLocation {
        CLLocation(latitude: latitude, longitude: longitude)
    }
}
