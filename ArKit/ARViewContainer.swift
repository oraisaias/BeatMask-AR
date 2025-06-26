import SwiftUI
import ARKit
import SceneKit

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

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARFaceAnchor else { return }
        node.addChildNode(loadVeniceMask())
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
