# Language and Framework

## Language
- Swift 5+
- Use modern Swift features where appropriate
- iOS 18.6+

## UI Framework
- SwiftUI-first architecture
- UIKit only for specialized interactive components

UIKit must be wrapped with:
- `UIViewRepresentable`
- `UIViewControllerRepresentable`

SwiftUI remains the app shell and navigation owner.

# Architecture

Harbor follows a layered modular architecture:

```text
App
Core
Features
Resources
```

## Core

```text
Core/
  Domain/
  Data/
  Infrastructure/
  DesignSystem/
  Utilities/
  Routing/
```

Core should remain framework-agnostic whenever possible.

## Features

Each feature follows the same structure:

```text
Feature/
  Domain/
  Data/
  Presentation/
  Components/
  Routing/
```

Examples:

```text
Features/
  Accounts/
  Records/
  Categories/
  Reports/
  Budgets/
  SemanticBar/
```

# Architectural Rules

1. Domain cannot depend on UI frameworks
2. Presentation cannot access backend directly
3. Business logic lives in Domain
4. Repositories must be protocol-driven
5. Services perform domain logic
6. Views remain declarative and lightweight
7. Domain models must be independent from persistence DTOs

# Core Engines

## Ledger Engine

Responsible for:

* financial commands
* record validation
* generating postings
* balance logic

All financial writes must go through this engine.

## Currency Engine

Responsible for:

* money value objects
* FX conversion
* transaction currency validation
* FX snapshots

Never perform currency math outside this engine.

## Semantic Command Engine

Responsible for:

* parsing semantic input
* generating intents
* producing draft commands

UI components must not implement parsing logic.

# Preferred Patterns

## MVVM + Services

```text
View
ViewModel
Service
Repository
```

### View

* rendering
* bindings
* simple UI state

### ViewModel

* screen state
* service orchestration
* navigation intents

### Domain Service

* business rules
* validation
* coordinating repository calls

### Repository

* persistence abstraction

# Concurrency

Use Swift structured concurrency:

* `async/await`
* `Task`

Avoid:

* manual dispatch queues
* callback pyramids
* Combine unless required for streaming behavior

# Accesibility

When building user interfaces, always consider accesibility:

- Localization and internationalization
- Vision (dynamic type sizes, paddings)
- Optimize the app’s UI for Assistive Access
- Consider gender-specific or neutral labels and plurals

# Data Handling

## Money Representation

Use minor units.

```swift
struct Money {
    let amountMinor: Int64
    let currency: CurrencyCode
}
```

Never store floating-point currency values.

# Naming Conventions

Use clear domain naming:

* `Account`
* `FinancialRecord`
* `Posting`
* `FundingLeg`
* `Category`
* `Budget`
* `Money`
* `ExchangeRate`

Avoid ambiguous names like:

* `Item`
* `Object`
* `Data`
* `Model`

Use verb-based names for use cases:

* `CreateExpenseUseCase`
* `TransferFundsUseCase`
* `ComputeAccountBalanceUseCase`

# File Structure

One main type per file.

Examples:

* `CreateExpenseUseCase.swift`
* `LedgerService.swift`
* `Account.swift`

SwiftUI files should match screen names:

* `AccountsView.swift`
* `AccountsViewModel.swift`

# Testing

Use Swift Testing.

```swift
import Testing
```

## Domain tests

Highest priority.

Examples:

* `LedgerServiceTests`
* `CurrencyServiceTests`
* `BudgetServiceTests`
* `SemanticParserTests`

## ViewModel tests

Test:

* state transitions
* navigation intents
* validation behavior

Avoid testing SwiftUI layout details.

# Dependency Rules

Allowed:

```text
Presentation -> Domain
Domain -> Protocols
Data -> Domain protocols
Infrastructure -> Data
App -> all modules
```

Not allowed:

```text
Domain -> SwiftUI
Domain -> UIKit
Feature -> other feature internal code
Presentation -> backend directly
```

# Dependencies

Prefer minimal dependencies.

Allowed:

* SwiftUI
* Foundation
* Supabase client in Infrastructure only

Avoid introducing new third-party dependencies unless necessary.

# Documentation

Public domain types and services should include short doc comments where useful.

Example:

```swift
/// Creates an expense record and generates ledger postings.
```

Do not over-document trivial code.

# Code Style

* `camelCase` for properties and functions
* `PascalCase` for types
* avoid excessive nesting
* prefer small functions
* prefer `struct` unless reference semantics are required
