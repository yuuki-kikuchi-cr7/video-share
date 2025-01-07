import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:tiktok_app/controllers/auth_controller.dart';

final fbStore = FirebaseFirestore.instance;
final fbAuth = FirebaseAuth.instance;
final fbStorage = FirebaseStorage.instance;
final authController = AuthController.instance;
