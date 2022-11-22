// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MainPost {
  final int postId;
  final String title;
  final String category;
  final String catUrl;
  final String description;
  final List<String> mediaUrls;
  final likes;
  final dislikes;
  final love;
  final postdate;

  MainPost({
    required this.postId,
    required this.title,
    required this.description,
    required this.mediaUrls,
    required this.likes,
    required this.dislikes,
    required this.love,
    required this.postdate,
    required this.category,
    required this.catUrl,
  });

  static MainPost fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return MainPost(
        description: snapshot["description"],
        title: snapshot["title"],
        mediaUrls: snapshot["mediaUrls"],
        postId: snapshot["postId"],
        postdate: snapshot["postdate"],
        likes: snapshot["likes"],
        dislikes: snapshot['dislikes'],
        love: snapshot['love'],
        catUrl: snapshot['catUrl'],
        category: snapshot['category']);
  }

  Map<String, dynamic> toJson() => {
        "description": description,
        "title": title,
        "likes": likes,
        "dislikes": dislikes,
        "love": love,
        "postdate": postdate,
        'postId': postId,
        'mediaUrls': mediaUrls,
        'catUrls': catUrl,
        'category': category,
      };
}
