extension Array {
    func sorted<Value>(by keyPath: KeyPath<Element, Value>) -> [Element] where Value: Comparable {
        return sorted(by: { $0[keyPath: keyPath] < $1[keyPath: keyPath] })
    }
}
