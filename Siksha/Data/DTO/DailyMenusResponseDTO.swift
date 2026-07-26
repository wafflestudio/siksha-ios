//
//  DailyMenusResponseDTO.swift
//  Siksha
//
//  Created by Jihyeon on 2/13/26.
//

import Foundation

struct DailyMenusResponseDTO: Decodable, Sendable {
    let count: Int
    let result: [DailyMenusDTO]
}
