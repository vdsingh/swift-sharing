import CustomDump
import IdentifiedCollections
import IssueReporting

// NB: Deprecated for 0.1

@available(*, deprecated, renamed: "SharedKey")
public typealias PersistenceKey = SharedKey

@available(
  *, deprecated, message: "Use 'Base.Default' instead of 'PersistenceKeyDefault<Base>'"
)
public typealias PersistenceKeyDefault = _SharedKeyDefault

@available(*, deprecated, renamed: "SharedReaderKey")
public typealias PersistenceReaderKey = SharedReaderKey

extension _SharedKeyDefault {
  @available(
    *, deprecated, message: "Use the static subscript 'Self[key, default: value]', instead"
  )
  public init(_ key: Base, _ value: @autoclosure @escaping @Sendable () -> Base.Value) {
    self = Self[key, default: value()]
  }
}

extension Shared {
  @available(*, deprecated, message: "renamed to 'SharedSubscription'")
  public typealias Subscription = SharedSubscription

  @available(
    *, deprecated, message: "Use the 'SharedReader($shared)' initializer, instead"
  )
  public var reader: SharedReader<Value> {
    SharedReader(self)
  }

  #if compiler(>=6)
    @available(*, deprecated, renamed: "init(value:)")
    public init(_ value: sending Value) {
      self.init(value: value)
    }
  #else
    @available(*, deprecated, renamed: "init(value:)")
    public init(_ value: Value) {
      self.init(value: value)
    }
  #endif

  @_disfavoredOverload
  @available(*, deprecated, renamed: "init(require:)")
  public init(_ key: some SharedKey<Value>) throws {
    try self.init(require: key)
  }
}

extension Shared where Value: Equatable {
  @available(*, deprecated, message: "Assert directly on shared state, instead")
  public func assert(
    _ updateValueToExpectedResult: (inout Value) throws -> Void,
    fileID: StaticString = #fileID,
    file filePath: StaticString = #filePath,
    line: UInt = #line,
    column: UInt = #column
  ) rethrows {
    guard let tracker = SharedChangeTracker.tracker(for: reference)
    else {
      reportIssue(
        """
        Expected changes, but none were tracked.
        """,
        fileID: fileID,
        filePath: filePath,
        line: line,
        column: column
      )
      return
    }
    guard let snapshot = reference.snapshot, snapshot != reference.wrappedValue
    else {
      reportIssue(
        """
        Expected changes, but none occurred.
        """,
        fileID: fileID,
        filePath: filePath,
        line: line,
        column: column
      )
      return
    }
    try tracker.assert {
      try withLock {
        try updateValueToExpectedResult(&$0)
      }
      expectNoDifference(
        self,
        self,
        fileID: fileID,
        filePath: filePath,
        line: line,
        column: column
      )
    }
  }
}

@available(
  *, deprecated, message: "Use '$array' directly instead of '$array.elements'"
)
extension Shared
where
  Value: _MutableIdentifiedCollection & RandomAccessCollection,
  Value.Element: Sendable,
  Value.Index == Value.IDs.Index
{
  public var elements: some RandomAccessCollection<Shared<Value.Element>> {
    self
  }
}

extension SharedReader {
  @available(*, deprecated, renamed: "init(require:)")
  public init(_ key: some SharedReaderKey<Value>) throws {
    try self.init(require: key)
  }
}

@available(
  *, deprecated, message: "Encode or ignore '@SharedReader' explicitly, instead"
)
extension SharedReader: Encodable where Value: Encodable {
  public func encode(to encoder: any Encoder) throws {
    do {
      var container = encoder.singleValueContainer()
      try container.encode(self.wrappedValue)
    } catch {
      try self.wrappedValue.encode(to: encoder)
    }
  }
}

@available(
  *, unavailable, message: "'@SharedReader' is not hashable"
)
extension SharedReader: Hashable where Value: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(wrappedValue)
  }
}

@available(
  *, deprecated, message: "Use '$array' directly instead of '$array.elements'"
)
extension SharedReader
where
  Value: _IdentifiedCollection & RandomAccessCollection,
  Value.Element: Sendable,
  Value.Index == Value.IDs.Index
{
  public var elements: some RandomAccessCollection<SharedReader<Value.Element>> {
    self
  }
}

// NB: Deprecated before 0.1

extension Shared {
  @_disfavoredOverload
  @available(
    *,
    deprecated,
    message: "Use 'Shared($value.optional)' to unwrap optional shared values, instead"
  )
  public subscript<Member>(
    dynamicMember keyPath: WritableKeyPath<Value, Member?>
  ) -> Shared<Member>? {
    Shared<Member>(self[dynamicMember: keyPath])
  }

  @_disfavoredOverload
  @available(
    *,
    deprecated,
    message: "Use 'Shared($value.optional)' to unwrap optional shared values, instead"
  )
  public subscript<Member>(
    dynamicMember keyPath: KeyPath<Value, Member?>
  ) -> SharedReader<Member>? {
    SharedReader<Member>(self[dynamicMember: keyPath])
  }
}

extension SharedReader {
  @_disfavoredOverload
  @available(
    *,
    deprecated,
    message: "Use 'SharedReader($value.optional)' to unwrap optional shared values, instead"
  )
  public subscript<Member>(
    dynamicMember keyPath: KeyPath<Value, Member?>
  ) -> SharedReader<Member>? {
    SharedReader<Member>(self[dynamicMember: keyPath])
  }
}
