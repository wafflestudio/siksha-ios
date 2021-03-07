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
                                    .renderingMode(.original)
                                    .frame(width: 8, height: 15)
                            }
                        }

                        Button(action: {
                            viewModel.showSignOutAlert = true
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
                                    .renderingMode(.original)
                                    .frame(width: 8, height: 15)
                            }
                        }
                        
                        NavigationLink(destination: FavoriteMenuOrderView(viewModel)) {
                            SettingsCell(text: "즐겨찾기 식당 순서 변경") {
                                Image("Arrow")
                                    .resizable()
                                    .renderingMode(.original)
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
                                    .renderingMode(.original)
                                    .frame(width: 26, height: 26)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.top, 32)
                    .padding([.leading, .trailing], 16)
                    .navigationBarTitle(Text(""), displayMode: .inline)
                    .navigationBarHidden(true)
                }
            }
            .actionSheet(isPresented: $viewModel.showSignOutAlert, content: {
                ActionSheet(title: Text("로그아웃"),
                            message: Text("앱에서 로그아웃합니다."),
                            buttons: [
                                .destructive(Text("로그아웃"), action: {
                                    UserDefaults.standard.set(nil, forKey: "accessToken")
                                    viewControllerHolder?.present(style: .fullScreen) {
                                        LoginView().environmentObject(appState)
                                    }
                                }),
                                .cancel(Text("취소"))
                            ]
                )
            })
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
