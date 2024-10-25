import Dependencies
import Foundation
import PerceptionCore

final class PersistentReferences: Sendable, DependencyKey {
  static var liveValue: PersistentReferences { PersistentReferences() }
  static var testValue: PersistentReferences { PersistentReferences() }

  struct Pair<Key: SharedReaderKey> {
    var cachedValue: Key.Value
    var reference: _PersistentReference<Key>?
  }

  private let storage = Mutex<[AnyHashable: Any]>([:])

  func value<Key: SharedReaderKey>(
    forKey key: Key,
    default value: @autoclosure () throws -> Key.Value
  ) rethrows -> _ManagedReference<Key> {
    try storage.withLock { storage in
      guard var pair = storage[key.id] as? Pair<Key> else {
        let value = try value()
        let persistentReference = _PersistentReference(key: key, value: value)
        storage[key.id] = Pair(cachedValue: value, reference: persistentReference)
        return _ManagedReference(persistentReference)
      }
      guard let persistentReference = pair.reference else {
        let persistentReference = _PersistentReference(key: key, value: pair.cachedValue)
        pair.reference = persistentReference
        storage[key.id] = pair
        return _ManagedReference(persistentReference)
      }
      return _ManagedReference(persistentReference)
    }
  }

  func removeReference<Key: SharedReaderKey>(forKey key: Key) {
    storage.withLock {
      guard var pair = $0[key.id] as? Pair<Key> else { return }
      pair.reference = nil
      $0[key.id] = pair
    }
  }
}
