---
name: csharp-architect
description: |
  C# software development with MVVM, Clean Architecture, TDD, CQRS, and DDD.
  Use for: linter warnings, build errors, refactoring, feature implementation, code review.
  Triggers: C#, .NET, MVVM, Clean Architecture, DDD, CQRS, TDD, リファクタリング, コードレビュー
allowed-tools: Read, Edit, Write, Bash, Grep, Glob, Task
---

# C# Architect Skill

MVVM × Clean Architecture × TDD × CQRS × DDD に基づくC#ソフトウェア開発スキル。

## Core Principles

### Clean Architecture Layers

```
┌─────────────────────────────────────────┐
│         Presentation (MVVM)             │  ← ViewModels, Views
├─────────────────────────────────────────┤
│         Application (CQRS)              │  ← Commands, Queries, Handlers
├─────────────────────────────────────────┤
│         Domain (DDD)                    │  ← Entities, ValueObjects, Services
├─────────────────────────────────────────┤
│         Infrastructure                  │  ← Repositories, External Services
└─────────────────────────────────────────┘
```

**依存関係の方向**: 外側 → 内側（Domain は何にも依存しない）

### MVVM Guidelines

- **View**: XAML/Razor のみ、コードビハインドは最小限
- **ViewModel**: `INotifyPropertyChanged`, `ICommand` 実装
- **Model**: Domain 層のエンティティを使用

### CQRS Guidelines

- **Command**: 状態を変更、戻り値なし or ID のみ
- **Query**: 状態を変更しない、DTOを返す
- **Handler**: 単一責任、1ハンドラー1操作

### DDD Guidelines

- **Entity**: 一意の識別子を持つ
- **Value Object**: 不変、等価性は値で判断
- **Aggregate Root**: トランザクション境界
- **Domain Service**: エンティティに属さないビジネスロジック
- **Repository**: Aggregate Root 単位でのみ定義

### TDD Workflow

1. **Red**: 失敗するテストを書く
2. **Green**: 最小限のコードでテストを通す
3. **Refactor**: コードを改善（テストは緑のまま）

## Task-Specific Instructions

### Linter Warning Resolution

1. 警告メッセージを正確に読む
2. 根本原因を特定（表面的な修正を避ける）
3. アーキテクチャ原則に従って修正
4. 修正後、関連するテストを実行

**よくある警告と対応**:
- `CA1062`: null チェック追加 or nullable 参照型を使用
- `CA1822`: インスタンス状態を使わないなら static に
- `CS8618`: nullable 参照型を有効化、または初期化を保証

### Build Error Resolution

1. エラーメッセージ全体を読む
2. 依存関係の問題か、コードの問題かを判別
3. 依存関係 → NuGet/プロジェクト参照を確認
4. コード → 型、名前空間、アクセス修飾子を確認
5. 修正後、クリーンビルドで確認

### Refactoring

**実施前チェックリスト**:
- [ ] 既存テストがすべて通る
- [ ] リファクタリングの目的が明確
- [ ] 小さなステップで進める

**よく行うリファクタリング**:
- Extract Method/Class
- Move to appropriate layer
- Introduce Value Object
- Replace conditional with polymorphism

**実施後**:
- すべてのテストを実行
- 新しい警告がないか確認

### Feature Implementation

1. **要件を明確化**: 何を実現するか
2. **影響範囲を特定**: 変更が必要なレイヤー
3. **テストを先に書く** (TDD)
4. **Domain から実装**: 内側のレイヤーから外側へ
5. **インテグレーションテスト追加**

**実装順序**:
```
Domain Entity/VO → Domain Service → Repository Interface
→ Application Command/Query → Handler
→ Infrastructure Repository → ViewModel → View
```

### Code Review

**レビュー観点**:

1. **アーキテクチャ準拠**
   - レイヤー間の依存関係は正しいか
   - 適切なレイヤーに配置されているか

2. **DDD 準拠**
   - ドメインロジックが Domain 層にあるか
   - Aggregate の境界は適切か

3. **CQRS 準拠**
   - Command と Query が分離されているか
   - Handler は単一責任か

4. **テスト品質**
   - 十分なカバレッジか
   - テスト名は意図を表しているか

5. **コード品質**
   - SOLID 原則に従っているか
   - 命名は明確か

## File Naming Conventions

```
Domain/
  Entities/          {Name}.cs
  ValueObjects/      {Name}.cs
  Services/          {Name}Service.cs
  Events/            {Name}Event.cs

Application/
  Commands/          {Action}{Entity}Command.cs
  Queries/           Get{Entity}Query.cs
  Handlers/          {Command/Query}Handler.cs
  DTOs/              {Name}Dto.cs

Infrastructure/
  Repositories/      {Entity}Repository.cs
  Services/          {External}Service.cs

Presentation/
  ViewModels/        {View}ViewModel.cs
  Views/             {Name}View.xaml
```

## Common Patterns Reference

詳細なパターンと実装例は以下を参照:
- [architecture.md](./architecture.md) - レイヤー詳細設計
- [patterns.md](./patterns.md) - 実装パターン集
- [examples.md](./examples.md) - コード例

## Quality Checklist

実装完了時に確認:

- [ ] すべてのテストが通る
- [ ] 新しい警告がない
- [ ] ビルドが成功する
- [ ] 依存関係の方向が正しい
- [ ] 命名規則に従っている
- [ ] 適切なレイヤーに配置されている
