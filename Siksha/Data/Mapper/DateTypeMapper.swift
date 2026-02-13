//
//  DateTypeMapper.swift
//  Siksha
//
//  Created by Jihyeon on 2/13/26.
//

import Foundation

enum DateTypeMapper {
    static func toModel(_ dto: String) -> DateType {
        switch dto.uppercased() {
        case "WEEKDAY": return .weekday
        case "SATURDAY": return .saturday
        case "HOLIDAY": return .holiday
        default: return .weekday
        }
    }
}
