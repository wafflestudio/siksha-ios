//
//  ImageReviewView.swift
//  Siksha
//
//  Created by You Been Lee on 2021/05/23.
//

import SwiftUI

struct ImageReviewView: View {
    
    private let lightGrayColor = Color.init("LightGrayColor")

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject var mealInfoViewModel: MealInfoViewModel

    let meal: Meal

    init(_ meal: Meal, mealInfoViewModel: MealInfoViewModel) {
        self.meal = meal
        self.mealInfoViewModel = mealInfoViewModel
    }

    var body: some View {

        GeometryReader { geometry in

            if mealInfoViewModel.mealImageReviews.count > 0 {
                List {
                    ForEach(mealInfoViewModel.mealImageReviews, id: \.id) { review in
                        ImageReviewCell(review)
                            .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                            .listRowInsets(EdgeInsets())
                            .background(Color.white)
                            .onAppear {
                                mealInfoViewModel.loadMoreReviewsIfNeeded(currentItem: review)
                            }
                    }
                    if mealInfoViewModel.hasMorePages && mealInfoViewModel.getReviewStatus == .loading {
                        HStack {
                            Spacer()
                            ActivityIndicator(isAnimating: .constant(true), style: .medium)
                            Spacer()
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .padding([.leading, .trailing], -10)
            } else {
                VStack {
                    Text("사진 리뷰가 없습니다.")
                        .font(.custom("NanumSquareOTFB", size: 13))
                        .foregroundColor(lightGrayColor)
                        .padding(.top, 20)
                }
                .frame(maxWidth: .infinity)
                
            }


        }
        .background(Color.white.onTapGesture {
            UIApplication.shared.endEditing()
        })
        .navigationBarTitle(
            Text("사진 리뷰 모아보기"),
            displayMode: .inline
        )
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Image("Back")
                .resizable()
                .renderingMode(.original)
                .frame(width: 10, height: 16)
        })

    }

}

//struct ImageReviewView_Previews: PreviewProvider {
//    static var previews: some View {
//        let meal = Meal()
//        ImageReviewView(meal: meal)
//    }
//}
