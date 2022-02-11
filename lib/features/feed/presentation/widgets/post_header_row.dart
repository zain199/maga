import 'package:auto_route/src/router/auto_router_x.dart';
import 'package:colibri/core/constants/appconstants.dart';
import 'package:colibri/core/extensions/widget_extensions.dart';
import 'package:colibri/core/routes/routes.gr.dart';
import 'package:colibri/core/theme/app_icons.dart';
import 'package:colibri/core/theme/colors.dart';
import 'package:colibri/extensions.dart';
import 'package:colibri/features/authentication/data/models/login_response.dart';
import 'package:colibri/features/feed/domain/entity/post_entity.dart';
import 'package:colibri/translations/locale_keys.g.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';

class PostHeaderRow extends StatelessWidget {
  const PostHeaderRow({
    Key? key,
    required this.detailedPost,
    required this.postEntity,
    this.onPostOptionItem,
    this.loginResponseFeed,
  }) : super(key: key);
  final bool detailedPost;
  final PostEntity? postEntity;
  final StringToVoidFunc? onPostOptionItem;
  final LoginResponse? loginResponseFeed;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        [
          Padding(
            padding: EdgeInsets.only(
              top: AC.getDeviceHeight(context) * 0.013,
              right: !context.isArabic() ? 10 : 0,
              left: context.isArabic() ? 10 : 0,
            ),
            child: postEntity!.profileUrl!
                .toRoundNetworkImage(radius: 11)
                .toContainer(alignment: Alignment.topRight)
                .toVerticalPadding(0)
                .onTapWidget(
              () {
                navigateToProfile(context);
              },
            ),
          ),
        ]
            .toRow(mainAxisAlignment: MainAxisAlignment.end)
            .toVisibility(detailedPost),
        [
          detailedPost
              ? SizedBox(height: AC.getDeviceHeight(context) * 0.010)
              : Container(),
          [
            [
              RichText(
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                maxLines: 1,
                strutStyle: StrutStyle.disabled,
                textWidthBasis: TextWidthBasis.longestLine,
                text: TextSpan(
                  text: postEntity!.name,
                  style: context.subTitle1.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                    fontSize: AC.device17(context),
                    fontFamily: "CeraPro",
                  ),
                ),
              ).onTapWidget(() {
                navigateToProfile(context);
              }).toFlexible(flex: 2),
              5.toSizedBoxHorizontal,
              AppIcons.verifiedIcons
                  .toVisibility(postEntity!.postOwnerVerified),
              5.toSizedBoxHorizontal,
              Padding(
                padding: EdgeInsets.only(top: 2),
                child: Text(
                  postEntity!.time!,
                  style: TextStyle(
                    color: AppColors.greyText,
                    fontSize: AC.getDeviceHeight(context) * 0.015,
                    fontWeight: FontWeight.w400,
                    fontFamily: "CeraPro",
                  ),
                ),
              )
            ].toRow(crossAxisAlignment: CrossAxisAlignment.center).toFlexible(),
            6.toSizedBoxHorizontal
          ].toRow(crossAxisAlignment: CrossAxisAlignment.center).toContainer(),
          3.toSizedBoxVertical,
          InkWell(
            onTap: () {
              navigateToProfile(context);
            },
            child: SizedBox(
              height: 15,
              child: Text(
                postEntity!.userName!,
                style: TextStyle(
                  color: const Color(0xFF737880),
                  fontSize: AC.getDeviceHeight(context) * 0.015,
                  fontWeight: FontWeight.w400,
                  fontFamily: "CeraPro",
                ),
              ),
            ),
          ),
          5.toSizedBox.toVisibility(postEntity!.responseTo != null),
          [
            "In response to".toCaption(
                fontSize: 13,
                textOverflow: TextOverflow.ellipsis,
                maxLines: 2,
                color: AppColors.greyText),
            if (postEntity!.responseTo != null)
              InkWell(
                onTap: () {
                  context.router.root.push(
                    ProfileScreenRoute(
                      otherUserId: postEntity!.isOtherUser
                          ? postEntity!.responseToUserId
                          : null,
                    ),
                  );
                },
                child: postEntity!.responseTo!.toCaption(
                    color: AppColors.colorPrimary,
                    fontWeight: FontWeight.w600,
                    textOverflow: TextOverflow.ellipsis,
                    maxLines: 1),
              ),
            LocaleKeys.post.tr().toCaption(
                fontSize: 13,
                textOverflow: TextOverflow.ellipsis,
                maxLines: 1,
                color: AppColors.greyText)
          ].toWrap().toVisibility(
                postEntity!.responseTo != null &&
                    postEntity!.responseTo!.isNotEmpty,
              ),
        ]
            .toColumn(mainAxisAlignment: MainAxisAlignment.center)
            .toExpanded(flex: 8),
        [
          InkWell(
            onTap: () {
              bottomSheet(context);
            },
            child: Container(
              height: 30,
              width: 15,
              margin: context.isArabic()
                  ? const EdgeInsets.only(top: 3, left: 10)
                  : const EdgeInsets.only(top: 3, right: 10),
              child: Icon(
                Icons.keyboard_arrow_down,
                color: Colors.grey.withOpacity(0.6),
                size: 25,
              ),
            ),
          )
        ].toRow(crossAxisAlignment: CrossAxisAlignment.center),
      ],
    ).toHorizontalPadding(20);
  }

  void navigateToProfile(BuildContext context) {
    if (postEntity!.isOtherUser) {
      context.router.root.push(
        ProfileScreenRoute(
          otherUserId: postEntity!.userName!.split("@")[0],
        ),
      );
    } else
      context.router.root.push(ProfileScreenRoute());
  }

  bottomSheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 200,
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.only(
          left: 30,
          right: 30,
          top: 15,
          bottom: 20,
        ),
        decoration: const BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              height: 6,
              width: 37,
              margin: EdgeInsets.only(bottom: 10),
              decoration:  BoxDecoration(
                color:  Colors.red[900],
                borderRadius: BorderRadius.all(
                  Radius.circular(5),
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      onPostOptionItem!('Show likes');
                    },
                    child: Container(
                      height: 25,
                      margin: const EdgeInsets.only(top: 30),
                      child: Row(
                        children: [
                          AppIcons.showLikesIcon(color: Colors.white),
                          const SizedBox(width: 20),
                          Text(
                            LocaleKeys.show_likes.tr(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              fontFamily: "CeraPro",
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      onPostOptionItem!(
                        !postEntity!.isSaved! ? 'Bookmark' : "UnBookmark",
                      );
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 25,
                      margin: const EdgeInsets.only(top: 15),
                      child: Row(
                        children: [
                          AppIcons.bookmarkOption(),
                          const SizedBox(width: 20),
                          Text(
                            !postEntity!.isSaved! ? 'Bookmark' : "UnBookmark",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              fontFamily: "CeraPro",
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  postEntity!.isOtherUser &&
                          postEntity!.userName !=
                              loginResponseFeed!.data!.user!.userName
                      ? InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            onPostOptionItem!('Report Post');
                          },
                          child: Container(
                            height: 25,
                            margin: const EdgeInsets.only(top: 15),
                            child: Row(
                              children: [
                                AppIcons.reportIcon(color: Colors.white),
                                const SizedBox(width: 20),
                                Text(
                                  LocaleKeys.report_post.tr(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: "CeraPro",
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      : InkWell(
                          onTap: () {
                            print("Hel");
                            Navigator.pop(context);
                            onPostOptionItem!('Delete');
                          },
                          child: Container(
                            height: 25,
                            margin: const EdgeInsets.only(top: 10),
                            child: Row(
                              children: [
                                AppIcons.deleteOption(color: Colors.white),
                                const SizedBox(width: 20),
                                Text(
                                  LocaleKeys.delete.tr(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: "CeraPro",
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
