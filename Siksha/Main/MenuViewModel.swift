//
//  MenuViewModel.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/01.
//

import Foundation
import Combine

class MenuViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    @Published var selectedPage: Int = 0
    @Published var scroll: Int = 0
    
    var appState: AppState? = nil
    
    init() {
        $selectedPage
            .sink { [weak self] page in
                guard let self = self, let appState = self.appState else {
                    return
                }
                
                if page == 0 {
                    appState.ratingEnabled = true
                } else {
                    appState.ratingEnabled = false
                }
            }
            .store(in: &cancellables)
        
        $scroll
            .filter { $0 != 0 }
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.scroll = 0
            }
            .store(in: &cancellables)
    }
}
