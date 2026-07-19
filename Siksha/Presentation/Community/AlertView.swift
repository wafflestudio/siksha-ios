import SwiftUI

struct AlertView<CommunityPostViewModel>: View where CommunityPostViewModel: CommunityPostViewModelType {
    private let fontColor = Color("Color/Foundation/Gray/700")
    private let orangeColor = Color.init("Color/Foundation/Orange/500")
    private let lightGrayColor = Color.init("Color/Foundation/Gray/600")
    private var commentId: Int? = nil
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @State private var reportCompleteAlertIsShown = false
    @State private var isReportSuccessful = false
    @State private var reportReason = ""
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @ObservedObject var settingsViewModel: RenewalSettingsViewModel
    @ObservedObject var communityPostViewModel: CommunityPostViewModel
    var backButton: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Image("NavigationBack")
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .foregroundColor(Color.iconWhiteIcon)
        }
        .contentShape(Rectangle())
    }

    init(_ settingsViewModel: RenewalSettingsViewModel, _ communityPostViewModel: CommunityPostViewModel) {
        self.settingsViewModel = settingsViewModel
        self.communityPostViewModel = communityPostViewModel
    }
    init(
        _ settingsViewModel: RenewalSettingsViewModel, _ communityPostViewModel: CommunityPostViewModel, commentId: Int?
    ) {
        self.settingsViewModel = settingsViewModel
        self.communityPostViewModel = communityPostViewModel
        self.commentId = commentId
        print("COMMENT: \(commentId)")
        if let commentId {
            if commentId <= 0 {
                self.commentId = nil
            }
        }
    }
    var body: some View {
        GeometryReader { geometry in
            VStack {
                VStack(spacing: 0) {
                    ZStack {
                        Color.backgroundGNB
                            .ignoresSafeArea(.all)
                        HStack {
                            backButton
                            Spacer()
                        }.padding(.zero)
                        HStack {
                            Text("신고하기")
                                .foregroundColor(.textGNB)
                                .frame(alignment: .center)
                                .customFont(font: .text18(weight: .ExtraBold))
                        }.padding(.zero)

                    }.frame(height: 44)
                    HStack(spacing: 10) {
                        Image("Comment-new")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(Color.gray700)
                            .frame(width: 18, height: 18)

                        Text("어떤 이유로 신고하시나요?")
                            .customFont(font: .text18(weight: .ExtraBold))
                            .foregroundStyle(Color.blackColor)
                            .lineLimit(1)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(EdgeInsets(top: 44, leading: 16, bottom: 20, trailing: 16))

                    HStack {
                        Image(.Icons.Common.profileImagePlaceholder)
                            .renderingMode(.original)
                            .resizable()
                            .frame(width: 24, height: 24)

                        Text("ID \(settingsViewModel.userId)")
                            .customFont(font: .text12(weight: .Bold))

                        Spacer()
                    }
                    .padding(EdgeInsets(top: 0, leading: 28, bottom: 8, trailing: 28))

                    ZStack(alignment: .bottom) {
                        TextView(text: $reportReason, placeHolder: .constant(""), maxCount: 500)
                            .frame(height: 280)
                            .customFont(font: .text13(weight: .Regular))

                        HStack {
                            Spacer()
                            Text("\(reportReason.count)자 / 500자")
                                .customFont(font: .text11(weight: .Regular))
                                .foregroundColor(.gray700)
                        }
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 8))
                    }
                    .padding([.leading, .trailing], 28)

                    Spacer()

                    Button(
                        action: {
                            if commentId == nil {
                                communityPostViewModel.reportPost(reason: reportReason) { success, errorMessage in
                                    if success {
                                        alertTitle = "신고"
                                        alertMessage = "신고되었습니다."
                                        isReportSuccessful = true

                                    } else {
                                        alertTitle = "신고"
                                        alertMessage = errorMessage ?? "신고에 실패했습니다."
                                    }
                                    reportCompleteAlertIsShown = true
                                }
                            } else {
                                communityPostViewModel.reportComment(commentId: commentId!, reason: reportReason) {
                                    success, errorMessage in
                                    if success {
                                        alertTitle = "신고"
                                        alertMessage = "신고되었습니다."
                                        isReportSuccessful = true
                                    } else {
                                        alertTitle = "신고"
                                        alertMessage = errorMessage ?? "신고에 실패했습니다."
                                    }
                                    reportCompleteAlertIsShown = true
                                }
                            }
                        },
                        label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .foregroundColor(reportReason.count > 0 ? .orange500 : .gray600)

                                Text("올리기")
                                    .customFont(font: .text18(weight: .ExtraBold))
                                    .foregroundColor(.textButton)
                            }
                        }
                    )
                    .disabled(reportReason.count == 0)
                    .frame(height: 56)
                    .padding(16)
                }
                .background(
                    Color.backgroundPrimary.onTapGesture {
                        UIApplication.shared.endEditing()
                    }
                )
                .alert(
                    isPresented: $reportCompleteAlertIsShown,
                    content: {
                        Alert(
                            title: Text(alertTitle), message: Text(alertMessage),
                            dismissButton: .default(Text("OK")) {
                                if isReportSuccessful {
                                    self.presentationMode.wrappedValue.dismiss()
                                }
                            })
                    }
                )
                .ignoresSafeArea(.keyboard)
            }
        }
    }
}

#Preview {
    AlertView(
        RenewalSettingsViewModel(
            manageRestaurantsWithoutMenuVisibilityUseCase: AppContainer.shared.useCases
                .manageRestaurantsWithoutMenuVisibilityUseCase,
            fetchCurrentUserUseCase: AppContainer.shared.useCases.fetchCurrentUserUseCase,
            submitVOCUseCase: AppContainer.shared.useCases.submitVOCUseCase,
            fetchAppStoreVersionUseCase: AppContainer.shared.useCases.fetchAppStoreVersionUseCase
        ),
        CommunityPostViewModel(
            communityRepository: AppContainer.shared.domain.communityRepository,
            blockManager: AppContainer.shared.blockManager,
            postId: 1
        )
    )
}
