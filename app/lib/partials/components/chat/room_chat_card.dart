import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:minestrix_chat/pages/room_page.dart';

import '../minestrix/minestrix_title.dart';

class RoomChatCard extends StatelessWidget {
  const RoomChatCard({
    Key? key,
    required this.room,
  }) : super(key: key);

  final Room room;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const H2Title("Chat"),
          Expanded(
            child: Container(
              color: Theme.of(context).cardColor,
              child: RoomPage(roomId: room.id, client: room.client),
            ),
          ),
        ],
      ),
    );
  }
}
