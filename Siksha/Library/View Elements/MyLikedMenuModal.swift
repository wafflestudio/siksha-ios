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
            Text("찜한 메뉴, 이제는 나올 때마다\n알림으로 받을 수 있어요!")
                .foregroundStyle(Color.blackColor)
                .customFont(font: .text18(weight: .ExtraBold))
            Spacer()
                .frame(height:8)
            infoTextView
            Spacer()
                .frame(height:30)
            Image("myLikedMenuModal")
                .resizable()
                .frame(width: 253,height:163)
                .shadow(color: Color.black.opacity(0.25), radius: 0, y: -1)
            Spacer()
                .frame(height:31.5)
            HStack(alignment: .center,spacing:10){
                Image("radio-unselected")
                    .resizable()
                    .frame(width:20,height:20)
                Text("좋아요, 알림을 받을래요.")
            }
            Spacer()
                .frame(height:12)
            HStack(alignment: .center,spacing:10){
                Image("radio-unselected")
                    .resizable()
                    .frame(width:20,height:20)
                Text("괜찮아요, 알림을 받지 않을래요.")
            }
            Spacer()
                .frame(height:30)
            HStack(alignment: .center,spacing:7){
                NavigationLink(destination:MyLikedMenuView()){
                    Text("직접 설정하기")
                    
                        .padding(EdgeInsets(top: 11, leading: 33.25, bottom: 11, trailing: 33.25))
                        .foregroundStyle(Color.gray600)
                        .frame(maxWidth:.infinity)
                        .background(Color.gray100)
                        .cornerRadius(6)
                }.simultaneousGesture(TapGesture().onEnded{
                    contentViewModel.showModal = false
                })
                Button(action:{
                    contentViewModel.showModal = false
                }){
                    Text("완료")
                    
                        .padding(EdgeInsets(top: 11, leading: 33.25, bottom: 11, trailing: 33.25))
                        .foregroundStyle(Color.textButton)
                        .frame(maxWidth:.infinity)
                        .background(Color.orange500)
                        .cornerRadius(6)
                }
            }
            .padding(.zero)
            .frame(maxWidth:.infinity)

        }
        .padding(EdgeInsets(top: 24, leading: 20, bottom: 24, trailing: 20))
        .background(Color.backgroundSecondary)

        .cornerRadius(16)
        .frame(maxWidth:.infinity,alignment: .topLeading)

            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.gray200, lineWidth: 1)
            )


    }
}

#Preview {
    VStack{
        MyLikedMenuModal()
            .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 7))
    }
}
