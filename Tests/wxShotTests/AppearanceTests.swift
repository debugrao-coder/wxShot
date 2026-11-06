import AppKit
import XCTest
@testable import wxShot

@MainActor
final class AppearanceTests: XCTestCase {
    func testToolbarIconsRemainReadableInBothAppearances() throws {
        for name in [NSAppearance.Name.aqua, .darkAqua] {
            let appearance = try XCTUnwrap(NSAppearance(named: name))
            let foreground = AdaptiveChrome.resolvedColor(ToolbarItemID.rectangle.normalColor, for: appearance)
            let background = AdaptiveChrome.resolvedColor(AdaptiveChrome.toolbarBackground, for: appearance)
            let high = max(luminance(foreground), luminance(background))
            let low = min(luminance(foreground), luminance(background))
            XCTAssertGreaterThan((high + 0.05) / (low + 0.05), 4.5, "\(name)")
        }
    }

    func testExistingToolbarFollowsApplicationAppearanceRoundTrip() throws {
        let app = NSApplication.shared
        let original = app.appearance
        defer { app.appearance = original }
        let toolbar = ToolbarView(items: ToolbarLayout.default.primary, orientation: .horizontal)
        let window = NSWindow(contentRect: toolbar.bounds, styleMask: [.borderless], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.contentView = toolbar
        defer { window.close() }
        XCTAssertEqual(toolbar.material, .popover)
        XCTAssertEqual(toolbar.blendingMode, .withinWindow)
        XCTAssertEqual(toolbar.state, .active)
        XCTAssertEqual(toolbar.subviews.compactMap { $0 as? NSBox }.count, 3)
        var triggered: ToolbarItemID?
        toolbar.onItemTriggered = { triggered = $0 }
        let firstButton = try XCTUnwrap(toolbar.subviews.compactMap { $0 as? ToolButton }.first)
        firstButton.performClick(nil)
        XCTAssertEqual(triggered, .rectangle)
        XCTAssertNil(window.appearance)
        XCTAssertNil(toolbar.appearance)

        // 同一个窗口继承应用外观，验证浅色 → 深色 → 浅色，无需重新创建控件。
        for dark in [false, true, false] {
            app.appearance = NSAppearance(named: dark ? .darkAqua : .aqua)
            XCTAssertEqual(AdaptiveChrome.isDark(toolbar.effectiveAppearance), dark)
            // 毛玻璃由窗口合成器绘制；离屏只核对实际图标像素。
            let button = try XCTUnwrap(toolbar.subviews.compactMap { $0 as? ToolButton }.first)
            XCTAssertEqual(AdaptiveChrome.isDark(button.effectiveAppearance), dark)
            let bitmap = try XCTUnwrap(button.bitmapImageRepForCachingDisplay(in: button.bounds))
            button.cacheDisplay(in: button.bounds, to: bitmap)
            var pixels: [CGFloat] = []
            for y in 0..<bitmap.pixelsHigh {
                for x in 0..<bitmap.pixelsWide {
                    if let pixel = bitmap.colorAt(x: x, y: y)?.usingColorSpace(.deviceRGB), pixel.alphaComponent > 0.9 {
                        pixels.append(pixel.redComponent)
                    }
                }
            }
            XCTAssertFalse(pixels.isEmpty)
            let brightness = pixels.reduce(0, +) / CGFloat(max(1, pixels.count))
            if dark {
                XCTAssertGreaterThan(brightness, 0.7)
            } else {
                XCTAssertLessThan(brightness, 0.3)
            }
        }
    }

    func testLayerSurfacesRefreshWhenAppearanceChanges() throws {
        let surface = AdaptiveChromeSurfaceView(style: .card, cornerRadius: 6)
        let separator = AdaptiveSeparatorView(frame: NSRect(x: 0, y: 0, width: 1, height: 18))
        surface.addSubview(separator)
        for dark in [false, true, false] {
            surface.appearance = NSAppearance(named: dark ? .darkAqua : .aqua)
            // 直接触发 AppKit 生命周期回调，验证已经解析为 CGColor 的图层颜色。
            surface.viewDidChangeEffectiveAppearance()
            separator.viewDidChangeEffectiveAppearance()
            let fill = try XCTUnwrap(surface.layer?.backgroundColor)
            let divider = try XCTUnwrap(separator.layer?.backgroundColor)
            XCTAssertEqual(fill, AdaptiveChrome.resolvedCGColor(AdaptiveChrome.cardBackground, for: surface.effectiveAppearance))
            XCTAssertEqual(divider, AdaptiveChrome.resolvedCGColor(AdaptiveChrome.separator, for: separator.effectiveAppearance))
        }
    }

    func testMagnifierChoosesLightAndDarkBackgrounds() throws {
        let key = "magnifierLensPanelFollowSystemAppearance"
        let previous = Defaults.defaults.object(forKey: key)
        defer {
            if let previous { Defaults.defaults.set(previous, forKey: key) }
            else { Defaults.defaults.removeObject(forKey: key) }
        }
        Defaults.magnifierLensPanelFollowSystemAppearance = true
        let light = try XCTUnwrap(NSAppearance(named: .aqua))
        let dark = try XCTUnwrap(NSAppearance(named: .darkAqua))
        XCTAssertEqual(MagnifierLensPanelSampler.backgroundColor(forAppearance: light), MagnifierLensPanelSampler.lightBackgroundColor())
        XCTAssertEqual(MagnifierLensPanelSampler.backgroundColor(forAppearance: dark), MagnifierLensPanelSampler.darkBackgroundColor())
        Defaults.magnifierLensPanelFollowSystemAppearance = false
        XCTAssertEqual(MagnifierLensPanelSampler.backgroundColor(forAppearance: light), MagnifierLensPanelSampler.darkBackgroundColor())
    }

    private func luminance(_ color: NSColor) -> CGFloat {
        func linear(_ value: CGFloat) -> CGFloat {
            value <= 0.04045 ? value / 12.92 : pow((value + 0.055) / 1.055, 2.4)
        }
        return 0.2126 * linear(color.redComponent)
            + 0.7152 * linear(color.greenComponent)
            + 0.0722 * linear(color.blueComponent)
    }
}
