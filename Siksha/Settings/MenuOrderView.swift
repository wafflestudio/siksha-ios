//
//  MenuOrderView.swift
//  Siksha
//
//  Created by You Been Lee on 2021/02/09.
//

import SwiftUI

struct MenuOrderView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State private var dummy = ["학생회관 식당", "농생대 3식당", "302동식당"]
    @State private var isEditable = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading) {
                
                // Navigation Bar
                HStack {
                    BackButton(self.presentationMode)
                    Spacer()
                    
                    Text("식단 순서 변경")
                        .font(.custom("NanumSquareOTFB", size: 17))
                        .foregroundColor(.init("DefaultFontColor"))
                    Spacer()
                    
                    Button(action: {
                        self.isEditable.toggle()
                        // viewModel code...
                        
                    }, label: {
                        Text(isEditable ? "확인" : "편집")
                            .font(.custom("NanumSquareOTFB", size: 14))
                            .foregroundColor(.init("LightGrayColor"))
                    })
                    .frame(width: 100, alignment: .trailing)
                }
                .padding([.leading, .trailing], 16)
                .padding(.top, 26)
                
                // Description
                HStack {
                    Spacer()
                    Text("우측 손잡이를 드래그하여 순서를 바꿔보세요.")
                        .font(.custom("NanumSquareOTFR", size: 14))
                        .foregroundColor(.init("DefaultFontColor"))
                    Spacer()
                }
                .padding([.top, .bottom], 20)
                
                List {
                    ForEach(dummy, id: \.self) { row in
                        MenuRow(text: row)
                            .padding(EdgeInsets(top: 3, leading: 12, bottom: 1, trailing: 12))
                            .listRowInsets(EdgeInsets())
                            .background(Color.white)
                    }
                    .onMove(perform: move)
                }
                .padding(.leading, isEditable ? -44 : 0)
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
