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
                RoundedRectangle(cornerRadius: 15.0)
                    .fill(Color.white)
                    .frame(width: 45, height: 25)
                Text("올리기")
                    .font(.custom("Inter-SemiBold", size: 12))
                    .foregroundColor(Color.init("MainThemeColor"))
            }
        }
    }
    
    var anonymousButton: some View {
        Button(action: {
            viewModel.isAnonymous.toggle()
                }) {
                    if viewModel.isAnonymous {
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
    }
    
    var customDivider: some View {
        HStack {
            Color("ReviewLowColor") 
                .frame(height: 1)
                .frame(maxWidth: .infinity)
        }
    }
    
    var imageSection: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    Button(action: {
                        self.isShowingPhotoLibrary = true
                    }) {
                        ZStack {
                            Rectangle()
                                .foregroundColor(Color("DefaultImageColor"))
                                .frame(width: 118, height: 118)

                            Image(systemName: "plus")
                                .resizable()
                                .foregroundColor(Color.white)
                                .frame(width: 40, height: 40)
                        }
                    }
                    .sheet(isPresented: $isShowingPhotoLibrary) {
                        ImagePickerCoordinatorView(selectedImages: $viewModel.images)
                    }
                    
                    ForEach(viewModel.images, id: \.self) { image in
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: image)
                                .resizable()
                                .renderingMode(.original)
                                .scaledToFill()
                                .frame(width: 119, height: 119)
                                .clipped()
                                .padding([.top, .trailing], 5)
                            
                            Button(action: {
                                if viewModel.images.contains(image) {
                                    viewModel.images.removeAll(where: { $0 == image })
                                }
                            }) {
                                ZStack {
                                    Circle()
                                        .foregroundColor(Color("MainThemeColor"))
                                        .frame(width: 24, height: 24)
                                    
                                    Image(systemName: "xmark")
                                        .resizable()
                                        .foregroundColor(Color.white)
                                        .frame(width: 10, height: 10)
                                }
                                .padding(EdgeInsets(top: 0, leading: 8, bottom: 8, trailing: 0))
                            }
                        }
                    }
                }
            }
            .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    anonymousButton
                    Spacer()
                }
                .padding(EdgeInsets(top: 0, leading: 7, bottom: 7, trailing: 0))
                
                TextField("제목", text: $viewModel.title)
                    .font(.custom("Inter-Bold", size: 14))
                    .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                
                customDivider
                
                ZStack {
                    let placeholder: String = "내용을 입력하세요."
                    
                    TextEditor(text: $viewModel.content)
                        .font(.custom("Inter-ExtraLight", size: 12))
                        .frame(minHeight: 30)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    if viewModel.content.isEmpty {
                        Text(placeholder)
                            .font(.custom("Inter-ExtraLight", size: 12))
                            .foregroundColor(Color.init("ReviewLowColor"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 4)
                    }
                }
                .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
                
                customDivider
                
                imageSection
                
                Spacer()
            }
            .padding(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20))
            .customNavigationBar(title: "글쓰기")
            .navigationBarItems(leading: backButton, trailing: postButton)
            
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
        viewModel.isSubmitted ? "게시물이 등록되었습니다." : "게시물을 등록하지 못했습니다. 다시 시도해주세요."
    }
    
    
}

/*struct CommunityPostPublishView_Previews: PreviewProvider {
    static var previews: some View {
        CommunityPostPublishView(viewModel: CommunitySubmitPostViewModel(boardId : 1,communityRepository: DomainManager.shared.domain.communityRepository))
    }
}
*/
