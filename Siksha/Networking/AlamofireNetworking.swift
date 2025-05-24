//
//  AlamofireNetworking.swift
//  Siksha
//
//  Created by 한상현 on 2023/09/11.
//

import Combine
import Alamofire

final class AlamofireNetworking: NetworkModuleProtocol {
    func request<T: Decodable>(endpoint: SikshaAPI) -> AnyPublisher<T, AppError> {
        var request:DataRequest
        if(endpoint.multiPartFormDataNeeded) {
            request = AF.upload(multipartFormData: endpoint.multipartFormData!, with: endpoint)
        }
        else { request = AF.request(endpoint) }
        return request
            .validate(statusCode: 200..<300)
            .publishDecodable(type: T.self)
            .value()
            .handleEvents(receiveCompletion: {_ in
                if let data = request.data {
                    print(String(bytes:data,encoding:.utf8) ?? "")
                }
            })
            .mapError { error in
                self.mapToAppError(error: error)
            }
            .eraseToAnyPublisher()
    }
    
    func requestWithNoContent(endpoint: SikshaAPI) -> AnyPublisher<Void, AppError> {
        let request = AF.request(endpoint)

        return request
            .validate()
            .publishData(emptyResponseCodes:[201])
            .tryMap { response in
                if let error = response.error {
                    throw error
                }
                return ()
            }
            .mapError { error in
                if let afError = error as? AFError {
                    return self.mapToAppError(error: afError)
                }
                return .unknownError(error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }

    private func mapToAppError(error: AFError) -> AppError {
        if error.isResponseValidationError {
            if let statusCode = error.responseCode {
                switch statusCode {
                case 409:
                    return .networkError("Conflict error occurred.")
                default:
                    return .networkError("HTTP \(statusCode): \(error.localizedDescription)")
                }
            }
        }
        return .unknownError(error.localizedDescription)
    }
}
