//
//  SettingsViewModel.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/01.
//

import Foundation
import Combine

class SettingsViewModel: ObservableObject {
    
    private var cancellables = Set<AnyCancellable>()
        
        @Published var noMenuHide = false
        
        init() {
            noMenuHide = UserDefaults.standard.bool(forKey: "noMenuHide")
            
            $noMenuHide
                .sink { hide in
                    UserDefaults.standard.set(hide, forKey: "noMenuHide")
                }
                .store(in: &cancellables)
        }
    
}
