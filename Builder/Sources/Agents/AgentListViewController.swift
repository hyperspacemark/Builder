import UIKit
import Buildkite

final class AgentListViewController: UITableViewController {
    init() {
        super.init(style: .plain)
        title = "Agents"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
    }
}

