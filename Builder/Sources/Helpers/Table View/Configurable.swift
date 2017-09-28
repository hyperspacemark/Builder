protocol Configurable {
    associatedtype Configuration
    func configure(with configuration: Configuration)
}
