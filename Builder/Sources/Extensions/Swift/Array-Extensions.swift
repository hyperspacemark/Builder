extension Array {
    func sorted<Value: Comparable>(by keyPath: KeyPath<Element, Value>) -> [Element] {
        return sorted(by: { $0[keyPath: keyPath] < $1[keyPath: keyPath] })
    }
}
