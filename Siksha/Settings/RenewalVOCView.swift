//
//  RenewalVOCView.swift
//  Siksha
//
//  Created by 김령교 on 4/14/24.
//

import SwiftUI

struct RenewalVOCView: View {
    private let fontColor = Color.gray700
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
        }) {
            Image("NavigationBack")
                .resizable()
                .frame(width: 7, height: 15)
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
                        .font(.custom("NanumSquareOTFB", size: 18))
                        .foregroundStyle(Color.blackColor)
                }
                .frame(maxWidth: .infinity)
                .padding(EdgeInsets(top: 44, leading: 16, bottom: 20, trailing: 16))
                
                HStack {
                    Image("LogoEllipse")
                        .renderingMode(.original)
                        .resizable()
                        .frame(width: 24, height: 24)
                    
                    Text("ID \(viewModel.userId)")
                        .font(.custom("NanumSquareOTFB", size: 12))
                    
                    Spacer()
                }
                .padding([.leading, .trailing], 28)
                .padding(.bottom, 8)
                
                ZStack(alignment: .bottom) {
                    TextView(text: $viewModel.vocComment, placeHolder: .constant(""))
                        .frame(height: 280)
                    
                    HStack {
                        Spacer()
                        Text("\(viewModel.vocComment.count)자 / 500자")
                            .font(.custom("NanumSquareOTFL", size: 11))
                            .foregroundColor(fontColor)
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
                            .font(.custom("NanumSquareOTFB", size: 18))
                            .foregroundColor(.textButton)
                    }
                })
                .disabled(viewModel.vocComment.count == 0 || viewModel.postVOCStatus != .idle)
                .frame(height: 56)
                .padding(16)
            }
    //        .edgesIgnoringSafeArea(.all)
            .background(Color.white.onTapGesture {
                UIApplication.shared.endEditing()
            })
    //        .navigationBarTitle("", displayMode: .inline)
    //        .navigationBarHidden(true)
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
        }
        .ignoresSafeArea(.keyboard)
    }
}
