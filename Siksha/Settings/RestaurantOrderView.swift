//
//  MenuOrderView.swift
//  Siksha
//
//  Created by You Been Lee on 2021/02/09.
//
import SwiftUI

struct RestaurantOrderView: View {
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
        VStack(alignment: .center) {
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
            List {
                ForEach(viewModel.restaurantIds.map { UserDefaults.standard.string(forKey: "restName\($0)") ?? "" }, id: \.self) { row in
                        RestaurantOrderRow(text: row)
                            .padding(EdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 12))
                            .listRowInsets(EdgeInsets())
                            .background(backgroundColor)
                }
                .onMove(perform: move)
            }
            .environment(\.editMode, .constant(.active))
        } // VStack
        .contentShape(Rectangle())
        .customNavigationBar(title: "식당 순서 변경")
        .navigationBarItems(leading: backButton)
        .background(backgroundColor)
        .onAppear {
            viewModel.bind()
            viewModel.loadRestaurants()
        }
    } // View
    
    func move(from source: IndexSet, to destination: Int) {
        viewModel.restaurantIds.move(fromOffsets: source, toOffset: destination)
    }
}

struct MenuOrderView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RestaurantOrderView(RestaurantOrderViewModel())
                .previewDevice(PreviewDevice(rawValue: "iPhone 7"))
        }
    }
}
