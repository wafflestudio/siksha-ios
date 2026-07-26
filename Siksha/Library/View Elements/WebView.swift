//
//  WebView.swift
//  Siksha
//
//  Created by 이수민 on 11/12/24.
//

import SwiftUI
import WebKit

@MainActor
struct WebView: UIViewRepresentable {
    let urlString: String
    @Binding var showWebView: Bool
    var navigationDelegate: (any WKNavigationDelegate)?

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator.navigationDelegate ?? context.coordinator
        context.coordinator.loadURLIfNeeded(urlString, in: webView)
        return webView
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    @MainActor
    final class Coordinator: NSObject, WKNavigationDelegate {
        let navigationDelegate: (any WKNavigationDelegate)?
        private var loadedURLString: String?

        init(_ parent: WebView) {
            self.navigationDelegate = parent.navigationDelegate
        }

        func loadURLIfNeeded(_ urlString: String, in webView: WKWebView) {
            guard loadedURLString != urlString, let url = URL(string: urlString) else {
                return
            }
            loadedURLString = urlString
            webView.load(URLRequest(url: url))
        }
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        context.coordinator.loadURLIfNeeded(urlString, in: uiView)
    }
}

// 카카오 전용 웹뷰
@MainActor
struct KakaoShareWebView: View {
    let urlString: String
    @Binding var showWebView: Bool
    let restaurant: KakaoShareRestaurantModel
    let selectedDate: String
    let kakaoShareManager: any KakaoShareManaging

    var body: some View {
        WebView(
            urlString: urlString,
            showWebView: $showWebView,
            navigationDelegate: KakaoShareNavigationDelegate(
                showWebView: $showWebView,
                restaurant: restaurant,
                selectedDate: selectedDate,
                kakaoShareManager: kakaoShareManager
            )
        )
        .id(kakaoShareManager.webViewLoadRevision)
    }
}

@MainActor
final class KakaoShareNavigationDelegate: NSObject, WKNavigationDelegate {
    @Binding var showWebView: Bool
    let restaurant: KakaoShareRestaurantModel
    let selectedDate: String
    private let kakaoShareManager: any KakaoShareManaging

    init(
        showWebView: Binding<Bool>,
        restaurant: KakaoShareRestaurantModel,
        selectedDate: String,
        kakaoShareManager: any KakaoShareManaging = KakaoShareManager()
    ) {
        _showWebView = showWebView
        self.restaurant = restaurant
        self.selectedDate = selectedDate
        self.kakaoShareManager = kakaoShareManager
    }

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping @MainActor @Sendable (WKNavigationActionPolicy) -> Void
    ) {
        decisionHandler(decidePolicy(for: navigationAction.request.url))
    }

    func decidePolicy(for url: URL?) -> WKNavigationActionPolicy {
        if let url, kakaoShareManager.isKakaoTalkLoginURL(url) {
            handleKakaoAuth(url: url)
        }
        return .allow
    }

    private func handleKakaoAuth(url: URL) {
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let code = components.queryItems?.first(where: { $0.name == "code" })?.value
        {
            kakaoShareManager.exchangeToken(code: code) { [weak self] didSucceed in
                guard didSucceed else {
                    return
                }

                self?.handleSuccessfulAuth()
            }
        }
    }

    private func handleSuccessfulAuth() {
        showWebView = false
        kakaoShareManager.shareKakao(restaurant: restaurant, selectedDateString: selectedDate)
    }
}
