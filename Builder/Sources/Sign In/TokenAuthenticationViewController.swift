import UIKit
import Buildkite

protocol TokenAuthenticationViewControllerDelegate: class {
    func tokenAuthenticationViewController(_ viewController: TokenAuthenticationViewController,
                                           didAuthenticate user: User,
                                           usingToken: String)
}

final class TokenAuthenticationViewController: UIViewController {

    // MARK: - Properties

    weak var delegate: TokenAuthenticationViewControllerDelegate?

    // MARK: - Initialization

    init(authenticator: TokenAuthenticator) {
        self.authenticator = authenticator
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Sign In"
        navigationController?.navigationBar.prefersLargeTitles = true

        let token = "c16c53a1289346f23870d30545ada3f19b1a1348"
        textField.text = token

        view.backgroundColor = .white

        let stackView = UIStackView(arrangedSubviews: [textField, signInButton, activityIndicator])
        stackView.axis = .vertical
        stackView.spacing = UIStackView.spacingUseSystem
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
            ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateActivityIndicator(isAnimating: false)
    }

    func updateActivityIndicator(isAnimating: Bool) {
        if isAnimating {
            activityIndicator.startAnimating()
            signInButton.isHidden = true
        } else {
            activityIndicator.stopAnimating()
            signInButton.isHidden = false
        }
    }

    // MARK: Private

    private let authenticator: TokenAuthenticator

    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "Buildkite access token…"
        textField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
        return textField
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private lazy var signInButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .preferredFont(forTextStyle: .title3)
        button.setTitle("Sign In", for: .normal)
        button.addTarget(self, action: #selector(signInButtonTapped), for: .touchUpInside)
        return button
    }()

    @objc
    private func textFieldEditingChanged() {
        signInButton.isEnabled = (textField.text?.count ?? 0) > 0
    }

    @objc
    private func signInButtonTapped() {
        updateActivityIndicator(isAnimating: true)
        let token = textField.text!
        authenticator.authenticateUser(usingToken: token) { [weak self] result in
            guard let strongSelf = self else {
                return
            }

            strongSelf.updateActivityIndicator(isAnimating: false)

            switch result {
            case let .success(user):
                strongSelf.delegate?.tokenAuthenticationViewController(strongSelf, didAuthenticate: user, usingToken: token)

            case .failure(_):
                // TODO: Handle me
                break
            }
        }
    }
}

