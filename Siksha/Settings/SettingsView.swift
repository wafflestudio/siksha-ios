//
//  SettingsView.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/01.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @EnvironmentObject var appState: AppState
    @State private var isAnimating = false
    @State private var inProgress = false
    
    private let foreverAnimation = Animation.linear(duration: 2.0).repeatForever(autoreverses: false)
    
    init() {
        viewModel = SettingsViewModel()
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                NavigationBar(geometry)
                
                NavigationView {
                    VStack(alignment: .leading) {
                        NavigationLink(destination: InformationView()) {
                            SettingsCell(text: "식샤 정보") {
                                Image("Arrow")
                                    .resizable()
                                    .frame(width: 8, height: 15)
                            }
                        }
                        Button(action: {
                            viewModel.refreshMenu = true
                        }) {
                            SettingsCell(text: "메뉴 새로고침") {
                                if viewModel.refreshMenu {
                                    Image("Refresh")
                                        .resizable()
                                        .frame(width: 13, height: 13)
                                        .rotationEffect(isAnimating ? .degrees(360) : .zero)
                                        .animation(foreverAnimation)
                                        .onAppear {
                                            self.isAnimating = true
                                        }
                                        .onDisappear {
                                            self.isAnimating = false
                                        }
                                } else {
                                    Image("Refresh")
                                        .resizable()
                                        .frame(width: 13, height: 13)
                                }
                            }
                        }
                        
                        Text("식당")
                            .foregroundColor(.init("DefaultFontColor"))
                            .font(.footnote)
                            .padding(.top, 25)
                        
                        Button(action: {
                            // change button
                            viewModel.noMenuHide.toggle()
                        }) {
                            SettingsCell(text: "메뉴 없는 식당 숨기기") {
                                Image(viewModel.noMenuHide ? "Checked" : "NotChecked")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                            }
                        }
                        NavigationLink(destination: MenuOrderView()) {
                            SettingsCell(text: "식당 순서 변경") {
                                Image("Arrow")
                                    .resizable()
                                    .frame(width: 8, height: 15)
                            }
                        }
                        
                        Text("즐겨찾기")
                            .foregroundColor(.init("DefaultFontColor"))
                            .font(.footnote)
                            .padding(.top, 25)
                        
                        NavigationLink(destination: FavoriteMenuOrderView()) {
                            SettingsCell(text: "식당 순서 변경") {
                                Image("Arrow")
                                    .resizable()
                                    .frame(width: 8, height: 15)
                            }
                        }
                        Spacer()
                    }
                    .padding(.top, 32)
                    .padding([.leading, .trailing], 16)
                    .navigationBarHidden(true)
                }
                
            }
        }
        .onAppear {
            self.viewModel.appState = appState
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
