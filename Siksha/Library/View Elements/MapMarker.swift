//
//  MapMarker.swift
//  Siksha
//
//  Created by 박정헌 on 8/14/25.
//

import SwiftUI

struct MapMarker: View {
    @Environment(\.colorScheme) private var colorScheme

    let name: String
    var body: some View {
        ZStack {
            Image("mapMarker")
            Text(name)
                .customFont(font: .text14(weight: .Bold))
                .foregroundStyle(Color.gray900)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 12, trailing: 0))
        }.padding(.zero)
    }

}

#Preview {
    MapMarker(name: "학생회관")
}
