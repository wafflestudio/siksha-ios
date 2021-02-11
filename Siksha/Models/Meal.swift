//
//  Meal.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/01.
//

import Foundation
import SwiftyJSON
import Realm
import RealmSwift

class Meal: Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var code: String = ""
    @objc dynamic var nameKr: String = ""
    @objc dynamic var nameEn: String = ""
    @objc dynamic var price: Int = 0
    @objc dynamic var etc: String = ""
    @objc dynamic var score: Double = 0
    @objc dynamic var reviewCnt: Int = 0
    
    convenience init(_ json: JSON) {
        self.init()
        self.id = json["id"].intValue
        self.code = json["code"].stringValue
        self.nameKr = json["name_kr"].stringValue
        self.nameEn = json["name_en"].stringValue
        self.price = json["price"].intValue
        self.etc = json["etc"].stringValue
        self.score = json["score"].doubleValue
        self.reviewCnt = json["review_cnt"].intValue
    }
}
