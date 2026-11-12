import XCTest
@testable import wxShot

final class LogicTests: XCTestCase {
    func testReportCheckpoints() {
        XCTAssertEqual(SurvivalReporter.dueCheckpoint(ageDays: 0, lastSent: -1), 0)
        XCTAssertNil(SurvivalReporter.dueCheckpoint(ageDays: 0, lastSent: 0))
        XCTAssertNil(SurvivalReporter.dueCheckpoint(ageDays: 5, lastSent: 3))
        XCTAssertEqual(SurvivalReporter.dueCheckpoint(ageDays: 8, lastSent: 3), 7)
        XCTAssertEqual(SurvivalReporter.dueCheckpoint(ageDays: 95, lastSent: 30), 90)
        XCTAssertNil(SurvivalReporter.dueCheckpoint(ageDays: 40, lastSent: 30))
    }

    func testWeChatOwnership() {
        let monitor = WeChatMonitor.shared
        // State is machine dependent, so only check the pure policy table through a fresh evaluation of each policy.
        for policy in WeChatPolicy.allCases {
            let owns = monitor.shouldOwnShortcut(policy: policy)
            switch monitor.state {
            case .notRunning: XCTAssertTrue(owns)
            case .loginScreen: XCTAssertEqual(owns, policy != .yieldWhenRunning)
            case .loggedIn: XCTAssertEqual(owns, policy == .alwaysUs)
            }
        }
    }

    func testDefaultShortcutIsOptionA() {
        let hk = HotkeyManager.defaultHotkey
        XCTAssertEqual(HotkeyManager.modifierString(hk.modifiers) + HotkeyManager.keyString(hk.keyCode), "⌥A")
    }

    func testStaleCaptureSessionRecovery() {
        let waitingTimeout = CaptureSessionRecovery.waitingTimeout
        let sessionTimeout = CaptureSessionRecovery.sessionTimeout

        XCTAssertTrue(CaptureSessionRecovery.shouldRecover(
            sessionEnded: true,
            isOverlayPresented: true,
            isWaitingForSnapshot: false,
            isWaitingForWindowCapture: false,
            elapsed: 0
        ))
        XCTAssertFalse(CaptureSessionRecovery.shouldRecover(
            sessionEnded: false,
            isOverlayPresented: false,
            isWaitingForSnapshot: false,
            isWaitingForWindowCapture: false,
            elapsed: waitingTimeout - 1
        ))
        XCTAssertTrue(CaptureSessionRecovery.shouldRecover(
            sessionEnded: false,
            isOverlayPresented: false,
            isWaitingForSnapshot: false,
            isWaitingForWindowCapture: false,
            elapsed: waitingTimeout + 1
        ))
        XCTAssertTrue(CaptureSessionRecovery.shouldRecover(
            sessionEnded: false,
            isOverlayPresented: true,
            isWaitingForSnapshot: true,
            isWaitingForWindowCapture: false,
            elapsed: waitingTimeout + 1
        ))
        XCTAssertFalse(CaptureSessionRecovery.shouldRecover(
            sessionEnded: false,
            isOverlayPresented: true,
            isWaitingForSnapshot: false,
            isWaitingForWindowCapture: false,
            elapsed: sessionTimeout - 1
        ))
        XCTAssertTrue(CaptureSessionRecovery.shouldRecover(
            sessionEnded: false,
            isOverlayPresented: true,
            isWaitingForSnapshot: false,
            isWaitingForWindowCapture: false,
            elapsed: sessionTimeout + 1
        ))
        XCTAssertTrue(CaptureSessionRecovery.shouldRecover(
            sessionEnded: false,
            isOverlayPresented: true,
            isWaitingForSnapshot: false,
            isWaitingForWindowCapture: false,
            elapsed: -1
        ))
        XCTAssertTrue(CaptureSessionRecovery.shouldRecover(
            sessionEnded: false,
            isOverlayPresented: false,
            isWaitingForSnapshot: true,
            isWaitingForWindowCapture: false,
            elapsed: -1
        ))
    }
}
