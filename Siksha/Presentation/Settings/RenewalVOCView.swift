//
//  RenewalVOCView.swift
//  Siksha
//
//  Created by 김령교 on 4/14/24.
//

import SwiftUI

struct RenewalVOCView: View {
    private let fontColor = Color.blackColor
    private let orangeColor = Color.orange500
    private let lightGrayColor = Color.gray600
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject var viewModel: RenewalSettingsViewModel
    
    init(_ viewModel: RenewalSettingsViewModel) {
        self.viewModel = viewModel
    }

    var backButton: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
            viewModel.vocComment = ""
        }) {
            Image("NavigationBack")
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .foregroundColor(Color.iconWhiteIcon)
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack {
                    Image("Comment-new")
                        .renderingMode(.original)
                        .resizable()
                        .frame(width: 18, height: 18)
                    
                    Text("문의할 내용을 남겨주세요.")
                        .customFont(font: .text18(weight: .ExtraBold))
                        .foregroundStyle(Color.blackColor)
                }
                .frame(maxWidth: .infinity)
                .padding(EdgeInsets(top: 44, leading: 16, bottom: 20, trailing: 16))
                
                HStack {
                    Image(.Icons.Common.profileImagePlaceholder)
                        .renderingMode(.original)
                        .resizable()
                        .frame(width: 24, height: 24)
                    
                    Text("ID \(viewModel.userId)")
                        .customFont(font: .text12(weight: .Bold))
                        .foregroundColor(Color.blackColor)
                    
                    Spacer()
                }
                .padding([.leading, .trailing], 28)
                .padding(.bottom, 8)
                
                ZStack(alignment: .bottom) {
                    TextView(text: $viewModel.vocComment, placeHolder: .constant("내용을 입력해주세요."))
                        .frame(height: 280)
                    
                    HStack {
                        Spacer()
                        Text("\(viewModel.vocComment.count)자 / 500자")
                            .customFont(font: .text11(weight: .Regular))
                            .foregroundColor(.gray600)
                    }
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 8))
                }
                .padding(EdgeInsets(top: 0, leading: 28, bottom: 0, trailing: 28))
                
                Spacer()
                
                Button(action: {
                    viewModel.sendVOC()
                }, label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundColor(viewModel.vocComment.count > 0 && viewModel.postVOCStatus == .idle ? orangeColor : lightGrayColor)
                        
                        Text("완료")
                            .customFont(font: .text18(weight: .ExtraBold))
                            .foregroundColor(.textButton)
                    }
                })
                .disabled(viewModel.vocComment.count == 0 || viewModel.postVOCStatus != .idle)
                .frame(height: 56)
                .padding(16)
            }
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
            .background(Color.backgroundPrimary.onTapGesture {
                UIApplication.shared.endEditing()
            })
            .alert(isPresented: $viewModel.showAlert, content: {
                Alert(title: Text("1:1 문의하기"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("확인"), action: {
                    if viewModel.postVOCStatus == .succeeded {
                        viewModel.vocComment = ""
                        viewModel.postVOCStatus = .idle
                        viewModel.showAlert = false
                        presentationMode.wrappedValue.dismiss()
                    } else {
                        viewModel.postVOCStatus = .idle
                        viewModel.showAlert = false
                        return
                    }
                }))
            })
            .customNavigationBar(title: "1:1 문의하기")
            .navigationBarItems(leading: backButton)
            .background(Color.backgroundPrimary)
        }
        .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    RenewalVOCView(
        RenewalSettingsViewModel(
            manageRestaurantsWithoutMenuVisibilityUseCase: AppContainer.shared.useCases.manageRestaurantsWithoutMenuVisibilityUseCase
        )
    )
}
