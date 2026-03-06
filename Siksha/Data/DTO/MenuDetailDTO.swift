//
//  MenuDetailDTO.swift
//  Siksha
//
//  Created by Jihyeon on 2/13/26.
//

import Foundation

struct MenuDetailDTO: Decodable {
    let createdAt: Date
    let updatedAt: Date
    let id: Int
    let restaurantId: Int
    let code: String
    let date: Date
    let type: String
    let nameKr: String?
    let nameEn: String?
    let price: Int?
    let score: Double?
    let reviewCnt: Int
    let likeCnt: Int
    let isLiked: Bool
    let etc: [String]
}
