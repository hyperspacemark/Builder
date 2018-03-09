import UIKit
import struct Buildkite.Pipeline
import struct Buildkite.Organization

protocol PipelineListViewControllerDelegate: class {
    func pipelineListViewController(_ viewController: PipelineListViewController,
                                    didSelect pipeline: Pipeline)
}

final class PipelineListViewController: UITableViewController {

    // MARK: - Properties

    weak var delegate: PipelineListViewControllerDelegate?

    // MARK: - Init

    init(pipelines: Resource<[Pipeline]>) {
        self.pipelines = pipelines
        super.init(style: .plain)
        title = "Pipelines"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        definesPresentationContext = true

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true

        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshTriggered(_:)), for: .valueChanged)

        tableView.dataSource = dataSource

        subscription = pipelines.addSubscriber { [weak self] state in
            switch state {
            case .pending:
                print("pending")
                break

            case .loading:
                print("loading")
                break

            case let .loaded(pipelines):
                print("loaded")
                self?.dataSource.setValues(pipelines)
                self?.refreshControl?.endRefreshing()

            case .refreshing:
                print("refreshing")
                break
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        refreshPipelines()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        let isInSplitViewPresentation = !(splitViewController?.isCollapsed ?? true)

        coordinator.animate(alongsideTransition: nil) { (_) in
            self.dataSource.shouldShowDisclosureIndicator = isInSplitViewPresentation
        }

        super.viewWillTransition(to: size, with: coordinator)
    }

    // MARK: - Private
    // MARK: Properties

    private let pipelines: Resource<[Pipeline]>
    private lazy var dataSource = TableViewDataSource<Pipeline, Cell>(tableView: self.tableView)
    private var subscription: Disposable?

    private lazy var searchResultsController: SearchResultsController = {
        let controller = SearchResultsController()
        controller.tableView.delegate = self
        return controller
    }()

    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: self.searchResultsController)
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.sizeToFit()
        return searchController
    }()

    // MARK: Private Methods

    private func refreshPipelines() {
        pipelines.refresh()
    }

    private func endRefreshingIfNeeded() {
        if let control = refreshControl, control.isRefreshing {
            control.endRefreshing()
        }
    }

    // MARK: Actions

    @objc private func refreshTriggered(_ sender: UIRefreshControl) {
        refreshPipelines()
    }
}

// MARK: - Cell

extension PipelineListViewController {
    private final class Cell: UITableViewCell, Configurable, Reusable {
        struct ViewData: ViewConfiguration {
            let name: String
            init(model: Pipeline) {
                self.name = model.name
            }
        }

        func configure(with configuration: ViewData) {
            textLabel?.text = configuration.name
        }
    }
}

// MARK: - UISearchBarDelegate

extension PipelineListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK: - UISearchResultsUpdating

extension PipelineListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let results = dataSource.values.lazy.map { $0.name }.filter { (pipeline) -> Bool in
            pipeline.localizedCaseInsensitiveContains(searchController.searchBar.text!)
        }

        if let resultsController = searchController.searchResultsController as? SearchResultsController {
            resultsController.results = Array(results)
            resultsController.tableView.reloadData()
        }
    }
}

// MARK: - UITableViewDelegate

extension PipelineListViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView === self.tableView {
            let pipeline = dataSource.value(at: indexPath)
            delegate?.pipelineListViewController(self, didSelect: pipeline)
        } else if tableView === searchResultsController.tableView {
            let name = searchResultsController.results[indexPath.row]

            if let index = dataSource.values.index(where: { $0.name == name }) {
                let pipeline = dataSource.value(at: IndexPath(row: index, section: 0))
                delegate?.pipelineListViewController(self, didSelect: pipeline)
            }
        }
    }
}
