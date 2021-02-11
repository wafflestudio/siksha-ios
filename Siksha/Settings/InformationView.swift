//
//  InformationView.swift
//  Siksha
//
//  Created by You Been Lee on 2021/02/05.
//

import SwiftUI

struct InformationView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @GestureState private var dragOffset = CGSize.zero

    var body: some View {
        VStack(alignment: .leading) {
            
            Spacer()
                .frame(height: 20)
            
            // Navigation Bar
            HStack {
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image("Back")
                                .frame(width: 25, height: 25)
                            Text("설정")
                                .font(.custom("NanumSquareOTFB", size: 20))
                                .foregroundColor(.init("DefaultFontColor"))
                        }
                    }
                    .frame(width: 100)

                Spacer()
                
                Text("식샤 정보")
                    .font(.custom("NanumSquareOTFExtraBold", size: 30))
                    .foregroundColor(.init("DefaultFontColor"))
                Spacer()
                Text("")
                    .frame(width: 100)
            }
            //
            
            VStack(alignment: .leading) {
                
                Spacer()
                    .frame(height: 25)
                
                // Version Information
                VersionView()
                    .padding()
                
                Spacer()
                    .frame(height: 25)
                
                // Contributors
                HStack(alignment: .center) {
                    VStack (alignment: .center) {
                        Text("Development")
                            .padding(.bottom, 7)
                            .font(.custom("NanumSquareOTFBold", size: 15))
                            .foregroundColor(.init("DefaultFontColor"))
    
                        VStack (alignment: .leading) {
                            Text("이유빈")
                                .font(.custom("NanumSquareOTFLight", size: 15))
                                .foregroundColor(.init("DefaultFontColor"))
                            Text("이유빈")
                                .font(.custom("NanumSquareOTFLight", size: 15))
                                .foregroundColor(.init("DefaultFontColor"))
                            Text("이유빈")
                                .font(.custom("NanumSquareOTFLight", size: 15))
                                .foregroundColor(.init("DefaultFontColor"))
                        }
                    }
                    .frame(width: UIScreen.main.bounds.size.width/2)
                    
                    Spacer()
                    
                    VStack(alignment: .center) {
                        Text("Design")
                            .padding(.bottom, 7)
                            .font(.custom("NanumSquareOTFBold", size: 15))
                            .foregroundColor(.init("DefaultFontColor"))
    
                        VStack (alignment: .leading) {
                            Text("이유빈")
                                .font(.custom("NanumSquareOTFLight", size: 15))
                                .foregroundColor(.init("DefaultFontColor"))
                            Text("이유빈")
                                .font(.custom("NanumSquareOTFLight", size: 15))
                                .foregroundColor(.init("DefaultFontColor"))
                            Text("이유빈")
                                .font(.custom("NanumSquareOTFLight", size: 15))
                                .foregroundColor(.init("DefaultFontColor"))
                        }
                    }
                    .frame(width: UIScreen.main.bounds.size.width/2)
                }
                // HStack
            }
            
//
//                HStack {
//                    // WaffleStudio new logo
//                    Image("Logo")
//                        .resizable()
//                        .frame(width: 30, height: 30, alignment: .center)
//                }
            
            Spacer()
            
        }
        // VStack
        .contentShape(Rectangle())
        .gesture(DragGesture().updating($dragOffset, body: { (value, state, transaction) in
                
            if(value.startLocation.x < 20 && value.translation.width > 100) {
                    self.presentationMode.wrappedValue.dismiss()
                }
        }))
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitle("", displayMode: .inline)

    }
}

struct InformationView_Previews: PreviewProvider {
    static var previews: some View {
        InformationView()
    }
}
