//
//  MainViewModel.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/01.
//

import Foundation
import Combine

class MainViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    
    @Published var selectedPage: Int = 0
    @Published var scroll: Int = -1
    
    init() {
    }
}
