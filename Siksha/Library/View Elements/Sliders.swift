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
    let step: Double = 50
    private let orangeColor = Color("Orange500")
    private let sliderBackgroundColor: Color = Color("Gray200")
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                let targetX = position(for: targetValue, in: geometry)
                let sliderWidth = geometry.size.width
                
                ZStack {
                    Capsule()
                        .fill(sliderBackgroundColor)
                        .frame(height: 4)
                    
                    Capsule()
                        .fill(orangeColor)
                        .frame(width: targetX + sliderWidth / 2, height: 4)
                        .offset(x: (2 * targetX - sliderWidth) / 4)
                    
                    Circle()
                        .fill(orangeColor)
                        .frame(width: 18, height: 18)
                        .offset(x: targetX)
                        .gesture(
                            DragGesture()
                                .onChanged { val in
                                    let newValue = steppedValue(at: val.location.x - 12, in: geometry)
                                    targetValue = newValue
                                }
                        )
                    
                    SliderValueIndicator(text: distanceString, sliderWidth: sliderWidth, pointerOffset: targetX)
                        .offset(y: -31)
                }
            }
            .frame(height: 24)
        }
        .padding(.horizontal, 12)
    }
    
    private var distanceString: String {
        targetValue == maxValue ? "1km 이상" : "\(Int(targetValue))m 이내"
    }
    
    private func position(for value: Double, in geometry: GeometryProxy) -> CGFloat {
        let sliderWidth = geometry.size.width
        return sliderWidth * CGFloat((value - minValue) / (maxValue - minValue)) - sliderWidth / 2
    }
    
    private func steppedValue(at x: CGFloat, in geometry: GeometryProxy) -> Double {
        let rawValue = value(at: x, in: geometry)
        let steppedValue = (round(rawValue / step) * step)
        return min(max(steppedValue, minValue), maxValue)
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
    
    let minValue: Double = 2500
    let maxValue: Double = 10000
    let step: Double = 500
    private let orangeColor = Color("Orange500")
    private let sliderBackgroundColor: Color = Color("Gray200")
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                let lowerX = position(for: lowerValue, in: geometry)
                let upperX = position(for: upperValue, in: geometry)
                let centerX = (lowerX + upperX) / 2
                let sliderWidth = geometry.size.width
                
                ZStack {
                    Capsule()
                        .fill(sliderBackgroundColor)
                        .frame(height: 4)
                    
                    Capsule()
                        .fill(orangeColor)
                        .frame(width: upperX - lowerX, height: 4)
                        .offset(x: centerX)
                    
                    Circle()
                        .fill(orangeColor)
                        .frame(width: 18, height: 18)
                        .offset(x: lowerX)
                        .gesture(
                            DragGesture()
                                .onChanged { val in
                                    let newValue = steppedValue(at: val.location.x - 12, in: geometry)
                                    if newValue <= upperValue - step {
                                        lowerValue = newValue
                                    } else {
                                        lowerValue = upperValue - step
                                    }
                                }
                        )
                    
                    Circle()
                        .fill(orangeColor)
                        .frame(width: 18, height: 18)
                        .offset(x: upperX)
                        .gesture(
                            DragGesture()
                                .onChanged { val in
                                    let newValue = steppedValue(at: val.location.x - 12, in: geometry)
                                    if newValue >= lowerValue + step {
                                        upperValue = newValue
                                    } else {
                                        upperValue = lowerValue + step
                                    }
                                }
                        )
                    
                    SliderValueIndicator(text: priceRangeString, sliderWidth: sliderWidth, pointerOffset: centerX)
                        .offset(y: -31)
                }
            }
            .frame(height: 24)
        }
        .padding(.horizontal, 12)
    }
    
    private var priceRangeString: String {
        let lowerPriceStr = lowerValue == minValue ? "0원" : formatPrice(lowerValue)
        let upperPriceStr = upperValue == maxValue ? "\(formatPrice(maxValue)) 이상" : formatPrice(upperValue)
        return "\(lowerPriceStr) ~ \(upperPriceStr)"
    }
    
    func formatPrice(_ price: Double) -> String {
        let intPrice = Int(price)
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return (numberFormatter.string(from: NSNumber(value: intPrice)) ?? "\(intPrice)") + "원"
    }
    
    private func position(for value: Double, in geometry: GeometryProxy) -> CGFloat {
        let sliderWidth = geometry.size.width
        return sliderWidth * CGFloat((value - minValue) / (maxValue - minValue)) - sliderWidth / 2
    }
    
    private func steppedValue(at x: CGFloat, in geometry: GeometryProxy) -> Double {
        let rawValue = value(at: x, in: geometry)
        let steppedValue = (round(rawValue / step) * step)
        return min(max(steppedValue, minValue), maxValue)
    }
    
    private func value(at x: CGFloat, in geometry: GeometryProxy) -> Double {
        let sliderWidth = geometry.size.width
        let percentage = min(max((x + sliderWidth / 2) / sliderWidth, 0), 1)
        return (minValue + (maxValue - minValue) * Double(percentage))
    }
}

struct SliderValueIndicator: View {
    let text: String
    let sliderWidth: CGFloat
    let pointerOffset: CGFloat
    
    private let backgroundColor: Color = Color("Gray100")
    private let fontColor: Color = Color("Gray700")
    
    @State private var boxWidth: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 0) {
            Text(text)
                .font(.custom("NanumSquareOTFB", size: 12))
                .foregroundStyle(fontColor)
                .padding(6)
                .background(RoundedRectangle(cornerRadius: 2)
                    .fill(backgroundColor))
                .background(GeometryReader { proxy in
                    Color.clear
                        .preference(key: BubbleWidthKey.self, value: proxy.size.width)
                })
                .offset(x: adjustedXOffset)
            
            BubblePointer()
                .fill(backgroundColor)
                .frame(width: 10, height: 5)
                .offset(x: pointerOffset)
        }
        .onPreferenceChange(BubbleWidthKey.self) { newWidth in
            boxWidth = newWidth
        }
    }
    
    private var adjustedXOffset: CGFloat {
        let sliderHandleRadius: CGFloat = 12
        let minX = (boxWidth - sliderWidth) / 2 - sliderHandleRadius
        let maxX = (sliderWidth - boxWidth) / 2 + sliderHandleRadius
        return max(minX, min(pointerOffset, maxX))
    }
}

struct BubblePointer: Shape {
    var cornerRadius: CGFloat = 1.0
    
    func path(in rect: CGRect) -> Path {
        let path = CGMutablePath()
        let bottomY = rect.maxY
        let topY = rect.minY
        
        path.move(to: CGPoint(x: rect.midX - cornerRadius, y: bottomY - cornerRadius))
        path.addArc(tangent1End: CGPoint(x: rect.minX + cornerRadius, y: topY),
                    tangent2End: CGPoint(x: rect.minX, y: topY),
                    radius: cornerRadius)
        path.addLine(to: CGPoint(x: rect.maxX, y: topY))
        path.addArc(tangent1End: CGPoint(x: rect.maxX - cornerRadius, y: topY),
                    tangent2End: CGPoint(x: rect.midX + cornerRadius, y: bottomY - cornerRadius),
                    radius: cornerRadius)
        path.addLine(to: CGPoint(x: rect.midX + cornerRadius, y: bottomY - cornerRadius))
        path.addArc(tangent1End: CGPoint(x: rect.midX, y: bottomY),
                    tangent2End: CGPoint(x: rect.midX - cornerRadius, y: bottomY - cornerRadius),
                    radius: cornerRadius)
        
        return Path(path)
    }
}

struct BubbleWidthKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct RangeSlider_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
    }
    
    struct PreviewWrapper: View {
        @State private var lowerValue: Double = 5000
        @State private var upperValue: Double = 6000
        @State private var targetDistance: Double = 400
        var body: some View {
            VStack(spacing: 60) {
                DistanceSliderView(targetValue: $targetDistance)
                PriceRangeSliderView(lowerValue: $lowerValue, upperValue: $upperValue)
            }
        }
    }
}
