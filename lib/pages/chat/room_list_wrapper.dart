import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:minestrix_chat/utils/matrix_widget.dart';
import 'package:minestrix_chat/view/room_list/room_list_builder.dart';
import 'package:minestrix_chat/view/room_list/room_list_spaces_list.dart';
import 'package:minestrix_chat/view/room_list/room_list_widget.dart';
import 'package:provider/provider.dart';

import '../../router.gr.dart';

class RoomListWrapper extends StatefulWidget {
  const RoomListWrapper({Key? key}) : super(key: key);

  @override
  State<RoomListWrapper> createState() => RoomListWrapperState();
}

class RoomListWrapperState extends State<RoomListWrapper> {
  final scrollControllerSpaces = ScrollController();
  final scrollControllerDrawer = ScrollController();
  final scrollControllerRoomList = ScrollController();

  bool mobile = true;

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) => this,
      child: RoomList(
        client: Matrix.of(context).client,
        allowPop: false,
        onSelection: (String roomId) async {
          await context
              .navigateTo(RoomListRoomRoute(displaySettingsOnDesktop: true));
        },
        child: Scaffold(
            body: LayoutBuilder(builder: (context, constraints) {
              mobile = constraints.maxWidth < 800;
              return Row(
                children: [
                  if (!mobile)
                    Consumer<RoomListState>(
                        builder: (context, state, _) => SizedBox(
                            width: state.spaceListExpanded ? 230 : 60,
                            child: RoomListSpacesList(
                                mobile: false,
                                scrollController: scrollControllerSpaces))),
                  if (!mobile)
                    ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 360),
                        child: RoomListBuilder(
                          scrollController: scrollControllerRoomList,
                        )),
                  Expanded(child: AutoRouter()),
                ],
              );
            }),
            drawer: Drawer(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                child: SafeArea(
                  child: RoomListSpacesList(
                      mobile: true, scrollController: scrollControllerDrawer),
                ))),
      ),
    );
  }
}