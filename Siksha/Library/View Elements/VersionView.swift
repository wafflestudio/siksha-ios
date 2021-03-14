//
//  VersionView.swift
//  Siksha
//
//  Created by You Been Lee on 2021/02/05.
//
import SwiftUI

struct VersionView: View {
    private let fontColor = Color.init("DefaultFontColor")
    @State var version: String = ""
    @State var appStoreVersion: String = ""
    
    func getVersion() {
        guard let dictionary = Bundle.main.infoDictionary,
            let version = dictionary["CFBundleShortVersionString"] as? String else {
            return
        }
        self.version = version
    }
    
    func getAppStoreVersion() {
        guard let url = URL(string: "http://itunes.apple.com/lookup?id=1032700617"),
            let data = try? Data(contentsOf: url),
            let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
            let results = json["results"] as? [[String: Any]],
            results.count > 0,
            let appStoreVersion = results[0]["version"] as? String
            else { return }
        self.appStoreVersion = appStoreVersion
    }
    
    var isUpdateAvailable: Bool {
        if self.version == self.appStoreVersion && self.version != "" {
            return false
        } else {
            return true
        }
    }
    
    var body: some View {
        ZStack {
            VStack {
                Image("LogoEllipse")
                    .resizable()
                    .frame(width: 100, height: 100)
                Text(self.isUpdateAvailable ? "업데이트가 가능합니다" : "최신 버전을 이용 중입니다.")
                    .font(.custom("NanumSquareOTFB", size: 15))
                    .foregroundColor(fontColor)
                    .padding(.top, 20)
                Text("식샤 버전: \(self.version)")
                    .font(.custom("NanumSquareOTFB", size: 15))
                    .foregroundColor(fontColor)
            }
        }
        .onAppear {
            self.getVersion()
            self.getAppStoreVersion()
        }
    }
}

struct VersionView_Previews: PreviewProvider {
    static var previews: some View {
        VersionView()
    }
}
