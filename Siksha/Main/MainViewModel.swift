//
//  MainViewModel.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/01.
//

import Foundation
import Combine

enum DaySelection: Int {
    case today = 0
    case tomorrow = 1
}

enum TypeSelection: Int {
    case breakfast = 0
    case lunch = 1
    case dinner = 2
}

class MainViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    
    @Published var selectedPage: Int = 0
    
    var menus: [Menu] = []
    
    init() {
    }
}
