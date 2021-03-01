//
//  SettingsView.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/01.
//

import SwiftUI
import KakaoSDKAuth
import UIKit

struct SettingsView: View {
    @ObservedObject var viewModel = SettingsViewModel()
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                NavigationBar(geometry)
                
                NavigationView {
                    VStack(alignment: .leading) {
                        Text("식샤 설정")
                            .foregroundColor(.init(white: 79/255))
                            .font(.custom("NanumSquareOTFB", size: 18))
                            .padding(.top, 20)
                        
                        NavigationLink(destination: InformationView()) {
                            SettingsCell(text: "식샤 정보") {
                                Image("Arrow")
                                    .resizable()
                                    .frame(width: 8, height: 15)
                            }
                        }

                        Button(action: {
                            
                        }) {
                            SettingsCell(text: "앱 로그아웃") {
                                EmptyView()
                            }
                        }
                        
                        Text("식당 설정")
                            .foregroundColor(.init(white: 79/255))
                            .font(.custom("NanumSquareOTFB", size: 18))
                            .padding(.top, 25)
                        
                        NavigationLink(destination: MenuOrderView(viewModel)) {
                            SettingsCell(text: "식당 순서 변경") {
                                Image("Arrow")
                                    .resizable()
                                    .frame(width: 8, height: 15)
                            }
                        }
                        
                        NavigationLink(destination: FavoriteMenuOrderView(viewModel)) {
                            SettingsCell(text: "즐겨찾기 식당 순서 변경") {
                                Image("Arrow")
                                    .resizable()
                                    .frame(width: 8, height: 15)
                            }
                        }
                        
                        Button(action: {
                            // change button
                            viewModel.noMenuHide.toggle()
                        }) {
                            SettingsCell(text: "메뉴 없는 식당 숨기기") {
                                Image(viewModel.noMenuHide ? "Checked" : "NotChecked")
                                    .resizable()
                                    .frame(width: 26, height: 26)
                            }
                        }
                        
                        Text("로그인")
                            .foregroundColor(.init("DefaultFontColor"))
                            .font(.footnote)
                            .padding(.top, 25)
                        
                        Button(action : {
                            // checks whether KakaoTalk is installed
                            if (AuthApi.isKakaoTalkLoginAvailable()) {
                                AuthApi.shared.loginWithKakaoTalk {(oauthToken, error) in
                                    print(oauthToken?.accessToken)
                                    print(error)
                                }
                            } else {
                                // Login through Safari
                                AuthApi.shared.loginWithKakaoAccount {(oauthToken, error) in
                                    print(oauthToken?.accessToken)
                                    print(error)
                                }
                            }
                        }){
                            Text("카카오 로그인")
                        }
                
                        Spacer()
                    }
                    .padding(.top, 32)
                    .padding([.leading, .trailing], 16)
                    .navigationBarHidden(true)
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SettingsView()
        }
    }
}
