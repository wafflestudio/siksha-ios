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
        GeometryReader { geometry in
            VStack(alignment: .leading) {

                HStack {
                    BackButton(presentationMode)

                    Spacer()
                    
                    Text("식샤 정보")
                        .font(.custom("NanumSquareOTFB", size: 18))
                        .foregroundColor(.init(white: 79/255))
                    Spacer()
                    Text("")
                        .frame(width: 100)
                }
                .padding([.leading, .trailing], 16)
                .padding(.top, 26)
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
                                .font(.custom("NanumSquareOTFB", size: 15))
                                .foregroundColor(.init("DefaultFontColor"))
        
                            VStack (alignment: .leading) {
                                Text("이유빈")
                                    .font(.custom("NanumSquareOTFL", size: 15))
                                    .foregroundColor(.init("DefaultFontColor"))
                                Text("이유빈")
                                    .font(.custom("NanumSquareOTFL", size: 15))
                                    .foregroundColor(.init("DefaultFontColor"))
                                Text("이유빈")
                                    .font(.custom("NanumSquareOTFL", size: 15))
                                    .foregroundColor(.init("DefaultFontColor"))
                            }
                        }
                        .frame(width: UIScreen.main.bounds.size.width/2)
                        
                        Spacer()
                        
                        VStack(alignment: .center) {
                            Text("Design")
                                .padding(.bottom, 7)
                                .font(.custom("NanumSquareOTFB", size: 15))
                                .foregroundColor(.init("DefaultFontColor"))
        
                            VStack (alignment: .leading) {
                                Text("이유빈")
                                    .font(.custom("NanumSquareOTFL", size: 15))
                                    .foregroundColor(.init("DefaultFontColor"))
                                Text("이유빈")
                                    .font(.custom("NanumSquareOTFL", size: 15))
                                    .foregroundColor(.init("DefaultFontColor"))
                                Text("이유빈")
                                    .font(.custom("NanumSquareOTFL", size: 15))
                                    .foregroundColor(.init("DefaultFontColor"))
                            }
                        }
                        .frame(width: UIScreen.main.bounds.size.width/2)
                    }
                    // HStack
                }
                
                Spacer()
                    .frame(height: 75)

                    HStack {
                        Spacer()
                        Image("WaffleStudioLogo")
                            .resizable()
                            .frame(width: 127, height: 47)
                        Spacer()
                    }
                
                Spacer()
                
            }
            // VStack
            .contentShape(Rectangle())
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
            .navigationBarTitle("", displayMode: .inline)
        }
    }
}

struct InformationView_Previews: PreviewProvider {
    static var previews: some View {
        InformationView()
    }
}
