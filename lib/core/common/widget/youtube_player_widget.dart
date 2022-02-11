import '../../theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubePlayerWidget extends StatelessWidget {
  YoutubePlayerWidget(this.url, {Key? key}) : super(key: key);
  final String url;

  YoutubePlayerController get _controller => YoutubePlayerController(
        initialVideoId: YoutubePlayer.convertUrlToId(url) ?? '',
        flags: YoutubePlayerFlags(
          autoPlay: true,
          mute: true,
        ),
      );
  @override
  Widget build(BuildContext context) {
    return YoutubePlayer(
      controller: _controller,
      showVideoProgressIndicator: true,
      progressIndicatorColor: AppColors.colorPrimary,
    );
  }
}
