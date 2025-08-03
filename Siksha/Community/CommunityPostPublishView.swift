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
    
    @Binding var needRefresh:Bool
    @Binding var needPostViewRefresh:Bool
    @State private var isShowingPhotoLibrary = false
    @State private var isExpanded = false
    private var cornerRadius = 7.0
    @ObservedObject  var viewModel:ViewModel
    @StateObject private var keyboardResponder = KeyboardResponder()
    private var cancellables = Set<AnyCancellable>()
    init(needRefresh: Binding<Bool>, needPostViewRefresh: Binding<Bool> = .constant(false), viewModel: ViewModel) {
        self._needRefresh = needRefresh
        self._needPostViewRefresh = needPostViewRefresh
        self.viewModel = viewModel
    }
 
    
    var backButton: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "xmark")
                .resizable()
                .foregroundColor(Color.white)
                .frame(width: 12, height: 12)
                .padding(.vertical, 15)
                .padding(.trailing, 15)
        }
        .contentShape(Rectangle())
    }
    
    var postAndEditButton: some View {
        HStack {
            Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(Color.gray100)
                        .frame(height: 60)
                    Text("취소")
                        .customFont(font: .text16(weight: .Bold))
                        .foregroundStyle(Color.gray600)
                }
            }
            .frame(maxWidth: .infinity)
            .disabled(viewModel.title.isEmpty || viewModel.content.isEmpty)
            
            Button(action: {
                viewModel.submitPost()
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(viewModel.title.isEmpty || viewModel.content.isEmpty ? Color.gray600 : Color.orange500)
                        .frame(height: 60)
                    Text("완료")
                        .customFont(font: .text16(weight: .Bold))
                        .foregroundStyle(Color.textButton)
                }
            }
            .frame(maxWidth: .infinity)
            .disabled(viewModel.title.isEmpty || viewModel.content.isEmpty)
        }
    }
    
    var postButton: some View {
        Button(action: {
            viewModel.submitPost()
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(viewModel.title.isEmpty || viewModel.content.isEmpty ? Color.gray600 : Color.orange500)
                    .frame(height: 60)
                Text("올리기")
                    .customFont(font: .text16(weight: .Bold))
                    .foregroundStyle(Color.textButton)
            }
        }
        .frame(maxWidth: .infinity)
        .disabled(viewModel.title.isEmpty || viewModel.content.isEmpty)
    }

    var anonymousButton: some View {
        Toggle(isOn: $viewModel.isAnonymous) {
            Text("익명")
                .customFont(font: .text12(weight: .Bold))
                .foregroundStyle(Color.gray600)
        }
        .toggleStyle(CustomCheckboxStyle())
    }
    
    struct CustomCheckboxStyle: ToggleStyle {
        func makeBody(configuration: Configuration) -> some View {
            HStack(spacing: 5) {
                    if configuration.isOn {
                        Image("CheckboxTicked")
                            .frame(width: 13, height: 13)
                    } else {
                        Image("Checkbox")
                            .frame(width: 13, height: 13)
                    }
                
                configuration.label
                    .foregroundColor(configuration.isOn ? .orange500 : .gray600)
            }
            .padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
            .foregroundColor(configuration.isOn ? .orange500 : .gray600)
            .contentShape(Rectangle())
            .onTapGesture {
                configuration.isOn.toggle()
            }
        }
    }

    
    var customDivider: some View {
        HStack {
            Color.borderPrimary
                .frame(height: 2)
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
                                        .foregroundColor(.gray700)
                                        .frame(width: 24, height: 24)
                                    
                                    Image(systemName: "xmark")
                                        .resizable()
                                        .foregroundColor(.whiteColor)
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
                                .foregroundColor(.gray100)
                                .frame(width: 106, height: 106)

                            Image(systemName: "plus")
                                .resizable()
                                .foregroundColor(.gray600)
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

    var boardPicker: some View {
        ZStack(alignment: .top) {
            // Background to dismiss the picker when tapped outside
            if isExpanded {
                Color.clear
                    .contentShape(Rectangle()) // This makes the clear color tappable
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation {
                            isExpanded = false
                        }
                    }
            }
            
            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Spacer()
                    Text(viewModel.boardsList.first { $0.id == viewModel.boardId }?.name ?? "게시판 선택")
                        .foregroundColor(.gray800)
                    Image("DownArrow")
                        .foregroundColor(.gray600)
                    Spacer()
                }
                .padding()
                .frame(height: 35)
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(Color.gray200)
                )
            }
            
            if isExpanded {
                VStack(spacing: 0) {
                    ForEach(viewModel.boardsList, id: \.id) { board in
                        VStack(spacing: 0) {
                            Button(action: {
                                viewModel.boardId = board.id
                                withAnimation {
                                    isExpanded = false
                                }
                            }) {
                                HStack {
                                    Spacer()
                                    if viewModel.boardId == board.id {
                                        Text(board.name)
                                            .foregroundColor(.orange500)
                                        Image("CheckMark")
                                            .foregroundColor(.orange500)
                                    } else {
                                        Text(board.name)
                                            .foregroundColor(.gray800)
                                    }
                                    Spacer()
                                }
                                .padding()
                            }
                            .frame(height: 35)
                            
                            if board.id != viewModel.boardsList.last?.id {
                                Divider()
                                    .background(Color.borderPrimary)
                            }
                        }
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(Color.gray200)
                        .background(
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .fill(Color.backgroundSecondary)
                        )
                )
                .offset(y: 40)
            }
        }
        .zIndex(1)
    }

    
    var KeyboardToolbar: some View {
        HStack {
            anonymousButton
                .padding(.leading, 20)
            Spacer()
            Button(action: {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }) {
                Text("OK")
                    .font(.custom("Inter-SemiBold", size: 16))
                    .foregroundColor(.orange)
                    .padding(.trailing, 20)
            }
        }
        .frame(height: 44)
        .background(Color.backgroundSecondary)
    }


    var body: some View {
        GeometryReader { geometry in
            let availableHeight = geometry.size.height
            
            ZStack(alignment: .top) {
                boardPicker
                    .padding(EdgeInsets(top: 10, leading: 20, bottom: 0, trailing: 20))
                
                VStack {
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.gray50)
                            .frame(height: 35)
                        TextField("제목", text: $viewModel.title)
                            .customFont(font: .text14(weight: .Bold))
                            .foregroundStyle(Color.blackColor)
                            .padding(EdgeInsets(top: 7, leading: 12, bottom: 7, trailing: 12))
                    }
                    .frame(maxWidth: .infinity)
                    
                    ZStack(alignment: .topLeading) {
                        let placeholder: String = "내용을 입력하세요."
                        
                        TextEditor(text: $viewModel.content)
                            .frame(minHeight: 120, maxHeight: max(120, availableHeight - 350))
                            .customFont(font: .text14(weight: .Regular))
                            .foregroundColor(.blackColor)
                            .fixedSize(horizontal: false, vertical: true)

                        if viewModel.content.isEmpty {
                            Text(placeholder)
                                .customFont(font: .text14(weight: .Regular))
                                .foregroundColor(Color.gray300)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(EdgeInsets(top: 8, leading: 6, bottom: 0, trailing: 0))
                        }
                    }

                    if keyboardResponder.currentHeight == 0 {
                        HStack {
                            anonymousButton
                            Spacer()
                        }
                    }
                    
                    customDivider
                    
                    imageSection
                    
                    Spacer()
                    
                    if let _ = viewModel.postInfo {
                        postAndEditButton
                            .padding(.bottom, 20)
                    } else {
                        postButton
                            .padding(.bottom, 20)
                    }

                }
                .padding(EdgeInsets(top: 60, leading: 20, bottom: 0, trailing: 20))
                .customNavigationBar(title: "글쓰기")
                .navigationBarItems(leading: backButton)
                .alert(isPresented: $viewModel.isErrorAlert, content: {
                    Alert(title: Text("게시물 남기기"), message: Text(alertMessage), dismissButton: alertButton)
                })
                    VStack {
                        Spacer()
                        KeyboardToolbar
                            .frame(height: 44)
                            .offset(y: keyboardResponder.currentHeight == 0 ? 50 : -keyboardResponder.currentHeight)
                            .animation(.easeOut(duration: 0.25))
                    }
                    .edgesIgnoringSafeArea(.bottom)
            }
        }
        .ignoresSafeArea(.keyboard)
        .navigationBarBackButtonHidden(true)
    }
    
    var alertButton: Alert.Button {
        var action: (() -> Void)? = nil
        if viewModel.isSubmitted {
            action = {
                needRefresh = true
                needPostViewRefresh = true
                presentationMode.wrappedValue.dismiss()
            }
        } else {
            action = {}
        }
        return Alert.Button.default(Text("확인"), action: action)
    }

    var alertMessage: String {
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
