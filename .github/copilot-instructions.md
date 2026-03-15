# Language and Framework

## Language
- Swift 5+
- Use modern Swift features (value types, async/await, result builders where appropriate)
- iOS 18.6+

## UI Framework
- **SwiftUI-first architecture**
- UIKit may be used **for specialized components**

UIKit must always be wrapped with:

- `UIViewRepresentable`
- `UIViewControllerRepresentable`

SwiftUI remains the app shell and navigation owner.

---

# Architecture

Harbor follows a **layered modular architecture**.

```

App
Core
Features
Resources

```

## Core
Contains shared logic and engines:

```

Core/
Domain/
Data/
Infrastructure/
DesignSystem/
Utilities/
Routing/

```

Core must be **framework-agnostic whenever possible**.

## Features

Each feature follows the same structure:

```

Feature/
Domain/
Data/
Presentation/
Components/
Routing/

```

Examples:

```

Features/
Accounts/
Records/
Categories/
Reports/
Budgets/
SemanticBar/

```

---

# Architectural Rules

1. **Domain layer cannot depend on UI frameworks**
   - No SwiftUI
   - No UIKit

2. **Presentation layer cannot access backend directly**

3. **Business logic lives in Domain**

4. **Repositories must be protocol-driven**

5. **Services perform domain logic**

6. **Views remain declarative and lightweight**

7. **Domain models must be independent from database DTOs**

---

# Core Engines

The following engines are central to the system:

## Ledger Engine
Responsible for:
- financial commands
- record validation
- generating postings
- balance logic

All financial writes must go through this engine.

## Currency Engine
Responsible for:
- money value objects
- FX conversion
- transaction currency validation
- FX snapshots

Never perform currency math outside this engine.

## Semantic Command Engine
Responsible for:
- parsing semantic input
- generating intents
- producing draft commands

UI components must not implement parsing logic.

---

# Preferred Patterns

## MVVM + Services

```

View
ViewModel
Service
Repository

```

Responsibilities:

### View
- rendering
- bindings
- simple UI state

### ViewModel
- screen state
- calling service
- navigation intents

### Domain Service
- business rules
- validation
- orchestrating repository calls

### Repository
- persistence abstraction

---

# Concurrency

Use **Swift structured concurrency**.

Preferred:

```swift
async / await
Task
```

Avoid:
- manual dispatch queues
- callback pyramids
- Combine unless required for streaming behavior

---

# Data Handling

## Money Representation
Use minor units.

Example:

```swift
struct Money {
    let amountMinor: Int64
    let currency: CurrencyCode
}
```

Never store floating-point currency values.

---

# Naming Conventions

Use clear domain naming.

Examples:

```

Account
FinancialRecord
Posting
FundingLeg
Category
Budget
Money
ExchangeRate

```

Avoid ambiguous names like:

```

Item
Object
Data
Model

```

Use **verb-based names for use cases**:

```

CreateExpenseUseCase
TransferFundsUseCase
ComputeAccountBalanceUseCase

```

---

# File Structure

One main type per file.

Example:

```

CreateExpenseUseCase.swift
LedgerService.swift
Account.swift

```

View-related files may group small helpers.

SwiftUI files should match screen names.

```

AccountsView.swift
AccountsViewModel.swift

```

---

# Testing

Use **Swift Testing**.

Prefer:

```

import Testing

```

Test types:

## Domain tests
Highest priority.

Examples:

```

LedgerServiceTests
CurrencyServiceTests
BudgetServiceTests
SemanticParserTests

```

## ViewModel tests
Test:

- state transitions
- navigation intents
- validation behavior

Avoid testing SwiftUI layout logic.

---

# Dependency Rules

Allowed:

```

Presentation -> Domain
Domain -> Protocols
Data -> Domain protocols
Infrastructure -> Data
App -> all modules

```

Not allowed:

```

Domain -> SwiftUI
Domain -> UIKit
Feature -> other feature internal code
Presentation -> backend directly

```

---

# Dependencies

Prefer minimal dependencies.

Allowed:
- SwiftUI
- Foundation
- Supabase client (in infrastructure layer only)

Avoid introducing new third-party dependencies unless necessary.

---

# Documentation

Public domain types and services should include short doc comments.

Example:

```

/// Creates an expense record and generates ledger postings.

```

Do not over-document trivial code.

---

# Code Style

Follow Swift conventions:

- `camelCase` for properties and functions
- `PascalCase` for types
- avoid excessive nesting
- prefer small functions

Prefer **value types (`struct`)** unless reference semantics are required.

---

# AI Assistance Guidelines

When generating code:

1. Follow existing architecture and folder structure.
2. Reuse existing domain models and services.
3. Do not introduce new patterns without justification.
4. Keep changes minimal and focused.
5. Avoid modifying unrelated code.
6. If unsure about financial behavior, defer to the Ledger engine.

---

# Safety Rules

Never:

- bypass ledger logic for financial writes
- implement FX conversion outside the currency engine
- embed parsing logic inside UIKit views
- mix persistence code into SwiftUI views
- silently change domain behavior

When uncertain, prefer **raising ambiguity instead of guessing**.

