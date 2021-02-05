//
//  Extensions.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/01.
//

import Foundation
import SwiftUI

extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}

extension View {
    func sheet<Content: View>(isPresented: Binding<Bool>, title: String = "", height: CGFloat, @ViewBuilder content: @escaping () -> Content) -> some View {
        self
            .blur(radius: isPresented.wrappedValue ? 5 : 0)
            .overlay(
                !isPresented.wrappedValue ? nil :
                    Color.init(white: 0, opacity: 0.3)
                        .edgesIgnoringSafeArea(.all)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .onTapGesture {
                            withAnimation {
                                isPresented.wrappedValue = false
                            }
                        }
            )
            .overlay(
                !isPresented.wrappedValue ? nil :
                    BottomModalView(isPresented: isPresented, title: title, height: height, content: content)
                        .transition(.move(edge: .bottom))
                        .animation(.easeInOut)
            )
    }
}
