import 'dart:js_interop';

import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService{

  final userCollection = FirebaseFirestore.instance.collection("users");

  Future<void> register({required String name,required String surname,required String username,required JSNumber phoneNumber,required String email,required String password, }) async {

    await userCollection.doc().set({
      'name' : name,
      'surname' : surname,
      'username' : username,
      'phoneNumber' : phoneNumber,
      'email' : email,
      'password' : password
    });
  }
}