//
//  CalendarView.swift
//  Siksha
//
//  Created by You Been Lee on 2021/05/04.
//

import SwiftUI

struct CalendarView: View {
    
    @ObservedObject var viewModel = MenuViewModel()
    
    var body: some View {
        
        HStack {
            
            Spacer()
            
            Button(action: {

            }, label: {
                Image("PrevDate")
                    .resizable()
                    .frame(width: 10, height: 16)
            })
            .padding(.trailing, 16)
            
            Text("2021.03")
            
            Button(action: {
                
            }, label: {
                Image("NextDate")
                    .resizable()
                    .frame(width: 10, height: 16)
            })
            .padding(.leading, 16)
            
            Spacer()
            
        }
        
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
    }
}
