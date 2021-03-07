//
//  RatingStar.swift
//  Siksha
//
//  Created by 박종석 on 2021/03/06.
//

import SwiftUI

struct RatingStar: View {
    @Binding var score: Double
    private var starSize: CGFloat
    
    init(_ score: Binding<Double>, size: CGFloat){
        self._score = score
        self.starSize = size
    }
    
    func starImage(_ index: Int) -> some View {
        let intScore = Int(score * 2)

        var image: String
        if index*2<intScore-1 {
            image = "RatingFilled"
        } else if index*2<intScore {
            image = "RatingHalf"
        } else {
            image = "RatingEmpty"
        }
        
        return Image(image).resizable().frame(width: starSize, height: starSize)
    }
    
    var body: some View {
        HStack {
            ForEach(0..<5) { index in
                starImage(index)
            }
        }
    }
}

struct RatingStar_Preview: PreviewProvider {
    static var previews: some View {
        RatingStar(.constant(3.5), size: 32)
    }
}
