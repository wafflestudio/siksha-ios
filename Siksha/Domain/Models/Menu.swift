//
//  Menu.swift
//  Siksha
//
//  Created by Jihyeon on 2/12/26.
//

import Foundation

struct Menu: Identifiable {
    let id: Int
    let code: String
    let nameKr: String
    let nameEn: String
    let price: Int
    let score: Double
    let reviewCount: Int
    let isLiked: Bool
    let likeCount: Int
    let imageURLString: [String]
}
