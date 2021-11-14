import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:minestrix/components/accountCard.dart';
import 'package:minestrix/components/minesTrix/MinesTrixTitle.dart';
import 'package:minestrix/utils/matrixWidget.dart';
import 'package:minestrix/utils/minestrix/minestrixClient.dart';
import 'package:minestrix/utils/minestrix/minestrixRoom.dart';

class UserFriendsPage extends StatelessWidget {
  const UserFriendsPage({Key? key, required this.sroom}) : super(key: key);

  final MinestrixRoom sroom;

  @override
  Widget build(BuildContext context) {
    MinestrixClient? sclient = Matrix.of(context).sclient;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: H2Title((sroom.user.displayName ?? 'user') + " friends"),
        ),
        Wrap(alignment: WrapAlignment.spaceBetween, children: [
          for (User user in sroom.room.getParticipants().where((User u) =>
              u.membership == Membership.join &&
              u.id != sclient!.userID &&
              u.id != sroom.user.id))
            AccountCard(user: user),
        ]),
      ],
    );
  }
}