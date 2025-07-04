//
//  HorizontalGraph.swift
//  Siksha
//
//  Created by You Been Lee on 2021/05/10.
//

import SwiftUI

struct HorizontalGraph: View {
    private var distribution = Array<CGFloat>(repeating: 0, count: 5)
    private var multiple: CGFloat = 1
//    var barGraph: BarGraph
    
    init(_ distribution: [CGFloat]) {
        if !distribution.isEmpty {
            self.distribution = distribution.reversed()
            
            let maxVal = distribution.max() ?? 0
            if maxVal != 0 {
                multiple = 100.0 / CGFloat(maxVal)
            }
            
        }
    }
    
    private let orangeColor = Color.init("Orange500")
    
    var body: some View {
                
        VStack(alignment: .leading, spacing: 5) {
            ForEach(Array(zip(distribution.indices, distribution)), id: \.0) { (index, value) in
                HStack {
                    Text("\(5-index)")
                        .font(.custom("NanumSquareOTF", size: 8))
                        .foregroundColor(.gray)
                        .bold()
                        .padding(.top, 2)
                    Image("GrayStar")
                        .frame(width: 8, height: 8)
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .frame(width: value*multiple*0.5, height: 5)
                        Capsule().frame(width: value*multiple, height: 5)
                    }
                    .foregroundColor(orangeColor)
                }
            }
        }
        
    }
        
}

struct HorizontalGraph_Previews: PreviewProvider {
    static var previews: some View {
        HorizontalGraph([200, 1, 1, 1, 1])
    }
}
