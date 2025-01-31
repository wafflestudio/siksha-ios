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
    @State private var minimumRating: Double = 0.0
    @State private var selectedCategory: String = "전체"
    
    let ratings = [3.5, 4.0, 4.5]
    let categories = ["전체", "한식", "중식", "분식", "일식", "양식", "아시안", "뷔페"]
    
    var body: some View {
        VStack(spacing: 0) {
            // Handle
            Capsule()
                .fill(Color.secondary)
                .opacity(0.5)
                .frame(width: 42, height: 4)
                .padding(.vertical, 17)
            
            // Header
            Text("필터")
                .font(.custom("NanumSquareOTFB", size: 14))
                .padding(EdgeInsets(top: 1.32, leading: 0, bottom: 13.68, trailing: 0))
            
            // Sections
            ScrollView {
                VStack(spacing: 40) {
                    // Distance Section
                    //                    SectionHeader(title: "거리")
                    //                    SliderView(label: "\(Int(distanceValue))m 이내", value: $distanceValue, range: 0...1000)
                    
                    // Price Section
                    //                    SectionHeader(title: "가격")
                    //                    RangeSliderView(label: "\(Int(lowerPrice))원 ~ \(Int(upperPrice))원",
                    //                                    lowerValue: $lowerPrice,
                    //                                    upperValue: $upperPrice,
                    //                                    bounds: 0...20000)
                    
                    // Operating Hours Section
                    PickerFilterSection(title: "영업시간") {
                        SegmentedPicker(
                            selectedOption: $isOpen,
                            options: [false, true],
                            format: { $0 ? "영업 중" : "전체" }
                        )
                    }
                    
                    // Reviews Section
                    PickerFilterSection(title: "리뷰") {
                        SegmentedPicker(
                            selectedOption: $hasReview,
                            options: [false, true],
                            format: { $0 ? "리뷰 있음" : "전체" }
                        )
                    }
                    
                    // Minimum Rating Section
                    PickerFilterSection(title: "최소 평점") {
                        SegmentedPicker(
                            selectedOption: $minimumRating,
                            options: [0, 3.5, 4.0, 4.5],
                            format: { $0 == 0 ? "모두" : String(format: "%.1f", $0) }
                        )
                    }
                    
                    // Category Section
                    //                    SectionHeader(title: "카테고리")
                    //                    FlowLayout(items: categories, selected: $selectedCategory)
                }
            }
            
            Divider()
            
            // Bottom Buttons
            HStack {
                Button("초기화") {
                    resetFilters()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.7))
                .foregroundColor(.white)
                .cornerRadius(8)
                
                Button("적용") {
                    applyFilters()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .padding(.horizontal, 16)
        .navigationTitle("title")
    }
    
    // Reset Filters
    func resetFilters() {
        distanceValue = 400
        lowerPrice = 5000
        upperPrice = 8000
        //        priceRange = 5000...8000
        isOpen = true
        hasReview = true
        minimumRating = 4.0
        selectedCategory = "전체"
    }
    
    // Apply Filters
    func applyFilters() {
        print("Filters applied!")
    }
}

// MARK: - Components

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

// Section Header
struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.custom("NanumSquareOTFEB", size: 16))
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// Slider View
struct SliderView: View {
    let label: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    
    var body: some View {
        VStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
            Slider(value: $value, in: range)
                .foregroundColor(.orange)
        }
        .tint(Color("Grey4"))
    }
}

// Range Slider View
struct RangeSliderView: View {
    let label: String
    @Binding var lowerValue: Double
    @Binding var upperValue: Double
    let bounds: ClosedRange<Double>
    
    var body: some View {
        VStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
            RangeSlider(lowerValue: $lowerValue, upperValue: $upperValue, bounds: bounds)
        }
        .padding(.horizontal)
    }
}

// Flow Layout for Categories
struct FlowLayout: View {
    let items: [String]
    @Binding var selected: String
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 10)], spacing: 10) {
            ForEach(items, id: \.self) { item in
                Button(item) {
                    selected = item
                }
                .padding(8)
                .background(selected == item ? Color.orange : Color.gray.opacity(0.2))
                .foregroundColor(selected == item ? .white : .black)
                .cornerRadius(8)
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Range Slider Component
struct RangeSlider: View {
    @Binding var lowerValue: Double
    @Binding var upperValue: Double
    let bounds: ClosedRange<Double>
    
    var body: some View {
        VStack {
            HStack {
                Slider(value: $lowerValue, in: bounds.lowerBound...upperValue, step: 100)
                Slider(value: $upperValue, in: lowerValue...bounds.upperBound, step: 100)
            }
        }
    }
}

struct MenuFilterView_Previews: PreviewProvider {
    struct ContainerView: View {
        @State private var showFilters: Bool = false
        
        var body: some View {
            Button(action: {
                print("clicked")
                self.showFilters = true
            }) {
                Text("button")
            }.sheet(isPresented: $showFilters, content: {
                MenuFilterView()
            })
        }
    }
    static var previews: some View {
        //        ContainerView()
        MenuFilterView()
    }
    
}
