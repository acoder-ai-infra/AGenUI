# [AGenUI SDK](https://genui.amap.com/) &middot; [![iOS](https://img.shields.io/badge/iOS-13%2B-blue?logo=apple)](https://developer.apple.com) [![Android](https://img.shields.io/badge/Android-API%2021%2B-green?logo=android)](https://developer.android.com) [![HarmonyOS](https://img.shields.io/badge/HarmonyOS-NEXT-red)](https://developer.huawei.com) [![License: MIT](https://img.shields.io/badge/License-MIT-lightgrey)](LICENSE)

[AGenUI](https://genui.amap.com/) is a cross-platform SDK for rendering AI-generated UI. Built on the [A2UI](https://a2ui.org/) v0.9 open protocol by Google, it turns structured JSON streamed from a large language model into high-performance **native components** on iOS, Android, and HarmonyOS — in real time.

- **Streaming-first.** Feed raw JSON token by token and the engine assembles and renders incrementally, so the UI appears as the model is still generating.
- **High performance.** All components are rendered natively on each platform — no WebView, no bridge overhead.
- **Custom styles.** Every visual property of every component is fully customizable through the A2UI protocol.
- **Custom themes.** Register your own theme JSON and DesignToken set to match your brand; switch between presets at any time.

## Installation

### iOS (CocoaPods) 

```ruby
pod 'AGenUI'
```

### Android (Gradle)

```groovy
// settings.gradle
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// app/build.gradle
dependencies {
    // AGenUI SDK
    implementation 'com.amap.agenui:agenui-sdk:1.0.1'
}
```

### HarmonyOS (ohpm)

```json5
// oh-package.json5
{
  "dependencies": {
    "@ohos/agenui": "0.9.8"
  }
}
// install
ohpm install @ohos/agenui
```

## Examples

**iOS**

```swift
private let surfaceManager = SurfaceManager()
surfaceManager.addListener(self)
func onCreateSurface(_ surface: Surface) {
    surface.updateSize(width: view.bounds.width, height: .infinity)
    view.addSubview(surface.view)
}
func onDeleteSurface(_ surfaceId: String) { }
surfaceManager.receiveTextChunk(jsonChunk)
```

**Android**

```java
SurfaceManager surfaceManager = new SurfaceManager(context);
surfaceManager.addListener(new ISurfaceListener() {
    public void onCreateSurface(String surfaceId, Surface surface) {
        runOnUiThread(() -> containerLayout.addView(surface.getContainer()));
    }
    public void onDeleteSurface(String surfaceId) {
        runOnUiThread(() -> containerLayout.removeAllViews());
    }
});
surfaceManager.receiveTextChunk(jsonChunk);
```

**HarmonyOS**

```typescript
this.surfaceManager = new SurfaceManager(getContext(this) as common.UIAbilityContext);
this.surfaceManager.addListener({
  onCreateSurface: (surfaceId: string) => { this.activeSurfaceId = surfaceId; },
  onDeleteSurface: (_: string)         => { this.activeSurfaceId = ''; }
});
// In build(): AGenUIContainer({ surfaceId: this.activeSurfaceId }).width('100%')
this.surfaceManager.receiveTextChunk(jsonChunk);
```

## License

AGenUI is [MIT licensed](LICENSE).

## Report Bug · Request Feature · Contact

Found a bug or have a feature request? [Open an issue](https://github.com/acoder-ai-infra/AGenUI/issues) — please include steps to reproduce for bugs, or a clear description for feature requests.

For general questions and discussions, reach us at:

- Website: [genui.amap.com](https://genui.amap.com/)
- GitHub: [github.com/acoder-ai-infra/AGenUI](https://github.com/acoder-ai-infra/AGenUI)
