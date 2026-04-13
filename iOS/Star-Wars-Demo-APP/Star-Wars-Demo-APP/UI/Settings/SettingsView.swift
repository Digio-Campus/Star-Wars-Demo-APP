import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    headerCard
                    appearanceCard
                }
                .padding()
            }
            .background(StarWarsColors.background.ignoresSafeArea())
            .navigationTitle("Settings")
        }
    }

    private var headerCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "gearshape")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(StarWarsColors.primary)

            VStack(alignment: .leading, spacing: 2) {
                Text("Customize")
                    .font(.headline)
                Text("Theme applies immediately and is saved on this device")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .background(StarWarsColors.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(StarWarsColors.primary.opacity(0.18), lineWidth: 1)
        )
    }

    private var appearanceCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Appearance", systemImage: "sun.max")
                .font(.headline)
                .foregroundStyle(StarWarsColors.primary)

            VStack(spacing: 0) {
                ForEach(Array(ThemeManager.ThemePreference.allCases.enumerated()), id: \.element.id) { index, option in
                    themeRow(option)

                    if index < ThemeManager.ThemePreference.allCases.count - 1 {
                        Divider()
                            .overlay(StarWarsColors.primary.opacity(0.12))
                            .padding(.leading, 44)
                    }
                }
            }
            .background(
                StarWarsColors.surface,
                in: RoundedRectangle(cornerRadius: 14, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(StarWarsColors.primary.opacity(0.18), lineWidth: 1)
            )
        }
        .padding(16)
        .background(StarWarsColors.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(StarWarsColors.primary.opacity(0.18), lineWidth: 1)
        )
    }

    private func themeRow(_ option: ThemeManager.ThemePreference) -> some View {
        let isSelected = themeManager.preference == option

        return Button {
            themeManager.preference = option
        } label: {
            HStack(spacing: 12) {
                Image(systemName: option.symbolName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(StarWarsColors.primary)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 2) {
                    Text(option.title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(option.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 0)

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? StarWarsColors.primary : .secondary)
                    .font(.system(size: 20, weight: .semibold))
            }
            .padding(12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Theme: \(option.title)")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    SettingsView()
        .environmentObject(ThemeManager())
}
