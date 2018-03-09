import UIKit
import struct Buildkite.Pipeline

final class PipelineDetailViewController: UIViewController {
    init(pipeline: Pipeline) {
        super.init(nibName: nil, bundle: nil)
        title = pipeline.name
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
    }
}
