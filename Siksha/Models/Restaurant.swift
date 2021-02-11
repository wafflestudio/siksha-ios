//
//  Restaurant.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/01.
//

import Foundation
import SwiftyJSON
import Realm
import RealmSwift

class Restaurant: Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var code: String = ""
    @objc dynamic var nameKr: String = ""
    @objc dynamic var nameEn: String = ""
    @objc dynamic var addr: String = ""
    @objc dynamic var lat: String = ""
    @objc dynamic var lng: String = ""
    @objc dynamic var etc: String = ""
    var menus = List<Meal>()
    
    convenience init(_ json: JSON) {
        self.init()
        self.id = json["id"].intValue
        self.code = json["code"].stringValue
        self.nameKr = json["name_kr"].stringValue
        self.nameEn = json["name_kr"].stringValue
        self.addr = json["addr"].stringValue
        self.lat = json["lat"].stringValue
        self.lng = json["lng"].stringValue
        self.etc = json["etc"].stringValue
        
        addMenus(json["menus"])
    }
    
    private func addMenus(_ json: JSON) {
        json.forEach { (str, mealJson) in
            let newMeal = Meal(mealJson)
            self.menus.append(newMeal)
        }
    }
}
