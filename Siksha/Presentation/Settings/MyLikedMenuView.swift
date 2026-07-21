//
//  MyLikedMenuView.swift
//  Siksha
//
//  Created by 박정헌 on 8/17/25.
//

import SwiftUI

struct MyLikedMenuView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject private var contentViewModel: ContentViewModel
    @ObservedObject var viewModel: MyLikedMenuViewModel
    var backButton: some View {
        Button(action: {
            contentViewModel.showPopUp = false
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Image("NavigationBack")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(.white)
        }
    }
    init(viewModel: MyLikedMenuViewModel) {
        self.viewModel = viewModel

    }
    var body: some View {
        ZStack(alignment: .topTrailing) {
            contentView
        }

        .padding(.zero)

        .customNavigationBar(title: "내가 찜한 메뉴")
        .navigationBarItems(leading: backButton)
        .navigationBarItems(
            trailing: NavigationLink(destination: AlarmView(viewModel: viewModel)) {
                Image("notification").padding(
                    EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 5))
            }
        )
        .onAppear {
            contentViewModel.showPopUp = true

        }
        .task {
            await viewModel.loadMyLikedMenu()
        }
        .onDisappear {
            viewModel.unLikedMenuCleanup()
            contentViewModel.showPopUp = false

        }
        .background(Color.backgroundMain)
        .errorAlert(error: $viewModel.error)

    }

}

private extension MyLikedMenuView {
    @ViewBuilder
    var contentView: some View {
        switch viewModel.loadState {
        case .idle, .loading:
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .loaded:
            if viewModel.likedMenuGroups.isEmpty {
                emptyView
            } else {
                likedMenuListView
            }
        case .failed:
            if viewModel.likedMenuGroups.isEmpty {
                loadFailedView
            } else {
                likedMenuListView
            }
        }
    }

    var emptyView: some View {
        ZStack(
            alignment: .center,
            content: {
                Text("내가 찜한 메뉴가 없어요")
                    .customFont(font: .text15(weight: .Bold))
                    .foregroundColor(Color.gray600)
            }
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    var loadFailedView: some View {
        ZStack(
            alignment: .center,
            content: {
                Text("내가 찜한 메뉴를 불러오지 못했어요")
                    .customFont(font: .text15(weight: .Bold))
                    .foregroundColor(Color.gray600)
            }
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    var likedMenuListView: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(viewModel.likedMenuGroups, id: \.self) { group in
                    LikedMenuRestaurantCell(viewModel, group)
                }
            }
            .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
        }
        .padding(EdgeInsets(top: 12, leading: 0, bottom: 0, trailing: 0))
    }
}
