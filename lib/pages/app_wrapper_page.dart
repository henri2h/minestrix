import 'package:flutter/material.dart';

import 'package:auto_route/auto_route.dart';

import 'package:minestrix/partials/home/notificationView.dart';
import 'package:minestrix/partials/navbar.dart';
import 'package:minestrix_chat/utils/matrix_widget.dart';

class AppWrapperPage extends StatefulWidget {
  const AppWrapperPage({Key? key}) : super(key: key);

  @override
  State<AppWrapperPage> createState() => _AppWrapperPageState();
}

class _AppWrapperPageState extends State<AppWrapperPage> {
  Future<void>? loadFuture;

  Future<void> load() async {
    final m = Matrix.of(context).client;
    await m.roomsLoading;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    loadFuture ??= load();

    Matrix.of(context).navigatorContext = context;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth > 800;
          return Column(
            children: [
              if (isWideScreen) NavBarDesktop(),
              Expanded(child: AutoRouter()),
            ],
          );
        }),
      ),
      endDrawer: NotificationView(),
    );
  }
}
