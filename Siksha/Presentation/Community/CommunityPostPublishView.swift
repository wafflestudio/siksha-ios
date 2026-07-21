//
//  CommunityPostPublishView.swift
//  Siksha
//
//  Created by Chaehyun Park on 2023/07/29.
//

import Combine
import SwiftUI

struct CommunityPostPublishView<ViewModel>: View where ViewModel: CommunityPostPublishViewModel {

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @Binding var needRefresh: Bool
    @Binding var needPostViewRefresh: Bool
    @State private var isShowingPhotoLibrary = false
    @State private var isExpanded = false
    private var cornerRadius = 7.0
    @ObservedObject var viewModel: ViewModel
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
            Image("Close")
                .resizable()
                .foregroundColor(Color.iconWhiteIcon)
                .frame(width: 28, height: 28)
                .padding(.leading, 9)
        }
        .contentShape(Rectangle())
    }

    var postAndEditButton: some View {
        HStack {
            Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray100)
                        .frame(height: 44)
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
                    RoundedRectangle(cornerRadius: 8)
                        .fill(viewModel.title.isEmpty || viewModel.content.isEmpty ? Color.gray600 : Color.orange500)
                        .frame(height: 44)
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
                RoundedRectangle(cornerRadius: 8)
                    .fill(viewModel.title.isEmpty || viewModel.content.isEmpty ? Color.gray600 : Color.orange500)
                    .frame(height: 56)
                Text("올리기")
                    .customFont(font: .text18(weight: .ExtraBold))
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
                .foregroundStyle(viewModel.isAnonymous ? Color.orange500 : Color.gray600)
        }
        .toggleStyle(CustomCheckboxStyle())
    }

    struct CustomCheckboxStyle: ToggleStyle {
        func makeBody(configuration: Configuration) -> some View {
            HStack(spacing: 5) {
                if configuration.isOn {
                    Image("CheckboxTicked")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 13, height: 13)
                        .foregroundStyle(Color.orange500)
                } else {
                    Image("Checkbox")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 13, height: 13)
                        .foregroundStyle(Color.gray600)
                }

                configuration.label
                    .foregroundColor(configuration.isOn ? .orange500 : .gray600)
            }
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
                .frame(height: 1)
                .frame(maxWidth: .infinity)
        }
    }

    var imageSection: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 3) {
                    ForEach(viewModel.images, id: \.self) { image in
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: image)
                                .resizable()
                                .renderingMode(.original)
                                .scaledToFill()
                                .frame(width: 106, height: 106)
                                .clipped()
                                .cornerRadius(cornerRadius)
                                .padding(.top, 4)
                                .padding(.trailing, 5)

                            Button(action: {
                                viewModel.removeImage(image)
                            }) {
                                Image("Cancel")
                                    .frame(width: 18, height: 18)
                                    .background(Color.white)
                                    .clipShape(Circle())
                            }
                        }
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
                                .frame(width: 28, height: 28)
                        }
                        .padding(.top, 4)
                        .padding(.trailing, 5)
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
                HStack(spacing: 6.5) {
                    Spacer()
                    Text(viewModel.boardsList.first { $0.id == viewModel.boardId }?.name ?? "게시판 선택")
                        .customFont(font: .text13(weight: .Regular))
                        .foregroundColor(.gray800)
                    Image("DownArrow")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 10, height: 6)
                        .foregroundColor(.gray600)
                    Spacer()
                }
                .frame(height: 35)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.backgroundSecondary)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .inset(by: 1)
                        .stroke(Color.gray200, lineWidth: 1)
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
                                HStack(spacing: 4) {
                                    Spacer()
                                    if viewModel.boardId == board.id {
                                        Text(board.name)
                                            .foregroundColor(.orange500)
                                            .customFont(font: .text13(weight: .Bold))
                                        Image("Check")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 16, height: 16)
                                            .foregroundColor(.orange500)
                                    } else {
                                        Text(board.name)
                                            .foregroundColor(.gray800)
                                            .customFont(font: .text13(weight: .Regular))
                                    }
                                    Spacer()
                                }
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
                .offset(y: 38)
            }
        }
        .zIndex(1)
    }

    var KeyboardToolbar: some View {
        HStack {
            //            anonymousButton
            //                .padding(.leading, 20)
            Spacer()
            Button(action: {
                UIApplication.shared.sendAction(
                    #selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }) {
                Text("OK")
                    .customFont(font: .text16(weight: .Bold))
                    .foregroundColor(.orange500)
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
                    .padding(EdgeInsets(top: 15, leading: 20, bottom: 0, trailing: 20))

                VStack(spacing: 0) {
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.gray50)
                            .frame(height: 35)

                        TextField("제목", text: $viewModel.title, prompt: Text("제목").foregroundColor(.gray500))
                            .customFont(font: .text14(weight: .Bold))
                            .foregroundStyle(Color.blackColor)
                            .padding(.horizontal, 12)
                    }
                    .frame(maxWidth: .infinity)

                    Spacer().frame(height: 6)

                    ZStack(alignment: .topLeading) {
                        let placeholder: String = "내용을 입력하세요."

                        TextEditor(text: $viewModel.content)
                            .frame(minHeight: 120, maxHeight: max(120, availableHeight - 350))
                            .customFont(font: .text14(weight: .Regular))
                            .foregroundColor(.blackColor)
                            .fixedSize(horizontal: false, vertical: true)
                            .scrollContentBackground(.hidden)
                            .background(Color.backgroundPrimary)

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
                            //                            anonymousButton
                            Spacer()
                        }
                        .padding(.vertical, 11)
                    }

                    customDivider

                    Spacer().frame(height: 13)

                    imageSection

                    Spacer()

                    if viewModel.postInfo != nil {
                        postAndEditButton
                            .padding(.bottom, 20)
                    } else {
                        postButton
                            .padding(.bottom, 20)
                    }

                }
                .padding(EdgeInsets(top: 56, leading: 20, bottom: 0, trailing: 20))
                .customNavigationBar(title: "글쓰기")
                .navigationBarItems(leading: backButton)
                .alert(
                    isPresented: $viewModel.isErrorAlert,
                    content: {
                        Alert(title: Text("게시글 작성"), message: Text(alertMessage), dismissButton: alertButton)
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
            .background(Color.backgroundPrimary)
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
        if viewModel.postInfo != nil {
            viewModel.isSubmitted ? "게시물이 수정되었습니다." : "게시물을 수정하지 못했습니다. 다시 시도해주세요."
        } else {
            viewModel.isSubmitted ? "게시물이 등록되었습니다." : "게시물을 등록하지 못했습니다. 다시 시도해주세요."
        }
    }
}

struct CommunityPostPublishView_Previews: PreviewProvider {
    static var previews: some View {
        CommunityPostPublishView(
            needRefresh: .constant(false),
            viewModel: CommunityPostPublishViewModel(
                boardId: 1, communityRepository: AppContainer.shared.domain.communityRepository,
                orderedImageDataLoader: AppContainer.shared.orderedImageDataLoader,
                postInfo: .init(
                    title: "title", content: "content", isLiked: false, likeCount: 5, commentCount: 4,
                    imageURLs: [
                        "https://images.unsplash.com/photo-1751193978006-4c19abfb5f3f?q=80&w=1587&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                        "https://images.unsplash.com/photo-1754404053324-8f910c2b7e2d?q=80&w=2340&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                        "https://plus.unsplash.com/premium_photo-1754067486503-e3f98909b13a?q=80&w=1587&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                    ], isAnonymous: true, isMine: true)))
    }
}
