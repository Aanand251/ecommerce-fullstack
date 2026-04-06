# Feature Architecture (Step 1 Foundation)

Each feature follows Clean Architecture boundaries:

- `data/`: DTOs, API mappers, repository implementations
- `domain/entities/`: pure business entities
- `domain/repositories/`: repository contracts
- `domain/usecases/`: feature-specific application use cases
- `presentation/screens/`: route-level pages
- `presentation/providers/`: Riverpod Notifier/AsyncNotifier state layers
- `presentation/widgets/`: reusable feature UI components

This baseline is intentionally strict so that API and auth flows in Step 2+ remain modular and testable.
