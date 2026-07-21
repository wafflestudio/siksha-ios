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
    let type: KeywordRateType
    @ObservedObject var viewModel: MealReviewViewModel

    private var items: [String] {
        type.selectionTexts
    }

    var body: some View {
        KeywordFlowLayout(horizontalSpacing: 6, verticalSpacing: 6) {
            ForEach(items.indices, id: \.self) { index in
                KeywordCell(text: items[index], isSelected: viewModel.selectedKeywords[type] == items[index])
                    .onTapGesture {
                        viewModel.selectedKeywords[type] = items[index]
                    }
            }
        }
    }
}

struct KeywordFlowLayout: Layout {
    struct Arrangement {
        let size: CGSize
        let origins: [CGPoint]
    }

    let horizontalSpacing: CGFloat
    let verticalSpacing: CGFloat

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let availableWidth = proposal.width ?? .greatestFiniteMagnitude
        return arrangement(for: sizes, availableWidth: availableWidth).size
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let origins = arrangement(for: sizes, availableWidth: bounds.width).origins

        for (subview, origin) in zip(subviews, origins) {
            subview.place(
                at: CGPoint(x: bounds.minX + origin.x, y: bounds.minY + origin.y),
                proposal: .unspecified
            )
        }
    }

    func arrangement(for sizes: [CGSize], availableWidth: CGFloat) -> Arrangement {
        guard !sizes.isEmpty else {
            return Arrangement(
                size: CGSize(width: availableWidth.isFinite ? availableWidth : 0, height: 0), origins: [])
        }

        var origins: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var contentWidth: CGFloat = 0

        for size in sizes {
            if x > 0, x + size.width > availableWidth {
                x = 0
                y += rowHeight + verticalSpacing
                rowHeight = 0
            }

            origins.append(CGPoint(x: x, y: y))
            contentWidth = max(contentWidth, x + size.width)
            rowHeight = max(rowHeight, size.height)
            x += size.width + horizontalSpacing
        }

        return Arrangement(
            size: CGSize(
                width: availableWidth.isFinite ? availableWidth : contentWidth,
                height: y + rowHeight
            ),
            origins: origins
        )
    }
}
