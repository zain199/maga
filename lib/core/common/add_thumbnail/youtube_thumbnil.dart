// library simple_url_preview;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:colibri/core/extensions/color_extension.dart';
import 'package:colibri/core/theme/colors.dart';
import 'package:colibri/core/theme/images.dart';
import 'package:colibri/core/widgets/circle_painter.dart';
import 'package:colibri/extensions.dart';
import 'package:colibri/features/feed/domain/entity/post_entity.dart';
import 'package:colibri/features/feed/presentation/widgets/interaction_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:simple_url_preview/widgets/preview_description.dart';

import 'package:simple_url_preview/widgets/preview_title.dart';
import 'package:string_validator/string_validator.dart';
import 'package:auto_route/auto_route.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

/// Provides URL preview
class SimpleUrlPreview extends StatefulWidget {
  /// URL for which preview is to be shown
  final String url;

  /// Height of the preview
  final double previewHeight;

  /// Container padding
  final EdgeInsetsGeometry? previewContainerPadding;

  final bool homePagePostCreate;
  final Function? clearText;

  final String? linkTitle;
  final String? linkDescription;

  /// Whether or not to show close button for the preview
  final bool? isClosable;

  /// Background color
  final Color? bgColor;

  /// Style of Title.
  final TextStyle? titleStyle;

  /// Number of lines for Title. (Max possible lines = 2)
  final int titleLines;

  /// Style of Description
  final TextStyle? descriptionStyle;

  /// Number of lines for Description. (Max possible lines = 3)
  final int descriptionLines;

  /// Style of site title
  final TextStyle? siteNameStyle;

  /// Color for loader icon shown, till image loads
  final Color? imageLoaderColor;

  /// onTap URL preview, by default opens URL in default browser
  final VoidCallback? onTap;

  final PostEntity? postEntity;
  final Function? onClickAction;

  SimpleUrlPreview(
      {required this.url,
      this.previewHeight = 130.0,
      this.isClosable,
      this.bgColor,
      this.titleStyle,
      this.titleLines = 2,
      this.descriptionStyle,
      this.descriptionLines = 3,
      this.siteNameStyle,
      this.imageLoaderColor,
      this.previewContainerPadding,
      this.onTap,
      this.homePagePostCreate = false,
      this.clearText,
      this.postEntity,
      this.linkTitle,
      this.linkDescription,
      this.onClickAction})
      : assert(previewHeight >= 130.0,
            'The preview height should be greater than or equal to 130'),
        assert(titleLines <= 2 && titleLines > 0,
            'The title lines should be less than or equal to 2 and not equal to 0'),
        assert(descriptionLines <= 3 && descriptionLines > 0,
            'The description lines should be less than or equal to 3 and not equal to 0');

  @override
  _SimpleUrlPreviewState createState() => _SimpleUrlPreviewState();
}

class _SimpleUrlPreviewState extends State<SimpleUrlPreview> {
  late bool _isClosable;
  double? _previewHeight;
  TextStyle? _titleStyle;
  TextStyle? _descriptionStyle;
  Color? _imageLoaderColor;
  EdgeInsetsGeometry? _previewContainerPadding;
  VoidCallback? _onTap;

  bool isVideoPlay = false;
  //widget.homePagePostCreate true close icon show : -

  @override
  void initState() {
    super.initState();
    _getUrlData();
  }

  void _initialize() {
    _previewHeight = widget.previewHeight;
    _descriptionStyle = widget.descriptionStyle;
    _titleStyle = widget.titleStyle;
    _previewContainerPadding = widget.previewContainerPadding;
    _onTap = widget.onTap ?? _launchURL;
  }

  void _getUrlData() async {
    if (!isURL(widget.url)) {
      return;
    }

    await DefaultCacheManager()
        .getSingleFile(widget.url)
        .catchError((error) {});

    if (!this.mounted) {
      return;
    }

    return;
  }

  void _launchURL() async {
    YoutubePlayerController _controller = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(widget.url)!,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );
    var isFullScreen = false;
    showAnimatedDialog(
      barrierDismissible: true,
      context: context,
      builder: (c) => OrientationBuilder(
        builder: (_, orientation) => StatefulBuilder(
          builder: (context, setState) {
            return Container(
              color: HexColor.fromHex('#24282E').withOpacity(1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (orientation == Orientation.portrait) closeButton(),
                  Expanded(
                    child: YoutubePlayerBuilder(
                      onEnterFullScreen: () => setState(() {
                        isFullScreen = true;
                      }),
                      onExitFullScreen: () => setState(() {
                        isFullScreen = false;
                      }),
                      player: YoutubePlayer(
                        controller: _controller,
                        liveUIColor: Colors.grey,
                      ),
                      builder: (_, __) => __,
                    ),
                  ),
                  if (!isFullScreen) ...[
                    SizedBox(
                      height: 10,
                    ),
                    InteractionRow(
                      onClickAction: widget.onClickAction!,
                      postEntity: widget.postEntity!,
                    ),
                    SizedBox(
                      height: context.getScreenHeight * .1,
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print(widget.postEntity);
    _isClosable = widget.isClosable ?? false;
    _imageLoaderColor =
        widget.imageLoaderColor ?? Theme.of(context).colorScheme.secondary;
    _initialize();

    return GestureDetector(
      onTap: _onTap,
      child: Container(
        padding: _previewContainerPadding,
        height: _previewHeight,
        child: Stack(
          children: [
            _buildPreviewCard(context),
            _buildClosablePreview(),
            widget.homePagePostCreate
                ? Align(
                    alignment: Alignment.topRight,
                    child: InkWell(
                      onTap: () {
                        // _onTap();
                        widget.clearText!();
                      },
                      child: Container(
                        height: 20,
                        width: 20,
                        margin: EdgeInsets.only(right: 20, top: 5),
                        decoration: BoxDecoration(
                            color: AppColors.twitterBlue,
                            shape: BoxShape.circle),
                        child: const Icon(Icons.close,
                            color: Colors.white, size: 15),
                      ),
                    ),
                  )
                : Align(
                    alignment: Alignment.center,
                    child: InkWell(
                      onTap: () {
                        _onTap!();
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 80.0),
                        child: CustomPaint(
                          painter: CirclePainter(),
                          child: Container(
                            height: 45.toHeight as double?,
                            width: 45.toHeight as double?,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.colorPrimary,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 2.0),
                              child: const Icon(
                                FontAwesomeIcons.play,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
          ],
        ),
      ),
    );
  }

  Widget _buildClosablePreview() {
    return _isClosable
        ? Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: Icon(
                Icons.clear,
              ),
              onPressed: () {},
            ),
          )
        : SizedBox();
  }

  _buildPreviewCard(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
          left: widget.homePagePostCreate ? 70 : 0,
          right: widget.homePagePostCreate ? 15 : 0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(
          10,
        ),
      ),
      child: Column(
        children: [
          Expanded(
            flex: 6,
            child: PreviewImage(
              'https://img.youtube.com/vi/${YoutubePlayer.convertUrlToId(widget.url)!}/0.jpg',
              _imageLoaderColor,
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              padding: EdgeInsets.all(8),
              alignment: Alignment.topLeft,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  PreviewTitle(
                    widget.postEntity?.ogData['title'] ?? widget.linkTitle,
                    _titleStyle == null
                        ? const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            fontFamily: "CeraPro",
                            color: Colors.black,
                          )
                        : _titleStyle,
                    1,
                    // _titleLines
                  ),
                  PreviewDescription(
                    widget.postEntity?.ogData['description'] ??
                        widget.linkDescription,
                    _descriptionStyle == null
                        ? const TextStyle(
                            fontSize: 10,
                            color: Colors.black,
                          )
                        : _descriptionStyle,
                    2,

                    // _descriptionLines,
                  ),
                  // PreviewSiteName(
                  //   widget.url,
                  //   // _urlPreviewData['og:site_name'],
                  //   _siteNameStyle == null
                  //       ? TextStyle(
                  //           fontSize: 10,
                  //           color: Theme.of(context).colorScheme.secondary,
                  //         )
                  //       : _siteNameStyle,
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget closeButton() {
    return SafeArea(
      child: Align(
        alignment: Alignment.topRight,
        child: InkWell(
          onTap: () {
            context.router.root.pop();
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Images.closeButton.toSvg(
              color: Colors.white,
              height: 40,
              width: 40,
            ),
          ),
        ),
      ),
    );
  }
}

/// Shows site URL
class PreviewSiteName extends StatelessWidget {
  final String _siteName;
  final TextStyle? _textStyle;

  PreviewSiteName(this._siteName, this._textStyle);

  @override
  Widget build(BuildContext context) {
    return Text(
      _siteName,
      textAlign: TextAlign.left,
      maxLines: 2,
      style: _textStyle,
    );
  }
}

/// Shows thumbnail of the video
class PreviewImage extends StatelessWidget {
  final String? _image;
  final Color? _imageLoaderColor;

  PreviewImage(this._image, this._imageLoaderColor);

  @override
  Widget build(BuildContext context) {
    if (_image != null) {
      return ClipRRect(
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10), topRight: Radius.circular(10)),
        child: CachedNetworkImage(
          imageUrl: _image!,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.none,
          errorWidget: (context, url, error) => Icon(
            Icons.error,
            color: _imageLoaderColor,
          ),
          progressIndicatorBuilder: (context, url, downloadProgress) => Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(
                child: Container(
                  height: 20,
                  width: 20,
                  margin: EdgeInsets.all(5),
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return SizedBox();
    }
  }
}
