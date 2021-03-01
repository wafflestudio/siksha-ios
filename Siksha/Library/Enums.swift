//
//  Enums.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/03.
//

import Foundation

enum DaySelection: Int {
    case today = 0
    case tomorrow = 1
}

enum TypeSelection: Int {
    case breakfast = 0
    case lunch = 1
    case dinner = 2
}

enum Result {
    case failed
    case succeeded
    case loading
    case idle
}
