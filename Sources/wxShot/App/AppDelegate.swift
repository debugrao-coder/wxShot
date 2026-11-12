import AppKit

/// wxShot lives in the background: no Dock icon, no menu bar icon by default. The screenshot shortcut works as soon as
/// the app is running, and launching the app again opens Settings.
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusBarController: StatusBarController?
    private var overlayController: OverlayWindowController?
    private var suspendedEditDraft: OverlayWindowController.SuspendedEditDraft?
    private var pendingReopenSettingsWorkItem: DispatchWorkItem?
    private var captureSessionGeneration: Int = 0
    private var hotkeyHealthTimer: Timer?
    private var screenshotTriggerCallback: ((CaptureTriggerContext) -> Void)?
    private var quickPinTriggerCallback: (() -> Void)?
    private var fullScreenScreenshotTriggerCallback: (() -> Void)?

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        // A second copy would register the same shortcut and open a second, empty lens next to the first.
        if let bundleID = Bundle.main.bundleIdentifier,
           NSRunningApplication.runningApplications(withBundleIdentifier: bundleID).contains(where: { $0 != .current }) {
            NSApp.terminate(nil)
            return
        }
        #if DEBUG
        // 截图验收不注册全局快捷键、不检查更新，也不上报遥测。
        if DebugSnapshots.runIfRequested() { return }
        #endif
        ImageEditLauncher.clearTempDir()
        #if !MAS
        UpdateChecker.shared.checkAtLaunchIfDue()
        #endif
        if AppPermissions.screenRecordingGranted {
            OverlayWindowController.prewarmPresentationSurfaces()
            ScreenSnapshotProvider.shared.prewarm()
        }

        SettingsWindowController.shared.onMenuBarToggle = { [weak self] visible in
            self?.statusBarController?.setMenuBarVisible(visible)
        }
        statusBarController = StatusBarController(
            onTakeScreenshot: { [weak self] in self?.handleTrigger() },
            onTakeFullScreenScreenshot: { [weak self] in self?.handleFullScreenScreenshotTrigger() },
            onOpenSettings: { [weak self] in self?.openSettings() }
        )
        statusBarController?.setMenuBarVisible(Defaults.showMenuBar)

        for name in [Notification.Name.hotkeyDidChange, .weChatStateDidChange] {
            NotificationCenter.default.addObserver(forName: name, object: nil, queue: .main) { [weak self] _ in
                self?.applyHotkeyState()
            }
        }
        for name in [NSApplication.didBecomeActiveNotification, NSWorkspace.didWakeNotification] {
            let center: NotificationCenter = name == NSApplication.didBecomeActiveNotification
                ? NotificationCenter.default
                : NSWorkspace.shared.notificationCenter
            center.addObserver(forName: name, object: nil, queue: .main) { [weak self] _ in
                self?.recoverHotkeyRegistrationIfNeeded()
            }
        }
        hotkeyHealthTimer = Timer(timeInterval: 60, repeats: true) { [weak self] _ in
            self?.recoverHotkeyRegistrationIfNeeded()
        }
        if let hotkeyHealthTimer {
            RunLoop.main.add(hotkeyHealthTimer, forMode: .common)
        }
        WeChatMonitor.shared.start()
        SurvivalReporter.shared.start()
        applyHotkeyState()

        #if DEBUG
        if ProcessInfo.processInfo.environment["WXSHOT_DEBUG_CAPTURE"] == "1" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in self?.handleTrigger() }
            return
        }
        #endif
        if !Defaults.onboardingCompleted || !AppPermissions.screenRecordingGranted {
            OnboardingWindowController.shared.show()
        }
    }

    func applicationDidChangeScreenParameters(_ notification: Notification) {
        overlayController?.screenParametersDidChange()
        let displayIDs = Set(NSScreen.screens.compactMap { screen in
            screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID
        })
        ScreenSnapshotProvider.shared.invalidateAndPrewarm(displayIDs: displayIDs)
        OverlayWindowController.invalidateAndPrewarmPresentationSurfaces()
    }

    /// Opening the app again (Launchpad, Spotlight, double-click) is the way to reach Settings.
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        scheduleSettingsOpenFromReopen()
        return false
    }

    // MARK: - Hotkeys

    /// Registers the screenshot shortcut only while wxShot is supposed to own it (see `WeChatMonitor.shouldOwnShortcut`).
    private func applyHotkeyState() {
        let hotkeys = HotkeyManager.shared
        screenshotTriggerCallback = { [weak self] context in
            guard let self else {
                context.finish(.ignored)
                return
            }
            self.handleTrigger(fromShortcut: true, triggerContext: context)
        }
        quickPinTriggerCallback = { [weak self] in self?.handleQuickPinTrigger() }
        fullScreenScreenshotTriggerCallback = { [weak self] in
            self?.handleFullScreenScreenshotTrigger(fromShortcut: true)
        }
        if hotkeys.isRecording {
            hotkeys.unregister()
            hotkeys.unregisterQuickPin()
            hotkeys.unregisterFullScreenScreenshot()
            return
        }

        if WeChatMonitor.shared.shouldOwnShortcut() {
            if let callback = screenshotTriggerCallback {
                _ = hotkeys.register(callback: callback)
            }
        } else {
            hotkeys.unregister()
        }

        if Defaults.hasCustomQuickPinHotkey {
            if let callback = quickPinTriggerCallback {
                _ = hotkeys.registerQuickPin(callback: callback)
            }
        } else {
            hotkeys.unregisterQuickPin()
        }
        if Defaults.hasCustomFullScreenScreenshotHotkey {
            if let callback = fullScreenScreenshotTriggerCallback {
                _ = hotkeys.registerFullScreenScreenshot(callback: callback)
            }
        } else {
            hotkeys.unregisterFullScreenScreenshot()
        }
    }

    private func recoverHotkeyRegistrationIfNeeded() {
        let hotkeys = HotkeyManager.shared
        guard !hotkeys.isRecording else { return }
        let shouldOwnShortcut = WeChatMonitor.shared.shouldOwnShortcut()
        let expectedScreenshotRegistration = shouldOwnShortcut && hotkeys.currentHotkey() != nil
        let expectedQuickPinRegistration = Defaults.hasCustomQuickPinHotkey && hotkeys.currentQuickPinHotkey() != nil
        let expectedFullScreenRegistration = Defaults.hasCustomFullScreenScreenshotHotkey
            && hotkeys.currentFullScreenScreenshotHotkey() != nil
        let needsRecovery = hotkeys.isScreenshotHotkeyRegistered != expectedScreenshotRegistration
            || (expectedScreenshotRegistration && !hotkeys.isEventHandlerInstalled)
            || hotkeys.isQuickPinHotkeyRegistered != expectedQuickPinRegistration
            || hotkeys.isFullScreenScreenshotHotkeyRegistered != expectedFullScreenRegistration
        guard needsRecovery else { return }
        NSLog("wxShot hotkey health check: repairing registration")
        applyHotkeyState()
    }

    // MARK: - Capture

    func handleTrigger(
        fromShortcut: Bool = false,
        triggerContext: CaptureTriggerContext? = nil
    ) {
        let context = triggerContext ?? CaptureTriggerContext(
            source: fromShortcut ? .keyboardShortcut : .programmatic
        )
        context.mark(.handleTrigger)
        TextRecognitionPanel.dismissCurrent()

        guard recoverStaleCaptureSessionIfNeeded() else {
            context.finish(.ignored)
            return
        }
        guard AppPermissions.screenRecordingGranted else {
            context.finish(.ignored)
            OnboardingWindowController.shared.show()
            return
        }
        if resumeSuspendedEditIfAvailable() {
            context.finish(.rerouted)
            return
        }
        startCapture(
            triggerContext: context,
            onFirstFramePresented: fromShortcut ? {
                #if !MAS
                UpdateChecker.shared.checkFromScreenshotShortcutIfDue()
                #endif
            } : nil
        )
    }

    /// Select a screen region and pin it immediately after capture.
    func handleQuickPinTrigger() {
        guard recoverStaleCaptureSessionIfNeeded(), AppPermissions.screenRecordingGranted else { return }
        startCapture(postCaptureAction: .quickPin)
    }

    func handleFullScreenScreenshotTrigger(fromShortcut: Bool = false) {
        TextRecognitionPanel.dismissCurrent()
        guard recoverStaleCaptureSessionIfNeeded() else { return }
        guard AppPermissions.screenRecordingGranted else {
            OnboardingWindowController.shared.show()
            return
        }

        let focusRestorer = SourceAppFocusRestorer.captureFrontmostApplication()
        let cursorPoint = NSEvent.mouseLocation
        captureSessionGeneration += 1
        let generation = captureSessionGeneration
        let screen = NSScreen.screens.first(where: { $0.frame.contains(cursorPoint) })
            ?? NSScreen.main
            ?? NSScreen.screens.first
        guard let screen,
              let displayID = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID,
              let image = ScreenCapturer.capture(rect: CGDisplayBounds(displayID), screen: screen),
              let controller = ImageEditLauncher.launch(
                generatedImage: image,
                source: .fullScreen,
                onRequestFocusReturn: { focusRestorer.restore() },
                onSuspend: self.suspendedDraftHandler(for: generation),
                onComplete: self.completionHandler(for: generation)
              )
        else {
            ToastWindow.show(message: L10n.fullScreenScreenshotFailed)
            return
        }

        overlayController = controller
        applyHotkeyState()
    }

    /// Re-opens the editor for an image that was pinned (the pin toolbar's edit button).
    @discardableResult
    func handlePinnedImageEditRequest(_ image: NSImage, beforePresent: () -> Void) -> Bool {
        guard recoverStaleCaptureSessionIfNeeded() else { return false }
        beforePresent()
        let generation = captureSessionGeneration + 1

        guard let controller = ImageEditLauncher.launch(
            generatedImage: image,
            source: .pin,
            keepsEditorAcrossSpaces: Defaults.pinAcrossSpaces,
            onSuspend: suspendedDraftHandler(for: generation),
            onComplete: completionHandler(for: generation)
        ) else {
            return false
        }

        captureSessionGeneration = generation
        overlayController = controller
        applyHotkeyState()
        return true
    }

    func startCapture(
        postCaptureAction: OverlayWindowController.PostCaptureAction = .edit,
        triggerContext: CaptureTriggerContext? = nil,
        onFirstFramePresented: (() -> Void)? = nil
    ) {
        let context = triggerContext ?? CaptureTriggerContext(source: .programmatic)
        context.mark(.startCapture)
        guard recoverStaleCaptureSessionIfNeeded() else {
            context.finish(.ignored)
            return
        }
        captureSessionGeneration += 1
        let generation = captureSessionGeneration
        let focusRestorer = SourceAppFocusRestorer.captureFrontmostApplication()
        overlayController = OverlayWindowController(
            postCaptureAction: postCaptureAction,
            triggerContext: context,
            onFirstFramePresented: onFirstFramePresented,
            onRequestFocusReturn: { focusRestorer.restore() },
            onSuspend: suspendedDraftHandler(for: generation),
            onComplete: completionHandler(for: generation)
        )
        overlayController?.activate()
        applyHotkeyState()
    }

    private func completionHandler(for generation: Int) -> (NSImage?) -> Void {
        { [weak self] finalImage in
            self?.handleEditCompletion(finalImage, generation: generation)
        }
    }

    private func suspendedDraftHandler(for generation: Int) -> (OverlayWindowController.SuspendedEditDraft) -> Void {
        { [weak self] draft in
            self?.handleEditSuspension(draft, generation: generation)
        }
    }

    private func recoverStaleCaptureSessionIfNeeded() -> Bool {
        guard let controller = overlayController else { return true }
        let startedAt = controller.captureSessionStartedAt ?? .distantPast
        let elapsed = Date().timeIntervalSince(startedAt)
        let shouldRecover = CaptureSessionRecovery.shouldRecover(
            sessionEnded: controller.isCaptureSessionEnded,
            isOverlayPresented: controller.isOverlayPresented,
            isWaitingForSnapshot: controller.isWaitingForSnapshot,
            isWaitingForWindowCapture: controller.isWaitingForWindowCapture,
            elapsed: elapsed
        )
        guard shouldRecover else { return false }
        NSLog(
            "wxShot capture recovery: stale session elapsed=%.1f ended=%d presented=%d",
            elapsed,
            controller.isCaptureSessionEnded ? 1 : 0,
            controller.isOverlayPresented ? 1 : 0
        )
        captureSessionGeneration += 1
        overlayController = nil
        suspendedEditDraft = nil
        controller.forceCancel()
        TextRecognitionPanel.dismissCurrent()
        OverlayWindowController.recyclePresentationSurfaces()
        applyHotkeyState()
        return true
    }

    private func handleEditCompletion(_ finalImage: NSImage?, generation: Int) {
        guard generation == captureSessionGeneration else { return }
        if let finalImage = finalImage {
            SurvivalReporter.shared.count("capture")
            let quality = Defaults.screenshotClipboardQuality
            if quality.usesLossyCompression {
                ToastWindow.show(message: L10n.screenshotQualityCompressingClipboard, duration: 600)
            }
            ImageOutputEncoder.encodeClipboardAsync(image: finalImage, quality: quality) { result in
                if quality.usesLossyCompression {
                    ToastWindow.dismiss()
                }
                switch result {
                case .failure:
                    ToastWindow.show(message: L10n.screenshotCompressionFailed, duration: 3.0)
                case .success(let output):
                    ClipboardManager.copyToClipboard(imageOutput: output)
                    ToastWindow.show()
                }
            }
        }
        overlayController = nil
        applyHotkeyState()
    }

    private func handleEditSuspension(_ draft: OverlayWindowController.SuspendedEditDraft, generation: Int) {
        guard generation == captureSessionGeneration else { return }
        suspendedEditDraft = draft
        overlayController = nil
        applyHotkeyState()
        ToastWindow.show(
            message: L10n.editSuspendedToast,
            on: screen(for: draft),
            duration: 3.0
        )
    }

    private func resumeSuspendedEditIfAvailable() -> Bool {
        guard let draft = suspendedEditDraft else { return false }
        captureSessionGeneration += 1
        let generation = captureSessionGeneration
        let focusRestorer = SourceAppFocusRestorer.captureFrontmostApplication()
        let controller = OverlayWindowController(
            suspendedDraft: draft,
            onRequestFocusReturn: { focusRestorer.restore() },
            onSuspend: suspendedDraftHandler(for: generation),
            onComplete: completionHandler(for: generation)
        )
        suspendedEditDraft = nil
        overlayController = controller
        controller.activate()
        applyHotkeyState()
        return true
    }

    private func screen(for draft: OverlayWindowController.SuspendedEditDraft) -> NSScreen? {
        if let displayID = draft.screenDisplayID,
           let screen = NSScreen.screens.first(where: {
               ($0.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID) == displayID
           }) {
            return screen
        }
        return NSScreen.screens.first(where: { $0.frame == draft.screenFrame }) ?? NSScreen.main
    }

    // MARK: - Settings

    private func openSettings() {
        SettingsWindowController.shared.showAsSettings()
    }

    private func scheduleSettingsOpenFromReopen() {
        pendingReopenSettingsWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            guard let self, self.recoverStaleCaptureSessionIfNeeded() else { return }
            if OnboardingWindowController.shared.isVisible { return }
            self.openSettings()
        }
        pendingReopenSettingsWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: workItem)
    }
}
