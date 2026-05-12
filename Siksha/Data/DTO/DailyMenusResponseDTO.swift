//
//  DailyMenusResponseDTO.swift
//  Siksha
//
//  Created by Jihyeon on 2/13/26.
//

import Foundation

struct DailyMenusResponseDTO: Decodable {
    let count: Int
    let result: [DailyMenusDTO]
}
