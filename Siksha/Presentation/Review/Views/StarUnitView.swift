//
//  StarUnitView.swift
//  Siksha
//
//  Created by Jihyeon on 10/7/25.
//

import SwiftUI

/// 비율에 따라 색이 채워진 별 (0.0 ~ 1.0)
struct StarUnitView: View {
    private let fraction: Double // 0...1
    private let emptyColor: Color
    private let fillColor: Color
    private let starImage = Image("Star")

    init(fraction: Double, emptyColor: Color = .gray200, fillColor: Color = .orange500) {
        self.fraction = max(0, min(1, fraction))
        self.emptyColor = emptyColor
        self.fillColor = fillColor
    }

    var body: some View {
        ZStack(alignment: .leading) {
            star(with: emptyColor)

            star(with: fillColor)
                .mask(
                    GeometryReader { geo in
                        HStack(spacing: 0) {
                            Rectangle()
                                .frame(width: geo.size.width * fraction)
                            Spacer(minLength: 0)
                        }
                        .allowsHitTesting(false)
                    }
                )
        }
        .contentShape(Rectangle())
    }

    private func star(with color: Color) -> some View {
        starImage
            .resizable()
            .scaledToFit()
            .foregroundStyle(color)
    }
}

#Preview {
    StarUnitView(fraction: 1)
}
