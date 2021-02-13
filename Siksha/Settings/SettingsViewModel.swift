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
    
    var _appState: AppState? = nil
    var appState: AppState? {
        get {
            return _appState
        }
        set(newVal) {
            if let state = newVal {
                state.$getResult
                    .sink { [weak self] result in
                        guard let self = self else { return }
                        if result == .failed {
                            self.getMenuError = true
                        }
                        
                        self.refreshMenu = false
                    }
                    .store(in: &cancellables)
                
                _appState = newVal
            }
        }
    }
    
    @Published var noMenuHide = false
    @Published var refreshMenu = false
    @Published var getMenuError = false
    
    init() {
        noMenuHide = UserDefaults.standard.bool(forKey: "noMenuHide")
        
        $noMenuHide
            .sink { hide in
                UserDefaults.standard.set(hide, forKey: "noMenuHide")
            }
            .store(in: &cancellables)
        
        $refreshMenu
            .filter { $0 }
            .sink { [weak self] _ in
                guard let self = self else { return }
                guard let appState = self.appState else {
                    self.getMenuError = true
                    self.refreshMenu = false
                    return
                }
                appState.getMenus()
            }
            .store(in: &cancellables)
    }
}
