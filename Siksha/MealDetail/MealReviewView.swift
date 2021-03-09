//
//  RatingView.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/05.
//

import SwiftUI

@available(iOS 14.0, *)
private extension MealReviewView {
    var starSection: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(viewModel.meal?.nameKr ?? "")
                    .font(.custom("NanumSquareOTFB", size: 22))
                    .foregroundColor(darkFontColor)
                
                RatingStar($viewModel.scoreToSubmit, size: 35)
                    .gesture(
                        DragGesture(minimumDistance: 0, coordinateSpace: .local)
                            .updating($score) { (value, state, transcation) in
                                state = Int(value.location.x/20.5)
                                viewModel.scoreToSubmit = Double(state)/2.0
                            }
                    )
            }
            
            Spacer()
        }
        .padding(EdgeInsets(top: 20, leading: 34, bottom: 48, trailing: 34))
    }
    
    var commentSection: some View {
        VStack(spacing: 0) {
            HStack {
                Image("Comment")
                    .resizable()
                    .frame(width: 17, height: 16)
                
                Text("식단 한 줄 평을 함께 남겨보세요!")
                    .font(.custom("NanumSquareOTFB", size: 14))
                    .foregroundColor(fontColor)
                
                Spacer()
            }
            .padding([.leading, .trailing], 36)
            
            TextView(text: $viewModel.commentToSubmit)
                .frame(height: 148)
                .padding(EdgeInsets(top: 11, leading: 28, bottom: 6, trailing: 28))
            
            HStack {
                Spacer()
                Text("\(viewModel.commentToSubmit.count) / 150자")
                    .font(.custom("NanumSquareOTFL", size: 11))
                    .foregroundColor(fontColor)
            }
            .padding([.leading, .trailing], 28)
        }
    }
    
    func submitButton(_ geometry: GeometryProxy) -> some View {
        Button(action: {
            viewModel.submitReview()
        }) {
            ZStack(alignment: .top) {
                if viewModel.canSubmit {
                    Image("SubmitButton")
                        .resizable()
                        .renderingMode(.original)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50 + geometry.safeAreaInsets.bottom)
                } else {
                    Color.init("LightGrayColor")
                }
                
                Text("평가하기")
                    .font(.custom("NanumSquareOTFB", size: 20))
                    .foregroundColor(.white)
                    .padding(.top, 15)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50 + geometry.safeAreaInsets.bottom)
        }
        .disabled(!viewModel.canSubmit)
    }
    
    var alertMessage: Text {
        var message = ""
        if viewModel.postReviewStatus == .succeeded {
            message = "평가가 등록되었습니다."
        } else if viewModel.postReviewStatus == .failed {
            if let error = viewModel.errorCode {
                message = error.message
            } else {
                message = "예상치 못한 오류입니다. 다시 시도해주세요."
            }
        }
        return Text(message)
    }
    
    var alertButton: Alert.Button {
        var action: (() -> Void)? = nil
        if viewModel.postReviewStatus == .succeeded {
            action = {
                presentationMode.wrappedValue.dismiss()
            }
        } else if viewModel.postReviewStatus == .failed {
            if let _ = viewModel.errorCode {
                action = {
                    presentationMode.wrappedValue.dismiss()
                }
            } else {
                action = {}
            }
        }
        return Alert.Button.default(Text("확인"), action: action)
    }
}

// MARK: - Rating View

@available(iOS 14.0, *)
struct MealReviewView: View {
    private let darkFontColor = Color("DarkFontColor")
    private let fontColor = Color("DefaultFontColor")
    private let orangeColor = Color.init("MainThemeColor")

    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @GestureState var score: Int = 0

    @StateObject var viewModel: MealReviewViewModel = MealReviewViewModel()
    
    let meal: Meal
    
    init(_ meal: Meal) {
        self.meal = meal
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                starSection
                
                commentSection
                
                Spacer()
                
                submitButton(geometry)
            }
            .edgesIgnoringSafeArea(.bottom)
            .background(Color.white.onTapGesture {
                UIApplication.shared.endEditing()
            })
            .navigationBarTitle(
                Text("평가 남기기"),
                displayMode: .inline
            )
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Image("BackButton")
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: 20, height: 17)
            })
            .onAppear {
                viewModel.meal = self.meal
            }
            .alert(isPresented: $viewModel.showAlert, content: {
                Alert(title: Text("평가 남기기"), message: alertMessage, dismissButton: alertButton)
            })
            
        }
        .ignoresSafeArea(.keyboard)
    }
}

// MARK: - iOS 13

@available(iOS 13.0, *)
private extension MealReviewView13 {
    var starSection: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(viewModel.meal?.nameKr ?? "")
                    .font(.custom("NanumSquareOTFB", size: 22))
                    .foregroundColor(darkFontColor)
                
                RatingStar($viewModel.scoreToSubmit, size: 35)
                    .gesture(
                        DragGesture(minimumDistance: 0, coordinateSpace: .local)
                            .updating($score) { (value, state, transcation) in
                                state = Int(value.location.x/20.5)
                                viewModel.scoreToSubmit = Double(state)/2.0
                            }
                    )
            }
            
            Spacer()
        }
        .padding(EdgeInsets(top: 20, leading: 34, bottom: 48, trailing: 34))
    }
    
    var commentSection: some View {
        VStack(spacing: 0) {
            HStack {
                Image("Comment")
                    .resizable()
                    .frame(width: 17, height: 16)
                
                Text("식단 한 줄 평을 함께 남겨보세요!")
                    .font(.custom("NanumSquareOTFB", size: 14))
                    .foregroundColor(fontColor)
                
                Spacer()
            }
            .padding([.leading, .trailing], 36)
            
            TextView(text: $viewModel.commentToSubmit)
                .frame(height: 148)
                .padding(EdgeInsets(top: 11, leading: 28, bottom: 6, trailing: 28))
            
            HStack {
                Spacer()
                Text("\(viewModel.commentToSubmit.count) / 150자")
                    .font(.custom("NanumSquareOTFL", size: 11))
                    .foregroundColor(fontColor)
            }
            .padding([.leading, .trailing], 28)
        }
    }
    
    func submitButton(_ geometry: GeometryProxy) -> some View {
        Button(action: {
            viewModel.submitReview()
        }) {
            ZStack(alignment: .top) {
                if viewModel.canSubmit {
                    Image("SubmitButton")
                        .resizable()
                        .renderingMode(.original)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50 + geometry.safeAreaInsets.bottom)
                } else {
                    Color.init("LightGrayColor")
                }
                
                Text("평가하기")
                    .font(.custom("NanumSquareOTFB", size: 20))
                    .foregroundColor(.white)
                    .padding(.top, 15)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50 + geometry.safeAreaInsets.bottom)
        }
        .disabled(!viewModel.canSubmit)
    }
    
    var alertMessage: Text {
        var message = ""
        if viewModel.postReviewStatus == .succeeded {
            message = "평가가 등록되었습니다."
        } else if viewModel.postReviewStatus == .failed {
            if let error = viewModel.errorCode {
                message = error.message
            } else {
                message = "예상치 못한 오류입니다. 다시 시도해주세요."
            }
        }
        return Text(message)
    }
    
    var alertButton: Alert.Button {
        var action: (() -> Void)? = nil
        if viewModel.postReviewStatus == .succeeded {
            action = {
                presentationMode.wrappedValue.dismiss()
            }
        } else if viewModel.postReviewStatus == .failed {
            if let _ = viewModel.errorCode {
                action = {
                    presentationMode.wrappedValue.dismiss()
                }
            } else {
                action = {}
            }
        }
        return Alert.Button.default(Text("확인"), action: action)
    }
}

@available(iOS 13.0, *)
struct MealReviewView13: View {
    private let darkFontColor = Color("DarkFontColor")
    private let fontColor = Color("DefaultFontColor")
    private let orangeColor = Color.init("MainThemeColor")

    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @GestureState var score: Int = 0

    @ObservedObject var viewModel: MealReviewViewModel = MealReviewViewModel()

    init(_ meal: Meal) {
        viewModel.meal = meal
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                starSection
                
                commentSection
                
                Spacer()
                
                submitButton(geometry)
            }
            .edgesIgnoringSafeArea(.bottom)
            .background(Color.white.onTapGesture {
                UIApplication.shared.endEditing()
            })
            .navigationBarTitle(
                Text("평가 남기기"),
                displayMode: .inline
            )
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Image("BackButton")
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: 20, height: 17)
            })
            .alert(isPresented: $viewModel.showAlert, content: {
                Alert(title: Text("평가 남기기"), message: alertMessage, dismissButton: alertButton)
            })
        }
    }
}

// MARK: - Preview

//struct MealReviewView_Previews: PreviewProvider {
////    static var previews: some View {
////        let meal = Meal()
////        meal.nameKr = "올리브스테이크"
////
////        if #available(iOS 14.0, *) {
////            return MealReviewView(meal)
////        } else {
////            return MealReviewView13(meal)
////        }
////    }
//}
