import Foundation
import CoreMotion

class WatchMotionManager: ObservableObject {
    @Published var isRecording: Bool = false
    private(set) var collectedSamples: [[Double]] = []

    private let motionManager = CMMotionManager()
    private let updateInterval: TimeInterval = 1.0 / 50.0   // 50 Hz
    private let queue = OperationQueue()

    func startRecording() {
        guard motionManager.isDeviceMotionAvailable else {
            print("WatchMotionManager: device motion not available")
            return
        }
        collectedSamples = []
        motionManager.deviceMotionUpdateInterval = updateInterval
        motionManager.startDeviceMotionUpdates(to: queue) { [weak self] motion, error in
            guard let self, let motion, error == nil else { return }

            // Accelerometer: userAcceleration + gravity × 9.81 → m/s²
            let ax = (motion.userAcceleration.x + motion.gravity.x) * 9.81
            let ay = (motion.userAcceleration.y + motion.gravity.y) * 9.81
            let az = -((motion.userAcceleration.z + motion.gravity.z) * 9.81)

            // Gyroscope: rotationRate → rad/s
            let gx = motion.rotationRate.x
            let gy = motion.rotationRate.y
            let gz = motion.rotationRate.z

            self.collectedSamples.append([ax, ay, az, gx, gy, gz])
        }
        DispatchQueue.main.async { self.isRecording = true }
    }

    func stopRecording() -> [[Double]] {
        motionManager.stopDeviceMotionUpdates()
        DispatchQueue.main.async { self.isRecording = false }
        return collectedSamples
    }
}
