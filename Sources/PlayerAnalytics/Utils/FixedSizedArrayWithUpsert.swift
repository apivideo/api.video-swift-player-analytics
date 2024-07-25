import Foundation

/// A class representing a fixed sized array.
/// The array will only contain the last `maxSize` elements.
class FixedSizedArrayWithUpsert<T: Equatable> {
    private let maxSize: Int
    private var elements: [T] = []

    /// True if the array is empty.
    var isEmpty: Bool {
        elements.isEmpty
    }

    /// The array of elements.
    /// Available for testing purposes.
    var array: [T] {
        elements
    }

    /// Initialize the array with a maximum size.
    init(maxSize: Int) {
        self.maxSize = maxSize
    }

    /// Upsert an element.
    func upsert(_ element: T) {
        if elements.last == element {
            elements.removeLast()
            elements.append(element)
        } else {
            add(element)
        }
    }

    private func add(_ element: T) {
        if elements.count >= maxSize {
            elements.remove(at: 0)
        }
        elements.append(element)
    }

    func removeAll() {
        elements.removeAll()
    }
}
