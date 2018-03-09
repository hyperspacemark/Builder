import UIKit

final class SearchResultsController: UITableViewController {
    var results: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(Cell.self)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(Cell.self, for: indexPath)
        cell.textLabel?.text = results[indexPath.row]
        return cell
    }

    private final class Cell: UITableViewCell, Reusable {}
}
