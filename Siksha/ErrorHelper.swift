//
//  ErrorHelper.swift
//  Siksha
//
//  Created by Chaehyun Park on 12/22/24.
//

import Foundation

struct ErrorHelper {
    static func categorize(_ error: Error) -> AppError {
        if let urlError = error as? URLError {
            return handleURLError(urlError)
        }
        
        if let decodingError = error as? DecodingError {
            return handleDecodingError(decodingError)
        }

        if let apiError = handleAPIError(error) {
            return apiError
        }

        return .unknownError(error.localizedDescription)
    }

    private static func handleURLError(_ urlError: URLError) -> AppError {
        switch urlError.code {
        case .notConnectedToInternet:
            return .networkError("인터넷 연결이 없습니다.")
        case .timedOut:
            return .networkError("요청 시간이 초과되었습니다.")
        case .cannotFindHost, .cannotConnectToHost:
            return .networkError("서버에 연결할 수 없습니다.")
        case .networkConnectionLost:
            return .networkError("네트워크 연결이 끊어졌습니다.")
        default:
            return .networkError("네트워크 오류: \(urlError.localizedDescription)")
        }
    }

    private static func handleDecodingError(_ decodingError: DecodingError) -> AppError {
        switch decodingError {
        case .dataCorrupted(let context):
            return .parsingError("데이터 손상: \(context.debugDescription)")
        case .keyNotFound(let key, _):
            return .parsingError("필수 키가 누락되었습니다: \(key.stringValue)")
        case .typeMismatch(let type, _):
            return .parsingError("유형 불일치: \(type)")
        case .valueNotFound(let value, _):
            return .parsingError("값을 찾을 수 없습니다: \(value)")
        @unknown default:
            return .parsingError("알 수 없는 디코딩 오류가 발생했습니다.")
        }
    }
    
    private static func handleAPIError(_ error: Error) -> AppError? {
        if let networkError = error as? NetworkError {
            switch networkError {
            case .apiError(let message, let code):
                return .serverError(message, code)
            default:
                return nil
            }
        }
        return nil
    }
}
