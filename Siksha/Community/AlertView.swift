import SwiftUI


struct AlertView<CommunityPostViewModel>: View where CommunityPostViewModel: CommunityPostViewModelType {
    private let fontColor = Color("DefaultFontColor")
    private let orangeColor = Color.init("main")
    private let lightGrayColor = Color.init("LightGrayColor")
    @EnvironmentObject var appState:AppState
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State private var reportCompleteAlertIsShown = false
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
        }
    }
    init(_ settingsViewModel: RenewalSettingsViewModel,_ communityPostViewModel:CommunityPostViewModel) {
        self.settingsViewModel = settingsViewModel
        self.communityPostViewModel = communityPostViewModel
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
                        TextView(text: $reportReason, placeHolder: .constant(""))
                            .frame(height: 280)
                        
                        HStack {
                            Spacer()
                            Text("\(reportReason.count)자 / 500자")
                                .font(.custom("NanumSquareOTFL", size: 11))
                                .foregroundColor(fontColor)
                        }
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 8))
                    }
                    .padding([.leading, .trailing], 28)
                    
                    Spacer()
                    
                    Button(action: {
                        communityPostViewModel.reportPost(reason: reportReason ) { success, errorMessage in
                            if success {
                                alertTitle = "신고"
                                alertMessage = "신고되었습니다."
                            } else {
                                alertTitle = "신고"
                                alertMessage = errorMessage ?? "신고에 실패했습니다."
                            }
                            reportCompleteAlertIsShown = true
                        }}, label: {
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
                    Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                })
                
                .ignoresSafeArea(.keyboard)
                //        .navigationBarTitle("", displayMode: .inline)
                //        .navigationBarHidden(true)
                
            }
            .onAppear{
                appState.showTabbar = false
            }
            
            
        }
        
    }
    
    
}
