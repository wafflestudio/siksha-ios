//
//  Config.swift
//  Siksha
//
//  Created by 박종석 on 2021/03/05.
//

import Foundation

class Config {
    static let shared = Config()
    
    private init() {}
    
    var baseURL: String! = nil
}
