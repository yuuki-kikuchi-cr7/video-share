import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tiktok_app/models/user_model.dart';
import 'package:tiktok_app/utils/constants/firebase_constatnts.dart';
import 'package:tiktok_app/views/screens/auth/login_screen.dart';
import 'package:tiktok_app/views/screens/home_screen.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();

  final Rx<File?> _pickedImage = Rx<File?>(null);
  late Rx<User?> user;
  File? get profilePhoto => _pickedImage.value;
  RxBool isInitializing = true.obs;

  @override
  void onReady() {
    super.onReady();
    user = Rx<User?>(fbAuth.currentUser);
    user.bindStream(fbAuth.authStateChanges());
    ever(user, _setInitialScreen);
    Future.delayed(const Duration(seconds: 2), () {
      isInitializing.value = false;
    });
  }

  void _setInitialScreen(User? user) {
    if (!isInitializing.value) {
      if (user == null) {
        Get.offAll(() => const LoginScreen());
      } else {
        Get.offAll(() => const HomeScreen());
      }
    }
  }

  Future<bool> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      Get.snackbar("Profile Picture",
          "You have successfully selected your profile picture! ");
      _pickedImage.value = File(pickedImage.path);
      return true;
    } else {
      return false;
    }
  }

  Future<String> _uploadToStorage(File image) async {
    Reference ref =
        fbStorage.ref().child("profilePics").child(fbAuth.currentUser!.uid);

    UploadTask uploadTask = ref.putFile(image);
    TaskSnapshot snap = await uploadTask;
    String downloadUrl = await snap.ref.getDownloadURL();
    return downloadUrl;
  }

  void registerUser({
    required String userName,
    required String email,
    required String password,
    required File? image,
  }) async {
    try {
      if (userName.isNotEmpty &&
          email.isNotEmpty &&
          password.isNotEmpty &&
          image != null) {
        UserCredential cred = await fbAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        String downloadUrl = await _uploadToStorage(image);
        UserModel user = UserModel(
          name: userName,
          profilePhoto: downloadUrl,
          email: email,
          uid: cred.user!.uid,
        );
        await fbStore.collection("users").doc(cred.user!.uid).set(
              user.toMap(),
            );
      } else {
        Get.snackbar(
          "Error Creating Account",
          "Please enter all the fields",
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error Creating Account",
        e.toString(),
      );
    }
  }

  void loginUser(String email, String password) async {
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        await fbAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        Get.snackbar(
          "Error Logging in ",
          "Please enter all the fields",
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error Login gin",
        e.toString(),
      );
    }
  }
}
