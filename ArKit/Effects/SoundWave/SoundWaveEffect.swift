import Foundation
import SceneKit

class SoundWaveEffect {
    static func createAndAnimate(on parent: SCNNode, color: UIColor = UIColor.white.withAlphaComponent(0.7), duration: TimeInterval = 0.7, initialRadius: CGFloat = 0.1, finalRadius: CGFloat = 0.2) {
        // Crear un torus delgado (círculo)
        let torus = SCNTorus(ringRadius: initialRadius, pipeRadius: 0.001)
        let material = SCNMaterial()
        material.diffuse.contents = color
        material.isDoubleSided = true
        material.emission.contents = color
        material.blendMode = .add
        torus.materials = [material]
        let node = SCNNode(geometry: torus)
        node.opacity = 1.0
        node.eulerAngles = SCNVector3(Double.pi / 2, 0, 0) // plano XY
        node.position.z = 0.03 // delante de la máscara
        
        parent.addChildNode(node)
        
        // Animar el crecimiento y desvanecimiento
        let scaleAction = SCNAction.customAction(duration: duration) { (node, elapsed) in
            let t = CGFloat(elapsed / CGFloat(duration))
            let currentRadius = initialRadius + (finalRadius - initialRadius) * t
            (node.geometry as? SCNTorus)?.ringRadius = currentRadius
            node.opacity = CGFloat(Float(1.0 - t))
        }
        let removeAction = SCNAction.removeFromParentNode()
        let sequence = SCNAction.sequence([scaleAction, removeAction])
        node.runAction(sequence)
    }
} 
