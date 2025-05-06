import SwiftUI


struct AlertView<CommunityPostViewModel>: View where CommunityPostViewModel: CommunityPostViewModelType {
    private let fontColor = Color("Gray700")
    private let orangeColor = Color.init("main")
    private let lightGrayColor = Color.init("Gray600")
    private var commentId:Int? = nil
    @EnvironmentObject var appState:AppState
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State private var reportCompleteAlertIsShown = false
    @State private var isReportSuccessful = false
    @State private var reportReason = ""
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @ObservedObject var settingsViewModel: RenewalSettingsViewModel
    @ObservedObject var communityPostViewModel:CommunityPostViewModel
    var backButton: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Image("NavigationBack")
                .resizable()
                .frame(width: 7, height: 15)
                .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
        }
        .contentShape(Rectangle())
    }

    init(_ settingsViewModel: RenewalSettingsViewModel,_ communityPostViewModel:CommunityPostViewModel) {
        self.settingsViewModel = settingsViewModel
        self.communityPostViewModel = communityPostViewModel
    }
    init(_ settingsViewModel: RenewalSettingsViewModel,_ communityPostViewModel:CommunityPostViewModel,commentId:Int?) {
        self.settingsViewModel = settingsViewModel
        self.communityPostViewModel = communityPostViewModel
        self.commentId = commentId
        print("COMMENT: \(commentId)")
        if let commentId{
            if (commentId <= 0){
                self.commentId = nil
            }
        }
    }
    var body: some View {
        GeometryReader { geometry in
            VStack {
                VStack(spacing:0){
                    ZStack{
                        Color("MainThemeColor")
                            .ignoresSafeArea(.all)
                        HStack{
                            backButton
                            Spacer()
                        }.padding(.zero)
                        HStack{
                            Text("신고하기")
                                .foregroundColor(.white)
                                .frame(alignment: .center)
                                .font(.custom("Inter-Bold", size: 16))
                        }.padding(.zero)
                        
                    }.frame(height:44)
                    HStack {
                        Image("Comment-new")
                            .renderingMode(.original)
                            .resizable()
                            .frame(width: 17, height: 16)
                        
                        Text("어떤 이유로 신고하시나요?")
                            .font(.custom("NanumSquareOTFB", size: 20))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(EdgeInsets(top: 44, leading: 16, bottom: 20, trailing: 16))
                    
                    HStack {
                        Image("LogoEllipse")
                            .renderingMode(.original)
                            .resizable()
                            .frame(width: 24, height: 24)
                        
                        Text("ID \(settingsViewModel.userId)")
                            .font(.custom("NanumSquareOTFB", size: 12))
                        
                        Spacer()
                    }
                    .padding(EdgeInsets(top: 0, leading: 28, bottom: 8, trailing: 28))
                    
                    ZStack(alignment: .bottom) {
                        TextView(text: $reportReason, placeHolder: .constant(""), maxCount: 200)
                            .frame(height: 280)
                        
                        HStack {
                            Spacer()
                            Text("\(reportReason.count)자 / 200자")
                                .font(.custom("NanumSquareOTFL", size: 11))
                                .foregroundColor(fontColor)
                        }
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 8))
                    }
                    .padding([.leading, .trailing], 28)
                    
                    Spacer()
                    
                    Button(action: {
                        if(commentId == nil){
                            communityPostViewModel.reportPost(reason: reportReason ) { success, errorMessage in
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
                        else{
                            communityPostViewModel.reportComment(commentId:commentId!,reason: reportReason ) { success, errorMessage in
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
                    }, label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .foregroundColor(reportReason.count > 0 ? orangeColor : lightGrayColor)
                                
                                Text("전송하기")
                                    .font(.custom("NanumSquareOTFB", size: 17))
                                    .foregroundColor(.white)
                            }
                        })
                    .disabled(reportReason.count == 0)
                    .frame(height: 56)
                    .padding(16)
                }
                //        .edgesIgnoringSafeArea(.all)
                .background(Color.white.onTapGesture {
                    UIApplication.shared.endEditing()
                })
                .alert(isPresented: $reportCompleteAlertIsShown, content: {
                    Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")) {
                        if isReportSuccessful {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    })
                })
                
                .ignoresSafeArea(.keyboard)
                //        .navigationBarTitle("", displayMode: .inline)
                //        .navigationBarHidden(true)
                
            }
          
            
            
        }
        
    }
    
    
}
