# Implementation Examples

## Complete Feature: Order Management

この例では、注文管理機能を MVVM × Clean Architecture × TDD × CQRS × DDD で実装します。

### Domain Layer

#### Value Objects

```csharp
// Domain/ValueObjects/Money.cs
public sealed class Money : ValueObject
{
    public decimal Amount { get; }
    public string Currency { get; }

    private Money(decimal amount, string currency)
    {
        Amount = amount;
        Currency = currency;
    }

    public static Money Create(decimal amount, string currency = "JPY")
    {
        if (amount < 0)
            throw new DomainException("Amount cannot be negative");
        if (string.IsNullOrWhiteSpace(currency))
            throw new DomainException("Currency is required");

        return new Money(amount, currency.ToUpperInvariant());
    }

    public Money Add(Money other)
    {
        if (Currency != other.Currency)
            throw new DomainException("Cannot add different currencies");
        return Create(Amount + other.Amount, Currency);
    }

    protected override IEnumerable<object?> GetEqualityComponents()
    {
        yield return Amount;
        yield return Currency;
    }
}
```

```csharp
// Domain/ValueObjects/Address.cs
public sealed class Address : ValueObject
{
    public string Street { get; }
    public string City { get; }
    public string PostalCode { get; }
    public string Country { get; }

    private Address(string street, string city, string postalCode, string country)
    {
        Street = street;
        City = city;
        PostalCode = postalCode;
        Country = country;
    }

    public static Address Create(string street, string city, string postalCode, string country)
    {
        if (string.IsNullOrWhiteSpace(street))
            throw new DomainException("Street is required");
        if (string.IsNullOrWhiteSpace(city))
            throw new DomainException("City is required");

        return new Address(street, city, postalCode, country);
    }

    protected override IEnumerable<object?> GetEqualityComponents()
    {
        yield return Street;
        yield return City;
        yield return PostalCode;
        yield return Country;
    }
}
```

#### Entity

```csharp
// Domain/Entities/OrderItem.cs
public class OrderItem : Entity<Guid>
{
    public Guid ProductId { get; private set; }
    public string ProductName { get; private set; } = string.Empty;
    public int Quantity { get; private set; }
    public Money UnitPrice { get; private set; } = null!;

    private OrderItem() { } // EF Core

    internal OrderItem(Guid productId, string productName, int quantity, Money unitPrice)
    {
        Id = Guid.NewGuid();
        ProductId = productId;
        ProductName = productName;
        Quantity = quantity;
        UnitPrice = unitPrice;
    }

    public Money GetTotalPrice() => Money.Create(UnitPrice.Amount * Quantity, UnitPrice.Currency);

    public void UpdateQuantity(int newQuantity)
    {
        if (newQuantity <= 0)
            throw new DomainException("Quantity must be positive");
        Quantity = newQuantity;
    }
}
```

#### Aggregate Root

```csharp
// Domain/Entities/Order.cs
public class Order : AggregateRoot<Guid>
{
    private readonly List<OrderItem> _items = [];

    public Guid UserId { get; private set; }
    public Address ShippingAddress { get; private set; } = null!;
    public OrderStatus Status { get; private set; }
    public DateTime CreatedAt { get; private set; }
    public IReadOnlyCollection<OrderItem> Items => _items.AsReadOnly();

    private Order() { } // EF Core

    public static Order Create(Guid userId, Address shippingAddress)
    {
        var order = new Order
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            ShippingAddress = shippingAddress,
            Status = OrderStatus.Pending,
            CreatedAt = DateTime.UtcNow
        };

        order.AddDomainEvent(new OrderCreatedEvent(order.Id, userId));
        return order;
    }

    public void AddItem(Guid productId, string productName, int quantity, Money unitPrice)
    {
        if (Status != OrderStatus.Pending)
            throw new DomainException("Cannot modify non-pending order");

        var existingItem = _items.FirstOrDefault(i => i.ProductId == productId);
        if (existingItem is not null)
        {
            existingItem.UpdateQuantity(existingItem.Quantity + quantity);
        }
        else
        {
            _items.Add(new OrderItem(productId, productName, quantity, unitPrice));
        }
    }

    public Money GetTotalAmount()
    {
        if (_items.Count == 0)
            return Money.Create(0);

        return _items
            .Select(i => i.GetTotalPrice())
            .Aggregate((a, b) => a.Add(b));
    }

    public void Confirm()
    {
        if (Status != OrderStatus.Pending)
            throw new DomainException("Only pending orders can be confirmed");
        if (_items.Count == 0)
            throw new DomainException("Cannot confirm empty order");

        Status = OrderStatus.Confirmed;
        AddDomainEvent(new OrderConfirmedEvent(Id));
    }

    public void Cancel()
    {
        if (Status == OrderStatus.Shipped || Status == OrderStatus.Delivered)
            throw new DomainException("Cannot cancel shipped or delivered order");

        Status = OrderStatus.Cancelled;
        AddDomainEvent(new OrderCancelledEvent(Id));
    }
}

public enum OrderStatus
{
    Pending,
    Confirmed,
    Shipped,
    Delivered,
    Cancelled
}
```

#### Repository Interface

```csharp
// Domain/Repositories/IOrderRepository.cs
public interface IOrderRepository : IRepository<Order, Guid>
{
    Task<IReadOnlyList<Order>> GetByUserIdAsync(Guid userId, CancellationToken ct = default);
    Task<Order?> GetWithItemsAsync(Guid id, CancellationToken ct = default);
}
```

### Application Layer

#### DTOs

```csharp
// Application/DTOs/OrderDto.cs
public record OrderDto(
    Guid Id,
    Guid UserId,
    string Status,
    decimal TotalAmount,
    DateTime CreatedAt,
    List<OrderItemDto> Items
);

public record OrderItemDto(
    Guid ProductId,
    string ProductName,
    int Quantity,
    decimal UnitPrice
);

public record CreateOrderItemDto(
    Guid ProductId,
    int Quantity
);
```

#### Command

```csharp
// Application/Commands/CreateOrderCommand.cs
public record CreateOrderCommand(
    Guid UserId,
    string Street,
    string City,
    string PostalCode,
    string Country,
    List<CreateOrderItemDto> Items
) : IRequest<Guid>;
```

#### Validator

```csharp
// Application/Validators/CreateOrderCommandValidator.cs
public class CreateOrderCommandValidator : AbstractValidator<CreateOrderCommand>
{
    public CreateOrderCommandValidator()
    {
        RuleFor(x => x.UserId).NotEmpty();
        RuleFor(x => x.Street).NotEmpty().MaximumLength(200);
        RuleFor(x => x.City).NotEmpty().MaximumLength(100);
        RuleFor(x => x.Items).NotEmpty().WithMessage("Order must have at least one item");

        RuleForEach(x => x.Items).ChildRules(item =>
        {
            item.RuleFor(x => x.ProductId).NotEmpty();
            item.RuleFor(x => x.Quantity).GreaterThan(0);
        });
    }
}
```

#### Handler

```csharp
// Application/Handlers/CreateOrderHandler.cs
public class CreateOrderHandler : IRequestHandler<CreateOrderCommand, Guid>
{
    private readonly IOrderRepository _orderRepository;
    private readonly IProductService _productService;
    private readonly IUnitOfWork _unitOfWork;
    private readonly ILogger<CreateOrderHandler> _logger;

    public CreateOrderHandler(
        IOrderRepository orderRepository,
        IProductService productService,
        IUnitOfWork unitOfWork,
        ILogger<CreateOrderHandler> logger)
    {
        _orderRepository = orderRepository;
        _productService = productService;
        _unitOfWork = unitOfWork;
        _logger = logger;
    }

    public async Task<Guid> Handle(CreateOrderCommand request, CancellationToken ct)
    {
        _logger.LogInformation("Creating order for user {UserId}", request.UserId);

        var address = Address.Create(
            request.Street,
            request.City,
            request.PostalCode,
            request.Country);

        var order = Order.Create(request.UserId, address);

        foreach (var item in request.Items)
        {
            var product = await _productService.GetByIdAsync(item.ProductId, ct)
                ?? throw new EntityNotFoundException("Product", item.ProductId);

            var unitPrice = Money.Create(product.Price);
            order.AddItem(item.ProductId, product.Name, item.Quantity, unitPrice);
        }

        await _orderRepository.AddAsync(order, ct);
        await _unitOfWork.SaveChangesAsync(ct);

        _logger.LogInformation("Order {OrderId} created successfully", order.Id);
        return order.Id;
    }
}
```

#### Query

```csharp
// Application/Queries/GetOrderByIdQuery.cs
public record GetOrderByIdQuery(Guid OrderId) : IRequest<OrderDto?>;

// Application/Handlers/GetOrderByIdHandler.cs
public class GetOrderByIdHandler : IRequestHandler<GetOrderByIdQuery, OrderDto?>
{
    private readonly IOrderRepository _orderRepository;

    public GetOrderByIdHandler(IOrderRepository orderRepository)
        => _orderRepository = orderRepository;

    public async Task<OrderDto?> Handle(GetOrderByIdQuery request, CancellationToken ct)
    {
        var order = await _orderRepository.GetWithItemsAsync(request.OrderId, ct);
        if (order is null) return null;

        return new OrderDto(
            order.Id,
            order.UserId,
            order.Status.ToString(),
            order.GetTotalAmount().Amount,
            order.CreatedAt,
            order.Items.Select(i => new OrderItemDto(
                i.ProductId,
                i.ProductName,
                i.Quantity,
                i.UnitPrice.Amount
            )).ToList()
        );
    }
}
```

### Infrastructure Layer

```csharp
// Infrastructure/Persistence/Repositories/OrderRepository.cs
public class OrderRepository : Repository<Order, Guid>, IOrderRepository
{
    public OrderRepository(AppDbContext context) : base(context) { }

    public async Task<IReadOnlyList<Order>> GetByUserIdAsync(Guid userId, CancellationToken ct)
        => await DbSet
            .Where(o => o.UserId == userId)
            .OrderByDescending(o => o.CreatedAt)
            .ToListAsync(ct);

    public async Task<Order?> GetWithItemsAsync(Guid id, CancellationToken ct)
        => await DbSet
            .Include(o => o.Items)
            .FirstOrDefaultAsync(o => o.Id == id, ct);
}
```

### Presentation Layer (MVVM)

```csharp
// Presentation/ViewModels/OrderViewModel.cs
public class OrderViewModel : ViewModelBase
{
    private readonly IMediator _mediator;
    private OrderDto? _order;
    private bool _isLoading;

    public OrderViewModel(IMediator mediator)
    {
        _mediator = mediator;
        LoadOrderCommand = new AsyncRelayCommand(LoadOrderAsync);
        ConfirmOrderCommand = new AsyncRelayCommand(ConfirmOrderAsync, _ => CanConfirm);
    }

    public OrderDto? Order
    {
        get => _order;
        private set => SetProperty(ref _order, value);
    }

    public bool IsLoading
    {
        get => _isLoading;
        private set => SetProperty(ref _isLoading, value);
    }

    public bool CanConfirm => Order?.Status == "Pending";

    public Guid OrderId { get; set; }

    public ICommand LoadOrderCommand { get; }
    public ICommand ConfirmOrderCommand { get; }

    private async Task LoadOrderAsync(object? _)
    {
        IsLoading = true;
        try
        {
            Order = await _mediator.Send(new GetOrderByIdQuery(OrderId));
        }
        finally
        {
            IsLoading = false;
        }
    }

    private async Task ConfirmOrderAsync(object? _)
    {
        await _mediator.Send(new ConfirmOrderCommand(OrderId));
        await LoadOrderAsync(null);
    }
}
```

### Test Examples (TDD)

```csharp
// Domain.Tests/Entities/OrderTests.cs
public class OrderTests
{
    [Fact]
    public void Create_ShouldCreatePendingOrder()
    {
        // Arrange
        var userId = Guid.NewGuid();
        var address = Address.Create("123 Main St", "Tokyo", "100-0001", "Japan");

        // Act
        var order = Order.Create(userId, address);

        // Assert
        order.Id.Should().NotBeEmpty();
        order.UserId.Should().Be(userId);
        order.Status.Should().Be(OrderStatus.Pending);
        order.Items.Should().BeEmpty();
        order.DomainEvents.Should().ContainSingle()
            .Which.Should().BeOfType<OrderCreatedEvent>();
    }

    [Fact]
    public void AddItem_ShouldAddItemToOrder()
    {
        // Arrange
        var order = CreatePendingOrder();
        var productId = Guid.NewGuid();
        var unitPrice = Money.Create(1000);

        // Act
        order.AddItem(productId, "Test Product", 2, unitPrice);

        // Assert
        order.Items.Should().ContainSingle();
        order.Items.First().Quantity.Should().Be(2);
        order.GetTotalAmount().Amount.Should().Be(2000);
    }

    [Fact]
    public void Confirm_WithEmptyOrder_ShouldThrow()
    {
        // Arrange
        var order = CreatePendingOrder();

        // Act
        var act = () => order.Confirm();

        // Assert
        act.Should().Throw<DomainException>()
            .WithMessage("Cannot confirm empty order");
    }

    [Fact]
    public void Cancel_ShippedOrder_ShouldThrow()
    {
        // Arrange
        var order = CreateShippedOrder();

        // Act
        var act = () => order.Cancel();

        // Assert
        act.Should().Throw<DomainException>()
            .WithMessage("Cannot cancel shipped or delivered order");
    }

    private static Order CreatePendingOrder()
    {
        var address = Address.Create("123 Main St", "Tokyo", "100-0001", "Japan");
        return Order.Create(Guid.NewGuid(), address);
    }

    private static Order CreateShippedOrder()
    {
        var order = CreatePendingOrder();
        order.AddItem(Guid.NewGuid(), "Product", 1, Money.Create(1000));
        order.Confirm();
        // Simulate shipping through reflection or internal method
        return order;
    }
}
```

```csharp
// Application.Tests/Handlers/CreateOrderHandlerTests.cs
public class CreateOrderHandlerTests
{
    private readonly Mock<IOrderRepository> _orderRepositoryMock;
    private readonly Mock<IProductService> _productServiceMock;
    private readonly Mock<IUnitOfWork> _unitOfWorkMock;
    private readonly CreateOrderHandler _handler;

    public CreateOrderHandlerTests()
    {
        _orderRepositoryMock = new Mock<IOrderRepository>();
        _productServiceMock = new Mock<IProductService>();
        _unitOfWorkMock = new Mock<IUnitOfWork>();

        _handler = new CreateOrderHandler(
            _orderRepositoryMock.Object,
            _productServiceMock.Object,
            _unitOfWorkMock.Object,
            Mock.Of<ILogger<CreateOrderHandler>>());
    }

    [Fact]
    public async Task Handle_ValidCommand_ShouldCreateOrder()
    {
        // Arrange
        var productId = Guid.NewGuid();
        var command = new CreateOrderCommand(
            UserId: Guid.NewGuid(),
            Street: "123 Main St",
            City: "Tokyo",
            PostalCode: "100-0001",
            Country: "Japan",
            Items: [new CreateOrderItemDto(productId, 2)]
        );

        _productServiceMock
            .Setup(x => x.GetByIdAsync(productId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(new ProductDto(productId, "Test Product", 1000));

        // Act
        var orderId = await _handler.Handle(command, CancellationToken.None);

        // Assert
        orderId.Should().NotBeEmpty();
        _orderRepositoryMock.Verify(
            x => x.AddAsync(It.IsAny<Order>(), It.IsAny<CancellationToken>()),
            Times.Once);
        _unitOfWorkMock.Verify(
            x => x.SaveChangesAsync(It.IsAny<CancellationToken>()),
            Times.Once);
    }

    [Fact]
    public async Task Handle_ProductNotFound_ShouldThrow()
    {
        // Arrange
        var productId = Guid.NewGuid();
        var command = new CreateOrderCommand(
            UserId: Guid.NewGuid(),
            Street: "123 Main St",
            City: "Tokyo",
            PostalCode: "100-0001",
            Country: "Japan",
            Items: [new CreateOrderItemDto(productId, 2)]
        );

        _productServiceMock
            .Setup(x => x.GetByIdAsync(productId, It.IsAny<CancellationToken>()))
            .ReturnsAsync((ProductDto?)null);

        // Act
        var act = () => _handler.Handle(command, CancellationToken.None);

        // Assert
        await act.Should().ThrowAsync<EntityNotFoundException>();
    }
}
```
