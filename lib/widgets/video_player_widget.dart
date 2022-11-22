import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final video;
  const VideoPlayerWidget({Key? key, required this.video}) : super(key: key);

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  BetterPlayerConfiguration? betterPlayerConfiguration;
  BetterPlayerListVideoPlayerController? controller;
  final bool showControlsOnInitialize = false;

  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      controller = BetterPlayerListVideoPlayerController();
      betterPlayerConfiguration = const BetterPlayerConfiguration(
        autoPlay: true,
      );
    });

    controller?.setVolume(0.0);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
        child: BetterPlayerListVideoPlayer(
          BetterPlayerDataSource(
            BetterPlayerDataSourceType.network,
            widget.video,
            notificationConfiguration:
                const BetterPlayerNotificationConfiguration(
              showNotification: false,
            ),
            bufferingConfiguration: const BetterPlayerBufferingConfiguration(
                minBufferMs: 2000,
                maxBufferMs: 10000,
                bufferForPlaybackMs: 1000,
                bufferForPlaybackAfterRebufferMs: 2000),
          ),

          configuration: const BetterPlayerConfiguration(
              controlsConfiguration: BetterPlayerControlsConfiguration(
                controlBarColor: Color(0x51000000),
                showControlsOnInitialize: false,
              ),
              autoPlay: false,
              aspectRatio: 1,
              handleLifecycle: true),
          //key: Key(videoListData.hashCode.toString()),
          playFraction: 0.8,
          betterPlayerListVideoPlayerController: controller,
        ),
        aspectRatio: 1.2);
  }
}

// AspectRatio(
// aspectRatio: 16 / 9,
// child: BetterPlayer.network(
// widget.snap['videoUrl'],
// betterPlayerConfiguration:
// const BetterPlayerConfiguration(
// handleLifecycle: true,
// autoPlay: false,
// controlsConfiguration:
// BetterPlayerControlsConfiguration(
// showControlsOnInitialize: false,
// ),
// aspectRatio: 16 / 9,
// ),
// ),
// )
