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
            
            Spacer()
            
            VStack(alignment: .center) {
                Text("\(Text("'\(viewModel.meal?.nameKr ?? "")'").foregroundColor(darkFontColor))는 어땠나요?")
                    .font(.custom("NanumSquareOTFB", size: 22))
                    .foregroundColor(Color(red: 112 / 255, green: 112 / 255, blue: 112 / 255))
                    .padding(.top, 24)
                
                Text("별점을 선택해주세요.")
                    .font(.custom("NanumSquareOTFB", size: 14))
                    .foregroundColor(Color(red: 112 / 255, green: 112 / 255, blue: 112 / 255))
                    .padding(.top, 26)
                
                RatingStar($viewModel.scoreToSubmit, size: 35)
                    .gesture(
                        DragGesture(minimumDistance: 0, coordinateSpace: .local)
                            .updating($score) { (value, state, transcation) in
                                state = Int(value.location.x/50.0)+1
                                viewModel.scoreToSubmit = Double(state)
                            }
                    )
                
                // score
                Text("\(String(Int(viewModel.scoreToSubmit)))")
                    .font(.custom("NanumSquareOTFB", size: 20))
                    .foregroundColor(darkFontColor)
                    .padding(.top, 7)
                                
            }
            
            Spacer()
        }
        .padding(EdgeInsets(top: 20, leading: 28, bottom: 48, trailing: 28))
    }
    
    var commentSection: some View {
        VStack(spacing: 0) {
            HStack {
                Image("Comment-new")
                    .resizable()
                    .frame(width: 17, height: 16)
                
                Text("식단 한 줄 평을 함께 남겨보세요!")
                    .font(.custom("NanumSquareOTFB", size: 14))
                    .foregroundColor(fontColor)
                
                Spacer()
            }
            .padding([.leading, .trailing], 36)
            
            TextView(text: $viewModel.commentToSubmit, placeHolder: $viewModel.commentPlaceHolder)
                .frame(height: 148)
                .padding(EdgeInsets(top: 11, leading: 28, bottom: 6, trailing: 28))
            
            HStack {
                Spacer()
                Text("\(viewModel.commentCount) / 150자")
                    .font(.custom("NanumSquareOTFL", size: 11))
                    .foregroundColor(fontColor)
            }
            .padding([.leading, .trailing], 28)
            
        }
    }
    
    var imageSection: some View {
        VStack {
            HStack {
                ScrollView (.horizontal) {
                    HStack {
                        ForEach(addedImages, id: \.self) { image in
                            ZStack {
                                Image(uiImage: image)
                                    .resizable()
                                    .renderingMode(.original)
                                    .frame(width: 80, height: 80)
                                    .cornerRadius(8)
                                
                                Button(action: {
                                    if self.addedImages.contains(image) {
                                        self.addedImages.removeAll(where: { $0 == image })
                                    }
                                }) {
                                    Image("XButton")
                                        .resizable()
                                        .renderingMode(.original)
                                        .frame(width: 25, height: 25)
                                        .padding(EdgeInsets(top: 5, leading: 70, bottom: 70, trailing: 5))
                                }
                                
                            }
                            
                        }
                    }
                }
                
                Spacer()
            }
            .padding([.leading, .trailing], 28)
            .padding(.top, 8)
            
            HStack {
                Button(action: {
                    self.isShowingPhotoLibrary = true
                }) {
                    ZStack {
                        Image("ReviewPictureButton")
                            .resizable()
                            .renderingMode(.original)
                            .frame(width: 134, height: 32)

                        Image("AddPicture")
                            .resizable()
                            .renderingMode(.original)
                            .frame(width: 84, height: 16)
                    }
                }
                .padding(.top, 16)
                .sheet(isPresented: $isShowingPhotoLibrary) {
                    ImagePickerCoordinatorView(selectedImages: $addedImages)
                }
                
                Spacer()
            }
            .padding([.leading, .trailing], 28)
        }
    }
    
    var submitButton: some View {
        Button(action: {
            if addedImages.count > 0 {
                viewModel.submitReviewImages(images: addedImages)
            } else {
                viewModel.submitReview()
            }
        }) {
            ZStack(alignment: .top) {
                if viewModel.canSubmit {
                    Image("SubmitButton-new")
                        .resizable()
                        .renderingMode(.original)
                        .frame(width: 343, height: 56)
                } else {
                    // need gray image
                    Image("SubmitButton-new")
                        .resizable()
                        .renderingMode(.original)
                        .frame(width: 343, height: 56)
//                    Color.init("LightGrayColor")
                }
                
                Text("평가 등록")
                    .font(.custom("NanumSquareOTFB", size: 20))
                    .foregroundColor(.white)
                    .padding(.top, 15)
            }
        }
        .padding(.bottom, 66)
        .disabled(!viewModel.canSubmit)
    }

    var alertMessage: Text {
        var message = ""
        if viewModel.postReviewSucceeded {
            message = "평가가 등록되었습니다."
        } else {
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
        if viewModel.postReviewSucceeded {
            action = {
                mealInfoViewModel.mealReviews = []
                mealInfoViewModel.currentPage = 1
                mealInfoViewModel.loadMoreReviewsIfNeeded(currentItem: nil)
                presentationMode.wrappedValue.dismiss()
            }
        } else {
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
    
    var bindingForImage: Binding<UIImage> {
        Binding<UIImage> { () -> UIImage in
            return addedImages.last ?? UIImage()
        } set: { (newImage) in
            addedImages.append(newImage)
            print("Images: \(addedImages.count)")
        }
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
    @ObservedObject var mealInfoViewModel: MealInfoViewModel
    
    @State private var isShowingPhotoLibrary = false
    @State private var addedImages = [UIImage]()
    
    let meal: Meal
    
    init(_ meal: Meal, mealInfoViewModel: MealInfoViewModel) {
        self.meal = meal
        self.mealInfoViewModel = mealInfoViewModel
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center, spacing: 0) {
                starSection
                
                commentSection
                
                imageSection
                
                Spacer()
                
                submitButton
            }
//            .edgesIgnoringSafeArea(.bottom)
            .background(Color.white.onTapGesture {
                UIApplication.shared.endEditing()
            })
            .navigationBarTitle(
                Text("나의 평가 남기기"),
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
            .onAppear {
                viewModel.meal = self.meal
            }
            .alert(isPresented: $viewModel.showAlert, content: {
                Alert(title: Text("나의 평가 남기기"), message: alertMessage, dismissButton: alertButton)
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
            
            Spacer()
            
            VStack(alignment: .center) {
                // "(메뉴)는 어땠나요?" 추가 안 됨 -> string interpolation only available in iOS 14.0
                Text(viewModel.meal?.nameKr ?? "")
                    .font(.custom("NanumSquareOTFB", size: 22))
                    .foregroundColor(darkFontColor)
                    .padding(.top, 24)
                
                Text("별점을 선택해주세요.")
                    .font(.custom("NanumSquareOTFB", size: 14))
                    .foregroundColor(Color(red: 112 / 255, green: 112 / 255, blue: 112 / 255))
                    .padding(.top, 26)
                
                RatingStar($viewModel.scoreToSubmit, size: 35)
                    .gesture(
                        DragGesture(minimumDistance: 0, coordinateSpace: .local)
                            .updating($score) { (value, state, transcation) in
                                state = Int(value.location.x/50.0)+1
                                viewModel.scoreToSubmit = Double(state)
                            }
                    )
                
                // score
                Text("\(String(Int(viewModel.scoreToSubmit)))")
                    .font(.custom("NanumSquareOTFB", size: 20))
                    .foregroundColor(darkFontColor)
                    .padding(.top, 7)
                                
            }
            
            Spacer()
        }
        .padding(EdgeInsets(top: 20, leading: 28, bottom: 48, trailing: 28))
    }
    
    var commentSection: some View {
        VStack(spacing: 0) {
            HStack {
                Image("Comment-new")
                    .resizable()
                    .frame(width: 17, height: 16)
                
                Text("식단 한 줄 평을 함께 남겨보세요!")
                    .font(.custom("NanumSquareOTFB", size: 14))
                    .foregroundColor(fontColor)
                
                Spacer()
            }
            .padding([.leading, .trailing], 36)
            
            TextView(text: $viewModel.commentToSubmit, placeHolder: $viewModel.commentPlaceHolder)
                .frame(height: 148)
                .padding(EdgeInsets(top: 11, leading: 28, bottom: 6, trailing: 28))
            
            HStack {
                Spacer()
                Text("\(viewModel.commentCount) / 150자")
                    .font(.custom("NanumSquareOTFL", size: 11))
                    .foregroundColor(fontColor)
            }
            .padding([.leading, .trailing], 28)
            
        }
    }
    
    var imageSection: some View {
        VStack {
            HStack {
                ScrollView (.horizontal) {
                    HStack {
                        ForEach(addedImages, id: \.self) { image in
                            ZStack {
                                Image(uiImage: image)
                                    .resizable()
                                    .renderingMode(.original)
                                    .frame(width: 80, height: 80)
                                    .cornerRadius(8)
                                
                                Button(action: {
                                    if self.addedImages.contains(image) {
                                        self.addedImages.removeAll(where: { $0 == image })
                                    }
                                }) {
                                    Image("XButton")
                                        .resizable()
                                        .renderingMode(.original)
                                        .frame(width: 25, height: 25)
                                        .padding(EdgeInsets(top: 5, leading: 70, bottom: 70, trailing: 5))
                                }
                                
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding([.leading, .trailing], 28)
            .padding(.top, 8)
            
            HStack {
                Button(action: {
                    self.isShowingPhotoLibrary = true
                }) {
                    ZStack {
                        Image("ReviewPictureButton")
                            .resizable()
                            .renderingMode(.original)
                            .frame(width: 134, height: 32)

                        Image("AddPicture")
                            .resizable()
                            .renderingMode(.original)
                            .frame(width: 84, height: 16)
                    }
                }
                .padding(.top, 16)
                .sheet(isPresented: $isShowingPhotoLibrary) {
                    ImagePickerCoordinatorView(selectedImages: $addedImages)
                }
                
                Spacer()
            }
            .padding([.leading, .trailing], 28)
        }
    }
    
    var submitButton: some View {
        Button(action: {
            if addedImages.count > 0 {
                viewModel.submitReviewImages(images: addedImages)
            } else {
                viewModel.submitReview()
            }
        }) {
            ZStack(alignment: .top) {
                if viewModel.canSubmit {
                    Image("SubmitButton-new")
                        .resizable()
                        .renderingMode(.original)
                        .frame(width: 343, height: 56)
                } else {
                    // need gray image
                    Image("SubmitButton-new")
                        .resizable()
                        .renderingMode(.original)
                        .frame(width: 343, height: 56)
//                    Color.init("LightGrayColor")
                }
                
                Text("평가 등록")
                    .font(.custom("NanumSquareOTFB", size: 20))
                    .foregroundColor(.white)
                    .padding(.top, 15)
            }
        }
        .padding(.bottom, 66)
        .disabled(!viewModel.canSubmit)
    }
    
    var alertMessage: Text {
        var message = ""
        if viewModel.postReviewSucceeded {
            message = "평가가 등록되었습니다."
        } else {
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
        if viewModel.postReviewSucceeded {
            action = {
                presentationMode.wrappedValue.dismiss()
            }
        } else {
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
    
    var bindingForImage: Binding<UIImage> {
        Binding<UIImage> { () -> UIImage in
            return addedImages.last ?? UIImage()
        } set: { (newImage) in
            addedImages.append(newImage)
            print("Images: \(addedImages.count)")
        }
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
    
    @State private var isShowingPhotoLibrary = false
    @State private var addedImages = [UIImage]()

    init(_ meal: Meal) {
        viewModel.meal = meal
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center, spacing: 0) {
                starSection
                
                commentSection
                
                imageSection
                
                Spacer()
                
                submitButton
            }
            .edgesIgnoringSafeArea(.all)
            .background(Color.white.onTapGesture {
                UIApplication.shared.endEditing()
            })
            .navigationBarHidden(true)
            .alert(isPresented: $viewModel.showAlert, content: {
                Alert(title: Text("평가 남기기"), message: alertMessage, dismissButton: alertButton)
            })
        }
    }
}

// MARK: - Preview


//struct MealReviewView_Previews: PreviewProvider {
//    static var previews: some View {
//        let meal = Meal()
//        meal.nameKr = "올리브스테이크"
//
//        return MealReviewView(meal, mealInfoViewModel: MealInfoViewModel(meal))
//    }
//}
