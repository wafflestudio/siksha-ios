//
//  Restaurant.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/01.
//

import Foundation
import Realm
import RealmSwift

final class Restaurant: Object{
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

    convenience init(_ response:RestaurantResponse){
        self.init()
        self.id = response.id
        self.code = response.code
        self.nameKr = response.name_kr
        self.nameEn = response.name_en ?? ""
        self.addr = response.addr == nil ? "" :(
            response.addr!.replacingOccurrences(of: "서울 관악구 관악로 1 서울대학교 ", with: "")
        )
        self.lat = "\(response.lat ?? -1)"
        self.lng = "\(response.lng ?? -1)"
        if let operatingHours = response.etc?.operating_hours{
            self.operatingHours.append(getOperatingHoursAsString(operatingHours.weekdays))
            self.operatingHours.append(getOperatingHoursAsString(operatingHours.saturday))
            self.operatingHours.append(getOperatingHoursAsString(operatingHours.holiday))
        }
        addMenus(response.menus ?? [])
        
        
        
    }
    private func getOperatingHoursAsString(_ operatingHours:[String]) -> String{
        var hours = ""
        operatingHours.forEach{
            time in hours += time + "\n"
            
        }
        return hours.replacingOccurrences(of: "-", with: " - ")
    }
 
    private func addMenus(_ menus:[MenuResponse]){
        menus.forEach{
            menu in
            self.menus.append(Meal(menu))
        }
    }
}
