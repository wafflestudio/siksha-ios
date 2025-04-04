//
//  MeasureFrameModifier.swift
//  Siksha
//
//  Created by 이지현 on 4/5/25.
//

import SwiftUI

struct MeasureFrameModifier: ViewModifier {
    @Binding var frame: CGRect
    
    func body(content: Content) -> some View {
        content.background(
            GeometryReader { geometry in
                Color.clear
                    .onAppear {
                        frame = geometry.frame(in: .global)
                    }
                    .onChange(of: geometry.frame(in: .global)) { newValue in
                        frame = newValue
                    }
            }
        )
    }
}

extension View {
    func measureFrame(_ frame: Binding<CGRect>) -> some View {
        modifier(MeasureFrameModifier(frame: frame))
    }
    
    func measureHeight(_ height: Binding<CGFloat>) -> some View {
        measureFrame(Binding(
            get: { CGRect(x: 0, y: 0, width: 0, height: height.wrappedValue) },
            set: { height.wrappedValue = $0.height }
        ))
    }
    
    func measureWidth(_ width: Binding<CGFloat>) -> some View {
        measureFrame(Binding(
            get: { CGRect(x: 0, y: 0, width: width.wrappedValue, height: 0) },
            set: { width.wrappedValue = $0.width }
        ))
    }
}
