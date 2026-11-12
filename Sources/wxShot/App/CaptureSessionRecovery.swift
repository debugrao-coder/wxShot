import Foundation

enum CaptureSessionRecovery {
    static let waitingTimeout: TimeInterval = 15
    static let sessionTimeout: TimeInterval = 12 * 60 * 60

    static func shouldRecover(
        sessionEnded: Bool,
        isOverlayPresented: Bool,
        isWaitingForSnapshot: Bool,
        isWaitingForWindowCapture: Bool,
        elapsed: TimeInterval
    ) -> Bool {
        if sessionEnded { return true }
        if elapsed < 0 { return true }
        if isWaitingForSnapshot || isWaitingForWindowCapture || !isOverlayPresented {
            return elapsed >= waitingTimeout
        }
        return elapsed >= sessionTimeout
    }
}
