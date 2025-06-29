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
    @State private var isShowingActionSheet = false
    @State private var isShowingPhotoLibrary = false
    
    var body: some View {
        GeometryReader { _ in
            ZStack {
                mainContent
                keyboardToolbarContent
            }
            .errorAlert(error: $viewModel.error)
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
            .onChange(of: viewModel.shouldDismiss) { shouldDismiss in
                if shouldDismiss {
                    presentationMode.wrappedValue.dismiss()
                }
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
            
            existingNicknameToast
                .padding(.bottom, 25)
            
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
            .foregroundColor(Color("Color/Foundation/Gray/200"))
            .overlay(
                ClearableTextField("닉네임", text: $viewModel.nickname)
                    .padding(.horizontal, 18)
            )
    }
    
    var profileImage: some View {
        Button(action: {
            isShowingActionSheet = true
        }) {
            ZStack(alignment: .topTrailing) {
                if let profileImageData = viewModel.profileImageData,
                let uiImage = UIImage(data: profileImageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipShape(Circle())
                        .frame(width: 171, height: 171)
                } else {
                    Image("BigLogoEllipse")
                        .resizable()
                        .clipShape(Circle())
                        .frame(width: 171, height: 171)
                }
                
                cameraImage
                    .offset(x: -2.5, y: 2.5)
            }
        }
        .actionSheet(isPresented: $isShowingActionSheet) {
            ActionSheet(title: Text("프로필 사진 설정"), buttons: [
                .default(Text("앨범에서 사진 선택"), action: {
                    isShowingPhotoLibrary = true
                }),
                .default(Text("기본 이미지 적용"), action: {
                    viewModel.setProfileImage(with: nil)
                }),
                .cancel(Text("취소"))
            ])
        }
        .sheet(isPresented: $isShowingPhotoLibrary) {
            ImagePickerCoordinatorView(selectedImages: .constant([]), maxSelection: 1) { images in
                if let firstImage = images.first,
                   let imageData = firstImage.jpegData(compressionQuality: 0.8) {
                    viewModel.setProfileImage(with: imageData)
                }
            }
        }
        
    }
    
    var cameraImage: some View {
        ZStack {
            Circle()
                .frame(width: 41.61, height: 41.61)
                .foregroundColor(Color("SemanticColor/Background/Secondary"))
                .overlay(
                    Circle()
                    .stroke(Color("Color/Foundation/Gray/200"), lineWidth: 1)
                )
            
            Image("Camera")
                .frame(width: 22.5, height: 18)
                .foregroundColor(Color("Color/Foundation/Gray/600"))
        }
    }
    
    var doneButton: some View {
        Button(action: done) {
            ZStack(alignment: .center) {
                RoundedRectangle(cornerRadius: 8.0)
                    .fill(viewModel.enableDoneButton ? Color("Color/Foundation/Orange/500") : Color("Color/Foundation/Gray/600"))
                Text("완료")
                    .font(.custom("NanumSquareOTFEB", size: 18))
                    .foregroundStyle(Color("SemanticColor/Text/Button"))
            }
        }
        .disabled(!viewModel.enableDoneButton)
        .frame(height: 56)
        .padding(.horizontal, 16)
    }
    
    var keyboardToolbar: some View {
        HStack {
            Button(action: {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                viewModel.resetNickname()
            }) {
                Text("취소")
                    .font(.custom("NanumSquareOTFB", size: 14))
                    .foregroundColor(Color("Color/Foundation/Orange/500"))
                    .padding(.leading, 20)
            }
            Spacer()
            Button(action: {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                viewModel.setPreviousNickname()
            }) {
                Text("OK")
                    .font(.custom("NanumSquareOTFB", size: 14))
                    .foregroundColor(Color("Color/Foundation/Orange/500"))
                    .padding(.trailing, 20)
            }
        }
        .frame(height: 42)
        .background(Color("SemanticColor/Background/Secondary"))
        .border(Color("Color/Foundation/Gray/200"), width: 1)
    }
    
    private func done() {
        viewModel.updateUserProfile()
    }
    
    private var backButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Image("NavigationBack")
                .resizable()
                .frame(width: 7, height: 15)
        }
    }
    
    private var existingNicknameToast: some View {
        VStack {
            ZStack(alignment: .center) {
                RoundedRectangle(cornerRadius: 8.0)
                    .fill(Color.black.opacity(0.5))
                
                HStack(spacing: 0) {
                    Image("Error")
                        .frame(width: 14, height: 14)
                        .foregroundColor(Color("Color/Foundation/Orange/500"))
                        .padding(.trailing, 10)
                    Text("이미 존재하는 닉네임입니다.")
                        .font(.custom("NanumSquareOTFB", size: 12))
                        .lineLimit(1)
                        .foregroundColor(.white)
                }
            }
            .frame(width: 185, height: 30)
            .opacity(viewModel.showNicknameExistsToast ? 1 : 0)
            .animation(.easeIn(duration: 0.2))
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
                .foregroundStyle(Color("Color/Foundation/Base/BlackColor"))
                .padding(.horizontal, 20)
            if (text != "") {
                Image(systemName: "xmark.circle.fill")
                    .frame(width: 18, height: 18)
                    .foregroundColor(Color("SemanticColor/Icon/Close_bg"))
                    .onTapGesture {
                        text = ""
                    }
            }
        }
    }
}

#Preview {
    ProfileEditView(viewModel: ProfileEditViewModel())
}
