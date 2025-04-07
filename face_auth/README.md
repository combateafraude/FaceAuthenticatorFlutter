# FaceAuthenticator SDK Documentation

Enables integration of live facial authentication and fingerprint technology into Android apps, ensuring seamless and secure user authentication.

---

## Terms & Policies

Ensure compliance with our [Privacy Policy](https://en.caf.io/politicas/politicas-de-privacidade) and [Terms of Use](https://en.caf.io/politicas/termos-e-condicoes-de-uso).

---

### Runtime Permissions

| Platform | Permission                  | Required | 
| -------- | --------------------------- | :------: |
| Android  | `CAMERA`                    | ✅       |
| iOS      | `Privacy - Camera Usage`    | ✅       |

---

## Installation

2. **Add Dependency**: Update `pubspec.yaml`:
   ```yaml
   dependencies:
     flutter_caf_face_auth: ^1.0.0
   ```

---

## Usage

### Event Handling

The `CafLivenessListener` in Flutter handles key events during the SDK's liveness detection process. Below are the correct Flutter events you can listen to:


| **Event**                           | **Description**                                                                                      |
| ----------------------------------- | ---------------------------------------------------------------------------------------------------- |
| **FaceAuthEventClosed**       | Triggered when the user cancels the liveness detection process.                                      |
| **FaceAuthEventFailure**         | Called when an SDK failure occurs, providing error details like `errorType` and `errorDescription`. |
| **FaceAuthEventConnected**          | Triggered when the SDK is fully loaded and ready to start.                                             |
| **FaceAuthEventConnecting**         | Indicates the SDK is initializing or in the process of loading.                                      |
| **FaceAuthEventSuccess**         | Triggered upon successful liveness detection, with the result available in `signedResponse`.         |


**Example:**

```dart
stream.listen((event) {
  if (event is FaceAuthEventSuccess) {
    print('Success! Response: ${event.signedResponse}');
  } else if (event is FaceAuthEventFailure) {
    print('Failure! Error: ${event.errorDescription}');
  }
});
```

---

## Building the SDK

Configure the SDK using the `CafBuilder` class:

| Parameter                          | Description                                                                 | Required |
| ----------------------------------- | --------------------------------------------------------------------------- | :--------: | 
| **setScreenCaptureEnabled(Boolean)** | Enables or disables screen capture. Default: `false`.                       | ❌       |
| **setStage(CafStage)**              | Defines the environment stage (e.g., `PROD`, `BETA`). Default: `PROD`.       | ❌       |
| **setLoadingScreen(Boolean)**       | Enables or disables the loading screen. Default: `false`.                   | ❌       |
| **setListener(CafLivenessListener)** | Sets a listener for liveness verification events.                           | ✅      |

**Example:**

```dart
  void _initializeLivenessSDK() {
    _livenessSDK = CafFaceLiveness();
    _livenessSDK.setStage(CafStage.prod);
    _livenessSDK.setScreenCaptureEnabled(true);
    _livenessSDK.setLoadingScreen(true);
    _livenessSDK.setListener(_setupLivenessListener());
  }
``` 

---

## Start Authentication

Initialize and start the SDK:

```dart
  void startSDK() {
    final stream = _faceAuth.start();
    _setupFaceAuthListener(stream);
  }

  void _setupFaceAuthListener(Stream<FaceAuthEvent> stream) {
    stream.listen((event) {
      if (event is FaceAuthEventConnecting) {
        print('Connecting to FaceAuth...');
      } else if (event is FaceAuthEventConnected) {
        print('Connected to FaceAuth.');
      } else if (event is FaceAuthEventClosed) {
        print('SDK closed by the user.');
      } else if (event is FaceAuthEventSuccess) {
        print('Success! SignedResponse: ${event.signedResponse}');
      } else if (event is FaceAuthEventFailure) {
        print(
          'Failure! Error type: ${event.errorType}, '
              'Error description: ${event.errorDescription}',
        );
      }
    });
  }
```
