//
//  SettingsView.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/01.
//

import SwiftUI
import UIKit

struct SettingsView: View {
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @ObservedObject var viewModel = SettingsViewModel()
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                ScrollView {
                    NavigationLink(destination: InformationView(viewModel)) {
                        HStack {
                            Image("LogoEllipse")
                                .resizable()
                                .frame(width: 48, height: 48)
                                .padding(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
                            
                            VStack(alignment: .leading) {
                                Text(viewModel.isUpdateAvailable ? "업데이트가 가능합니다." : "최신버전을 이용중입니다.")
                                    .font(.custom("NanumSquareOTFR", size: 14))
                                    .foregroundColor(.black)
                                Text("siksha-\(viewModel.version)")
                                    .font(.custom("NanumSquareOTFR", size: 14))
                                    .foregroundColor(.black)
                            }
                            
                            Spacer()
                            
                            Image("Arrow")
                                .resizable()
                                .renderingMode(.original)
                                .frame(width: 10, height: 16)
                                .padding(.trailing, 11)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.init(white: 232/255), lineWidth: 1)
                                .padding(1)
                        )
                    }
                    
                    VStack(spacing: 0) {
                        NavigationLink(destination: RestaurantOrderView(viewModel)) {
                            HStack(alignment: .center) {
                                Text("식당 순서 변경")
                                    .font(.custom("NanumSquareOTFR", size: 15))
                                    .foregroundColor(.black)
                                    .padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 0))
                                
                                Spacer()
                                
                                Image("Arrow")
                                    .resizable()
                                    .renderingMode(.original)
                                    .frame(width: 8, height: 15)
                                    .padding(.trailing, 11)
                            }
                        }
                        
                        Color.init(white: 232/255)
                            .frame(height: 1)
                            .padding([.leading, .trailing], 8)
                        
                        NavigationLink(destination: FavoriteRestaurantOrderView(viewModel)) {
                            HStack(alignment: .center) {
                                Text("즐겨찾기 식당 순서 변경")
                                    .font(.custom("NanumSquareOTFR", size: 15))
                                    .foregroundColor(.black)
                                    .padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 0))
                                
                                Spacer()
                                
                                Image("Arrow")
                                    .resizable()
                                    .renderingMode(.original)
                                    .frame(width: 8, height: 15)
                                    .padding(.trailing, 11)
                            }
                        }
                        
                        Color.init(white: 232/255)
                            .frame(height: 1)
                            .padding([.leading, .trailing], 8)
                        
                        Button(action: {
                            // change button
                            viewModel.noMenuHide.toggle()
                        }) {
                            HStack(alignment: .center) {
                                Text("메뉴 없는 식당 숨기기")
                                    .font(.custom("NanumSquareOTFR", size: 15))
                                    .foregroundColor(.black)
                                    .padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 0))
                                
                                Spacer()
                                
                                Image(viewModel.noMenuHide ? "Checked" : "NotChecked")
                                    .resizable()
                                    .renderingMode(.original)
                                    .frame(width: 20, height: 20)
                                    .padding(.trailing, 11)
                            }
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.init(white: 232/255), lineWidth: 1)
                            .padding(1)
                    )
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Button(action: {
                                viewModel.showVOC = true
                            }) {
                                Text("1:1 문의하기")
                                    .font(.custom("NanumSquareOTFR", size: 15))
                                    .foregroundColor(Color("MainThemeColor"))
                            }
                            .padding(.bottom, 8)
                            
                            Button(action: {
                                viewModel.showSignOutAlert = true
                            }) {
                                Text("앱 로그아웃")
                                    .font(.custom("NanumSquareOTFR", size: 15))
                                    .foregroundColor(.black)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(16)
                    
                    Spacer()
                    
                }
                .padding(.top, 24)
                .padding([.leading, .trailing], 8)
            }
            .customNavigationBar(title: "icon")
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $viewModel.showVOC) {
            VOCView(viewModel)
        }
        .actionSheet(isPresented: $viewModel.showSignOutAlert, content: {
            ActionSheet(title: Text("로그아웃"),
                        message: Text("앱에서 로그아웃합니다."),
                        buttons: [
                            .destructive(Text("로그아웃"), action: {
                                UserDefaults.standard.set(nil, forKey: "accessToken")
                                viewControllerHolder?.present(style: .fullScreen) {
                                    LoginView()
                                }
                            }),
                            .cancel(Text("취소"))
                        ]
            )
        })
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SettingsView()
        }
    }
}
