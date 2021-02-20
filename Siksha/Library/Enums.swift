//
//  Enums.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/03.
//

import Foundation
import SwiftUI

enum TypeSelection: Int {
    case breakfast = 0
    case lunch = 1
    case dinner = 2
}

struct TypeInfo: Identifiable {
    var id: Int
    var type: TypeSelection
    var icon: String
    var height: CGFloat
    var width: CGFloat
    
    init(type: TypeSelection) {
        self.id = type.rawValue
        self.type = type

        switch(type){
        case .breakfast:
            self.icon = "Breakfast"
            self.width = 20
            self.height = 12
        case .lunch:
            self.icon = "Lunch"
            self.width = 20
            self.height = 20
        case .dinner:
            self.icon = "Dinner"
            self.width = 14
            self.height = 14
        }
    }
}

enum NetworkStatus {
    case loading
    case failed
    case succeeded
    case idle
}
