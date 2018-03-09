protocol Configurable {
    associatedtype Configuration: ViewConfiguration
    func configure(with configuration: Configuration)
}

protocol ViewConfiguration {
    associatedtype Model
    init(model: Model)
}
