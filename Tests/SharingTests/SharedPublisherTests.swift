import Combine
import ConcurrencyExtras
import Sharing
import Testing

@Suite struct SharedPublisherTests {
  @Test func publisher() {
    @Shared(value: 0) var count

    let counts = LockIsolated<[Int]>([])
    let cancellable = $count.publisher.sink { value in counts.withValue { $0.append(value) } }
    defer { _ = cancellable }

    $count.withLock { $0 += 1 }
    $count.withLock { $0 += 1 }
    $count.withLock { $0 += 1 }

    #expect(counts.withValue { $0 } == [1, 2, 3])
  }
}
