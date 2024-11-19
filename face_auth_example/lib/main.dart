import 'package:caf_face_auth/face_auth.dart';
import 'package:caf_face_auth/face_auth_enums.dart';
import 'package:caf_face_auth/face_auth_events.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final FaceAuth _faceAuth;

  final String _mobileToken = "sample_mobile_token";
  final String _personId = "sample_person_id";

  @override
  void initState() {
    super.initState();
    _initializeFaceAuth();
  }

  void _initializeFaceAuth() {
    _faceAuth = FaceAuth(mobileToken: _mobileToken, personId: _personId);
    _faceAuth.setStage(CafStage.prod);
    _faceAuth.setCameraFilter(CameraFilter.natural);
    _faceAuth.setEnableScreenshots(true);
  }

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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('FaceAuthenticator Demo'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed:  () {
              startSDK();
            },
            child: const Text('Start FaceAuth'),
          ),
        ),
      ),
    );
  }
}
