//
//  KeywordRateRow.swift
//  Siksha
//
//  Created by Jihyeon on 10/7/25.
//

import SwiftUI

struct KeywordRateRow: View {
    var type: KeywordRateType
    
    var body: some View {
        HStack(spacing: 0) {
            Image(type.imageString)
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 16)
                .padding(.trailing, 9.5)
                .padding(.leading, 18)
            
            Text(type.description)
                .customFont(font: .text13(weight: .Bold))
                .foregroundStyle(Color.gray800)
            
            Spacer()
            
            Text("\(type.tempCnt)")
                .customFont(font: .text14(weight: .ExtraBold))
                .foregroundStyle(Color.orange500)
                .padding(.trailing, 19)
        }
        .frame(height: 36)
        .frame(maxWidth: .infinity)
        .background {
            ZStack(alignment: .leading) {
                Color.gray100
                
                Group {
                    if type == .price {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.orangeTint)
                            .frame(width: 106)
                    } else if type == .yang {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.orangeTint)
                            .frame(width: 156)
                    } else {
                        Color.orangeTint
                    }
                }
                .background{ Color.white }
                .cornerRadius(8)
            }
        }
        .cornerRadius(8)
    }
}
