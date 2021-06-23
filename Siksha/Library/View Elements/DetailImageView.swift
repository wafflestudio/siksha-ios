//
//  ZoomedImage.swift
//  Siksha
//
//  Created by You Been Lee on 2021/05/31.
//

import SwiftUI

struct DetailImageView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    private var image: RemoteImage
    
    init(_ image: RemoteImage) {
        self.image = image
    }
    
    var body: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            
            VStack {
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image("XButton")
                            .resizable()
                            .frame(width: 25, height:25)
                            .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 0))
                    }
                    
                    Spacer()
                    
                }
                
                Spacer()
                
                image
                    .aspectRatio(contentMode: .fit)

                Spacer()
                
            }
        }
    }
}

//struct DetailImageView_Previews: PreviewProvider {
//    static var previews: some View {
//        let image = Image("Logo")
//        DetailImageView(image)
//    }
//}
