//
//  ProfileEditView.swift
//  Siksha
//
//  Created by 이지현 on 4/14/24.
//

import SwiftUI

struct ProfileEditView<ViewModel>: View where ViewModel: ProfileEditViewModelType {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @ObservedObject  var viewModel:ViewModel
    @State private var isShowingPhotoLibrary = false
    @State private var addedImages = [UIImage]()
    
    var body: some View {
        GeometryReader { _ in
            VStack {
                ProfileImageView(selectedImage: viewModel.selectedImage, imageURL: viewModel.imageURL)
                    .padding(.top, 65.0)
                    .onTapGesture {
                        print("image tapped")
                    }
                nicknameTextField
                    .padding(.top, 15.0)
                buttons
                    .padding(.top, 18.0)
                
                Spacer()
                
                versionInfo
                    .padding(.bottom, 41.0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .customNavigationBar(title: "프로필 관리")
            .navigationBarItems(leading: backButton)
            .ignoresSafeArea(.keyboard)
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
            .onAppear {
                viewModel.loadInfo()
            }
            
        }
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
    var profileImage: some View {
        Button(action: {
            self.isShowingPhotoLibrary = true
        }) {
            Image("")
                .clipShape(Circle())
                .frame(width: 171, height: 171)
                .background(Circle().foregroundColor(Color("DefaultImageColor")))
        }
        .sheet(isPresented: $isShowingPhotoLibrary) {
            ImagePickerCoordinatorView(selectedImages: $addedImages, maxSelection: 1)
        }
    }
    
    var buttons: some View {
        HStack {
            Button(action: cancel) {
                    Text("취소")
                        .font(.custom("NanumSquareOTFB", size: 14))
            }
            .frame(width: 164, height: 44)
            .foregroundColor(Color.white)
            .background(
                RoundedRectangle(cornerRadius: 8.0)
                    .fill(Color("LightGrayColor"))
            )
            
            Button(action: done) {
                    Text("완료")
                        .font(.custom("NanumSquareOTFB", size: 14))
            }
            .disabled(!viewModel.enableDoneButton)
            .frame(width: 164, height: 44)
            .foregroundColor(Color.white)
            .background(
                RoundedRectangle(cornerRadius: 8.0)
                    .fill(viewModel.enableDoneButton ? Color("MainThemeColor") : Color("LightGrayColor"))
            )
        }
    }
    
    private func cancel() {
        presentationMode.wrappedValue.dismiss()
    }
    
    private func done() {
        viewModel.updateUserProfile()
        presentationMode.wrappedValue.dismiss()
    }
    
    var versionInfo: some View {
        VStack(alignment: .center) {
            Text(viewModel.versionInfo)
                .font(.custom("NanumSquareOTFR", size: 12))
                .foregroundColor(Color("VersionInfoColor"))
                .multilineTextAlignment(.center)
        }
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

struct ProfileImageView: View {
    let selectedImage: UIImage?
    let imageURL: String?

    var body: some View {
        Group {
            if let selectedImage = selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 171, height: 171)
                    .clipShape(Circle())
            } else if let urlString = imageURL, let imageUrl = URL(string: urlString) {
                if #available(iOS 15.0, *) {
                    AsyncImage(url: imageUrl) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } else if phase.error != nil {
                            Color("DefaultImageColor")
                        } else {
                            ProgressView()
                        }
                    }
                    .frame(width: 171, height: 171)
                    .clipShape(Circle())
                } else {
                    ThumbnailImage(urlString)
                        .frame(width: 171, height: 171)
                        .clipShape(Circle())
                }
            } else {
                Color("DefaultImageColor")
                    .frame(width: 171, height: 171)
                    .clipShape(Circle())
            }
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

#Preview {
    ProfileEditView(viewModel: ProfileEditViewModel())
}
