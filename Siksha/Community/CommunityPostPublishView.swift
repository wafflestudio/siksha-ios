//
//  CommunityPostPublishView.swift
//  Siksha
//
//  Created by Chaehyun Park on 2023/07/29.
//

import SwiftUI
import Combine

struct CommunityPostPublishView<ViewModel>: View where ViewModel:CommunityPostPublishViewModel {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
  //  @State private var anonymousIsToggled = false
   // @State var title: String = ""
   // @State var content: String = ""
    @Binding var needRefresh:Bool
    @State private var isShowingPhotoLibrary = false
 //   @State private var addedImages = [UIImage]()
    private var cornerRadius = 7.0
    @ObservedObject  var viewModel:ViewModel
    private var cancellables = Set<AnyCancellable>()
    init( needRefresh: Binding<Bool> , viewModel: ViewModel) {
        self._needRefresh = needRefresh
        self.viewModel = viewModel
    }
 
    
    var backButton: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "xmark")
                .resizable()
                .foregroundColor(Color.white)
                .frame(width: 10, height: 10)
        }
    }
    
    var postButton: some View {
        Button(action: {
            viewModel.submitPost()
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(viewModel.title.isEmpty || viewModel.content.isEmpty ? Color.gray : Color("MainThemeColor"))
                    .frame(height: 60)
                Text("올리기")
                    .font(.custom("Inter-SemiBold", size: 17))
                    .foregroundColor(Color.white)
            }
        }
        .frame(maxWidth: .infinity)
        .disabled(viewModel.title.isEmpty || viewModel.content.isEmpty)
    }

    var anonymousButton: some View {
        Toggle(isOn: $viewModel.isAnonymous) {
            Text("익명")
                .font(.custom("Inter-Regular", size: 14))
        }
        .toggleStyle(CustomCheckboxStyle())
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

    
    var customDivider: some View {
        HStack {
            Color("DefaultImageColor")
                .frame(height: 0.5)
                .frame(maxWidth: .infinity)
        }
    }
    
    var imageSection: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(viewModel.images, id: \.self) { image in
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: image)
                                .resizable()
                                .renderingMode(.original)
                                .scaledToFill()
                                .frame(width: 106, height: 106)
                                .clipped()
                                .cornerRadius(cornerRadius)
                            
                            Button(action: {
                                viewModel.removeImage(image)
                            }) {
                                ZStack {
                                    Circle()
                                        .foregroundColor(Color(hex:0x575757))
                                        .frame(width: 24, height: 24)
                                    
                                    Image(systemName: "xmark")
                                        .resizable()
                                        .foregroundColor(Color(hex:0xDFDFDF))
                                        .frame(width: 10, height: 10)
                                }
                                .offset(x: 8, y: -8)
                            }
                        }
                        .frame(width:115, height: 130)
                    }
                    
                    Button(action: {
                        self.isShowingPhotoLibrary = true
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .foregroundColor(Color("DefaultImageColor"))
                                .frame(width: 106, height: 106)

                            Image(systemName: "plus")
                                .resizable()
                                .foregroundColor(Color.white)
                                .frame(width: 40, height: 40)
                        }
                    }
                    .sheet(isPresented: $isShowingPhotoLibrary) {
                        ImagePickerCoordinatorView(selectedImages: $viewModel.images, maxSelection: 5)
                    }

                }
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(Color(hex: 0xF8F8F8))
                        .frame(height: 35)
                    TextField("제목", text: $viewModel.title)
                        .font(.custom("Inter-Bold", size: 14))
                        .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                }
                .frame(maxWidth:.infinity)
                                
                ZStack(alignment: .topLeading) {
                    let placeholder: String = "내용을 입력하세요."
                    
                    TextEditor(text: $viewModel.content)
                        .font(.custom("Inter-ExtraLight", size: 12))
                        .frame(minHeight: 120)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    if viewModel.content.isEmpty {
                        Text(placeholder)
                            .font(.custom("Inter-ExtraLight", size: 12))
                            .foregroundColor(Color.init("ReviewLowColor"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(EdgeInsets(top: 8, leading: 6, bottom: 0, trailing: 0))
                    }
                }
                .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                
                HStack {
                    anonymousButton
                    Spacer()
                }
                
                customDivider
                
                imageSection
                
                Spacer()

                postButton
                    .padding(.bottom, 5)
                
            }
            .padding(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20))
            .customNavigationBar(title: "글쓰기")
            .navigationBarItems(leading: backButton)
            
        }.navigationBarBackButtonHidden(true)
        .alert(isPresented: $viewModel.isErrorAlert, content: {
            Alert(title: Text("게시물 남기기"), message:  Text(alertMessage), dismissButton: alertButton)
        })
      
    }
    
    
    var alertButton: Alert.Button {
            var action: (() -> Void)? = nil
            if viewModel.isSubmitted {
                action = {
                    needRefresh = true
                    presentationMode.wrappedValue.dismiss()
                }
            } else {
                action = {
                    
                }
            
            }
            return Alert.Button.default(Text("확인"), action: action)
        }
    var alertMessage:String{
        if let _ = viewModel.postInfo {
            viewModel.isSubmitted ? "게시물이 수정되었습니다." : "게시물을 수정하지 못했습니다. 다시 시도해주세요."
        } else {
            viewModel.isSubmitted ? "게시물이 등록되었습니다." : "게시물을 등록하지 못했습니다. 다시 시도해주세요."
        }
    }
    
    
}

/*struct CommunityPostPublishView_Previews: PreviewProvider {
    static var previews: some View {
        CommunityPostPublishView(viewModel: CommunitySubmitPostViewModel(boardId : 1,communityRepository: DomainManager.shared.domain.communityRepository))
    }
}
*/
