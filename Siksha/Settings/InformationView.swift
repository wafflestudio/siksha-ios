//
//  InformationView.swift
//  Siksha
//
//  Created by You Been Lee on 2021/02/05.
//
import SwiftUI
import Combine

struct InformationView: View {
    private let backgroundColor = Color.init("AppBackgroundColor")
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @GestureState private var dragOffset = CGSize.zero
    @State var showRemoveAccountAlert: Bool = false
    @State var removeAccountFailed: Bool = false
    @State private var cancellable: AnyCancellable? = nil

    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading) {

                HStack {
                    BackButton(presentationMode)

                    Spacer()
                    
                    Text("식샤 정보")
                        .font(.custom("NanumSquareOTFB", size: 18))
                        .foregroundColor(.init(white: 79/255))
                    Spacer()
                    Text("")
                        .frame(width: 100)
                }
                .padding([.leading, .trailing], 16)
                .padding(.top, 26)
                
                VersionView()
                    .padding(.vertical, 50)
                    .frame(maxWidth: .infinity)
                
                Spacer()
                
                HStack {
                    Spacer()
                    Button(action: {
                        self.showRemoveAccountAlert = true
                    }, label: {
                        Text("식샤 회원 탈퇴")
                            .foregroundColor(.red)
                            .font(.custom("NanumSquareOTFR", size: 16))
                    })
                    Spacer()
                }
                .padding(.bottom, 20)
                
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
        InformationView()
    }
}
