import enum Buildkite.Result
import class Buildkite.Client
import struct Buildkite.User
import class UIKit.UIAlertController
import class UIKit.UIAlertAction

protocol SignInUI: class, ViewControllerPresenting {
    var tokenInputChanged: ((String?) -> Void)? { get set }
    var tokenSubmitted: (() -> Void)? { get set }
    func updateActivityIndicator(isAnimating: Bool)
}

final class SignInPresenter: ViewDriver {
    struct State: DriverState {
        enum Message {
            case tokenInputChanged(String?)
            case tokenSubmitted
            case currentUserRequestFinished(Result<User, SignInServiceError>)
        }

        enum Command {
            case requestCurrentUser(token: String, completion: (Result<User, SignInServiceError>) -> Message)
            case finish(User, token: String)
            case showAlert(Alert<Message>)
            case updateActivityIndicator(isAnimating: Bool)
        }

        static let initial = State()

        var token: String = ""
        var signingIn: Bool = false

        mutating func send(_ message: Message) -> [Command] {
            switch message {
            case let .tokenInputChanged(token):
                self.token = token ?? ""
                return []

            case .tokenSubmitted:
                signingIn = true
                return [
                    .requestCurrentUser(token: token, completion: Message.currentUserRequestFinished),
                    .updateActivityIndicator(isAnimating: true)
                ]

            case let .currentUserRequestFinished(result):
                switch result {
                case let .success(user):
                    return [
                        .finish(user, token: token),
                        .updateActivityIndicator(isAnimating: false)
                    ]

                case let .failure(error):
                    switch error {
                    case .requestFailed:
                        return [
                            .showAlert(Alert(title: "Sign In Failed", message: "Couldn't communicate with Buildkite. Please try again.")),
                            .updateActivityIndicator(isAnimating: false)
                        ]

                    case .invalidAccessToken:
                        return [
                            .showAlert(Alert(title: "Invalid Access Token", message: "Ensure the token has been entered correctly and try again.")),
                            .updateActivityIndicator(isAnimating: false)
                        ]
                    }
                }
            }
        }
    }

    var state: State = .initial
    let ui: SignInUI

    func execute(_ command: State.Command) {
        switch command {
        case let .requestCurrentUser(token, completion):
            service.signIn(usingToken: token, bind(completion))

        case let .finish(user, token):
            didFinish(user, token)

        case .showAlert(let alert):
            let alertController = UIAlertController(alert: alert, send: send)
            ui.present(alertController, animated: true, completion: nil)

        case let .updateActivityIndicator(isAnimating):
            ui.updateActivityIndicator(isAnimating: isAnimating)
        }
    }

    init(ui: SignInUI, service: SignInServiceProtocol, didFinish: @escaping (User, String) -> Void) {
        self.ui = ui
        self.service = service
        self.didFinish = didFinish

        ui.tokenInputChanged = bind(State.Message.tokenInputChanged)
        ui.tokenSubmitted = bind(State.Message.tokenSubmitted)
    }

    private let service: SignInServiceProtocol
    private let didFinish: (User, String) -> Void
}

extension UIAlertController {
    convenience init<Message>(alert: Alert<Message>, send: @escaping (Message) -> Void) {
        self.init(title: alert.title, message: alert.message, preferredStyle: .alert)

        alert.actions.map { action in
            UIAlertAction(title: action.title, style: action.style) { _ in send(action.message) }
        }.forEach(addAction)

        if actions.isEmpty {
            addAction(.init(title: "OK", style: .default, handler: nil))
        }
    }
}
