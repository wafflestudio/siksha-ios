//
//  AlarmView.swift
//  Siksha
//
//  Created by 박정헌 on 8/30/25.
//

import SwiftUI
var SAMPLE_ALARM_MENU = [
    AlarmMenu(id:0,restaurant: "학생회관식당", menus: ["콩나물밥 & 부추양념", "돌솥부대찌개"]),
    AlarmMenu(id:1,restaurant: "학생회관식당", menus: ["콩나물밥 & 부추양념", "돌솥부대찌개"])

]
struct AlarmMenu:Hashable{
    var id:Int
    var restaurant:String
    var menus:[String]
}
struct AlarmView: View {
    @State var isAlarmOn = false
    var menus:[AlarmMenu]
    @Environment(\.presentationMode) var presentationMode:
        Binding<PresentationMode>
    var backButton: some View {
        Button(action: {
            ContentViewModel.contentViewModel.showPopUp = false
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Image("NavigationBack")
                .resizable()
                .frame(width: 10, height: 16)
        }
    }
    var alarmSettingsView:some View{
        VStack(spacing: 0){
            HStack(alignment:.center){
                Text("찜한 메뉴 알림 받기")
                    .foregroundStyle(Color.blackColor)
                    .customFont(font: .text15(weight: .Regular))
                Spacer()
                Toggle(isOn:$isAlarmOn){
                    EmptyView()
                }
                    .toggleStyle(AlarmSwitchStyle())

            }
            Spacer()
                .frame(height:10)
            Color.borderPrimary
                .frame(height:1)
            Spacer()
                .frame(height:13.5)
            HStack(alignment:.center){
                Text("메뉴 알림 설정")
                    .foregroundStyle(Color.blackColor)
                    .customFont(font: .text15(weight: .Regular))
                Spacer()
                Image("alarm-arrow")
                    .resizable()
                    .frame(width:16,height:16)
            }

        }
        .padding(EdgeInsets(top: 10, leading: 14, bottom: 10, trailing: 14))
        .background(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(Color.gray200, lineWidth: 1)
                .background(Color.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        )
    }
        var body: some View {
            ScrollView{
                VStack(alignment:.leading,spacing:0){
                    alarmSettingsView
                    Spacer()
                        .frame(height:20)
                    Text("알림 받을 메뉴를 선택하세요.")
                        .foregroundStyle(Color.gray600)
                        .customFont(font: .text14(weight: .Bold))
                        .padding(EdgeInsets(top: 0, leading: 14, bottom: 0, trailing: 0))
                    if isAlarmOn{
                        ForEach(menus,id:\.self){
                            menu in
                            AlarmRestaurantCell(restaurantName: menu.restaurant, menus: menu.menus)
                            Spacer()
                                .frame(height:12)
                        }
                    }
                    
                    
                    
                }
            }
            .padding(EdgeInsets(top: 18, leading: 16, bottom: 0, trailing: 17))
                .customNavigationBar(title: "내가 찜한 메뉴")
                .navigationBarItems(leading: backButton)
        }
    }

#Preview {
    AlarmView(menus: SAMPLE_ALARM_MENU)
}
