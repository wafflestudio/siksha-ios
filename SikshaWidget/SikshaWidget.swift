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
            configuration: ConfigurationAppIntent()
        )
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            restaurantName: "75-1동 4층 푸드코트",
            mealTime: .breakfast,
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
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let restaurantName: String
    let mealTime: MealTime
    let configuration: ConfigurationAppIntent
}

struct SikshaWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Text(entry.restaurantName)
                .lineLimit(1)
            Text("Time:")
            Text(entry.date, style: .time)

            Text("Favorite Emoji:")
            Text(entry.configuration.favoriteEmoji)
        }
    }
}

struct SikshaWidget: Widget {
    let kind: String = "SikshaWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            SikshaWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
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
                configuration: .smiley)
    SimpleEntry(date: .now,
                restaurantName: "75-1동 4층 푸드코트",
                mealTime: .breakfast,
                configuration: .starEyes)
}
