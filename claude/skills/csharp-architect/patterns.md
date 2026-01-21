# Implementation Patterns

## DDD Patterns

### Entity Base Class

```csharp
public abstract class Entity<TId> : IEquatable<Entity<TId>>
    where TId : notnull
{
    public TId Id { get; protected set; } = default!;

    public override bool Equals(object? obj)
        => obj is Entity<TId> entity && Id.Equals(entity.Id);

    public bool Equals(Entity<TId>? other)
        => other is not null && Id.Equals(other.Id);

    public override int GetHashCode() => Id.GetHashCode();

    public static bool operator ==(Entity<TId>? left, Entity<TId>? right)
        => Equals(left, right);

    public static bool operator !=(Entity<TId>? left, Entity<TId>? right)
        => !Equals(left, right);
}
```

### Value Object Base Class

```csharp
public abstract class ValueObject : IEquatable<ValueObject>
{
    protected abstract IEnumerable<object?> GetEqualityComponents();

    public override bool Equals(object? obj)
        => obj is ValueObject other && Equals(other);

    public bool Equals(ValueObject? other)
    {
        if (other is null) return false;
        return GetEqualityComponents()
            .SequenceEqual(other.GetEqualityComponents());
    }

    public override int GetHashCode()
    {
        return GetEqualityComponents()
            .Aggregate(0, (hash, component) =>
                HashCode.Combine(hash, component?.GetHashCode() ?? 0));
    }

    public static bool operator ==(ValueObject? left, ValueObject? right)
        => Equals(left, right);

    public static bool operator !=(ValueObject? left, ValueObject? right)
        => !Equals(left, right);
}
```

### Aggregate Root

```csharp
public abstract class AggregateRoot<TId> : Entity<TId>
    where TId : notnull
{
    private readonly List<IDomainEvent> _domainEvents = [];

    public IReadOnlyCollection<IDomainEvent> DomainEvents
        => _domainEvents.AsReadOnly();

    protected void AddDomainEvent(IDomainEvent domainEvent)
        => _domainEvents.Add(domainEvent);

    public void ClearDomainEvents() => _domainEvents.Clear();
}
```

### Domain Event

```csharp
public interface IDomainEvent
{
    DateTime OccurredOn { get; }
}

public abstract record DomainEvent : IDomainEvent
{
    public DateTime OccurredOn { get; } = DateTime.UtcNow;
}

// Example
public record OrderCreatedEvent(Guid OrderId, Guid UserId) : DomainEvent;
```

### Specification Pattern

```csharp
public abstract class Specification<T>
{
    public abstract Expression<Func<T, bool>> ToExpression();

    public bool IsSatisfiedBy(T entity)
        => ToExpression().Compile()(entity);

    public Specification<T> And(Specification<T> other)
        => new AndSpecification<T>(this, other);

    public Specification<T> Or(Specification<T> other)
        => new OrSpecification<T>(this, other);

    public Specification<T> Not()
        => new NotSpecification<T>(this);
}

// Example
public class ActiveUserSpecification : Specification<User>
{
    public override Expression<Func<User, bool>> ToExpression()
        => user => user.IsActive && !user.IsDeleted;
}
```

## CQRS Patterns

### Command

```csharp
// Command with no result
public record DeleteUserCommand(Guid UserId) : IRequest;

// Command with result
public record CreateOrderCommand(
    Guid UserId,
    List<OrderItemDto> Items
) : IRequest<Guid>;
```

### Query

```csharp
public record GetUserByIdQuery(Guid UserId) : IRequest<UserDto?>;

public record GetOrdersQuery(
    Guid? UserId = null,
    DateTime? FromDate = null,
    int PageNumber = 1,
    int PageSize = 10
) : IRequest<PagedResult<OrderDto>>;
```

### Handler

```csharp
public class CreateOrderHandler : IRequestHandler<CreateOrderCommand, Guid>
{
    private readonly IOrderRepository _orderRepository;
    private readonly IUnitOfWork _unitOfWork;

    public CreateOrderHandler(
        IOrderRepository orderRepository,
        IUnitOfWork unitOfWork)
    {
        _orderRepository = orderRepository;
        _unitOfWork = unitOfWork;
    }

    public async Task<Guid> Handle(
        CreateOrderCommand request,
        CancellationToken cancellationToken)
    {
        var order = Order.Create(request.UserId, request.Items);

        await _orderRepository.AddAsync(order, cancellationToken);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return order.Id;
    }
}
```

### Pipeline Behavior (Validation)

```csharp
public class ValidationBehavior<TRequest, TResponse>
    : IPipelineBehavior<TRequest, TResponse>
    where TRequest : notnull
{
    private readonly IEnumerable<IValidator<TRequest>> _validators;

    public ValidationBehavior(IEnumerable<IValidator<TRequest>> validators)
        => _validators = validators;

    public async Task<TResponse> Handle(
        TRequest request,
        RequestHandlerDelegate<TResponse> next,
        CancellationToken cancellationToken)
    {
        if (!_validators.Any()) return await next();

        var context = new ValidationContext<TRequest>(request);

        var failures = (await Task.WhenAll(
            _validators.Select(v => v.ValidateAsync(context, cancellationToken))))
            .SelectMany(r => r.Errors)
            .Where(f => f is not null)
            .ToList();

        if (failures.Count != 0)
            throw new ValidationException(failures);

        return await next();
    }
}
```

## MVVM Patterns

### ViewModel Base

```csharp
public abstract class ViewModelBase : INotifyPropertyChanged
{
    public event PropertyChangedEventHandler? PropertyChanged;

    protected virtual void OnPropertyChanged([CallerMemberName] string? name = null)
        => PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(name));

    protected bool SetProperty<T>(
        ref T field,
        T value,
        [CallerMemberName] string? name = null)
    {
        if (EqualityComparer<T>.Default.Equals(field, value))
            return false;

        field = value;
        OnPropertyChanged(name);
        return true;
    }
}
```

### Relay Command

```csharp
public class RelayCommand : ICommand
{
    private readonly Action<object?> _execute;
    private readonly Func<object?, bool>? _canExecute;

    public RelayCommand(Action<object?> execute, Func<object?, bool>? canExecute = null)
    {
        _execute = execute ?? throw new ArgumentNullException(nameof(execute));
        _canExecute = canExecute;
    }

    public event EventHandler? CanExecuteChanged;

    public bool CanExecute(object? parameter) => _canExecute?.Invoke(parameter) ?? true;

    public void Execute(object? parameter) => _execute(parameter);

    public void RaiseCanExecuteChanged() => CanExecuteChanged?.Invoke(this, EventArgs.Empty);
}

public class RelayCommand<T> : ICommand
{
    private readonly Action<T?> _execute;
    private readonly Func<T?, bool>? _canExecute;

    public RelayCommand(Action<T?> execute, Func<T?, bool>? canExecute = null)
    {
        _execute = execute ?? throw new ArgumentNullException(nameof(execute));
        _canExecute = canExecute;
    }

    public event EventHandler? CanExecuteChanged;

    public bool CanExecute(object? parameter) => _canExecute?.Invoke((T?)parameter) ?? true;

    public void Execute(object? parameter) => _execute((T?)parameter);

    public void RaiseCanExecuteChanged() => CanExecuteChanged?.Invoke(this, EventArgs.Empty);
}
```

### Async Relay Command

```csharp
public class AsyncRelayCommand : ICommand
{
    private readonly Func<object?, Task> _execute;
    private readonly Func<object?, bool>? _canExecute;
    private bool _isExecuting;

    public AsyncRelayCommand(
        Func<object?, Task> execute,
        Func<object?, bool>? canExecute = null)
    {
        _execute = execute ?? throw new ArgumentNullException(nameof(execute));
        _canExecute = canExecute;
    }

    public event EventHandler? CanExecuteChanged;

    public bool CanExecute(object? parameter)
        => !_isExecuting && (_canExecute?.Invoke(parameter) ?? true);

    public async void Execute(object? parameter)
    {
        if (_isExecuting) return;

        _isExecuting = true;
        RaiseCanExecuteChanged();

        try
        {
            await _execute(parameter);
        }
        finally
        {
            _isExecuting = false;
            RaiseCanExecuteChanged();
        }
    }

    public void RaiseCanExecuteChanged()
        => CanExecuteChanged?.Invoke(this, EventArgs.Empty);
}
```

### ViewModel ↔ View 通信パターン比較

| 名称 | 種別 | 主な用途 | VM→View | View→VM | 典型例 | 注意点 |
|------|------|----------|---------|---------|--------|--------|
| **INotifyPropertyChanged** | インターフェイス | 1プロパティの変更通知（Binding更新） | ✅（状態通知） | — | Text/IsEnabled/Visible相当 | 命令系（Close/ShowDialog等）には不向き |
| **INotifyCollectionChanged** (ObservableCollection) | インターフェイス/実装 | コレクションの追加/削除/並び替え通知 | ✅（Items更新） | — | ListBox Items / DataGrid Rows | 要素自体の変更は要素側INPCも必要になりがち |
| **ICommand** | インターフェイス | 操作の起点（ボタン等） | △（CanExecuteで有効/無効） | ✅ | Button Command / MenuItem Command | 非同期や例外処理は自前実装だと面倒 |
| **ReactiveCommand** | クラス（ReactiveUI） | ICommand強化（非同期・例外・状態ストリーム） | ✅（IsExecuting等で状態反映しやすい） | ✅ | `SaveCommand = ReactiveCommand.CreateFromTask(...)` | ReactiveUI前提。学習コストあり |
| **Interaction** (ReactiveUI等) | クラス/パターン | VM→Viewへ「UI処理依頼」（Dialog/Picker/Close） | ✅（命令系） | —（戻り値は返せる） | Confirmダイアログ、OpenFile、通知 | View側でハンドラ登録が必要。多用すると流れが散る |
| **MessageBus / Messenger** | パターン/仕組み | 疎結合イベント（画面/VM跨ぎ） | ✅ | ✅ | "保存完了"を全体へ通知、ナビ要求 | 追跡が難しくなりがち。乱用注意 |
| **AttachedProperty** | Avaloniaの仕組み | View都合の機能をBinding可能に（Focus/Scroll等） | ✅（VMの状態でViewが動く） | — | `IsFocused`、`ScrollToEnd` | 実装コスト高め。UI依存が入りやすい |
| **Behavior** (Interactivity) | パターン | Viewイベント→Command、UI操作の切り出し | ✅/✅（両方向に組める） | ✅ | EventTrigger→Command、フォーカス移動 | パッケージ依存＆デバッグがやや大変 |

**選定ガイドライン**:
- 状態の同期 → `INotifyPropertyChanged` + `ObservableCollection`
- ユーザー操作の受付 → `ICommand` (シンプル) / `ReactiveCommand` (高機能)
- VMからView への命令 → `Interaction` / `MessageBus`
- View固有の振る舞い → `AttachedProperty` / `Behavior`

### Avalonia / MVVM 連携・通知・入力検証 まとめ

| 名称 | 種別 | 主な用途 | VM→View | View→VM | 典型例 | 注意点 |
|------|------|----------|---------|---------|--------|--------|
| **INotifyPropertyChanged** | インターフェイス | プロパティ変更通知（Binding更新） | ✅ | — | Text/IsEnabled/Visible相当 | 命令系（Close/ShowDialog等）には不向き |
| **INotifyCollectionChanged** (ObservableCollection) | インターフェイス/実装 | コレクション変更通知 | ✅ | — | ListBox Items / DataGrid Rows | 要素の中身変更は要素側INPCも必要になりがち |
| **ICommand** | インターフェイス | 操作実行（ボタン等） | △（CanExecute） | ✅ | Button / MenuItem | 非同期・例外・多重実行制御は自前だと面倒 |
| **ReactiveCommand** | クラス（ReactiveUI） | ICommand強化（非同期・状態・例外） | ✅ | ✅ | Create / CreateFromTask | ReactiveUI前提。流儀に寄る |
| **Interaction** (ReactiveUI等) | クラス/パターン | VM→ViewへUI処理依頼（Dialog等） | ✅ | —（戻り値は返せる） | Confirm/OpenFile/Close | View側ハンドラ必須。散らかりやすい |
| **MessageBus / Messenger** | パターン/仕組み | 疎結合通知（画面/VM跨ぎ） | ✅ | ✅ | 保存完了通知、ナビ要求 | 受信箇所が追いにくい。乱用注意 |
| **AttachedProperty** | Avalonia機構 | UI都合の機能をBinding化 | ✅ | — | Focus/Scroll/Selection制御 | 実装コスト高め、UI依存が入りやすい |
| **Behavior** (Interactivity) | パターン | Viewイベント→Command、UI操作の分離 | ✅/✅ | ✅ | EventTrigger→Command | パッケージ依存・デバッグ難しめ |
| **INotifyDataErrorInfo** | インターフェイス | 入力バリデーション（プロパティ単位のエラー通知） | ✅（Errorsで反映） | — | TextBoxの入力エラー表示 | 実装がやや手間。非同期検証もやるなら設計要 |
| **DataAnnotations** (`System.ComponentModel.DataAnnotations`) | 属性 + 検証API | 必須/範囲/正規表現など宣言的検証 | ✅（INotifyDataErrorInfo等と連携して表示） | — | `[Required]`, `[Range]` | "属性だけ"ではUIに自動反映されないので、橋渡しが必要 |
| **ValidationRules** (Avalonia) | 仕組み/ルール | Bindingの検証（変換・条件チェック） | ✅（Validation.Errorsで反映） | ✅（入力→検証） | `TextBox` の Binding に検証 | ルールがView寄りになりがち（VM外で検証が散る） |
| **Exceptionベース検証**（変換/更新時例外） | パターン | パース失敗などを例外で弾く | ✅（エラーとして扱える） | ✅ | 数値入力のparse失敗 | 例外をロジックに使いすぎると追いづらい |

### 層間インタラクション表（Avalonia / MVVM + Clean Architecture）

| From → To | 役割/目的 | 推奨インタラクション | データ形 | 依存の向き | 例 | 注意点 |
|-----------|-----------|----------------------|----------|------------|-----|--------|
| **View → VM** | ユーザー操作の入力 | **Command**（ICommand/ReactiveCommand） | パラメータ/入力DTO | View → VM | Save/Cancel/検索 | Viewにロジックを置かない |
| **View → VM** | 入力の反映 | **TwoWay Binding** + **INPC** | プリミティブ/VM用モデル | View ↔ VM | TextBox.Text ↔ Name | 入力整形はVM側に寄せることが多い |
| **View → VM** | イベントをCommand化 | **Behavior/Trigger** | EventArgs→CommandParam | View → VM | KeyDownで確定 | 乱用するとXAMLが複雑化 |
| **VM → View** | 状態通知（表示更新） | **INotifyPropertyChanged** | 状態（IsBusy等） | VM → View | Busy/Progress/ErrorText | "状態"に落として通知する |
| **VM → View** | UI命令（ダイアログ等） | **Interaction**（推奨）/ RequestCloseイベント | request/response | VM → View | Confirm/Picker/Close | UI依存をVMから追い出す |
| **VM ↔ UseCase** | アプリ操作の実行 | **メソッド呼び出し（async）** / **IObservable** | Input/Output DTO | VM → UseCase | `await uc.Save(input)` | UIスレッド制御はVM側で吸収 |
| **UseCase → VM** | 結果/失敗の返却 | **戻り値(Result\<T\>)** / 例外（方針次第） | Result/DTO | UseCase → VM | `Result<SaveOutput>` | 例外は"予期しない障害"に限定しがち |
| **UseCase ↔ Domain** | ドメイン規則の実行 | **ドメインメソッド呼び出し** | Entity/VO | UseCase → Domain | `order.Pay(...)` | DomainはUI/Infraを知らない |
| **Domain → UseCase** | ドメインイベント | **Domain Event（in-memory）** | Eventオブジェクト | Domain →（収集） | `OrderPaid` | 発火→収集→UseCaseが処理、が多い |
| **UseCase ↔ Infra** | 永続化・外部I/O | **Port/Interface**（Repository/Gateway等） | Domain/DTO | UseCase → Port（実装はInfra） | `IOrderRepository` | 依存逆転：UseCaseがIFを定義する流儀が多い |
| **Infra → UseCase/Domain** | 実装提供 | **DIで注入** | 実装クラス | Infra →（注入されるだけ） | DB/HTTP/FS | Infraは上位層を参照しない（参照すると泥沼） |
| **VM ↔ VM** | 画面間連携 | **Navigator（専用IF）** / **MessageBus**（必要最小限） | Route/Message | VM →（専用IF推奨） | 画面遷移/タブ追加 | MessageBus乱用は追跡性が落ちる |

### 「どこに何を置くか」最短ガイド

| 層 | 責務 |
|----|------|
| **View** | 見た目・イベントの橋渡し（Behavior/InteractionHandler） |
| **VM** | UI状態（INPC）と操作（Command）。UseCase呼び出し、結果を状態に変換 |
| **UseCase** | アプリの手順（トランザクション、権限、ワークフロー、ポート呼び出し） |
| **Domain** | 業務ルール（Entity/VO/Domain Service/Domain Event） |
| **Infra** | DB/HTTP/FS/OS/外部ライブラリ実装（Repository等） |

### 実装パターンの"型"（Avalonia + Clean）

| 層 | 実装パターン |
|----|-------------|
| **View** | Interactionのハンドラだけ持つ（Dialog/Picker/Close） |
| **VM** | ReactiveCommand（or ICommand）→ `await UseCase.Execute()` → INPCで状態更新 |
| **UseCase** | IRepository 等の Port を使ってDomainを進め、`Result<T>`で戻す |
| **Domain** | 純粋ロジック、例外は"不変条件違反"などに限定 |
| **Infra** | Port実装、失敗はInfra例外→UseCaseでResultに変換（方針統一） |

## TDD Patterns

### ハードウェア/OS依存の抽象化

| 依存対象 | 抽象化 | パッケージ/名前空間 | テスト時の差し替え | 典型的な用途 | 注意点 |
|----------|--------|-------------------|-------------------|--------------|--------|
| **現在時刻** | `TimeProvider` | .NET 8+ 標準 | `FakeTimeProvider` | 日時判定、有効期限、タイムアウト | .NET 8未満は自前`IClock`が多い |
| **現在時刻** | `IClock` (NodaTime) | NodaTime | `FakeClock` | 日時計算、タイムゾーン処理 | NodaTime流儀に寄せるなら強力 |
| **スケジューラ** | `IScheduler` | System.Reactive | `TestScheduler` | Timer、Delay、Interval、非同期ストリーム | `AdvanceTo`/`AdvanceBy`で時間制御 |
| **ファイルシステム** | `IFileSystem` | System.IO.Abstractions | `MockFileSystem` | ファイル読み書き、ディレクトリ操作 | 実FS使うE2Eも別途必要になりがち |
| **環境変数** | `IEnvironment` | 自前 or ライブラリ | Mock/Fake | `GetEnvironmentVariable`、`MachineName` | 標準がないので自前定義が多い |
| **コンソールI/O** | `IConsole` | 自前 or Spectre.Console等 | `TestConsole` | CLI入出力、プログレス表示 | Spectre.ConsoleはTestConsole提供 |
| **HTTP通信** | `IHttpClientFactory` | Microsoft.Extensions.Http | `MockHttpMessageHandler` | 外部API呼び出し | `HttpClient`直接newは避ける |
| **乱数** | `Random` (seed固定) / 自前`IRandom` | 標準 / 自前 | seed固定 or Mock | ランダム生成、シャッフル | .NET 6+ `Random.Shared`は注入困難 |
| **Guid生成** | `IGuidGenerator` | 自前 | 固定値返すFake | ID生成 | 標準がないので自前定義 |
| **日付のみ** | `DateOnly`/`TimeOnly` + `TimeProvider` | .NET 6+ | `FakeTimeProvider` | 日付比較、営業日計算 | `DateTime.Now`直接参照を避ける |
| **クリップボード** | `IClipboard` | TextCopy | `MockClipboard` | テキストのコピー/ペースト | クロスプラットフォーム対応。DI対応 |
| **クリップボード** | `IClipboard` (Avalonia) | Avalonia.Input.Platform | 自前ラッパー必要 | Avalonia UI内でのコピペ | 11.1.4+で`NotClientImplementable`、直接モック不可 |
| **クリップボード** | `IClipboard` (MAUI) | Microsoft.Maui.ApplicationModel | Mock/Fake | MAUIアプリのコピペ | MAUI環境専用 |

### 抽象化の設計指針

| 方針 | 説明 |
|------|------|
| **薄いラッパーに留める** | 抽象化は最小限のメソッドのみ。機能を増やしすぎない |
| **静的メソッド回避** | `DateTime.Now`、`File.ReadAllText`等の静的呼び出しを避け、注入可能にする |
| **Infraに実装配置** | 本番用実装（RealFileSystem等）はInfra層に置く |
| **Fakeはテストプロジェクトに** | `FakeTimeProvider`等はテストプロジェクト or 共通テストユーティリティに |
| **E2Eは実物で** | 単体テストはFake、E2E/統合テストでは実際のFS/HTTP等を使う |

### プラットフォーム固有の注意事項

**Avalonia `IClipboard` (11.1.4+)**

`[NotClientImplementable]`属性が付与され、ユーザーコードでの実装が禁止された。テスト時に直接モックできないため、自前でラッパーを定義する：

```csharp
// 自前の抽象化（Application/Domain層に定義）
public interface IClipboardService
{
    Task SetTextAsync(string? text);
    Task<string?> GetTextAsync();
}

// 本番用実装（Infra層）
public class AvaloniaClipboardService : IClipboardService
{
    private readonly IClipboard _clipboard;

    public AvaloniaClipboardService(TopLevel topLevel)
        => _clipboard = topLevel.Clipboard!;

    public Task SetTextAsync(string? text) => _clipboard.SetTextAsync(text);
    public Task<string?> GetTextAsync() => _clipboard.GetTextAsync();
}

// テスト用Fake
public class FakeClipboardService : IClipboardService
{
    public string? Text { get; private set; }
    public Task SetTextAsync(string? text) { Text = text; return Task.CompletedTask; }
    public Task<string?> GetTextAsync() => Task.FromResult(Text);
}
```

## Repository Pattern

### Interface

```csharp
public interface IRepository<T, TId>
    where T : AggregateRoot<TId>
    where TId : notnull
{
    Task<T?> GetByIdAsync(TId id, CancellationToken ct = default);
    Task<IReadOnlyList<T>> GetAllAsync(CancellationToken ct = default);
    Task AddAsync(T entity, CancellationToken ct = default);
    void Update(T entity);
    void Remove(T entity);
}
```

### Implementation

```csharp
public class Repository<T, TId> : IRepository<T, TId>
    where T : AggregateRoot<TId>
    where TId : notnull
{
    protected readonly AppDbContext Context;
    protected readonly DbSet<T> DbSet;

    public Repository(AppDbContext context)
    {
        Context = context;
        DbSet = context.Set<T>();
    }

    public virtual async Task<T?> GetByIdAsync(TId id, CancellationToken ct = default)
        => await DbSet.FindAsync([id], ct);

    public virtual async Task<IReadOnlyList<T>> GetAllAsync(CancellationToken ct = default)
        => await DbSet.ToListAsync(ct);

    public virtual async Task AddAsync(T entity, CancellationToken ct = default)
        => await DbSet.AddAsync(entity, ct);

    public virtual void Update(T entity)
        => DbSet.Update(entity);

    public virtual void Remove(T entity)
        => DbSet.Remove(entity);
}
```

## Unit of Work Pattern

```csharp
public interface IUnitOfWork
{
    Task<int> SaveChangesAsync(CancellationToken ct = default);
}

public class UnitOfWork : IUnitOfWork
{
    private readonly AppDbContext _context;

    public UnitOfWork(AppDbContext context) => _context = context;

    public async Task<int> SaveChangesAsync(CancellationToken ct = default)
        => await _context.SaveChangesAsync(ct);
}
```

## Result Pattern

```csharp
public class Result
{
    public bool IsSuccess { get; }
    public bool IsFailure => !IsSuccess;
    public string Error { get; }

    protected Result(bool isSuccess, string error)
    {
        IsSuccess = isSuccess;
        Error = error;
    }

    public static Result Success() => new(true, string.Empty);
    public static Result Failure(string error) => new(false, error);
    public static Result<T> Success<T>(T value) => new(value, true, string.Empty);
    public static Result<T> Failure<T>(string error) => new(default!, false, error);
}

public class Result<T> : Result
{
    public T Value { get; }

    protected internal Result(T value, bool isSuccess, string error)
        : base(isSuccess, error)
    {
        Value = value;
    }
}
```
