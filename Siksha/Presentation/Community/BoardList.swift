//
//  BoardList.swift
//  Siksha
//
//  Created by 박정헌 on 2023/07/29.
//

import Combine
import SwiftUI

struct BoardList<ViewModel>: View where ViewModel: CommunityViewModelType {
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .center, spacing: 10) {
                ForEach(self.viewModel.boardsListPublisher, id: \.self) { boardInfo in
                    BoardNameCell(isSelected: boardInfo.isSelected, boardName: boardInfo.name)
                        .onTapGesture {
                            self.viewModel.selectBoard(id: boardInfo.id)
                        }
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

#Preview {
    BoardList(viewModel: StubCommunityViewModel())
}
