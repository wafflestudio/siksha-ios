//
//  NavigationBarModifier.swift
//  Siksha
//
//  Created by 박종석 on 2021/06/12.
//

import Foundation
import SwiftUI

struct NavigationBarModifier: ViewModifier {
    var title: String

    init(title: String) {
        self.title = title
    }

    func body(content: Content) -> some View {
        content
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    if title == "icon" {
                        Image(.Logos.sikshaSplash)
                            .resizable()
                            .frame(width: 39, height: 23)
                    } else {
                        Text(title)
                            .foregroundColor(.white)
                            .customFont(font: .text16(weight: .ExtraBold))
                    }
                }
            }
            .toolbarBackground(Color.backgroundGNB, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationViewStyle(StackNavigationViewStyle())
    }
}

private struct Preview: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Text("navigation")
                .modifier(NavigationBarModifier(title: "navigation"))
                .navigationBarItems(leading: backButton)
        }
    }

    var backButton: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Image("NavigationBack")
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .foregroundColor(.white)
        }
    }
}

#Preview {
    Preview()
}
