import 'package:cloud_firestore/cloud_firestore.dart';

class Video {
  String username;
  String uid;
  String id;
  List likes;
  int commentCount;
  int shareCount;
  String songName;
  String caption;
  String videoUrl;
  String thumbnail;
  String profilePhoto;
  Video({
    required this.username,
    required this.uid,
    required this.id,
    required this.likes,
    required this.commentCount,
    required this.shareCount,
    required this.songName,
    required this.caption,
    required this.videoUrl,
    required this.thumbnail,
    required this.profilePhoto,
  });

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'uid': uid,
      'profilePhoto': profilePhoto,
      'id': id,
      'likes': likes,
      'commentCount': commentCount,
      'shareCount': shareCount,
      'songname': songName,
      "caption": caption,
      "videoUrl": videoUrl,
      "thumbnail": thumbnail,
    };
  }

  factory Video.fromDoc(DocumentSnapshot videoDoc) {
    final video = videoDoc.data() as Map<String, dynamic>;

    return Video(
      username: video["username"],
      uid: video["uid"],
      id: video["id"],
      likes: video["likes"],
      commentCount: video["commentCount"],
      shareCount: video["shareCount"],
      songName: video["songname"],
      caption: video["caption"],
      videoUrl: video["videoUrl"],
      thumbnail: video["thumbnail"],
      profilePhoto: video["profilePhoto"],
    );
  }
}
