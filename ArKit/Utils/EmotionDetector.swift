import Foundation
import ARKit

enum Emotion: String {
    case alegre, triste, enojado, sorprendido, neutral
}

struct EmotionDetector {
    static func detectEmotion(from blendShapes: [ARFaceAnchor.BlendShapeLocation : NSNumber]) -> Emotion {
        let smile = (blendShapes[.mouthSmileLeft]?.floatValue ?? 0) + (blendShapes[.mouthSmileRight]?.floatValue ?? 0)
        let frown = (blendShapes[.mouthFrownLeft]?.floatValue ?? 0) + (blendShapes[.mouthFrownRight]?.floatValue ?? 0)
        let browDown = (blendShapes[.browDownLeft]?.floatValue ?? 0) + (blendShapes[.browDownRight]?.floatValue ?? 0)
        let browUp = blendShapes[.browInnerUp]?.floatValue ?? 0
        let jawOpen = blendShapes[.jawOpen]?.floatValue ?? 0
        let eyeWide = (blendShapes[.eyeWideLeft]?.floatValue ?? 0) + (blendShapes[.eyeWideRight]?.floatValue ?? 0)
        if smile > 0.7 { return .alegre }
        if frown > 0.5 && browUp > 0.3 { return .triste }
        if browDown > 0.5 && frown > 0.3 { return .enojado }
        if jawOpen > 0.5 && eyeWide > 0.5 { return .sorprendido }
        return .neutral
    }
} 