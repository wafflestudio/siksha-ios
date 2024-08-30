//
//  ProfileEditView.swift
//  Siksha
//
//  Created by 이지현 on 4/14/24.
//

import SwiftUI

struct ProfileEditView<ViewModel>: View where ViewModel: ProfileEditViewModelType {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @StateObject  var viewModel:ViewModel
    @StateObject private var keyboardResponder = KeyboardResponder()
    @State private var isShowingPhotoLibrary = false
    
    var body: some View {
        GeometryReader { _ in
            ZStack {
                mainContent
                keyboardToolbarContent
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .customNavigationBar(title: "프로필 관리")
            .navigationBarItems(leading: backButton)
            .ignoresSafeArea(.keyboard)
            .onTapGesture {
                UIApplication.shared.endEditing()
                viewModel.setPreviousNickname()
            }
            .onAppear {
                viewModel.loadInfo()
            }
        }
    }
    
    private var mainContent: some View {
        VStack {
            profileImage
                .padding(.top, 65.0)
            nicknameTextField
                .padding(.top, 15.0)
            
            Spacer()
            
            doneButton
                .padding(.bottom, 20)
        }
    }
    
    private var keyboardToolbarContent: some View {
        VStack {
            Spacer()
                keyboardToolbar
                    .opacity(keyboardResponder.didKeyboardShow ? 1 : 0)
                    .offset(y: keyboardResponder.didKeyboardShow ? -keyboardResponder.currentHeight : 50)
                    .animation(.easeOut(duration: 0.35))
        }
        .edgesIgnoringSafeArea(.bottom)
    }
    
    var nicknameTextField: some View {
        RoundedRectangle(cornerRadius: 11)
            .strokeBorder(lineWidth: 1)
            .frame(width: 336, height: 49)
            .foregroundColor(Color("TextFieldBorderColor"))
            .overlay(
                ClearableTextField("닉네임", text: $viewModel.nickname)
                    .padding(.horizontal, 18)
            )
    }
    
    var profileImage: some View {
        ZStack(alignment: .topTrailing) {
            Button(action: {
                isShowingPhotoLibrary = true
            }) {
                if let profileImage = viewModel.profileImage {
                    Image(uiImage: profileImage)
                        .resizable()
                        .clipShape(Circle())
                        .frame(width: 171, height: 171)
                } else {
                    Color("DefaultImageColor")
                        .frame(width: 171, height: 171)
                        .clipShape(Circle())
                }
            }
            .frame(width: 171, height: 171)
            .sheet(isPresented: $isShowingPhotoLibrary) {
                ImagePickerCoordinatorView(selectedImages: $viewModel.addedImages, maxSelection: 1)
            }
            
            cameraButton
                .offset(x: -2.5, y: 2.5)
        }
        
    }
    
    var cameraButton: some View {
        Button(action: {
            print("clicked")
        }) {
            ZStack {
                Circle()
                    .frame(width: 41.61, height: 41.61)
                    .foregroundColor(.white)
                    .overlay(
                        Circle()
                        .stroke(Color("TextFieldBorderColor"), lineWidth: 1)
                    )
                
                Image("Camera")
                    .frame(width: 22.5, height: 18)
                    .foregroundColor(Color("LightGrayColor"))
            }
        }
        .frame(width: 41.61, height: 41.61)
    }
    
    var doneButton: some View {
        Button(action: done) {
                Text("완료")
                    .font(.custom("NanumSquareOTFB", size: 17))
        }
        .disabled(!viewModel.enableDoneButton)
        .frame(width: 343, height: 56)
        .foregroundColor(Color.white)
        .background(
            RoundedRectangle(cornerRadius: 8.0)
                .fill(viewModel.enableDoneButton ? Color("MainThemeColor") : Color("LightGrayColor"))
        )
    }
    
    var keyboardToolbar: some View {
        HStack {
            Button(action: {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                viewModel.resetNickname()
            }) {
                Text("취소")
                    .font(.custom("NanumSquareOTFB", size: 14))
                    .foregroundColor(Color("MainThemeColor"))
                    .padding(.leading, 20)
            }
            Spacer()
            Button(action: {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                viewModel.setPreviousNickname()
            }) {
                Text("OK")
                    .font(.custom("NanumSquareOTFB", size: 14))
                    .foregroundColor(Color("MainThemeColor"))
                    .padding(.trailing, 20)
            }
        }
        .frame(height: 42)
        .background(Color.white)
        .border(Color("TextFieldBorderColor"), width: 1)
    }
    
    private func done() {
        viewModel.updateUserProfile()
        presentationMode.wrappedValue.dismiss()
    }
    
    var backButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
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
            if (text != "") {
                Image(systemName: "xmark.circle.fill")
                    .frame(width: 18, height: 18)
                    .foregroundColor(Color("LightGrayColor"))
                    .onTapGesture {
                        text = ""
                    }
            }
        }
    }
}
