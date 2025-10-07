//
//  StarRateView.swift
//  Siksha
//
//  Created by Jihyeon on 10/7/25.
//

import SwiftUI

struct StarRateView: View {
    let rate: Double
    let spacing: CGFloat
    
    var body: some View {
        HStack(spacing: spacing) {
            ForEach(0..<5) { i in
                StarUnitView(fraction: rate - Double(i))
            }
        }
    }
}

#Preview {
    StarRateView(rate: 4.2, spacing: 1)
        .frame(height: 12)
}
