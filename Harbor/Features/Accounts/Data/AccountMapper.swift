import Foundation

/// Maps between persistence DTOs and domain models.
enum AccountMapper {

    static func toSummary(_ dto: AccountDTO) -> AccountSummary {
        AccountSummary(
            id: dto.id,
            name: dto.name,
            type: AccountType(rawValue: dto.type) ?? .general,
            currency: dto.currency,
            balance: dto.balance,
            isTracked: dto.isTracked
        )
    }

    static func toDetail(_ dto: AccountDTO) -> AccountDetail {
        AccountDetail(
            id: dto.id,
            name: dto.name,
            type: AccountType(rawValue: dto.type) ?? .general,
            currency: dto.currency,
            balance: dto.balance,
            isTracked: dto.isTracked,
            metadata: dto.metadata ?? [:]
        )
    }

    static func toDTO(id: UUID, balance: Int64, input: SaveAccountInput) -> AccountDTO {
        AccountDTO(
            id: id,
            name: input.name,
            type: input.type.rawValue,
            currency: input.currency,
            balance: balance,
            isTracked: input.isTracked,
            metadata: input.metadata
        )
    }
}
