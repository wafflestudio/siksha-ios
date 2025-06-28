//
//  VOCView.swift
//  Siksha
//
//  Created by 박종석 on 2021/05/30.
//

import SwiftUI


struct VOCView: View {
    private let fontColor = Color("Gray700")
    private let orangeColor = Color.init("Orange500")
    private let lightGrayColor = Color.init("Gray600")
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject var viewModel: SettingsViewModel
    
    init(_ viewModel: SettingsViewModel) {
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
                .padding(EdgeInsets(top: 0, leading: 28, bottom: 8, trailing: 28))
                
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
                .padding([.leading, .trailing], 28)
                
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

   
