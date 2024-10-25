#if canImport(SwiftUI)
  import PerceptionCore
  import SwiftUI

  extension Binding {
    /// Creates a binding from a shared reference.
    ///
    /// Useful for binding shared state to a SwiftUI control.
    ///
    /// ```swift
    /// @Shared var count: Int
    /// // ...
    /// Stepper("\(count)", value: Binding($count))
    /// ```
    ///
    /// - Parameter base: A shared reference to a value.
    @MainActor
    public init(_ base: Shared<Value>) {
      func open(_ reference: some MutableReference<Value>) -> Binding<Value> {
        @PerceptionCore.Bindable var reference = reference
        return $reference._wrappedValue
      }
      self = open(base.reference)
    }
  }

  extension MutableReference {
    fileprivate var _wrappedValue: Value {
      get { wrappedValue }
      set { withLock { $0 = newValue } }
    }
  }
#endif
