import 'package:bmprogresshud/bmprogresshud.dart';
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
  var _scanInProgress = false;

  String _result = "";
  String _description = "";

  String mobileToken = "";
  String personId = "";

  var personIdController = TextEditingController();
  var mobileTokenController = TextEditingController();
  bool isBeta = true;

  @override
  void initState() {
    super.initState();
  }

  void startFaceAuth() {
    personId = personIdController.text;
    mobileToken = mobileTokenController.text;

    setState(() {
      _scanInProgress = true;
      _result = "";
      _description = "";
    });
    ProgressHud.show(ProgressHudType.loading, 'Launching SDK');

    FaceAuth faceAuth = FaceAuth(mobileToken: mobileToken, personId: personId);

    faceAuth.setStage(isBeta ? CafStage.beta : CafStage.prod);
    faceAuth.setCameraFilter(CameraFilter.natural);
    faceAuth.setEnableScreenshots(true);

    // Put the others parameters here

    final stream = faceAuth.start();

    stream.listen((event) {
      if (event.isFinal) {
        setState(() => _scanInProgress = false);
      }

      if (event is FaceAuthEventConnecting) {
        ProgressHud.show(ProgressHudType.loading, 'Loading...');
      } else if (event is FaceAuthEventConnected) {
        ProgressHud.dismiss();
      } else if (event is FaceAuthEventClosed) {
        ProgressHud.dismiss();
        setState(() {
          _result = "Canceled";
          _description = "Usuário fechou o SDK";
        });
        print('Canceled\nUsuário fechou o SDK');
      } else if (event is FaceAuthEventSuccess) {
        ProgressHud.showAndDismiss(ProgressHudType.success, 'Success!');
        setState(() {
          _result = "Success";
          _description = "SignedResponse: ${event.signedResponse}";
        });
        print('Success!\nSignedResponse: ${event.signedResponse}');
      } else if (event is FaceAuthEventFailure) {
        ProgressHud.showAndDismiss(ProgressHudType.error, event.errorType!);
        setState(() {
          _result = "Failure";
          _description = personId.isEmpty
              ? '\nError type: ${event.errorType} \nError Message: personId is empty'
              : '\nError type: ${event.errorType} \nError Message: ${event.errorDescription}';
        });
        print(
            'Failure!\nError type: ${event.errorType} \nError Message: ${event.errorDescription}');
      }
    });

    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: const Text('FaceAuthenticator Demo'),
            ),
            body: ProgressHud(
                isGlobalHud: true,
                child: Container(
                    margin: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: mobileTokenController,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Insert mobileToken here',
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 10.0),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: personIdController,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Insert your ID/CPF here',
                                ),
                              ),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: SwitchListTile(
                                  title: const Text('Beta'),
                                  value: isBeta,
                                  onChanged: (bool value) {
                                    setState(() {
                                      isBeta = value;
                                    });
                                  }),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: _scanInProgress
                                  ? null
                                  : () {
                                      startFaceAuth();
                                    },
                              child: const Text('Start FaceAuth'),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                                margin: const EdgeInsets.only(top: 10.0),
                                child: Text("Result: $_result")
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text("Description:\n$_description",
                                  maxLines: 15,
                                  overflow: TextOverflow.ellipsis
                              ),
                            )
                          ],
                        ),
                      ],
                    )
                )
            )
        )
    );
  }
}
