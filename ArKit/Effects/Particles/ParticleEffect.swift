import Foundation
import SceneKit
import ARKit

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
         particleSize: Float = 1, 
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
        
        // Dispersión total
        particleSystem.spreadingAngle = 180
        
        // Emission shape (sphere around the node)
        particleSystem.emitterShape = createEmissionShape()
        
        // Create the node with particle system
        let node = SCNNode()
        node.addParticleSystem(particleSystem)
        
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
    
    // MARK: - Private Methods
    
    /// Creates an emission shape for the particles
    private func createEmissionShape() -> SCNGeometry {
        let sphere = SCNSphere(radius: 0.15)
        return sphere
    }
}

// MARK: - Particle Effect Presets
extension ParticleEffect {
    
    /// Creates a magical sparkle effect
    static func magicalSparkle() -> ParticleEffect {
        return ParticleEffect(
            particleCount: 100,
            particleSize: 0.025,
            particleColor: UIColor(red: 1.0, green: 0.5, blue: 1.0, alpha: 1.0), // Bright magenta
            birthRate: 25.0,
            lifetime: 2.0
        )
    }
    
    /// Creates a fire effect
    static func fireEffect() -> ParticleEffect {
        return ParticleEffect(
            particleCount: 80,
            particleSize: 0.04,
            particleColor: UIColor(red: 1.0, green: 0.3, blue: 0.0, alpha: 1.0), // Bright orange
            birthRate: 30.0,
            lifetime: 1.5
        )
    }
    
    /// Creates a mystical aura effect
    static func mysticalAura() -> ParticleEffect {
        return ParticleEffect(
            particleCount: 60,
            particleSize: 0.035,
            particleColor: UIColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0), // Bright cyan
            birthRate: 15.0,
            lifetime: 3.0
        )
    }
    
    /// Creates a golden sparkle effect (very visible)
    static func goldenSparkle() -> ParticleEffect {
        return ParticleEffect(
            particleCount: 120,
            particleSize: 0.05,
            particleColor: UIColor(red: 0.8, green: 0.7, blue: 0.2, alpha: 0.4), // Bright gold
            birthRate: 1.0,
            lifetime: 2.5
        )
    }
} 
