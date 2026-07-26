//
//  Extensions.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/01.
//

import Combine
import Foundation
import SwiftUI

struct ViewControllerHolder {
    weak var value: UIViewController?
}

struct ViewControllerKey: EnvironmentKey {
    static var defaultValue: ViewControllerHolder {
        ViewControllerHolder(value: nil)
    }
}

struct MenuViewModelKey: EnvironmentKey {
    static var defaultValue: MenuViewModel? {
        return nil
    }
}

struct SafeAreaInsetsKey: EnvironmentKey {
    static let defaultValue: EdgeInsets = .init()
}

extension EnvironmentValues {
    var viewController: UIViewController? {
        get { return self[ViewControllerKey.self].value }
        set { self[ViewControllerKey.self].value = newValue }
    }

    var menuViewModel: MenuViewModel? {
        get { return self[MenuViewModelKey.self] }
        set { self[MenuViewModelKey.self] = newValue }
    }

    var safeAreaInsets: EdgeInsets {
        get { self[SafeAreaInsetsKey.self] }
        set { self[SafeAreaInsetsKey.self] = newValue }
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

extension View {
    func sheet<Content: View>(
        isPresented: Binding<Bool>, title: String = "", height: CGFloat, @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self
            .blur(radius: isPresented.wrappedValue ? 5 : 0)
            .overlay(
                !isPresented.wrappedValue
                    ? nil
                    : Color.init(white: 0, opacity: 0.3)
                        .edgesIgnoringSafeArea(.all)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .onTapGesture {
                            withAnimation {
                                isPresented.wrappedValue = false
                            }
                        }
            )
            .overlay(
                !isPresented.wrappedValue
                    ? nil
                    : BottomModalView(isPresented: isPresented, title: title, height: height, content: content)
                        .transition(.move(edge: .bottom))
                        .animation(.easeInOut, value: isPresented.wrappedValue)
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
    mutating func setToken(token: String, type: String = "Authorization") {
        self.setValue("Bearer " + token, forHTTPHeaderField: type)
    }
}

@MainActor
protocol ImageCache: AnyObject {
    subscript(_ url: URL) -> UIImage? { get set }
}

@MainActor
final class TemporaryImageCache: ImageCache {
    private let cache = NSCache<NSURL, UIImage>()

    subscript(_ key: URL) -> UIImage? {
        get { cache.object(forKey: key as NSURL) }
        set {
            newValue == nil
                ? cache.removeObject(forKey: key as NSURL) : cache.setObject(newValue!, forKey: key as NSURL)
        }
    }
}

struct ImageCacheKey: EnvironmentKey {
    static var defaultValue: ImageCache? { nil }
}

extension EnvironmentValues {
    var imageCache: ImageCache? {
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

        if let lastUtf = last?.utf16.first, lastUtf > 0xAC00 && lastUtf < 0xD7A3 {
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

        let days = Int(diff / 86400)
        let hours = Int(diff / 3600)
        let minutes = Int(diff / 60)

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
        } else if days == 1 {
            return "어제"
        } else if days < 7 {
            return "\(days)일 전"
        } else {
            return def
        }
    }
}

extension UIImage {
    func resizedToFit(maxPixelDimension: CGFloat) -> UIImage? {
        guard maxPixelDimension > 0, size.width > 0, size.height > 0 else {
            return nil
        }

        let pixelSize = CGSize(width: size.width * scale, height: size.height * scale)
        let longestDimension = max(pixelSize.width, pixelSize.height)
        guard longestDimension > maxPixelDimension else {
            return self
        }

        let ratio = maxPixelDimension / longestDimension
        let targetSize = CGSize(
            width: max(1, floor(pixelSize.width * ratio)),
            height: max(1, floor(pixelSize.height * ratio))
        )
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        format.opaque = false

        return UIGraphicsImageRenderer(size: targetSize, format: format).image { _ in
            draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}
