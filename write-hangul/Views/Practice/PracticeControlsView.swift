import SwiftUI

struct DemoControlsView: View {
    let canGoPrevious: Bool
    let canGoNext: Bool
    let onPrevious: () -> Void
    let onNext: () -> Void
    let onTryIt: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button("Previous", action: onPrevious)
                .buttonStyle(SecondaryControlButtonStyle())
                .disabled(!canGoPrevious)

            Button("Next", action: onNext)
                .buttonStyle(SecondaryControlButtonStyle())
                .disabled(!canGoNext)

            Button("Try it", action: onTryIt)
                .buttonStyle(PrimaryControlButtonStyle())
        }
    }
}

struct PracticeControlsView: View {
    let canGoPrevious: Bool
    let canGoNext: Bool
    let onClear: () -> Void
    let onPrevious: () -> Void
    let onNext: () -> Void
    let onDone: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button("Clear", action: onClear)
                .buttonStyle(SecondaryControlButtonStyle())

            Button("Previous", action: onPrevious)
                .buttonStyle(SecondaryControlButtonStyle())
                .disabled(!canGoPrevious)

            Button("Next", action: onNext)
                .buttonStyle(SecondaryControlButtonStyle())
                .disabled(!canGoNext)

            Button("Done", action: onDone)
                .buttonStyle(PrimaryControlButtonStyle())
        }
    }
}

private struct PrimaryControlButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold, design: .rounded))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.appAccent.opacity(configuration.isPressed ? 0.85 : 1), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .foregroundStyle(.white)
    }
}

private struct SecondaryControlButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold, design: .rounded))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.appTile.opacity(configuration.isPressed ? 0.7 : 1), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .foregroundStyle(Color.appInk)
    }
}
