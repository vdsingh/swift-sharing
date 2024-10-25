import Foundation
import JavaScriptKit
import Sharing

extension SharedKey {
  static func localStorage<Value>(_ key: String) -> Self where Self == LocalStorageKey<Value> {
    LocalStorageKey(key: key)
  }
}

struct LocalStorageKey<Value: Codable & Sendable>: SharedKey {
  let key: String

  var id: some Hashable { key }

  func load(initialValue: Value?) -> Value? {
    guard
      let string = JSObject.global.window.localStorage.getItem(key).string,
      let value = try? JSONDecoder().decode(Value.self, from: Data(string.utf8))
    else { return nil }
    return value
  }

  func subscribe(
    initialValue: Value?,
    didSet receiveValue: @escaping (Value?) -> Void
  ) -> SharedSubscription {
    nonisolated(unsafe) let listener = JSClosure { _ in
      receiveValue(load(initialValue: initialValue))
      return .undefined
    }
    _ = JSObject.global.window.addEventListener("storage", listener)
    return SharedSubscription {
       _ = JSObject.global.window.removeEventListener("storage", listener)
    }
  }

  func save(_ value: Value, immediately: Bool) {
    _ = try? JSObject.global.window.localStorage.setItem(
      key,
      String(decoding: JSONEncoder().encode(value), as: UTF8.self)
    )
  }
}
