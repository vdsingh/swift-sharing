# Gotchas of @Shared

Learn about a few gotchas to be aware of when using shared state in your application.

#### Hashability

Because the `@Shared` type is equatable based on its wrapped value, and because the value is held 
in a reference that can change over time, it cannot be hashable. This also means that types
containing `@Shared` properties should not compute their hashes from their shared values.

#### Codability

The `@Shared` type is not conditionally encodable or decodable because the source of truth of the 
wrapped value is rarely local: it might be derived from some other shared value, or it might rely on 
loading the value from a backing persistence strategy.

When introducing shared state to a data type that is encodable or decodable, you must explicitly
declare its non-shared coding keys in order to synthesize conformances:

```swift
struct TodosFeature {
  @Shared(.appStorage("launchCount")) var launchCount = 0
  var todos: [String] = []
}

extension TodosFeature: Codable {
  enum CodingKeys: String, CodingKey {
    // Omit 'launchCount'
    case todos
  }
}
```

Or you must provide your own implementations of `encode(to:)` and `init(from:)` that do the
appropriate thing.

For example, if the data type is sharing state with a persistence strategy, you can _decode_ by 
delegating to the memberwise initializer that implicitly loads the shared value from the property 
wrapper's persistence strategy, or you can explicitly initialize a shared value via
``Shared/init(wrappedValue:_:)-5xce4``. And you can _encode_ by skipping the shared value:

```swift
struct TodosFeature {
  @Shared(.appStorage("launchCount")) var launchCount = 0
  var todos: [String] = []
}

extension TodosFeature: Codable {
  enum CodingKeys: String, CodingKey {
    case todos
  }

  init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    // Do not decode 'launchCount'
    self._launchCount = Shared(wrappedValue: 0, .appStorage("launchCount"))
    self.todos = try container.decode([String].self, forKey: .todos)
  }

  func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.todos, forKey: .todos)
    // Do not encode 'launchCount'
  }
}
```

#### Previews and tests

When a preview is run in an app target, the entry point is also created. And when a test is run in
an app target, the app runs in the background for the duration of the test. This means if your entry
point looks something like this:

```swift
@Observable
class AppModel {
  @ObservationIgnored
  @Shared(.appStorage("launchCount")) var launchCount = 0
}

@main
struct MainApp: App {
  let model = AppModel()

  var body: some Scene {
    // ...
  }
}
```

…then the `launchCount` key in user defaults will be accessed and set to `0` if no value currently
exists. This means that when running a preview or test where you might want to set the default value
of this key to something else, you will not be able to because the entry point has already set
it.

The fix is to delay creation of any models until the entry point's `body` is executed. Further, it
can be a good idea to also not run the `body` when in tests because that can also interfere with
tests. Here is one way this can be accomplished:

```swift
import SwiftUI

@main
struct MyApp: App {
  @MainActor
  static let model = AppModel()

  var body: some Scene {
    WindowGroup {
      // NB: Don't run application in tests to avoid interference 
      //     between the app and the test.
      if !isTesting {
        AppView(model: Self.model)
      }
    }
  }
}
```
