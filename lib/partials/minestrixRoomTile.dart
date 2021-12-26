import 'package:auto_route/src/router/auto_router_x.dart';
import 'package:flutter/material.dart';
import 'package:matrix/src/utils/uri_extension.dart';
import 'package:minestrix/router.gr.dart';
import 'package:minestrix/utils/matrixWidget.dart';
import 'package:minestrix/utils/minestrix/minestrixClient.dart';
import 'package:minestrix/utils/minestrix/minestrixRoom.dart';
import 'package:minestrix_chat/helpers/text_helper.dart';
import 'package:minestrix_chat/partials/matrix_user_image.dart';

class ContactView extends StatelessWidget {
  const ContactView({
    Key? key,
    required this.sroom,
  }) : super(key: key);
  final MinestrixRoom sroom;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.0),
        ),
        child: TextButton(
          onPressed: () {
            context.navigateTo(UserFeedRoute(sroom: sroom));
          },
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Flexible(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      MatrixUserImage(
                        client: Matrix.of(context).sclient,
                        url: sroom.user.avatarUrl,
                        width: 32,
                        height: 32,
                        thumnail: true,
                        rounded: true,
                        defaultIcon: Icon(Icons.person, size: 32),
                      ),
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text((sroom.user.displayName ?? sroom.user.id),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyText1!
                                            .color)),
                                Text(
                                  sroom.user.id,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyText1!
                                          .color),
                                )
                              ]),
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
        ),
      ),
    );
  }
}

class MinestrixRoomTile extends StatelessWidget {
  const MinestrixRoomTile({
    Key? key,
    required this.sroom,
  }) : super(key: key);
  final MinestrixRoom sroom;
  @override
  Widget build(BuildContext context) {
    final MinestrixClient? client = Matrix.of(context).sclient;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: MaterialButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        onPressed: () {
          context.navigateTo(GroupRoute(sroom: sroom));
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Flexible(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      MatrixUserImage(
                        url: sroom.room.avatar,
                        fit: true,
                        defaultIcon: Text(TextHelper.getRoomInitial(sroom.name),
                            style: const TextStyle(
                                fontSize: 18, color: Colors.white)),
                        backgroundColor: Colors.blue,
                        thumnail: true,
                        width: 46,
                        height: 46,
                        client: client,
                      ),
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(sroom.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    )),
                                Text(
                                  sroom.roomType == SRoomType.UserRoom
                                      ? sroom.user.id
                                      : sroom.room.topic,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(),
                                )
                              ]),
                        ),
                      ),
                    ],
                  ),
                ),
                if (sroom.room.encrypted)
                  Icon(Icons.verified_user,
                      color: Theme.of(context).textTheme.bodyText1!.color),
                if (!sroom.room.encrypted)
                  Icon(Icons.no_encryption,
                      color: Theme.of(context).textTheme.bodyText1!.color)
              ]),
        ),
      ),
    );
  }
}
