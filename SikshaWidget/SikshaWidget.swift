//
//  SikshaWidget.swift
//  SikshaWidget
//
//  Created by Jihyeon on 2/12/26.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            restaurantName: "75-1동 4층 푸드코트",
            mealTime: .breakfast,
            menus: [],
            configuration: ConfigurationAppIntent()
        )
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            restaurantName: "75-1동 4층 푸드코트",
            mealTime: .breakfast,
            menus: [],
            configuration: configuration
        )
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(
                date: entryDate,
                restaurantName: "75-1동 4층 푸드코트",
                mealTime: .breakfast,
                menus: [],
                configuration: configuration
            )
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .atEnd)
    }

//    func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

enum MealTime {
    case breakfast
    case lunch
    case dinner
    
    var imageName: String {
        switch self {
            case .breakfast: return "BreakfastTime"
            case .lunch: return "LunchTime"
            case .dinner: return "DinnerTime"
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let restaurantName: String
    let mealTime: MealTime
    let menus: [String]
    let configuration: ConfigurationAppIntent
}

struct SikshaWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 6) {
                Text(entry.restaurantName)
                    .customFont(font: .text13(weight: .ExtraBold))
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Image(entry.mealTime.imageName)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(Color.orange500)
                    .frame(width: 20, height: 20)
            }
            
            Spacer()
                .frame(height: 4)
            
            Rectangle()
                .fill(Color.orange500)
                .frame(height: 1)
            
            if entry.menus.isEmpty {
                VStack(spacing: 0) {
                    Spacer()
                    Text("등록된 메뉴가 없어요")
                        .customFont(font: .text12(weight: .Regular))
                        .foregroundStyle(Color.gray600)
                    Spacer()
                }
            } else {
                VStack(spacing: 8) {
                    ForEach(0..<4) {
                        if entry.menus.count > $0 {
                            Text(entry.menus[$0])
                                .lineLimit(1)
                                .customFont(font: .text12(weight: .Regular))
                                .foregroundStyle(Color.gray900)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .padding(.top, 10)
                
                Spacer(minLength: 0)
            }
            
            Spacer(minLength: 0)
        }
    }
}

struct SikshaWidget: Widget {
    let kind: String = "SikshaWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            SikshaWidgetEntryView(entry: entry)
                .containerBackground(Color.whiteColor, for: .widget)
                .padding(14)
        }
        .contentMarginsDisabled()
    }
}

extension ConfigurationAppIntent {
    fileprivate static var smiley: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "😀"
        return intent
    }
    
    fileprivate static var starEyes: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "🤩"
        return intent
    }
}

#Preview(as: .systemSmall) {
    SikshaWidget()
} timeline: {
    SimpleEntry(date: .now,
                restaurantName: "75-1동 4층 푸드코트",
                mealTime: .breakfast,
                menus: [],
                configuration: .smiley)
    SimpleEntry(date: .now,
                restaurantName: "75-1동 4층 푸드코트",
                mealTime: .dinner,
                menus: ["1인 목살스테이크 샐러드", "치즈미트토마토파스타", "김치 필라프", "뚝배기불고기+비빔밥+김치필라프"],
                configuration: .starEyes)
}
