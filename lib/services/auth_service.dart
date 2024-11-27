import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  //for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  //for acessing cloud firestore database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  static User get user => auth.currentUser!;

  Future<String?> userLogin(
      {required String email,
      required String senha,
      required Function onFail,
      required Function onSuccess}) async {
    try {
      UserCredential userCredential =
          await auth.signInWithEmailAndPassword(email: email, password: senha);

      // Verificar se o e-mail foi verificado
      if (userCredential.user!.emailVerified) {
        onSuccess();
      } else {
        return "Por favor, verifique seu e-mail antes de fazer login.";
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "user-not-found":
          return "Usuário não cadastrado";
        case "wrong-password":
          return "Email ou senha incorretos";
      }
      onFail();

      return e.code;
    }
    return null;
  }

  //for cheking if user exists or not?
  static Future<bool> userExists() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  //for create a new user
  static Future<void> createUser(String email, String name) async {
    final dataUser = {'name': user.displayName, 'email': user.email};

    return await firestore.collection('users').doc(user.uid).set(dataUser);
  }

  Future<String?> cadastrarUsuario({
    required String email,
    required String name,
    required String password,
    required Function onSuccess,
    required Function onFail,
  }) async {
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user!.updateDisplayName(user.displayName);

      // Enviar e-mail de verificação
      await userCredential.user!.sendEmailVerification();

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'id': user.uid,
        'nome': user.displayName,
        'email': user.email,
      });

      onSuccess();
      log("Usuário cadastrado com sucesso!");
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "email-already-in-use":
          return "O e-mail já está em uso.";
      }
      onFail() {}
      return e.code;
    } catch (e) {
      log("Erro ao salvar no Firestore: $e");
      return "Erro ao salvar os dados.";
    }

    return null;
  }

  Future<String?> removerConta({required String senha}) async {
    try {
      await auth.signInWithEmailAndPassword(
          email: auth.currentUser!.email!, password: senha);
      await auth.currentUser!.delete();
    } on FirebaseAuthException catch (e) {
      return e.code;
    }
    return null;
  }

  Future<String?> resetPassword(
      {required String email,
      required Function onFail,
      required Function onSuccess}) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
      onSuccess();
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
        return "E-mail não cadastrado.";
      }
      onFail();
      return e.code;
    }
    return null;
  }
}
