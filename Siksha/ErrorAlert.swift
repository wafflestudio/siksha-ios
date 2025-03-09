//
//  ErrorAlert.swift
//  Siksha
//
//  Created by Chaehyun Park on 12/22/24.
//

import SwiftUI

enum AppError: LocalizedError, Identifiable {
    case networkError(String)
    case parsingError(String)
    case unknownError(String)
    case serverError(String, String)

    var id: String { // Required for `Identifiable`
        UUID().uuidString
    }

    var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "Network Error: \(message)"
        case .parsingError(let message):
            return "Parsing Error: \(message)"
        case .serverError(let message, let code):
            return "Server Error (\(code)): \(message)"
        case .unknownError(let message):
            return "Unknown Error: \(message)"
        }
    }
}

struct ErrorAlert: ViewModifier {
    @Binding var error: AppError?

    func body(content: Content) -> some View {
        content
            .alert(item: $error) { error in
                Alert(
                    title: Text("오류"),
                    message: Text(error.errorDescription ?? "예상치 못한 오류가 발생했습니다."),
                    dismissButton: .default(Text("확인")) {
                        self.error = nil // Clear error after dismiss
                    }
                )
            }
    }
}

extension View {
    func errorAlert(error: Binding<AppError?>) -> some View {
        self.modifier(ErrorAlert(error: error))
    }
}
