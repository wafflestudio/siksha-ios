//
//  AddImageView.swift
//  Siksha
//
//  Created by You Been Lee on 2021/05/23.
//

import SwiftUI

struct AddImageView: View {
    @State private var addedImages = [UIImage]()
    @State private var isShowingPhotoLibrary = false
    
    var bindingForImage: Binding<UIImage> {
        Binding<UIImage> { () -> UIImage in
            return addedImages.last ?? UIImage()
        } set: { (newImage) in
            addedImages.append(newImage)
            print("Images: \(addedImages.count)")
        }
    }
    
    var imageView: some View {
        HStack {
            ScrollView (.horizontal) {
                HStack {
                    ForEach(addedImages, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .renderingMode(.original)
                            .frame(width: 80, height: 80)
                            .cornerRadius(8)
                    }
                }
            }
            
            Spacer()
        }
        .padding([.leading, .trailing], 28)

    }
    
    var body: some View {
        
        VStack {
            
            imageView
            
            HStack {
                Button(action: {
                    self.isShowingPhotoLibrary = true
                }) {
                    ZStack {
                        Image("ReviewPictureButton")
                            .resizable()
                            .renderingMode(.original)
                            .frame(width: 134, height: 32)

                        Image("AddPicture")
                            .resizable()
                            .renderingMode(.original)
                            .frame(width: 84, height: 16)
                    }
                }
                .padding(.top, 16)
                .sheet(isPresented: $isShowingPhotoLibrary) {
                    ImagePicker(sourceType: .photoLibrary, selectedImage: bindingForImage)
                }
                
                Spacer()
            }
            .padding([.leading, .trailing], 28)
        }

    }
}

struct AddImageView_Previews: PreviewProvider {
    static var previews: some View {
        AddImageView()
    }
}
