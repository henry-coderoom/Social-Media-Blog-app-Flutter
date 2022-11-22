
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
class FireStoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> uploadPostAdmin(
    String title,
    String description,
    String uid,
    String username,
    // String profilePic,
    String postImage,
    String videoLink,
    String section,
    String category,
    String media1,
    String media2,
    String media3,
    String media4,
    String media5,
  ) async {
    String res = "Some error occurred";
    try {
      if (title.isNotEmpty) {
        String postId = const Uuid().v1();
        late String catUrl = '';
        await FirebaseFirestore.instance
            .collection('categories')
            .doc(category)
            .get()
            .then((ds) {
          catUrl = ds['catUrl'];
        }).catchError((e) {});
        _firestore.collection('posts').doc(postId).set({
          'postedBy': username,
          'uid': uid,
          'title': title,
          'description': description,
          'likes': [],
          'dislikes': [],
          'love': [],
          'section': section,
          'category': category,
          'catUrl': catUrl,
          'postId': postId,
          'mediaUrl': postImage,
          'videoUrl': videoLink,
          'media1': media1,
          'media2': media2,
          'media3': media3,
          'media4': media4,
          'media5': media5,
          'postdate': DateTime.now(),
        });
        res = 'success';
      } else {
        res = "Title cannot be empty!";
      }
    } catch (err) {
      print(err.toString());
      res = err.toString();
    }
    return res;
  }

  Future<String> uploadPostUser(
    String title,
    String description,
    String uid,
    String username,
    String profilePic,
    String postImage,
    String videoLink,
    String category,
    String media1,
    String media2,
    String media3,
    String media4,
    String media5,
  ) async {
    String res = "Some error occurred";
    try {
      if (title.isNotEmpty) {
        String postId = const Uuid().v1();
        String section = videoLink == 'with' ? 'userPost' : '';
        late String catUrl;
        await FirebaseFirestore.instance
            .collection('categories')
            .doc(category)
            .get()
            .then((ds) {
          catUrl = ds['catUrl'];
        }).catchError((e) {});
        _firestore.collection('posts').doc(postId).set({
          'profilePic': profilePic,
          'postedBy': username,
          'uid': uid,
          'title': title,
          'description': description,
          'likes': [],
          'dislikes': [],
          'love': [],
          'section': section,
          'category': category,
          'catUrl': catUrl,
          'postId': postId,
          'mediaUrl': postImage,
          'videoUrl': videoLink,
          'media1': media1,
          'media2': media2,
          'media3': media3,
          'media4': media4,
          'media5': media5,
          'postdate': DateTime.now(),
        });
        _firestore
            .collection('users')
            .doc(uid)
            .collection('posts')
            .doc(postId)
            .set({
          'postedBy': username,
          'uid': uid,
          'title': title,
          'description': description,
          'likes': [],
          'dislikes': [],
          'love': [],
          'section': section,
          'category': category,
          'catUrl': catUrl,
          'postId': postId,
          'mediaUrl': postImage,
          'videoUrl': videoLink,
          'media1': media1,
          'media2': media2,
          'media3': media3,
          'media4': media4,
          'media5': media5,
          'postdate': DateTime.now(),
        });
        res = 'success';
      } else {
        res = "Title cannot be empty!";
      }
    } catch (err) {
      print(err.toString());
      res = err.toString();
    }
    return res;
  }

  Future<String> likePost(String postId, String? uid, List likes) async {
    String res = "Some error occurred";
    try {
      if (likes.contains(uid)) {
        // if the likes list contains the user uid, we need to remove it
        _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid])
        });
      } else {
        // else we need to add uid to the likes array
        _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid])
        });
      }
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future disLikePost(
    String postId,
    String? uid,
    List dislikes,
  ) async {
    String res = "Some error occurred";

    try {
      if (dislikes.contains(uid)) {
        // if the likes list contains the user uid, we need to remove it
        _firestore.collection('posts').doc(postId).update({
          'dislikes': FieldValue.arrayRemove([uid])
        });
      } else {
        _firestore.collection('posts').doc(postId).update({
          'dislikes': FieldValue.arrayUnion([uid])
        });
      }
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future lovePost(
    String postId,
    String? uid,
    List love,
  ) async {
    String res = "Some error occurred";

    try {
      if (love.contains(uid)) {
        // if the likes list contains the user uid, we need to remove it
        _firestore.collection('posts').doc(postId).update({
          'love': FieldValue.arrayRemove([uid])
        });
      } else {
        _firestore.collection('posts').doc(postId).update({
          'love': FieldValue.arrayUnion([uid])
        });
      }
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> removeLikeForDislike(String postId, String? uid) async {
    String res = "Some error occurred";
    try {
      // if the likes list contains the user uid, we need to remove it
      _firestore.collection('posts').doc(postId).update({
        'likes': FieldValue.arrayRemove([uid])
      });
      _firestore.collection('posts').doc(postId).update({
        'dislikes': FieldValue.arrayUnion([uid])
      });

      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> removeLikeForLove(String postId, String? uid) async {
    String res = "Some error occurred";
    try {
      // if the likes list contains the user uid, we need to remove it
      _firestore.collection('posts').doc(postId).update({
        'likes': FieldValue.arrayRemove([uid])
      });
      _firestore.collection('posts').doc(postId).update({
        'love': FieldValue.arrayUnion([uid])
      });

      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> removeDislikeForLikes(
    String postId,
    String? uid,
  ) async {
    String res = "Some error occurred";
    try {
      // if the likes list contains the user uid, we need to remove it
      _firestore.collection('posts').doc(postId).update({
        'dislikes': FieldValue.arrayRemove([uid])
      });
      _firestore.collection('posts').doc(postId).update({
        'likes': FieldValue.arrayUnion([uid])
      });

      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> removeDislikeForLove(String postId, String? uid) async {
    String res = "Some error occurred";
    try {
      // if the likes list contains the user uid, we need to remove it
      _firestore.collection('posts').doc(postId).update({
        'dislikes': FieldValue.arrayRemove([uid])
      });
      _firestore.collection('posts').doc(postId).update({
        'love': FieldValue.arrayUnion([uid])
      });

      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> removeLoveForLikes(
    String postId,
    String? uid,
  ) async {
    String res = "Some error occurred";
    try {
      // if the likes list contains the user uid, we need to remove it
      _firestore.collection('posts').doc(postId).update({
        'love': FieldValue.arrayRemove([uid])
      });
      _firestore.collection('posts').doc(postId).update({
        'likes': FieldValue.arrayUnion([uid])
      });
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> removeLoveForDislikes(String postId, String? uid) async {
    String res = "Some error occurred";
    try {
      // if the likes list contains the user uid, we need to remove it
      _firestore.collection('posts').doc(postId).update({
        'love': FieldValue.arrayRemove([uid])
      });
      _firestore.collection('posts').doc(postId).update({
        'dislikes': FieldValue.arrayUnion([uid])
      });
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

//Add Posts to Bookmark page
  Future<String> savePost(
    String uid,
    String postId,
    String postTitle,
    String mediaUrl,
  ) async {
    String res = "Some error occurred";
    try {
      _firestore
          .collection('users')
          .doc(uid)
          .collection('bookmarks')
          .doc(postId)
          .set({
        'mediaUrl': mediaUrl,
        'title': postTitle,
        'uid': uid,
        'postId': postId,
        'dateSaved': DateTime.now(),
      });
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> unsavePost(
    String? uid,
    String postId,
  ) async {
    String res = "Some error occurred";
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('bookmarks')
          .doc(postId)
          .delete();
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // Post comment
  Future<String> postComment(String postId, String text, String uid,
      String name, String profilePic, commentImage, String postTitle) async {
    String res = "Some error occurred";
    try {
      if (text.isNotEmpty) {
        String commentId = const Uuid().v1();
        _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .set({
          'profilePic': profilePic,
          'name': name,
          'uid': uid,
          'text': text,
          'upvotes': [],
          'downvotes': [],
          'commentId': commentId,
          'commentImage': commentImage,
          'datePublished': DateTime.now(),
        });
        _firestore
            .collection('users')
            .doc(uid)
            .collection('allComments')
            .doc('Comment - $commentId')
            .set({
          'profilePic': profilePic,
          'name': name,
          'type': 'comment',
          'uid': uid,
          'text': text,
          'upvotes': [],
          'post': postId,
          'downvotes': [],
          'commentId': commentId,
          'commentImage': commentImage,
          'datePublished': DateTime.now(),
        });
        res = 'success';
      } else {
        res = "Comment_Not_Posted: you didn't enter any texts!";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> postCommentReply(
    String postId,
    String text,
    String uid,
    String commentOwner,
    String name,
    String profilePic,
    String commentId,
    String commentImage,
    String postTitle,
    String commentText,
  ) async {
    String res = "Some error occurred";

    try {
      String commentReplyId = const Uuid().v1();
      if (text.isNotEmpty) {
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .collection('commentreply')
            .doc(commentReplyId)
            .set({
          'profilePic': profilePic,
          'name': name,
          'uid': uid,
          'text': text,
          'upvotes': [],
          'downvotes': [],
          'commentImage': commentImage,
          'commentId': commentId,
          'commentReplyId': commentReplyId,
          'datePublished': DateTime.now(),
        });
        await _firestore
            .collection('users')
            .doc(uid)
            .collection('allComments')
            .doc('Reply - $commentReplyId')
            .set({
          'profilePic': profilePic,
          'name': name,
          'uid': uid,
          'text': text,
          'post': postId,
          'type': 'commentReply',
          'upvotes': [],
          'downvotes': [],
          'commentImage': commentImage,
          'commentId': commentId,
          'commentReplyId': commentReplyId,
          'datePublished': DateTime.now(),
        });
        if (uid != commentOwner) {
          await _firestore
              .collection('users')
              .doc(commentOwner)
              .collection('notifs')
              .doc('Reply - $commentReplyId')
              .set({
            'commentText': commentText,
            'notifType': 'reply',
            'name': name,
            'commentOwner': commentOwner,
            'uid': uid,
            'text': text,
            'post': postId,
            'notifId': 'Reply - $commentReplyId',
            'clicked': false,
            'postTitle': postTitle,
            'commentId': commentId,
            'commentReplyId': commentReplyId,
            'dateSent': DateTime.now(),
          });
        } else {}

        res = 'success';
      } else {
        res = "Reply_Not_Posted: you didn't enter any texts!";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // Delete Post
  Future<String> deleteComment(
    String commentId,
    String postId,
    String? uid,
    String commentImage,
  ) async {
    String res = "Some error occurred";
    try {
      if (commentImage == '!@!@') {
      } else {
        await FirebaseStorage.instance.refFromURL(commentImage).delete();
      }
      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .delete();
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('allComments')
          .doc('Comment - $commentId')
          .delete();
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> deleteReply(
    String commentId,
    String postId,
    String commentReplyId,
    String? uid,
    String commentOwner,
    String commentReplyImage,
  ) async {
    String res = "Some error occurred";
    try {
      if (commentReplyImage == '!@!@') {
      } else {
        await FirebaseStorage.instance.refFromURL(commentReplyImage).delete();
      }
      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .collection('commentreply')
          .doc(commentReplyId)
          .delete();
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('allComments')
          .doc('Reply - $commentReplyId')
          .delete();
      await _firestore
          .collection('users')
          .doc(commentOwner)
          .collection('notifs')
          .doc('Reply - $commentReplyId')
          .delete();
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> deleteUserDoc(String? userId, String userImage) async {
    String res = "Some error occurred";
    try {
      if (userImage == '!@!@') {
      } else {
        await FirebaseStorage.instance.refFromURL(userImage).delete();
      }
      await _firestore.collection('users').doc(userId).delete();
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> deleteUsername(
    String username,
  ) async {
    String res = "Some error occurred";
    try {
      await _firestore.collection('usernames').doc(username).delete();
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> postCommentMentionNotif(
    String postId,
    String uid,
    String text,
    String taggedUserId,
    String name,
    String postTitle,
  ) async {
    String res = "Some error occurred";
    try {
      String commentMentionId = const Uuid().v1();

      _firestore
          .collection('users')
          .doc(taggedUserId)
          .collection('notifs')
          .doc('commentMention - $name - $commentMentionId')
          .set({
        'notifType': 'commentMention',
        'name': name,
        'uid': uid,
        'clicked': false,
        'notifId': 'commentMention - $name - $commentMentionId',
        'commentText': text,
        'post': postId,
        'postTitle': postTitle,
        'commentMentionId': commentMentionId,
        'dateSent': DateTime.now(),
      });

      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> postReplyTagNotif(
    String postId,
    String uid,
    String text,
    String taggedUserId,
    String name,
    String commentId,
    String postTitle,
    String commentOwner,
    String commentText,
  ) async {
    String res = "Some error occurred";
    try {
      String replyTagId = const Uuid().v1();

      _firestore
          .collection('users')
          .doc(taggedUserId)
          .collection('notifs')
          .doc('ReplyTagBy - $name - $replyTagId')
          .set({
        'notifType': 'tag',
        'commentText': commentText,
        'name': name,
        'uid': uid,
        'clicked': false,
        'replyText': text,
        'post': postId,
        'commentOwner': commentOwner,
        'postTitle': postTitle,
        'commentId': commentId,
        'notifId': 'ReplyTagBy - $name - $replyTagId',
        'dateSent': DateTime.now(),
      });

      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  //MAIN COMMENT REACTION
  Future<String> commentUpvote(
      String postId, String commentId, String? uid, List upvotes) async {
    String res = "Some error occurred";
    try {
      if (upvotes.contains(uid)) {
        // if the upvotes list contains the user uid, we need to remove it
        _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .update({
          'upvotes': FieldValue.arrayRemove([uid])
        });
      } else {
        // else we need to add uid to the likes array
        _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .update({
          'upvotes': FieldValue.arrayUnion([uid])
        });
      }
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> removecommentUpvote(
      String postId, String commentId, String? uid, List upvotes) async {
    String res = "Some error occurred";
    try {
      // if the upvotes list contains the user uid, we need to remove it
      _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .update({
        'upvotes': FieldValue.arrayRemove([uid])
      });
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> addCommentUpvote(
      String postId, String commentId, String? uid, List upvotes) async {
    String res = "Some error occurred";
    try {
      // if the upvotes list contains the user uid, we need to remove it
      _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .update({
        'upvotes': FieldValue.arrayUnion([uid])
      });
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> commentDownvote(
      String postId, String commentId, String? uid, List downvotes) async {
    String res = "Some error occurred";
    try {
      if (downvotes.contains(uid)) {
        // if the upvotes list contains the user uid, we need to remove it
        _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .update({
          'downvotes': FieldValue.arrayRemove([uid])
        });
      } else {
        // else we need to add uid to the likes array
        _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .update({
          'downvotes': FieldValue.arrayUnion([uid])
        });
      }
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> addCommentDownvote(
      String postId, String commentId, String? uid, List downvotes) async {
    String res = "Some error occurred";
    try {
      // if the upvotes list contains the user uid, we need to remove it
      _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .update({
        'downvotes': FieldValue.arrayUnion([uid])
      });
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> removecommentDownvote(
      String postId, String commentId, String? uid, List downvotes) async {
    String res = "Some error occurred";
    try {
      // if the upvotes list contains the user uid, we need to remove it
      _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .update({
        'downvotes': FieldValue.arrayRemove([uid])
      });
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

//COMMENT REPLY REACTION CODES
  Future<String> commentReplyUpvote(String postId, String commentId,
      String commentReplyId, String? uid, List upvotes) async {
    String res = "Some error occurred";
    try {
      if (upvotes.contains(uid)) {
        // if the upvotes list contains the user uid, we need to remove it
        _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .collection('commentreply')
            .doc(commentReplyId)
            .update({
          'upvotes': FieldValue.arrayRemove([uid])
        });
      } else {
        // else we need to add uid to the likes array
        _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .collection('commentreply')
            .doc(commentReplyId)
            .update({
          'upvotes': FieldValue.arrayUnion([uid])
        });
      }
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> removecommentReplyUpvote(String postId, String commentId,
      String commentReplyId, String? uid, List upvotes) async {
    String res = "Some error occurred";
    try {
      // if the upvotes list contains the user uid, we need to remove it
      _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .collection('commentreply')
          .doc(commentReplyId)
          .update({
        'upvotes': FieldValue.arrayRemove([uid])
      });
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> addCommentReplyUpvote(String postId, String commentId,
      String commentReplyId, String? uid, List upvotes) async {
    String res = "Some error occurred";
    try {
      // if the upvotes list contains the user uid, we need to remove it
      _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .collection('commentreply')
          .doc(commentReplyId)
          .update({
        'upvotes': FieldValue.arrayUnion([uid])
      });
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> commentReplyDownvote(String postId, String commentId,
      String commentReplyId, String? uid, List downvotes) async {
    String res = "Some error occurred";
    try {
      if (downvotes.contains(uid)) {
        // if the upvotes list contains the user uid, we need to remove it
        _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .collection('commentreply')
            .doc(commentReplyId)
            .update({
          'downvotes': FieldValue.arrayRemove([uid])
        });
      } else {
        // else we need to add uid to the likes array
        _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .collection('commentreply')
            .doc(commentReplyId)
            .update({
          'downvotes': FieldValue.arrayUnion([uid])
        });
      }
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> addCommentReplyDownvote(String postId, String commentId,
      String commentReplyId, String? uid, List downvotes) async {
    String res = "Some error occurred";
    try {
      // if the upvotes list contains the user uid, we need to remove it
      _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .collection('commentreply')
          .doc(commentReplyId)
          .update({
        'downvotes': FieldValue.arrayUnion([uid])
      });
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> removecommentReplyDownvote(String postId, String commentId,
      String commentReplyId, String? uid, List downvotes) async {
    String res = "Some error occurred";
    try {
      // if the upvotes list contains the user uid, we need to remove it
      _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .collection('commentreply')
          .doc(commentReplyId)
          .update({
        'downvotes': FieldValue.arrayRemove([uid])
      });
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }
}
