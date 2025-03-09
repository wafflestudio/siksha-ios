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
            .stroke(Color("Grey2"))
            .foregroundStyle(.clear)
            .frame(height: 34)
            .overlay(
                HStack(alignment: .center, spacing: 1) {
                    ForEach(options, id: \.self) { option in
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(self.selectedOption == option ? Color("SelectedBorder") : .clear)
                            .background(self.selectedOption == option ? Color("SelectedBackground") : .clear, in: RoundedRectangle(cornerRadius: 30))
                            .overlay(
                                PickerContentView(text: format(option), needStarImage: isRateFilter && format(option) != "모두" ? true : false)

                            )
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
                .font(.custom("NanumSquareOTFB", size: 14))
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
                    format: { $0 == 0 ? "모두" : String(format: "%.1f", $0) },
                    isRateFilter: true
                )
            }
        }
    }
}
