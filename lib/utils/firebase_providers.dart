import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Global Firebase providers for dependency injection.
final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);
final firebaseStorageProvider = Provider<FirebaseStorage>((ref) => FirebaseStorage.instance);

/// Current user stream provider
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});
