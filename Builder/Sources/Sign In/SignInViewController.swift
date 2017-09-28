import UIKit

final class SignInViewController: UIViewController, SignInUI {

    var tokenInputChanged: ((String?) -> Void)?
    var tokenSubmitted: (() -> Void)?

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

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
        tokenInputChanged?(textField.text)
    }

    @objc
    private func signInButtonTapped() {
        tokenSubmitted?()
    }
}
