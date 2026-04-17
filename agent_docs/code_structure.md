# Flutter App — Feature Implementation Guide

This document defines the architecture, code conventions, and implementation patterns used in this Flutter project. It is the authoritative reference for writing any new feature. Read it fully before generating any code. Follow every rule exactly — do not invent patterns that are not described here.

---

## Project Architecture

The app uses a **feature-first clean architecture**. Every feature is fully self-contained under `lib/features/<feature_name>/`. No feature imports directly from another feature's internal files — cross-feature dependencies go through `lib/core/` or barrel index files. Core shared infrastructure lives under `lib/core/`.

```
lib/
├── app/                         # App-level constants, theme tokens, string values
├── core/                        # Shared infrastructure used across all features
│   ├── components/              # Reusable UI components (buttons, fields, scaffolds, etc.)
│   ├── data/
│   │   ├── domain/              # Abstract UseCase base classes
│   │   ├── models/              # Shared base models: BaseModel, ErrorResponse, SuccessResponse
│   │   ├── services/api_client/ # Dio HTTP client wrapper + auth interceptor
│   │   └── utils/               # ServiceUtils (API version prefix), other shared utilities
│   └── utils/                   # Extensions, validators, environment config
├── features/
│   └── <feature>/
│       ├── <feature>_index.dart       # Data-layer barrel export (re-exports everything in data/)
│       ├── data/
│       │   ├── domain/                # Use cases (one file per resource)
│       │   ├── enums/                 # Feature-specific enums (one file per enum)
│       │   ├── extensions/            # Extensions on data models
│       │   ├── models/                # JSON-serializable API models + generated .g.dart files
│       │   └── remote/
│       │       ├── dto/               # Request body DTOs and query param classes
│       │       ├── <name>_service.dart    # Raw HTTP calls via ApiClient
│       │       └── <name>_repository.dart # Error handling + response parsing
│       └── presentation/
│           ├── presentation.dart           # Presentation-layer barrel export
│           ├── controllers/
│           │   ├── <feature>_bloc_provider.dart      # BlocProvider registration list
│           │   ├── <feature>_controller_index.dart   # Controllers barrel export
│           │   ├── blocs/                            # BLoCs for async/event-driven operations
│           │   └── cubits/                           # Cubits for persistent local UI state
│           ├── entities/              # Presentation-layer data shapes (decoupled from models)
│           ├── extensions/            # Presentation-layer type conversion extensions
│           ├── helpers/               # BLoC dispatching, navigation, dialog, form logic
│           ├── screens/               # Full screen widgets
│           └── widgets/               # Feature-scoped reusable UI components
└── navigation/
    └── routes/                        # GoRouter route definitions, one file per feature
```

---

## Layer 1 — Models (`data/models/`)

Models represent the shape of data returned by the API. They are the single source of truth for serialization and deserialization.

### Rules

- If the model maps to a persisted database entity (has `id`, `dateCreated`, `lastUpdated`), extend `BaseModel`.
- `BaseModel` extends `Equatable` and provides: `id` (required `String`), `dateCreated` (`DateTime?`), `lastUpdated` (`DateTime?`).
- If the model does NOT correspond to a persisted entity (e.g. an embedded sub-object), use a plain class — do NOT force `BaseModel` inheritance.
- Always annotate with `@JsonSerializable(fieldRename: FieldRename.snake)`. This maps camelCase Dart fields to snake_case JSON keys automatically.
- Every model must have exactly these three members:
  1. `factory Model.fromJson(Map<String, dynamic> json)` — for deserialization.
  2. `Map<String, dynamic> toJson()` — for serialization (used by cubits and DTOs).
  3. `static Model? maybeFromJson(Map<String, dynamic>? json)` — null-safe entry point used by cubits.
- Declare `part '<model_name>.g.dart';` after all imports and before the class definition. The `.g.dart` file is auto-generated — **never edit it manually**.
- After adding or modifying a model, run `dart run build_runner build --delete-conflicting-outputs` to regenerate.
- Enum fields in models are decoded with `$enumDecodeNullable` in the generated code. This works automatically as long as the enum is declared in scope.
- All fields should be `final`. Models are immutable.

### Example — entity-backed model

```dart
import 'package:json_annotation/json_annotation.dart';
import 'package:<app_package>/core/core.dart';

part 'invitation_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Invitation extends BaseModel {
  const Invitation({
    required super.id,
    super.dateCreated,
    super.lastUpdated,
    this.title,
    this.type,
    this.status,
  });

  factory Invitation.fromJson(Map<String, dynamic> json) =>
      _$InvitationFromJson(json);

  final String? title;
  final InvitationType? type;
  final InvitationStatus? status;

  @override
  Map<String, dynamic> toJson() => _$InvitationToJson(this);

  static Invitation? maybeFromJson(Map<String, dynamic>? json) {
    if (json != null) return Invitation.fromJson(json);
    return null;
  }
}
```

### Example — plain (non-entity) model

```dart
import 'package:json_annotation/json_annotation.dart';

part 'guest_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Guest {
  Guest({
    required this.firstname,
    required this.lastname,
    required this.email,
    this.phoneNumber,
  });

  factory Guest.fromJson(Map<String, dynamic> json) => _$GuestFromJson(json);

  final String firstname;
  final String lastname;
  final String email;
  final String? phoneNumber;

  Map<String, dynamic> toJson() => _$GuestToJson(this);

  static Guest? maybeFromJson(Map<String, dynamic>? json) {
    if (json != null) return Guest.fromJson(json);
    return null;
  }
}
```

---

## Layer 2 — Enums (`data/enums/`)

Enums represent a fixed set of values for a field. One enum per file.

### Rules

- Define the enum as a simple Dart enum — no fields, no constructor.
- Do NOT put display labels or JSON strings inside the enum body. Put them in extensions.
- Create a named extension on the enum for:
  - A human-readable `label` getter (for display in UI).
  - A `toJson` getter (for serialization), only if the JSON value differs from `.name`.
- Always use `switch` **expressions** (not statements) in extensions. Every case must be covered — this enforces exhaustiveness at compile time.
- If a JSON value differs from the Dart enum name (e.g. `serviceProvider` → `'service_provider'`), handle it in the custom getter. Do not rely on `json_serializable` to handle non-trivial mappings.
- If you need to parse from a string back to an enum, create a separate extension on `String`.

### Example

```dart
enum InvitationType { personal, delivery, serviceProvider, event }

// Extension for display labels and JSON serialization
extension InvitationTypeExt on InvitationType {
  // Human-readable label for UI dropdowns, chips, etc.
  String get label => switch (this) {
    InvitationType.personal => 'Personal visit',
    InvitationType.delivery => name.capitalize(),
    InvitationType.serviceProvider => 'Service provider',
    InvitationType.event => name.capitalize(),
  };

  // JSON serialization — only needed when the JSON value differs from .name
  String get toJson => switch (this) {
    InvitationType.personal => name,
    InvitationType.delivery => name,
    InvitationType.serviceProvider => 'service_provider', // differs from .name
    InvitationType.event => name,
  };
}

// Extension to parse a String back to the enum
extension InvitationTypeFromString on String {
  InvitationType get toInvitationType => switch (this) {
    'personal' => InvitationType.personal,
    'delivery' => InvitationType.delivery,
    'service_provider' => InvitationType.serviceProvider,
    'event' => InvitationType.event,
    _ => InvitationType.personal, // safe fallback
  };
}
```

> Enums that are used as model fields will have an auto-generated `EnumMap` in the `.g.dart` file. This is handled by `json_serializable` — you do not need to write it manually.

---

## Layer 3 — DTOs (`data/remote/dto/`)

DTOs (Data Transfer Objects) define the shape of data **sent to** the API. They are plain Dart classes — no `json_serializable`, no code generation.

### Rules
- Use `required this.field` for fields the API always expects.
- Use `this.field` (optional, nullable) for fields that are conditionally sent.
- In `toJson()`, always start with `final json = <String, dynamic>{};` and `return json;`.
- Only include optional fields in `toJson()` if they are non-null: `if (field != null) json['key'] = field;`. Never send null values to the API unless explicitly required.
- Serialize enums using their custom getter (e.g. `type.toJson`), never via `.toString()` or `.index`.
- Serialize `DateTime` to ISO 8601: `date.toIso8601String()`.
- For GET request query parameters, create a separate `<Resource>Params` class following the same pattern — all fields optional.
- Update DTOs must include `required this.id` and all other fields optional.

### Create DTO

```dart
class CreateInvitationDto {
  CreateInvitationDto({
    required this.title,
    required this.date,
    required this.duration,
    required this.durationOption,
    required this.type,
    this.description, // optional — only sent if non-null
  });

  final String title;
  final String? description;
  final DateTime date;
  final int duration;
  final DurationOption durationOption;
  final InvitationType type;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json['title'] = title;
    json['date'] = date.toIso8601String();
    json['duration'] = duration;
    json['duration_option'] = durationOption.name;  // .name works when JSON matches Dart name
    json['type'] = type.toJson;                     // custom getter for non-trivial mapping
    if (description != null) json['description'] = description;
    return json;
  }
}
```

### Update DTO

```dart
class UpdateInvitationDto {
  UpdateInvitationDto({
    required this.id,   // always required for updates
    this.title,
    this.date,
    this.duration,
    this.type,
  });

  final String id;
  final String? title;
  final DateTime? date;
  final int? duration;
  final InvitationType? type;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (title != null) json['title'] = title;
    if (date != null) json['date'] = date!.toIso8601String();
    if (duration != null) json['duration'] = duration;
    if (type != null) json['type'] = type!.toJson;
    return json;
  }
}
```

### Params (GET query string)

```dart
class InvitationParams {
  InvitationParams({this.status, this.type});

  final InvitationStatus? status;
  final InvitationType? type;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (status != null) json['status'] = status!.name;
    if (type != null) json['type'] = type!.toJson;
    return json;
  }
}
```

---

## Layer 4 — Service (`data/remote/<name>_service.dart`)

The service layer makes raw HTTP calls using `ApiClient`. It knows nothing about error handling or response parsing — that belongs in the repository.

### Rules

- Declare a **file-level global singleton** at the top: `final myService = MyService(apiClient);`
- Define an `abstract class MyServiceInterface` that declares every method. This documents the contract.
- The concrete `class MyService implements MyServiceInterface` provides the implementation.
- Inject `ApiClient` via the constructor — never access it globally inside methods.
- All methods return `Future<Response<dynamic>>` — do not parse the response here.
- Always pass `reqToken: true` on any endpoint that requires authentication.
- For endpoints that serve both single and list results via the same path, use an `isSingle` bool flag with an optional `id` string.
- All paths are prefixed with `ServiceUtils.v1` (which equals `'/api/v1'`).

### URL format rules

| Operation    | HTTP method | Path format                                                                |
|--------------|-------------|----------------------------------------------------------------------------|
| Fetch list   | GET         | `${ServiceUtils.v1}/resource`                                              |
| Fetch single | GET         | `${ServiceUtils.v1}/resource/$id/` (trailing slash)                        |
| Create       | POST        | `${ServiceUtils.v1}/resource`                                              |
| Update       | PUT         | `${ServiceUtils.v1}/resource$id` (id appended directly, no trailing slash) |
| Delete       | DELETE      | `${ServiceUtils.v1}/resource/$id/` (trailing slash)                        |

### Example

```dart
final invitationService = InvitationService(apiClient);

abstract class InvitationServiceInterface {
  Future<Response<dynamic>> createInvitation(CreateInvitationDto data);
  Future<Response<dynamic>> getInvitation({bool isSingle, String? id, Json? queryParams});
  Future<Response<dynamic>> updateInvitation(UpdateInvitationDto data);
  Future<Response<dynamic>> deleteInvitation(String id);
}

class InvitationService implements InvitationServiceInterface {
  InvitationService(this.apiClient);
  final ApiClient apiClient;

  @override
  Future<Response> createInvitation(CreateInvitationDto data) async {
    return apiClient.post(
      '${ServiceUtils.v1}/invitations',
      data: data.toJson(),
      reqToken: true,
    );
  }

  @override
  Future<Response> getInvitation({
    bool isSingle = false,
    String? id,
    Json? queryParams,
  }) async {
    final pathParam = isSingle ? '/$id/' : '';
    return apiClient.get(
      '${ServiceUtils.v1}/invitations$pathParam',
      reqToken: true,
      queryParams: queryParams,
    );
  }

  @override
  Future<Response> updateInvitation(UpdateInvitationDto data) async {
    return apiClient.put(
      '${ServiceUtils.v1}/invitations${data.id}', // no trailing slash
      data: data.toJson(),
      reqToken: true,
    );
  }

  @override
  Future<Response> deleteInvitation(String id) async {
    return apiClient.delete(
      '${ServiceUtils.v1}/invitations/$id/',
      reqToken: true,
    );
  }
}
```

---

## Layer 5 — Repository (`data/remote/<name>_repository.dart`)

The repository handles response parsing, error handling, and returns typed results to use cases. It is the boundary between HTTP and the rest of the app.

### Rules

- Declare a **file-level global singleton** at the top: `final myRepository = MyRepository(myService);`
- Define an `abstract class MyRepositoryInterface` that declares every method with its `Either` return type.
- The concrete class implements the interface.
- Return `Either<T, ErrorResponse>` for every method. **Left = success, Right = error.** Never invert this.
- Wrap every method body in this exact try-catch structure — no variations:

  ```dart
  try { ... } on DioException catch (e) { ... } catch (e) { ... }
  ```

- Handle `DioException` with `ApiError.handleError(e)` to produce a standardized `ErrorResponse`.
- Handle all other exceptions with `ErrorResponse(message: e.toString())`.
- Parse responses as follows:
  - **Single object**: `final json = response.data as Json;` → `Model.fromJson(json)`
  - **List**: `final json = response.data as List<dynamic>;` → `.map((e) => Model.fromJson(e as Json)).toList()`
  - **Delete (no response body)**: Do not parse — construct `SuccessResponse(message: 'Resource Deleted')` directly.
  - **Action with body**: `SuccessResponse.fromJson(response.data as Json)`

### Return type guide

| Operation         | Return type                              |
|-------------------|------------------------------------------|
| Fetch single      | `Either<Model, ErrorResponse>`           |
| Fetch list        | `Either<List<Model>, ErrorResponse>`     |
| Create            | `Either<Model, ErrorResponse>`           |
| Update            | `Either<Model, ErrorResponse>`           |
| Delete            | `Either<SuccessResponse, ErrorResponse>` |
| Action (no model) | `Either<SuccessResponse, ErrorResponse>` |

### Example

```dart
final invitationRepository = InvitationRepository(invitationService);

abstract class InvitationRepositoryInterface {
  Future<Either<Invitation, ErrorResponse>> createInvitation(CreateInvitationDto data);
  Future<Either<List<Invitation>, ErrorResponse>> getInvitations();
  Future<Either<Invitation, ErrorResponse>> getInvitation(String id);
  Future<Either<Invitation, ErrorResponse>> updateInvitation(UpdateInvitationDto data);
  Future<Either<SuccessResponse, ErrorResponse>> deleteInvitation(String id);
}

class InvitationRepository implements InvitationRepositoryInterface {
  InvitationRepository(this.invitationService);
  final InvitationService invitationService;

  @override
  Future<Either<List<Invitation>, ErrorResponse>> getInvitations() async {
    try {
      final response = await invitationService.getInvitation();
      final json = response.data as List<dynamic>;
      final data = json.map((e) => Invitation.fromJson(e as Json)).toList();
      return Left(data);
    } on DioException catch (e) {
      return Right(ApiError.handleError(e));
    } catch (e) {
      return Right(ErrorResponse(message: e.toString()));
    }
  }

  @override
  Future<Either<SuccessResponse, ErrorResponse>> deleteInvitation(String id) async {
    try {
      await invitationService.deleteInvitation(id);
      return Left(SuccessResponse(message: 'Invitation Deleted'));
    } on DioException catch (e) {
      return Right(ApiError.handleError(e));
    } catch (e) {
      return Right(ErrorResponse(message: e.toString()));
    }
  }
}
```

---

## Layer 6 — Use Cases (`data/domain/<name>_use_cases.dart`)

Use cases are the entry point into the data layer from the presentation layer. They are intentionally thin — their only job is to call the repository and pass through the result.

### Rules

- Declare a **file-level global singleton** for every use case: `final createInvitationUseCase = CreateInvitationUseCase();`
- Extend `UseCase<ReturnType, ParamsType>` if the operation requires parameters.
- Extend `NoParamsUseCase<ReturnType>` if the operation takes no parameters (e.g., fetch all).
- The `call()` method must only do two things: call the repository, and fold the result with `res.fold(Left.new, Right.new)`.
- Do NOT add validation, transformation, or business logic to use cases. That belongs in helpers or the BLoC.
- Group all use cases for a resource in a single file (e.g., `invitation_use_cases.dart`).

### Base class signatures

```dart
abstract class UseCase<Type, Params> {
  Future<Either<Type, ErrorResponse>> call(Params params);
}

abstract class NoParamsUseCase<Type> {
  Future<Either<Type, ErrorResponse>> call();
}
```

### Example

```dart
// Use case that takes parameters
final createInvitationUseCase = CreateInvitationUseCase();

class CreateInvitationUseCase extends UseCase<Invitation, CreateInvitationDto> {
  @override
  Future<Either<Invitation, ErrorResponse>> call(CreateInvitationDto params) async {
    final res = await invitationRepository.createInvitation(params);
    return res.fold(Left.new, Right.new);
  }
}

// Use case with no parameters
final multipleInvitationUseCase = MultipleInvitationUseCase();

class MultipleInvitationUseCase extends NoParamsUseCase<List<Invitation>> {
  @override
  Future<Either<List<Invitation>, ErrorResponse>> call() async {
    final res = await invitationRepository.getInvitations();
    return res.fold(Left.new, Right.new);
  }
}

// Use case that takes a simple String ID
final deleteInvitationUseCase = DeleteInvitationUseCase();

class DeleteInvitationUseCase extends UseCase<SuccessResponse, String> {
  @override
  Future<Either<SuccessResponse, ErrorResponse>> call(String params) async {
    final res = await invitationRepository.deleteInvitation(params);
    return res.fold(Left.new, Right.new);
  }
}
```

---

## Layer 7 — BLoCs (`presentation/controllers/blocs/`)

BLoCs handle **async operations** triggered by user interactions — API calls, form submissions, deletions. Each BLoC lives in its own folder with exactly three files.

### File structure

Every BLoC folder contains:

- `<name>_bloc.dart` — the BLoC class, imports, part directives, and global singleton
- `<name>_event.dart` — all event classes (`part of` the bloc file)
- `<name>_state.dart` — all state classes (`part of` the bloc file)

**`<name>_bloc.dart`**

```dart
import 'package:<app_package>/core/core.dart';
import 'package:<app_package>/features/<feature>/<feature>_index.dart';

part '<name>_event.dart';
part '<name>_state.dart';

final myActionBloc = MyActionBloc();

class MyActionBloc extends Bloc<MyActionEvent, MyActionState> {
  MyActionBloc() : super(MyActionInitial()) {
    on<DoSomething>(_doSomething);
  }

  Future<void> _doSomething(
    DoSomething event,
    Emitter<MyActionState> emit,
  ) async {
    emit(MyActionLoading());
    final params = MyDto(field: event.field);
    final res = await myUseCase.call(params);
    res.fold(
      (l) => emit(SomethingDone(l)),
      (r) => emit(MyActionError(r)),
    );
  }
}
```

**`<name>_event.dart`**

```dart
part of '<name>_bloc.dart';

@immutable
sealed class MyActionEvent {}

final class DoSomething extends MyActionEvent {
  DoSomething({required this.field});
  final String field;
}
```

**`<name>_state.dart`**

```dart
part of '<name>_bloc.dart';

@immutable
sealed class MyActionState {}

final class MyActionInitial extends MyActionState {}

final class MyActionLoading extends MyActionState {}

final class SomethingDone extends MyActionState {
  SomethingDone(this.result);
  final MyModel result;
}

final class MyActionError extends MyActionState {
  MyActionError(this.error);
  final ErrorResponse error;
}
```

### Naming conventions

| BLoC purpose                        | Class name pattern                            |
|-------------------------------------|-----------------------------------------------|
| Create / Update / Delete a resource | `<Resource>ActionBloc`                        |
| Fetch a list of a resource          | `Multiple<Resource>Bloc`                      |
| Fetch a single resource by ID       | `Single<Resource>Bloc`                        |
| A specific action (not pure CRUD)   | `<SpecificAction>Bloc` (e.g. `GuestPassBloc`) |

### State naming conventions

| State meaning                | Class name                 |
|------------------------------|----------------------------|
| Before anything has happened | `<BlocName>Initial`        |
| In-flight async call         | `<BlocName>Loading`        |
| Resource was created         | `<Resource>Created`        |
| Resource was updated         | `<Resource>Updated`        |
| Resource was deleted         | `<Resource>Deleted`        |
| List was loaded              | `Multiple<Resource>Loaded` |
| Single item was loaded       | `Single<Resource>Loaded`   |
| Any failure                  | `<BlocName>Error`          |

### Structural rules

- Always use `sealed class` for the base event/state type and `final class` for every subclass.
- Annotate the base event and base state with `@immutable`.
- Every handler method is named `_<camelCaseEventName>` (private, prefixed with underscore).
- Always emit `Loading` before the async call. Never skip this.
- Always handle both sides of `res.fold()` — success emits a success state, error emits the error state.

---

## Layer 8 — Cubits (`presentation/controllers/cubits/`)

Cubits hold **simple, persistent UI state** — typically the currently selected or active model that needs to survive navigation (e.g., the invitation a user just tapped on, passed to the detail screen).

### Rules

- All cubits extend `Cubit<ModelType?> with HydratedMixin`. The `HydratedMixin` persists state to disk so it survives hot restarts and app re-launches.
- Always call `hydrate()` in the constructor body.
- Every cubit exposes exactly two methods:
  - `void set<ModelName>(ModelType value) => emit(value);` — to set the state
  - `void reset() => emit(null);` — to clear the state
- Override `fromJson` and `toJson` for hydration. Always use `KeyValues.value` as the JSON key and delegate to the model's `maybeFromJson` / `toJson`.
- Declare a **file-level global singleton**: `final myCubit = MyCubit();`

### Example

```dart
final invitationCubit = InvitationCubit();

class InvitationCubit extends Cubit<Invitation?> with HydratedMixin {
  InvitationCubit() : super(null) {
    hydrate();
  }

  void reset() => emit(null);

  void setInvitation(Invitation value) => emit(value);

  @override
  Invitation? fromJson(Map<String, dynamic> json) =>
      Invitation.maybeFromJson(json[KeyValues.value] as Json?);

  @override
  Map<String, dynamic>? toJson(Invitation? state) {
    final json = Json();
    json[KeyValues.value] = state?.toJson();
    return json;
  }
}
```

> Use a cubit when you need to pass an object between screens without re-fetching it from the API. Set it before navigating, read it on the next screen via `context.watch<MyCubit>().state`, reset it when done.

---

## Layer 9 — BLoC Provider (`presentation/controllers/<feature>_bloc_provider.dart`)

All blocs and cubits for a feature are registered in a single `List<BlocProvider>`. This list is then spread into the app-level `MultiBlocProvider`.

### Rules

- Create one provider entry per BLoC and per Cubit.
- Use the global singleton instances directly: `create: (context) => myBloc`.
- This file must be exported through the feature's controller index file.

```dart
final List<BlocProvider> myFeatureBlocProvider = [
  BlocProvider<MyActionBloc>(
    create: (context) => myActionBloc,
  ),
  BlocProvider<MultipleResourceBloc>(
    create: (context) => multipleResourceBloc,
  ),
  BlocProvider<MyCubit>(
    create: (context) => myCubit,
  ),
];
```

---

## Layer 10 — Entities (`presentation/entities/`)

Entities are presentation-layer data classes that decouple what a screen *displays* from what the API *returns*. They are purpose-built for UI concerns.

### Rules

- Use an entity when a widget or screen needs a subset of a model, or a transformed/flattened version of it.
- Extend `Equatable` if the entity will be stored in a list, compared, or used in a `ValueNotifier<List<T>>`.
- Implement `List<Object?> get props` when extending `Equatable` — include all fields that determine identity.
- Entities may include UI-specific fields (e.g. `GuestSource` to track whether a guest was added manually or from contacts).
- Provide a `toJson()` method if the entity needs to be sent to the API directly (e.g., as part of a DTO).

### Example — entity with Equatable

```dart
class GuestEntity extends Equatable {
  const GuestEntity({
    required this.firstname,
    required this.lastname,
    required this.source,
    this.email,
    this.phoneNumber,
  });

  final String firstname;
  final String lastname;
  final String? email;
  final String? phoneNumber;
  final GuestSource source; // UI-only field

  // Used when sending guest data to the API
  Json toJson() {
    final json = Json();
    json['firstname'] = firstname;
    json['lastname'] = lastname;
    if (email != null) json['email'] = email;
    if (phoneNumber != null) json['phone_number'] = phoneNumber;
    return json;
  }

  @override
  List<Object?> get props => [firstname, lastname, email, phoneNumber];
}

enum GuestSource { manual, contact }
```

### Example — display-only entity (no Equatable needed)

```dart
// Used only in builder widgets to carry pre-formatted display strings
class InvitationEntity {
  InvitationEntity({
    required this.summary,
    required this.status,
    required this.type,
    required this.date,
  });
  final String summary;
  final String status;
  final String type;
  final String date;
}
```

---

## Layer 11 — Helpers (`presentation/helpers/`)

Helpers are plain Dart classes instantiated with a `BuildContext`. They keep screen `build()` methods clean by extracting dispatching logic, navigation, dialog management, and form initialization.

### Rules

- Every helper takes `BuildContext context` as its only constructor parameter.
- Never store state in a helper — they are instantiated and discarded inline.
- There are two kinds of helpers:

**`<Feature>Helper`** — stateless, for dispatching events, navigation, and opening dialogs.

```dart
class InvitationHelper {
  InvitationHelper(this.context);
  final BuildContext context;

  void fetchInvitations() {
    context.read<MultipleInvitationBloc>().add(FetchInvitations());
  }

  void navigateToCreate() {
    context.read<InvitationCubit>().reset();
    context.goNamed(AppRoutes.createInvitation.name);
  }

  void openDeleteDialog(String id) {
    DialogHelper(context).showDialogV1(
      // ...
    );
  }
}
```

**`<Feature>Controller`** — manages `TextEditingController`s, `ValueNotifier`s, form keys, and form submission. Always `dispose()`d in the screen's `dispose()` override.

```dart
class InvitationController {
  InvitationController(this.context);
  final BuildContext context;

  final formKey = GlobalKey<FormState>();
  final title = TextEditingController();
  final date = ValueNotifier<DateTime?>(null);
  final invitationType = ValueNotifier<InvitationType?>(null);
  final isCreate = ValueNotifier<bool>(true);

  // Call this in initState to pre-fill fields when editing
  void init() {
    final existing = context.read<InvitationCubit>().state;
    if (existing != null) {
      isCreate.value = false;
      if (existing.title != null) title.text = existing.title!;
      if (existing.type != null) invitationType.value = existing.type;
    }
  }

  void submit() {
    if (!formKey.currentState!.validate()) return;
    if (isCreate.value) {
      context.read<InvitationActionBloc>().add(
        CreateInvitation(
          title: title.text,
          type: invitationType.value ?? InvitationType.personal,
          date: date.value ?? DateTime.now(),
        ),
      );
    } else {
      context.read<InvitationActionBloc>().add(
        UpdateInvitation(
          id: context.read<InvitationCubit>().state!.id,
          title: title.text,
        ),
      );
    }
  }

  void dispose() {
    title.dispose();
    date.dispose();
    invitationType.dispose();
    isCreate.dispose();
  }
}
```

> Instantiate a Controller in `initState` and call `dispose()` in the screen's `dispose()`. Instantiate a Helper inline inside methods or `build()` — it has no state to manage.

---

## Layer 12 — Screens (`presentation/screens/`)

Screens are full-page widgets. They wire up the controller, observe BLoC state, and render the UI.

### Rules

- Use `StatefulWidget` for screens that need `initState` and `dispose` (i.e., most screens).
- Use `HookWidget` (from `flutter_hooks`) for screens that use `useState`, `useTextEditingController`, `useEffect`, etc. and do not need a controller class.
- In `initState`, always initialize the controller and dispatch the initial data-fetch event.
- Wrap the screen body in `MultiBlocListener` to react to state changes (toasts, navigation, error display).
- Use `BlocBuilder` inside the widget tree to rebuild in response to state.
- Use the `ScreenFrame` `isLoading` parameter to show a loading overlay — never build your own loading overlay.
- After any successful mutation:
  1. Show a success toast via `ToastHelper(context).showToast(content: '...')`.
  2. Re-trigger the list fetch via the helper.
  3. Navigate (pop or go to detail screen).

### `MultiBlocListener` pattern

```dart
MultiBlocListener(
  listeners: [
    BlocListener<InvitationActionBloc, InvitationActionState>(
      listener: (context, state) {
        if (state is InvitationActionError) {
          controller.error.value = state.error.message;
        } else if (state is InvitationCreated) {
          toastHelper.showToast(content: 'Invitation created!');
          InvitationHelper(context).fetchInvitations();
          context.pop();
        } else if (state is InvitationUpdated) {
          toastHelper.showToast(content: 'Invitation updated!');
          InvitationHelper(context).fetchInvitations();
          context.pop();
        }
      },
    ),
  ],
  child: ScreenFrame(
    isLoading: state is InvitationActionLoading,
    // ...
  ),
)
```

### `BlocBuilder` pattern

```dart
BlocBuilder<MultipleInvitationBloc, MultipleInvitationState>(
  builder: (context, state) {
    if (state is MultipleInvitationLoading) {
      return const LoadingIndicator();
    } else if (state is MultipleInvitationError) {
      return InfoDisplay(title: state.error.message);
    } else if (state is MultipleInvitationLoaded) {
      return InvitationBuilder(
        invitations: state.invitations,
        serializer: (value) => InvitationEntity(
          summary: value.title ?? '',
          status: value.status?.name ?? '',
          type: value.type?.label ?? '',
          date: value.startDate?.toIso8601String() ?? '',
        ),
        onTap: (value) {
          context.read<InvitationCubit>().setInvitation(value);
          context.goNamed(AppRoutes.invitationDetail.name, pathParameters: {'id': value.id});
        },
      );
    }
    return const SizedBox.shrink();
  },
)
```

---

## Layer 13 — Generic Builder Widgets (`presentation/widgets/`)

Builder widgets render lists of items. They use a **serializer pattern** to stay decoupled from the API model type.

### Rules

- Make builders generic: `class MyBuilder<T> extends StatelessWidget`.
- Accept three parameters: `List<T> items`, `MyEntity Function(T) serializer`, and `ValueChanged<T>? onTap`.
- Call `serializer(item)` inside `itemBuilder` to convert the raw model to a display entity.
- Always handle the empty state (return `InfoDisplay` or equivalent).
- Use `SliverList.separated` with `DividerV1` as the separator.
- The callback `onTap` passes back the **raw model `T`**, not the entity — so the caller can act on the full data.

```dart
class InvitationBuilder<T> extends StatelessWidget {
  const InvitationBuilder({
    required this.invitations,
    required this.serializer,
    super.key,
    this.onTap,
    this.padding,
  });

  final List<T> invitations;
  final InvitationEntity Function(T) serializer;
  final ValueChanged<T>? onTap;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    if (invitations.isEmpty) {
      return SliverHelper.buildSliverFillRemaining(
        child: InfoDisplay(title: ContentStrings.nothingHereYet),
      );
    }
    return SliverPadding(
      padding: padding ?? EdgeInsets.zero,
      sliver: SliverList.separated(
        itemCount: invitations.length,
        itemBuilder: (context, index) {
          final item = invitations[index];
          final entity = serializer(item);
          return InvitationItem(
            invitationSummary: entity.summary,
            invitationStatus: entity.status,
            onTap: () => onTap?.call(item),
          );
        },
        separatorBuilder: (context, index) => const DividerV1(),
      ),
    );
  }
}
```

---

## Layer 14 — Extensions

Extensions add computed properties or conversion methods without modifying the original class.

### `data/extensions/` — model extensions

Use for computed values derived from model fields (e.g., calculating a derived date).

```dart
extension InvitationExtension on Invitation {
  // Computes end date from start date + duration fields
  DateTime? calculateEndDate() {
    final d = switch (durationOption) {
      null => Duration(hours: duration ?? 0),
      DurationOption.hours => Duration(hours: duration ?? 0),
      DurationOption.days => Duration(days: duration ?? 0),
      DurationOption.weeks => Duration(days: (duration ?? 0) * 7),
      DurationOption.months => Duration(days: (duration ?? 0) * 30),
      DurationOption.years => Duration(days: (duration ?? 0) * 365),
    };
    return startDate?.add(d);
  }
}
```

### `presentation/extensions/` — presentation type conversions

Use for converting between presentation-layer types (e.g., between a `Contact` from the contacts plugin and `GuestEntity`).

```dart
extension GuestContactExtension on Contact {
  GuestEntity convertToGuest() {
    return GuestEntity(
      firstname: name.first,
      lastname: name.last,
      email: emails.firstOrNull?.address,
      phoneNumber: phones.firstOrNull?.number,
      source: GuestSource.contact,
    );
  }
}

// List extensions for common list operations
extension GuestEntityListExt on List<GuestEntity> {
  List<GuestEntity> sortAlphabetically() {
    return this..sort((a, b) => a.firstname.compareTo(b.firstname));
  }
}
```

---

## Layer 15 — Barrel Exports

Barrel files re-export everything in a layer so consumers use a single import. **Always import from barrels, never from leaf files directly.**

| File                                                       | What it exports                                                           |
|------------------------------------------------------------|---------------------------------------------------------------------------|
| `<feature>/<feature>_index.dart`                           | All of `data/` — models, enums, DTOs, services, repositories, use cases   |
| `presentation/presentation.dart`                           | All of `presentation/` — controllers, entities, helpers, screens, widgets |
| `presentation/controllers/<feature>_controller_index.dart` | All blocs, cubits, and the bloc provider list                             |
| `presentation/screens/<feature>_screens_index.dart`        | All screen widgets                                                        |

Example `<feature>_index.dart`:

```dart
export 'data/domain/invitation_use_cases.dart';
export 'data/enums/invitation_status.dart';
export 'data/enums/invitation_type.dart';
export 'data/models/invitation_model.dart';
export 'data/remote/dto/create_invitation_dto.dart';
export 'data/remote/dto/invitation_params.dart';
export 'data/remote/dto/update_invitation_dto.dart';
export 'data/remote/invitation_repository.dart';
export 'data/remote/invitation_service.dart';
export 'presentation/presentation.dart';
```

---

## Layer 16 — Navigation (`navigation/routes/`)

### Rules

- One route file per feature: `navigation/routes/<feature>_routes.dart`.
- Use `GoRoute` with both `path` and `name` always set.
- Nest child routes using the `routes` parameter.
- For screens that should render over the shell/nav bar (full-screen overlays), add `parentNavigatorKey: rootNavigatorKey` to the child `GoRoute`.
- Navigate with `context.goNamed(AppRoutes.xxx.name)` (replaces current) or `context.pushNamed(...)` (stacks on top).
- Pass path parameters as `pathParameters: {'id': value}` — never encode them manually into the path string.

```dart
final myFeatureRoutes = [
  GoRoute(
    path: AppRoutes.myFeature.path,
    name: AppRoutes.myFeature.name,
    builder: (context, state) => const MyFeatureScreen(),
    routes: [
      GoRoute(
        parentNavigatorKey: rootNavigatorKey, // renders above nav bar
        path: AppRoutes.myDetail.path,
        name: AppRoutes.myDetail.name,
        builder: (context, state) => const MyDetailScreen(),
        routes: [
          GoRoute(
            parentNavigatorKey: rootNavigatorKey,
            path: AppRoutes.mySubDetail.path,
            name: AppRoutes.mySubDetail.name,
            builder: (context, state) => const MySubDetailScreen(),
          ),
        ],
      ),
    ],
  ),
];
```

---

## Core Conventions at a Glance

| Convention             | Rule                                                                                                  |
|------------------------|-------------------------------------------------------------------------------------------------------|
| `Json` type alias      | `Map<String, dynamic>` — always use `Json`, never write the full type                                 |
| Authenticated requests | Pass `reqToken: true` on every `apiClient` call that requires a token                                 |
| Error handling         | `DioException` → `ApiError.handleError(e)` · All others → `ErrorResponse(message: e.toString())`      |
| Result type            | `Either<T, ErrorResponse>` — Left = success, Right = error. Never invert.                             |
| Cubit persistence      | `HydratedMixin` + `hydrate()` + `fromJson`/`toJson` using `KeyValues.value`                           |
| Enum serialization     | Use a custom getter — never depend on `.toString()`, `.index`, or auto-mapping for non-trivial values |
| Theme tokens           | Colors: `colors.xxx.resolve(context)` · Text styles: `$token.textStyle.xxx.resolve(context)`          |
| Global singletons      | Service, repository, use case, BLoC, and Cubit each have one file-level instance                      |
| Imports                | Always import from barrel files (`<feature>_index.dart`, `presentation.dart`)                         |
| Loading state          | Use `ScreenFrame(isLoading: ...)` — never build a manual loading overlay                              |
| Success flow           | Toast → re-fetch list → navigate                                                                      |

---

## Adding a New Feature — Step-by-Step

Follow these steps in order. Do not skip steps or reorder them.

1. Create `lib/features/<feature>/` directory and `<feature>_index.dart` barrel file.
2. Define enums in `data/enums/` — one file per enum, with label and JSON extensions.
3. Define models in `data/models/` — extend `BaseModel` for entity models, plain class otherwise. Add `@JsonSerializable(fieldRename: FieldRename.snake)` and the `part` directive.
4. Run `dart run build_runner build --delete-conflicting-outputs` to generate `.g.dart` files.
5. Define DTOs in `data/remote/dto/` — create, update (with `id`), and params classes as needed.
6. Define the service in `data/remote/<name>_service.dart` — abstract interface + concrete class + singleton.
7. Define the repository in `data/remote/<name>_repository.dart` — abstract interface + concrete class + singleton, returning `Either`.
8. Define use cases in `data/domain/<name>_use_cases.dart` — one class and one singleton per operation.
9. Update `<feature>_index.dart` to export all of the above.
10. Create BLoC triads in `presentation/controllers/blocs/<bloc_name>/` for each async operation.
11. Create Cubits in `presentation/controllers/cubits/<cubit_name>/` for each piece of persistent UI state.
12. Register all blocs and cubits in `presentation/controllers/<feature>_bloc_provider.dart`.
13. Create entities in `presentation/entities/`.
14. Create helpers in `presentation/helpers/` — a `<Feature>Helper` for dispatching/navigation, and a `<Feature>Controller` if the feature has forms.
15. Create screens in `presentation/screens/` — one folder per screen.
16. Create builder and item widgets in `presentation/widgets/`.
17. Update `presentation/presentation.dart` to export everything created above.
18. Add routes in `navigation/routes/<feature>_routes.dart` and register the list in the main router.
19. Add the bloc provider list to the app-level `MultiBlocProvider` in `app.dart`.
