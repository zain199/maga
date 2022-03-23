import '../../../../translations/locale_keys.g.dart';

import '../../../../core/di/injection.dart';
import '../../../../extensions.dart';
import '../bloc/notification_cubit.dart';
import 'mentions_page.dart';
import 'notification_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  NotificationCubit? _notificationCubit;

  @override
  void initState() {
    super.initState();
    _notificationCubit = getIt<NotificationCubit>();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (c) => _notificationCubit!,
      child: DefaultTabController(
        length: 2,
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverAppBar(
                  automaticallyImplyLeading: false,
                  leading: null,
                  elevation: 5.0,
                  expandedHeight: 60.toHeight as double?,
                  floating: true,
                  pinned: true,
                  backgroundColor: Colors.white,
                  bottom: PreferredSize(
                    preferredSize: Size(context.getScreenWidth as double,
                        56.toHeight as double),
                    child: Stack(
                      children: [
                        Container(
                          color: Colors.white,
                          child: TabBar(
                            tabs: [
                              Tab(text: LocaleKeys.notifications.tr()),
                              Tab(text: LocaleKeys.mentions.tr()),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverFillRemaining(
                  child: TabBarView(
                    children: [NotificationPage(), MentionsPage()],
                  ),
                )
              ],
            ).toSafeArea,
          ],
        ),
      ),
    );
  }
}
