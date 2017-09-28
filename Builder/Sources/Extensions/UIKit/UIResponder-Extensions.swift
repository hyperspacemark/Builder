import UIKit

extension UIResponder {
    func nextResponder<Responder>(_ type: Responder.Type) -> Responder? {
        guard let responder = next else {
            return nil
        }

        if let typedResponder = responder as? Responder {
            return typedResponder
        }

        return responder.nextResponder(type)
    }
}
