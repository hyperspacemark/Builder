import class UIKit.UIViewController
import class UIKit.UIAlertController
import enum UIKit.UIAlertActionStyle
import class UIKit.UIAlertAction

struct Alert<Message> {
    struct Action<Message> {
        let title: String
        let style: UIAlertActionStyle
        let message: Message
    }

    init(title: String?, message: String?) {
        self.title = title
        self.message = message
    }
    let title: String?
    let message: String?
    private(set) var actions: [Action<Message>] = []

    mutating func addAction(title: String, style: UIAlertActionStyle, message: Message) {
        let action = Action(title: title, style: style, message: message)
        actions.append(action)
    }
}

protocol AlertPresenting {
    func present<Message>(_ alert: Alert<Message>, animated: Bool, completion: (() -> Void)?)
}

extension AlertPresenting where Self: ViewControllerPresenting {

}

protocol DriverState {
    associatedtype Message
    associatedtype Command

    static var initial: Self { get }

    mutating func send(_ message: Message) -> [Command]
}

protocol ViewDriver: class {
    associatedtype State: DriverState
    associatedtype UI

    var state: State { get set }
    var ui: UI { get }

    func execute(_ command: State.Command)
}

extension ViewDriver {
    func send(_ message: State.Message) {
        state.send(message).forEach { execute($0) }
    }

    func bind(_ message: State.Message) -> () -> Void {
        return { self.send(message) }
    }

    func bind<Value>(_ transform: @escaping (Value) -> State.Message) -> (Value) -> Void {
        return { value in
            self.send(transform(value))
        }
    }
}

extension UIViewController: ViewControllerPresenting {}
protocol ViewControllerPresenting {
    func present(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?)
}
