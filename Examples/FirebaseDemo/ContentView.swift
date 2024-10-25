import Dependencies
import Sharing
import SwiftUI

struct ContentView: View {
  @SharedReader(.remoteConfig("showPromo")) var showPromo = false

  var body: some View {
    VStack {
      Image(systemName: "globe")
        .imageScale(.large)
        .foregroundStyle(.tint)
      Text("Hello, world!")

      if showPromo {
        Text("Our promo has started!")
      }
    }
  }
}

#Preview {
  ContentView()
}
