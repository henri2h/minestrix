import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:minestrix_chat/minestrix_chat.dart';
import 'package:minestrix_chat/utils/matrix_widget.dart';

import '../../router.gr.dart';

class MinestrixNavigationRailItem {
  final Widget icon;
  final Widget label;
  final String path;
  final void Function(BuildContext) onDestinationSelected;

  MinestrixNavigationRailItem(
      {required this.icon,
      required this.label,
      required this.path,
      required this.onDestinationSelected});
}

class MinestrixNavigationRail extends StatefulWidget {
  const MinestrixNavigationRail({
    Key? key,
    required this.path,
  }) : super(key: key);

  final String path;
  @override
  State<MinestrixNavigationRail> createState() =>
      _MinestrixNavigationRailState();
}

class _MinestrixNavigationRailState extends State<MinestrixNavigationRail> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final client = Matrix.of(context).client;

    final items = [
      MinestrixNavigationRailItem(
          icon: const Icon(Icons.home),
          label: const Text("Feed"),
          path: "",
          onDestinationSelected: (BuildContext context) {
            context.navigateTo(const FeedRoute());
          }),
      MinestrixNavigationRailItem(
          icon: const Icon(Icons.person),
          label: const Text("My account"),
          path: "user_feed",
          onDestinationSelected: (BuildContext context) async {
            await context.navigateTo(
                UserViewRoute(userID: Matrix.of(context).client.userID));
          }),
      MinestrixNavigationRailItem(
          icon: const Icon(Icons.event),
          label: const Text("Event"),
          path: "events",
          onDestinationSelected: (BuildContext context) async {
            context.navigateTo(const CalendarEventListRoute());
          }),
      MinestrixNavigationRailItem(
          icon: const Icon(Icons.groups),
          label: const Text("Communities"),
          path: "community",
          onDestinationSelected: (BuildContext context) async {
            context.navigateTo(const CommunityRoute());
          }),
      MinestrixNavigationRailItem(
          icon: const Icon(Icons.people),
          label: const Text("Feeds"),
          path: "feeds",
          onDestinationSelected: (BuildContext context) async {
            context.navigateTo(const FeedListRoute());
          }),
      MinestrixNavigationRailItem(
          icon: StreamBuilder(
              stream: client.onSync.stream,
              builder: (context, _) {
                int notif = client.chatNotificationsCount;
                if (notif == 0) {
                  return const Icon(Icons.message_outlined);
                } else {
                  return Badge.count(
                      count: notif, child: const Icon(Icons.message));
                }
              }),
          label: const Text("Chat"),
          path: "chat",
          onDestinationSelected: (BuildContext context) async {
            context.navigateTo(const TabChatRoute());
          }),
      MinestrixNavigationRailItem(
          icon: const Icon(Icons.settings),
          label: const Text("Settings"),
          path: "settings",
          onDestinationSelected: (BuildContext context) async {
            context.navigateTo(const SettingsRoute());
          }),
    ];

    var selectedIndex = items.indexWhere((element) {
      final list = widget.path.split("/");
      if (list.length > 1) {
        if (list[1] == element.path) return true;
      }
      return false;
    });

    if (selectedIndex < 0 || selectedIndex >= items.length) selectedIndex = 0;

    return NavigationRail(
      // https://m3.material.io/components/navigation-rail/specs
      extended: expanded,
      labelType: NavigationRailLabelType.all,
      onDestinationSelected: (pos) => items[pos].onDestinationSelected(context),
      destinations: [
        ...items
            .map((e) => NavigationRailDestination(
                icon: e.icon, label: e.label, padding: const EdgeInsets.all(6)))
            .toList()
      ],

      selectedIndex: selectedIndex,
    );
  }
}
