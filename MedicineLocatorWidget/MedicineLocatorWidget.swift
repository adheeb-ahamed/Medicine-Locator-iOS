//
//  MedicineLocatorWidget.swift
//  MedicineLocatorWidget
//

import WidgetKit
import SwiftUI

// MARK: - Colours (the widget can't see the app's Theme file)

private let teal = Color(red: 0x0E / 255, green: 0x8C / 255, blue: 0x88 / 255)
private let darkTeal = Color(red: 0x05 / 255, green: 0x48 / 255, blue: 0x45 / 255)

/// Sample numbers for the widget gallery and Xcode previews.
extension RequestsSummary {
    static let preview = RequestsSummary(activeCount: 2, answerCount: 3,
                                         medicineNames: [], updatedAt: .now)
}

// MARK: - Entry = what the widget shows at one moment

struct RequestsEntry: TimelineEntry {
    let date: Date
    let summary: RequestsSummary?     // nil = the app hasn't saved anything yet
}

// MARK: - Provider = tells iOS what to show

struct RequestsProvider: TimelineProvider {

    /// Grey "loading" version while iOS draws the widget for the first time.
    func placeholder(in context: Context) -> RequestsEntry {
        RequestsEntry(date: .now, summary: .preview)
    }

    /// One-off picture, e.g. in the "Add Widget" gallery.
    func getSnapshot(in context: Context, completion: @escaping (RequestsEntry) -> Void) {
        if context.isPreview {
            completion(RequestsEntry(date: .now, summary: .preview))      // gallery: sample numbers
        } else {
            completion(RequestsEntry(date: .now, summary: RequestsSummaryStore().load()))
        }
    }

    /// The real data. .never = don't refresh on a timer;
    /// the app calls reloadTimelines() whenever the numbers change (Step 3).
    func getTimeline(in context: Context, completion: @escaping (Timeline<RequestsEntry>) -> Void) {
        let entry = RequestsEntry(date: .now, summary: RequestsSummaryStore().load())
        completion(Timeline(entries: [entry], policy: .never))
    }
}

// MARK: - Views

struct RequestsWidgetView: View {
    @Environment(\.widgetFamily) private var family    // which size the user picked
    let entry: RequestsEntry

    var body: some View {
        switch family {
        case .accessoryCircular:    circular
        case .accessoryRectangular: rectangular
        case .systemMedium:         medium
        default:                    small
        }
    }

    // Home Screen — small: big answer count
    private var small: some View {
        VStack(alignment: .leading, spacing: 2) {
            header
            Spacer(minLength: 0)
            numbers
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .widgetURL(URL(string: "medicinelocator://requests"))      // tap anywhere → My Requests
    }

    // Home Screen — medium: numbers + two buttons
    private var medium: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 2) {
                header
                Spacer(minLength: 0)
                numbers
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 8) {
                // Link = a button inside a medium widget (each opens a different place)
                Link(destination: URL(string: "medicinelocator://requests")!) {
                    pill("My requests", systemImage: "tray.full")
                }
                Link(destination: URL(string: "medicinelocator://home")!) {
                    pill("Find medicine", systemImage: "magnifyingglass")
                }
            }
        }
        .foregroundStyle(.white)
    }

    // Lock Screen — circle: answer count
    private var circular: some View {
        ZStack {
            AccessoryWidgetBackground()                // the standard grey Lock Screen circle
            VStack(spacing: 0) {
                Image(systemName: "tray.full").font(.caption2)
                Text("\(entry.summary?.answerCount ?? 0)")
                    .font(.system(.title3, design: .rounded, weight: .black))
            }
        }
        .widgetURL(URL(string: "medicinelocator://requests"))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spokenSummary)
    }

    // Lock Screen — rectangle: one line of text
    private var rectangular: some View {
        VStack(alignment: .leading, spacing: 2) {
            Label("Medicine Locator", systemImage: "cross.case.fill")
                .font(.caption.weight(.bold))
            if let summary = entry.summary {
                Text("\(summary.activeCount) open · \(summary.answerCount) answers")
                    .font(.headline)
            } else {
                Text("Open the app to start").font(.caption)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .widgetURL(URL(string: "medicinelocator://requests"))
        .accessibilityElement(children: .combine)
    }

    // MARK: Pieces

    private var header: some View {
        Label("Medicine Locator", systemImage: "cross.case.fill")
            .font(.caption2.weight(.bold))
            .foregroundStyle(.white.opacity(0.85))
    }

    @ViewBuilder
    private var numbers: some View {
        if let summary = entry.summary {
            Text("\(summary.answerCount)")
                .font(.system(.largeTitle, design: .rounded, weight: .black))
            Text(summary.answerCount == 1 ? "answer" : "answers")
                .font(.caption.weight(.semibold))
            // style: .relative keeps counting up by itself ("5 min", "6 min"…)
            Text("\(summary.activeCount) open · \(summary.updatedAt, style: .relative) ago")
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.8))
        } else {
            Text("Open the app to see your requests")
                .font(.caption.weight(.semibold))
        }
    }

    private func pill(_ title: String, systemImage: String) -> some View {
        Label(title, systemImage: systemImage)
            .font(.caption.weight(.bold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(.white.opacity(0.18), in: Capsule())
    }

    /// One sentence for VoiceOver on the Lock Screen circle.
    private var spokenSummary: String {
        guard let summary = entry.summary else { return "Medicine Locator. Open the app to start." }
        return "Medicine Locator. \(summary.activeCount) open requests, \(summary.answerCount) answers."
    }
}

// MARK: - The widget itself

struct MedicineLocatorWidget: Widget {
    let kind = RequestsSummaryStore.widgetKind      // same id the app uses to refresh it

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: RequestsProvider()) { entry in
            RequestsWidgetView(entry: entry)
                // Required since iOS 17. On the Lock Screen iOS removes it automatically.
                .containerBackground(for: .widget) {
                    LinearGradient(colors: [teal, darkTeal], startPoint: .top, endPoint: .bottom)
                }
        }
        .configurationDisplayName("My Requests")
        .description("Open requests and answers. Medicine names are never shown.")
        .supportedFamilies([.systemSmall, .systemMedium,
                            .accessoryCircular, .accessoryRectangular])
    }
}

// MARK: - Previews (Xcode canvas)

#Preview(as: .systemSmall) {
    MedicineLocatorWidget()
} timeline: {
    RequestsEntry(date: .now, summary: .preview)
    RequestsEntry(date: .now, summary: nil)          // fresh install
}

#Preview(as: .systemMedium) {
    MedicineLocatorWidget()
} timeline: {
    RequestsEntry(date: .now, summary: .preview)
}
