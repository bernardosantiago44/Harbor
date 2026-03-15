## What this app does
Harbor is a premium, calm, simplicity-first personal finance iOS app.

It helps users track accounts, records, budgets, and reports with a minimal UX, while using a rigorous internal financial model underneath.

The app is:
- SwiftUI-first
- modular and highly testable
- built around Ledger, Currency, and Semantic Command core engines

## Bounded Context
This repository is for the Harbor iOS application only.

Main bounded contexts:
- **Accounts**: financial containers such as cash, bank, credit card, loan, insurance, general-purpose
- **Records**: user-facing expense, income, and transfer actions
- **Ledger**: internal source of truth for balanced financial movements
- **Currency**: money, FX, and account-currency rules
- **Budgets**: category budgets with weekly, biweekly, or monthly periods
- **Reports**: read models and summaries derived from financial truth
- **Semantic Bar**: centralized command/search/draft-entry interaction layer

## Key concepts for AI to understand
- **Account**: a financial container or obligation with one base currency
- **Tracked account**: fully participates in financial flows
- **Untracked account**: visible for reference, but not always part of strict tracking behavior
- **Record**: user-facing financial event (`expense`, `income`, `transfer`)
- **Posting**: internal accounting movement generated from a record
- **Funding leg**: one source used to fund part of an expense
- **Category**: hierarchical spending classification
- **Budget**: category-based spending target for a period
- **FX snapshot**: stored conversion data at transaction time
- **Semantic draft**: a parsed but not yet fully committed financial action

Important principle:
- **Keep UX simple, but keep domain logic rigorous**

## Before Making Changes
Read `.github/copilot-instructions.md` in full.

## When working in this repository, AI should
- make small, focused changes
- keep business logic in Domain
- keep UI code thin
- reuse existing models, services, and patterns before creating new ones
- keep modules loosely coupled
- document assumptions if something is ambiguous
- surface any mismatch between implementation and project documents

## What AI should NOT do here
- Do **not** put business logic in SwiftUI views
- Do **not** put business logic in UIKit controls
- Do **not** bypass the Ledger engine for financial writes
- Do **not** bypass the Currency engine for FX-related logic
- Do **not** couple one feature directly to another feature’s internal implementation
- Do **not** query backend services directly from views or view models
- Do **not** introduce a new architectural pattern without strong reason
- Do **not** expand MVP scope unless explicitly requested
- Do **not** silently change domain concepts or financial behavior

## Related files to always check before editing
Always review these before making important changes:
- the feature folder being edited
- shared Core domain services and repository protocols
- any existing models or use cases related to the change

## Bug Fixes
When fixing a bug, AI should:
1. Write a failing test that reproduces it
2. Confirm the test fails before attempting any fix
3. Fix the bug
4. The fix is complete only when the test passes without modifying the test itself

For financial bugs:
- verify whether Ledger, Currency, or record-mapping logic is affected
- never patch around financial inconsistencies in the UI only

## Documentation mismatch
If implementation reveals that project documents are outdated or inconsistent, create an update request with:
- document name
- what should be added
- what should be removed
- what should be clarified
