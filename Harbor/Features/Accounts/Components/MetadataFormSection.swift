import SwiftUI

/// Displays type-specific metadata fields for account creation and editing.
/// Shows relevant fields based on the selected account type.
struct MetadataFormSection: View {
    let accountType: AccountType
    @Binding var metadata: [String: String]

    var body: some View {
        Section {
            ForEach(fields, id: \.key) { field in
                TextField(field.label, text: binding(for: field.key))
                    .autocorrectionDisabled()
            }
        } header: {
            if !fields.isEmpty {
                Text("Details")
            }
        }
    }

    // MARK: - Helpers

    private func binding(for key: String) -> Binding<String> {
        Binding(
            get: { metadata[key] ?? "" },
            set: { metadata[key] = $0.isEmpty ? nil : $0 }
        )
    }

    private var fields: [MetadataField] {
        switch accountType {
        case .creditCard:
            return [
                MetadataField(key: "issuer", label: "Issuer"),
                MetadataField(key: "dueDate", label: "Due Date"),
                MetadataField(key: "limit", label: "Credit Limit"),
            ]
        case .loan:
            return [
                MetadataField(key: "lender", label: "Lender"),
                MetadataField(key: "apr", label: "APR"),
                MetadataField(key: "dueDate", label: "Due Date"),
            ]
        case .insurance:
            return [
                MetadataField(key: "provider", label: "Provider"),
                MetadataField(key: "policyNumber", label: "Policy Number"),
                MetadataField(key: "renewalDate", label: "Renewal Date"),
            ]
        case .cash, .bank, .general:
            return []
        }
    }
}

/// A metadata field descriptor used to render type-specific form fields.
private struct MetadataField {
    let key: String
    let label: String
}

#Preview("Credit Card") {
    MetadataFormSection(
        accountType: .creditCard,
        metadata: .constant(["issuer": "Visa"])
    )
}

#Preview("Loan") {
    MetadataFormSection(
        accountType: .loan,
        metadata: .constant([:])
    )
}
