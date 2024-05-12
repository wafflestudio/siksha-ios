//
//  ProfileEditView.swift
//  Siksha
//
//  Created by 이지현 on 4/14/24.
//

import SwiftUI

struct ProfileEditView<ViewModel>: View where ViewModel:ProfileEditViewModel {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @ObservedObject  var viewModel:ViewModel
    
    var body: some View {
        VStack {
            profileImage.padding(.top, 65.0)
                
            nickname.padding(.top, 15.0)
            
            Spacer()
            
            versionInfo.padding(.bottom, 41.0)
        }
        .customNavigationBar(title: "프로필 관리")
        .navigationBarItems(leading: backButton)
    }
    
    var profileImage: some View {
        Image("")
            .clipShape(Circle())
            .frame(width: 171, height: 171)
            .background(Circle().foregroundColor(Color("DefaultImageColor")))
    }
    
    var nickname: some View {
        ZStack(alignment: .trailing) {
            ZStack(alignment: .center) {
                RoundedRectangle(cornerRadius: 11)
                    .strokeBorder(lineWidth: 1)
                    .frame(width: 336, height: 49)
                    .foregroundColor(Color("TextFieldBorderColor"))
                TextField("닉네임", text: $viewModel.nickname)
                    .multilineTextAlignment(.center)
                    .frame(width: 137)
                    .font(.custom("NanumSquareOTFB", size: 15))
            }
            Button(action: {
                print("nickname edit button tapped")
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8.0)
                                .fill(Color("MainThemeColor"))
                                .frame(width: 52, height: 33)
                            Text("완료")
                                .font(.custom("NanumSquareOTFR", size: 15))
                                .foregroundColor(Color.white)
                        }
                    }
                    .padding(.trailing, 8)
        }
        
    }
    
    var versionInfo: some View {
        VStack(alignment: .center) {
            Text("siksha-2.0.0")
                .font(.custom("NanumSquareOTFR", size: 12))
                .foregroundColor(Color("VersionInfoColor"))
            Text("최신버전을 이용중입니다.")
                .font(.custom("NanumSquareOTFR", size: 12))
                .foregroundColor(Color("VersionInfoColor"))
        }
    }
    
    var backButton: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Image("NavigationBack")
                .resizable()
                .frame(width: 7, height: 15)
        }
    }
}

#Preview {
    ProfileEditView(viewModel: ProfileEditViewModel())
}
