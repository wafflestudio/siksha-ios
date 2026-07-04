//
//  Networking.swift
//  Siksha
//
//  Created by 박종석 on 2021/05/07.
//

import Foundation
import Alamofire

class Networking {
    static let shared = Networking()
    
    private init() {}
    
    func testLogin() -> DataResponsePublisher<Data> {
        let request = AF.request(SikshaAPI.testLogin)
        return request.validate().publishData()
    }
    
    func getAccessToken(token: String, endPoint: String) -> DataResponsePublisher<Data> {
        let request = AF.request(SikshaAPI.getAccessToken(token: token, endPoint: endPoint))
        
        return request.validate().publishData()
    }
    
    func refreshAccessToken(token: String) -> DataResponsePublisher<Data> {
        let request = AF.request(SikshaAPI.refreshAccessToken(token: token))
        
        return request.validate().publishData()
    }
}
