import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:tiktok_app/models/user_model.dart';
import 'package:tiktok_app/models/video.dart';
import 'package:tiktok_app/utils/constants/firebase_constatnts.dart';
import 'package:video_compress/video_compress.dart';

class UploadVideoController extends GetxController {
  Future<File> _compressVideo(String videoPath) async {
    final compressVideo = await VideoCompress.compressVideo(
      videoPath,
      quality: VideoQuality.MediumQuality,
    );

    if (compressVideo == null || compressVideo.file == null) {
      throw Exception("Video compression failed");
    }

    return compressVideo.file!;
  }

  Future<String> _uploadVideoToStorage(String id, String videoPath) async {
    Reference ref = fbStorage.ref().child("videos").child(id);
    UploadTask uploadTask = ref.putFile(await _compressVideo(videoPath));
    TaskSnapshot snap = await uploadTask;
    String downloadUrl = await snap.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<File> _getThumbnail(String videoPath) async {
    final thumbnail = await VideoCompress.getFileThumbnail(videoPath);

    return thumbnail;
  }

  Future<String> _uploadImageToStorage(String id, String videoPath) async {
    Reference ref = fbStorage.ref().child("thumbnails").child(id);
    UploadTask uploadTask = ref.putFile(await _getThumbnail(videoPath));
    TaskSnapshot snap = await uploadTask;
    String downloadUrl = await snap.ref.getDownloadURL();
    return downloadUrl;
  }

  void uploadVideo(String songName, String caption, String videoPath) async {
    try {
      String uid = fbAuth.currentUser!.uid;
      DocumentSnapshot userDoc =
          await fbStore.collection("users").doc(uid).get();
      UserModel user = UserModel.fromDoc(userDoc);
      QuerySnapshot allDocs = await fbStore.collection("videos").get();
      int len = allDocs.docs.length;

      String videoUrl = await _uploadVideoToStorage("Video $len", videoPath);
      String thumbnail = await _uploadImageToStorage("Video $len", videoPath);

      Video video = Video(
        username: user.name,
        uid: uid,
        id: "Video $len",
        likes: [],
        commentCount: 0,
        shareCount: 0,
        songName: songName,
        caption: caption,
        videoUrl: videoUrl,
        thumbnail: thumbnail,
        profilePhoto: user.profilePhoto,
      );

      await fbStore.collection("videos").doc("Video $len").set(
            video.toMap(),
          );
      Get.back();
    } catch (e) {
      Get.snackbar(
        "Error Uploading Video",
        e.toString(),
      );
    }
  }
}
