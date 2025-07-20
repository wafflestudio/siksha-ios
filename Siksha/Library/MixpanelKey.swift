//
//  MixpanelKey.swift
//  Siksha
//
//  Created by 이지현 on 7/20/25.
//

import Foundation

enum MixpanelKey {

    enum Event: String {
        case filterModalOpened = "filter_modal_opened"
        case filterToggled = "instant_filter_toggled"
        case filterReset = "filter_reset"
        case filterModalApplied = "filter_modal_applied"
    }
    
    enum PropertyKey: String {
        case entryPoint = "entry_point"
        case pageName = "page_name"
        case filterType = "filter_type"
        case filterValue = "filter_value"
        case pageName = "page_name"
        case appliedFilterOptions = "applied_filter_options"
    }
    
    enum PageName: String {
        case `default` = "store_list_page"
        case favorite = "favorites_list_page"
    }

    enum EntryPoint: String {
        case main      = "main_filter"
        case distance  = "distance_filter"
        case price     = "price_filter"
        case rating    = "rating_filter"
        case category  = "category_filter"
    }

    enum FilterOption: String {
        case priceMin      = "price_min"
        case priceMax      = "price_max"
        case minRating     = "min_rating"
        case isOpenNow     = "is_open_now"
        case hasReviews    = "has_reviews"
        case maxDistanceKm = "max_distance_km"
    }
}
