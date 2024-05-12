//
//  RenewalSettingsView.swift
//  Siksha
//
//  Created by 김령교 on 3/3/24.
//

import SwiftUI
import UIKit

struct RenewalSettingsView: View {
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @ObservedObject var viewModel: RenewalSettingsViewModel
    @ObservedObject var orderViewModel = RestaurantOrderViewModel()
    @EnvironmentObject var appState: AppState
    
    init(viewModel: RenewalSettingsViewModel) {
        self.viewModel = viewModel
    }
    
    private let fontColor = Color.init(white: 185/255)
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 0) {
                profileState
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0))
                
                myWritings
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0))
                
                additionalSettings
                
                contact
                .padding(16)
                
                Spacer()
                
                versionInfo
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 15, trailing: 0))
                
            }
            .padding(.top, 24)
            .padding([.leading, .trailing], 8)
            .customNavigationBar(title: "icon")
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $viewModel.showVOC) {
            RenewalVOCView(viewModel)
        }
    }
    
    var profileState: some View {
        NavigationLink(destination: Dummy()) {
            HStack {
                Image("LogoEllipse")
                    .resizable()
                    .frame(width: 48, height: 48)
                    .padding(EdgeInsets(top: 13, leading: 12, bottom: 13, trailing: 6))
                
                
                Text("닉네임")
                    .font(.custom("NanumSquareOTFB", size: 16))
                    .foregroundColor(.black)
                
                Spacer()
                
                Text("변경하러 가기")
                    .font(.custom("NanumSquareOTFR", size: 10))
                    .foregroundColor(Color.init(white: 185/255))
                    .padding(.trailing, 1.25)
                arrow
            }.background(
                RoundedRectangle(cornerRadius: 8)
                    .foregroundColor(Color.init(white: 249/255))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(Color.init(white: 238/255), lineWidth: 1)
                    )
                    .padding(1)
            )
        }
    }
    
    var arrow: some View {
        Image("RenewalArrow")
            .resizable()
            .renderingMode(.original)
            .frame(width: 8, height: 11)
            .padding(.trailing, 11)
    }
    
    var myWritings: some View {
        NavigationLink(destination: Dummy()) {
            HStack(alignment: .center) {
                Text("내가 쓴 글")
                    .font(.custom("NanumSquareOTFB", size: 16))
                    .foregroundColor(.black)
                    .padding(EdgeInsets(top: 19, leading: 16, bottom: 19, trailing: 0))
                
                Spacer()
                
                arrow
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.init(white: 232/255), lineWidth: 1)
                .padding(1)
        )
    }
    
    var partitionBar: some View {
        Color.init(white: 232/255)
            .frame(height: 1)
            .padding([.leading, .trailing], 8)
    }
    
    var additionalSettings: some View {
        VStack(spacing: 0) {
            NavigationLink(destination: RestaurantOrderView(orderViewModel)) {
                HStack(alignment: .center) {
                    Text("식당 순서 변경")
                        .font(.custom("NanumSquareOTFR", size: 15))
                        .foregroundColor(.black)
                        .padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 0))
                    
                    Spacer()
                    
                    arrow
                }
            }
            
            partitionBar
            
            NavigationLink(destination: FavoriteRestaurantOrderView(orderViewModel)) {
                HStack(alignment: .center) {
                    Text("즐겨찾기 식당 순서 변경")
                        .font(.custom("NanumSquareOTFR", size: 15))
                        .foregroundColor(.black)
                        .padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 0))
                    
                    Spacer()
                    
                    arrow
                }
            }
            
            partitionBar
            
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
            
            partitionBar
            
            Button(action: {
                // change button
                viewModel.noMenuHide.toggle()
            }) {
                HStack(alignment: .center) {
                    Text("계정 관리")
                        .font(.custom("NanumSquareOTFR", size: 15))
                        .foregroundColor(.black)
                        .padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 0))
                    
                    Spacer()
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.init(white: 232/255), lineWidth: 1)
                .padding(1)
        )
    }
    
    var contact: some View {
        HStack {
            VStack(alignment: .leading) {
                Button(action: {
                    viewModel.showVOC = true
                }) {
                    Text("1:1 문의하기")
                        .font(.custom("NanumSquareOTFR", size: 15))
                        .foregroundColor(Color("main"))
                }
                .padding(.bottom, 8)
            }
            
            Spacer()
        }
    }
    
    var versionInfo: some View {
        VStack {
            Text(viewModel.isUpdateAvailable ? "업데이트가 가능합니다" : "최신버전을 이용중입니다.")
                .font(.custom("NanumSquareOTFB", size: 13))
                .foregroundColor(fontColor)
                .padding(.top, 20)
            Text("siksha-\(viewModel.version)")
                .font(.custom("NanumSquareOTFB", size: 13))
                .foregroundColor(fontColor)
        }
    }
}

struct RenewalSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RenewalSettingsView(viewModel: RenewalSettingsViewModel())
        }
    }
}
