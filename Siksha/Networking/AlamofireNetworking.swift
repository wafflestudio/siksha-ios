//
//  AlamofireNetworking.swift
//  Siksha
//
//  Created by 한상현 on 2023/09/11.
//

import Combine
import Alamofire

final class AlamofireNetworking: NetworkModuleProtocol {
    func request<T: Decodable>(endpoint: SikshaAPI, params: [String : String]?) -> AnyPublisher<T, Error> {
        let request = AF.request(endpoint)
        
        return request
            .validate()
            .publishDecodable(type: T.self)
            .value()
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
}
