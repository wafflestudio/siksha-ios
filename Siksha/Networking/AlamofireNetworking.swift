//
//  AlamofireNetworking.swift
//  Siksha
//
//  Created by 한상현 on 2023/09/11.
//

import Combine
import Alamofire

final class AlamofireNetworking: NetworkModuleProtocol {
    func request<T: Decodable>(endpoint: SikshaAPI) -> AnyPublisher<T, Error> {
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
                if error.isResponseValidationError {
                    if let statusCode = error.responseCode {
                        switch statusCode {
                        case 409:
                            return NetworkError.conflict
                        default:
                            return error
                        }
                    }
                }
                return error
            }
            .eraseToAnyPublisher()
    }
    
    func requestWithNoContent(endpoint: SikshaAPI) -> AnyPublisher<Void, Error> {
        let request = AF.request(endpoint)
        
        return request
            .validate()
            .publishData() // Use publishData() to get a publisher
            .map { _ in () } // Map the data response to Void, since no content is expected
            .mapError { $0 as Error } // Map any errors to the Error type
            .eraseToAnyPublisher()
    }
}
