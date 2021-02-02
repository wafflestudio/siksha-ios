//
//  DailyMenuViewModel.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/03.
//

import Foundation
import Combine

class DailyMenuViewModel: ObservableObject {
    @Published var selectedPage: Int = 0
    @Published var scroll: Int = -1
    
    init(_ day: DaySelection){
    }
}
