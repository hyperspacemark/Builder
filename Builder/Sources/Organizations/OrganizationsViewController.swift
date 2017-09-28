import UIKit
import Buildkite

final class OrganizationsViewDriver: ViewDriver, OrganizationsViewService {
    typealias UI = OrganizationsViewController

    struct State: DriverState {
        enum Message {
            case loadOrganizations
            case requestFinished(Result<[Organization], Client.Error>)
        }

        enum Command {
            case requestOrganizations(completion: (Result<[Organization], Client.Error>) -> Message)
            case displayOrganizations([Organization])
            case presentAlertController(title: String?, message: String?)

            static func showAlert(for clientError: Client.Error) -> Command {
                switch clientError {
                case let .buildkite(httpStatusCode: _, apiError):
                    return .presentAlertController(title: "Request Failed", message: apiError.message)

                case .urlSession(_):
                    return .presentAlertController(title: "Request Failed", message: "Networking Error")

                case .jsonDecoding(_):
                    return .presentAlertController(title: "Request Failed", message: "Unexpected Response")

                case .unknown:
                    return .presentAlertController(title: "Request Failed", message: "Unknown Error")
                }
            }
        }

        static let initial = State()

        mutating func send(_ message: Message) -> [Command] {
            switch message {
            case .loadOrganizations:
                return [.requestOrganizations(completion: Message.requestFinished)]

            case let .requestFinished(result):
                switch result {
                case let .success(organizations):
                    return [
                        .displayOrganizations(organizations.sorted { $0.name < $1.name }),
                    ]

                case let .failure(error):
                    return [
                        .showAlert(for: error),
                    ]
                }
            }
        }
    }

    var ui: OrganizationsViewController

    init(ui: OrganizationsViewController, _ didSelect: @escaping (Organization) -> Void) {
        self.ui = ui
        self.didSelect = didSelect
    }

    let didSelect: (Organization) -> Void

    func loadOrganizations() {
        send(.loadOrganizations)
    }

    func select(_ organization: Organization) {
        didSelect(organization)
    }

    var state: State = .initial

    func execute(_ command: State.Command) {
        switch command {
        case let .requestOrganizations(completion):
            break
            //client.execute(Organization.all) { self.send(completion($0)) }

        case let .displayOrganizations(organizations):
            break
            //ui?.displayOrganizations(organizations)

        case .presentAlertController(let title, let message):
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            ui.present(alertController, animated: true, completion: nil)
        }
    }
}

protocol OrganizationsViewService {
    func loadOrganizations()
    func select(_ organization: Organization)
}

final class OrganizationsViewController: UITableViewController {
    final class Cell: UITableViewCell, Configurable, Reusable {
        struct ViewData {
            let name: String

            init(_ organization: Organization) {
                self.name = organization.name
            }
        }

        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: .default, reuseIdentifier: reuseIdentifier)
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        func configure(with configuration: ViewData) {
            accessoryType = .disclosureIndicator
            textLabel?.text = configuration.name
        }
    }

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Organizations"
        navigationController?.navigationBar.prefersLargeTitles = true

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(signOut))

        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshControlDidBeginRefreshing(_:)), for: .valueChanged)

        tableView.dataSource = dataSource
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }

    func displayOrganizations(_ organizations: [Organization]) {
        dataSource.setValues(organizations)
    }

    func startRefreshControl() {
        refreshControl?.beginRefreshing()
    }

    func stopRefreshControl() {
        refreshControl?.endRefreshing()
    }

    // MARK: - Private

    private lazy var dataSource: TableViewDataSource<Organization, Cell> = {
        return TableViewDataSource<Organization, Cell>(tableView: self.tableView, transform: Cell.ViewData.init)
    }()

    @objc
    private func refreshControlDidBeginRefreshing(_ sender: UIRefreshControl) {
    }

    @objc
    private func signOut() {
        nextResponder(ServiceLocator.self)?.signOutService.signOut()
    }
}
