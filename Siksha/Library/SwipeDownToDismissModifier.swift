//
//  SwipeDownToDismissModifier.swift
//  Siksha
//
//  Created by 권현구 on 1/18/26.
//

import SwiftUI

struct SwipeDownToDismissModifier: ViewModifier {
    @Environment(\.dismiss) private var dismiss
    @State private var dragOffset: CGFloat = 0

    let threshold: CGFloat

    init(threshold: CGFloat = 100) {
        self.threshold = threshold
    }

    func body(content: Content) -> some View {
        content
            .offset(y: dragOffset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if value.translation.height > 0 {
                            dragOffset = value.translation.height
                        }
                    }
                    .onEnded { value in
                        if value.translation.height > threshold {
                            dismiss()
                        } else {
                            withAnimation(.spring()) {
                                dragOffset = 0
                            }
                        }
                    }
            )
    }
}

extension View {
    func swipeDownToDismiss(threshold: CGFloat = 100) -> some View {
        modifier(SwipeDownToDismissModifier(threshold: threshold))
    }
}
