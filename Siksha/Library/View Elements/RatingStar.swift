//
//  RatingStar.swift
//  Siksha
//
//  Created by 박종석 on 2021/03/06.
//

import SwiftUI

enum EmptyStarType {
    case empty
    case filled
}

struct RatingStar: View {
    @Binding var score: Double
    private var starSize: CGFloat
    private var spacing: CGFloat
    private var emptyStarType: EmptyStarType
    
    init(_ score: Binding<Double>, size: CGFloat, spacing: CGFloat = 8, emptyStarType: EmptyStarType = .empty){
        self._score = score
        self.starSize = size
        self.spacing = spacing
        self.emptyStarType = emptyStarType
    }
    
    func starImage(_ index: Int) -> some View {
        let intScore = Int(score * 2)

        var image: String
        
        if index * 2 < intScore - 1 {
            image = "RatingFilled"
        } else if index * 2 < intScore {
            image = "RatingHalf"
        } else {
            image = emptyStarType == .empty ? "RatingEmpty" :"RatingEmptyFilled"
        }
        
        return Image(image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: starSize * 13/12, height: starSize)
    }
    
    var body: some View {
        HStack(spacing: spacing) {
            ForEach(0..<5) { index in
                starImage(index)
            }
        }
    }
}

struct RatingStar_Preview: PreviewProvider {
    static var previews: some View {
        RatingStar(.constant(3.5), size: 32, spacing: 5)
    }
}
