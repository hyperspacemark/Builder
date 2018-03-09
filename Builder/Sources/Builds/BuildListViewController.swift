import UIKit

final class BuildListViewController: UITableViewController {
    init() {
        super.init(style: .plain)
        title = "Builds"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
    }
}
