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
    
    let templateId = Config.shared.kakaoShareTemplateId
    
    var kakaoShareInfo: [String: String] = [:]
    var maxMenus = 0
    
    let dateFormatter = DateFormatter()
    
    func setTempArgs(restaurant: Restaurant, selectedDateString: String) {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let today = dateFormatter.string(from: Date())
        kakaoShareInfo["date"] = selectedDateString == today ? "오늘" : selectedDateString
        
        kakaoShareInfo["restaurant"] = restaurant.nameKr
        let maxMenus = min(restaurant.menus.count, 5)
        switch restaurant.menus.count <= 5 {
        case true:
            if maxMenus > 0{
                for i in 0...maxMenus-1 {
                    kakaoShareInfo["menu\(i+1)"] = restaurant.menus[i].nameKr
                    kakaoShareInfo["price\(i+1)"] = restaurant.menus[i].price != 0 ? "\(restaurant.menus[i].price)원" : "-"
                }
            }
            for i in maxMenus...5 {
                kakaoShareInfo["menu\(i+1)"] = nil
                kakaoShareInfo["price\(i+1)"] = nil
            }
        case false:
            for i in 0...4 {
                kakaoShareInfo["menu\(i+1)"] = restaurant.menus[i].nameKr
                kakaoShareInfo["price\(i+1)"] = restaurant.menus[i].price != 0 ? "\(restaurant.menus[i].price)원" : "-"
            }
        }
    }
    
    func shareKakao(restaurant: Restaurant, selectedDateString: String) {
        setTempArgs(restaurant: restaurant, selectedDateString: selectedDateString)
        
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
