//
//  StartupView.swift
//  Siksha
//
//  Created by Codex on 7/12/26.
//

import SwiftUI

struct StartupView: View {
    @Environment(\.openURL) private var openURL
    @State private var isUpdateAlertPresented = false

    private let isUpdateRequired: Bool

    init(isUpdateRequired: Bool = false) {
        self.isUpdateRequired = isUpdateRequired
    }

    var body: some View {
        ZStack {
            Color.orange500

            Image(.Logos.sikshaSplash)
                .resizable()
                .scaledToFit()
                .frame(width: 85.5, height: 49.5)

            VStack {
                Spacer()

                Image(.Logos.wafflestudioTextLogo)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 191, height: 16)
                    .padding(.bottom, 90)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            isUpdateAlertPresented = isUpdateRequired
        }
        .onChange(of: isUpdateRequired) { _, required in
            isUpdateAlertPresented = required
        }
        .onChange(of: isUpdateAlertPresented) { _, presented in
            if !presented, isUpdateRequired {
                isUpdateAlertPresented = true
            }
        }
        .alert("업데이트가 필요합니다.", isPresented: $isUpdateAlertPresented) {
            Button("업데이트") {
                guard let url = URL(string: "https://apps.apple.com/app/id1032700617") else { return }
                openURL(url)
            }
        } message: {
            Text("원활한 서비스 이용을 위해 최신 버전으로 업데이트해주세요.")
        }
    }
}

struct StartupView_Previews: PreviewProvider {
    static var previews: some View {
        StartupView()
    }
}
