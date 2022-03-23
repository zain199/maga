import '../../../../core/extensions/context_exrensions.dart';
import '../../../../core/extensions/widget_extensions.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/images.dart';
import '../../../../core/widgets/media_picker.dart';
import '../../../feed/presentation/widgets/create_post_card.dart';
import '../bloc/chat_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SendMessageRow extends StatelessWidget {
  const SendMessageRow({
    Key? key,
    required this.chatCubit,
    required this.otherPersonUserId,
  }) : super(key: key);
  final ChatCubit? chatCubit;
  final String? otherPersonUserId;
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFECF1F6),
                borderRadius: BorderRadius.circular(40),
              ),
              child: TextField(
                onChanged: chatCubit!.message.onChange,
                controller: chatCubit!.message.textController,
                // style: AppTheme.button.copyWith(fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  hintText: 'Type Something...',
                  contentPadding: const EdgeInsets.all(16),
                  border: InputBorder.none,
                  hintStyle: context.subTitle2,
                  labelStyle:
                      AppTheme.caption.copyWith(fontWeight: FontWeight.bold),
                  suffixIcon: AppIcons.imageIcon(
                    enabled: true,
                    color: Color(0xFF737880),
                  ).toPadding(14).onTapWidget(() async {
                    await openMediaPicker(context, (image) async {
                      chatCubit!.sendImage(image, otherPersonUserId);
                    }, mediaType: MediaTypeEnum.IMAGE);
                  }),
                ),
              )),
        ),
        SvgPicture.asset(
          Images.sendIcon,
          height: 24,
          color: AppColors.colorPrimary,
        ).toHorizontalPadding(12).onTapWidget(() async {
          if (chatCubit!.message.text.trim().isNotEmpty) {
            chatCubit!.sendMessage(otherPersonUserId);
            chatCubit!.message.textController.clear();
          } else {
            context.showSnackBar(
                message: "Please enter a valid text", isError: true);
          }
        }, removeFocus: false),
      ],
    ).toPadding(8);
  }
}
