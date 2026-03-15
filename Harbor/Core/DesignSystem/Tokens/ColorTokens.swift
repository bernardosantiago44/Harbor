import SwiftUI

/// Semantic color tokens for consistent theming across the app.
enum ColorTokens {
    // MARK: - Background
    static let backgroundPrimary = Color(.systemBackground)
    static let backgroundSecondary = Color(.secondarySystemBackground)
    static let backgroundTertiary = Color(.tertiarySystemBackground)

    // MARK: - Label
    static let labelPrimary = Color(.label)
    static let labelSecondary = Color(.secondaryLabel)
    static let labelTertiary = Color(.tertiaryLabel)

    // MARK: - Accent
    static let accent = Color.accentColor

    // MARK: - Semantic
    static let positive = Color.green
    static let negative = Color.red
    static let warning = Color.orange
    static let neutral = Color(.systemGray)

    // MARK: - Separator
    static let separator = Color(.separator)
}
