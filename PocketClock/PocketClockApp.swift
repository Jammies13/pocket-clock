import SwiftUI
import UIKit

@main
struct PocketClockApp: App {
    var body: some Scene {
        WindowGroup { ClockView() }
    }
}

private enum Palette {
    static let background = Color(red: 0.055, green: 0.075, blue: 0.105)
    static let face = Color(red: 0.09, green: 0.115, blue: 0.15)
    static let accent = Color(red: 1, green: 0.57, blue: 0.35)
    static let ink = Color(red: 0.94, green: 0.93, blue: 0.89)
}

struct ClockView: View {
    @AppStorage("use24Hour") private var use24Hour = false
    @AppStorage("keepAwake") private var keepAwake = false
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ZStack {
            Palette.background.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 30) {
                    HStack {
                        Image(systemName: "clock")
                            .foregroundStyle(Palette.accent)
                        Text("Pocket Clock").font(.headline)
                        Spacer()
                    }
                    .padding(.top, 20)

                    TimelineView(.periodic(from: .now, by: 1)) { context in
                        VStack(spacing: 28) {
                            AnalogClock(date: context.date)
                                .frame(maxWidth: 310)
                                .aspectRatio(1, contentMode: .fit)
                                .accessibilityHidden(true)

                            VStack(spacing: 10) {
                                Text(timeString(context.date))
                                    .font(.system(size: 54, weight: .light, design: .rounded))
                                    .monospacedDigit()
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.45)
                                    .contentTransition(.identity)
                                    .accessibilityLabel("Time")
                                    .accessibilityValue(timeString(context.date))

                                Text(context.date.formatted(.dateTime.weekday(.wide).month(.wide).day()))
                                    .font(.title3)
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(Palette.ink.opacity(0.75))

                                Text(timeZoneString(context.date))
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(Palette.accent)
                            }
                        }
                    }

                    VStack(spacing: 18) {
                        Toggle("24-hour time", isOn: $use24Hour)
                        Divider().overlay(Palette.ink.opacity(0.12))
                        Toggle("Keep screen awake", isOn: $keepAwake)
                    }
                    .tint(Palette.accent)
                    .padding(22)
                    .background(Palette.face, in: RoundedRectangle(cornerRadius: 24))

                    Text("A little time, just for you.")
                        .font(.footnote)
                        .foregroundStyle(Palette.ink.opacity(0.45))
                        .padding(.bottom, 20)
                }
                .padding(.horizontal, 28)
                .frame(maxWidth: 450)
                .frame(maxWidth: .infinity)
            }
        }
        .foregroundStyle(Palette.ink)
        .preferredColorScheme(.dark)
        .onAppear { updateIdleTimer() }
        .onChange(of: keepAwake) { _, _ in updateIdleTimer() }
        .onChange(of: scenePhase) { _, _ in updateIdleTimer() }
        .onDisappear { UIApplication.shared.isIdleTimerDisabled = false }
    }

    private func updateIdleTimer() {
        UIApplication.shared.isIdleTimerDisabled = keepAwake && scenePhase == .active
    }

    private func timeString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .autoupdatingCurrent
        formatter.dateFormat = use24Hour ? "HH:mm:ss" : "h:mm:ss a"
        return formatter.string(from: date)
    }

    private func timeZoneString(_ date: Date) -> String {
        let zone = TimeZone.autoupdatingCurrent
        let name = zone.identifier.split(separator: "/").last.map(String.init)?
            .replacingOccurrences(of: "_", with: " ") ?? zone.identifier
        return "\(name) · \(zone.abbreviation(for: date) ?? zone.identifier)"
    }
}

private struct AnalogClock: View {
    let date: Date

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let components = Calendar.autoupdatingCurrent.dateComponents([.hour, .minute, .second], from: date)
            let second = Double(components.second ?? 0)
            let minute = Double(components.minute ?? 0) + second / 60
            let hour = Double((components.hour ?? 0) % 12) + minute / 60

            ZStack {
                Circle().fill(Palette.face)
                Circle().strokeBorder(Palette.ink.opacity(0.08), lineWidth: 1)
                ForEach(0..<60) { tick in
                    Capsule()
                        .fill(Palette.ink.opacity(tick % 5 == 0 ? 0.75 : 0.2))
                        .frame(width: tick % 5 == 0 ? 3 : 1,
                               height: size * (tick % 5 == 0 ? 0.042 : 0.018))
                        .offset(y: -size * 0.435)
                        .rotationEffect(.degrees(Double(tick) * 6))
                }
                hand(length: size * 0.24, width: 6, angle: hour * 30, color: Palette.ink)
                hand(length: size * 0.34, width: 4, angle: minute * 6, color: Palette.ink)
                hand(length: size * 0.37, width: 2, angle: second * 6, color: Palette.accent)
                Circle().fill(Palette.accent).frame(width: 12, height: 12)
                Circle().fill(Palette.background).frame(width: 4, height: 4)
            }
            .frame(width: size, height: size)
        }
    }

    private func hand(length: CGFloat, width: CGFloat, angle: Double, color: Color) -> some View {
        Capsule()
            .fill(color)
            .frame(width: width, height: length)
            .offset(y: -length / 2)
            .rotationEffect(.degrees(angle))
    }
}
