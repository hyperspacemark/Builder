public enum Result<Value, Error: Swift.Error> {
    case success(Value)
    case failure(Error)

    public init(attempt f: () throws -> Value) {
        do {
            self = .success(try f())
        } catch {
            self = .failure(error as! Error)
        }
    }

    public func analysis<Result>(ifSuccess: (Value) -> Result, ifFailure: (Error) -> Result) -> Result {
        switch self {
        case let .success(value):
            return ifSuccess(value)

        case let .failure(error):
            return ifFailure(error)
        }
    }

    public func bimap<V, E>(success: (Value) -> V, failure: (Error) -> E) -> Result<V, E> {
        return analysis(
            ifSuccess: { .success(success($0)) },
            ifFailure: { .failure(failure($0)) })
    }

    public func map<U>(_ transform: (Value) -> U) -> Result<U, Error> {
        return flatMap { .success(transform($0)) }
    }

    public func flatMap<U>(_ transform: (Value) -> Result<U, Error>) -> Result<U, Error> {
        return analysis(ifSuccess: transform, ifFailure: Result<U, Error>.failure)
    }

    public func mapError<NewError>(_ transform: (Error) -> NewError) -> Result<Value, NewError> {
        return flatMapError { .failure(transform($0)) }
    }
    
    public func flatMapError<NewError>(_ transform: (Error) -> Result<Value, NewError>) -> Result<Value, NewError> {
        return analysis(ifSuccess: Result<Value, NewError>.success, ifFailure: transform)
    }
}
