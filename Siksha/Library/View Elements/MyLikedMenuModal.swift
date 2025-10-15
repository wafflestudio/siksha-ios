//
//  MyLikedMenuModal.swift
//  Siksha
//
//  Created by 박정헌 on 8/27/25.
//

import SwiftUI

struct MyLikedMenuModal: View {
    @EnvironmentObject var contentViewModel:ContentViewModel
    static let infoText = ["알림 받을 메뉴는 ","[설정 > 내가 찜한 메뉴]"," 탭에서\n언제든 ","개별적으로"," ON/OFF 설정할 수 있어요."]
    let lineheight = UIFont(name: "NanumSquareOTFR", size: CGFloat(13))?.lineHeight ?? 0
    let padding = Float(UIFont(name: "NanumSquareOTFR", size: CGFloat(13))?.lineHeight ?? 0) * ((Float(140) - 100) / 100) / 2
    @State var isYesSelected = false
    @State var isNoSelected = false
    @State var isConfirmedEnabled = false
    var attributedInfoText:AttributedString{
        var result = AttributedString("")
        for (i,infoText) in MyLikedMenuModal.infoText.enumerated(){
            var attributedText = AttributedString(infoText)
            attributedText.font = .custom(i%2 == 0 ? "NanumSquareOTFR" : "NanumSquareOTFB",size: 13)
            result = result + attributedText
        }
        return result
    }
    var infoTextView: some View{

        Text(attributedInfoText)
            .padding(.vertical, CGFloat(padding))
            .lineSpacing(CGFloat(padding * 2))

    }
    var body: some View {
        VStack(alignment: .leading,spacing:0){
            VStack(alignment: .center,spacing: 0){
                Spacer()
                Image("alarm-modal")
                    .resizable()
                    .frame(width: 253,height:179)
                    .shadow(color:Color.black.opacity(0.25),radius:4,x:0,y:-1)
                    .mask(Rectangle().padding(.top, -1))

            }
            .frame(maxWidth: .infinity)
            .frame(height:216)
            .padding(.zero)
            .background(Color(UIColor(red: 247/255, green: 236/255, blue: 209/255, alpha: 1)))
            Spacer()
                .frame(height:24)
            VStack(alignment: .leading,spacing:0){
            Text("찜한 메뉴, 이제는 나올 때마다\n알림으로 받을 수 있어요!")
                .foregroundStyle(Color.blackColor)
                .customFont(font: .text18(weight: .ExtraBold))
            Spacer()
                .frame(height:8)
            Text("알림 받을 메뉴는 [설정 > 내가 찜한 메뉴] 탭에서\n언제든 개별적으로 ON/OFF 설정할 수 있어요.")
                .foregroundColor(Color.gray700)
                .customFont(font: .text12(weight: .Regular))
            Spacer()
                .frame(height:30)
            HStack(alignment: .center,spacing:10){
                Image(isYesSelected ? "radio-selected" : "radio-unselected")
                    .resizable()
                    .frame(width:20,height:20)
                    .onTapGesture {
                        isYesSelected = true
                        isNoSelected = false
                        isConfirmedEnabled = true
                    }
                Text("좋아요, 알림을 받을래요.")
            }
            Spacer()
                .frame(height:12)
            HStack(alignment: .center,spacing:10){
                Image(isNoSelected ? "radio-selected" : "radio-unselected")
                    .resizable()
                    .frame(width:20,height:20)
                    .onTapGesture {
                        isYesSelected = false
                        isNoSelected = true
                        isConfirmedEnabled = true
                    }
                Text("괜찮아요, 알림을 받지 않을래요.")
            }
            Spacer()
                .frame(height:30)
                HStack(alignment: .center,spacing:7){
                    Button(action:{
                        contentViewModel.showMyMenuViewFromPopup = true
                        contentViewModel.showModal = false                })
                    {Text("직접 설정하기")
                        
                            .padding(EdgeInsets(top: 11, leading: 33.25, bottom: 11, trailing: 33.25))
                            .foregroundStyle(Color.gray600)
                            .frame(maxWidth:.infinity)
                            .background(Color.gray100)
                            .cornerRadius(6)
                    }
                    Button(action:{
                        contentViewModel.showModal = false
                    }){
                        Text("완료")
                        
                            .padding(EdgeInsets(top: 11, leading: 33.25, bottom: 11, trailing: 33.25))
                            .foregroundStyle(Color.textButton)
                            .frame(maxWidth:.infinity)
                            .background(isConfirmedEnabled ? Color.orange500 : Color.gray600)
                            .cornerRadius(6)
                    }
                    .disabled(!isConfirmedEnabled)
                }
                
            }
            .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
            .frame(maxWidth:.infinity)

        }
        .padding(EdgeInsets(top: 0, leading: 0, bottom: 24, trailing: 0))
        .background(Color.backgroundSecondary)

        .cornerRadius(16)
        .frame(maxWidth:.infinity,alignment: .topLeading)

         

    }
}

#Preview {
    VStack{
        MyLikedMenuModal()
            .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 7))
    }
}
