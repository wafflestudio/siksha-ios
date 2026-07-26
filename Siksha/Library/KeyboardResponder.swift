//
//  KeyboardResponder.swift
//  Siksha
//
//  Created by 이지현 on 8/30/24.
//

import Combine
import SwiftUI

@MainActor
final class KeyboardResponder: ObservableObject {
    @Published var currentHeight: CGFloat = 0
    @Published var didKeyboardShow = false
    private var cancellables: Set<AnyCancellable> = []
    private var didShowTask: Task<Void, Never>?
    private let showDelayNanoseconds: UInt64

    init(showDelayNanoseconds: UInt64 = 200_000_000) {
        self.showDelayNanoseconds = showDelayNanoseconds

        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .receive(on: RunLoop.main)
            .sink { [weak self] notification in
                self?.keyboardNotification(notification: notification)
            }.store(in: &cancellables)

        NotificationCenter.default.publisher(for: UIResponder.keyboardDidShowNotification)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.scheduleDidShowUpdate()
            }.store(in: &cancellables)

        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.didShowTask?.cancel()
                self?.didKeyboardShow = false
                self?.currentHeight = 0
            }.store(in: &cancellables)
    }

    private func scheduleDidShowUpdate() {
        didShowTask?.cancel()
        let showDelayNanoseconds = showDelayNanoseconds
        didShowTask = Task { [weak self] in
            do {
                try await Task.sleep(nanoseconds: showDelayNanoseconds)
                try Task.checkCancellation()
                self?.didKeyboardShow = true
            } catch {
                return
            }
        }
    }

    private func keyboardNotification(notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            withAnimation(.easeOut(duration: 0.25)) {
                self.currentHeight = keyboardFrame.height
            }
        }
    }

    deinit {
        didShowTask?.cancel()
    }
}
