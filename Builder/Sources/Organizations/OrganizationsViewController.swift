import UIKit
import Buildkite

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
}
