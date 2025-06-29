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
    
    @ObservedObject var userModel = UserManager.shared
    @ObservedObject var viewModel: RenewalSettingsViewModel
    @ObservedObject var orderViewModel = RestaurantOrderViewModel()
    
    
    init(viewModel: RenewalSettingsViewModel) {
        self.viewModel = viewModel
    }
    
    private let borderColor = Color("Color/Foundation/Gray/200")
    private let partitionColor = Color("SemanticColor/Border/Primary")
    private let blackColor = Color("Color/Foundation/Base/BlackColor")
    private let gray500 = Color("Color/Foundation/Gray/500")
    private let gray900 = Color("Color/Foundation/Gray/900")
    
    var body: some View {
            VStack(alignment: .center, spacing: 0) {
                profileState
                    .padding(.bottom, 20)
                
                myWritings
                    .padding(.bottom, 20)
                
                additionalSettings
                    .padding(.bottom, 20)
                
                contact
                
                Spacer()
                
                versionInfo
                    .padding(.bottom, 15)
                
            }
            .errorAlert(error: $viewModel.error)
         
            .padding(.top, 24)
            .padding([.leading, .trailing], 20)
        
        .customNavigationBar(title: "icon")

        .sheet(isPresented: $viewModel.showVOC) {
            RenewalVOCView(viewModel)
        }
    }
    
    var profileState: some View {
        NavigationLink(destination: ProfileEditView(viewModel: ProfileEditViewModel())) {
            HStack {
                if let profileImageData = userModel.imageData,
                let uiImage = UIImage(data: profileImageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipShape(Circle())
                        .frame(width: 48, height: 48)
                        .padding(EdgeInsets(top: 13, leading: 12, bottom: 13, trailing: 6))
                } else {
                    Image("LogoEllipse")
                        .resizable()
                        .frame(width: 48, height: 48)
                        .padding(EdgeInsets(top: 13, leading: 12, bottom: 13, trailing: 6))
                }
                
                Text(userModel.nickname ?? "무명의 미식가")
                    .font(.custom("NanumSquareOTFB", size: 16))
                    .foregroundColor(gray900)
                
                Spacer()
                
                arrow
            }
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(borderColor, lineWidth: 1)
                    .background(Color("SemanticColor/Background/Secondary"))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            )
        }
    }
    
    var arrow: some View {
        Image("ArrowSmall")
            .resizable()
            .renderingMode(.template)
            .foregroundColor(Color("Color/Foundation/Gray/500"))
            .frame(width: 16, height: 16)
            .padding(.trailing, 12)
    }
    
    var myWritings: some View {
        NavigationLink(destination: MyPostView(viewModel: MyPostViewModel(communityRepository: DomainManager.shared.domain.communityRepository))) {
            HStack(alignment: .center) {
                Text("내가 쓴 글")
                    .font(.custom("NanumSquareOTF", size: 16))
                    .foregroundColor(blackColor)
                    .padding([.top, .bottom], 19)
                    .padding(.leading, 16)
                
                Spacer()
                
                arrow
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(borderColor, lineWidth: 1)
                .background(Color("SemanticColor/Background/Secondary"))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        )
    }
    
    var partitionBar: some View {
        partitionColor
            .frame(height: 1)
            .padding(.leading, 7)
            .padding(.trailing, 9)
    }
    
    var additionalSettings: some View {
        VStack(spacing: 0) {
            NavigationLink(destination: RestaurantOrderView(orderViewModel)) {
                HStack(alignment: .center) {
                    Text("식당 순서 변경")
                        .font(.custom("NanumSquareOTFR", size: 15))
                        .foregroundColor(blackColor)
                        .padding([.top, .bottom], 12)
                        .padding(.leading, 16)
                    
                    Spacer()
                    
                    arrow
                }
            }
            
            partitionBar
            
            NavigationLink(destination: FavoriteRestaurantOrderView(orderViewModel)) {
                HStack(alignment: .center) {
                    Text("즐겨찾기 식당 순서 변경")
                        .font(.custom("NanumSquareOTFR", size: 15))
                        .foregroundColor(blackColor)
                        .padding([.top, .bottom], 12)
                        .padding(.leading, 16)
                    
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
                        .foregroundColor(blackColor)
                        .padding([.top, .bottom], 12)
                        .padding(.leading, 16)
                    
                    Spacer()
                    
                    Image(viewModel.noMenuHide ? "CheckCircle" : "CheckCircle")
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 20, height: 20)
                        .foregroundStyle(Color(viewModel.noMenuHide ? "Color/Foundation/Orange/500" :"Color/Foundation/Gray/500"))
                        .padding(.trailing, 14)
                }
            }
            
            partitionBar
            
            NavigationLink(destination: AccountManageView(viewModel: viewModel)) {
                HStack(alignment: .center) {
                    Text("계정 관리")
                        .font(.custom("NanumSquareOTFR", size: 15))
                        .foregroundColor(blackColor)
                        .padding([.top, .bottom], 12)
                        .padding(.leading, 16)
                    
                    Spacer()
                    
                    arrow
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(borderColor, lineWidth: 1)
                .background(Color("SemanticColor/Background/Secondary"))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        )
    }
    
    var contact: some View {
        
        Button(action: {
            viewModel.showVOC = true
        }) {
            HStack(alignment: .center) {
                Text("1:1 문의하기")
                    .font(.custom("NanumSquareOTFB", size: 15))
                    .foregroundColor(Color("Color/Foundation/Orange/500"))
                    .padding([.top, .bottom], 15)
                    .padding(.leading, 16)
                
                Spacer()
                
                arrow
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(borderColor, lineWidth: 1)
                .background(Color("SemanticColor/Background/Secondary"))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        )
    }
    
    var versionInfo: some View {
        VStack {
            Text("siksha-\(viewModel.version)")
                .font(.custom("NanumSquareOTF", size: 12))
                .foregroundColor(gray500)
                .padding(.top, 20)
            Text(viewModel.isUpdateAvailable ? "업데이트가 가능합니다" : "최신버전을 이용중입니다.")
                .font(.custom("NanumSquareOTF", size: 12))
                .foregroundColor(gray500)
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
