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
    enum OperatingHourType : Int {
        case weekdays = 0
        case saturday = 1
        case holiday = 2
        
        var stringValue: String {
            switch self {
            case .weekdays:
                return "weekdays"
            case .saturday:
                return "saturday"
            case .holiday:
                return "holiday"
            }
        }
        
        static var getAllTypes: [OperatingHourType] {
            return [weekdays, saturday, holiday]
        }
    }
    
    @objc dynamic var id: Int = 0
    @objc dynamic var code: String = ""
    @objc dynamic var nameKr: String = ""
    @objc dynamic var nameEn: String = ""
    @objc dynamic var addr: String = ""
    @objc dynamic var lat: String = ""
    @objc dynamic var lng: String = ""
    var operatingHours = List<String>()
    var menus = List<Meal>()
    
    convenience init(_ json: JSON) {
        self.init()
        self.id = json["id"].intValue
        self.code = json["code"].stringValue
        self.nameKr = json["name_kr"].stringValue
        self.nameEn = json["name_en"].stringValue
        self.addr = json["addr"].stringValue.replacingOccurrences(of: "서울 관악구 관악로 1 서울대학교 ", with: "")
        self.lat = json["lat"].stringValue
        self.lng = json["lng"].stringValue
        
        OperatingHourType.getAllTypes.forEach { type in
            let timeList = json["etc"]["operating_hours"][type.stringValue].arrayValue.map{$0.stringValue}
            
            var hours = ""
            timeList.forEach { time in
                hours += time + "\n"
            }
            
            if hours.count == 0 {
                operatingHours.append("정보가 없습니다.")
            } else {
                operatingHours.append(hours.replacingOccurrences(of: "-", with: " ~ "))
            }
        }
        addMenus(json["menus"])
    }
    
    private func addMenus(_ json: JSON) {
        json.forEach { (str, mealJson) in
            let newMeal = Meal(mealJson)
            self.menus.append(newMeal)
        }
    }
}
