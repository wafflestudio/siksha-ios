//
//  DailyMenu.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/01.
//

import Foundation
import SwiftyJSON
import RealmSwift

class DailyMenu: Object {
    @objc dynamic var date: String = ""
    @objc dynamic var dateType:Int = 0
    var br = List<Restaurant>()
    var lu = List<Restaurant>()
    var dn = List<Restaurant>()
    
    override static func primaryKey() -> String? {
        return "date"
    }
    
    override init() {
        super.init()
    }
    
    convenience init(_ json: JSON){
        self.init()
        self.date = json["date"].stringValue
        switch(json["date_type"]){
        case "WEEKDAY":
            dateType = Restaurant.OperatingHourType.weekdays.rawValue
        case "SATURDAY":
            dateType = Restaurant.OperatingHourType.saturday.rawValue
        case "HOLIDAY":
            dateType = Restaurant.OperatingHourType.holiday.rawValue
        default:
            dateType = 0
        }
        
        addRestaurants(list: br, json["br"])
        addRestaurants(list: lu, json["lu"])
        addRestaurants(list: dn, json["dn"])
    }
   
    init(date: String, dateType: String, br: [Restaurant], lu: [Restaurant], dn: [Restaurant]) {
        super.init()
        self.date = date
        self.dateType = getDateTypeInt(dateType)
        self.br.append(objectsIn: br)
        self.lu.append(objectsIn: lu)
        self.dn.append(objectsIn: dn)
    }
    
    private func getDateTypeInt(_ str: String) -> Int {
        switch(str.uppercased()){
        case "WEEKDAY":
            return Restaurant.OperatingHourType.weekdays.rawValue
        case "SATURDAY":
            return Restaurant.OperatingHourType.saturday.rawValue
        case "HOLIDAY":
            return Restaurant.OperatingHourType.holiday.rawValue
        default:
            return 0
        }
    }
    
    private func addRestaurants(list: List<Restaurant>, _ json: JSON){
        json.forEach { (str, restJson) in
            let newRest = Restaurant(restJson)
            list.append(newRest)
        }
    }
    
    func getRestaurants(_ type: TypeSelection) -> List<Restaurant> {
        switch(type) {
        case .breakfast:
            return br
        case .lunch:
            return lu
        case .dinner:
            return dn
        }
    }
}

extension DailyMenu {
    func toModel() -> DailyMenuModel {
        DailyMenuModel(
            date: date,
            dateType: DateType.getType(from: dateType),
            breakfast: br.map { $0.toModel() },
            lunch: lu.map { $0.toModel() },
            dinner: dn.map { $0.toModel() }
        )
    }
}
