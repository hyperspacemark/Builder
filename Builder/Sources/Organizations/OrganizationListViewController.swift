import UIKit
import Buildkite

protocol OrganizationListViewControllerDelegate: class {
    func organizationListViewController(_ viewController: OrganizationListViewController, didSelect organization: Organization)
}

final class OrganizationListViewController: UITableViewController {
    final class Cell: UITableViewCell, Configurable, Reusable {
        struct ViewData: ViewConfiguration {
            let name: String

            init(model: Organization) {
                self.name = model.name
            }
        }

        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: .default, reuseIdentifier: reuseIdentifier)
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        func configure(with configuration: ViewData) {
            textLabel?.text = configuration.name
        }
    }

    weak var delegate: OrganizationListViewControllerDelegate?

    init(organizations: Resource<[Organization]>) {
        self.organizations = organizations
        super.init(nibName: nil, bundle: nil)
        title = "Organizations"
        refreshControl = makeRefreshControl()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = true

        tableView.dataSource = dataSource

        subscription = organizations.addSubscriber { [weak self] state in
            if case let .loaded(organizations) = state {
                self?.dataSource.setValues(organizations)
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadOrganizations()
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.organizationListViewController(self, didSelect: dataSource.value(at: indexPath))
    }

    func displayOrganizations(_ organizations: [Organization]) {
        dataSource.setValues(organizations)
    }

    func startRefreshControl() {
        refreshControl?.beginRefreshing()
    }

    func stopRefreshControl() {
        guard let refreshControl = refreshControl else { return }

        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
    }

    // MARK: - Private

    private let organizations: Resource<[Organization]>
    private var subscription: Disposable?
    private lazy var dataSource = TableViewDataSource<Organization, Cell>(tableView: self.tableView)

    private func makeRefreshControl() -> UIRefreshControl {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refreshControlDidBeginRefreshing(_:)), for: .valueChanged)
        return control
    }

    private func reloadOrganizations() {
//        store.refresh { [weak self] result in
//            switch result {
//            case let .success(organizations):
//                self?.displayOrganizations(organizations)
//                self?.stopRefreshControl()
//
//            case let .failure(error):
//                print(error)
//            }
//        }
    }

    @objc
    private func refreshControlDidBeginRefreshing(_ sender: UIRefreshControl) {
        organizations.refresh()
    }
}
