//
//  MenuOrderView.swift
//  Siksha
//
//  Created by You Been Lee on 2021/02/09.
//

import SwiftUI

struct FavoriteMenuOrderView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @ObservedObject var viewModel: SettingsViewModel
    
    private var leading: CGFloat {
        if UIScreen.main.bounds.width > 380 {
            return -44
        } else {
            return -40
        }
    }
    
    init(_ viewModel: SettingsViewModel) {
        UITableView.appearance().separatorStyle = .none
        
        self.viewModel = viewModel
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading) {
                // Navigation Bar
                HStack {
                    BackButton(self.presentationMode)
                    Spacer()
                    
                    Text("식단 순서 변경")
                        .font(.custom("NanumSquareOTFB", size: 18))
                        .foregroundColor(.init(white: 79/255))
                    Spacer()
                    
                    Text("")
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
                .padding(.top, 20)
                .padding(.bottom, 5)
                
                if viewModel.favRestaurantIds.count > 0 {
                    List() {
                        ForEach(viewModel.favRestaurantIds.map { UserDefaults.standard.string(forKey: "restName\($0)") ?? "" }, id: \.self) { row in
                            MenuRow(text: row)
                                .padding(EdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 12))
                                .listRowInsets(EdgeInsets())
                                .background(Color.white)
                        }
                        .onMove(perform: move)
                    }
                    .padding(.leading, leading)
                    .environment(\.editMode, .constant(.active))
                } else {
                    VStack {
                        Spacer()
                        
                        Text("즐겨찾기에 추가된 식당이 없습니다.")
                            .font(.custom("NanumSquareOTFB", size: 15))
                            .foregroundColor(.init("DefaultFontColor"))
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                }
            } // VStack
            .contentShape(Rectangle())
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
            .navigationBarTitle("", displayMode: .inline)
            
        } //Geometry
        .onAppear {
            viewModel.setRestaurantIdList()
        }
    } // View
    
    func move(from source: IndexSet, to destination: Int) {
        viewModel.favRestaurantIds.move(fromOffsets: source, toOffset: destination)
    }
}

struct FavoriteMenuOrderView_Previews: PreviewProvider {
    static var previews: some View {
        MenuOrderView(SettingsViewModel())
    }
}
