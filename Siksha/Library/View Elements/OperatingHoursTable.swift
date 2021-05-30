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
    
    init(type: String, hours: [String]) {
        self.type = type
        
        if hours.count == 3 {
            self.hours.append(("아침", hours[0]))
            self.hours.append(("점심", hours[1]))
            self.hours.append(("저녁", hours[2]))
        } else if hours.count == 2 {
            self.hours.append(("점심", hours[0]))
            self.hours.append(("저녁", hours[1]))
        } else if hours.count == 1 {
            self.hours.append(("", hours[0]))
        }
    }
    
    var body: some View {
        HStack(alignment: .top) {
            Text(type)
                .font(.custom("NanumSquareOTFR", size: 14))
                .padding(EdgeInsets(top: 0, leading: 3, bottom: 0, trailing: 0))

            
            Spacer()
            
            if hours.count > 0 {
                VStack(spacing: 8) {
                    ForEach(hours, id: \.0) { hourType, hour in
                        HStack(spacing: 10) {
                            Text(hourType)
                                .font(.custom("NanumSquareOTFR", size: 12))
                                .foregroundColor(.init("MainThemeColor"))
                            
                            Text(hour)
                                .font(.custom("NanumSquareOTFR", size: 14))
                                .frame(width: 90, alignment: .trailing)
                        }
                    }
                }
            } else {
                Text("정보가 없습니다")
                    .font(.custom("NanumSquareOTFR", size: 14))
            }
        }
        .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
    }
}

struct OperatingHoursTable: View {
    private let wdHours: [String]
    private let weHours: [String]
    private let hoHours: [String]
    
    private let dividerColor = Color.init(red: 236/255, green: 236/255, blue: 236/255)
    
    init(hours: [String]) {
        self.wdHours = hours[0].split(separator: "\n").map { String($0) }
        self.weHours = hours[1].split(separator: "\n").map { String($0) }
        self.hoHours = hours[2].split(separator: "\n").map { String($0) }
    }
    
    var body: some View {
        VStack {
            OperatingHoursCell(type: "주중", hours: wdHours)
            
            dividerColor
                .frame(height: 1)
                .frame(maxWidth: .infinity)
                .padding([.leading, .trailing], 16)
            
            OperatingHoursCell(type: "토요일", hours: weHours)
            
            dividerColor
                .frame(height: 1)
                .frame(maxWidth: .infinity)
                .padding([.leading, .trailing], 16)
            
            OperatingHoursCell(type: "휴일", hours: hoHours)
        }
    }
}

struct OperatingHoursTable_Previews: PreviewProvider {
    static var previews: some View {
        var operatingHours = ["", "", ""]
        operatingHours[0] = "11:30 - 13:30\n17:30 - 19:30"
        operatingHours[1] = "11:30 - 13:30\n17:30 - 18:30"

        
        return OperatingHoursTable(hours: operatingHours)
    }
}
