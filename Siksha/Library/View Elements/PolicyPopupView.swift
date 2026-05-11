//
//  PolicyPopupView.swift
//  Siksha
//

import SwiftUI

/// A reusable center-screen policy popup with a dimmed backdrop.
/// `title`, `message`, and `onClose` are all injectable, so this component
/// can be repurposed anywhere in the app without modification.
struct PolicyPopupView: View {
    let title: String
    let message: String
    let onClose: () -> Void

    /// Drives the spring-in appear animation; set to true inside `onAppear`.
    @State private var isAppeared = false

    var body: some View {
        ZStack {
            // Full-screen dimming layer – absorbs taps so the user must use ✕
            Color.black
                .opacity(0.45)
                .ignoresSafeArea()

            cardView
                // Scale + fade spring animation on first appearance
                .scaleEffect(isAppeared ? 1 : 0.88)
                .opacity(isAppeared ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
                isAppeared = true
            }
        }
    }
}

// MARK: - Subviews

private extension PolicyPopupView {
    var cardView: some View {
        VStack(spacing: 0) {
            closeButtonRow
            Spacer().frame(height: 4)
            iconView
            Spacer().frame(height: 14)
            titleView
            Spacer().frame(height: 10)
            messageView
            Spacer().frame(height: 28)
        }
        .padding(.horizontal, 20)
        .background(Color.backgroundSecondary)
        .cornerRadius(16)
        .padding(.horizontal, 40)
    }

    var closeButtonRow: some View {
        HStack {
            Spacer()
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 12, height: 12)
                    .foregroundColor(.gray700)
                    .padding(12)
            }
        }
    }

    var iconView: some View {
        Image(systemName: "info.circle.fill")
            .resizable()
            .scaledToFit()
            .frame(width: 34, height: 34)
            .foregroundColor(.orange500)
    }

    var titleView: some View {
        Text(title)
            .customFont(font: .text16(weight: .ExtraBold))
            .foregroundColor(.blackColor)
            .multilineTextAlignment(.center)
    }

    var messageView: some View {
        Text(message)
            .customFont(font: .text13(weight: .Regular))
            .foregroundColor(.gray700)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
    }
}

// MARK: - Preview

#Preview {
    PolicyPopupView(
        title: "앱스토어 정책 안내",
        message: "iOS에서는 앱스토어 정책에 의해\n익명 게시글과 댓글의 작성 및 열람이 불가합니다.",
        onClose: {}
    )
}
