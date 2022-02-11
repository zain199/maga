import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:colibri/core/extensions/color_extension.dart';
import 'package:colibri/core/theme/images.dart';
import 'package:colibri/translations/locale_keys.g.dart';
import 'package:easy_localization/src/public_ext.dart';
import '../../../../core/datasource/local_data_source.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/constants/appconstants.dart';
import '../bloc/chat_cubit.dart';
import '../../domain/entity/chat_entity.dart';
import 'package:flutter/material.dart';
import '../../../../extensions.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:flutter/services.dart';

@immutable
class SenderChatItem extends StatelessWidget {
  final ChatEntity? chatEntity;
  final ChatCubit? chatCubit;
  SenderChatItem({Key? key, this.chatEntity, this.chatCubit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _userData = getIt<LocalDataSource>().getUserData();

    return FractionallySizedBox(
      widthFactor: .9,
      alignment: Alignment.centerRight,
      child: Container(
        child: Wrap(
          alignment: WrapAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (chatEntity!.chatMediaType == ChatMediaType.TEXT)
                  Row(
                    children: [
                      [LocaleKeys.delete.tr()].toPopUpMenuButton(
                        (_) async {
                          await chatCubit!.deleteMessage(chatEntity!.messageId);
                          chatCubit!.chatPagination!.onRefresh();
                        },
                        icon: Icon(Icons.more_horiz, color: Colors.grey),
                        backGroundColor: Theme.of(context).errorColor,
                        textStyle: TextStyle(
                          fontFamily: 'CeraPro',
                          color: Theme.of(context).errorColor,
                        ),
                      ),
                      5.toSizedBoxHorizontal,
                      Expanded(
                        flex: 8,
                        child: GestureDetector(
                          onLongPress: () {
                            Clipboard.setData(ClipboardData(
                                text: parseHtmlString(chatEntity!.message!)));
                            context.showSnackBar(
                              message: 'Text Copied to Clipboard',
                              isError: false,
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.purple.shade600,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(
                                    !context.isArabic() ? 40 : 0),
                                bottomLeft: Radius.circular(40),
                                bottomRight: Radius.circular(40),
                                topRight: Radius.circular(
                                    context.isArabic() ? 40 : 0),
                              ),
                            ),
                            child: Container(
                              child: chatEntity!.message!
                                  .toCaption(
                                    color: Colors.grey.shade200,
                                    fontWeight: FontWeight.w600,
                                    linkColor: Colors.white,
                                  )
                                  .toPadding(16),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 5.0,
                            right: 5.0,
                            bottom: 20,
                          ),
                          child: _userData!.data!.user!.profilePicture!
                              .toRoundNetworkImage(radius: 10),
                        ),
                      ),
                    ],
                  )
                // ProfileUrl is the image sent url
                else if (chatEntity!.profileUrl!.isValidUrl)
                  Row(
                    children: [
                      ['Delete'].toPopUpMenuButton(
                        (_) async {
                          await chatCubit!.deleteMessage(chatEntity!.messageId);
                          chatCubit!.chatPagination!.onRefresh();
                        },
                        icon: Icon(Icons.more_horiz, color: Colors.grey),
                        backGroundColor: Theme.of(context).errorColor,
                        textStyle: TextStyle(
                          fontFamily: 'CeraPro',
                          color: Theme.of(context).errorColor,
                        ),
                      ).toExpanded(),
                      5.toSizedBoxHorizontal,
                      Expanded(
                        flex: 8,
                        child: CachedNetworkImage(
                          placeholder: (c, i) =>
                              const CircularProgressIndicator(),
                          imageUrl: chatEntity!.profileUrl!,
                        ).onTapWidget(
                          () {
                            showAnimatedDialog(
                              barrierDismissible: true,
                              alignment: Alignment.center,
                              context: context,
                              builder: (c) => Container(
                                color:
                                    HexColor.fromHex('#24282E').withOpacity(1),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    closeButton(context),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: 100.0),
                                        child: CachedNetworkImage(
                                          fit: BoxFit.scaleDown,
                                          placeholder: (c, i) => Center(
                                            child:
                                                const CircularProgressIndicator(),
                                          ),
                                          imageUrl: chatEntity!.profileUrl!,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  )
                else
                  Image.file(File(chatEntity!.profileUrl!)).onTapWidget(
                    () {
                      showAnimatedDialog(
                        barrierDismissible: true,
                        alignment: Alignment.center,
                        context: context,
                        builder: (c) => Container(
                          color: HexColor.fromHex('#24282E').withOpacity(1),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              closeButton(context),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 100.0),
                                  child: Image.file(
                                    File(
                                      chatEntity!.profileUrl!,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                5.toSizedBox,
                Padding(
                  padding: EdgeInsets.only(
                      right: chatEntity!.chatMediaType == ChatMediaType.TEXT
                          ? 70
                          : 20),
                  child: Text(
                    chatEntity!.time!,
                    style: TextStyle(
                      color: const Color(0xFF737880),
                      fontSize: AC.getDeviceHeight(context) * 0.013,
                      fontWeight: FontWeight.w600,
                      fontFamily: "CeraPro",
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ).toHorizontalPadding(16).toVerticalPadding(6),
    );
  }

  Widget closeButton(BuildContext context) {
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
