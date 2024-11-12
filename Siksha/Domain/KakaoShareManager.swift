//
//  KakaoShareManager.swift
//  Siksha
//
//  Created by 이수민 on 11/10/24.
//

import UIKit
import SwiftUI

import KakaoSDKCommon
import KakaoSDKShare
import KakaoSDKTemplate
import KakaoSDKAuth

class KakaoShareManager: ObservableObject {
    @Published var showWebView = false
    @Published var urlToLoad: String?
    
    let kakaoAppKey = (UIApplication.shared.delegate as! AppDelegate).configDict?.object(forKey: "kakao_app_key") as! String
    
    var kakaoShareInfo: [String: String] = [:]
    var maxPlaces = 0
    
    func setTempArgs(restaurant: Restaurant) {
        kakaoShareInfo["restuarant"] = restaurant.nameKr
        let maxMenus = min(restaurant.menus.count, 5)
        switch restaurant.menus.count <= 5 {
        case true:
            for i in 0...maxPlaces-1 {
                kakaoShareInfo["menu\(i+1)"] = restaurant.menus[i].nameKr
                kakaoShareInfo["price\(i+1)"] = "\(restaurant.menus[i].price)원"
            }
            for i in maxPlaces...5 {
                kakaoShareInfo["menu\(i+1)"] = nil
                kakaoShareInfo["price\(i+1)"] = nil
            }
        case false:
            for i in 0...4 {
                kakaoShareInfo["menu\(i+1)"] = restaurant.menus[i].nameKr
                kakaoShareInfo["price\(i+1)"] = "\(restaurant.menus[i].price)원"
            }
        }
    }
    
    func shareToKakao(restaurant: Restaurant) {
        if !AuthApi.hasToken() {
            // Generate Redirect URI
            let redirectURI = "kakao\(kakaoAppKey)://oauth"
            // Redirect to Kakao login page
            let loginUrl = "https://kauth.kakao.com/oauth/authorize?client_id=\(kakaoAppKey)&redirect_uri=\(redirectURI)&response_type=code"
            urlToLoad = loginUrl
            showWebView = true
            return
        }
        
        let templateId: Int64 = ###
        setTempArgs(restaurant: restaurant)
        
        // Check if KakaoTalk is installed
        if ShareApi.isKakaoTalkSharingAvailable() {
            ShareApi.shared.shareCustom(
                templateId: templateId,
                templateArgs: kakaoShareInfo) { (sharingResult, error) in
                    if let error = error {
                        print(error)
                    }
                    else {
                        print("shareCustom() success.")
                        if let sharingResult = sharingResult {
                            UIApplication.shared.open(sharingResult.url, options: [:], completionHandler: nil)
                        }
                    }
                }
        } else {
            if let sharingResult = ShareApi.shared.makeCustomUrl(templateId: templateId, templateArgs: kakaoShareInfo) {
                print("makeCustomURL success")
                urlToLoad = sharingResult.absoluteString
                showWebView = true
            } else {
                let error = NSError(domain: "CustomURL", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create custom URL"])
                print(error)
            }
        }
    }
}
