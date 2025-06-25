//
//  Config.swift
//  Siksha
//
//  Created by 박종석 on 2021/03/05.
//

import Foundation

final class Config {
    static let shared = Config()
    
    let baseURL: String
    let googleClientId: String
    let naverMapClientId: String
    let kakaoAppKey: String
    let kakaoShareTemplateId: Int64
    
    private let envDict: NSDictionary
    
    private init() {
        #if DEBUG
        let configKey = "debug"
        #else
        let configKey = "release"
        #endif
        
        guard let path = Bundle.main.path(forResource: "config", ofType: "plist"),
              let fullDict = NSDictionary(contentsOfFile: path),
              let envDict = fullDict[configKey] as? NSDictionary else {
            fatalError("Failed to load config.plist or parse \(configKey) environment.")
        }
        
        self.envDict = envDict
        
        self.baseURL = Self.getString(from: envDict, key: .serverURL)
        self.googleClientId = Self.getString(from: envDict, key: .googleClientId)
        self.naverMapClientId = Self.getString(from: envDict, key: .naverMapClientId)
        self.kakaoAppKey = Self.getString(from: envDict, key: .kakaoAppKey)
        self.kakaoShareTemplateId = Self.getInt64(from: envDict, key: .kakaoShareTemplateId)
    }
    
    enum Key: String {
        case serverURL = "server_url"
        case googleClientId = "google_client_id"
        case naverMapClientId = "naver_map_client_id"
        case kakaoAppKey = "kakao_app_key"
        case kakaoShareTemplateId = "kakao_share_template_id"
    }
    
    private static func getString(from dict: NSDictionary, key: Key) -> String {
        guard let value = dict[key.rawValue] as? String else {
            fatalError("Missing or invalid string for key '\(key.rawValue)' in config.plist.")
        }
        return value
    }
    
    private static func getInt64(from dict: NSDictionary, key: Key) -> Int64 {
        guard let str = dict[key.rawValue] as? String,
              let value = Int64(str) else {
            fatalError("Missing or invalid Int64 string for key '\(key.rawValue)' in config.plist.")
        }
        return value
    }
}
