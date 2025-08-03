//
//  SegmentedPicker.swift
//  Siksha
//
//  Created by 권현구 on 1/31/25.
//

import SwiftUI

struct SegmentedPicker<T: Hashable>: View {
    @Binding var selectedOption: T
    let options: [T]
    let format: (T) -> String
    let isRateFilter: Bool
    
    var body: some View {
        RoundedRectangle(cornerRadius: 30)
            .stroke(Color("Color/Foundation/Gray/200"))
            .frame(height: 34)
            .overlay(
                HStack(alignment: .center, spacing: 1) {
                    ForEach(options, id: \.self) { option in
                        ZStack {
                            if self.selectedOption == option {
                                RoundedRectangle(cornerRadius: 30)
                                    .fill(Color("Color/Foundation/Orange/100"))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 30)
                                            .stroke(Color("Color/Foundation/Orange/500"), lineWidth: 1)
                                    )
                            }
                            PickerContentView(text: format(option), needStarImage: isRateFilter && format(option) != "전체")
                                .frame(maxWidth: .infinity)
                                .frame(height: 34)
                                .contentShape(Rectangle())
                        }
                        .onTapGesture {
                            self.selectedOption = option
                        }
                    }
                }
            )
    }
}

struct PickerContentView: View {
    let text: String
    let needStarImage: Bool
    
    var body: some View {
        HStack {
            Text(text)
                .customFont(font: .text14(weight: .Bold))
            if needStarImage {
                Image("RateStar")
            }
        }
    }
}

struct CustomSegmentedPicker_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
    }
    
    struct PreviewWrapper: View {
        @State private var isOpen: Bool = true
        @State private var hasReview: Bool = true
        @State private var minimumRating: Float = 3.5
        
        var body: some View {
            VStack(spacing: 20) {
                SegmentedPicker(
                    selectedOption: $isOpen,
                    options: [false, true],
                    format: { $0 ? "영업 중" : "전체" },
                    isRateFilter: false
                )
                
                SegmentedPicker(
                    selectedOption: $hasReview,
                    options: [false, true],
                    format: { $0 ? "리뷰 있음" : "전체" },
                    isRateFilter: false
                )
                
                SegmentedPicker(
                    selectedOption: $minimumRating,
                    options: [0, 3.5, 4.0, 4.5],
                    format: { $0 == 0 ? "전체" : String(format: "%.1f", $0) },
                    isRateFilter: true
                )
            }
        }
    }
}
