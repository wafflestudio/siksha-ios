//
//  WebView.swift
//  Siksha
//
//  Created by 이수민 on 11/12/24.
//

import SwiftUI
@preconcurrency import WebKit
import KakaoSDKAuth

struct WebView: UIViewRepresentable {
    let urlString: String
    @Binding var showWebView: Bool
    var navigationDelegate: WKNavigationDelegate?
    
    func makeUIView(context: Context) -> WKWebView {
        guard let url = URL(string: urlString) else {
            return WKWebView()
        }
        
        let webView = WKWebView()
        webView.navigationDelegate = navigationDelegate ?? context.coordinator
        let request = URLRequest(url: url)
        webView.load(request)
        return webView
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

// 카카오 전용 웹뷰
struct KakaoShareWebView: View {
    let urlString: String
    @Binding var showWebView: Bool
    let restaurant: Restaurant
    let selectedDate: String
    
    var body: some View {
        WebView(
            urlString: urlString,
            showWebView: $showWebView,
            navigationDelegate: KakaoShareNavigationDelegate(
                showWebView: $showWebView,
                restaurant: restaurant,
                selectedDate: selectedDate
            )
        )
    }
}


class KakaoShareNavigationDelegate: NSObject, WKNavigationDelegate {
    @Binding var showWebView: Bool
    let restaurant: Restaurant
    let selectedDate: String
    let kakaoShareManager = KakaoShareManager()
    
    init(showWebView: Binding<Bool>, restaurant: Restaurant, selectedDate: String) {
        _showWebView = showWebView
        self.restaurant = restaurant
        self.selectedDate = selectedDate
    }
    
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
            if (AuthApi.isKakaoTalkLoginUrl(url)) {
                handleKakaoAuth(url: url)
            }
        }
        decisionHandler(.allow)
    }
    
    private func handleKakaoAuth(url: URL) {
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let code = components.queryItems?.first(where: { $0.name == "code" })?.value {
            
            AuthApi.shared.token(code: code) { [weak self] (oauthToken, error) in
                if let error = error {
                    print("Token error: \(error)")
                } else {
                    self?.handleSuccessfulAuth()
                }
            }
        }
    }
    
    private func handleSuccessfulAuth() {
        kakaoShareManager.shareKakao(restaurant: restaurant, selectedDateString: selectedDate)
        DispatchQueue.main.async { [weak self] in
            self?.showWebView = false
        }
    }
}
