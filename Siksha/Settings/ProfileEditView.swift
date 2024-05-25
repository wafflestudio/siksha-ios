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
                .onTapGesture {
                    print("Image tapped")
                }
            nickname.padding(.top, 15.0)
            buttons.padding(.top, 18.0)
            Spacer()
            versionInfo.padding(.bottom, 41.0)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            UIApplication.shared.endEditing()
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
        RoundedRectangle(cornerRadius: 11)
            .strokeBorder(lineWidth: 1)
            .frame(width: 336, height: 49)
            .foregroundColor(Color("TextFieldBorderColor"))
            .overlay(
                ClearableTextField("닉네임", text: $viewModel.nickname)
                    .padding(.horizontal, 18)
            )
    }
    
    var buttons: some View {
        HStack {
            Button(action: {
                print("cancel button tapped")
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8.0)
                        .fill(Color("LightGrayColor"))
                        .frame(width: 164, height: 44)
                    Text("취소")
                        .font(.custom("NanumSquareOTFB", size: 14))
                        .foregroundColor(Color.white)
                }
            }
            Button(action: {
                print("done button tapped")
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8.0)
                        .fill(Color("MainThemeColor"))
                        .frame(width: 164, height: 44)
                    Text("완료")
                        .font(.custom("NanumSquareOTFB", size: 14))
                        .foregroundColor(Color.white)
                }
            }
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

struct ClearableTextField: View {
    var title: String
    @Binding var text: String
    
    init(_ title: String, text: Binding<String>) {
        self.title = title
        _text = text
    }
    
    var body: some View {
        ZStack(alignment: .trailing) {
            TextField(title, text: $text)
                .multilineTextAlignment(.center)
                .font(.custom("NanumSquareOTFB", size: 15))
                .padding(.horizontal, 20)
            Image(systemName: "xmark.circle.fill")
                .frame(width: 18, height: 18)
                .foregroundColor(Color("LightGrayColor"))
                .onTapGesture {
                    text = ""
                }
        }
    }
}

extension UIApplication {
    func addTapGestureRecognizer() {
        guard let window = windows.first else { return }
        let tapGesture = UITapGestureRecognizer(target: window, action: #selector(UIView.endEditing))
        tapGesture.requiresExclusiveTouchType = false
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        window.addGestureRecognizer(tapGesture)
    }
}

extension UIApplication: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

#Preview {
    ProfileEditView(viewModel: ProfileEditViewModel())
}
