//
//  InformationView.swift
//  Siksha
//
//  Created by You Been Lee on 2021/02/05.
//
import SwiftUI
import Combine

private extension InformationView {
    var versionView: some View {
        ZStack {
            VStack {
                Image("LogoEllipse")
                    .resizable()
                    .frame(width: 100, height: 100)
                Text(viewModel.isUpdateAvailable ? "업데이트가 가능합니다" : "최신버전을 이용중입니다.")
                    .font(.custom("NanumSquareOTFB", size: 15))
                    .foregroundColor(fontColor)
                    .padding(.top, 20)
                Text("siksha-\(viewModel.version)")
                    .font(.custom("NanumSquareOTFB", size: 15))
                    .foregroundColor(fontColor)
            }
        }
    }
}

struct InformationView: View {
    private let backgroundColor = Color.init("AppBackgroundColor")
    private let fontColor = Color.init(white: 185/255)
    
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    
    @State var showRemoveAccountAlert: Bool = false
    @State var removeAccountFailed: Bool = false
    @State private var cancellable: AnyCancellable? = nil
    
    @ObservedObject var viewModel: SettingsViewModel
    
    init(_ viewModel: SettingsViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading) {
                NavigationBar(title: "식샤 정보", showBack: true, geometry)
                
                versionView
                    .padding(.vertical, 50)
                    .frame(maxWidth: .infinity)
                
                HStack {
                    Spacer()
                    Button(action: {
                        self.showRemoveAccountAlert = true
                    }, label: {
                        Text("회원 탈퇴")
                            .foregroundColor(.red)
                            .font(.custom("NanumSquareOTFR", size: 16))
                    })
                    Spacer()
                }
                .padding(.top, 20)
                
                Spacer()
                
                HStack {
                    Spacer()
                    Image("WaffleStudioLogo")
                        .resizable()
                        .frame(width: 127, height: 47)
                    Spacer()
                }
                .padding(.bottom, 40)
            }
            // VStack
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
            .navigationBarTitle("", displayMode: .inline)
            .background(backgroundColor)
            .actionSheet(isPresented: $showRemoveAccountAlert, content: {
                ActionSheet(title: Text("회원 탈퇴"),
                            message: Text("앱 계정을 삭제합니다.\n이 계정으로 등록된 리뷰 정보들도 모두 함께 삭제됩니다."),
                            buttons: [
                                .destructive(Text("회원 탈퇴"), action: {
                                    self.removeAccount()
                                }),
                                .cancel(Text("취소"))
                            ]
                )
            })
            .alert(isPresented: $removeAccountFailed, content: {
                Alert(title: Text("회원 탈퇴"), message: Text("회원 탈퇴에 실패했습니다."), dismissButton: .default(Text("확인")))
            })
        }
    }
    
    func removeAccount() {
        guard let accessToken = UserDefaults.standard.string(forKey: "accessToken") else {
            removeAccountFailed = true
            return
        }
        
        let url = Config.shared.baseURL + "/auth/"
        
        if var request = try? URLRequest(url: url, method: .delete){
            request.setToken(token: accessToken)
            
            self.cancellable = URLSession.shared.dataTaskPublisher(for: request)
                .receive(on: RunLoop.main)
                .sink { _ in }
                    receiveValue: { (data, response) in
                        guard let response = response as? HTTPURLResponse,
                              200..<300 ~= response.statusCode else {
                            removeAccountFailed = true
                            return
                        }
                        
                        UserDefaults.standard.set(nil, forKey: "accessToken")
                        
                        viewControllerHolder?.present(style: .fullScreen) {
                            LoginView()
                        }
                    }
        }
    }
}

struct InformationView_Previews: PreviewProvider {
    static var previews: some View {
        InformationView(SettingsViewModel())
    }
}
