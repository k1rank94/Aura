import AppIntents
import SwiftUI
import WidgetKit

private struct WidgetSnapshot: Codable {
    let openToday: Int
    let completedToday: Int
    let nextTaskTitle: String?
    let updatedAt: Date

    static let empty = WidgetSnapshot(openToday: 0, completedToday: 0, nextTaskTitle: nil, updatedAt: .now)
}

private struct AuraWidgetEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetSnapshot
}

private struct AuraWidgetProvider: TimelineProvider {
    private let appGroup = "group.com.kiran.Aura"
    private let snapshotKey = "aura.widget.snapshot"

    func placeholder(in context: Context) -> AuraWidgetEntry {
        AuraWidgetEntry(
            date: .now,
            snapshot: WidgetSnapshot(
                openToday: 3,
                completedToday: 2,
                nextTaskTitle: "Shape one meaningful thing",
                updatedAt: .now
            )
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (AuraWidgetEntry) -> Void) {
        completion(AuraWidgetEntry(date: .now, snapshot: loadSnapshot()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<AuraWidgetEntry>) -> Void) {
        let entry = AuraWidgetEntry(date: .now, snapshot: loadSnapshot())
        let refresh = Calendar.current.date(byAdding: .minute, value: 30, to: .now) ?? .now
        completion(Timeline(entries: [entry], policy: .after(refresh)))
    }

    private func loadSnapshot() -> WidgetSnapshot {
        guard
            let data = UserDefaults(suiteName: appGroup)?.data(forKey: snapshotKey),
            let snapshot = try? JSONDecoder().decode(WidgetSnapshot.self, from: data)
        else {
            return .empty
        }
        return snapshot
    }
}

private struct OpenAuraIntent: AppIntent {
    static let title: LocalizedStringResource = "Open Aura"
    static let openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        .result()
    }
}

private struct AuraWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: AuraWidgetEntry

    private var total: Int {
        entry.snapshot.openToday + entry.snapshot.completedToday
    }

    private var progress: Double {
        guard total > 0 else { return 0 }
        return Double(entry.snapshot.completedToday) / Double(total)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("AURA", systemImage: "sparkles")
                    .font(.caption2.weight(.black))
                    .tracking(1.2)
                Spacer()
                Text(Date.now, format: .dateTime.weekday(.abbreviated))
                    .font(.caption2.weight(.bold))
                    .opacity(0.68)
            }

            if family == .systemSmall {
                smallContent
            } else {
                mediumContent
            }

            Spacer(minLength: 0)

            Button(intent: OpenAuraIntent()) {
                Label("Open Aura", systemImage: "arrow.up.right")
                    .font(.caption2.weight(.bold))
            }
            .buttonStyle(.plain)
        }
        .foregroundStyle(.white)
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: [
                    Color(red: 0.34, green: 0.18, blue: 0.72),
                    Color(red: 0.78, green: 0.25, blue: 0.68),
                    Color(red: 1.00, green: 0.39, blue: 0.32)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private var smallContent: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(entry.snapshot.openToday)")
                .font(.system(size: 40, weight: .black, design: .rounded))
            Text(entry.snapshot.openToday == 1 ? "task left today" : "tasks left today")
                .font(.caption.weight(.semibold))
                .opacity(0.82)
                .lineLimit(2)
        }
    }

    private var mediumContent: some View {
        HStack(spacing: 18) {
            ZStack {
                Circle()
                    .stroke(.white.opacity(0.2), lineWidth: 7)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(.white, style: StrokeStyle(lineWidth: 7, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text("\(Int(progress * 100))%")
                    .font(.headline.weight(.black))
            }
            .frame(width: 68, height: 68)

            VStack(alignment: .leading, spacing: 4) {
                Text(entry.snapshot.nextTaskTitle ?? "A clear day")
                    .font(.headline.weight(.bold))
                    .lineLimit(2)
                Text(entry.snapshot.openToday == 0 ? "Make room for what matters." : "\(entry.snapshot.openToday) left · \(entry.snapshot.completedToday) complete")
                    .font(.caption)
                    .opacity(0.78)
            }
        }
    }
}

struct AuraTodayWidget: Widget {
    let kind = "AuraTodayWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: AuraWidgetProvider()) { entry in
            AuraWidgetView(entry: entry)
        }
        .configurationDisplayName("Today in Aura")
        .description("See today's progress and your next task.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
