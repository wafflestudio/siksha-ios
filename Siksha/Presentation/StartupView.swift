//
//  StartupView.swift
//  Siksha
//
//  Created by Codex on 7/12/26.
//

import SwiftUI

struct StartupView: View {
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
    }
}

struct StartupView_Previews: PreviewProvider {
    static var previews: some View {
        StartupView()
    }
}
