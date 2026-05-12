//
//  Date+Extensions.swift
//  Siksha
//
//  Created by Jihyeon on 2/25/26.
//

import Foundation

extension Date {
    var yyyyMMdd: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_kr")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }
}
