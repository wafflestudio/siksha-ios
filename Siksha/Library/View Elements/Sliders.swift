//
//  Sliders.swift
//  Siksha
//
//  Created by 권현구 on 1/31/25.
//

import SwiftUI

struct DistanceSliderView: View {
    @Binding var targetValue: Double
    let minValue: Double = 200
    let maxValue: Double = 1000
    private let orangeColor = Color("main")
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                let targetX = position(for: targetValue, in: geometry)
                let sliderWidth = geometry.size.width
                
                ZStack {
                    Capsule()
                        .fill(Color("Grey4"))
                        .frame(height: 4)
                    
                    Capsule()
                        .fill(orangeColor)
                        .frame(width: targetX + sliderWidth / 2, height: 4)
                        .offset(x: (2 * targetX - sliderWidth) / 4)
                    
                    Circle()
                        .fill(orangeColor)
                        .frame(width: 24, height: 24)
                        .offset(x: targetX)
                        .gesture(
                            DragGesture()
                                .onChanged { val in
                                    let newValue = value(at: val.location.x - 12, in: geometry)
                                    targetValue = newValue
                                }
                        )
                }
                .overlay(
                    Text("\(Int(targetValue))m 이내")
                        .font(.custom("NanumSquareOTF", size: 12))
                        .foregroundStyle(Color(hex: 0x707070, opacity: 1))
                        .padding(6)
                        .background(Color("Grey0.5"))
                        .cornerRadius(1)
                        .offset(x: targetX, y: -36)
                    , alignment: .top
                )
            }
            .frame(height: 24)
        }
        .padding(.horizontal, 12)
    }
    
    private func position(for value: Double, in geometry: GeometryProxy) -> CGFloat {
        let sliderWidth = geometry.size.width
        return sliderWidth * CGFloat((value - minValue) / (maxValue - minValue)) - sliderWidth / 2
    }
    
    private func value(at x: CGFloat, in geometry: GeometryProxy) -> Double {
        let sliderWidth = geometry.size.width
        let percentage = min(max((x + sliderWidth / 2) / sliderWidth, 0), 1)
        return (minValue + (maxValue - minValue) * Double(percentage))
    }
}

struct PriceRangeSliderView: View {
    @Binding var lowerValue: Double
    @Binding var upperValue: Double
    
    let minValue: Double = 0
    let maxValue: Double = 15000
    private let orangeColor = Color("main")
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                let lowerX = position(for: lowerValue, in: geometry)
                let upperX = position(for: upperValue, in: geometry)
                let centerX = (lowerX + upperX) / 2
                
                ZStack {
                    Capsule()
                        .fill(Color("Grey4"))
                        .frame(height: 4)
                    
                    Capsule()
                        .fill(orangeColor)
                        .frame(width: upperX - lowerX, height: 4)
                        .offset(x: centerX)
                    
                    Circle()
                        .fill(orangeColor)
                        .frame(width: 24, height: 24)
                        .offset(x: lowerX)
                        .gesture(
                            DragGesture()
                                .onChanged { val in
                                    let newValue = value(at: val.location.x - 12, in: geometry)
                                    if newValue < upperValue {
                                        lowerValue = newValue
                                    }
                                }
                        )
                    
                    Circle()
                        .fill(orangeColor)
                        .frame(width: 24, height: 24)
                        .offset(x: upperX)
                        .gesture(
                            DragGesture()
                                .onChanged { val in
                                    let newValue = value(at: val.location.x - 12, in: geometry)
                                    if newValue > lowerValue {
                                        upperValue = newValue
                                    }
                                }
                        )
                }
                .overlay(
                    Text("\(Int(lowerValue))원 ~ \(Int(upperValue))원")
                        .font(.custom("NanumSquareOTF", size: 12))
                        .foregroundStyle(Color(hex: 0x707070))
                        .padding(6)
                        .background(Color("Grey0.5"))
                        .cornerRadius(1)
                        .offset(x: centerX, y: -36)
                    , alignment: .top
                )
            }
            .frame(height: 24)
        }
        .padding(.horizontal, 12)
    }
    
    private func position(for value: Double, in geometry: GeometryProxy) -> CGFloat {
        let sliderWidth = geometry.size.width
        return sliderWidth * CGFloat((value - minValue) / (maxValue - minValue)) - sliderWidth / 2
    }
    
    private func value(at x: CGFloat, in geometry: GeometryProxy) -> Double {
        let sliderWidth = geometry.size.width
        let percentage = min(max((x + sliderWidth / 2) / sliderWidth, 0), 1)
        return (minValue + (maxValue - minValue) * Double(percentage))
    }
}

struct RangeSlider_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
    }
    
    struct PreviewWrapper: View {
        @State private var lowerValue: Double = 2000
        @State private var upperValue: Double = 8000
        @State private var targetDistance: Double = 400
        var body: some View {
            VStack(spacing: 60) {
                DistanceSliderView(targetValue: $targetDistance)
                PriceRangeSliderView(lowerValue: $lowerValue, upperValue: $upperValue)
            }
        }
    }
}
