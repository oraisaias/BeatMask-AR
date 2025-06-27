import Foundation
import AVFoundation
import Accelerate

class AudioReactiveEngine {
    private let audioEngine = AVAudioEngine()
    private let fftSize = 1024
    private var lastBeatTime: TimeInterval = 0
    private let beatCooldown: TimeInterval = 0.25 // mínimo tiempo entre beats
    private var energyHistory: [Float] = []
    private let historyLength = 43 // ~1 segundo a 44100Hz y 1024 samples
    
    /// Closure que se llama cuando se detecta un beat
    var onBeatDetected: (() -> Void)?
    
    func start() {
        let inputNode = audioEngine.inputNode
        let bus = 0
        let format = inputNode.inputFormat(forBus: bus)
        
        inputNode.installTap(onBus: bus, bufferSize: AVAudioFrameCount(fftSize), format: format) { [weak self] (buffer, time) in
            self?.process(buffer: buffer, format: format)
        }
        
        do {
            try audioEngine.start()
        } catch {
            print("Error al iniciar AVAudioEngine: \(error)")
        }
    }
    
    func stop() {
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.stop()
    }
    
    private func process(buffer: AVAudioPCMBuffer, format: AVAudioFormat) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let frameLength = Int(buffer.frameLength)
        let log2n = vDSP_Length(log2(Float(fftSize)))
        
        // Copia los datos del canal a un array y aplica ventana de Hanning
        var windowed = [Float](repeating: 0, count: fftSize)
        let window = vDSP.window(ofType: Float.self, usingSequence: .hanningDenormalized, count: fftSize, isHalfWindow: false)
        vDSP_vmul(channelData, 1, window, 1, &windowed, 1, vDSP_Length(min(frameLength, fftSize)))
        
        // Rellena con ceros si el frame es menor que fftSize
        if frameLength < fftSize {
            for i in frameLength..<fftSize {
                windowed[i] = 0
            }
        }
        
        // FFT
        var realp = [Float](repeating: 0, count: fftSize/2)
        var imagp = [Float](repeating: 0, count: fftSize/2)
        var splitComplex = DSPSplitComplex(realp: &realp, imagp: &imagp)
        windowed.withUnsafeBufferPointer { ptr in
            ptr.baseAddress!.withMemoryRebound(to: DSPComplex.self, capacity: fftSize) { complexPtr in
                let fftSetup = vDSP_create_fftsetup(log2n, FFTRadix(kFFTRadix2))
                vDSP_ctoz(complexPtr, 2, &splitComplex, 1, vDSP_Length(fftSize/2))
                vDSP_fft_zrip(fftSetup!, &splitComplex, 1, log2n, FFTDirection(FFT_FORWARD))
                vDSP_destroy_fftsetup(fftSetup)
            }
        }
        
        // Magnitud de frecuencias bajas (0-200Hz aprox)
        let nyquist = 0.5 * format.sampleRate
        let lowFreqLimit: Float = 200.0
        let lowFreqIndex = Int(Float(fftSize) * lowFreqLimit / Float(nyquist))
        let magnitudes = (0..<lowFreqIndex).map { sqrt(realp[$0]*realp[$0] + imagp[$0]*imagp[$0]) }
        let energy = magnitudes.reduce(0, +) / Float(lowFreqIndex)
        
        // Historial para umbral adaptativo
        energyHistory.append(energy)
        if energyHistory.count > historyLength {
            energyHistory.removeFirst()
        }
        let avgEnergy = energyHistory.reduce(0, +) / Float(energyHistory.count)
        let threshold = avgEnergy * 1 // Umbral dinámico
        
        let now = Date().timeIntervalSince1970
        if energy > threshold && (now - lastBeatTime) > beatCooldown {
            lastBeatTime = now
            DispatchQueue.main.async {
                self.onBeatDetected?()
            }
        }
    }
} 
