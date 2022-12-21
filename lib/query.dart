import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';

Future<void> addAccount(Map<String, dynamic> userDetails) async {
  var uid = FirebaseAuth.instance.currentUser!.uid;

  var usersCollection = FirebaseFirestore.instance.collection('users');
  await usersCollection.doc(uid).set(userDetails);
}

Future<void> updateAccount(Map<String, dynamic> userDetails) async {
  var uid = FirebaseAuth.instance.currentUser!.uid;

  var usersCollection = FirebaseFirestore.instance.collection('users');
  await usersCollection.doc(uid).set(userDetails, SetOptions(merge: true));
}

Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetails() async {
  var uid = FirebaseAuth.instance.currentUser!.uid;

  var usersCollection = FirebaseFirestore.instance.collection('users');
  var userDetails = await usersCollection.doc(uid).get();

  return userDetails;
}

Future<List<Reference>> downloadFeedbacks(var exercise, var week) async {
  log(exercise);
  var email = FirebaseAuth.instance.currentUser!.email;

  final path = '$email/${week}_week/$exercise/Feedback';

  final files = await FirebaseStorage.instance.ref(path).listAll();
  log(files.items.toString());

  final dir = await getTemporaryDirectory();
  var fileRefs = files.items;

  for (var ref in fileRefs) {
    await Directory('${dir.absolute.path}/$path').create(recursive: true);
    final file = File('${dir.path}/${ref.fullPath}');

    await ref.writeToFile(file);
    log(File('${dir.path}/${ref.fullPath}').path);
  }

  return fileRefs;
}
