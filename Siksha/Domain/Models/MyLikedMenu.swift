//
//  MyLikedMenu.swift
//  Siksha
//
//  Created by 박정헌 on 9/18/25.
//
struct RestaurantLikedMenuGroup: Hashable, Equatable, Sendable {
    var id: Int
    var name: String
    var menus: [MyLikedMenu]
}

struct MyLikedMenu: Equatable, Hashable, Sendable {
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
    var alarm = false
}
