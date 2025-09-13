//
//  MyLikedMenuView.swift
//  Siksha
//
//  Created by 박정헌 on 8/17/25.
//

import SwiftUI

struct MyLikedMenuView: View {
    @Environment(\.presentationMode) var presentationMode:
        Binding<PresentationMode>
    var restaurants:[Restaurant]
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
    var body: some View {
        ZStack(alignment: .topTrailing) {

            ScrollView {
                VStack{
                    ForEach(restaurants,id:\.self){restaurant in
                        LikedMenuRestaurantCell(restaurant)
                    }
                }
            }
        }
     
        .padding(.zero)

        .customNavigationBar(title: "내가 찜한 메뉴")
        .navigationBarItems(leading: backButton)
        .navigationBarItems(
            trailing: NavigationLink(destination:AlarmView(menus: SAMPLE_ALARM_MENU)){Image("notification").padding(
                EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 5))
            })
        .onAppear{
            ContentViewModel.contentViewModel.showPopUp = true
            print("appeared")
        }
    }

}

struct MyLikedMenuView_Previews:PreviewProvider{
   static var previews : some View {
        let emptyRes = Restaurant()
        let nonEmptyRes = Restaurant()
        emptyRes.nameKr = "빈 식당"
        nonEmptyRes.nameKr = "든 식당"
        let menu = Meal()
        menu.price = 3000
        menu.nameKr = "식단"
        menu.reviewCnt = 1
        menu.score = 3
        let menu2 = Meal()
        menu2.price = 4000
        menu2.nameKr = "식단2"
        menu2.reviewCnt = 0
        menu2.score = 4
        nonEmptyRes.menus.append(menu)
        nonEmptyRes.menus.append(menu2)

       return MyLikedMenuView(restaurants: [emptyRes,nonEmptyRes])
    }
}
