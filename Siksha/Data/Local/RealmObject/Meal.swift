//
//  Meal.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/01.
//

import Foundation
import SwiftyJSON
import RealmSwift

class Meal: Object {
    @objc dynamic var realmKey: String = ""
    @objc dynamic var id: Int = 0
    @objc dynamic var code: String = ""
    @objc dynamic var nameKr: String = ""
    @objc dynamic var nameEn: String = ""
    @objc dynamic var price: Int = 0
    @objc dynamic var score: Double = 0
    @objc dynamic var reviewCnt: Int = 0
    @objc dynamic var isLiked: Bool = false
    @objc dynamic var likeCnt: Int = 0
    var etc = List<String>()
    
    override static func primaryKey() -> String? {
        return "realmKey"
    }
    
    override init() {
        super.init()
    }
    
    convenience init(_ json: JSON, menuContext: String? = nil) {
        self.init()
        self.id = json["id"].intValue
        self.realmKey = Self.makeRealmKey(id: id, menuContext: menuContext)
        self.code = json["code"].stringValue
        self.nameKr = json["name_kr"].stringValue
        self.nameEn = json["name_en"].stringValue
        self.price = json["price"].intValue
        self.score = json["score"].doubleValue
        self.isLiked = json["is_liked"].boolValue
        self.reviewCnt = json["review_cnt"].intValue
        self.likeCnt = json["like_cnt"].intValue
        json["etc"].arrayValue.map{ $0.stringValue }.forEach { self.etc.append($0) }
    }
    
    init(id: Int, code: String, nameKr: String, nameEn: String, price: Int, score: Double, reviewCnt: Int, isLiked: Bool, likeCnt: Int, etc: [String]) {
        super.init()
        
        self.id = id
        self.realmKey = Self.makeRealmKey(id: id)
        self.code = code
        self.nameKr = nameKr
        self.nameEn = nameEn
        self.price = price
        self.score = score
        self.reviewCnt = reviewCnt
        self.isLiked = isLiked
        self.likeCnt = likeCnt
        self.etc.append(objectsIn: etc)
    }
    
    func applyMenuContext(_ menuContext: String) {
        realmKey = Self.makeRealmKey(id: id, menuContext: menuContext)
    }
    
    private static func makeRealmKey(id: Int, menuContext: String? = nil) -> String {
        if let menuContext {
            return "\(menuContext):meal:\(id)"
        }
        return "meal:\(id)"
    }
}

extension Meal {
    func toModel() -> MenuModel {
        MenuModel(
            id: id,
            code: code,
            nameKr: nameKr,
            nameEn: nameEn,
            price: price,
            score: score,
            reviewCount: reviewCnt,
            isLiked: isLiked,
            likeCount: likeCnt,
            imageURLStrings: Array(etc)
        )
    }
}
