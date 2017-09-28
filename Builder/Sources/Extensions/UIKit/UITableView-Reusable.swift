import struct Foundation.IndexPath
import class UIKit.UITableView
import class UIKit.UITableViewCell

extension UITableView {
    func register<Cell>(_ cellClass: Cell.Type) where Cell: UITableViewCell & Reusable {
        register(cellClass, forCellReuseIdentifier: cellClass.reuseIdentifier)
    }

    func dequeue<Cell>(_ cellClass: Cell.Type, for indexPath: IndexPath) -> Cell where Cell: UITableViewCell & Reusable {
        return dequeueReusableCell(withIdentifier: cellClass.reuseIdentifier, for: indexPath) as! Cell
    }
}

