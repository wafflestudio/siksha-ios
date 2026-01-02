//
//  KeywordRateRow.swift
//  Siksha
//
//  Created by Jihyeon on 10/7/25.
//

import SwiftUI

struct KeywordRateRow: View {
    let summary: ReviewKeywordSummary
    
    @State private var barWidth: CGFloat = 0
    
    var body: some View {
        HStack(spacing: 0) {
            Image(summary.type.imageString)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .padding(.trailing, 6)
                .padding(.leading, 14)
            
            Text(summary.keyword.isEmpty ? summary.type.title : summary.keyword)
                .customFont(font: .text13(weight: .Bold))
                .foregroundStyle(summary.keyword.isEmpty ? Color.gray600 : Color.gray800)
            
            Spacer()
            
            Text("\(summary.count)")
                .customFont(font: .text14(weight: .ExtraBold))
                .foregroundStyle(Color.orange500)
                .padding(.trailing, 19)
        }
        .frame(height: 36)
        .frame(maxWidth: .infinity)
        .measureWidth($barWidth)
        .background {
            ZStack(alignment: .leading) {
                Color.gray100
                
                if summary.total > 0 {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.orangeTint)
                        .frame(width: barWidth * CGFloat(summary.count) / CGFloat(summary.total))
                }
            }
        }
        .cornerRadius(8)
    }
}
