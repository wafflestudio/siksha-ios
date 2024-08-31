//
//  CommunityReplyBar.swift
//  Siksha
//
//  Created by 김령교 on 8/27/23.
//

import SwiftUI

struct CommunityReplyBar: View {
    @State var commentText: String = ""
    @State var isAnonymous: Bool = UserDefaults.standard.bool(forKey: "isAnonymous")
    var onCommentSubmit: (String,Bool) -> Void
    
    let dividerColor = Color(red: 183/255, green: 183/255, blue: 183/255, opacity: 1)
    let replyColor = Color(red: 248/255, green: 248/255, blue: 248/255, opacity: 1)
    
    var body: some View {
        ZStack{
            Rectangle()
                .fill(Color.white)
                .frame(height: 40)
            
            RoundedRectangle(cornerRadius: 12)
                .fill(replyColor)
                .frame(maxWidth: .infinity, maxHeight: 37)
                .overlay(
                    HStack {
                        anonymousButton
                            .padding(EdgeInsets(top: 5, leading: 12, bottom: 5, trailing: 6))
                        TextField("댓글을 입력하세요", text: $commentText)
                        Button(action: {
                            onCommentSubmit(commentText,isAnonymous)
                            commentText = ""
                        }){
                            Text("올리기")
                                .padding(EdgeInsets(top: 6.5, leading: 11, bottom: 6.5, trailing: 11))
                                .background(Color("main"))
                                .font(.custom("NanumSquareOTFBold", size: 12))
                                .foregroundColor(.white)
                                .cornerRadius(6)
                        }
                        .padding(EdgeInsets(top: 5, leading: 6, bottom: 5, trailing: 12))
                    }
                )
                .padding(EdgeInsets(top: 0, leading: 16, bottom: 5, trailing: 16))
        }
    }
    /*var anonymousButton: some View {
        Button(action: {
            isAnonymous.toggle()
                }) {
                    if isAnonymous {
                        ZStack {
                            RoundedRectangle(cornerRadius: 15.0)
                                .fill(Color("MainThemeColor"))
                                .frame(width: 34, height: 25)
                            Text("익명")
                                .font(.custom("Inter-SemiBold", size: 12))
                                .foregroundColor(Color.white)
                        }
                    } else {
                        ZStack {
                            RoundedRectangle(cornerRadius: 15.0)
                                .stroke(Color("MainThemeColor"))
                                .frame(width: 34, height: 25)
                            Text("익명")
                                .font(.custom("Inter-SemiBold", size: 12))
                                .foregroundColor(Color("MainThemeColor"))
                        }
                    }
                }
    }*/
    var anonymousButton: some View {
        Toggle(isOn: $isAnonymous) {
            Text("익명")
                .font(.custom("Inter-Regular", size: 14))
        }
        .toggleStyle(CustomCheckboxStyle())
        .onChange(of: isAnonymous) { newValue in
            UserDefaults.standard.set(newValue, forKey: "isAnonymous")
        }
    }
    struct CustomCheckboxStyle: ToggleStyle {
        func makeBody(configuration: Configuration) -> some View {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(configuration.isOn ? Color.clear : Color(hex:0xDFDFDF), lineWidth: 1)
                        .frame(width: 14, height: 14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(configuration.isOn ? Color("MainThemeColor") : Color.clear)
                        )
                    
                    
                    if configuration.isOn {
                        Image(systemName: "checkmark")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.white)
                            .frame(width: 10, height: 10)
                    }
                }
                .onTapGesture {
                    configuration.isOn.toggle()
                }
                
                Text("익명")
                    .font(.custom("Inter-Regular", size: 14))
                    .foregroundColor(configuration.isOn ? Color("MainThemeColor") : Color(hex:0x575757))
            }
        }
    }
}

struct CommunityReplyBar_Previews: PreviewProvider {
    static var previews: some View {
        CommunityReplyBar(onCommentSubmit: { commentText,isAnonymous in
            print("Comment submitted: \(commentText)\nisAnonymous: \(isAnonymous)")
        })
    }
}
