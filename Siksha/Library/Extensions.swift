//
//  Extensions.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/01.
//

import Foundation
import SwiftUI

struct ViewControllerHolder {
    weak var value: UIViewController?
}

struct ViewControllerKey: EnvironmentKey {
    static var defaultValue: ViewControllerHolder {
        return ViewControllerHolder(value: UIApplication.shared.windows.first?.rootViewController)
    }
}

struct FavoriteViewModelKey: EnvironmentKey {
    static var defaultValue: FavoriteViewModel? {
        return nil
    }
}

public extension EnvironmentValues {
    var viewController: UIViewController? {
        get { return self[ViewControllerKey.self].value }
        set { self[ViewControllerKey.self].value = newValue }
    }
    
    var favoriteViewModel: FavoriteViewModel? {
        get { return self[FavoriteViewModelKey.self] }
        set { self[FavoriteViewModelKey.self] = newValue }
    }
}

public extension UIViewController {
    func present<Content: View>(style: UIModalPresentationStyle = .automatic, @ViewBuilder builder: () -> Content) {
        let toPresent = UIHostingController(rootView: AnyView(EmptyView()))
        toPresent.modalPresentationStyle = style
        toPresent.rootView = AnyView(
            builder()
                .environment(\.viewController, toPresent)
        )
        self.present(toPresent, animated: true, completion: nil)
    }
}

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

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension URLRequest {
    mutating func setToken(token: String, type: String = "authorization") {
        self.setValue("Bearer " + token, forHTTPHeaderField: "\(type)-token")
    }
}
