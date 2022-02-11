import 'package:auto_route/auto_route.dart';
import 'profile_user_stats_bar.dart';
import 'report_profile_widget.dart';
import '../../../../translations/locale_keys.g.dart';
import '../../../../core/common/widget/custom_svg_renderer.dart';
import '../../../../core/routes/routes.gr.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/images.dart';
import '../../../../core/widgets/media_picker.dart';
import '../../../feed/presentation/bloc/feed_cubit.dart';
import '../../../feed/presentation/widgets/all_home_screens.dart';
import '../../domain/entity/profile_entity.dart';
import '../bloc/profile_cubit.dart';
import '../pages/followers_following_screen.dart';
import '../pages/profile_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';

class SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new Container(
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

class GetStatusBar extends StatefulWidget {
  final String? otherUserId;

  const GetStatusBar({Key? key, this.otherUserId}) : super(key: key);

  @override
  _GetStatusBarState createState() => _GetStatusBarState();
}

class _GetStatusBarState extends State<GetStatusBar> {
  ProfileCubit? profileCubit;

  @override
  void initState() {
    super.initState();
    profileCubit = BlocProvider.of<ProfileCubit>(context);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ProfileEntity>(
      stream: profileCubit!.profileEntity,
      builder: (context, snapshot) {
        if (snapshot.data == null) return const SizedBox();
        return ProfileUserStatsBar(
          profileCubit,
          snapshot.data,
          userId: widget.otherUserId,
        );
      },
    );
  }
}

class TopAppBar extends StatefulWidget {
  final bool otherUser;
  final ProfileEntity? profileEntity;
  final ProfileNavigationEnum? profileNavigationEnum;
  final String? otherUserId;

  const TopAppBar(
      {Key? key,
      this.otherUser = false,
      this.profileEntity,
      this.profileNavigationEnum,
      this.otherUserId})
      : super(key: key);

  @override
  _TopAppBarState createState() => _TopAppBarState();
}

class _TopAppBarState extends State<TopAppBar> {
  var buttonText = '';
  late ProfileCubit profileCubit;

  @override
  void initState() {
    super.initState();
    profileCubit = BlocProvider.of<ProfileCubit>(context);
    buttonText = widget.otherUserId != null
        ? !widget.profileEntity!.isFollowing
            ? LocaleKeys.follow.tr()
            : LocaleKeys.unfollow.tr()
        : LocaleKeys.settings.tr().capitalize();
  }

  String _capitalizedStringLetters(String str) {
    try {
      String temp = '';
      str.split(' ').forEach((s) {
        temp += '${s[0].toUpperCase()}${s.substring(1)} ';
      });
      return temp;
    } catch (e) {
      return '${str[0].toUpperCase()}${str.substring(1)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    print(widget.profileEntity!.website);
    return getTopAppBar(otherUser: widget.otherUser);
  }

  Widget getTopAppBar({otherUser = false}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        [
          AspectRatio(
            aspectRatio: 2.5,
            child: Container(
              child: widget.profileEntity!.backgroundUrl!.toNetWorkOrLocalImage(
                width: double.infinity,
                borderRadius: 0,
              ),
            ),
          ),
          [
            40.toSizedBoxHorizontal,
            [
              [
                [
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder: (context) => Container(
                          height: otherUser ? 200 : 150,
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.only(
                            left: 30,
                            right: 30,
                            top: 15,
                            bottom: 20,
                          ),
                          decoration: const BoxDecoration(
                            color: Colors.purple,
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
                                  color:  Colors.purple[900],
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(5),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 18.0),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      if (!profileCubit.isPrivateUser)
                                        InkWell(
                                          onTap: () {
                                            context.router.root.push(
                                              FollowingFollowersScreenRoute(
                                                userId: widget.otherUserId,
                                                followScreenEnum:
                                                    FollowUnFollowScreenEnum
                                                        .FOLLOWING,
                                              ),
                                            );
                                          },
                                          child: Row(
                                            children: [
                                              Images.showFollowing
                                                  .toSvg(
                                                    color: Colors.white,
                                                    height: 25,
                                                    width: 25,
                                                  )
                                                  .toHorizontalPadding(5),
                                              const SizedBox(width: 20),
                                              Text(
                                                LocaleKeys.show_followings.tr(),
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
                                      if (!profileCubit.isPrivateUser)
                                        InkWell(
                                          onTap: () {
                                            context.router.root.push(
                                              FollowingFollowersScreenRoute(
                                                userId: widget.otherUserId,
                                                followScreenEnum:
                                                    FollowUnFollowScreenEnum
                                                        .FOLLOWERS,
                                              ),
                                            );
                                          },
                                          child: Row(
                                            children: [
                                              Images.showFollowers
                                                  .toSvg(
                                                    color: Colors.white,
                                                    height: 25,
                                                    width: 25,
                                                  )
                                                  .toHorizontalPadding(5),
                                              const SizedBox(width: 20),
                                              Text(
                                                LocaleKeys.show_followers.tr(),
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
                                      if (otherUser)
                                        InkWell(
                                          onTap: () {
                                            Navigator.pop(context);
                                            showModalBottomSheet(
                                              context: context,
                                              builder: (_) =>
                                                  ReportProfileWidget(
                                                      widget.otherUserId!),
                                            );
                                          },
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.flag_outlined,
                                                color: Colors.white,
                                              ),
                                              const SizedBox(width: 20),
                                              Text(
                                                LocaleKeys.report_this_profile
                                                    .tr(),
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
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Icon(
                        Icons.more_horiz,
                        color: AppColors.colorPrimary,
                      ),
                    ),
                  ),
                ].toColumn().toPadding(12),
                if (otherUser)
                  AppIcons.messageProfile().onTapWidget(
                    () {
                      context.router.root.push(
                        ChatScreenRoute(
                          otherPersonProfileUrl:
                              widget.profileEntity!.profileUrl,
                          otherPersonUserId: widget.profileEntity!.id,
                          otherUserFullName: widget.profileEntity!.fullName,
                        ),
                      );
                    },
                  ),
                if (otherUser) 10.toSizedBox,
                LocaleKeys.settings
                    .tr()
                    .toUpperCase()
                    .toCaption(
                      fontWeight: FontWeight.bold,
                      color: AppColors.colorPrimary,
                    )
                    .toOutlinedBorder(() {
                      context.router.root
                          .push(SettingsScreenRoute(fromProfile: true));
                    })
                    .toContainer(height: 30, alignment: Alignment.center)
                    .toVisibility(!widget.otherUser),
                getOtherUserButton().toVisibility(widget.otherUser)
              ].toRow(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center),
              [
                _capitalizedStringLetters(widget.profileEntity!.fullName)
                    .toHeadLine6(
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade700,
                    )
                    .toEllipsis
                    .toFlexible(),
                4.toSizedBoxHorizontal,
                AppIcons.verifiedIcons
                    .toVisibility(widget.profileEntity!.isVerified!)
              ].toRow(crossAxisAlignment: CrossAxisAlignment.center),
              widget.profileEntity!.userName.toSubTitle2(
                fontWeight: FontWeight.w600,
                color: Colors.black54,
                fontFamily1: "CeraPro",
              ),
              if (widget.profileEntity!.about!.isNotEmpty) 10.toSizedBox,
              [
                widget.profileEntity!.about!
                    .toSubTitle2(
                      fontWeight: FontWeight.w600,
                      color: widget.profileEntity!.about == ''
                          ? Colors.transparent
                          : Colors.black54,
                      fontFamily1: "CeraPro",
                    )
                    .toContainer(maxWidth: context.getScreenWidth * .8)
                    .onTapWidget(
                  () {
                    context.showOkAlertDialog(
                      desc: widget.profileEntity!.about!,
                      title: LocaleKeys.about_you.tr(),
                    );
                  },
                )
              ]
                  .toRow(crossAxisAlignment: CrossAxisAlignment.center)
                  .toVisibility(
                    widget.profileEntity!.about!.isNotEmpty &&
                        widget.profileEntity!.about != '',
                  ),
              if (widget.profileEntity!.website!.isNotEmpty) 13.toSizedBox,
              [
                const Icon(
                  Icons.insert_link_outlined,
                  size: 15,
                  color: AppColors.optionIconColor,
                )
                    .toVisibility(
                      widget.profileEntity!.website!.isNotEmpty,
                    )
                    .toVerticalPadding(2),
                5.toSizedBoxHorizontal,
                widget.profileEntity!.website!
                    .toCaption(
                      textOverflow: TextOverflow.ellipsis,
                    )
                    .toVisibility(
                      widget.profileEntity!.website!.isNotEmpty,
                    )
              ].toRow(),
              if (widget.profileEntity!.website!.isNotEmpty) 5.toSizedBox,
              [
                Images.profileCounry.toSvg(color: AppColors.optionIconColor),
                5.toSizedBoxHorizontal,
                "${LocaleKeys.living_in.tr(namedArgs: {
                      '@country_name@': widget.profileEntity!.country!
                    })}"
                    .toCaption(),
                5.toSizedBoxHorizontal,
                FutureBuilder<DrawableRoot>(
                  builder: (_, item) => CustomPaint(
                    painter: MySvgRenderer(item.data),
                    size: const Size(20, 20),
                  ),
                  future: svg.fromSvgString(widget.profileEntity!.countryFlag!,
                      widget.profileEntity!.countryFlag!),
                ),
                7.toSizedBoxHorizontal,
              ].toRow(crossAxisAlignment: CrossAxisAlignment.center),
              8.toSizedBox,
              [
                Images.profileCalendar.toSvg(color: AppColors.optionIconColor),
                5.toSizedBoxHorizontal,
                "${LocaleKeys.member_since.tr(namedArgs: {
                      '@date@': widget.profileEntity!.memberSince!
                    })}"
                    .toCaption()
              ].toRow(crossAxisAlignment: CrossAxisAlignment.center),
              13.toSizedBox,
              GetStatusBar(
                otherUserId: widget.otherUserId,
              ),
            ].toColumn().toExpanded(),
            10.toSizedBoxHorizontal
          ].toRow().toExpanded(flex: 3),
        ].toColumn(),
        Positioned(
          top: calculateHeightForImage(widget.profileEntity!) as double?,
          right: context.isArabic() ? 30.toWidth as double? : null,
          left: context.isArabic() ? null : 30.toWidth as double?,
          child: Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 3.0),
                shape: BoxShape.circle),
            child: widget.profileEntity!.profileUrl!
                .toRoundNetworkImage(radius: 17),
          ).onTapWidget(
            () async {
              if (!widget.otherUser)
                await openMediaPicker(
                  context,
                  (media) async {
                    profileCubit.changeProfileEntity(
                      widget.profileEntity!.copyWith(profileImage: media),
                    );
                    await profileCubit.updateProfileAvatar(media);
                  },
                );
            },
          ),
        ),
        Positioned(
          top: 10.toHeight as double?,
          left: !context.isArabic() ? 10.toWidth as double? : null,
          right: context.isArabic() ? 10.toWidth as double? : null,
          child: IconButton(
            icon: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.black26,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_back, color: Colors.white),
            ),
            onPressed: () {
              switch (widget.profileNavigationEnum!) {
                case ProfileNavigationEnum.FROM_BOOKMARKS:
                  BlocProvider.of<FeedCubit>(context)
                      .changeCurrentPage(const ScreenType.home());
                  break;
                case ProfileNavigationEnum.FROM_FEED:
                  context.router.root.pop();
                  break;
                case ProfileNavigationEnum.FROM_SEARCH:
                  BlocProvider.of<FeedCubit>(context)
                      .changeCurrentPage(const ScreenType.search());
                  break;
                case ProfileNavigationEnum.FROM_VIEW_POST:
                  break;
                case ProfileNavigationEnum.FROM_MY_PROFILE:
                  BlocProvider.of<FeedCubit>(context)
                      .changeCurrentPage(const ScreenType.home());
                  break;
                case ProfileNavigationEnum.FROM_OTHER_PROFILE:
                  BlocProvider.of<FeedCubit>(context)
                      .changeCurrentPage(const ScreenType.home());
                  break;
                case ProfileNavigationEnum.FROM_MESSAGES:
                  BlocProvider.of<FeedCubit>(context)
                      .changeCurrentPage(const ScreenType.message());
                  break;
                case ProfileNavigationEnum.FROM_NOTIFICATION:
                  BlocProvider.of<FeedCubit>(context)
                      .changeCurrentPage(const ScreenType.notification());
                  break;
              }
            },
          ),
        )
      ],
    );
  }

  num calculateHeightForName(ProfileEntity profileEntity) {
    if (profileEntity.about!.isNotEmpty)
      return context.getScreenWidth > 320
          ? profileEntity.about!.length > 40
              ? 155.toHeight
              : 165.toHeight
          : 160.toHeight;
    return 160.toHeight;
  }

  num calculateHeightForImage(ProfileEntity profileEntity) {
    if (profileEntity.about!.isEmpty)
      return context.getScreenWidth > 320 ? 120.toHeight : 85.toHeight;
    return context.getScreenWidth > 320
        ? profileEntity.about!.length > 40
            ? 115.toHeight
            : 120.toHeight
        : 90.toHeight;
  }

  Widget getOtherUserButton() {
    if (buttonText == LocaleKeys.unfollow.tr())
      return buttonText
          .toCaption(color: Colors.white, fontWeight: FontWeight.w800)
          .toMaterialButton(
        () {
          context.showOkCancelAlertDialog(
              desc: LocaleKeys
                  .please_note_that_if_you_unsubscribe_then_this_user_s_posts_will_n
                  .tr(),
              title: LocaleKeys.please_confirm_your_actions.tr(),
              onTapOk: () {
                context.router.root.pop();
                profileCubit.followUnFollow();
                setState(
                  () {
                    buttonText = LocaleKeys.follow.tr();
                  },
                );
              },
              okButtonTitle: LocaleKeys.unfollow.tr());
        },
      ).toContainer(height: 25);
    else
      return buttonText
          .toCaption(fontWeight: FontWeight.bold, color: AppColors.colorPrimary)
          .toOutlinedBorder(
        () {
          if (widget.otherUser) {
            setState(
              () {
                buttonText = LocaleKeys.unfollow.tr();
              },
            );
            profileCubit.followUnFollow();
          } else
            context.router.root.push(SettingsScreenRoute(fromProfile: true));
        },
      ).toContainer(height: 25);
  }
}
