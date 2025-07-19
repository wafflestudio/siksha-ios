//
//  OperatingHoursTable.swift
//  Siksha
//
//  Created by 박종석 on 2021/05/02.
//

import SwiftUI

struct OperatingHoursCell: View {
    private let type: String
    private var hours = [(String, String)]()
    
    init(type: String, hours: [String], isFestivalRestaurant: Bool) {
        self.type = type
        
        if hours.count == 3 {
            self.hours.append(("BreakfastTime", hours[0]))
            self.hours.append(("LunchTime", hours[1]))
            self.hours.append(("DinnerTime", hours[2]))
        } else if hours.count == 2 {
            if isFestivalRestaurant {
                self.hours.append(("5/13, 5/14", hours[0]))
                self.hours.append(("5/15", hours[1]))
            } else {
                self.hours.append(("LunchTime", hours[0]))
                self.hours.append(("DinnerTime", hours[1]))
            }
        } else if hours.count == 1 {
            self.hours.append(("", hours[0]))
        }
    }
    
    var body: some View {
        HStack(alignment: .top) {
            Text(type)
                .customFont(font: .text14(weight: .Bold))
            Spacer()
        
            if hours.count > 0 {
                VStack(alignment: .trailing, spacing: 4) {
                    ForEach(hours, id: \.0) { hourType, hour in
                        HStack(spacing: 0.5) {
                            Image(hourType)
                                .resizable()
                                .frame(width:20,height:20)
                            Text(hour)
                                .customFont(font: .text14(weight: .Regular))
                        }
                        .padding(.zero)
                    }
                }.padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 6))
            } else {
                Text("정보가 없습니다")
                    .customFont(font: .text14(weight: .Regular))
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 7))
            }
        }
        .padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
    }
}

struct OperatingHoursTable: View {
    private let wdHours: [String]
    private let weHours: [String]
    private let hoHours: [String]
    private let isFestivalRestaurant: Bool
    
    private let dividerColor = Color.init(red: 236/255, green: 236/255, blue: 236/255)
    
    init(hours: [String], isFestivalRestaurant: Bool) {
        self.wdHours = hours[0].split(separator: "\n").map { String($0) }
        self.weHours = hours[1].split(separator: "\n").map { String($0) }
        self.hoHours = hours[2].split(separator: "\n").map { String($0) }
        self.isFestivalRestaurant = isFestivalRestaurant
    }
    
    var body: some View {
        VStack(spacing:0) {
            OperatingHoursCell(type: "주중", hours: wdHours, isFestivalRestaurant: self.isFestivalRestaurant)
            
            dividerColor
                .frame(height: 1)
                .frame(maxWidth: .infinity)
                .padding([.leading, .trailing], 16)
            
            OperatingHoursCell(type: "토요일", hours: weHours, isFestivalRestaurant: self.isFestivalRestaurant)
            
            dividerColor
                .frame(height: 1)
                .frame(maxWidth: .infinity)
                .padding([.leading, .trailing], 16)
            
            OperatingHoursCell(type: "휴일", hours: hoHours, isFestivalRestaurant: self.isFestivalRestaurant)
        }
    }
}

struct OperatingHoursTable_Previews: PreviewProvider {
    static var previews: some View {
        var operatingHours = ["", "", ""]
        operatingHours[0] = "11:30 - 13:30\n17:30 - 19:30"
        operatingHours[1] = "11:30 - 13:30\n17:30 - 18:30"

        
        return
        VStack(spacing:0){
            Color(.black)
                .frame(height:1)
                .padding(.zero)
            OperatingHoursTable(hours: operatingHours, isFestivalRestaurant: false)
        }
        .preferredColorScheme(.light)
    }
}
