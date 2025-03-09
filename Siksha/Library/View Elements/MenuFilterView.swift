//
//  MenuFilterView.swift
//  Siksha
//
//  Created by 권현구 on 1/26/25.
//

import SwiftUI

struct MenuFilterView: View {
    @State private var distanceValue: Double = 400
    @State private var lowerPrice: Double = 5000
    @State private var upperPrice: Double = 8000
    @State private var isOpen: Bool = false
    @State private var hasReview: Bool = false
    @State private var minimumRating: Float = 0.0
    @State private var selectedCategories: [String] = ["전체", "분식", "양식"]
    @ObservedObject var menuViewModel: MenuViewModel
    @ObservedObject var favoriteViewModel: FavoriteViewModel
    @Environment(\.dismiss) var dismiss
    let ratings = [3.5, 4.0, 4.5]
    let categories = ["전체", "한식", "중식", "분식", "일식", "양식", "아시안", "뷔페"]
    let maxPrice = 15000.0
    let maxDistance = 1000.0
    
    private var viewModelType: ViewModelType
    enum ViewModelType {
        case menu
        case favorite
    }
    
    // menuViewModel 사용
    init(menuViewModel: MenuViewModel) {
        self.menuViewModel = menuViewModel
        self.favoriteViewModel = FavoriteViewModel()
        self.viewModelType = .menu
    }
    
    // favoriteViewModel 사용
    init(favoriteViewModel: FavoriteViewModel) {
        self.favoriteViewModel = favoriteViewModel
        self.menuViewModel = MenuViewModel() // 필요한 기본값
        self.viewModelType = .favorite
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color.secondary)
                .opacity(0.5)
                .frame(width: 42, height: 4)
                .padding(.vertical, 17)
            
            Text("필터")
                .font(.custom("NanumSquareOTFB", size: 14))
                .padding(EdgeInsets(top: 1.32, leading: 0, bottom: 13.68, trailing: 0))
            
            ScrollView {
                VStack(spacing: 40) {
                    SectionHeader(title: "거리")
                    DistanceSliderView(targetValue: $distanceValue)
                    
                    SectionHeader(title: "가격")
                    PriceRangeSliderView(lowerValue: $lowerPrice, upperValue: $upperPrice)
                    
                    PickerFilterSection(title: "영업시간") {
                        SegmentedPicker(
                            selectedOption: $isOpen,
                            options: [false, true],
                            format: { $0 ? "영업 중" : "전체" }
                        )
                    }
                    
                    PickerFilterSection(title: "리뷰") {
                        SegmentedPicker(
                            selectedOption: $hasReview,
                            options: [false, true],
                            format: { $0 ? "리뷰 있음" : "전체" }
                        )
                    }
                    
                    PickerFilterSection(title: "최소 평점") {
                        SegmentedPicker(
                            selectedOption: $minimumRating,
                            options: [0, 3.5, 4.0, 4.5],
                            format: { $0 == 0 ? "모두" : String(format: "%.1f", $0) }
                        )
                    }
                    
                    VStack(spacing: 14.5) {
                        SectionHeader(title: "카테고리")
                        CategoriesFlowLayout(items: categories, selected: $selectedCategories)
                    }
                    
                    Spacer(minLength: 88)
                }
            }
            .padding(.horizontal, 16)
            
            ZStack {
                Rectangle()
                    .fill(Color.white)
                    .frame(height: 77)
                    .shadow(color: Color.black.opacity(0.05), radius: 3, y: -1)
                    .zIndex(0)
                
                HStack {
                    Button("초기화") {
                        resetFilters()
                    }
                    .font(.custom("NanumSquareOTF", size: 16))
                    .frame(maxWidth: .infinity)
                    .frame(height: 38)
                    .background(Color("Grey3"))
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    
                    Button("적용") {
                        applyFilters()
                    }
                    .font(.custom("NanumSquareOTF", size: 16))
                    .frame(maxWidth: .infinity)
                    .frame(height: 38)
                    .background(Color("main"))
                    .foregroundColor(.white)
                    .cornerRadius(20)
                }
                .padding(EdgeInsets(top: 19, leading: 16, bottom: 20, trailing: 16))
                .background(Color.white)
                .zIndex(1)
            }
            
        }
    }
    
    func resetFilters() {
        distanceValue = maxDistance
        lowerPrice = 0
        upperPrice = maxPrice
        isOpen = false
        hasReview = false
        minimumRating = 0
        selectedCategories = ["전체"]
    }
    
    func applyFilters() {
        
        /*@State private var distanceValue: Double = 400
        @State private var lowerPrice: Double = 5000
        @State private var upperPrice: Double = 8000
        @State private var isOpen: Bool = false
        @State private var hasReview: Bool = false
        @State private var minimumRating: Double = 0.0
        @State private var selectedCategories: [String] = ["전체", "분식", "양식"]*/
        switch viewModelType {
        case .menu:
            menuViewModel.selectedFilters.distance = distanceValue < maxDistance ? Int(distanceValue) : nil
            menuViewModel.selectedFilters.priceRange = lowerPrice == 0 && upperPrice == maxPrice ? nil : Int(lowerPrice)...Int(upperPrice)
            menuViewModel.selectedFilters.minimumRating = minimumRating > 0 ? minimumRating : nil
            menuViewModel.selectedFilters.isOpen = isOpen ? true : nil
            menuViewModel.selectedFilters.hasReview = hasReview ? true : nil
            menuViewModel.selectedFilters.categories = selectedCategories.contains("전체") ? nil : selectedCategories
        case .favorite:
            favoriteViewModel.selectedFilters.distance = distanceValue < maxDistance ? Int(distanceValue) : nil
            favoriteViewModel.selectedFilters.priceRange = lowerPrice == 0 && upperPrice == maxPrice ? nil : Int(lowerPrice)...Int(upperPrice)
            favoriteViewModel.selectedFilters.minimumRating = minimumRating > 0 ? minimumRating : nil
            favoriteViewModel.selectedFilters.isOpen = isOpen ? true : nil
            favoriteViewModel.selectedFilters.hasReview = hasReview ? true : nil
            favoriteViewModel.selectedFilters.categories = selectedCategories.contains("전체") ? nil : selectedCategories
        }
        dismiss()
        print("Filters applied!")
    }
}

struct PickerFilterSection<Content: View>: View {
    let title: String
    let pickerView: Content
    
    init(title: String, @ViewBuilder pickerView: () -> Content) {
        self.title = title
        self.pickerView = pickerView()
    }
    
    var body: some View {
        VStack(spacing: 14.5) {
            SectionHeader(title: self.title)
            pickerView
                .padding(1)
        }
    }
}

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.custom("NanumSquareOTFEB", size: 16))
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct CategoryButton: View {
    let category: String
    let isSelected: Bool
    private let selectedBackground = Color(hex: 0xFFE8CE)
    
    var body: some View {
        RoundedRectangle(cornerRadius: 30)
            .stroke(isSelected ? Color("main") : Color("Grey2"))
            .frame(height: 34)
            .overlay(
                Text(category)
                    .font(.custom("NanumSquareOTF", size: 13))
                    .foregroundColor(.black)
            )
            .background(isSelected ? selectedBackground : .clear, in: RoundedRectangle(cornerRadius: 30))
    }
}

struct CategoriesFlowLayout: View {
    let items: [String]
    @Binding var selected: [String]
    
    private let spacing: CGFloat = 8
    private let itemWidth: CGFloat = 56
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                let maxColumns = Int((spacing + geometry.size.width) / (itemWidth + spacing))
                let columns = Array(repeating: GridItem(.fixed(itemWidth), spacing: spacing), count: maxColumns)
                LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
                    ForEach(items, id: \.self) { item in
                        CategoryButton(category: item, isSelected: selected.contains(item))
                            .onTapGesture {
                                if selected.contains(item) {
                                    selected = selected.filter{$0 != item}
                                } else {
                                    selected.append(item)
                                }
                            }
                    }
                }
            }
        }
        .padding(.horizontal, 1)

    }
}



struct MenuFilterView_Previews: PreviewProvider {
    struct ContainerView: View {
        @State private var showFilters: Bool = false
        
        var body: some View {
            Button(action: {
                self.showFilters = true
            }) {
                Text("button")
            }.sheet(isPresented: $showFilters, content: {
                MenuFilterView(menuViewModel: MenuViewModel())
            })
        }
    }
    static var previews: some View {
//                ContainerView()
        MenuFilterView(menuViewModel: MenuViewModel())
    }
    
}
