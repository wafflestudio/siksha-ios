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
    
    private let borderColor = Color.gray200
    private let partitionColor = Color.borderPrimary
    private let blackColor = Color.blackColor
    private let gray500 = Color.gray500
    private let gray900 = Color.gray900
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 20) {
                profileState
                
                myWritings
                
                additionalSettings
                
                contact
                
                Spacer()
                
                versionInfo
                    .padding(.bottom, 35)
                
            }
            .padding(.top, 24)
            .padding([.leading, .trailing], 20)
        }
        .background(Color.backgroundPrimary)
        .customNavigationBar(title: "icon")
        .errorAlert(error: $viewModel.error)
    }
    
    var profileState: some View {
        NavigationLink(destination: ProfileEditView(viewModel: ProfileEditViewModel())) {
            HStack(spacing: 11) {
                if let profileImageData = userModel.imageData,
                let uiImage = UIImage(data: profileImageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipShape(Circle())
                        .frame(width: 48, height: 48)
                } else {
                    Image(.Icons.Common.profileImagePlaceholder)
                        .resizable()
                        .frame(width: 48, height: 48)
                }
                
                Text(userModel.nickname ?? "무명의 미식가")
                    .customFont(font: .text16(weight: .Bold))
                    .foregroundColor(gray900)
                
                Spacer()
                
                arrow
            }
            .padding(.vertical, 11)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(borderColor, lineWidth: 1)
                    .background(Color.backgroundSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            )
        }
    }
    
    var arrow: some View {
        Image("ArrowSmall")
            .resizable()
            .renderingMode(.template)
            .foregroundColor(Color.gray500)
            .frame(width: 16, height: 16)
    }
    
    var myWritings: some View {

        VStack(spacing: 8) {
            NavigationLink(destination: MyPostView(viewModel: MyPostViewModel(communityRepository: AppContainer.shared.domain.communityRepository))) {
                HStack(alignment: .center) {
                    Text("내가 쓴 글")
                        .customFont(font: .text15(weight: .Regular))
                        .foregroundColor(blackColor)
                    
                    Spacer()
                    
                    arrow
                }
            }
            
            partitionBar
            
            NavigationLink(destination: MyReviewManageView(viewModel: MyReviewViewModel(repository: AppContainer.shared.domain.userRepository))) {
                HStack(alignment: .center) {
                    Text("나의 평가 관리")
                        .customFont(font: .text15(weight: .Regular))
                        .foregroundColor(blackColor)
                    
                    Spacer()
                    
                    arrow
                }
            }
            
            partitionBar
            NavigationLink(destination: MyLikedMenuView(viewModel: MyLikedMenuViewModel(myLikedMenuRepository: AppContainer.shared.domain.myLikedMenuRepository))) {
                HStack(alignment: .center) {
                    Text("내가 찜한 메뉴")
                        .customFont(font: .text15(weight: .Regular))
                        .foregroundColor(blackColor)
                    
                    Spacer()
                    
                    arrow
                }
            }
        }
        .padding([.vertical, .trailing], 12)
        .padding(.leading, 16)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(borderColor, lineWidth: 1)
                .background(Color.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        )
    }
    
    var partitionBar: some View {
        partitionColor
            .frame(height: 1)
    }
    
    var additionalSettings: some View {
        VStack(spacing: 8) {
            NavigationLink(destination: RestaurantOrderView(orderViewModel)) {
                HStack(alignment: .center) {
                    Text("식당 순서 변경")
                        .customFont(font: .text15(weight: .Regular))
                        .foregroundColor(blackColor)
                    
                    Spacer()
                    
                    arrow
                }
            }
            
            partitionBar
            
            NavigationLink(destination: FavoriteRestaurantOrderView(orderViewModel)) {
                HStack(alignment: .center) {
                    Text("즐겨찾기 식당 순서 변경")
                        .customFont(font: .text15(weight: .Regular))
                        .foregroundColor(blackColor)
                    
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
                        .customFont(font: .text15(weight: .Regular))
                        .foregroundColor(blackColor)
                    
                    Spacer()
                    
                    Image("CheckCircle")
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 20, height: 20)
                        .foregroundStyle(viewModel.noMenuHide ? Color.orange500 : Color.gray500)
                        .padding(.trailing, 2)
                }
            }
            
            partitionBar
            
            NavigationLink(destination: AccountManageView(viewModel: viewModel)) {
                HStack(alignment: .center) {
                    Text("계정 관리")
                        .customFont(font: .text15(weight: .Regular))
                        .foregroundColor(blackColor)
                    
                    Spacer()
                    
                    arrow
                }
            }
            #if DEBUG
            partitionBar
            
            NavigationLink(destination: DevMenuView()) {
                HStack(alignment: .center) {
                    Text("개발자 메뉴")
                        .customFont(font: .text15(weight: .Regular))
                        .foregroundColor(blackColor)
                    
                    Spacer()
                    
                    arrow
                }
            }
            #endif
        }
        .padding([.vertical, .trailing], 12)
        .padding(.leading, 16)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(borderColor, lineWidth: 1)
                .background(Color.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        )
    }
    
    var contact: some View {
        NavigationLink(destination: RenewalVOCView(viewModel)) {
            HStack(alignment: .center) {
                Text("1:1 문의하기")
                    .customFont(font: .text15(weight: .Bold))
                    .foregroundColor(.orange500)
                
                Spacer()
                
                arrow
            }
        }
        .padding(.vertical, 8)
        .padding(.leading, 16)
        .padding(.trailing, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(borderColor, lineWidth: 1)
                .background(Color.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        )
    }
    
    var versionInfo: some View {
        VStack(spacing: 0) {
            Text("siksha-\(viewModel.version)")
                .customFont(font: .text12(weight: .Regular))
                .foregroundColor(gray500)
                .padding(.top, 20)
            Text(viewModel.isUpdateAvailable ? "업데이트가 가능합니다" : "최신버전을 이용중입니다.")
                .customFont(font: .text12(weight: .Regular))
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
