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
            .background {
                InteractivePopGestureBridge()
                    .frame(width: 0, height: 0)
            }
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
        BackButton {
            self.presentationMode.wrappedValue.dismiss()
        }
    }
}

#Preview {
    Preview()
}
