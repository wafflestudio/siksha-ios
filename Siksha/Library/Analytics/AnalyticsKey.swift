//
//  AnalyticsKey.swift
//  Siksha
//
//  Created by Jihyeon on 8/17/25.
//

import Foundation

enum AnalyticsKey {
    static let entryPoint = "entry_point"
    static let pageName = "page_name"
    static let filterType = "filter_type"
    static let filterValue = "filter_value"
    static let appliedFilterOptions = "applied_filter_options"
}

enum EntryPoint: String {
    case mainFilter     = "main_filter"
    case distanceFilter = "distance_filter"
    case priceFilter    = "price_filter"
    case ratingFilter   = "rating_filter"
    case categoryFilter = "category_filter"
}

enum PageName: String {
    case storeList     = "store_list_page"
    case favoritesList = "favorites_list_page"
}

enum FilterType: String, CaseIterable {
    case isOpenNow      = "is_open_now"
    case hasReviews     = "has_reviews"
    case distance       = "distance"
    case price          = "price"
    case minimumRating  = "min_rating"
    case category       = "category"
}

struct AppliedFilterOptions {
    var priceMin: Int?
    var priceMax: Int?
    var minRating: Float?
    var isOpenNow: Bool?
    var hasReviews: Bool?
    var maxDistanceKm: Double?

    init(priceMin: Int? = nil,
                priceMax: Int? = nil,
                minRating: Float? = nil,
                isOpenNow: Bool? = nil,
                hasReviews: Bool? = nil,
                maxDistanceKm: Double? = nil) {
        self.priceMin = priceMin
        self.priceMax = priceMax
        self.minRating = minRating
        self.isOpenNow = isOpenNow
        self.hasReviews = hasReviews
        self.maxDistanceKm = maxDistanceKm
    }

    /// Mixpanel 전송용 직렬화 (nil 제거)
    var asDictionary: [String: Any] {
        var dict: [String: Any] = [:]
        if let priceMin { dict["price_min"] = priceMin }
        if let priceMax { dict["price_max"] = priceMax }
        if let minRating { dict["min_rating"] = minRating }
        if let isOpenNow { dict["is_open_now"] = isOpenNow }
        if let hasReviews { dict["has_reviews"] = hasReviews }
        if let maxDistanceKm { dict["max_distance_km"] = maxDistanceKm }
        return dict
    }

    /// 적용된 필터 개수
    var appliedCount: Int { asDictionary.count }
}
