//
//  HorizontalGraph.swift
//  Siksha
//
//  Created by You Been Lee on 2021/05/10.
//

import SwiftUI

struct HorizontalGraph: View {
    
    @State var five : CGFloat = 0
    @State var four : CGFloat = 0
    @State var three : CGFloat = 0
    @State var two : CGFloat = 0
    @State var one : CGFloat = 0
//    var barGraph: BarGraph
    
    private let orangeColor = Color.init("MainThemeColor")

    
    var body: some View {
                
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("5")
                    .font(.custom("NanumSquareOTF", size: 8))
                    .foregroundColor(.gray)
                    .bold()
                Image("GrayStar")
                    .frame(width: 8, height: 8)
                Capsule().frame(width: five, height: 5)
                    .foregroundColor(orangeColor)
            }
            HStack {
                Text("4")
                    .font(.custom("NanumSquareOTF", size: 8))
                    .foregroundColor(.gray)
                    .bold()
                Image("GrayStar")
                    .frame(width: 8, height: 8)
                Capsule().frame(width: four, height: 5)
                    .foregroundColor(orangeColor)
            }
            HStack {
                Text("3")
                    .font(.custom("NanumSquareOTF", size: 8))
                    .foregroundColor(.gray)
                    .bold()
                Image("GrayStar")
                    .frame(width: 8, height: 8)
                Capsule().frame(width: three, height: 5)
                    .foregroundColor(orangeColor)
            }
            HStack {
                Text("2")
                    .font(.custom("NanumSquareOTF", size: 8))
                    .foregroundColor(.gray)
                    .bold()
                Image("GrayStar")
                    .frame(width: 8, height: 8)
                Capsule().frame(width: two, height: 5)
                    .foregroundColor(orangeColor)
            }
            HStack {
                Text("1")
                    .font(.custom("NanumSquareOTF", size: 8))
                    .foregroundColor(.gray)
                    .bold()
                Image("GrayStar")
                    .frame(width: 8, height: 8)
                Capsule().frame(width: one, height: 5)
                    .foregroundColor(orangeColor)
            }
            
        }
        
    }
        
}

struct HorizontalGraph_Previews: PreviewProvider {
    static var previews: some View {
        HorizontalGraph(five: 20, four: 30, three: 20, two: 100, one: 10)
    }
}
