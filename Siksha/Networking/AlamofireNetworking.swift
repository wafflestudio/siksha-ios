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
        if(endpoint.multiPartFormDataNeeded){
            request = AF.upload(multipartFormData: endpoint.multipartFormData!, with: endpoint)
            

        }
        else{
             request = AF.request(endpoint)

        }
        return request
            .validate()
            .publishDecodable(type: T.self)
           
            .value()
            .handleEvents(receiveCompletion: {_ in
                if let data = request.data {
                    print(String(bytes:data,encoding:.utf8))
                }
            }
                )
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
}
