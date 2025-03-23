//
//  MenuFilterView.swift
//  Siksha
//
//  Created by 권현구 on 1/26/25.
//

import SwiftUI
import CoreLocation

public enum MenuFilterType {
    case all
    case distance
    case price
    case minimumRating
    case category
    
    var modalSheetHeight: CGFloat {
        switch self {
        case .all:
            return 727 - 17
        case .distance, .price, .category:
            return 259 - 17
        case .minimumRating:
            return 211 - 17
        }
    }
}

class MenuFilterViewModel: ObservableObject {
    @Published var distanceValue: Double = 1000
    @Published var lowerPrice: Double = 2500
    @Published var upperPrice: Double = 10000
    @Published var isOpen: Bool = false
    @Published var hasReview: Bool = false
    @Published var minimumRating: Float = 0.0
    @Published var selectedCategories: [String] = []
}

struct MenuFilterView: View {
    @ObservedObject var menuViewModel: MenuViewModel
    @ObservedObject var menuFilterViewModel = MenuFilterViewModel()
    @Environment(\.dismiss) var dismiss
    @State var isDistanceAlertPresented = false
    let ratings = [3.5, 4.0, 4.5]
    let categories = ["한식", "중식", "분식", "일식", "양식", "아시안", "뷔페"]
    let maxPrice = 10000.0
    let minPrice = 2500.0
    let maxDistance = 1000.0
    
    var menuFilterType: MenuFilterType
    
    // menuViewModel 사용
    init(menuViewModel: MenuViewModel, menuFilterType: MenuFilterType) {
        self.menuViewModel = menuViewModel
        self.menuFilterType = menuFilterType
        if let distanceValue = menuViewModel.selectedFilters.distance {
            menuFilterViewModel.distanceValue = Double(distanceValue)
        }
        if let lowerPrice = menuViewModel.selectedFilters.priceRange?.lowerBound {
            menuFilterViewModel.lowerPrice = lowerPrice == 0 ? minPrice : Double(lowerPrice)
        }
        if let upperPrice = menuViewModel.selectedFilters.priceRange?.upperBound {
            menuFilterViewModel.upperPrice = Double(upperPrice)
        }
        if let isOpen = menuViewModel.selectedFilters.isOpen {
            menuFilterViewModel.isOpen = isOpen
        }
        if let hasReivew = menuViewModel.selectedFilters.hasReview {
            menuFilterViewModel.hasReview = hasReivew
        }
        if let minimumRating = menuViewModel.selectedFilters.minimumRating {
            menuFilterViewModel.minimumRating = minimumRating
        }
        if let selectedCategories = menuViewModel.selectedFilters.categories {
            menuFilterViewModel.selectedCategories = selectedCategories
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            switch menuFilterType {
            case .all:
                Capsule()
                    .fill(Color.secondary)
                    .opacity(0.5)
                    .frame(width: 42, height: 4)
                    .padding(.vertical, 17)
                
                Text("필터")
                    .font(.custom("NanumSquareOTFB", size: 14))
                    .padding(EdgeInsets(top: 1.32, leading: 0, bottom: 13.68, trailing: 0))
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 40) {
                        SectionHeader(title: "거리")
                        DistanceSliderView(targetValue: $menuFilterViewModel.distanceValue)
                        
                        SectionHeader(title: "가격")
                        PriceRangeSliderView(lowerValue: $menuFilterViewModel.lowerPrice, upperValue: $menuFilterViewModel.upperPrice)
                        
                        PickerFilterSection(title: "영업시간") {
                            SegmentedPicker(
                                selectedOption: $menuFilterViewModel.isOpen,
                                options: [false, true],
                                format: { $0 ? "영업 중" : "전체" },
                                isRateFilter: false
                            )
                        }
                        
                        PickerFilterSection(title: "리뷰") {
                            SegmentedPicker(
                                selectedOption: $menuFilterViewModel.hasReview,
                                options: [false, true],
                                format: { $0 ? "리뷰 있음" : "전체" },
                                isRateFilter: false
                            )
                        }
                        
                        PickerFilterSection(title: "최소 평점") {
                            SegmentedPicker(
                                selectedOption: $menuFilterViewModel.minimumRating,
                                options: [0, 3.5, 4.0, 4.5],
                                format: { $0 == 0 ? "모두" : String(format: "%.1f", $0) },
                                isRateFilter: true
                            )
                        }
                        
//                        VStack(spacing: 14.5) {
//                            SectionHeader(title: "카테고리")
//                            CategoriesFlowLayout(items: categories, selected: $menuFilterViewModel.selectedCategories)
//                        }
                        
                        // bottom padding
                        Rectangle()
                            .frame(height: 88)
                            .opacity(0)
                    }
                }
                .padding(.horizontal, 16)
            case .distance:
                VStack(spacing: 0) {
                    SectionHeader(title: "거리")
                    Spacer()
                    DistanceSliderView(targetValue: $menuFilterViewModel.distanceValue)
                }
                .padding(EdgeInsets(top: 16, leading: 16, bottom: 58, trailing: 16))
            case .price:
                VStack(spacing: 0) {
                    SectionHeader(title: "가격")
                    Spacer()
                    PriceRangeSliderView(lowerValue: $menuFilterViewModel.lowerPrice, upperValue: $menuFilterViewModel.upperPrice)
                }
                .padding(EdgeInsets(top: 16, leading: 16, bottom: 58, trailing: 16))
            case .minimumRating:
                PickerFilterSection(title: "최소 평점") {
                    VStack(spacing: 0) {
                        SegmentedPicker(
                            selectedOption: $menuFilterViewModel.minimumRating,
                            options: [0, 3.5, 4.0, 4.5],
                            format: { $0 == 0 ? "모두" : String(format: "%.1f", $0) },
                            isRateFilter: true
                        )
                        Spacer()
                    }
                }
                .padding(EdgeInsets(top: 16, leading: 16, bottom: 0, trailing: 16))
            case .category:
                VStack(spacing: 0) {
                    SectionHeader(title: "카테고리")
                    Spacer()
                    CategoriesFlowLayout(items: categories, selected: $menuFilterViewModel.selectedCategories)
                }
                .padding(EdgeInsets(top: 16, leading: 16, bottom: 36, trailing: 16))
            }
            
            ZStack {
                if menuFilterType == .all {
                    Rectangle()
                        .fill(Color.white)
                        .frame(height: 77)
                        .shadow(color: Color.black.opacity(0.05), radius: 3, y: -1)
                        .zIndex(0)                    
                }
                
                HStack {
                    Text("초기화")
                        .font(.custom("NanumSquareOTFB", size: 16))
                        .frame(maxWidth: .infinity)
                        .frame(height: 38)
                        .foregroundStyle(.white)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color("Grey3"))
                        )
                        .onTapGesture {
                            resetFilters()
                        }
                    
                    Text("적용")
                        .font(.custom("NanumSquareOTFB", size: 16))
                        .frame(maxWidth: .infinity)
                        .frame(height: 38)
                        .foregroundStyle(.white)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color("main"))
                        )
                        .onTapGesture {
                            applyFilters()
                        }
                }
                .padding(EdgeInsets(top: 19, leading: 16, bottom: 20, trailing: 16))
                .background(Color.white)
                .zIndex(1)
            }
        }
        .alert("위치 서비스 사용", isPresented: $isDistanceAlertPresented, actions: {
            Button("취소") {}
            Button("설정으로 이동") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        }, message: {
            Text("거리 필터를 사용하기 위해 위치서비스 사용이 필요합니다.\n 설정에서 위치서비스를 켜주세요.")
        })
    }
    
    func resetFilters() {
        switch menuFilterType {
        case .all:
            menuFilterViewModel.distanceValue = maxDistance
            menuFilterViewModel.lowerPrice = minPrice
            menuFilterViewModel.upperPrice = maxPrice
            menuFilterViewModel.isOpen = false
            menuFilterViewModel.hasReview = false
            menuFilterViewModel.minimumRating = 0
            menuFilterViewModel.selectedCategories = []
        case .distance:
            menuFilterViewModel.distanceValue = maxDistance
        case .price:
            menuFilterViewModel.lowerPrice = minPrice
            menuFilterViewModel.upperPrice = maxPrice
        case .minimumRating:
            menuFilterViewModel.minimumRating = 0
        case .category:
            menuFilterViewModel.selectedCategories = []
        }
        
    }
    
    func applyFilters() {
        
        // 거리 설정 시 위치 권한 확인
        if menuFilterViewModel.distanceValue < maxDistance {
            let locationManager = CLLocationManager()
            
            switch locationManager.authorizationStatus {
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
                return
            case .restricted:
                DispatchQueue.main.async { self.isDistanceAlertPresented = true }
                return
            case .denied:
                DispatchQueue.main.async { self.isDistanceAlertPresented = true }
                return
            case .authorizedAlways, .authorizedWhenInUse:
                break
            }
        }
        
        switch menuFilterType {
            /// 거리만, 가격만 필터 선택 시 다른 필터 바뀌는 거 방지
        case .distance:
            menuViewModel.selectedFilters.distance = menuFilterViewModel.distanceValue < maxDistance ? Int(menuFilterViewModel.distanceValue) : nil
        case .price:
            if menuFilterViewModel.lowerPrice == minPrice && menuFilterViewModel.upperPrice == maxPrice {
                menuViewModel.selectedFilters.priceRange = nil
            } else {
                let lowerPrice = menuFilterViewModel.lowerPrice == minPrice ? 0 : menuFilterViewModel.lowerPrice
                menuViewModel.selectedFilters.priceRange = Int(lowerPrice)...Int(menuFilterViewModel.upperPrice)
            }
        default:
            menuViewModel.selectedFilters.distance = menuFilterViewModel.distanceValue < maxDistance ? Int(menuFilterViewModel.distanceValue) : nil
            if menuFilterViewModel.lowerPrice == minPrice && menuFilterViewModel.upperPrice == maxPrice {
                menuViewModel.selectedFilters.priceRange = nil
            } else {
                let lowerPrice = menuFilterViewModel.lowerPrice == minPrice ? 0 : menuFilterViewModel.lowerPrice
                menuViewModel.selectedFilters.priceRange = Int(lowerPrice)...Int(menuFilterViewModel.upperPrice)
            }
            menuViewModel.selectedFilters.minimumRating = menuFilterViewModel.minimumRating > 0 ? menuFilterViewModel.minimumRating : nil
            menuViewModel.selectedFilters.isOpen = menuFilterViewModel.isOpen ? true : nil
            menuViewModel.selectedFilters.hasReview = menuFilterViewModel.hasReview ? true : nil
            menuViewModel.selectedFilters.categories = menuFilterViewModel.selectedCategories.isEmpty ? nil : menuFilterViewModel.selectedCategories
        }
        menuViewModel.saveFilters()
        
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
            .frame(height: 27.5)
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
                    .font(.custom("NanumSquareOTFB", size: 13))
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
                    CategoryButton(category: "전체", isSelected: selected.isEmpty)
                        .onTapGesture {
                            selected = []
                        }
                    
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

//struct MenuFilterView_Previews: PreviewProvider {
//    struct ContainerView: View {
//        @State private var showFilters: Bool = false
//
//        var body: some View {
//            Button(action: {
//                self.showFilters = true
//            }) {
//                Text("button")
//            }.sheet(isPresented: $showFilters, content: {
//
//                MenuFilterView(menuViewModel: MenuViewModel())
//            })
//        }
//    }
//    static var previews: some View {
//        MenuFilterView(menuViewModel: MenuViewModel())
//    }
//}
