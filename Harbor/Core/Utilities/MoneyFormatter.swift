import Foundation

/// Formats minor-unit money values into human-readable strings.
enum MoneyFormatter {

    /// Formats a minor-unit balance (e.g. cents) with the given currency code.
    ///
    /// Example: `format(amount: 1_250_00, currency: "USD")` → `"1,250.00 USD"`
    static func format(amount: Int64, currency: String) -> String {
        let major = Double(amount) / 100.0
        let formatted = major.formatted(
            .number.grouping(.automatic).precision(.fractionLength(2))
        )
        return "\(formatted) \(currency)"
    }
}
