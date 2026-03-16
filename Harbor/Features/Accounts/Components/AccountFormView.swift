import SwiftUI

/// Shared form used by both Create and Edit account flows.
/// Displays fields for name, account type, currency, tracked state, and metadata.
struct AccountFormView: View {
    @Binding var name: String
    @Binding var accountType: AccountType
    @Binding var currency: String
    @Binding var isTracked: Bool
    @Binding var metadata: [String: String]
    var validationErrors: [String: String]

    var body: some View {
        Form {
            Section {
                TextField("Account Name", text: $name)
                    .autocorrectionDisabled()

                if let nameError = validationErrors["name"] {
                    Text(nameError)
                        .font(Typography.caption)
                        .foregroundStyle(ColorTokens.negative)
                }
            } header: {
                Text("Name")
            }

            Section {
                Picker("Account Type", selection: $accountType) {
                    ForEach(AccountType.allCases, id: \.self) { type in
                        Text(type.displayName).tag(type)
                    }
                }
            } header: {
                Text("Type")
            }

            Section {
                TextField("Currency Code", text: $currency)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.characters)
            } header: {
                Text("Currency")
            }

            Section {
                Toggle("Tracked", isOn: $isTracked)
            } footer: {
                Text("Tracked accounts participate in financial flows and reports.")
                    .font(Typography.caption)
            }

            MetadataFormSection(
                accountType: accountType,
                metadata: $metadata
            )
        }
    }
}

#Preview {
    AccountFormView(
        name: .constant("Checking"),
        accountType: .constant(.bank),
        currency: .constant("USD"),
        isTracked: .constant(true),
        metadata: .constant([:]),
        validationErrors: [:]
    )
}
