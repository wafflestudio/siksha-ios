//
//  AlarmView.swift
//  Siksha
//
//  Created by 박정헌 on 8/30/25.
//

import SwiftUI

struct AlarmView: View {
    @ObservedObject var viewModel: MyLikedMenuViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject private var contentViewModel: ContentViewModel
    var backButton: some View {
        BackButton {
            contentViewModel.showPopUp = false
            self.presentationMode.wrappedValue.dismiss()
        }
    }
    var alarmSettingsView: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                Text("찜한 메뉴 알림 받기")
                    .foregroundStyle(Color.blackColor)
                    .customFont(font: .text15(weight: .Regular))
                Spacer()
                Toggle(
                    isOn: Binding(
                        get: { viewModel.isAlarmEnabled },
                        set: { viewModel.requestAlarmEnabledChange($0) }
                    )
                ) {
                    EmptyView()
                }
                .toggleStyle(AlarmSwitchStyle())

            }
            Spacer()
                .frame(height: 10)
            Color.borderPrimary
                .frame(height: 1)
            Spacer()
                .frame(height: 13.5)
            NavigationLink(destination: AlarmTimeView(viewModel: viewModel)) {
                HStack(alignment: .center) {
                    Text("메뉴 알림 설정")
                        .foregroundStyle(Color.blackColor)
                        .customFont(font: .text15(weight: .Regular))
                    Spacer()
                    Image("ArrowSmall")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(Color.gray500)
                        .frame(width: 16, height: 16)
                }
            }

        }
        .padding(EdgeInsets(top: 10, leading: 14, bottom: 10, trailing: 14))
        .background(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(Color.gray200, lineWidth: 1)
                .background(Color.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        )
    }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                alarmSettingsView
                Spacer()
                    .frame(height: 20)
                if viewModel.isAlarmEnabled {
                    if viewModel.likedMenuGroups.isEmpty {
                        Text("내가 찜한 메뉴가 없어요")
                            .foregroundStyle(Color.gray600)
                            .customFont(font: .text15(weight: .Bold))
                            .frame(maxWidth: .infinity, alignment: .center)

                            .padding(EdgeInsets(top: 231.5, leading: 0, bottom: 0, trailing: 0))

                    } else {
                        Text("알림 받을 메뉴를 선택하세요.")
                            .foregroundStyle(Color.gray600)
                            .customFont(font: .text14(weight: .Bold))
                            .padding(EdgeInsets(top: 0, leading: 14, bottom: 8, trailing: 0))

                        ForEach(viewModel.likedMenuGroups, id: \.self) {
                            group in
                            AlarmRestaurantCell(viewModel: viewModel, restaurantName: group.name, menus: group.menus)
                            Spacer()
                                .frame(height: 12)
                        }
                    }
                }

            }
            .padding(EdgeInsets(top: 18, leading: 16, bottom: 0, trailing: 17))
            .customNavigationBar(title: "메뉴 알림 설정")
            .navigationBarItems(leading: backButton)

        }
        .errorAlert(error: $viewModel.error)
        .background(Color.backgroundMain)
        .alert(
            "알림에 대한 권한이 없어요.", isPresented: $viewModel.noAlarmPermission,
            actions: {
                Button("취소", action: { viewModel.noAlarmPermission = false }).keyboardShortcut(.defaultAction)
                Button("설정하기") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                    viewModel.noAlarmPermission = false
                }
            },
            message: {
                Text("앱 설정으로 가서 알림 권한을 수정할 수 있어요. 수정 이후 설정에서 알람을 켜야 해요. 지금 설정으로 이동하시겠어요?")
            })

    }

}
