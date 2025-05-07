//
//  RenewalVOCView.swift
//  Siksha
//
//  Created by 김령교 on 4/14/24.
//

import SwiftUI

struct RenewalVOCView: View {
    private let fontColor = Color("Gray700")
    private let orangeColor = Color.init("Orange500")
    private let lightGrayColor = Color.init("Gray600")
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject var viewModel: RenewalSettingsViewModel
    
    init(_ viewModel: RenewalSettingsViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack {
                    Image("Comment-new")
                        .renderingMode(.original)
                        .resizable()
                        .frame(width: 17, height: 16)
                    
                    Text("문의할 내용을 남겨주세요.")
                        .font(.custom("NanumSquareOTFB", size: 20))
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
                .padding([.leading, .trailing], 20)
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
                            .foregroundColor(viewModel.vocComment.count > 0 ? orangeColor : lightGrayColor)
                        
                        Text("전송하기")
                            .font(.custom("NanumSquareOTFB", size: 17))
                            .foregroundColor(.white)
                    }
                })
                .disabled(viewModel.vocComment.count == 0)
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
                        presentationMode.wrappedValue.dismiss()
                    } else {
                        return
                    }
                }))
            })
        }
        .ignoresSafeArea(.keyboard)
    }
}
