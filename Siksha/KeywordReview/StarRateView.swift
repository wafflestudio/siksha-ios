//
//  StarRateView.swift
//  Siksha
//
//  Created by Jihyeon on 10/7/25.
//

import SwiftUI

struct StarRateView: View {
    private let displayRate: Double?
    @Binding private var editableRate: Int?
    
    let spacing: CGFloat
    private let isEditable: Bool
    
    init(rate: Double, spacing: CGFloat) {
        self.displayRate = rate
        self._editableRate = .constant(nil)
        self.spacing = spacing
        self.isEditable = false
    }
    
    init(rate: Binding<Int>, spacing: CGFloat) {
        // 내부에서는 옵셔널 바인딩으로 보관
        self._editableRate = Binding<Int?>(
            get: { rate.wrappedValue },
            set: { newValue in
                if let v = newValue { rate.wrappedValue = v }
            }
        )
        self.displayRate = nil
        self.spacing = spacing
        self.isEditable = true
    }
    
    var body: some View {
        HStack(spacing: spacing) {
            ForEach(0..<5, id: \.self) { i in
                if let displayRate {
                    let fraction = max(0, min(1, displayRate - Double(i)))
                    StarUnitView(fraction: fraction)
                } else if let editableRate {
                    let fraction = editableRate > i ? 1.0 : 0.0
                    StarUnitView(fraction: fraction)
                } else {
                    StarUnitView(fraction: 0.0)
                }
            }
        }
        .overlay(
            Group {
                if isEditable {
                    GeometryReader { geo in
                        Color.clear
                            .contentShape(Rectangle())
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        let tapX = value.location.x
                                        let starWidth = geo.size.width / CGFloat(5)
                                        let raw = Double(tapX / starWidth)
                                        let newRating = Int(ceil(raw))
                                        let clamped = max(0, min(5, newRating))
                                        self.editableRate = clamped
                                    }
                            )
                    }
                }
            }
        )
    }
}

private struct Preview: View {
    @State var score: Int = 0
    
    var body: some View {
        StarRateView(rate: $score, spacing: 5)
            .frame(height: 50)
    }
}

#Preview {
    Preview()
}
