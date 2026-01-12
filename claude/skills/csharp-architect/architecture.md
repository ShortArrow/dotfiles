# Architecture Reference

## Layer Details

### Domain Layer

最も内側のレイヤー。ビジネスロジックの中核。

**依存**: なし（純粋なC#のみ）

**含むもの**:
- Entities
- Value Objects
- Domain Services
- Domain Events
- Repository Interfaces
- Specifications

```csharp
// Domain Layer には以下を含めない
// ❌ フレームワーク依存 (EF Core attributes, etc.)
// ❌ インフラ関連 (HttpClient, File I/O, etc.)
// ❌ プレゼンテーション関連 (ViewModel, etc.)
```

### Application Layer

ユースケースを実装。Domain をオーケストレーション。

**依存**: Domain Layer のみ

**含むもの**:
- Commands / Queries (CQRS)
- Handlers
- DTOs
- Application Services
- Validators
- Mappers

```csharp
// Application Layer の責務
// ✅ ユースケースの実装
// ✅ トランザクション制御
// ✅ 認可チェック
// ❌ ビジネスルール（Domain に委譲）
// ❌ インフラ詳細
```

### Infrastructure Layer

外部システムとの連携を実装。

**依存**: Domain Layer, Application Layer

**含むもの**:
- Repository 実装
- External Service 実装
- Database Context
- Message Queue 実装
- File System 操作

```csharp
// Infrastructure の実装
// ✅ Repository Interface の実装
// ✅ 外部 API クライアント
// ✅ データベースアクセス
// ❌ ビジネスロジック
```

### Presentation Layer

ユーザーインターフェース。MVVM パターン。

**依存**: Application Layer

**含むもの**:
- Views (XAML/Razor)
- ViewModels
- Converters
- Behaviors

```csharp
// Presentation の責務
// ✅ UI ロジック
// ✅ 入力バリデーション（UI レベル）
// ✅ 画面遷移
// ❌ ビジネスロジック
// ❌ データアクセス
```

## Project Structure

```
Solution/
├── src/
│   ├── Domain/
│   │   ├── Entities/
│   │   ├── ValueObjects/
│   │   ├── Services/
│   │   ├── Events/
│   │   ├── Repositories/          # Interfaces only
│   │   └── Specifications/
│   │
│   ├── Application/
│   │   ├── Commands/
│   │   ├── Queries/
│   │   ├── Handlers/
│   │   ├── DTOs/
│   │   ├── Validators/
│   │   ├── Mappers/
│   │   └── Interfaces/            # Application service interfaces
│   │
│   ├── Infrastructure/
│   │   ├── Persistence/
│   │   │   ├── DbContext.cs
│   │   │   ├── Configurations/    # EF Core configurations
│   │   │   └── Repositories/      # Repository implementations
│   │   ├── Services/              # External service implementations
│   │   └── DependencyInjection.cs
│   │
│   └── Presentation/
│       ├── ViewModels/
│       ├── Views/
│       ├── Converters/
│       └── App.xaml
│
└── tests/
    ├── Domain.Tests/
    ├── Application.Tests/
    ├── Infrastructure.Tests/
    └── Presentation.Tests/
```

## Dependency Injection Setup

```csharp
// Infrastructure/DependencyInjection.cs
public static class DependencyInjection
{
    public static IServiceCollection AddInfrastructure(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        // DbContext
        services.AddDbContext<AppDbContext>(options =>
            options.UseSqlServer(configuration.GetConnectionString("Default")));

        // Repositories
        services.AddScoped<IUserRepository, UserRepository>();
        services.AddScoped<IOrderRepository, OrderRepository>();

        // External Services
        services.AddHttpClient<IPaymentService, PaymentService>();

        return services;
    }
}

// Application/DependencyInjection.cs
public static class DependencyInjection
{
    public static IServiceCollection AddApplication(
        this IServiceCollection services)
    {
        // MediatR (CQRS)
        services.AddMediatR(cfg =>
            cfg.RegisterServicesFromAssembly(Assembly.GetExecutingAssembly()));

        // Validators
        services.AddValidatorsFromAssembly(Assembly.GetExecutingAssembly());

        return services;
    }
}
```

## Cross-Cutting Concerns

### Logging

```csharp
// Application Layer で ILogger を使用
public class CreateOrderHandler : IRequestHandler<CreateOrderCommand, Guid>
{
    private readonly ILogger<CreateOrderHandler> _logger;

    public async Task<Guid> Handle(CreateOrderCommand request, CancellationToken ct)
    {
        _logger.LogInformation("Creating order for user {UserId}", request.UserId);
        // ...
    }
}
```

### Validation

```csharp
// FluentValidation in Application Layer
public class CreateOrderCommandValidator : AbstractValidator<CreateOrderCommand>
{
    public CreateOrderCommandValidator()
    {
        RuleFor(x => x.UserId).NotEmpty();
        RuleFor(x => x.Items).NotEmpty();
        RuleForEach(x => x.Items).ChildRules(item =>
        {
            item.RuleFor(x => x.ProductId).NotEmpty();
            item.RuleFor(x => x.Quantity).GreaterThan(0);
        });
    }
}
```

### Exception Handling

```csharp
// Domain Exceptions
public class DomainException : Exception
{
    public DomainException(string message) : base(message) { }
}

public class EntityNotFoundException : DomainException
{
    public EntityNotFoundException(string entity, object id)
        : base($"{entity} with id '{id}' was not found.") { }
}

// Application Layer で catch して適切に処理
```
