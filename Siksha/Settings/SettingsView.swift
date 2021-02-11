//
//  SettingsView.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/01.
//

import SwiftUI
import CoreGraphics

private extension SettingsView {
    
    func settingsCell(text: String, imageText: String, rotation: Bool, hide: Bool, _ geometry: GeometryProxy) -> some View {
        ZStack(alignment: .leading) {
            Image("SettingsCell")
                .resizable()
                .frame(width: geometry.size.width-32, height: 54)
            HStack() {
                Text(text)
                    .padding(.leading, 20)
                    .font(.custom("NanumSquareOTFB", size: 15))
                    .foregroundColor(.init("DefaultFontColor"))
                      
                Spacer()
                
                SettingsIcon(imageName: imageText, rotationAnimation: rotation, noMenuHide: hide)
            }
            .frame(width: geometry.size.width-48)
        }
    }
}

struct SettingsView: View {
    
    @ObservedObject var viewModel: SettingsViewModel

    
    init() {
        viewModel = SettingsViewModel()
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                // Navigation Bar
                ZStack {
                    Image("NaviBar")
                        .resizable()
                        .frame(width: geometry.size.width, height: geometry.safeAreaInsets.top+40)
                        .padding(.top, -geometry.safeAreaInsets.top)
                    Image("Logo")
                }
                // Navigation Bar
                
                NavigationView {
                    VStack(alignment: .leading, spacing: 10) {
                        Button(action: {
                            
                        }) {
                            NavigationLink(destination: InformationView()) {
                                settingsCell(text: "식샤 정보", imageText: "Back", rotation: false, hide: false, geometry)
                            }
                        }
                        Button(action: {
                            // icon rotation
                        }) {
                            settingsCell(text: "메뉴 새로고침", imageText: "Refresh", rotation: true, hide: false, geometry)
                        }
                        Spacer()
                            .frame(height: 25)
                        
                        Text("식당")
                            .multilineTextAlignment(/*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/)
                            .foregroundColor(.init("DefaultFontColor"))
                            .font(.footnote)
                        Button(action: {
                            // change button
                            viewModel.noMenuHide = !viewModel.noMenuHide
                        }) {
                            settingsCell(text: "메뉴 없는 식당 숨기기", imageText: "NotChecked", rotation: false, hide: viewModel.noMenuHide, geometry)
                        }
                        Button(action: {
                            
                        }) {
                            NavigationLink(destination: MenuOrderView()) {
                                settingsCell(text: "식당 순서 변경", imageText: "Back", rotation: false, hide: false, geometry)
                            }
                        }
                        Spacer()
                            .frame(height: 25)
                        
                        Text("즐겨찾기")
                            .multilineTextAlignment(/*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/)
                            .foregroundColor(.init("DefaultFontColor"))
                            .font(.footnote)
                        Button(action: {
                            
                        }) {
                            NavigationLink(destination: FavoriteMenuOrderView()) {
                                settingsCell(text: "식당 순서 변경", imageText: "Back", rotation: false, hide: false, geometry)
                            }
                        }
                        Spacer()
                    }
                    .padding(.top)
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
