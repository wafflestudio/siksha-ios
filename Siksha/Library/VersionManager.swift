//
//  VersionManager.swift
//  Siksha
//
//  Created by 이지현 on 5/26/24.
//

import Alamofire
import Foundation

class VersionManager {
    static let shared = VersionManager()
    
    func checkAppVersion(callback: ((_ updateAvailable: Bool, _ currentVersion: String, _ appStoreVersion: String) -> Void)? = nil) {
        
        guard let dictionary = Bundle.main.infoDictionary,
              let currentVersion = dictionary["CFBundleShortVersionString"] as? String else { return }
        
        AF.request("https://itunes.apple.com/lookup?id=1032700617").responseJSON { response in
            switch response.result {
            case let .success(value):
                if let json = value as? NSDictionary,
                   let results = json["results"] as? NSArray,
                   let entry = results.firstObject as? NSDictionary,
                   let appStoreVersion = entry["version"] as? String {
                    let compareVersion = currentVersion.compare(appStoreVersion, options: .numeric)
                    var updateAvailable = false
                    if compareVersion == .orderedAscending {
                        updateAvailable = true
                    }
                    callback?(updateAvailable, currentVersion, appStoreVersion)
                } else {
                    callback?(false, currentVersion, "Unknown")
                }
            case let .failure(error):
                print(error)
                callback?(false, currentVersion, "Error")
            }
        }
        
    }
    
    private init() {}
}
