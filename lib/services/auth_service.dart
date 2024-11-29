import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:to_do_list/providers/task_provider.dart';

class AuthService {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  static User? get user => auth.currentUser;

  /// Login do usuário
  Future<String?> userLogin(
      {required String email,
      required String senha,
      required Function onFail,
      required Function onSuccess,
      required BuildContext context}) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: senha);
      await Provider.of<TaskProvider>(context, listen: false)
          .handleLogin(user!.uid);
      onSuccess();
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

  /// Cadastro de usuário
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

      await userCredential.user!.updateDisplayName(name);

      await firestore.collection('users').doc(user!.uid).set({
        'id': user!.uid,
        'nome': user!.displayName,
        'email': user!.email,
      });

      onSuccess();
      log("Usuário cadastrado com sucesso!");
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "email-already-in-use":
          return "O e-mail já está em uso.";
      }
      onFail();
      return e.code;
    } catch (e) {
      log("Erro ao salvar no Firestore: $e");
      return "Erro ao salvar os dados.";
    }

    return null;
  }

  /// Remove a conta do usuário
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

  /// Reseta a senha do usuário
  Future<String?> resetPassword({
    required String email,
    required Function onFail,
    required Function onSuccess,
  }) async {
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

  /// Faz logout do usuário
  Future<void> logout() async {
    await auth.signOut();
    await GoogleSignIn().signOut();
  }
}
