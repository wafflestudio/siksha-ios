//
//  MenuModel.swift
//  Siksha
//
//  Created by Jihyeon on 2/12/26.
//

import Foundation

struct MenuModel: Identifiable, Sendable {
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
