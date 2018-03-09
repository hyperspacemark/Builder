import UIKit

final class TableViewDataSource<Value, Cell>: NSObject, UITableViewDataSource
where Value: Equatable, Cell: UITableViewCell & Reusable, Cell: Configurable {

    var shouldShowDisclosureIndicator = true {
        didSet {
            updateDisclosureIndicatorVisibilityForVisibleCells()
        }
    }

    private let diffCalculator: TableViewDiffCalculator<Int, Value>
    private let transform: (Value) -> Cell.Configuration

    init(tableView: UITableView, transform: @escaping (Value) -> Cell.Configuration) {
        tableView.register(Cell.self)

        self.diffCalculator = TableViewDiffCalculator(tableView: tableView, initialSectionedValues: SectionedValues([(0, [])]))
        self.transform = transform
    }

    func setValues(_ values: [Value]) {
        self.values = values
        diffCalculator.sectionedValues = SectionedValues([(0, values)])
    }

    func value(at indexPath: IndexPath) -> Value {
        return diffCalculator.value(atIndexPath: indexPath)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return diffCalculator.numberOfObjects(inSection: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(Cell.self, for: indexPath)
        cell.configure(with: transform(value(at: indexPath)))
        updateDisclosureIndicatorVisibility(for: cell)

        return cell
    }

    func updateDisclosureIndicatorVisibility(for cell: UITableViewCell) {
        if shouldShowDisclosureIndicator && cell.accessoryType == .none {
            cell.accessoryType = .disclosureIndicator
        } else if !shouldShowDisclosureIndicator && cell.accessoryType == .disclosureIndicator {
            cell.accessoryType = .none
        }
    }

    func updateDisclosureIndicatorVisibilityForVisibleCells() {
        guard let tableView = diffCalculator.tableView else {
            return
        }

        tableView.visibleCells.forEach(updateDisclosureIndicatorVisibility(for:))
    }

    private(set) var values: [Value] = []
}

extension TableViewDataSource where Cell.Configuration == Value {
    convenience init(tableView: UITableView) {
        self.init(tableView: tableView, transform: { $0 })
    }
}

extension TableViewDataSource where Cell.Configuration.Model == Value {
    convenience init(tableView: UITableView) {
        self.init(tableView: tableView, transform: Cell.Configuration.init)
    }
}
