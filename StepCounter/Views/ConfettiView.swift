import UIKit
import Foundation

/// Confetti controller
class ConfettiController: UIViewController {
    /// Build an array of confetti
    lazy var confettiTypes: [ConfettiType] = {
        let confettiColors = AppConfig.confettiColors.map({ UIColor($0) })
        return [ConfettiPosition.foreground, ConfettiPosition.background].flatMap { position in
            return [ConfettiShape.rectangle, ConfettiShape.circle].flatMap { shape in
                return confettiColors.map { color in
                    return ConfettiType(color: color, shape: shape, position: position)
                }
            }
        }
    }()
    
    /// Confetti emitter
    lazy var confettiLayer: CAEmitterLayer = {
        let emitterLayer = CAEmitterLayer()
        emitterLayer.emitterCells = confettiCells
        emitterLayer.emitterPosition = CGPoint(x: view.bounds.midX, y: view.bounds.minY - 500)
        emitterLayer.emitterSize = CGSize(width: view.bounds.size.width, height: 500)
        emitterLayer.emitterShape = .rectangle
        emitterLayer.frame = view.bounds
        emitterLayer.beginTime = CACurrentMediaTime() - 2
        return emitterLayer
    }()

    /// An array of emitter cells
    lazy var confettiCells: [CAEmitterCell] = {
        return confettiTypes.map { confettiType in
            let cell = CAEmitterCell()
            cell.birthRate = 5
            cell.contents = confettiType.image.cgImage
            cell.emissionRange = CGFloat(Double.pi)
            cell.lifetime = 10
            cell.spin = 4
            cell.spinRange = 8
            cell.velocityRange = 100
            cell.yAcceleration = 150
            cell.setValue("plane", forKey: "particleType")
            cell.setValue(Double.pi, forKey: "orientationRange")
            cell.setValue(Double.pi / 2, forKey: "orientationLongitude")
            cell.setValue(Double.pi / 2, forKey: "orientationLatitude")
            return cell
        }
    }()
    
    /// Set a clear background color
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
    }

    /// Add the confetti layer when the view appears
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.layer.addSublayer(confettiLayer)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.confettiLayer.birthRate = 0.0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    /// Show confetti view
    static func showConfettiOverlay() {
        let confetti = ConfettiController()
        confetti.modalPresentationStyle = .overFullScreen
        rootController?.present(confetti, animated: false, completion: nil)
    }
}

/// A generic class confetti configuration
class ConfettiType {
    let color: UIColor
    let shape: ConfettiShape
    let position: ConfettiPosition
    
    /// Custom init method
    init(color: UIColor, shape: ConfettiShape, position: ConfettiPosition) {
        self.color = color
        self.shape = shape
        self.position = position
    }
    
    /// Create the confetti image
    lazy var image: UIImage = {
        let imageRect: CGRect = {
            switch shape {
            case .rectangle:
                return CGRect(x: 0, y: 0, width: 20, height: 13)
            case .circle:
                return CGRect(x: 0, y: 0, width: 10, height: 10)
            }
        }()

        UIGraphicsBeginImageContext(imageRect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)

        switch shape {
        case .rectangle:
            context.fill(imageRect)
        case .circle:
            context.fillEllipse(in: imageRect)
        }

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }()
}

enum ConfettiShape {
    case rectangle
    case circle
}

enum ConfettiPosition {
    case foreground
    case background
}
