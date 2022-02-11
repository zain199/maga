import 'package:auto_route/auto_route.dart';
import 'package:better_player/better_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:colibri/core/extensions/color_extension.dart';
import 'package:colibri/core/theme/images.dart';
import 'package:colibri/features/feed/presentation/widgets/interaction_row.dart';
import '../common/add_thumbnail/check_link.dart';
import '../common/add_thumbnail/web_link_show.dart';
import '../common/add_thumbnail/youtube_thumbnil.dart';
import '../theme/colors.dart';
import 'MediaOpener.dart';
import 'thumbnail_widget.dart';
import '../../features/feed/domain/entity/post_entity.dart';
import '../../features/feed/domain/entity/post_media.dart';
import '../../features/feed/presentation/widgets/create_post_card.dart';
import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/material.dart';
import '../../extensions.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:velocity_x/velocity_x.dart';

class CustomSlider extends StatefulWidget {
  final PostEntity? postEntity;
  final bool? isOnlySocialLink;
  final bool? isComeHome;
  final bool fromComments;
  final List<PostMedia>? mediaItems;
  final bool dialogView;
  final int currentIndex;
  final Function? onClickAction;
  final ogData;
  // final OgDataClass1  ogData;

  const CustomSlider(
      {Key? key,
      this.onClickAction,
      this.postEntity,
      this.isOnlySocialLink,
      this.mediaItems,
      this.dialogView = false,
      this.currentIndex = 0,
      this.fromComments = false,
      this.ogData,
      this.isComeHome})
      : super(key: key);
  @override
  _CustomSliderState createState() => _CustomSliderState();
}

class _CustomSliderState extends State<CustomSlider> {
  int _current = 0;
  PageController? pageController;

  final ValueNotifier<int> _pageNotifier = new ValueNotifier<int>(0);
  PageController _pageController = PageController();

  PageController? _pageControllerClick;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();

    _current = widget.currentIndex;
    pageController = PageController(initialPage: widget.currentIndex);
    _pageControllerClick = PageController(initialPage: currentPage);

    if (widget.mediaItems != null && widget.mediaItems!.length != 0) {
      print(widget.mediaItems![0].mediaType == MediaTypeEnum.IMAGE);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: heightSet(),
      margin: const EdgeInsets.only(bottom: 10),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(50)),
      child: showPostWiseData(),
    );
  }

  heightSet() {
    if (widget.postEntity?.ogData != null &&
        widget.postEntity!.ogData != "" &&
        (widget.postEntity!.ogData["image"] == null ||
            widget.postEntity!.ogData["image"] == "") &&
        widget.postEntity!.ogData["url"] != null &&
        widget.postEntity!.ogData["url"] != "") {
      return 135.0;
    } else {
      if (widget.isOnlySocialLink!) {
        return context.getScreenHeight * .23;
      } else {
        if (widget.mediaItems != null && widget.mediaItems!.length != 0) {
          print(widget.mediaItems![0].mediaType == MediaTypeEnum.VIDEO);
          if (widget.mediaItems![0].mediaType == MediaTypeEnum.VIDEO) {
            return 135.0;
          } else {
            return 160.0;
          }
        } else {
          return 160.0;
        }
      }
    }
  }

  showPostWiseData() {
    String description = "";

    if (widget.ogData != null && widget.ogData != "") {
      description = widget.ogData['url'] ?? "";
    }

    String linkGet = "";

    if (widget.ogData != null) {
      String convertLink1 = CheckLink.checkYouTubeLink(description);

      print("vishal <><><<><><><> $convertLink1");

      String convertLink = convertLink1.replaceAll("\n", " ");

      List d1 = [];

      d1 = convertLink.split(" ");

      print("Vishal .,.,.,.,.,.,.,.,  $d1");

      d1.forEach((element) {
        if (element.contains("https://www.youtube.com") ||
            element.contains("https://youtu.be") ||
            element.contains("https://m.youtube.com/") ||
            element.contains("www.youtube.com")) {
          linkGet = element;
        } else if (element.contains("https://") || element.contains("www.")) {
          linkGet = element;
        } else {
          print("no data");
          // linkGet = "";
        }
      });
    }

    if (widget.postEntity?.ogData != null &&
        widget.postEntity!.ogData != "" &&
        (widget.postEntity!.ogData["image"] == null ||
            widget.postEntity!.ogData["image"] == "") &&
        widget.postEntity!.ogData["url"] != null &&
        widget.postEntity!.ogData["url"] != "") {
      return imageNotShow();
    } else if (linkGet.contains("https://www.youtube.com") ||
        linkGet.contains("https://youtu.be") ||
        linkGet.contains("https://m.youtube.com/") ||
        linkGet.contains("www.youtube.com")) {
      return SimpleUrlPreview(
        url: CheckLink.checkYouTubeLink(linkGet),
        previewHeight: 200,
        previewContainerPadding: EdgeInsets.all(0),
        homePagePostCreate: false,
        postEntity: widget.postEntity,
        onClickAction: (index) {
          print(index);
          widget.onClickAction!(index);
          Future.delayed(Duration(milliseconds: 50), () {
            setState(() {});
          });
        },
      );
    } else if (linkGet.contains("https://www.youtube")) {
      return Container(
        height: 100,
        width: 300,
        child: Text("No Youtube data found",
            style: TextStyle(color: Colors.purpleAccent)),
      );
    } else if (linkGet.contains("https://") || linkGet.contains("www.")) {
      print('qwd');
      return SimpleUrlPreviewWeb(
        url: CheckLink.checkYouTubeLink(linkGet),
        bgColor: Colors.purple,
        isClosable: false,
        previewHeight: 180,
        homePagePostCreate: false,
        postEntity: widget.postEntity,
      );
    } else {
      return showGrid(widget.mediaItems?.length ?? 0);
    }
  }

  showGrid(int length) {
    if (length == 1) {
      return Container(
        decoration: const BoxDecoration(
          // color: Colors.black,
          borderRadius: BorderRadius.all(
            Radius.circular(15),
          ),
        ),
        child: gridData(0, length),
      );
    } else if (length == 2) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: widget.mediaItems?.length ?? 0,
              itemBuilder: (context, index) {
                return Container(
                  decoration: const BoxDecoration(
                      // color: Colors.black,
                      borderRadius: BorderRadius.all(Radius.circular(15))),
                  child: twoImageShow(index, widget.mediaItems?.length),
                );
              },
              onPageChanged: (index) {
                setState(() {
                  print("Hello vishal $index");
                  _current = index;
                  _pageNotifier.value = index;
                  _pageControllerClick = PageController(initialPage: index);
                });
              },
            ),
            Container(
              height: 6,
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.only(
                  right: 5,
                  top: 10,
                  left: MediaQuery.of(context).size.width / 1.65),
              alignment: Alignment.centerRight,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: ListView.builder(
                  controller: _pageController,
                  itemCount: widget.mediaItems?.length ?? 0,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return SizedBox(
                      height: 6,
                      width: _current == index ? 20 : 12,
                      child: Container(
                        height: 6,
                        width: _current == index ? 20 : 12,
                        margin: EdgeInsets.only(right: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          // shape: BoxShape.circle,
                          color: _current == index
                              ? Color(0xFF1D88F0)
                              : Color(0xFF1D88F0).withOpacity(0.7),
                        ),
                      ),
                    );
                  }),
            ),
          ],
        ),
      );
    } else if (length == 3 || length >= 3) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            flex: 1,
            child: Container(
              height: context.getScreenHeight * .223,
              margin: EdgeInsets.only(right: 0),
              decoration: const BoxDecoration(
                // color: Colors.black,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
                ),
              ),
              child: gridData(0, length),
            ),
          ),
          Flexible(
              flex: 1,
              child: Column(children: [
                Container(
                  height: context.getScreenHeight * .11,
                  decoration: const BoxDecoration(
                    // color: Colors.black,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(15),
                    ),
                  ),
                  child: gridData(1, length),
                ),
                Container(
                  height: widget.fromComments
                      ? context.getScreenHeight * .085
                      : context.getScreenHeight * .11,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: const BoxDecoration(
                      // color: Colors.black,
                      borderRadius:
                          BorderRadius.only(bottomRight: Radius.circular(15))),
                  child: gridData(2, length),
                ),
              ]))
        ],
      );
    } else {
      return Container();
    }
  }

  twoImageShow(int itemIndex, int? length) {
    if (widget.mediaItems![itemIndex].mediaType == MediaTypeEnum.IMAGE) {
      return ClipRRect(
          borderRadius: BorderRadius.circular(0),
          child: CachedNetworkImage(
              imageUrl: widget.mediaItems![itemIndex].url!,
              width: context.getScreenWidth as double?,
              height: 180,
              fit: BoxFit.cover,
              progressIndicatorBuilder: (_, ___, progress) {
                Vx.teal100;
                return const CircularProgressIndicator()
                    .toPadding(8)
                    .toCenter();
              })).toHorizontalPadding(0).onTapWidget(() {
        if (!widget.dialogView) showMediaSlider(itemIndex, length);
      });
    } else if (widget.mediaItems![itemIndex].mediaType == MediaTypeEnum.VIDEO) {
      GlobalKey<MyVideoPlayerState> videoKey = GlobalKey();
      return ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: MyVideoPlayer(
            withAppBar: false,
            key: videoKey,
            path: widget.mediaItems![itemIndex].url),
      ).onTapWidget(() {
        videoKey.currentState!.pause();
        showAnimatedDialog(
            barrierDismissible: true,
            context: context,
            builder: (c) => MyVideoPlayer(
                path: widget.mediaItems![itemIndex].url,
                withAppBar: false,
                fullVideoControls: true));
      });
    } else if (widget.mediaItems![itemIndex].mediaType == MediaTypeEnum.GIF) {
      return GiphyWidget(
        path: widget.mediaItems![itemIndex].url,
        enableClose: false,
      ).toContainer(color: Colors.purple);
    } else if (widget.mediaItems![itemIndex].mediaType == MediaTypeEnum.EMOJI) {
      return GiphyWidget(
        path: widget.mediaItems![itemIndex].url,
      ).toContainer(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)));
    }
  }

  Widget getListView() {
    return ExpandablePageView(
      children: List<Widget>.generate(
        widget.mediaItems!.length,
        (itemIndex) {
          switch (widget.mediaItems![itemIndex].mediaType) {
            case MediaTypeEnum.IMAGE:
              return ClipRRect(
                borderRadius: BorderRadius.circular(35),
                child: CachedNetworkImage(
                  imageUrl: widget.mediaItems![itemIndex].url!,
                  width: context.getScreenWidth as double?,
                  height: 180,
                  fit: BoxFit.cover,
                  progressIndicatorBuilder: (_, ___, progress) {
                    Vx.teal100;
                    return const CircularProgressIndicator()
                        .toPadding(8)
                        .toCenter();
                  },
                ),
              ).toHorizontalPadding(4).onTapWidget(
                () {
                  if (!widget.dialogView)
                    showAnimatedDialog(
                        alignment: Alignment.center,
                        context: context,
                        builder: (c) => Column(
                              // mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Stack(
                                  // fit: StackFit.passthrough,
                                  children: [
                                    CustomSlider(
                                      mediaItems: widget.mediaItems,
                                      dialogView: true,
                                      currentIndex: _current,
                                    ),
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: CircleAvatar(
                                          backgroundColor: Colors.black54,
                                          child: CloseButton(
                                            color: Colors.white,
                                            onPressed: () {
                                              context.router.root.pop();
                                            },
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            )
                                .makeScrollable()
                                .toContainer(
                                    height: context.getScreenHeight as double,
                                    alignment: Alignment.center)
                                .toSafeArea,
                        barrierDismissible: true);
                },
              );

            case MediaTypeEnum.VIDEO:
              GlobalKey<MyVideoPlayerState> videoKey = GlobalKey();
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: MyVideoPlayer(
                  withAppBar: false,
                  key: videoKey,
                  path: widget.mediaItems![itemIndex].url,
                ),
              ).onTapWidget(
                () {
                  videoKey.currentState!.pause();
                  showAnimatedDialog(
                      barrierDismissible: true,
                      context: context,
                      builder: (c) => MyVideoPlayer(
                          path: widget.mediaItems![itemIndex].url,
                          withAppBar: false,
                          fullVideoControls: true));
                },
              );

            case MediaTypeEnum.GIF:
              return GiphyWidget(
                path: widget.mediaItems![itemIndex].url,
                enableClose: false,
              ).toContainer(color: Colors.purple);
            case MediaTypeEnum.EMOJI:
              return GiphyWidget(
                path: widget.mediaItems![itemIndex].url,
              ).toContainer(
                  height: 150,
                  width: double.infinity,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(8)));

            default:
              return Container();
          }
        },
      ),
      controller: pageController,
    );
  }

  gridData(int itemIndex, int length) {
    if (widget.mediaItems == null || widget.mediaItems!.length == 0) {
      return Container();
    } else {
      if (widget.mediaItems![itemIndex].mediaType == MediaTypeEnum.IMAGE) {
        return ClipRRect(
          borderRadius: boarderRadiusCheck(itemIndex, length),
          child: CachedNetworkImage(
            imageUrl: widget.mediaItems![itemIndex].url!,
            width: context.getScreenWidth as double?,
            fit: BoxFit.cover,
            progressIndicatorBuilder: (_, ___, progress) {
              Vx.teal100;
              return const CircularProgressIndicator().toPadding(8).toCenter();
            },
          ),
        ).toHorizontalPadding(1).onTapWidget(
          () {
            print("cureenty index show $itemIndex");

            _pageControllerClick = PageController(initialPage: itemIndex);

            setState(() {});
            if (!widget.dialogView) showMediaSlider(itemIndex, length);
          },
        );
      } else if (widget.mediaItems![itemIndex].mediaType ==
          MediaTypeEnum.VIDEO) {
        GlobalKey<MyVideoPlayerState> videoKey = GlobalKey();
        return ClipRRect(
          borderRadius: boarderRadiusCheck(itemIndex, length),
          child: MyVideoPlayer(
            withAppBar: false,
            key: videoKey,
            path: widget.mediaItems![itemIndex].url,
            isComeHome: widget.isComeHome,
          ).onTapWidget(
            () {
              videoKey.currentState!.pause();
              showMediaSlider(itemIndex, length);
            },
          ),
        );
      } else if (widget.mediaItems![itemIndex].mediaType == MediaTypeEnum.GIF) {
        return GiphyWidget(
          path: widget.mediaItems![itemIndex].url,
          enableClose: false,
          itemIndex: itemIndex,
          length: length,
        ).toContainer(color: Colors.purple);
      } else if (widget.mediaItems![itemIndex].mediaType ==
          MediaTypeEnum.EMOJI) {
        return GiphyWidget(
          path: widget.mediaItems![itemIndex].url,
          itemIndex: itemIndex,
          length: length,
        ).toContainer(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)));
      } else {
        return Container();
      }
    }
  }

  boarderRadiusCheck(int itemIndex, int length) {
    if (length == 1) {
      return BorderRadius.circular(15);
    } else if (length == 2) {
      if (itemIndex == 0) {
        return const BorderRadius.only(
            topLeft: Radius.circular(15), bottomLeft: Radius.circular(15));
      } else {
        return const BorderRadius.only(
            topRight: Radius.circular(15), bottomRight: Radius.circular(15));
      }
    } else if (length == 3 || length >= 3) {
      if (itemIndex == 0) {
        return const BorderRadius.only(
            topLeft: Radius.circular(15), bottomLeft: Radius.circular(15));
      } else if (itemIndex == 1) {
        return const BorderRadius.only(topRight: Radius.circular(15));
      } else {
        return const BorderRadius.only(bottomRight: Radius.circular(15));
      }
    } else if (length == 4) {
      if (itemIndex == 0) {
        return const BorderRadius.only(topLeft: Radius.circular(15));
      } else if (itemIndex == 1) {
        return const BorderRadius.only(bottomLeft: Radius.circular(15));
      } else if (itemIndex == 2) {
        return const BorderRadius.only(topRight: Radius.circular(15));
      } else {
        return const BorderRadius.only(bottomRight: Radius.circular(15));
      }
    } else {
      return BorderRadius.circular(15);
    }
  }

  showMediaSlider(int itemIndex, int? length) {
    GlobalKey<MyVideoPlayerState> videoAlertKey = GlobalKey();
    videoAlertKey.currentState?.isPlaying = false;

    bool isArrowShow = true;
    bool isVideoPlay = true;

    return showAnimatedDialog(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (context, setState) {
          return InkWell(
            onTap: () {
              if (widget.mediaItems![itemIndex].mediaType ==
                  MediaTypeEnum.IMAGE) {
                isArrowShow = !isArrowShow;
                setState(() {});
              } else {
                isVideoPlay = !isVideoPlay;
                setState(() {});
              }
            },
            child: Container(
              color: HexColor.fromHex('#24282E').withOpacity(1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  closeButton(),
                  Expanded(
                    child: PageView.builder(
                      itemCount: length ?? 0,
                      controller: _pageControllerClick,
                      onPageChanged: (int index) {
                        currentPage = index;
                        setState(() {});
                      },
                      itemBuilder: (context, index) {
                        return widget.mediaItems![itemIndex].mediaType ==
                                MediaTypeEnum.VIDEO
                            ? videoSlider(itemIndex)
                            : imageSlider(index);
                      },
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  InteractionRow(
                    onClickAction: widget.onClickAction!,
                    postEntity: widget.postEntity!,
                    setStateFun: () => setState(() {}),
                  ),
                  SizedBox(
                    height: context.getScreenHeight * .1,
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget imageSlider(int index) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: context.getScreenHeight * .7,
      ),
      child: CachedNetworkImage(
        imageUrl: widget.mediaItems![index].url!,
        fit: BoxFit.scaleDown,
        progressIndicatorBuilder: (_, __, progress) {
          Vx.teal100;
          return const CircularProgressIndicator().toPadding(8).toCenter();
        },
      ),
    );
  }

  Widget videoSlider(int itemIndex) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: BetterPlayer.network(
            widget.mediaItems![itemIndex].url!,
            betterPlayerConfiguration: BetterPlayerConfiguration(
              fit: BoxFit.fitHeight,
              aspectRatio: 16 / 9,
            ),
          ),
        ),
      ],
    );
  }

  imageNotShow() {
    return Container(
      height: 130,
      width: 250,
      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 12, right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
        border: Border.all(color: AppColors.sfBgColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
              CheckLink.removeHtmlTag(widget.postEntity?.ogData["title"]) ??
                  "Page not found!",
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 17,
                fontFamily: "CeraPro",
                color: Colors.black,
              ),
              maxLines: 1),
          const SizedBox(height: 5),
          Text(
              CheckLink.removeHtmlTag(
                      widget.postEntity?.ogData["description"]) ??
                  "Page not found!",
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
                fontFamily: "CeraPro",
                color: AppColors.greyText,
              ),
              maxLines: 2),
          const SizedBox(height: 5),
          Text(
              CheckLink.removeHtmlTag(widget.postEntity?.ogData["url"]) ??
                  "Page link not found!",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 15,
                fontFamily: "CeraPro",
                color: Theme.of(context).colorScheme.secondary,
              ),
              maxLines: 2),
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
