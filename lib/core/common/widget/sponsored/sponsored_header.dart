import 'package:auto_route/src/router/auto_router_x.dart';
import 'package:colibri/core/constants/appconstants.dart';
import 'package:colibri/core/extensions/widget_extensions.dart';
import 'package:colibri/core/routes/routes.gr.dart';
import 'package:colibri/core/theme/app_icons.dart';
import 'package:colibri/core/theme/colors.dart';
import 'package:colibri/extensions.dart';
import 'package:colibri/features/feed/domain/entity/post_entity.dart';
import 'package:colibri/translations/locale_keys.g.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SponsoredHeader extends StatelessWidget {
  const SponsoredHeader({Key? key, required this.advertisementEntity})
      : super(key: key);

  final AdvertisementEntity? advertisementEntity;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        [
          Padding(
            padding: EdgeInsets.only(
              right: !context.isArabic() ? 10 : 0,
              left: context.isArabic() ? 10 : 0,
            ),
            child: advertisementEntity!.advertiserProfileUrl!
                .toRoundNetworkImage(radius: 11)
                .onTapWidget(
              () {
                navigateToProfile(context);
              },
            ),
          ),
        ].toRow(mainAxisAlignment: MainAxisAlignment.start),
        [
          [
            [
              RichText(
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                maxLines: 1,
                strutStyle: StrutStyle.disabled,
                textWidthBasis: TextWidthBasis.longestLine,
                text: TextSpan(
                  text: advertisementEntity!.advertiserName,
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
                  .toVisibility(advertisementEntity!.isVerified),
              5.toSizedBoxHorizontal,
              Padding(
                padding: EdgeInsets.only(top: 2),
                child: Text(
                  advertisementEntity!.time!,
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
          if (advertisementEntity!.advertiserUsername != null)
            GestureDetector(
              onTap: () => navigateToProfile(context),
              child: Text(
                advertisementEntity!.advertiserUsername!,
                style: TextStyle(
                  color: const Color(0xFF737880),
                  fontSize: AC.getDeviceHeight(context) * 0.015,
                  fontWeight: FontWeight.w400,
                  fontFamily: "CeraPro",
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          InkWell(
            onTap: () {
              navigateToProfile(context);
            },
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: Text(
                    '${LocaleKeys.sponsored_by.tr()}',
                    style: TextStyle(
                      color: const Color(0xFF737880),
                      fontSize: AC.getDeviceHeight(context) * 0.015,
                      fontWeight: FontWeight.w400,
                      fontFamily: "CeraPro",
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                SizedBox(width: 2),
                '${advertisementEntity!.adWebsite}'.toSubTitle1(
                  (link) => launch(link),
                  color: const Color(0xFF737880),
                  fontSize: AC.getDeviceHeight(context) * 0.015,
                  fontWeight: FontWeight.w400,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ]
            .toColumn(mainAxisAlignment: MainAxisAlignment.center)
            .toExpanded(flex: 8),
      ],
    ).toHorizontalPadding(20);
  }

  void navigateToProfile(BuildContext context) {
    context.router.root.push(
      ProfileScreenRoute(
        otherUserId: advertisementEntity!.advertiserUsername!.split("@")[0],
      ),
    );
  }
}
