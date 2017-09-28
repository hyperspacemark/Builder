import UIKit

final class TableViewDataSource<Value, Cell>: NSObject, UITableViewDataSource
where Value: Equatable, Cell: UITableViewCell & Reusable, Cell: Configurable {
    private let diffCalculator: TableViewDiffCalculator<Int, Value>
    private let transform: (Value) -> Cell.Configuration

    init(tableView: UITableView, transform: @escaping (Value) -> Cell.Configuration) {
        tableView.register(Cell.self)

        self.diffCalculator = TableViewDiffCalculator(tableView: tableView, initialSectionedValues: SectionedValues([(0, [])]))
        self.transform = transform
    }

    func setValues(_ values: [Value]) {
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
        return cell
    }
}

extension TableViewDataSource where Cell.Configuration == Value {
    convenience init(tableView: UITableView) {
        self.init(tableView: tableView, transform: { $0 })
    }
}
