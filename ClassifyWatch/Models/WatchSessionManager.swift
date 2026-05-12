import Foundation
import WatchConnectivity

class WatchSessionManager: NSObject, ObservableObject {
    @Published var isSessionActive: Bool = false
    @Published var isReachable: Bool = false

    private(set) var sessionStartTime: Date?

    override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    // MARK: - Sending

    func sendSamples(_ samples: [[Double]]) {
        guard WCSession.default.activationState == .activated else { return }

        let batchSize = 25
        let batches = stride(from: 0, to: samples.count, by: batchSize).map {
            Array(samples[$0..<min($0 + batchSize, samples.count)])
        }

        DispatchQueue.global(qos: .userInitiated).async {
            let session = WCSession.default
            for (index, batch) in batches.enumerated() {
                let isLast = index == batches.count - 1
                session.transferUserInfo([
                    "samples":    batch,
                    "batchIndex": index,
                    "isLast":     isLast
                ])
                if !isLast {
                    Thread.sleep(forTimeInterval: 0.05)
                }
            }
        }
    }
}

// MARK: - WCSessionDelegate

extension WatchSessionManager: WCSessionDelegate {
    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
        }
        if let error { print("WatchSessionManager activation error: \(error)") }

        // Restore session state from the last context written by the iPhone
        if let isActive = session.receivedApplicationContext["isSessionActive"] as? Bool {
            DispatchQueue.main.async {
                self.isSessionActive = isActive
                if isActive, self.sessionStartTime == nil { self.sessionStartTime = Date() }
                else if !isActive { self.sessionStartTime = nil }
            }
        }
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        guard let isActive = applicationContext["isSessionActive"] as? Bool else { return }
        DispatchQueue.main.async {
            self.isSessionActive = isActive
            if isActive, self.sessionStartTime == nil { self.sessionStartTime = Date() }
            else if !isActive { self.sessionStartTime = nil }
        }
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
        }
    }

    // Receive commands from iPhone (sent via sendMessage)
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        guard let command = message["command"] as? String else { return }
        processCommand(command)
    }

    // Also handle commands sent via transferUserInfo (fallback)
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any]) {
        guard let command = userInfo["command"] as? String else { return }
        processCommand(command)
    }

    private func processCommand(_ command: String) {
        DispatchQueue.main.async {
            switch command {
            case "start":
                self.sessionStartTime = Date()
                self.isSessionActive = true
            case "stop":
                self.isSessionActive = false
                self.sessionStartTime = nil
            default:
                break
            }
        }
    }
}
