import 'dart:async';

import 'package:animations/animations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:colibri/core/theme/images.dart';
import '../widgets/feed_widgets.dart';
import 'package:flutter/services.dart';
import '../../../../translations/locale_keys.g.dart';
import '../../../../core/common/uistate/common_ui_state.dart';
import '../../../../core/constants/appconstants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/routes/routes.gr.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/colors.dart';
import '../../../../extensions.dart';
import '../../../authentication/data/models/login_response.dart';
import '../bloc/feed_cubit.dart';
import '../core/my_border_shape.dart';
import 'redeem_confirmation_screen.dart';
import '../widgets/all_home_screens.dart';
import '../widgets/get_drawer_menu.dart';
import '../../../messages/presentation/pages/message_screen.dart';
import '../../../notifications/presentation/pages/notification_screen.dart';
import '../../../posts/presentation/bloc/createpost_cubit.dart';
import '../../../posts/presentation/widgets/post_pagination_widget.dart';
import '../../../profile/domain/entity/profile_entity.dart';
import '../../../profile/presentation/pages/profile_screen.dart';
import '../../../profile/presentation/pages/settings_page.dart';
import '../../../search/presentation/pages/searh_screen.dart';
import '../../../../main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../profile/presentation/pages/bookmark_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

StreamController<double> controller = StreamController<double>.broadcast();
LoginResponse? loginResponseFeed;

class FeedScreen extends StatefulWidget {
  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  FeedCubit? feedCubit;
  CreatePostCubit? createPostCubit;

  int prevIndex = 0;
  int currentIndex = 0;

  bool _isVisible = true;

  bool isKeyBoardShow = false;

  SearchScreen searScreen = const SearchScreen();

  bool? isMessageShow = false;
  bool? isNotificationShow = false;

  @override
  void initState() {
    super.initState();
    feedCubit = getIt<FeedCubit>()
      ..getUserData()
      ..saveNotificationToken();
    createPostCubit = getIt<CreatePostCubit>();

    loginData();

    loginUserData();
    blurDotDataGet();
    updateData();
    checkIsKeyBoardShow();
  }

  @override
  void dispose() {
    super.dispose();
  }

  loginData() {
    Future.delayed(
      Duration(seconds: 1),
      () async {
        AC.loginResponse = await localDataSource!.getUserAuth();
      },
    );
  }

  loginUserData() async {
    loginResponseFeed = await localDataSource!.getUserData();
  }

  blurDotDataGet() {
    if (AC.prefs.containsKey("message")) {
      isMessageShow = AC.prefs.getBool("message");
    } else {
      AC.prefs.setBool("message", false);
    }

    if (AC.prefs.containsKey("notification")) {
      isNotificationShow = AC.prefs.getBool("notification");
    } else {
      AC.prefs.setBool("notification", false);
    }
    setState(() {});
  }

  updateData() {
    Stream stream = controller.stream;
    stream.listen((value) {
      isMessageShow = AC.prefs.getBool("message");
      isNotificationShow = AC.prefs.getBool("notification");

      setState(() {});
    });
  }

  checkIsKeyBoardShow() {
    KeyboardVisibilityController().onChange.listen((bool visible) {
      isKeyBoardShow = visible;
    });
  }

  @override
  Widget build(BuildContext context) {
    context.initScreenUtil();

    return MultiBlocProvider(
      providers: [
        BlocProvider<FeedCubit>(create: (c) => feedCubit!),
        BlocProvider<CreatePostCubit>(create: (c) => createPostCubit!)
      ],
      child: BlocListener<FeedCubit, CommonUIState>(
        listener: (_, state) {
          state.maybeWhen(
            orElse: () {},
            error: (e) => context.showSnackBar(message: e, isError: true),
            success: (s) {
              if (s is String) {
                if (s.toLowerCase().contains(LocaleKeys.logout.tr())) {
                  context.router.root.pushAndPopUntil(
                    LoginScreenRoute(),
                    predicate: (route) => false,
                  );
                }
                context.showSnackBar(message: s, isError: false);
              }
            },
          );
        },
        child: StreamBuilder<ScreenType>(
            stream: feedCubit!.currentPage,
            initialData: const ScreenType.home(),
            builder: (context, snapshot) {
              return WillPopScope(
                onWillPop: () async {
                  if (currentIndex != 0) {
                    onTapBottomBar(0);
                    return false;
                  } else
                    return context.willPopScopeDialog();
                },
                child: Scaffold(
                  key: scaffoldKey,
                  extendBody: true,
                  drawer: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      color: scaffoldKey.currentState?.isDrawerOpen != null &&
                              scaffoldKey.currentState!.isDrawerOpen
                          ? Colors.purple.withOpacity(0.6)
                          : Colors.transparent,
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width / 1.3,
                      child: Container(
                        color: Colors.white,
                        height: context.getScreenHeight as double?,
                        width: context.getScreenWidth / 1.3,
                        child: StreamBuilder<ProfileEntity>(
                          stream: feedCubit!.drawerEntity,
                          builder: (context, snapshot) {
                            if (snapshot.data == null)
                              return Container(
                                color: Colors.white,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const CircularProgressIndicator(),
                                  ],
                                ),
                              );
                            return GetDrawerMenu(
                              profileEntity: snapshot.data,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  appBar: appBarShow(snapshot.data),
                  body: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      SafeArea(
                        bottom: false,
                        child: PageTransitionSwitcher(
                          reverse: doReverse(),
                          child: getSelectedHomeScreen(snapshot.data!),
                          transitionBuilder: (Widget child,
                                  Animation<double> primaryAnimation,
                                  Animation<double> secondaryAnimation) =>
                              SharedAxisTransition(
                            animation: primaryAnimation,
                            secondaryAnimation: secondaryAnimation,
                            transitionType: SharedAxisTransitionType.horizontal,
                            child: child,
                          ),
                        ),
                      ),
                      currentIndex == 2
                          ? Container(
                              height: MediaQuery.of(context).size.height,
                              color: AppColors.alertBg.withOpacity(0.5),
                            )
                          : Container(),
                    ],
                  ),
                  bottomNavigationBar: Transform.translate(
                    offset: const Offset(0, -13),
                    child: Container(
                      height: _isVisible ? 51 : 0,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 5,
                      ),
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: MyBorderShape(),
                        shadows: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            blurRadius: 2.0,
                            offset: Offset(1, 1),
                          )
                        ],
                      ),
                      child: Row(
                        // mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              prevIndex = currentIndex;
                              currentIndex = 0;
                              feedCubit!.onRefresh();
                              feedCubit!
                                  .changeCurrentPage(const ScreenType.home());
                            },
                            child:
                                AppIcons.homeIcon(screenType: snapshot.data!),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 0, right: 5),
                            child: SizedBox(
                              height: 26,
                              width: 26,
                              child: InkWell(
                                onTap: () {
                                  // PushNotificationHelper.isMessageShow = false;
                                  isMessageShow = false;
                                  AC.prefs.setBool("message", false);
                                  prevIndex = currentIndex;
                                  currentIndex = 1;
                                  feedCubit!.changeCurrentPage(
                                      const ScreenType.message());
                                  setState(() {});
                                },
                                child: Padding(
                                  padding: EdgeInsets.only(top: 4),
                                  child: Stack(
                                    children: [
                                      AppIcons.messageIcon(
                                          screenType: snapshot.data!),
                                      Positioned(
                                        left: !context.isArabic() ? 40 : 0,
                                        right: context.isArabic() ? 40 : 0,
                                        child: Container(
                                          height: 5,
                                          width: 5,
                                          child: isMessageShow!
                                              ? Container(
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: AppColors.bottomMenu,
                                                    shape: BoxShape.circle,
                                                  ),
                                                )
                                              : Container(),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              left: !context.isArabic() ? 40 : 0,
                              right: context.isArabic() ? 40 : 0,
                            ),
                            child: SizedBox(
                              height: 26,
                              width: 26,
                              child: InkWell(
                                onTap: () {
                                  isNotificationShow = false;
                                  AC.prefs.setBool("notification", false);
                                  prevIndex = currentIndex;
                                  currentIndex = 3;
                                  feedCubit!.changeCurrentPage(
                                    const ScreenType.notification(),
                                  );
                                  setState(() {});
                                },
                                child: Padding(
                                  padding: EdgeInsets.only(top: 4),
                                  child: Stack(
                                    children: [
                                      AppIcons.notificationIcon(
                                          screenType: snapshot.data!),
                                      Positioned(
                                        right: !context.isArabic() ? 3 : null,
                                        top: 0,
                                        left: context.isArabic() ? 3 : null,
                                        child: Container(
                                          height: 5,
                                          width: 5,
                                          child: isNotificationShow!
                                              ? Container(
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Colors.purple,
                                                    shape: BoxShape.circle,
                                                  ),
                                                )
                                              : Container(),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              prevIndex = currentIndex;
                              currentIndex = 4;
                              feedCubit!.changeCurrentPage(
                                const ScreenType.search(),
                              );
                            },
                            child:
                                AppIcons.searchIcon(screenType: snapshot.data!),
                          ),
                        ],
                      ),
                    ),
                  ),
                  floatingActionButton: isKeyBoardShow
                      ? Container()
                      : Transform.translate(
                          offset: const Offset(0, -22),
                          child: Container(
                            // height: 65,
                            padding: EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: Colors.purple.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: FloatingActionButton(
                              backgroundColor: AppColors.bottomMenu,
                              onPressed: () {
                                Navigator.of(context).push(
                                  PageRouteBuilder(
                                    opaque: true,
                                    pageBuilder:
                                        (BuildContext context, _, __) =>
                                            RedeemConfirmationScreen(
                                      backRefresh: () {
                                        // prevIndex=currentIndex;
                                        // currentIndex = index;
                                        feedCubit!.onRefresh();
                                        // widget.backRefresh();
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                );

                                setState(() {});
                              },
                              child: currentIndex == 2
                                  ? Icon(Icons.close, size: 20)
                                  : AppIcons.newPostIcon,
                              elevation: 2.0,
                            ),
                          ),
                        ),
                  floatingActionButtonLocation:
                      FloatingActionButtonLocation.centerDocked,
                ),
              );
            }),
      ),
    );
  }

  Widget getHomeWidget() {
    return RefreshIndicator(
      onRefresh: () {
        feedCubit!.onRefresh();
        feedCubit!.getUserData();
        return Future.value();
      },
      child: Scrollbar(
        child: CustomScrollView(
          slivers: [
            // StoriesWidget(),
            SliverToBoxAdapter(),
            PostPaginationWidget(
              isComeHome: true,
              pagingController: feedCubit!.pagingController,
              onTapLike: feedCubit!.likeUnlikePost,
              onTapRepost: feedCubit!.repost,
              onOptionItemTap: (PostOptionsEnum postOptionsEnum, int index) =>
                  feedCubit!
                      .onOptionItemSelected(context, postOptionsEnum, index),
            )
          ],
        ),
      ),
    );
  }

  onTapBottomBar(int index) {
    if (index == 0) {
      currentIndex = 0;
      feedCubit!.changeCurrentPage(const ScreenType.home());
    } else if (index == 1) {
      currentIndex = 1;
      feedCubit!.changeCurrentPage(const ScreenType.message());
    } else if (index == 2) {
      currentIndex = 2;
      feedCubit!.changeCurrentPage(const ScreenType.notification());
    } else {
      currentIndex = 3;
      feedCubit!.changeCurrentPage(const ScreenType.search());
    }
  }

  Widget getSelectedHomeScreen(ScreenType data) {
    return data.when(
      home: getHomeWidget,
      message: () => MessageScreen(),
      notification: () => NotificationScreen(),
      search: () => searScreen,
      profile: (args) => ProfileScreen(
          otherUserId: args.otherUserId,
          profileUrl: args.profileUrl,
          coverUrl: args.coverUrl,
          profileNavigationEnum: args.profileNavigationEnum),
      settings: (args) => SettingsScreen(
        fromProfile: args,
      ),
      bookmarks: () => BlocProvider.value(
        value: feedCubit!,
        child: BookMarkScreen(),
      ),
    );
  }

  bool doReverse() {
    if (prevIndex == currentIndex) return false;
    return currentIndex < prevIndex;
  }

  appBarShow(ScreenType? data) {
    // && currentIndex != 2
    return data == const ScreenType.home()
        ? AppBar(
            elevation: 0.0,
            systemOverlayStyle: SystemUiOverlayStyle.light,
            actions: [
              currentIndex == 2
                  ? IconButton(
                      icon:
                          Icon(Icons.close, color: AppColors.alertBg, size: 30),
                      onPressed: () {},
                    )
                  : Container()
            ],
            leading: Padding(
              padding: EdgeInsets.all(5),
              child: StreamBuilder<ProfileEntity>(
                stream: feedCubit!.drawerEntity,
                builder: (
                  BuildContext context,
                  AsyncSnapshot<ProfileEntity> snapshot,
                ) {
                  if (snapshot.data == null)
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Images.showFollowing.toSvg(),
                    );
                  return snapshot.data!.profileUrl!
                      .toRoundNetworkImage(radius: 15);
                },
              ).onTapWidget(() {
                scaffoldKey.currentState!.openDrawer();
              }).toPadding(context.isArabic() ? 10 : 4),
            ),
            backgroundColor: Colors.white,
            title: AppIcons.appLogo.toContainer(height: 35, width: 35),
            centerTitle: true,
          )
        : null;
  }
}
