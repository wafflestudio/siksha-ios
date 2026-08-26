//
//  AccountManageView.swift
//  Siksha
//
//  Created by 김령교 on 6/26/24.
//

import SwiftUI

struct AccountManageView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel: AccountManageViewModel

    init(viewModel: AccountManageViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var backButton: some View {
        BackButton {
            self.presentationMode.wrappedValue.dismiss()
        }
    }

    var partitionBar: some View {
        Color.borderPrimary
            .frame(height: 1)
    }

    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 8) {
                Button(action: {
                    viewModel.showLogoutConfirmation = true
                }) {
                    HStack(alignment: .center) {
                        Text("로그아웃")
                            .customFont(font: .text15(weight: .Regular))
                            .foregroundColor(Color.blackColor)

                        Spacer()
                    }
                }
                .actionSheet(isPresented: $viewModel.showLogoutConfirmation) {
                    ActionSheet(
                        title: Text("로그아웃"),
                        message: Text("앱에서 로그아웃합니다."),
                        buttons: [
                            .destructive(Text("로그아웃"), action: performLogout),
                            .cancel(Text("취소")),
                        ]
                    )
                }

                partitionBar

                Button(action: {
                    viewModel.showDeleteAccountConfirmation = true
                }) {
                    HStack(alignment: .center) {
                        Text("회원탈퇴")
                            .customFont(font: .text15(weight: .Regular))
                            .foregroundColor(.accentLike)

                        Spacer()
                    }
                }
                .actionSheet(isPresented: $viewModel.showDeleteAccountConfirmation) {
                    ActionSheet(
                        title: Text("회원 탈퇴"),
                        message: Text("앱 계정을 삭제합니다.\n이 계정으로 등록된 리뷰 정보들도 모두 함께 삭제됩니다."),
                        buttons: [
                            .destructive(Text("회원 탈퇴"), action: performDeleteAccount),
                            .cancel(Text("취소")),
                        ]
                    )
                }
            }
            .padding(.vertical, 12)
            .padding(.leading, 18)
            .padding(.trailing, 11)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(Color.gray200, lineWidth: 1)
                    .background(Color.backgroundSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            )
            .padding(.top, 24)
            .padding(.horizontal, 20)
            .disabled(viewModel.isProcessing)

            Spacer()
        }
        .background(Color.backgroundPrimary)

        .alert(isPresented: $viewModel.deleteAccountFailed) {
            Alert(
                title: Text("회원 탈퇴"),
                message: Text("회원 탈퇴에 실패했습니다."),
                dismissButton: .default(Text("확인")))
        }
        .alert(isPresented: $viewModel.logoutFailed) {
            Alert(
                title: Text("로그아웃"),
                message: Text("로그아웃에 실패했습니다."),
                dismissButton: .default(Text("확인")))
        }

        .customNavigationBar(title: "계정관리")
        .navigationBarItems(leading: backButton)
    }

    private func transitionToLogin() {
        appState.didLogout()
    }

    private func performLogout() {
        Task {
            if await viewModel.logout() {
                transitionToLogin()
            }
        }
    }

    private func performDeleteAccount() {
        Task {
            if await viewModel.deleteAccount() {
                transitionToLogin()
            }
        }
    }
}

struct AccountManageView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AccountManageView(
                viewModel: AccountManageViewModel(
                    logoutUseCase: AppContainer.shared.useCases.logoutUseCase,
                    deleteAccountUseCase: AppContainer.shared.useCases.deleteAccountUseCase
                )
            )
            .environmentObject(AppState())
        }
    }
}
