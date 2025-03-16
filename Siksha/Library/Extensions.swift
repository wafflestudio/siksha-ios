//
//  Extensions.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/01.
//

import Foundation
import SwiftUI
import Combine

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

struct MenuViewModelKey: EnvironmentKey {
    static var defaultValue: MenuViewModel? {
        return nil
    }
}

extension EnvironmentValues {
    var viewController: UIViewController? {
        get { return self[ViewControllerKey.self].value }
        set { self[ViewControllerKey.self].value = newValue }
    }
    
    var favoriteViewModel: FavoriteViewModel? {
        get { return self[FavoriteViewModelKey.self] }
        set { self[FavoriteViewModelKey.self] = newValue }
    }
    
    var menuViewModel: MenuViewModel? {
        get { return self[MenuViewModelKey.self] }
        set { self[MenuViewModelKey.self] = newValue }
    }
}

extension UIViewController {
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
    
    func customNavigationBar(title: String) -> some View {
        self.modifier(NavigationBarModifier(title: title))
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

protocol ImageCache {
    subscript(_ url: URL) -> UIImage? { get set }
}

struct TemporaryImageCache: ImageCache {
    private let cache = NSCache<NSURL, UIImage>()
    
    subscript(_ key: URL) -> UIImage? {
        get { cache.object(forKey: key as NSURL) }
        set { newValue == nil ? cache.removeObject(forKey: key as NSURL) : cache.setObject(newValue!, forKey: key as NSURL) }
    }
}

struct ImageCacheKey: EnvironmentKey {
    static let defaultValue: ImageCache = TemporaryImageCache()
}

extension EnvironmentValues {
    var imageCache: ImageCache {
        get { self[ImageCacheKey.self] }
        set { self[ImageCacheKey.self] = newValue }
    }
}

extension String {
    enum FinalConsonantState {
        case notKorean
        case noConsonant
        case hasConsonant
        case exceptionConsonant // ㄹ 종성 + '으로'인 경우
    }
    
    func inspectFinalConsonant() -> FinalConsonantState {
        let last = self.last
        
        if let lastUtf = last?.utf16.first, (lastUtf > 0xAC00 && lastUtf < 0xD7A3) {
            let lastConsonantIndex = (lastUtf.advanced(by: -0xAC00)) % 28
            
            if lastConsonantIndex > 0 {
                if lastConsonantIndex == 8 {
                    return .exceptionConsonant
                } else {
                    return .hasConsonant
                }
            }
            
            return .noConsonant
        }
        
        return .notKorean
    }
}

extension Date {
    func toLegibleString() -> String {
        let formatter = DateFormatter()
        
        formatter.locale = Locale(identifier: "ko_kr")
        formatter.dateFormat = "yyyy년 M월 d일"
        
        let diff = Date().timeIntervalSince(self)
        
        let def = formatter.string(from: self)
        
        let days = Int(diff/86400)
        let hours = Int(diff/3600)
        let minutes = Int(diff/60)
        
        if days < 0 {
            return def
        } else if days == 0 {
            if hours == 0 {
                if minutes == 0 {
                    return "방금 전"
                } else {
                    return "\(minutes)분 전"
                }
            } else {
                return "\(hours)시간 전"
            }
        } else if days == 1{
            return "어제"
        } else if days < 7 {
            return "\(days)일 전"
        } else {
            return def
        }
    }
}

extension UIImage {
    func resizeWithWidth(width: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
}
