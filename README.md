# Fluent Firebird Driver

Firebird database driver for Vapor Fluent

## Note

Does not support the `QueryBuilder<Model>(…).first()` method. Please use:

```swift
database.query(Model.self)
	.all()
	.map { $0.first }
	.unwrap(orError: SomeError("Not found"))
```
