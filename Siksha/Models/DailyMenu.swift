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
    var br = List<Restaurant>()
    var lu = List<Restaurant>()
    var dn = List<Restaurant>()
    
    convenience init(_ json: JSON){
        self.init()
        self.date = json["date"].stringValue
        
        addRestaurants(list: br, json["BR"])
        addRestaurants(list: lu, json["LU"])
        addRestaurants(list: dn, json["DN"])
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
    
    override static func primaryKey() -> String? {
        return "date"
    }
}
