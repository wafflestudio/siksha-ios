//
//  StarRateView.swift
//  Siksha
//
//  Created by Jihyeon on 10/7/25.
//

import SwiftUI

struct StarRateView: View {
    @Binding var rate: Double
    let spacing: CGFloat
    private let isEditable: Bool
    
    init(rate: Double, spacing: CGFloat) {
        self._rate = .constant(rate)
        self.spacing = spacing
        self.isEditable = false
    }
    
    init(rate: Binding<Double>, spacing: CGFloat) {
        self._rate = rate
        self.spacing = spacing
        self.isEditable = true
    }
    
    var body: some View {
        HStack(spacing: spacing) {
            ForEach(0..<5) { i in
                StarUnitView(fraction: rate - Double(i))
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
                                        let tapLocation = value.location.x
                                        let starWidth = geo.size.width / CGFloat(5)
                                        
                                        let newRating = Double(tapLocation / starWidth)
                                        let roundedRating = ceil(newRating)
                                        
                                        self.rate = max(0, min(Double(5), roundedRating))
                                    }
                            )
                    }
                }
            }
        )
    }
}

// 돈육고추장찌개 리뷰 하나있는데 이미지만 있어서인지 안보임 다시 확인

private struct Preview: View {
    @State var score: Double = 0
    
    var body: some View {
        StarRateView(rate: $score, spacing: 5)
            .frame(height: 50)
    }
}


#Preview {
    Preview()
}
