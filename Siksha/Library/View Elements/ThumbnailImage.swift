//
//  ClickableImage.swift
//  Siksha
//
//  Created by You Been Lee on 2021/05/31.
//

import SwiftUI

struct ThumbnailImage: View {
    private var url: String
    @State var showDetailImage: Bool = false
    
    init(_ url: String) {
        self.url = url
    }
    
    var body: some View {
        Button(action: {
            self.showDetailImage = true
        }) {
            RemoteImage(url: url)
                .frame(width: 120, height: 120)
                .cornerRadius(8)
                .clipped()
        }
        .sheet(isPresented: $showDetailImage) {
            DetailImageView(RemoteImage(url: url))
        }
    }
}

//struct ThumbanailImage_Previews: PreviewProvider {
//    static var previews: some View {
//        ClickableImage()
//    }
//}
