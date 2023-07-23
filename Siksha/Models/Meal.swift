//
//  Meal.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/01.
//

import Foundation
import Realm
import RealmSwift

class Meal: Object{
    @objc dynamic var id: Int = 0
    @objc dynamic var code: String = ""
    @objc dynamic var nameKr: String = ""
    @objc dynamic var nameEn: String = ""
    @objc dynamic var price: Int = 0
    @objc dynamic var score: Double = 0
    @objc dynamic var reviewCnt: Int = 0
    var etc = List<String>()
    
    convenience init(_ response:MenuResponse){
        self.init()
        self.id = response.id
        self.code = response.code
        self.nameKr = response.name_kr
        self.nameEn = response.name_en ?? ""
        self.price = response.price ?? 0
        self.score = response.score ?? 0.0
        self.reviewCnt = response.review_cnt
        response.etc.forEach{
            str in self.etc.append(str)
        }
    }
}

