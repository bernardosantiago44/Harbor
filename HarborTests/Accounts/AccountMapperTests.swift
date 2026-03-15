import Testing
import Foundation
@testable import Harbor

struct AccountMapperTests {

    // MARK: - toSummary

    @Test("toSummary maps all fields correctly")
    func toSummaryMapsFields() {
        let id = UUID()
        let dto = AccountDTO(
            id: id,
            name: "Checking",
            type: "bank",
            currency: "USD",
            balance: 150_00,
            isTracked: true,
            metadata: ["note": "primary"]
        )

        let summary = AccountMapper.toSummary(dto)

        #expect(summary.id == id)
        #expect(summary.name == "Checking")
        #expect(summary.type == .bank)
        #expect(summary.currency == "USD")
        #expect(summary.balance == 150_00)
        #expect(summary.isTracked == true)
    }

    @Test("toSummary defaults unknown type to general")
    func toSummaryDefaultsUnknownType() {
        let dto = AccountDTO(
            id: UUID(),
            name: "Unknown",
            type: "crypto",
            currency: "BTC",
            balance: 0,
            isTracked: false,
            metadata: nil
        )

        let summary = AccountMapper.toSummary(dto)
        #expect(summary.type == .general)
    }

    // MARK: - toDetail

    @Test("toDetail maps all fields including metadata")
    func toDetailMapsFields() {
        let id = UUID()
        let dto = AccountDTO(
            id: id,
            name: "Savings",
            type: "bank",
            currency: "MXN",
            balance: 500_00,
            isTracked: true,
            metadata: ["institution": "BBVA"]
        )

        let detail = AccountMapper.toDetail(dto)

        #expect(detail.id == id)
        #expect(detail.name == "Savings")
        #expect(detail.type == .bank)
        #expect(detail.currency == "MXN")
        #expect(detail.balance == 500_00)
        #expect(detail.isTracked == true)
        #expect(detail.metadata == ["institution": "BBVA"])
    }

    @Test("toDetail defaults nil metadata to empty dictionary")
    func toDetailDefaultsNilMetadata() {
        let dto = AccountDTO(
            id: UUID(),
            name: "Cash",
            type: "cash",
            currency: "USD",
            balance: 20_00,
            isTracked: false,
            metadata: nil
        )

        let detail = AccountMapper.toDetail(dto)
        #expect(detail.metadata == [:])
    }

    @Test("toDetail defaults unknown type to general")
    func toDetailDefaultsUnknownType() {
        let dto = AccountDTO(
            id: UUID(),
            name: "Misc",
            type: "other",
            currency: "EUR",
            balance: 0,
            isTracked: false,
            metadata: nil
        )

        let detail = AccountMapper.toDetail(dto)
        #expect(detail.type == .general)
    }

    // MARK: - toDTO

    @Test("toDTO maps input and preserves id and balance")
    func toDTOMapsInput() {
        let id = UUID()
        let input = SaveAccountInput(
            name: "Visa",
            type: .creditCard,
            currency: "USD",
            isTracked: true,
            metadata: ["bank": "Chase"]
        )

        let dto = AccountMapper.toDTO(id: id, balance: 300_00, input: input)

        #expect(dto.id == id)
        #expect(dto.name == "Visa")
        #expect(dto.type == "creditCard")
        #expect(dto.currency == "USD")
        #expect(dto.balance == 300_00)
        #expect(dto.isTracked == true)
        #expect(dto.metadata == ["bank": "Chase"])
    }

    // MARK: - Round-trip

    @Test("DTO round-trips through toDetail and back")
    func roundTripDetailToDTO() {
        let id = UUID()
        let original = AccountDTO(
            id: id,
            name: "Loan",
            type: "loan",
            currency: "USD",
            balance: 1000_00,
            isTracked: true,
            metadata: ["term": "36mo"]
        )

        let detail = AccountMapper.toDetail(original)

        let input = SaveAccountInput(
            name: detail.name,
            type: detail.type,
            currency: detail.currency,
            isTracked: detail.isTracked,
            metadata: detail.metadata
        )
        let roundTripped = AccountMapper.toDTO(
            id: detail.id,
            balance: detail.balance,
            input: input
        )

        #expect(roundTripped.id == original.id)
        #expect(roundTripped.name == original.name)
        #expect(roundTripped.type == original.type)
        #expect(roundTripped.currency == original.currency)
        #expect(roundTripped.balance == original.balance)
        #expect(roundTripped.isTracked == original.isTracked)
        #expect(roundTripped.metadata == original.metadata)
    }

    // MARK: - All AccountType cases

    @Test("toSummary maps all known AccountType cases",
          arguments: AccountType.allCases)
    func toSummaryMapsAllTypes(type: AccountType) {
        let dto = AccountDTO(
            id: UUID(),
            name: "Test",
            type: type.rawValue,
            currency: "USD",
            balance: 0,
            isTracked: true,
            metadata: nil
        )

        let summary = AccountMapper.toSummary(dto)
        #expect(summary.type == type)
    }
}
