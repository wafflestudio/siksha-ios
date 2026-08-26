//
//  MyLikedMenuModal.swift
//  Siksha
//
//  Created by 박정헌 on 8/27/25.
//

import Combine
import SwiftUI

struct MyLikedMenuModal: View {
    @EnvironmentObject var contentViewModel: ContentViewModel
    @State var isYesSelected = false
    @State var isNoSelected = false
    @State var isConfirmedEnabled = false
    @ObservedObject var viewModel: MyLikedMenuViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .bottom) {
                VStack(alignment: .center, spacing: 0) {
                    Spacer()
                    Image(.Images.alarmModal)
                        .resizable()
                        .frame(width: 253, height: 179)
                        .shadow(color: Color.black.opacity(0.25), radius: 4, x: 0, y: -1)
                        .mask(Rectangle().padding(.top, -1))

                }
                .frame(maxWidth: .infinity)
                .frame(height: 216)
                .padding(.zero)
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(UIColor(red: 168 / 255, green: 146 / 255, blue: 123 / 255, alpha: 0.45)),
                        Color(UIColor(red: 1, green: 1, blue: 1, alpha: 0)),
                    ]), startPoint: .bottom, endPoint: .top
                )
                .frame(maxWidth: .infinity)
                .frame(height: 55)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 216)
            .padding(.zero)
            .background(Color(UIColor(red: 247 / 255, green: 236 / 255, blue: 209 / 255, alpha: 1)))
            Spacer()
                .frame(height: 24)
            VStack(alignment: .leading, spacing: 0) {
                Text("찜한 메뉴, 이제는 나올 때마다\n알림으로 받을 수 있어요!")
                    .foregroundStyle(Color.blackColor)
                    .customFont(font: .text18(weight: .ExtraBold))
                Spacer()
                    .frame(height: 8)
                Text("알림 받을 메뉴는 [설정 > 내가 찜한 메뉴] 탭에서\n언제든 개별적으로 ON/OFF 설정할 수 있어요.")
                    .foregroundColor(Color.gray700)
                    .customFont(font: .text12(weight: .Regular))
                Spacer()
                    .frame(height: 30)
                HStack(alignment: .center, spacing: 10) {
                    Image(isYesSelected ? .Icons.Common.CheckCircle.filled : .Icons.Common.CheckCircle.empty)
                        .renderingMode(.original)
                        .resizable()
                        .frame(width: 20, height: 20)
                        .onTapGesture {
                            isYesSelected = true
                            isNoSelected = false
                            isConfirmedEnabled = true
                        }
                    Text("좋아요, 알림을 받을래요.")
                        .foregroundStyle(Color.blackColor)
                        .customFont(font: .text15(weight: .Regular))

                }
                Spacer()
                    .frame(height: 12)
                HStack(alignment: .center, spacing: 10) {
                    Image(isNoSelected ? .Icons.Common.CheckCircle.filled : .Icons.Common.CheckCircle.empty)
                        .renderingMode(.original)
                        .resizable()
                        .frame(width: 20, height: 20)
                        .onTapGesture {
                            isYesSelected = false
                            isNoSelected = true
                            isConfirmedEnabled = true
                        }
                    Text("괜찮아요, 알림을 받지 않을래요.")
                        .foregroundStyle(Color.blackColor)
                        .customFont(font: .text15(weight: .Regular))

                }
                Spacer()
                    .frame(height: 30)
                HStack(alignment: .center, spacing: 7) {
                    Button(action: {
                        contentViewModel.showMyMenuViewFromPopup = true
                        contentViewModel.showModal = false
                        UserDefaults.standard.set(true, forKey: "isAlreadyDisplayedMyLikedMenuModal")

                    }) {
                        Text("직접 설정하기")
                            .padding(.vertical, 11)
                            .foregroundStyle(Color.gray600)
                            .frame(maxWidth: .infinity)
                            .background(Color.gray100)
                            .cornerRadius(8)
                            .customFont(font: .text16(weight: .Bold))
                    }
                    Button(action: {
                        if isYesSelected {
                            viewModel.requestAlarmEnabledChange(true)
                            contentViewModel.showModal = false
                        } else {
                            viewModel.setAlarmEnabled(false)
                            contentViewModel.showModal = false
                        }

                        UserDefaults.standard.set(true, forKey: "isAlreadyDisplayedMyLikedMenuModal")
                    }) {
                        Text("완료")
                            .padding(.vertical, 11)
                            .foregroundStyle(Color.textButton)
                            .frame(maxWidth: .infinity)
                            .background(isConfirmedEnabled ? Color.orange500 : Color.gray600)
                            .cornerRadius(8)
                            .customFont(font: .text16(weight: .Bold))
                    }
                    .disabled(!isConfirmedEnabled)
                }
            }
            .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
            .frame(maxWidth: .infinity)

        }
        .padding(EdgeInsets(top: 0, leading: 0, bottom: 24, trailing: 0))
        .background(Color.backgroundSecondary)
        .cornerRadius(16)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .errorAlert(error: $viewModel.error)
        .alert(
            "알림에 대한 권한이 없어요.", isPresented: $viewModel.noAlarmPermission,
            actions: {
                Button("취소", action: {}).keyboardShortcut(.defaultAction)
                Button("설정하기") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
            },
            message: {
                Text("앱 설정으로 가서 알림 권한을 수정할 수 있어요. 수정 이후 설정에서 알람을 켜야 해요. 지금 설정으로 이동하시겠어요?")
            })

    }
}
private struct MyLikedMenuModalPreview: View {
    @StateObject private var contentViewModel = ContentViewModel()
    @StateObject private var viewModel = MyLikedMenuViewModel(
        fetchMyLikedMenusUseCase: AppContainer.shared.useCases.fetchMyLikedMenusUseCase,
        getMenuAlarmEnabledUseCase: AppContainer.shared.useCases.getMenuAlarmEnabledUseCase,
        setMenuAlarmEnabledUseCase: AppContainer.shared.useCases.setMenuAlarmEnabledUseCase,
        updateMenuAlarmUseCase: AppContainer.shared.useCases.updateMenuAlarmUseCase,
        updateAllMenuAlarmsUseCase: AppContainer.shared.useCases.updateAllMenuAlarmsUseCase,
        fetchMenuAlarmTimeUseCase: AppContainer.shared.useCases.fetchMenuAlarmTimeUseCase,
        updateMenuAlarmTimeUseCase: AppContainer.shared.useCases.updateMenuAlarmTimeUseCase,
        updateMenuLikeUseCase: AppContainer.shared.useCases.updateMenuLikeUseCase,
        menuAlarmNotificationManager: AppContainer.shared.menuAlarmNotificationManager,
        fetchPersonalRestaurantsUseCase: AppContainer.shared.useCases.fetchPersonalRestaurantsUseCase,
        updateRestaurantPreferenceUseCase: AppContainer.shared.useCases.updateRestaurantPreferenceUseCase
    )

    var body: some View {
        ZStack {
            Color.backgroundDim
                .ignoresSafeArea()

            MyLikedMenuModal(viewModel: viewModel)
                .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 7))
        }
        .environmentObject(contentViewModel)
    }
}

#Preview {
    MyLikedMenuModalPreview()
}
