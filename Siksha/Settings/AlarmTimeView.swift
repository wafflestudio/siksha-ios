//
//  AlarmTimeView.swift
//  Siksha
//
//  Created by 박정헌 on 8/30/25.
//

import SwiftUI

struct AlarmTimeView: View {
    
    @Environment(\.presentationMode) var presentationMode:
        Binding<PresentationMode>
    @State var isMorning = true
    var backButton: some View {
        Button(action: {
            ContentViewModel.contentViewModel.showPopUp = false
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Image("NavigationBack")
                .resizable()
                .frame(width: 24, height:24)
                .foregroundColor(.white)
        }
    }
    var alarmTimeSettingsView:some View{
        VStack(spacing: 0){
            HStack(alignment:.center){
                Text("아침에 한 번에 받기")
                    .foregroundStyle(Color.blackColor)
                    .customFont(font: .text15(weight: .Regular))
                Spacer()
                if isMorning{
                    Image("alarm-time-check")
                }
           
            }
            .background(Color.backgroundSecondary) // for wider touch area
            .onTapGesture {
                isMorning = true
            }
            Spacer()
                .frame(height:10)
            Color.borderPrimary
                .frame(height:1)
            Spacer()
                .frame(height:10)
            HStack(alignment:.center){
                Text("식사시간마다 받기")
                    .foregroundStyle(Color.blackColor)
                    .customFont(font: .text15(weight: .Regular))
                Spacer()
                if !isMorning{
                    Image("alarm-time-check")
                }

            }
            .background(Color.backgroundSecondary)

            .onTapGesture {
                isMorning = false
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
        VStack(alignment:.center,spacing:10){
            alarmTimeSettingsView
            Text("아침에 한 번에 받기: 당일에 나온 찜한 메뉴를 한 번에 알려드려요.\n식사시간마다 받기: 아침·점심·저녁 메뉴를 해당 시간대에 맞춰\n나누어 안내드려요. (아침 7:30 / 점심 10:30 / 저녁 16:30)")
                .foregroundStyle(Color.gray600)
                .customFont(font: .text12(weight: .Bold))
                .frame(maxWidth: .infinity,alignment: .leading)
                .padding(EdgeInsets(top: 0, leading: 14, bottom: 0, trailing: 0))
        }
        .customNavigationBar(title: "내가 찜한 메뉴")
        .navigationBarItems(leading: backButton)
        .frame(maxHeight:.infinity,alignment: .top)
        .padding(EdgeInsets(top: 18, leading: 16, bottom: 0, trailing: 16))
    }
}

#Preview {
    AlarmTimeView()
}
