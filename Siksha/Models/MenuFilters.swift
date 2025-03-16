//
//  MenuFilters.swift
//  Siksha
//
//  Created by 이지현 on 3/16/25.
//

import Foundation

struct MenuFilters:Codable {
    var distance: Int? = nil               // Distance in meters (e.g., 400m); nil = all distances
    var priceRange: ClosedRange<Int>? = nil // Price range (e.g., 5000원 ~ 8000원); nil = all prices
    var isOpen: Bool? = nil                // Open status; true = open only, nil = open + closed
    var hasReview: Bool? = nil             // Review status; true = with reviews only, nil = review + no review
    var minimumRating: Float? = nil        // Minimum rating (e.g., 3.5); nil = all ratings
    var categories: [String]? = nil            // Category filter (e.g., 한식, 중식); nil = all categories
}
