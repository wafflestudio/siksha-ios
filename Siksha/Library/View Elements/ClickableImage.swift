//
//  ClickableImage.swift
//  Siksha
//
//  Created by You Been Lee on 2021/05/31.
//

import SwiftUI

struct ClickableImage: View {
    
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
                .cornerRadius(8)
                .frame(width: 120, height: 120)
        }
        .sheet(isPresented: $showDetailImage) {
            DetailImageView(RemoteImage(url: url))
        }
    }
}

//struct ClickableImage_Previews: PreviewProvider {
//    static var previews: some View {
//        ClickableImage()
//    }
//}
