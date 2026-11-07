# wxShot 个人维护版

本仓库是 [debugrao-coder/wxShot](https://github.com/debugrao-coder/wxShot)，上游为 [ntfstool/wxShot](https://github.com/ntfstool/wxShot)。应用采用 SwiftPM、AppKit，最低 macOS 14；PermissionFlow 以源码形式保存在 `ThirdParty/`。

状态：维护中。最近核对：2026-11-07。实现事实以 `Package.swift`、`Sources/`、`Tests/` 和 `scripts/` 为准；构建、安装、回滚与验收步骤统一维护在 [README 的个人版维护章节](README.md#个人版维护)。

## 开发与上游同步

- 允许按用户要求增加个人功能、改善体验和修复 macOS 兼容性；每次修改限定在本次任务范围内。
- 修改前检查工作区和目标文件 diff，保留用户或其他会话的改动。使用工作分支开发；只有获得本次提交、推送或合并授权后，才执行对应动作。
- `origin` 指向个人 fork，`upstream` 指向原项目，操作前核对远端。上游同步先在工作分支比较并合入 `upstream/main`，处理冲突后验证个人功能，再合入个人 `main`。保留上游历史，不用重置或强推替代合并。
- 外观维护优先使用 AppKit 原生材质、系统语义色和强调色。应用、窗口和视图默认继承系统外观；图层的 `CGColor` 与图像绘制闭包中使用的颜色，按视图实际外观解析并在切换时刷新。
- 主题修改只影响界面，不改变截图像素、标注色板和放大镜采样结果。同步上游后重点复核工具栏、快捷键输入框、OCR 预览和放大镜的外观行为。

## 产品约束

- 默认截图快捷键为 `⌥A`，是否注册由 `WeChatMonitor.shouldOwnShortcut()` 决定。验收快捷键前检查用户当前的微信共存策略，不擅自更改偏好。
- 截图功能只要求屏幕录制权限，不新增辅助功能或输入监控权限。开发用自动化工具的权限与应用自身权限分开处理。
- 新增界面文案通过 `scripts/add_strings.py` 维护八种语言，并在 `Sources/wxShot/Utilities/L10n+wxShot.swift` 提供入口。
- 工具布局由 `ToolbarLayout.default` 定义，图标在 `Sources/wxShot/Editor/ToolbarIcons.swift`，分组由 `ToolbarView.groupEnds` 定义。调整布局需保留按钮动作和快捷键行为。
- OCR 使用 Apple Vision；翻译使用 Apple 本机 Translation（macOS 15+）；分享使用系统分享面板。截图、识别文本和文件不上传。
- 保留根目录 `LICENSE` 和 `ThirdParty/PermissionFlow/LICENSE` 的版权与许可声明。

## 验证与安装

- 代码变更执行 `swift test`；应用交付使用 `scripts/build.sh`，核对构建、资源打包及签名结果。纯文档修改检查链接、命令语法和代码一致性即可。
- 外观回归入口为 `Tests/wxShotTests/AppearanceTests.swift`。调试快照入口为 `Sources/wxShot/App/DebugSnapshots.swift`；快照和单元测试分别证明其覆盖的渲染与逻辑，不替代实际截图操作。
- 实际界面验收包含系统浅色、深色及往返切换，工具栏普通/选中/禁用状态，以及真实框选后取消。原生浮层的自动拖拽路径尚未稳定，保留人工验收并注明结果来源。
- 安装前取得替换目标应用的授权，正常退出旧实例，备份旧应用与偏好并核验备份。安装后检查签名、构建产物一致性、运行路径和屏幕录制授权；回滚复用同一验证顺序。具体步骤见 README。
- 在 Claude Desktop 本地会话中，签名校验和进程取证若受沙箱限制，转到本机终端执行；不要把沙箱内的工具失败判断成应用损坏。
- 构建产物、截图证据、个人偏好、备份包及签名凭据留在本机，不进入源码提交。分别报告测试、构建、安装和人工验收的实际状态。

## 发布与上游服务

- 本机自用采用默认 ad-hoc 签名，不要求 Apple Developer 账号。Developer ID、公证和 Mac App Store 属于独立发布路径，使用维护者自己的证书与配置；MAS 说明见 [docs/MAS.md](docs/MAS.md)。
- `scripts/notarize.sh` 的默认 Keychain profile `MY_NTFSTOOL` 沿自上游；本机自用不需要它。使用自己的 profile 时显式传入该脚本第二参数，调用方式见 README。
- 非 MAS 构建的更新检查仍读取上游 `https://ntfstool.com/wxshot-version.json`；`UpdateChecker` 只检查版本并打开下载页面，不自动下载或安装。上游发行包不包含个人改动，个人版更新应从本 fork 同步、验证和构建。
- 更新提示逻辑还会处理上游 `min_version` 的强制更新状态；其行为以 `Sources/wxShot/Utilities/UpdateChecker.swift` 和 `Sources/wxShot/UI/StatusBarController.swift` 为准。迁移更新服务、反馈入口、遥测地址或应用标识应作为明确的维护任务，不要求维护者修改上游网站。
- 匿名使用统计由 `Sources/wxShot/Telemetry/SurvivalReporter.swift` 实现，可在设置中关闭；调试时 `WXSHOT_TELEMETRY=0` 可关闭上报。反馈使用用户邮件客户端或上游 Issue 入口。
