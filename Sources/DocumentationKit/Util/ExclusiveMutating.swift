//
//  ExclusiveMutating.swift
//  DocumentationKit
//
//  Copyright © 2024 Noah Kamara.
//

import Atomics
import Foundation

/// A simple container class that uses *multiple readers / single writer* concurrency pattern to protect the value stored in it.
///
/// Obviously, the instances of this class are `Sendable`.
///
public final class ExclusiveMutating<Value>: @unchecked Sendable {
    // The storage for the protected value
    private var _value: Value

    // Atomic counter to implement Readers/Writer Lock
    private let readerCount = ManagedAtomic(0)

    // Flag for writing state
    private let WRITING = -1

    // Add a reader
    private func beginReading() async {
        var done = false
        var count = 0
        while true {
            count = readerCount.load(ordering: .relaxed)
            if count != WRITING {
                (done, count) = readerCount.weakCompareExchange(expected: count, desired: count + 1, ordering: .acquiringAndReleasing)
                if done { break }
            }
            await Task.yield()
        }
    }

    // Remove a reader
    private func doneReading() { readerCount.wrappingDecrement(ordering: .acquiringAndReleasing) }

    // Enter writing state:
    private func signalWriting() async {
        while true {
            let (done, _) = readerCount.weakCompareExchange(expected: 0, desired: WRITING, ordering: .acquiringAndReleasing)
            if done { break }
            await Task.yield()
        }
    }

    // Leave writing state
    private func doneWriting() { readerCount.store(0, ordering: .releasing) }

    // The protected value as an async read only property
    public var value: Value {
        get async {
            await beginReading()
            defer { doneReading() }
            return _value
        }
    }

    /// The async method to set the value.
    ///
    /// Once we get async `set` feature for properties, it will become the setter of the `value` property.
    ///
    /// - Parameters:
    ///   - value: The new value to set
    /// - Returns: The old value that was overwritten
    ///
    @discardableResult
    public func set(to value: Value) async -> Value {
        await signalWriting()
        let oldValue = _value
        _value = value
        doneWriting()
        return oldValue
    }

    /// An async method to get the current value and transform it to the new value.
    ///
    /// Rethrows the error thrown by `transform` closure.
    ///
    /// - Parameters:
    ///   - transform: A potentilly async and throwing closure that receives the current value and return the new value.
    ///
    public func update(_ transform: (Value) async throws -> Value) async rethrows {
        await signalWriting()
        defer { doneWriting() }
        _value = try await transform(_value)
    }

    /// An async method to mutate the value in-place
    ///
    /// Rethrows the error thrown by `transform` closure.
    ///
    /// - Parameters:
    ///   - transform: A potentilly throwing closure that receives the mutable value to update.
    public func mutate(_ transform: (inout Value) throws -> Void) async rethrows {
        await signalWriting()
        defer { doneWriting() }
        try withUnsafeMutablePointer(to: &_value) { valuePtr in // FIXME!
            try transform(&valuePtr.pointee)
        }
    }

    /// Creates a `ReadersWriter` instance.
    ///
    /// - Parameters:
    ///   - value: The initial value.
    ///
    public init(_ value: Value) { self._value = value }
}

extension ExclusiveMutating {
    subscript<Key, T>(
        _ key: Key
    ) -> T? where Value == [Key: T] {
        get async {
            await beginReading()
            defer { doneReading() }
            return _value[key]
        }
    }
}
