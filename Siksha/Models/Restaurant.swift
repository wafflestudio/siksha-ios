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
    var openHours = Dictionary<String, [String]>()
    @objc dynamic var weekdays: String = ""
    @objc dynamic var saturday: String = ""
    @objc dynamic var holiday: String = ""
    var menus = List<Meal>()
    
    convenience init(_ json: JSON) {
        self.init()
        self.id = json["id"].intValue
        self.code = json["code"].stringValue
        self.nameKr = json["name_kr"].stringValue
        self.nameEn = json["name_en"].stringValue
        self.addr = json["addr"].stringValue
        self.lat = json["lat"].stringValue
        self.lng = json["lng"].stringValue
        self.openHours["weekdays"] = json["etc"]["operating_hours"]["weekdays"].arrayValue.map{$0.stringValue}
        self.openHours["saturday"] = json["etc"]["operating_hours"]["saturday"].arrayValue.map{$0.stringValue}
        self.openHours["holiday"] = json["etc"]["operating_hours"]["holiday"].arrayValue.map{$0.stringValue}

        getOpenHours(dictionary: self.openHours)
        addMenus(json["menus"])
    }
    
    private func addMenus(_ json: JSON) {
        json.forEach { (str, mealJson) in
            let newMeal = Meal(mealJson)
            self.menus.append(newMeal)
        }
    }
    
    private func getOpenHours(dictionary: [String : [String]]) {
        for (kind, list) in dictionary {
            if (kind == "weekdays" && list != []) {
                list.forEach { time in
                    self.weekdays += time + "\n"
                }
            }
            if (kind == "saturday" && list != []) {
                list.forEach { time in
                    self.saturday += time + "\n"
                }
            }
            if (kind == "holiday" && list != []) {
                list.forEach { time in
                    self.holiday += time + "\n"
                }
            }
        }
    }
}
