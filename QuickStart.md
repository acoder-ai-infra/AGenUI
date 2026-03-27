# AGenUI SDK — Quick Start

## iOS

### Prerequisites

- iOS 13+
- CocoaPods

### Installation

```ruby
pod 'AGenUI'
```

### Usage

**1. Initialize and register listener**

Conform your `UIViewController` to `SurfaceManagerListener` and register it:

```swift
import AGenUI

class MyViewController: UIViewController, SurfaceManagerListener {

    private let surfaceManager = SurfaceManager()
    private let scrollView = UIScrollView()

    override func viewDidLoad() {
        super.viewDidLoad()
        surfaceManager.addListener(self)
    }

    // Called when a Surface is created
    func onCreateSurface(_ surface: Surface) {
        // Set the Surface size to match the view width
        surface.updateSize(width: view.bounds.width, height: .infinity)
        scrollView.addSubview(surface.view)
    }

    // Called when a Surface is destroyed
    func onDeleteSurface(_ surfaceId: String) {
        scrollView.subviews.forEach { $0.removeFromSuperview() }
    }
}
```

Remove a listener when it is no longer needed:

```swift
surfaceManager.removeListener(self)
// or remove all at once:
surfaceManager.removeAllListeners()
```

**2. Feed data**

Send `createSurface` first, then `updateComponents` (and optionally `updateDataModel`). To replace an existing Surface, send `deleteSurface` before creating a new one:

```swift
// 1. Delete previous Surface (if any)
surfaceManager.receiveTextChunk("""
{"version":"v0.9","deleteSurface":{"surfaceId":"my_surface"}}
""")

// 2. Create a new Surface
surfaceManager.receiveTextChunk("""
{"version":"v0.9","createSurface":{"surfaceId":"my_surface","catalogId":"https://a2ui.org/specification/v0_9/basic_catalog.json"}}
""")

// 3. Send component data (complete packet or streaming chunks)
surfaceManager.receiveTextChunk(componentsJSON)

// 4. Send data model (optional)
surfaceManager.receiveTextChunk(dataModelJSON)
```

**3. Theme (optional)**

```swift
// Register theme and DesignToken
let result = surfaceManager.registerDefaultTheme(themeJson, designToken: tokenJson)
// result.result == true on success

// Switch light / dark mode at runtime
surfaceManager.setDayNightMode("dark") // "light" | "dark"
```

---

## Android

### Prerequisites

- minSdk 21

### Installation

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

### Usage

**1. Initialize**

```java
SurfaceManager surfaceManager = new SurfaceManager(context);
```

SDK initializes automatically on construction (idempotent).

**2. Handle Surface lifecycle**

```java
surfaceManager.addListener(new ISurfaceListener() {
    @Override
    public void onCreateSurface(String surfaceId, Surface surface) {
        // surface.getContainer() is a plain Android View
        runOnUiThread(() -> container.addView(surface.getContainer()));
    }

    @Override
    public void onDeleteSurface(String surfaceId) {
        runOnUiThread(() -> container.removeAllViews());
    }
});
```

Remove a listener when it is no longer needed:

```java
surfaceManager.removeListener(listener);
```

**3. Feed data**

```java
surfaceManager.receiveTextChunk(jsonString);
```

**4. Theme (optional)**

```java
// Throws ThemeException on failure
surfaceManager.registerDefaultTheme(themeJson, designTokenJson);

// Switch light / dark mode at runtime
surfaceManager.setDayNightMode("dark"); // "light" | "dark"
```

**5. Release**

Call `release()` in `onDestroy()` to destroy all Surfaces and clean up resources:

```java
@Override
protected void onDestroy() {
    super.onDestroy();
    surfaceManager.release();
}
```

---

## HarmonyOS

### Prerequisites

- DevEco Studio 5.0+

### Installation

```json5
{
  "dependencies": {
    "@ohos/agenui": "0.9.8"
  }
}

ohpm install @ohos/agenui
```

### Usage

```typescript
import { AGenUIContainer, AGenUI, ISurfaceListener } from '@ohos/agenui';

class SurfaceListenerImpl implements ISurfaceListener{
  private indexComponent: Index | null = null;

  constructor(indexComponent: Index) {
    this.indexComponent = indexComponent;
  }

  onCreateSurface(surfaceId: string): void {
    // You can perform follow-up operations here, such as binding Surface to UI
    if (this.indexComponent) {
      this.indexComponent.addAGenUIContainer(surfaceId);
    }
  }

  onDeleteSurface(surfaceId: string): void {
    // You can perform cleanup operations here
    if (this.indexComponent) {
      this.indexComponent.removeAGenUIContainer(surfaceId);
    }
  }

}

@Entry
@Component
struct Index {
  @State surfaceId: string = '';
  
  private surfaceManager: SurfaceManager | null = null;

  aboutToAppear() {
    // 1. Copy resources from rawfile to sandbox and initialize SDK
    const context = getContext(this) as common.UIAbilityContext;
    this.surfaceManager = new SurfaceManager(context);
    this.surfaceManager.addListener(new SurfaceListenerImpl(this));
  }

  // Add AGenUIContainer
  addAGenUIContainer(surfaceId: string) {
    this.surfaceId = surfaceId;
  }

  // Remove AGenUIContainer
  removeAGenUIContainer(surfaceId: string) {
    if (this.surfaceId === surfaceId) {
      this.surfaceId = '';
    }
  }

  build() {
    Stack() {
      // Use AGenUIContainer to render Surface
      if (this.surfaceId) {
        AGenUIContainer({ surfaceId: this.surfaceId })
          .width('100%')
          .height('100%')
      }
    }
    .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5')
  }
}
```

**4. Feed data**

```typescript
this.surfaceManager.receiveTextChunk(jsonString);
```

**5. Theme (optional)**

```typescript
// Throws Error on failure
this.surfaceManager.registerDefaultTheme(themeJson, designTokenJson);

// Switch light / dark mode at runtime
this.surfaceManager.setDayNightMode('dark'); // 'light' | 'dark'
```

**6. Release**

Call `release()` in `aboutToDisappear()` to unregister all listeners:

```typescript
aboutToDisappear() {
    this.surfaceManager?.release();
}
```
