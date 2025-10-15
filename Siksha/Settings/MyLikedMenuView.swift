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
                .frame(width: 24, height: 24)
                .foregroundColor(.white)
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
                        LikedMenuRestaurantCell(viewModel,restaurant)
                            
                    }
                }
                .padding(EdgeInsets(top: 18, leading: 16, bottom: 0, trailing: 16))
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

