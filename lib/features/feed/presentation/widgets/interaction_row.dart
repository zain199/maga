import 'package:auto_route/src/router/auto_router_x.dart';
import 'package:colibri/core/extensions/context_exrensions.dart';
import 'package:colibri/core/extensions/string_extensions.dart';
import 'package:colibri/core/extensions/widget_extensions.dart';
import 'package:colibri/core/theme/app_icons.dart';
import 'package:colibri/core/theme/colors.dart';
import 'package:colibri/core/theme/images.dart';
import 'package:colibri/features/feed/domain/entity/post_entity.dart';
import 'package:flutter/material.dart';

class InteractionRow extends StatefulWidget {
  const InteractionRow({
    Key? key,
    required this.onClickAction,
    required this.postEntity,
    required this.setStateFun,
  }) : super(key: key);
  final Function onClickAction;
  final PostEntity? postEntity;
  final Function setStateFun;
  @override
  State<InteractionRow> createState() => _InteractionRowState();
}

class _InteractionRowState extends State<InteractionRow> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        InkWell(
          onTap: () {
            widget.onClickAction(0);
            Future.delayed(Duration(milliseconds: 300), () {
              widget.setStateFun();
            });
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 0),
                child: Images.comment.toSvg(
                  height: 14,
                  width: 14,
                  color: Colors.white,
                ),
              ),
              Padding(
                padding: context.isArabic()
                    ? const EdgeInsets.only(bottom: 0, right: 5)
                    : const EdgeInsets.only(bottom: 0, left: 5),
                child: Text(
                  widget.postEntity?.commentCount ?? "0",
                  style: const TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontFamily: "CeraPro",
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                  ),
                ),
              )
            ],
          ),
        ),
        InkWell(
          onTap: () {
            widget.onClickAction(1);
            Future.delayed(Duration(milliseconds: 300), () {
              widget.setStateFun();
            });
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 0),
                child: widget.postEntity?.isLiked ?? false
                    ? AppIcons.filledHeartIcon(height: 14, width: 14)
                    : AppIcons.heartIcon(
                        color: Colors.white, height: 17, width: 17),
              ),
              Padding(
                padding: context.isArabic()
                    ? const EdgeInsets.only(bottom: 0, right: 5)
                    : const EdgeInsets.only(bottom: 0, left: 5),
                child: Text(
                  widget.postEntity?.likeCount ?? "0",
                  style: TextStyle(
                    color: widget.postEntity?.isLiked ?? false
                        ? Colors.purple
                        : Color(0xFFFFFFFF),
                    fontFamily: "CeraPro",
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                  ),
                ),
              )
            ],
          ),
        ),
        InkWell(
          onTap: () {
            widget.onClickAction(2);
            Future.delayed(Duration(milliseconds: 300), () {
              context.router.root.pop();
              widget.setStateFun();
              // 456123
            });
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 0),
                child: widget.postEntity?.isReposted ?? false
                    ? AppIcons.repostIcon(
                        color: Colors.purple, height: 16, width: 16)
                    : AppIcons.repostIcon(
                        color: Colors.white, height: 16, width: 16),
              ),
              Padding(
                padding: context.isArabic()
                    ? const EdgeInsets.only(bottom: 0, right: 5)
                    : const EdgeInsets.only(bottom: 0, left: 5),
                child: Text(
                  widget.postEntity?.repostCount ?? "",
                  style: TextStyle(
                    color: widget.postEntity?.isReposted ?? false
                        ? AppColors.alertBg
                        : Color(0xFFFFFFFF),
                    fontFamily: "CeraPro",
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                  ),
                ),
              )
            ],
          ),
        ),
        AppIcons.shareIcon(color: Colors.white, height: 18, width: 18)
            .toPadding(0)
            .onTapWidget(() {
          widget.onClickAction(3);
          Future.delayed(Duration(milliseconds: 300), () {
            widget.setStateFun();
          });
        })
      ],
    );
  }
}
