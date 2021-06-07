//
//  MenuOrderView.swift
//  Siksha
//
//  Created by You Been Lee on 2021/02/09.
//
import SwiftUI

struct MenuOrderView: View {
    private let backgroundColor = Color.init("AppBackgroundColor")
    
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
        UITableView.appearance().backgroundColor = .clear
        
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            NavigationBar(title: "식단 순서 변경", showBack: true)
            
            // Description
            HStack {
                Spacer()
                Text("우측 손잡이를 드래그하여 순서를 바꿔보세요.")
                    .font(.custom("NanumSquareOTFR", size: 14))
                    .foregroundColor(.init("DefaultFontColor"))
                Spacer()
            }
            .padding(.top, 10)
            .padding(.bottom, 5)
            
            List {
                ForEach(viewModel.restaurantIds.map { UserDefaults.standard.string(forKey: "restName\($0)") ?? "" }, id: \.self) { row in
                    RestaurantOrderRow(text: row)
                        .padding(EdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 12))
                        .listRowInsets(EdgeInsets())
                        .background(backgroundColor)
                }
                .onMove(perform: move)
            }
            .padding(.leading, leading)
            .environment(\.editMode, .constant(.active))
        } // VStack
        .edgesIgnoringSafeArea(.all)
        .contentShape(Rectangle())
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitle("", displayMode: .inline)
        .background(backgroundColor)
        .onAppear {
            viewModel.setRestaurantIdList()
        }
    } // View
    
    func move(from source: IndexSet, to destination: Int) {
        viewModel.restaurantIds.move(fromOffsets: source, toOffset: destination)
    }
}

struct MenuOrderView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MenuOrderView(SettingsViewModel())
                .previewDevice(PreviewDevice(rawValue: "iPhone 7"))
        }
    }
}
