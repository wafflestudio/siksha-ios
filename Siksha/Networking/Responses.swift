//
//  Responses.swift
//  Siksha
//
//  Created by 박종석 on 2021/03/11.
//

import Foundation

struct ReviewResponse: Codable {
    var totalCount: Int
    var reviews: [Review]
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case reviews = "result"
    }
}

struct CommentRecommendationResponse: Codable {
    var comment: String
}

struct UserInfoResponse: Codable {
    var id: Int
    var type: String
    var identity: String
    var etc: String?
}

struct ScoreDistributionResponse: Codable {
    var dist: [Int]
}
struct MenuIdResponse:Codable{
    var is_liked:Bool
}
struct MenuResponse:Codable{
    var id:Int
    var code:String
    var name_kr:String
    var name_en:String?
    var price:Int?
    var created_at:String
    var updated_at:String
    var score:Double?
    var review_cnt:Int
}
struct RestaurantResponse:Codable{
    var id:Int
    var code:String
    var name_kr:String
    var name_en:String?
    var addr:String?
    var lat:Double?
    var lng:Double?
    var etc:EtcResponse?
    var menus:[MenuResponse]?
    struct EtcResponse:Codable{
        var operating_hours:OperatingHoursResponse
        struct OperatingHoursResponse:Codable{
            var weekdays:[String]
            var saturday:[String]
            var holiday:[String]
        }
    }
    var created_at:String
    var updated_at:String
}
struct RestaurantsResponse:Codable{
    var count:Int
    var result:[RestaurantResponse]
   
}
struct DailyMenuResponse:Codable{
    var date:String
    var BR:[RestaurantResponse]
    var LU:[RestaurantResponse]
    var DN:[RestaurantResponse]
}
struct MenusResponse:Codable{
    var count:Int
    var result:[DailyMenuResponse]

}
struct AccessTokenResponse:Codable{
    var access_token:String
}
struct AppStoreResponse:Codable{
    var results:[VersionResponse]
    struct VersionResponse:Codable{
        var version:String
    }
}
