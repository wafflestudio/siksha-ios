//
//  FavoriteMenuOrderView.swift
//  Siksha
//
//  Created by You Been Lee on 2021/02/09.
//
import SwiftUI

struct FavoriteRestaurantOrderView: View {
    private let backgroundColor = Color.backgroundSecondary
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject var viewModel: RestaurantOrderViewModel
    
    var backButton: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Image("NavigationBack")
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .foregroundColor(Color.iconWhiteIcon)
        }
        .contentShape(Rectangle())
    }
    
    init(_ viewModel: RestaurantOrderViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            HStack {
                Spacer()
                Text("우측 손잡이를 드래그하여 순서를 바꿔보세요.")
                    .customFont(font: .text13(weight: .Regular))
                    .foregroundColor(.gray700)
                Spacer()
            }
            .padding(.top, 14)
            .padding(.bottom, 14)
            .background(backgroundColor)
            
            if viewModel.favRestaurantIds.count > 0 {
                List {
                    Section {
                        ForEach(viewModel.favRestaurantIds.map { UserDefaults.standard.string(forKey: "restName\($0)") ?? "" }, id: \.self) { row in
                            RestaurantOrderRow(text: row)
                                .listRowInsets(EdgeInsets())
                                .alignmentGuide(.listRowSeparatorLeading) { d in
                                    d[.leading]
                                }
                                .listRowSeparatorTint(Color.borderPrimary)
                        }
                        .onMove(perform: move)
                    } header: {
                        Spacer(minLength: 0).listRowInsets(EdgeInsets())
                    }
                }
                .environment(\.defaultMinListHeaderHeight, 20)
            } else {
                VStack {
                    Spacer()
                    
                    Text("즐겨찾기에 추가된 식당이 없습니다.")
                        .font(.custom("NanumSquareOTFB", size: 15))
                        .foregroundColor(.gray700)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            }
        }
        .contentShape(Rectangle())
        .customNavigationBar(title: "즐겨찾기 식당 순서 변경")
        .navigationBarItems(leading: backButton)
        .background(Color.backgroundPrimary)
        .onAppear {
            
            viewModel.loadRestaurants()
        }
    }
    
    func move(from source: IndexSet, to destination: Int) {
        viewModel.favRestaurantIds.move(fromOffsets: source, toOffset: destination)
    }
}

struct FavoriteMenuOrderView_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteRestaurantOrderView(RestaurantOrderViewModel())
    }
}
