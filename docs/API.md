## Core API

### SurfaceManager

`SurfaceManager` is the core entry point of AGenUI SDK, responsible for SDK initialization, Surface lifecycle management, data transmission, and theme management.

#### Initialization

| Platform | Method Signature |
|----------|------------------|
| Android | `SurfaceManager(@NonNull Activity context)` |
| iOS | `init()` |
| HarmonyOS | `SurfaceManager(context: UIAbilityContext)` |

**Description:**

- SDK initialization is performed automatically during construction (idempotent, safe for repeated calls)
- Android/HarmonyOS require passing a Context; iOS has no parameters

---

#### Data Interaction

##### receiveTextChunk

Transmits data (supports complete JSON or streaming chunks).

| Platform | Method Signature |
|----------|------------------|
| Android | `void receiveTextChunk(String dataString)` |
| iOS | `func receiveTextChunk(_ dataString: String)` |
| HarmonyOS | `receiveTextChunk(dataString: string): void` |

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `dataString` | `String` | JSON data string, must comply with **A2UI v0.9** protocol specification |

**Description:**

- Supports transmitting complete JSON data packets (createSurface, updateComponents, etc.) or streaming incremental chunks

---

#### Surface Event Listeners

##### addListener / removeListener

Adds/removes Surface event listeners. All platforms support multicast (multiple listeners can be registered simultaneously).

| Platform | Method Signature |
|----------|------------------|
| Android | `void addListener(ISurfaceListener listener)` |
| Android | `void removeListener(ISurfaceListener listener)` |
| iOS | `func addListener(_ listener: SurfaceManagerListener)` |
| iOS | `func removeListener(_ listener: SurfaceManagerListener)` |
| HarmonyOS | `addListener(callback: ISurfaceListener): void` |
| HarmonyOS | `removeListener(callback: ISurfaceListener): void` |

---

#### Theme Management

##### setDayNightMode

Sets day/night mode.

| Platform | Method Signature |
|----------|------------------|
| Android | `void setDayNightMode(String mode)` |
| iOS | `func setDayNightMode(_ mode: String)` |
| HarmonyOS | `setDayNightMode(mode: string): void` |

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `mode` | `String` | `"light"` or `"dark"` |

##### registerDefaultTheme

Registers default theme configuration.

| Platform | Method Signature |
|----------|------------------|
| Android | `void registerDefaultTheme(String theme, String designToken) throws ThemeException` |
| iOS | `func registerDefaultTheme(_ theme: String, designToken: String) -> SurfaceManagerError` |
| HarmonyOS | `registerDefaultTheme(theme: string, designToken: string): void` |

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `theme` | `String` | Theme configuration JSON string |
| `designToken` | `String` | DesignToken configuration JSON string |

**Error Handling:**

| Platform | Behavior |
|----------|----------|
| Android | Throws `ThemeException` |
| iOS | Returns `SurfaceManagerError` object (contains `result: Bool` and `message: String`), does not throw exceptions |
| HarmonyOS | Throws `Error` |

---

#### Resource Release

##### release

Releases SDK resources.

| Platform | Method Signature | Description |
|----------|------------------|-------------|
| Android | `void release()` | Destroys all Surfaces, removes all listeners, cleans up NativeEventBridge |
| HarmonyOS | `release(): void` | Only removes listeners registered via `addListener` by the current instance, does not affect other instances |
| iOS | Automatic release | Automatically released, no manual intervention required |

---

### Surface

`Surface` represents an independent UI canvas, created by the SDK and passed to the integrator via callbacks.

#### Surface Properties

| Property | Platform | Type | Description |
|----------|----------|------|-------------|
| `getSurfaceId()` | Android | `String` | Surface unique identifier |
| `getContainer()` | Android | `ViewGroup` (FrameLayout) | Root container View, call `addView` to add to view hierarchy |
| `surfaceId` | iOS | `String` | Surface unique identifier |
| `view` | iOS | `UIView` | Root container View, call `addSubview` to add to view hierarchy |

#### Surface Methods

| Method | Platform | Signature | Description |
|--------|----------|-----------|-------------|
| `updateSize` | iOS | `func updateSize(width: CGFloat, height: CGFloat)` | Updates size constraints, triggers re-layout |

**Android - Getting Container Example:**

```java
@Override
public void onCreateSurface(String surfaceId, Surface surface) {
    ViewGroup container = surface.getContainer();
    yourLayout.addView(container, new LayoutParams(
        LayoutParams.MATCH_PARENT,
        LayoutParams.WRAP_CONTENT
    ));
}
```

**iOS - Getting View Example:**

```swift
// Implement SurfaceManagerListener protocol
extension MyViewController: SurfaceManagerListener {
    func onCreateSurface(_ surface: Surface) {
        surface.view.frame = CGRect(x: 0, y: 0, width: 300, height: 400)
        self.containerView.addSubview(surface.view)
    }
}
// Register listener
surfaceManager.addListener(self)
```

**HarmonyOS - Rendering Example:**

```typescript
// ISurfaceListener only returns surfaceId, use with AGenUIContainer component for rendering
class MyListener implements ISurfaceListener {
    onCreateSurface(surfaceId: string): void {
        // Save surfaceId to state, AGenUIContainer will render automatically
        this.surfaceIds.push(surfaceId);
    }
    onDeleteSurface(surfaceId: string): void {
        // Remove from state
    }
}

struct index {
  build() {
    Stack() {
        ForEach(this.currentSurfaceId ? [this.currentSurfaceId] : [],
              (surfaceId: string) => {
                AGenUIContainer({ surfaceId: surfaceId })
                  .backgroundColor(this.isDarkMode ? '#121212' : '#FFFFFF')
                  .width('100%')
              },
              (_surfaceId: string) => `agenui_${this.surfaceVersion}`
            )
          }
  }
}
```

---

### ISurfaceListener / SurfaceManagerListener

Surface lifecycle event listeners, defined as follows for each platform.

#### Android — `ISurfaceListener` Interface

```java
public interface ISurfaceListener {
    // Callback when Surface is created, surface instance root container is available
    void onCreateSurface(Surface surface);
    // Callback when Surface is deleted
    void onDeleteSurface(Surface surface);
}
```

#### iOS — `SurfaceManagerListener` Protocol

```swift
@objc public protocol SurfaceManagerListener: AnyObject {
    // Callback after Surface is created, surface instance is ready
    @objc optional func onCreateSurface(_ surface: Surface)
    // Callback after Surface is deleted
    @objc optional func onDeleteSurface(_ surface: Surface)
}
```

#### HarmonyOS — `ISurfaceListener` Interface (from Native Layer)

```typescript
export interface ISurfaceListener {
    onCreateSurface(surfaceId: string): void;
    onDeleteSurface(surfaceId: string): void;
}
```

---

## Error Handling

### Exception Types

| Exception | Platform | Trigger Scenario |
|-----------|----------|-----------------|
| `ThemeException` | Android | Theme or DesignToken registration failed |
| `Error` | HarmonyOS | Theme or DesignToken registration failed |
| `SurfaceManagerError` | iOS | `registerDefaultTheme` returns error object, does not throw |

### SurfaceManagerError Type (iOS)

```swift
@objc public class SurfaceManagerError: NSObject {
    @objc public let result: Bool      // Whether operation succeeded
    @objc public let message: String   // Error message
}
```

### Error Handling Examples

**Android:**

```java
try {
    surfaceManager.registerDefaultTheme(themeJson, designTokenJson);
} catch (ThemeException e) {
    Log.e("AGenUI", "Theme registration failed: " + e.getMessage());
}
```

**iOS:**

```swift
let error = surfaceManager.registerDefaultTheme(themeJson, designToken: designTokenJson)
if !error.result {
    print("Theme registration failed: \(error.message)")
}
```

**HarmonyOS:**

```typescript
try {
    surfaceManager.registerDefaultTheme(themeJson, designTokenJson);
} catch (e) {
    console.error('Theme registration failed:', e);
}
```

---

## Platform Differences

| Feature | Android | iOS | HarmonyOS |
|---------|---------|-----|-----------|
| **Initialization** | Requires `Activity` context | No parameters | Requires `UIAbilityContext` |
| **Surface Container** | `getContainer()` returns `ViewGroup` | `view` property returns `UIView` | Use `AGenUIContainer` component |
| **Listener Callback** | Receives `Surface` object | Receives `Surface` object | Receives `surfaceId` string only |
| **Resource Release** | Manual `release()` | Automatic | Manual `release()` |
| **Error Handling** | Throws exceptions | Returns error object | Throws exceptions |
| **Size Update** | Use `WRAP_CONTENT` | `updateSize()` method | Component-based sizing |

---

## FAQ

### Q1: How to get the root container of a Surface?

**Android**: Get the `FrameLayout` (`ViewGroup`) via `surface.getContainer()`.

**iOS**: Get the `UIView` via `surface.view`.

**HarmonyOS**: `onCreateSurface` only returns `surfaceId`, you need to use the `AGenUIContainer` component and bind the `surfaceId` for rendering.

### Q2: How to implement height auto-adaptation?

**Android:**

```java
// Surface container uses WRAP_CONTENT for height auto-adaptation
ViewGroup container = surface.getContainer();
yourLayout.addView(container, new LayoutParams(
    LayoutParams.MATCH_PARENT,
    LayoutParams.WRAP_CONTENT
));
```

**iOS:**

```swift
// Surface default height = CGFloat.infinity (height auto-adaptation)
// For fixed size, call updateSize
surface.updateSize(width: 375, height: CGFloat.infinity)
```

**HarmonyOS:**

```typescript
// Use percentage or auto sizing in AGenUIContainer
AGenUIContainer({ surfaceId: surfaceId })
  .width('100%')
```

### Q3: What is the data protocol format?

The JSON data received by `receiveTextChunk` must comply with the A2UI protocol specification. See the [Protocol Documentation](https://a2ui.org/specification/v0.9-a2ui/) for details.

### Q4: How to switch between day and night mode?

```java
// 1. Register theme configuration first
surfaceManager.registerDefaultTheme(themeJson, designTokenJson);

// 2. Switch mode
surfaceManager.setDayNightMode("dark");  // or "light"
```

---

## Links

- [A2UI Protocol Specification](https://a2ui.org/specification/v0.9-a2ui/)
