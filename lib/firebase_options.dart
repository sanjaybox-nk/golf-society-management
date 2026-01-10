import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    // Return dummy options for development/compilation
    return const FirebaseOptions(
      apiKey: 'dummy-api-key',
      appId: 'dummy-app-id',
      messagingSenderId: 'dummy-sender-id',
      projectId: 'dummy-project-id',
    );
  }
}
