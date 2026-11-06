#if DEBUG
import AppKit

/// `WXSHOT_SNAPSHOT=<dir> [WXSHOT_LANG=zh|en|…] .build/debug/wxShot` renders real windows and the real toolbar to PNG
/// (no Screen Recording permission needed) for the website, then quits.
enum DebugSnapshots {
    static func runIfRequested() -> Bool {
        guard let dir = ProcessInfo.processInfo.environment["WXSHOT_SNAPSHOT"] else { return false }
        let out = URL(fileURLWithPath: dir, isDirectory: true)
        try? FileManager.default.createDirectory(at: out, withIntermediateDirectories: true)
        if let raw = ProcessInfo.processInfo.environment["WXSHOT_LANG"], let lang = AppLanguage(rawValue: raw) {
            Defaults.language = lang
        }
        let tag = Defaults.language.lprojName
        DispatchQueue.main.async {
            let scene = toolbarScene()
            let preview = NSWindow(contentRect: scene.bounds, styleMask: [.borderless], backing: .buffered, defer: false)
            preview.isReleasedWhenClosed = false
            preview.contentView = scene
            preview.center()
            preview.orderFrontRegardless()
            // 同一批控件来回切换，覆盖首次渲染和已打开窗口的刷新。
            for (name, appearance) in [("light", NSAppearance.Name.aqua), ("dark", .darkAqua), ("light-restored", .aqua)] {
                NSApp.appearance = NSAppearance(named: appearance)
                for (kind, controller) in [("settings", SettingsWindowController.shared as NSWindowController),
                                           ("onboarding", OnboardingWindowController.shared as NSWindowController)] {
                    controller.window?.orderFrontRegardless()
                    controller.window?.displayIfNeeded()
                    if let view = controller.window?.contentView {
                        write(view, to: out.appendingPathComponent("\(kind)-\(tag)-\(name).png"))
                    }
                }
                preview.displayIfNeeded()
                write(scene, to: out.appendingPathComponent("toolbar-\(name).png"))
            }
            if ProcessInfo.processInfo.environment["WXSHOT_SNAPSHOT_HOLD"] == "1" {
                // 保留真实窗口，供手工检查系统材质与按钮交互。
                NSApp.appearance = NSAppearance(named: .darkAqua)
                for window in NSApp.windows where window !== preview { window.orderOut(nil) }
                preview.makeKeyAndOrderFront(nil)
                NSApp.activate(ignoringOtherApps: true)
                return
            }
            preview.close()
            NSApp.appearance = nil
            let lens = MagnifierLensPanelWindow()
            if let cg = lensTestImage() {
                lens.update(snapshot: cg, screenFrame: NSRect(x: 0, y: 0, width: 400, height: 300),
                            mouseLocation: NSPoint(x: 200, y: 150), format: .hex)
            }
            if let view = lens.contentView { write(view, to: out.appendingPathComponent("lens.png")) }
            if let sample = NSImage(contentsOfFile: out.appendingPathComponent("../ocr-sample.png").path) {
                TextRecognitionPanel.present(image: sample, anchorRect: NSRect(x: 200, y: 300, width: 400, height: 200), screen: NSScreen.main!)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    if let v = TextRecognitionPanel.debugContent { write(v, to: out.appendingPathComponent("ocr.png")) }
                    NSApp.terminate(nil)
                }
                return
            }
            NSApp.terminate(nil)
        }
        return true
    }

    private static func toolbarScene() -> NSView {
        let size = NSSize(width: 1000, height: 420)
        let scene = AdaptiveChromeSurfaceView(style: .panel)
        scene.frame = NSRect(origin: .zero, size: size)

        let selection = NSView(frame: NSRect(x: 50, y: 120, width: 900, height: 250))
        selection.wantsLayer = true
        selection.layer?.backgroundColor = NSColor.white.cgColor
        selection.layer?.borderColor = NSColor.systemGreen.cgColor
        selection.layer?.borderWidth = 2
        scene.addSubview(selection)

        let toolbar = ToolbarView(items: ToolbarLayout.default.primary, orientation: .horizontal)
        toolbar.updateSelection(tool: .rectangle)
        toolbar.setUndoEnabled(false)
        toolbar.frame.origin = NSPoint(x: selection.frame.maxX - toolbar.frame.width, y: selection.frame.minY - toolbar.frame.height - 10)
        scene.addSubview(toolbar)
        return scene
    }

    private static func lensTestImage() -> CGImage? {
        let image = NSImage(size: NSSize(width: 400, height: 300), flipped: false) { rect in
            NSColor(white: 0.985, alpha: 1).setFill(); rect.fill()
            NSColor.darkGray.setFill(); NSRect(x: 150, y: 100, width: 60, height: 60).fill()
            return true
        }
        return image.cgImage(forProposedRect: nil, context: nil, hints: nil)
    }

    private static func write(_ view: NSView, to url: URL) {
        view.layoutSubtreeIfNeeded()
        guard let rep = view.bitmapImageRepForCachingDisplay(in: view.bounds) else { return }
        view.cacheDisplay(in: view.bounds, to: rep)
        try? rep.representation(using: .png, properties: [:])?.write(to: url)
    }
}
#endif
