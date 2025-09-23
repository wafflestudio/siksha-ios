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
    @ObservedObject var viewModel:MyLikedMenuViewModel
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
    init(viewModel:MyLikedMenuViewModel){
        self.viewModel = viewModel
    }
    var body: some View {
        ZStack(alignment: .topTrailing) {

            ScrollView {
                VStack{
                    ForEach(viewModel.myLikedRestaurants,id:\.self){restaurant in
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

