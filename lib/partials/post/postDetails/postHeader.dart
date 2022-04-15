import 'package:flutter/material.dart';

import 'package:auto_route/src/router/auto_router_x.dart';
import 'package:matrix/matrix.dart';
import 'package:minestrix_chat/partials/matrix_image_avatar.dart';
import 'package:minestrix_chat/utils/room_feed_extension.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:minestrix/router.gr.dart';
import 'package:minestrix/utils/matrixWidget.dart';
import 'package:minestrix/utils/minestrix/minestrixClient.dart';
import 'package:minestrix/utils/minestrix/minestrixRoom.dart';

class PostHeader extends StatelessWidget {
  final Event event;
  const PostHeader({Key? key, required this.event}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final MinestrixClient sclient = Matrix.of(context).sclient!;
    MinestrixRoom? sroom = sclient.srooms[event.roomId!];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: MatrixImageAvatar(
                      client: sclient,
                      url: event.sender.avatarUrl,
                      defaultText: event.sender.displayName ?? event.sender.id,
                      backgroundColor: Theme.of(context).primaryColor,
                      width: 48,
                      height: 48,
                      thumnail: true,
                      defaultIcon: Icon(Icons.person, size: 48)),
                ),
                if (sroom?.type != FeedRoomType.group)
                  Flexible(
                    child: Builder(builder: (BuildContext context) {
                      User? feedOwner =
                          event.room.getState("m.room.create")?.sender;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              TextButton(
                                style: TextButton.styleFrom(
                                    primary: Theme.of(context)
                                        .textTheme
                                        .bodyText1!
                                        .color),
                                onPressed: () {
                                  context.navigateTo(
                                      UserViewRoute(userID: event.senderId));
                                },
                                child: Text(
                                    (event.sender.displayName ??
                                        event.sender.id),
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold)),
                              ),
                              if (event.sender.id != feedOwner?.id)
                                Text("to",
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyText1!
                                            .color)),
                              if (event.sender.id != feedOwner?.id)
                                TextButton(
                                  style: TextButton.styleFrom(
                                      primary: Theme.of(context)
                                          .textTheme
                                          .bodyText1!
                                          .color),
                                  onPressed: () {
                                    context.navigateTo(
                                        UserViewRoute(userID: feedOwner?.id));
                                  },
                                  child: Text(
                                      (feedOwner?.displayName ??
                                          feedOwner?.id ??
                                          "null"),
                                      overflow: TextOverflow.clip,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400)),
                                ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(timeago.format(event.originServerTs),
                                style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    color: Theme.of(context)
                                        .textTheme
                                        .caption!
                                        .color)),
                          ),
                        ],
                      );
                    }),
                  ),
                if (sroom?.type == FeedRoomType.group)
                  Flexible(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {
                              context.navigateTo(
                                  UserViewRoute(userID: event.senderId));
                            },
                            child: Text(
                                (event.sender.displayName ?? event.sender.id),
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyText1!
                                        .color,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                          ),
                          Text("to",
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyText1!
                                      .color)),
                          TextButton(
                            onPressed: () {
                              MinestrixRoom? sroom =
                                  sclient.srooms[event.roomId];
                              if (sroom != null)
                                context.navigateTo(GroupRoute(sroom: sroom));
                            },
                            child: Text(event.room.name,
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyText1!
                                        .color,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400)),
                          ),
                        ],
                      ),
                      Text(timeago.format(event.originServerTs),
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              color:
                                  Theme.of(context).textTheme.caption!.color)),
                    ],
                  )),
              ],
            ),
          ),
        ),
        if (event.canRedact)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                PopupMenuButton<String>(
                    itemBuilder: (_) => [
                          /*if (event!.canRedact)
                            PopupMenuItem(
                                child: Row(
                                  children: [
                                    Icon(Icons.edit),
                                    SizedBox(width: 10),
                                    Text("Edit post"),
                                  ],
                                ),
                                value: "edit"),*/ // TODO : implement post editing
                          if (event.canRedact)
                            PopupMenuItem(
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: Colors.red),
                                    SizedBox(width: 10),
                                    Text("Delete post",
                                        style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                                value: "delete")
                        ],
                    icon: Icon(Icons.more_horiz),
                    onSelected: (String action) async {
                      switch (action) {
                        case "delete":
                          await event.redactEvent();
                          break;
                        default:
                      }
                    })
              ],
            ),
          )
      ],
    );
  }
}