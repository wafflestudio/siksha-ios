//
//  BottomModalView.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/05.
//

import SwiftUI

struct BottomModalView<Content: View>: View {
    @Binding var isPresented: Bool
    @GestureState private var translation: CGFloat = 0
    let height: CGFloat
    let content: Content
    let title: String
    
    init(isPresented: Binding<Bool>, title: String, height: CGFloat, @ViewBuilder content: @escaping () -> Content) {
        self.height = height
        self.title = title
        self.content = content()
        self._isPresented = isPresented
    }
    
    var body: some View {
        GeometryReader { geometry in
            content
                .background(Color(.systemBackground))
                .edgesIgnoringSafeArea(.bottom)
                .position(x: geometry.size.width/2, y: geometry.size.height*3/2 - height + geometry.safeAreaInsets.bottom/2)
                .offset(y: max(self.translation, -5))
                .simultaneousGesture(
                    DragGesture().updating($translation) { (value, state, transaction) in
                        transaction.disablesAnimations = true
                        transaction.animation = .interactiveSpring()
                        if abs(value.predictedEndTranslation.height) < 50 {
                            return
                        }
                        state = value.translation.height
                    }
                    .onEnded { value in
                        let snapDistance = self.height * 0.5
                        guard value.translation.height > 0, value.predictedEndTranslation.height > snapDistance else {
                            return
                        }
                        withAnimation {
                            self.isPresented = value.translation.height < 0
                        }
                    }
                )
        }
    }
}
