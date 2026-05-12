import Foundation
import WatchConnectivity

protocol WatchConnectivityDelegate: AnyObject {
    var isSessionActive: Bool { get }
    func didReceiveSamples(_ samples: [[Double]])
    func didLoseConnection()
}

class WatchConnectivityManager: NSObject, ObservableObject {
    weak var delegate: WatchConnectivityDelegate?

    private var pendingBatches: [Int: [[Double]]] = [:]

    override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    // MARK: - Commands

    func sendStartCommand() {
        guard WCSession.isSupported(),
              WCSession.default.activationState == .activated else { return }
        try? WCSession.default.updateApplicationContext(["isSessionActive": true])
        // sendMessage: immediate delivery when Watch is reachable
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(["command": "start"], replyHandler: nil, errorHandler: nil)
        }
        // transferUserInfo: guaranteed-delivery fallback (queued even when Watch is asleep)
        WCSession.default.transferUserInfo(["command": "start"])
    }

    func sendStopCommand() {
        guard WCSession.isSupported(),
              WCSession.default.activationState == .activated else { return }
        try? WCSession.default.updateApplicationContext(["isSessionActive": false])
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(["command": "stop"], replyHandler: nil, errorHandler: nil)
        }
        WCSession.default.transferUserInfo(["command": "stop"])
    }
}

// MARK: - WCSessionDelegate

extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {
        if let error { print("WCSession activation error: \(error)") }
        guard activationState == .activated else { return }
        try? session.updateApplicationContext(["isSessionActive": false])
    }

    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any]) {
        processSamplePacket(userInfo)
    }

    // Defensive handler: processes sample batches if Watch ever uses sendMessage
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        processSamplePacket(message)
    }

    private func processSamplePacket(_ packet: [String: Any]) {
        guard let samples    = packet["samples"]    as? [[Double]],
              let batchIndex = packet["batchIndex"] as? Int,
              let isLast     = packet["isLast"]     as? Bool
        else { return }

        pendingBatches[batchIndex] = samples

        if isLast {
            let allSamples = pendingBatches
                .sorted { $0.key < $1.key }
                .flatMap { $0.value }
            pendingBatches.removeAll()

            DispatchQueue.global(qos: .userInitiated).async {
                self.delegate?.didReceiveSamples(allSamples)
            }
        }
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        guard let delegate, delegate.isSessionActive else { return }
        if !session.isReachable {
            delegate.didLoseConnection()
        }
    }
}
