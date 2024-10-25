import Dependencies
@preconcurrency import FirebaseRemoteConfig
import Sharing

extension SharedReaderKey  {
  static func remoteConfig<Value>(_ key: String) -> Self where Self == RemoteConfigKey<Value> {
    RemoteConfigKey(key: key)
  }
}

struct RemoteConfigKey<Value: Decodable & Sendable>: SharedReaderKey {
  let key: String
  var id: some Hashable { key }
  @Dependency(RemoteConfigDependencyKey.self) var remoteConfig
  func load(initialValue: Value?) -> Value? {
    try? remoteConfig.configValue(forKey: key).decoded()
  }
  func subscribe(
    initialValue: Value?,
    didSet receiveValue: @escaping (Value?) -> Void
  ) -> SharedSubscription {
    remoteConfig.fetchAndActivate { changed, error in
      guard error == nil else { return }
      receiveValue(load(initialValue: initialValue))
    }
    let registration = remoteConfig.addOnConfigUpdateListener { update, error in
      guard error == nil else { return }
      remoteConfig.activate { changed, error in
        guard error == nil else { return }
        receiveValue(load(initialValue: initialValue))
      }
    }
    return SharedSubscription {
      registration.remove()
    }
  }
}

private enum RemoteConfigDependencyKey: DependencyKey {
  public static var liveValue: RemoteConfig {
    let remoteConfig = RemoteConfig.remoteConfig()
    let settings = RemoteConfigSettings()
    settings.minimumFetchInterval = 0
    remoteConfig.configSettings = settings
    return remoteConfig
  }
}
