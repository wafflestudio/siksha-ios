//
//  MenuOrderView.swift
//  Siksha
//
//  Created by You Been Lee on 2021/02/09.
//
import SwiftUI

struct RestaurantOrderView: View {
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
        ZStack {
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
                
                switch viewModel.networkStatus {
                case .idle, .loading:
                    Spacer()
                    ProgressView()
                    Spacer()
                case .failed:
                    Spacer()
                    Text("식당 정보를 불러오지 못했습니다.")
                        .customFont(font: .text15(weight: .Bold))
                        .foregroundColor(.gray600)
                    Spacer()
                case .succeeded:
                    List {
                        Section {
                            ForEach(viewModel.personalRestaurants, id: \.id) { restaurant in
                                RestaurantOrderRow(
                                    text: restaurant.nameKr ?? restaurant.code,
                                    isLiked: restaurant.liked,
                                    isVisible: restaurant.visible,
                                    onLikeTap: {
                                        Task {
                                            await viewModel.togglePersonalRestaurantLike(restaurantId: restaurant.id)
                                        }
                                    },
                                    onVisibilityTap: {
                                        Task {
                                            await viewModel.togglePersonalRestaurantVisibility(restaurantId: restaurant.id)
                                        }
                                    }
                                )
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
                }
            }

            ToastView(
                message: viewModel.toastMessage,
                bottomMargin: 60,
                isVisible: viewModel.isToastVisible
            )
        }
        .contentShape(Rectangle())
        .background(Color.backgroundMain)
        .customNavigationBar(title: "식당 순서 변경")
        .navigationBarItems(leading: backButton)
        .task {
            await viewModel.loadPersonalRestaurants()
        }
    }
    func move(from source: IndexSet, to destination: Int) {
        viewModel.movePersonalRestaurant(from: source, to: destination)
    }
}

struct MenuOrderView_Previews: PreviewProvider {
    static var previews: some View {
        RestaurantOrderView(RestaurantOrderViewModel())
    }
}
