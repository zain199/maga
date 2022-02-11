import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:colibri/features/messages/presentation/widgets/send_message_row.dart';
import '../../../../core/routes/routes.gr.dart';
import '../../domain/entity/message_entity.dart';
import '../../../../translations/locale_keys.g.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import '../../../../core/common/push_notification/push_notification_helper.dart';
import '../../../../core/common/uistate/common_ui_state.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../extensions.dart';
import '../../../feed/presentation/widgets/no_data_found_screen.dart';
import '../../data/models/request/delete_chat_request_model.dart';
import '../../domain/entity/chat_entity.dart';
import '../bloc/chat_cubit.dart';
import '../widgets/reviever_chat_item.dart';
import '../widgets/sender_chat_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:easy_localization/easy_localization.dart';

class ChatScreen extends StatefulWidget {
  final String? otherPersonUserId;
  final String? otherUserFullName;
  final String? otherPersonProfileUrl;
  final MessageEntity? entity;
  const ChatScreen({
    Key? key,
    this.otherPersonUserId,
    this.otherUserFullName,
    this.otherPersonProfileUrl,
    this.entity,
  }) : super(key: key);
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with AutomaticKeepAliveClientMixin {
  ChatCubit? chatCubit;
  bool chatCleared = false;
  bool chatDeleted = false;
  @override
  void initState() {
    super.initState();
    chatCubit = getIt<ChatCubit>()
      ..chatPagination!.userId = widget.otherPersonUserId;
    chatCubit!.chatPagination!.searchChat = false;
    PushNotificationHelper.listenNotificationOnChatScreen = (notificationItem) {
      chatCubit!.changeMessageList(
          chatCubit!.chatPagination!.pagingController.itemList!
            ..insert(0, notificationItem));
      chatCubit!.chatPagination!.pagingController;
    };
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    context.initScreenUtil();
    return WillPopScope(
      onWillPop: () async {
        navigateToBackWithResult();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: GestureDetector(
            onTap: () => navigateToBackWithResult(),
            child: Icon(
              Icons.arrow_back,
              color: Colors.grey,
            ),
          ),
          elevation: 0.0,
          backgroundColor: Colors.white,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              widget.otherUserFullName!.toSubTitle1(
                (url) => context.router.root.push(WebViewScreenRoute(url: url)),
                color: const Color(0xFF3D4146),
                fontWeight: FontWeight.w700,
                fontFamily1: 'CeraPro',
              ),
              AppIcons.verifiedIcons
                  .toVisibility(
                      widget.entity == null ? false : widget.entity!.isVerified)
                  .toHorizontalPadding(4),
            ],
          ),
          actions: [
            Padding(
              padding: EdgeInsets.only(
                right: context.isArabic() ? 0 : 8.0,
                left: !context.isArabic() ? 0 : 8.0,
              ),
              child: GestureDetector(
                onTap: () => bottomSheet(context),
                child: Icon(
                  Icons.more_horiz,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
          centerTitle: true,
        ),
        body: Column(
          children: [
            BlocConsumer<ChatCubit, CommonUIState>(
              bloc: chatCubit,
              listener: (BuildContext context, state) {
                state.maybeWhen(
                    orElse: () {},
                    success: (s) {
                      if (s is String) {
                        if (s
                            .toLowerCase()
                            .contains(LocaleKeys.clear_chat.tr()))
                          chatCleared = true;
                        else if (s
                            .toLowerCase()
                            .contains(LocaleKeys.delete_chat.tr())) {
                          chatDeleted = true;
                          navigateToBackWithResult();
                        }
                        context.showSnackBar(message: s);
                      }
                    },
                    error: (e) =>
                        context.showSnackBar(isError: true, message: e));
              },
              builder: (c, state) {
                return state.maybeWhen(
                  orElse: () => buildRefreshIndicator().toExpanded(),
                  success: (s) => buildRefreshIndicator().toExpanded(),
                  error: (e) => buildRefreshIndicator().toExpanded(),
                );
              },
            ),
            SendMessageRow(
              chatCubit: chatCubit,
              otherPersonUserId: widget.otherPersonUserId,
            ),
          ],
        ),

        //        MessagesFloatingSearchBar(chatCubit),
      ),
    );
  }

  Widget buildRefreshIndicator() {
    return RefreshIndicator(
      onRefresh: () {
        chatCubit!.chatPagination!.searchChat = false;
        chatCubit!.chatPagination!.onRefresh();
        return Future.value();
      },
      child: Column(
        children: [
          Expanded(
            child: PagedListView(
              reverse: true,
              pagingController: chatCubit!.chatPagination!.pagingController,
              builderDelegate: PagedChildBuilderDelegate<ChatEntity>(
                noItemsFoundIndicatorBuilder: (i) => NoDataFoundScreen(
                  onTapButton: () {
                    // context.router.root.push(Routes.createPost);
                  },
                  title: LocaleKeys.no_messages.tr(),
                  buttonText: LocaleKeys.go_to_the_homepage.tr(),
                  message: "",
                  buttonVisibility: false,
                ),
                itemBuilder: (BuildContext context, item, int index) =>
                    Container(
                  width: context.getScreenWidth as double?,
                  child: item.isSender
                      ? SenderChatItem(chatEntity: item, chatCubit: chatCubit)
                      : ReceiverChatItem(
                          otherUserProfileUrl: widget.otherPersonProfileUrl,
                          chatEntity: item,
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void navigateToBackWithResult() {
    if (chatDeleted) {
      context.router.root.pop("deleted");
    } else if (chatCleared) {
      context.router.root.pop("cleared");
    } else
      context.router.root.pop(chatCubit!.getLastMessage());
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    PushNotificationHelper.listenNotificationOnChatScreen = null;
    super.dispose();
  }

  bottomSheet(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
              height: context.getScreenHeight * .2,
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
                    decoration:  BoxDecoration(
                      color:  Colors.purple[900],
                      borderRadius: BorderRadius.all(
                        Radius.circular(5),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () async {
                            (await showAnimatedDialog(
                              context: context,
                              barrierDismissible: true,
                              animationType: DialogTransitionType.size,
                              curve: Curves.fastOutSlowIn,
                              duration: const Duration(seconds: 1),
                              builder: (_) => AlertDialog(
                                title: LocaleKeys.please_confirm_your_actions
                                    .tr()
                                    .toSubTitle1(
                                        (url) => context.router.root
                                            .push(WebViewScreenRoute(url: url)),
                                        fontWeight: FontWeight.bold),
                                content: LocaleKeys
                                    .do_you_want_to_delete_this_chat_with_please_note_that_this_action
                                    .tr(namedArgs: {
                                  '@interloc_name@': widget.otherUserFullName!
                                }).toSubTitle1(
                                  (url) => context.router.root
                                      .push(WebViewScreenRoute(url: url)),
                                ),
                                actions: <Widget>[
                                  LocaleKeys.cancel
                                      .tr()
                                      .toButton()
                                      .toFlatButton(
                                    () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  LocaleKeys.yes.tr().toButton().toFlatButton(
                                        () async => await deleteMethod(true),
                                      )
                                ],
                              ),
                            ));
                          },
                          child: Container(
                            height: 25,
                            margin: const EdgeInsets.only(top: 30),
                            child: Row(
                              children: [
                                AppIcons.deleteOption(
                                  color: Colors.white,
                                  height: 20,
                                  width: 20,
                                ),
                                const SizedBox(width: 20),
                                Text(
                                  LocaleKeys.delete_chat.tr(),
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
                          onTap: () async {
                            (await showAnimatedDialog(
                              context: context,
                              barrierDismissible: true,
                              animationType: DialogTransitionType.size,
                              curve: Curves.fastOutSlowIn,
                              duration: const Duration(seconds: 1),
                              builder: (_) => AlertDialog(
                                title: LocaleKeys.please_confirm_your_actions
                                    .tr()
                                    .toSubTitle1(
                                        (url) => context.router.root
                                            .push(WebViewScreenRoute(url: url)),
                                        fontWeight: FontWeight.bold),
                                content: LocaleKeys
                                    .are_you_sure_you_want_to_delete_all_messages_in_the_chat_with_ple
                                    .tr(
                                  namedArgs: {
                                    '@interloc_name@': widget.otherUserFullName!
                                  },
                                ).toSubTitle2(),
                                actions: <Widget>[
                                  LocaleKeys.cancel
                                      .tr()
                                      .toButton()
                                      .toFlatButton(
                                    () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  LocaleKeys.yes.tr().toButton().toFlatButton(
                                        () async => await deleteMethod(false),
                                      )
                                ],
                              ),
                            ));
                          },
                          child: Container(
                            height: 25,
                            margin: const EdgeInsets.only(top: 30),
                            child: Row(
                              children: [
                                AppIcons.clearChatIcon,
                                const SizedBox(width: 25),
                                Text(
                                  LocaleKeys.clear_chat.tr(),
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
                      ],
                    ),
                  )
                ],
              ),
            ));
  }

  Future<void> deleteMethod(bool deleteAndClear) async {
    Navigator.pop(context);
    Navigator.pop(context);
    await chatCubit!.deleteAllMessages(
      DeleteChatRequestModel(
        deleteChat: deleteAndClear,
        userId: widget.otherPersonUserId,
      ),
    );
    chatDeleted = deleteAndClear;
    navigateToBackWithResult();
  }
}
