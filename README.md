<p align="center">
  <a href="https://ntfstool.com/wxshot/"><img src="docs/img/banner.jpg" alt="wxShot: the WeChat-style screenshot for Mac, no WeChat login needed" width="720"></a>
</p>

<h1 align="center">wxShot</h1>

<p align="center"><b>微信截图替代品 · 不登录微信也能用的 macOS 截图工具</b><br>
The WeChat-style screenshot for macOS that works when WeChat is not signed in.</p>

<p align="center">
  <a href="https://github.com/ntfstool/wxShot/releases/latest"><img alt="Release" src="https://img.shields.io/github/v/release/ntfstool/wxShot?color=2FB36C"></a>
  <img alt="Downloads" src="https://img.shields.io/github/downloads/ntfstool/wxShot/total?color=2FB36C">
  <img alt="macOS 14+" src="https://img.shields.io/badge/macOS-14%2B-555">
  <img alt="License MIT" src="https://img.shields.io/badge/license-MIT-2FB36C">
</p>

<p align="center">
  <a href="https://github.com/ntfstool/wxShot/releases/latest/download/wxShot.dmg"><b>Download wxShot.dmg / 下载</b></a> ·
  <a href="https://ntfstool.com/wxshot/">Website &amp; animated demo / 官网与动画演示</a> ·
  <a href="https://ntfstool.com/wxshot/how-it-works/">How it works</a> ·
  <a href="https://ntfstool.com/wxshot/faq/">FAQ</a> ·
  <a href="https://ntfstool.com/wxshot/changelog/">Changelog</a>
</p>

## 个人维护版

本 fork 增加默认跟随 macOS 系统外观的深浅色主题。截图工具栏使用 AppKit 原生浮层材质、系统图标颜色和强调色；工具栏、快捷键输入框与 OCR 预览底色随系统切换，截图内容与标注颜色保持原样。

个人版从本仓库源码构建，产物为 `dist/wxShot.app`，采用本机 ad-hoc 签名。操作步骤见[个人版维护](#个人版维护)，协作边界见 [AGENTS.md](AGENTS.md)。

本页指向 `ntfstool/wxShot` 的下载链接，以及体积、Apple 公证说明属于上游发行版；这些安装包不包含本 fork 的主题改动。应用内更新检查、官网及反馈入口目前也仍指向上游。

## Highlights

- **Only 2.8 MB**, signed and **notarized by Apple**. Apple silicon and Intel.
- **Runs silently in the background**: no Dock icon, no menu bar icon by default. Press `⌥A` and it appears; open the app again for Settings.
- **WeChat's toolbar, exactly**: rectangle, ellipse, emoji, arrow, pen, mosaic, text | translate, extract text, long screenshot | undo, save, pin, share, close, confirm. A `···` menu holds numbered markers, redo and more tools.
- **Works when WeChat is closed or signed out**, and steps aside when WeChat is signed in (configurable).
- **Color picker lens**: coordinates and pixel color, `⌘C` copies it.
- **Extract text and translate on your Mac** (Apple Vision, Apple Translation). The screenshot sits on the left, the text on the right.
- **Long screenshot**: click, scroll slowly, done. The result is copied to the clipboard straight away.
- **Free, MIT, nothing leaves your Mac.** Screenshots, text and files are never uploaded.

<p align="center"><img src="docs/img/toolbar.png" alt="The wxShot toolbar, laid out like WeChat's" width="720"></p>

## 中文

微信没登录、没打开，就不能截图？wxShot 是常驻后台的原生 macOS 截图工具，**手感和微信截图一样**：

- **仅 2.8 MB**，已由 Apple 签名并公证，支持 Apple 芯片和 Intel。
- **隐形后台**：无 Dock 图标，默认无菜单栏图标；按 `⌥A` 即用，再次打开 App 进入设置。
- **工具栏与微信一致**：矩形、圆、表情、箭头、画笔、马赛克、文字 | 翻译、提取文字、长截图 | 撤销、保存、钉住、分享、关闭、确认；「···」里有序号、重做等更多工具。
- **和微信共存**：微信没运行或没登录时由 wxShot 截图；微信登录后默认交还给微信。
- **取色放大镜**：显示坐标和色值，`⌘C` 复制。
- **文字提取与翻译**在本机完成，左边是截图、右边是文字，方便对照。
- **长截图**：点击后慢慢滚动，结束即复制到剪贴板。
- **免费、MIT 开源、不上传任何截图。**

## Install / 安装

Download [`wxShot.dmg`](https://github.com/ntfstool/wxShot/releases/latest/download/wxShot.dmg), drag wxShot to Applications, open it once and allow **Screen Recording** when macOS asks. Then press `⌥A` anywhere.
下载 DMG，拖进「应用程序」，首次打开按提示允许「屏幕录制」，之后在任何界面按 `⌥A` 即可。

```bash
brew install --cask wxshot   # once the cask is accepted / Homebrew 收录后可用
```

If the shortcut stops working after an update, remove wxShot under System Settings › Privacy & Security › Screen Recording, add it back and reopen the app.

<p align="center">
  <img src="docs/img/welcome.png" alt="wxShot welcome window" width="300">
  <img src="docs/img/settings.png" alt="wxShot settings" width="220">
</p>

## Privacy / 隐私

No screenshot, text or file is uploaded. wxShot asks ntfstool.com once a day whether a new version exists (it sends only its own version) and, optionally, sends a few anonymous “still in use” pings in the first month (random install id, version, system, language, whether WeChat is running); both can be inspected in the source and the pings can be switched off in Settings.

## Feedback

Use **Settings › Send Feedback**, [open an issue](https://github.com/ntfstool/wxShot/issues), or write to service@ntfstool.com.

## More languages / 其他语言

[English](https://ntfstool.com/wxshot/) · [简体中文](https://ntfstool.com/lang/zhCN/wxshot/) · [繁體中文](https://ntfstool.com/lang/zhTW/wxshot/) · [日本語](https://ntfstool.com/lang/jp/wxshot/) · [한국어](https://ntfstool.com/lang/ko/wxshot/) · [Deutsch](https://ntfstool.com/lang/de/wxshot/) · [Français](https://ntfstool.com/lang/fr/wxshot/) · [Español](https://ntfstool.com/lang/es/wxshot/) · [Português](https://ntfstool.com/lang/pt/wxshot/) · [Italiano](https://ntfstool.com/lang/it/wxshot/) · [Русский](https://ntfstool.com/lang/ru/wxshot/) · [Türkçe](https://ntfstool.com/lang/tr/wxshot/) · [Tiếng Việt](https://ntfstool.com/lang/vi/wxshot/) · [ไทย](https://ntfstool.com/lang/th/wxshot/) · [हिन्दी](https://ntfstool.com/lang/hi/wxshot/) · [বাংলা](https://ntfstool.com/lang/bn/wxshot/) · [Kiswahili](https://ntfstool.com/lang/sw/wxshot/)

Also by NTFSTool: [NTFSTool](https://ntfstool.com/) (read and write NTFS drives on Mac) and [NTFS2exFAT](https://ntfstool.com/ntfs2exfat/).

## Build

在仓库根目录执行：

```bash
swift test
```

```bash
bash scripts/build.sh
```

`swift test` 同时编译测试所需的代码。构建脚本生成当前架构的 Release 应用 `dist/wxShot.app`，包含本地化与 PermissionFlow 资源，并执行 ad-hoc 签名和签名校验；它只重建 `dist/wxShot.app`，不会清空整个 `dist/`，也不会安装到 `/Applications`。DMG 仅在传入 `--dmg` 时重新生成；未传该参数时，目录内已有 DMG 可能是旧产物。需要同时生成 Apple silicon 与 Intel 版本时使用 `--universal`。

## 个人版维护

状态：维护中；最近核对：2026-11-07。以下流程适用于个人 fork 的 macOS 本机维护；参数与运行行为以 [构建脚本](scripts/build.sh)、[公证脚本](scripts/notarize.sh)、[应用标识](Sources/wxShot/App/Info.plist) 和 [外观测试](Tests/wxShotTests/AppearanceTests.swift) 为准。

### 修改与同步上游

开始前检查工作区和远端：

```bash
git status --short --branch
```

```bash
git remote -v
```

确认 `origin` 为 `debugrao-coder/wxShot`、`upstream` 为 `ntfstool/wxShot`。保留未提交改动，从最新个人 `main` 建立本次工作分支；上游同步在工作区干净时进行。

```bash
git fetch upstream
```

```bash
git log --oneline HEAD..upstream/main
```

查看上游改动，确认同步范围后，在工作分支合入 `upstream/main`。冲突处理后检查个人主题是否仍保留，运行 Build 章节的测试与构建，再完成下方界面验收。获得本次合并授权后合入个人 `main`，推送并回读远端提交；不通过重置到上游或强推清除个人历史。

应用内更新检查仍使用上游版本服务，只提供版本提示和下载页面，不会自动安装。个人版升级应走上述同步、验证与构建流程；直接安装上游下载包会替换个人功能。

### 本机安装与回滚

本机使用默认 ad-hoc 签名即可，无需 Apple Developer 账号。替换前确认目标是 `/Applications/wxShot.app`，并取得本次安装授权。

1. 完成构建并检查新产物；处理未保存的截图，正常退出已安装的 wxShot，确认旧进程已结束。
2. 在 `~/Library/Application Support/CodexBackups/app-updates/<时间戳>-wxShot/` 建立独立备份目录，用 `ditto` 保留资源和扩展属性，将旧应用保存为 `original-bundles/wxShot.app`。逐文件校验内容与符号链接，并验证备份签名。首次安装没有旧应用时记录该事实。
3. 通过 `defaults export` 备份现有偏好域为 `preferences.plist`，域名以 `Info.plist` 中的 `CFBundleIdentifier` 为准，当前为 `com.ntfstool.wxshot`。没有该偏好域时记录缺失，不创建伪备份。另写 `rollback.txt`，记录来源提交、应用版本、校验结果和恢复步骤。
4. 在目标应用同级的独立临时目录暂存新 `.app`，校验内容和签名；将旧应用移出目标路径后，再把完整新包移入。保留已验证的备份，不向旧包叠加复制。替换失败时恢复旧包。
5. 核对安装后签名和主程序哈希，再从 `/Applications/wxShot.app` 启动。用 `lsappinfo` 检查实际运行路径，确认只有预期实例，避免启动备份目录中的旧版。

以下命令在仓库根目录检查已安装应用与构建产物：

```bash
codesign --verify --deep --strict /Applications/wxShot.app
```

```bash
shasum -a 256 dist/wxShot.app/Contents/MacOS/wxShot /Applications/wxShot.app/Contents/MacOS/wxShot
```

```bash
open /Applications/wxShot.app
```

哈希应一致；版本号相同也应检查实际二进制。若 Claude Desktop 沙箱中的签名或进程工具受限，转到本机终端执行同一核验，不据此重签或修改应用。

回滚时正常退出 wxShot，把当前应用移至单独保留目录，再从 `original-bundles/wxShot.app` 恢复完整旧包；验证签名和运行路径后启动。应用回滚默认保留当前偏好，只有明确需要恢复设置时才导入 `preferences.plist`。屏幕录制授权由 macOS 管理，偏好备份不包含此授权。

### 权限与界面验收

更新签名后，macOS 可能要求重新授权屏幕录制。打开应用设置，以应用显示的权限状态为准；若未授权，由用户在“系统设置 → 隐私与安全性 → 屏幕与系统音频录制”开启 wxShot，并按系统提示重新打开。若旧条目已开启而应用仍报未授权，移除旧条目，重新添加 `/Applications/wxShot.app`。不直接修改 TCC 数据库，也不为截图功能增加辅助功能或输入监控权限。

使用无敏感内容的测试窗口，完成以下检查：

- **截图与退出**：检查当前快捷键及微信共存策略；通过 wxShot 菜单或有效快捷键框选，确认选区与编辑工具栏出现，再按 `Esc` 取消。验证无需占用原剪贴板内容。
- **深浅色外观**：在系统浅色、深色及切回浅色后，检查设置页、快捷键输入框、截图工具栏、OCR 预览和放大镜。已有窗口应随外观变化刷新，无需重启应用。
- **工具栏状态**：检查普通、选中和禁用图标、系统强调色、分隔线与原生浮层材质，确认按钮动作正常。
- **截图内容**：使用相同测试图像，确认界面主题不改变截图像素、标注颜色或放大镜采样值。需要检查导出时保存到本次临时目录，不覆盖用户文件。

原生截图浮层的自动拖拽路径目前尚未稳定，保留手工框选验收并注明由谁确认。菜单触发成功、浮层创建成功和完整框选成功分别记录；自动化未完成的步骤保持待验证。

[DebugSnapshots](Sources/wxShot/App/DebugSnapshots.swift) 可辅助检查真实控件的浅色、深色和切回浅色渲染。在仓库根目录构建调试版：

```bash
swift build
```

```bash
WXSHOT_SNAPSHOT="$(mktemp -d /tmp/wxshot-theme.XXXXXX)" WXSHOT_TELEMETRY=0 .build/debug/wxShot
```

快照输出包含 `toolbar-light.png`、`toolbar-dark.png`、`toolbar-light-restored.png` 及设置、引导页图像。它不需要屏幕录制权限；普通截图模式仍需授权。`WXSHOT_SNAPSHOT_HOLD=1` 会保留深色预览窗口，检查后退出调试进程；可选 `WXSHOT_LANG` 会写入该调试进程使用的语言偏好，需隔离验证时使用独立的调试 bundle 标识。不要与相同 bundle 标识的已运行实例混用。

系统材质由窗口合成器绘制，离屏快照可能缺少背景或毛玻璃效果；材质和真实框选以实际窗口检查为准。构建产物、截图证据、偏好及备份包留在本机，不提交到源码仓库。

### 对外发布时的签名配置

本机维护无需公证。需要对外发布时，使用自己的 Developer ID 身份构建签名包；需要公证时使用自己的 Keychain profile，凭据不写进仓库。

公证提交要求产物已用 Developer ID Application 证书签名。`build.sh` 使用 `--notarize` 时必须同时传入 `--sign` 和自己的 Developer ID 签名身份；仅传 `--notarize` 仍会生成 ad-hoc 包，不满足公证前提。

构建脚本调用公证脚本时不传 profile，因而沿用其上游默认值 `MY_NTFSTOOL`。使用其他 profile 时，先用 `--sign` 构建，再调用 `scripts/notarize.sh` 并通过第二参数显式指定自己的 profile；同时发布 DMG 时，App 和 DMG 都要分别完成公证及盖章验证。Mac App Store 流程见 [docs/MAS.md](docs/MAS.md)。

PermissionFlow is vendored under `ThirdParty/`. wxShot is an independent project and is not affiliated with Tencent. "WeChat" is a trademark of its owner and is used only to describe compatibility.
