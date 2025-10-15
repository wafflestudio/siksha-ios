//
//  MyLikedMenu.swift
//  Siksha
//
//  Created by 박정헌 on 9/18/25.
//
struct MyLikedRestaurant:Hashable,Codable,Equatable{
    var id: Int
    var name:String
    var menus: [MyLikedMenu]
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name_kr"
        case menus = "menus"
    }
    
}
struct MyLikedMenu:Codable,Equatable,Hashable{
    var id: Int = 0
    var code: String = ""
    var nameKr: String = ""
    var nameEn: String? = ""
    var price: Int? 
    var score: Double? = 0
    var reviewCnt: Int = 0
    var isLiked: Bool = false
    var likeCnt: Int = 0
    var etc: [String] = []
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case nameKr = "name_kr"
        case nameEn = "name_en"
        case price = "price"
        case score = "score"
        case reviewCnt = "review_cnt"
        case isLiked = "is_liked"
        case likeCnt = "like_cnt"
        case etc = "etc"
    }
}
