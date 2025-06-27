import SwiftUI
import ARKit
import SceneKit
import AVFoundation

struct ARViewContainer: UIViewRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> ARSCNView {
        let sceneView = ARSCNView()
        sceneView.delegate = context.coordinator
        sceneView.automaticallyUpdatesLighting = true
        sceneView.scene = SCNScene()

        guard ARFaceTrackingConfiguration.isSupported else {
            print("❌ Face tracking no soportado")
            return sceneView
        }

        let config = ARFaceTrackingConfiguration()
        config.isLightEstimationEnabled = true
        sceneView.session.run(config, options: [.resetTracking, .removeExistingAnchors])

        context.coordinator.sceneView = sceneView
        return sceneView
    }

    func updateUIView(_ uiView: ARSCNView, context: Context) {}
}

class Coordinator: NSObject, ARSCNViewDelegate {
    weak var sceneView: ARSCNView?
    private let audioEngine = AudioReactiveEngine()
    private var maskNode: SCNNode?
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARFaceAnchor else { return }
        let mask = loadVeniceMask()
        node.addChildNode(mask)
        self.maskNode = mask
        let smoke = ParticleEffect.subtleSmoke()
        let smokeNode = SCNNode()
        smokeNode.position = SCNVector3(0, 0.05, 0)
        mask.addChildNode(smokeNode)
        smoke.attach(to: smokeNode)
        audioEngine.onBeatDetected = { [weak node, weak self] in
            guard let node = node, let mask = self?.maskNode else { return }
            SoundWaveEffect.createAndAnimate(on: node)
            let baseScale: CGFloat = 0.001
            let pulseUp = SCNAction.scale(to: baseScale * 1.02, duration: 0.08)
            let pulseDown = SCNAction.scale(to: baseScale, duration: 0.18)
            let pulseSequence = SCNAction.sequence([pulseUp, pulseDown])
            mask.removeAction(forKey: "pulse")
            mask.runAction(pulseSequence, forKey: "pulse")
        }
        audioEngine.start()
    }
    
    private func loadVeniceMask() -> SCNNode {
        guard let scene = try? SCNScene(named: "Mask.usdz") else {
            print("❌ No se pudo cargar 'Venice_Mask.usdz'")
            return SCNNode()
        }
        let modelNode = SCNNode()
        for child in scene.rootNode.childNodes {
            modelNode.addChildNode(child)
        }
        modelNode.position = SCNVector3(0, 0.001, 0)
        modelNode.scale = SCNVector3(0.001, 0.001, 0.001)
        let light = SCNLight()
        light.type = .ambient
        light.intensity = 1000
        let light2 = SCNLight()
        light2.type = .directional
        light2.intensity = 100
        let lightNode = SCNNode()
        lightNode.light = light
        modelNode.addChildNode(lightNode)
        return modelNode
    }
}
