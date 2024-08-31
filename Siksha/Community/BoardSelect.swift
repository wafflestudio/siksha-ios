//
//  BoardSelect.swift
//  Siksha
//
//  Created by 박정헌 on 2023/07/29.
//

import Foundation
import SwiftUI
import Combine

struct BoardSelect<ViewModel>: View where ViewModel: CommunityViewModelType{
    @ObservedObject private var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body:some View{
        ScrollView(.horizontal, showsIndicators: false){
            HStack(alignment: .center, spacing: 10){
                ForEach(self.viewModel.boardsListPublisher, id: \.self) { boardInfo in
                    BoardNameCell(isSelected: boardInfo.isSelected, boardName: boardInfo.name)
                        .onTapGesture {
                            self.viewModel.selectBoard(id: boardInfo.id)
                        }
                }
            }
        }
        .padding(EdgeInsets(top: 23, leading: 20, bottom: 18, trailing: 28))
    }
}

struct BoardSelect_Preview:PreviewProvider{
    static var previews:some View{
        BoardSelect(viewModel: StubCommunityViewModel())
    }
}
