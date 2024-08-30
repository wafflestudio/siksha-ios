//
//  KeyboardResponder.swift
//  Siksha
//
//  Created by 이지현 on 8/30/24.
//

import SwiftUI
import Combine


class KeyboardResponder: ObservableObject {
    @Published var currentHeight: CGFloat = 0
    @Published var didKeyboardShow = false
    private var cancellables: Set<AnyCancellable> = []

    init() {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .sink { [weak self] notification in
                self?.keyboardNotification(notification: notification)
            }.store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UIResponder.keyboardDidShowNotification)
           .sink { [weak self] _ in
               DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                   self?.didKeyboardShow = true
               }
           }.store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .sink { [weak self] _ in
                self?.didKeyboardShow = false
                self?.currentHeight = 0
            }.store(in: &cancellables)
    }

    private func keyboardNotification(notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            withAnimation(.easeOut(duration: 0.25)) {
                self.currentHeight = keyboardFrame.height
            }
        }
    }
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
}
