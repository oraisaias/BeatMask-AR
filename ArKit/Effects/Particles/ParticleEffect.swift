import Foundation
import SceneKit
import ARKit
import AVFoundation
import Accelerate

/// Represents a single particle effect that can be attached to AR nodes
class ParticleEffect {
    
    // MARK: - Properties
    var particleNode: SCNNode
    var isActive: Bool = false
    var particleCount: Int
    var particleSize: Float
    var particleColor: UIColor
    var birthRate: Float
    var lifetime: Float
    
    // MARK: - Initialization
    init(particleCount: Int = 50, 
         particleSize: Float = 0.01,
         particleColor: UIColor = .systemBlue, 
         birthRate: Float = 10.0, 
         lifetime: Float = 2.0) {
        
        self.particleCount = particleCount
        self.particleSize = particleSize
        self.particleColor = particleColor
        self.birthRate = birthRate
        self.lifetime = lifetime
        
        // Create the particle node
        self.particleNode = SCNNode()
        self.particleNode.name = "ParticleEffect"
    }
    
    // MARK: - Public Methods
    
    /// Creates and returns a particle system node
    func createParticleSystem() -> SCNNode {
        let particleSystem = SCNParticleSystem()
        
        // Configure particle system properties
        particleSystem.particleSize = CGFloat(particleSize)
        particleSystem.particleColor = particleColor
        particleSystem.particleColorVariation = SCNVector4(0.2, 0.2, 0.2, 0.3)
        particleSystem.emissionDuration = 0.0 // Continuous emission
        particleSystem.birthRate = CGFloat(birthRate)
        particleSystem.particleLifeSpan = CGFloat(lifetime)
        particleSystem.particleLifeSpanVariation = CGFloat(lifetime * 0.5)
        
        // Physics and movement - Más envolvente y mágico
        particleSystem.particleVelocity = 0.1
        particleSystem.particleVelocityVariation = 1.0
        particleSystem.particleAngularVelocity = 0.5
        particleSystem.particleAngularVelocityVariation = 0.3
        
        // Sin aceleración vertical
        particleSystem.acceleration = SCNVector3(0, 0, 0)
        
        // Dispersión lateral
        particleSystem.spreadingAngle = 90 // Menos dispersión vertical, más lateral
        
        // Emission shape (toroide alrededor de la cara)
        particleSystem.emitterShape = createEmissionShape()
        
        // Create the node with particle system
        let node = SCNNode()
        node.addParticleSystem(particleSystem)
        
        // Orientar el anillo para que esté perpendicular al rostro (eje Y)
        node.eulerAngles = SCNVector3(Double.pi / 2, 0, 0)
        
        return node
    }
    
    /// Attaches the particle effect to a target node
    func attach(to targetNode: SCNNode) {
        let particleSystemNode = createParticleSystem()
        targetNode.addChildNode(particleSystemNode)
        self.particleNode = particleSystemNode
        self.isActive = true
    }
    
    /// Removes the particle effect
    func remove() {
        particleNode.removeFromParentNode()
        self.isActive = false
    }
    
    /// Anima el cambio de color de las partículas
    func animateColorChange(to newColor: UIColor, duration: TimeInterval = 0.5) {
        guard let particleSystem = particleNode.particleSystems?.first else { return }
        let startColor = particleSystem.particleColor ?? UIColor.white
        let steps = 30
        for i in 0...steps {
            let t = CGFloat(i) / CGFloat(steps)
            let interpolatedColor = startColor.interpolateRGBColorTo(end: newColor, fraction: t)
            DispatchQueue.main.asyncAfter(deadline: .now() + duration * Double(t)) {
                particleSystem.particleColor = interpolatedColor
            }
        }
    }
    
    // MARK: - Private Methods
    
    /// Creates an emission shape for the particles
    private func createEmissionShape() -> SCNGeometry {
        // Toroide (anillo) alrededor de la cara
        let torus = SCNTorus(ringRadius: 0.18, pipeRadius: 0.01)
        return torus
    }
}

// MARK: - Particle Effect Presets
extension ParticleEffect {
    
    /// Creates a magical sparkle effect
    static func magicalSparkle() -> ParticleEffect {
        return ParticleEffect(
            particleCount: 100,
            particleSize: 0.006,
            particleColor: UIColor(red: 1.0, green: 0.5, blue: 1.0, alpha: 1.0),
            birthRate: 25.0,
            lifetime: 2.0
        )
    }
    
    /// Creates a fire effect
    static func fireEffect() -> ParticleEffect {
        return ParticleEffect(
            particleCount: 80,
            particleSize: 0.008,
            particleColor: UIColor(red: 1.0, green: 0.3, blue: 0.0, alpha: 1.0),
            birthRate: 30.0,
            lifetime: 1.5
        )
    }
    
    /// Creates a mystical aura effect
    static func mysticalAura() -> ParticleEffect {
        return ParticleEffect(
            particleCount: 60,
            particleSize: 0.007,
            particleColor: UIColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0),
            birthRate: 15.0,
            lifetime: 3.0
        )
    }
    
    /// Creates a golden sparkle effect (very visible)
    static func goldenSparkle() -> ParticleEffect {
        return ParticleEffect(
            particleCount: 120,
            particleSize: 0.009,
            particleColor: UIColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0),
            birthRate: 2.0,
            lifetime: 2.5
        )
    }
}

// MARK: - UIColor Interpolation Helper
extension UIColor {
    func interpolateRGBColorTo(end: UIColor, fraction: CGFloat) -> UIColor {
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        self.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        end.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        return UIColor(red: r1 + (r2 - r1) * fraction,
                       green: g1 + (g2 - g1) * fraction,
                       blue: b1 + (b2 - b1) * fraction,
                       alpha: a1 + (a2 - a1) * fraction)
    }
} 
