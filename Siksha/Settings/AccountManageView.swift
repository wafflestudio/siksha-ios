//
//  AccountManageView.swift
//  Siksha
//
//  Created by 김령교 on 6/26/24.
//

import SwiftUI
import UIKit

struct AccountManageView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @ObservedObject var viewModel:RenewalSettingsViewModel
    
    init(viewModel: RenewalSettingsViewModel) {
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
    
    var partitionBar: some View {
        Color.init(white: 232/255)
            .frame(height: 1)
            .padding([.leading, .trailing], 8)
    }
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 0) {
                Button(action: {
                    viewModel.showSignOutAlert = true
                }) {
                    HStack(alignment: .center) {
                        Text("로그아웃")
                            .font(.custom("NanumSquareOTFR", size: 15))
                            .foregroundColor(.black)
                            .padding([.top, .bottom], 12)
                            .padding(.leading, 16)
                        
                        Spacer()
                    }
                }
                .actionSheet(isPresented: $viewModel.showSignOutAlert) {
                    ActionSheet(
                        title: Text("로그아웃"),
                        message: Text("앱에서 로그아웃합니다."),
                        buttons: [
                            .destructive(Text("로그아웃")){
                                viewModel.logOutAccount()
                                viewControllerHolder?.present(style: .fullScreen) {
                                    LoginView()
                                }
                            },
                            .cancel(Text("취소"))
                        ]
                    )
                }
                
                partitionBar
                
                Button(action: {
                    viewModel.showRemoveAccountAlert = true
                }) {
                    HStack(alignment: .center) {
                        Text("회원탈퇴")
                            .font(.custom("NanumSquareOTFR", size: 15))
                            .foregroundColor(Color.init(white: 87/255))
                            .padding([.top, .bottom], 12)
                            .padding(.leading, 16)
                        
                        Spacer()
                    }
                }
                .actionSheet(isPresented: $viewModel.showRemoveAccountAlert) {
                    ActionSheet(title: Text("회원 탈퇴"),
                                message: Text("앱 계정을 삭제합니다.\n이 계정으로 등록된 리뷰 정보들도 모두 함께 삭제됩니다."),
                                buttons: [
                                    .destructive(Text("회원 탈퇴")) {
                                        viewModel.removeAccount { success in
                                            if success {
                                                viewControllerHolder?.present(style: .fullScreen) {
                                                    LoginView()
                                                }
                                            }
                                        }
                                    },
                                    .cancel(Text("취소"))
                                ]
                    )
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.init(white: 232/255), lineWidth: 1)
            )
            .padding(.top, 24)
            .padding([.leading, .trailing], 20)

            Spacer()
        }
        .padding([.leading, .trailing], 8)
        
        .alert(isPresented: $viewModel.removeAccountFailed) {
            Alert(title: Text("회원 탈퇴"),
                  message: Text("회원 탈퇴에 실패했습니다."),
                  dismissButton: .default(Text("확인")))
        }
        .customNavigationBar(title: "계정관리")
                    .navigationBarItems(leading: backButton)
    }
}

struct AccountManageView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AccountManageView(viewModel: RenewalSettingsViewModel())
        }
    }
}
