//
//  MenuOrderView.swift
//  Siksha
//
//  Created by You Been Lee on 2021/02/09.
//

import SwiftUI

struct MenuOrderView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @GestureState private var dragOffset = CGSize.zero
    
    @State private var dummy = ["학생회관 식당", "농생대 3식당", "302동식당"]
    @State private var isEditable = true
    
    var body: some View {
        GeometryReader { geometry in
            
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
                                    .frame(width: 20, height: 20)
                                Text("설정")
                                    .font(.custom("NanumSquareOTFB", size: 14))
                                    .foregroundColor(.init("DefaultFontColor"))
                            }
                        }
                        .frame(width: 100)

                    Spacer()
                    
                    Text("식단 순서 변경")
                        .font(.custom("NanumSquareOTFExtraBold", size: 17))
                        .foregroundColor(.init("DefaultFontColor"))
                    Spacer()
                    Text("")
                        .frame(width: 100)
                }
                //
                
                Spacer()
                    .frame(height: 50)
                
                // Description
                HStack {
                    Spacer()
                    Text("우측 손잡이를 드래그하여 순서를 바꿔보세요.")
                        .font(.custom("NanumSquareOTFExtraBold", size: 14))
                        .foregroundColor(.init("DefaultFontColor"))
                    Spacer()
                }
                
                List() {
                    ForEach(dummy, id: \.self) { row in
                        MenuRow(text: row)
                    }
                    .onMove(perform: move)
                    .onLongPressGesture {
                        withAnimation {
                            self.isEditable = true
                        }
                    }
                }
                .padding(.leading, -55)
                .environment(\.editMode, isEditable ? .constant(.active) : .constant(.inactive))
                
                
            } // VStack
            .contentShape(Rectangle())
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
            .navigationBarTitle("", displayMode: .inline)
            
        } //Geometry
        
    } // View
    
    func move(from source: IndexSet, to destination: Int) {
        dummy.move(fromOffsets: source, toOffset: destination)
    }
}

struct MenuOrderView_Previews: PreviewProvider {
    static var previews: some View {
        MenuOrderView()
    }
}
