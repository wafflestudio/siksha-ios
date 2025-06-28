//
//  FavoriteMenuOrderView.swift
//  Siksha
//
//  Created by You Been Lee on 2021/02/09.
//
import SwiftUI

struct FavoriteRestaurantOrderView: View {
    private let backgroundColor = Color.init("AppBackgroundColor")
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject var viewModel: RestaurantOrderViewModel
    
    private var leading: CGFloat {
        if UIScreen.main.bounds.width > 380 {
            return -44
        } else {
            return -40
        }
    }
    
    var backButton: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Image("NavigationBack")
                .resizable()
                .frame(width: 10, height: 16)
        }
    }
    
    init(_ viewModel: RestaurantOrderViewModel) {
        UITableView.appearance().separatorStyle = .none
        UITableView.appearance().backgroundColor = .clear
        
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            // Description
            HStack {
                Spacer()
                Text("우측 손잡이를 드래그하여 순서를 바꿔보세요.")
                    .font(.custom("NanumSquareOTFR", size: 14))
                    .foregroundColor(.init("Gray700"))
                Spacer()
            }
            .padding(.top, 20)
            .padding(.bottom, 5)
            
            if viewModel.favRestaurantIds.count > 0 {
                List() {
                    ForEach(viewModel.favRestaurantIds.map { UserDefaults.standard.string(forKey: "restName\($0)") ?? "" }, id: \.self) { row in
                        RestaurantOrderRow(text: row)
                            .padding(EdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 12))
                            .listRowInsets(EdgeInsets())
                            .background(backgroundColor)
                    }
                    .onMove(perform: move)
                }
                .environment(\.editMode, .constant(.active))
            } else {
                VStack {
                    Spacer()
                    
                    Text("즐겨찾기에 추가된 식당이 없습니다.")
                        .font(.custom("NanumSquareOTFB", size: 15))
                        .foregroundColor(.init("Gray700"))
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            }
        } // VStack
        .customNavigationBar(title: "즐겨찾기 순서 변경")
        .navigationBarItems(leading: backButton)
        .contentShape(Rectangle())
        .background(backgroundColor)
        .onAppear {
            
            viewModel.loadRestaurants()
        }
    } // View
    
    func move(from source: IndexSet, to destination: Int) {
        viewModel.favRestaurantIds.move(fromOffsets: source, toOffset: destination)
    }
}

struct FavoriteMenuOrderView_Previews: PreviewProvider {
    static var previews: some View {
        RestaurantOrderView(RestaurantOrderViewModel())
    }
}
