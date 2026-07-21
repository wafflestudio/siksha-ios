//
//  KeywordSelectionView.swift
//  Siksha
//
//  Created by Jihyeon on 10/19/25.
//

import SwiftUI

struct KeywordSelectionView: View {
    var type: KeywordRateType
    @ObservedObject var viewModel: MealReviewViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 3) {
                type.displayIcon
                    .resizable()
                    .frame(width: 16, height: 16)
                    .padding(3)
                Text(type.displayTitle)
                    .customFont(font: .text14(weight: .Bold))
                    .foregroundStyle(Color.blackColor)
            }

            KeywordCellContainerView(type: type, viewModel: viewModel)
        }
    }
}

struct KeywordCell: View {
    var text: String
    var isSelected: Bool = false

    var body: some View {
        Text(text)
            .customFont(font: .text13(weight: isSelected ? .Bold : .Regular))
            .foregroundStyle(isSelected ? Color.orange500 : Color.gray800)
            .padding(.vertical, 5)
            .padding(.horizontal, 11)
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.orange500 : Color.gray200, lineWidth: 1)
                    .fill(Color.whiteColor)
            }
    }
}

private struct KeywordCellContainerView: View {
    @State var totalHeight: CGFloat = .zero
    let verticalSpacing: CGFloat = 6
    let horizontalSpacing: CGFloat = 6

    let type: KeywordRateType
    @ObservedObject var viewModel: MealReviewViewModel

    private var items: [String] {
        type.selectionTexts
    }

    public var body: some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        GeometryReader { geo in
            ZStack(alignment: .topLeading) {
                ForEach(0..<5) { index in
                    KeywordCell(text: items[index], isSelected: viewModel.selectedKeywords[type] == items[index])
                        .onTapGesture { _ in
                            viewModel.selectedKeywords[type] = items[index]
                        }
                        .alignmentGuide(.leading) { view in
                            if abs(width - view.width) > geo.size.width {
                                width = 0
                                height -= view.height
                                height -= verticalSpacing
                            }
                            let result = width

                            if items[index] == items.last {
                                width = 0
                            } else {
                                width -= view.width
                                width -= horizontalSpacing
                            }

                            return result
                        }
                        .alignmentGuide(.top) { _ in
                            let result = height

                            if items[index] == items.last {
                                height = 0
                            }
                            return result
                        }
                }
            }
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                            self.totalHeight = geometry.size.height
                        }
                }
            )
        }
        .frame(height: totalHeight)
    }
}
