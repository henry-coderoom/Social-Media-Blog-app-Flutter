// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:bbarena_app_com/widgets/video_player_widget.dart';
import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';

class VideoScreen extends StatefulWidget {
  // final VideoListData? videoListData;
  final video;
  const VideoScreen({
    Key? key,
    required this.video,
  }) : super(key: key);
  // static const routeName = '/videos';
  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

// class VideoListData {
//   final String videoTitle;
//   final String videoUrl;
//   Duration? lastPosition;
//   bool? wasPlaying = false;
//
//   VideoListData(this.videoTitle, this.videoUrl);
// }

class _VideoScreenState extends State<VideoScreen> {
  // late VideoPlayerController _videoController;

  BetterPlayerConfiguration? betterPlayerConfiguration;
  BetterPlayerListVideoPlayerController? controller;
  String asset =
      'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4';
  late Future<void> _initializedVideoPlayerFuture;

  @override
  void initState() {
    // _videoController = VideoPlayerController.network(asset);
    // _initializedVideoPlayerFuture = _videoController.initialize();

    controller = BetterPlayerListVideoPlayerController();
    betterPlayerConfiguration = const BetterPlayerConfiguration(autoPlay: true);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String asset =
        'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4';
    return const Center(
      child: VideoPlayerWidget(
        video:
            'https://www.instagram.com/reel/CdITWJTorlp/?igshid=YmMyMTA2M2Y=',
      ),
    );
  }
}
