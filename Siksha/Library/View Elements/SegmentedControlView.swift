//
//  SegmentedControlView.swift
//  Siksha
//
//  Created by You Been Lee on 2021/03/12.
//

import SwiftUI

struct Segment: Identifiable {
    var id: Int
    var name: String
}

struct SegmentedControlView: View {
    
    @Binding var selected: Int
    var segments: [Segment]
    
    var body: some View {
        HStack(alignment: .center, spacing: -1) {
            ForEach(segments) { segment in
                Button(action: {
                    self.selected = segment.id
                })
                {
                    VStack {
                        Text(segment.name)
                            .padding(.horizontal, 13)
                            .padding(.vertical, 4)
                            .font(.custom("NanumSquareOTFR", size: 12))
                    }
                }
                .foregroundColor(self.selected == segment.id ? .white : Color.init("MainThemeColor"))
                .background(self.selected == segment.id ? Color.init("MainThemeColor") : .white)
                .border(Color.init("MainThemeColor"))
            }
        }
        .overlay(RoundedRectangle(cornerRadius: 25)
                    .stroke(Color.init("MainThemeColor"), lineWidth: 1)
                    .padding(0.5))
        .cornerRadius(25.0)
        
    }
}

struct SegmentedControlView_Previews: PreviewProvider {
    static var previews: some View {
        SegmentedControlView(selected: .constant(0), segments: [Segment(id: 0, name: "주중"), Segment(id: 1, name: "주말"), Segment(id: 2, name: "방학")])
    }
}
