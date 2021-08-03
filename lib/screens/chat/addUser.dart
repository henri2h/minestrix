import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:matrix/matrix.dart';
import 'package:minestrix/components/minesTrix/MinesTrixUserImage.dart';
import 'package:minestrix/global/smatrix.dart';
import 'package:minestrix/global/smatrix/SMatrixRoom.dart';
import 'package:minestrix/global/smatrixWidget.dart';

class FollowUser extends StatefulWidget {
  FollowUser(BuildContext context, {Key key}) : super(key: key);
  @override
  _FollowUserState createState() => _FollowUserState();
}

class _FollowUserState extends State<FollowUser> {
  List<Profile> profiles = [];

  @override
  Widget build(BuildContext context) {
    SClient sclient = Matrix.of(context).sclient;
    return Scaffold(
        appBar: AppBar(
          title: Text("Add users"),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.done))
          ],
        ),
        body: ListView(children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TypeAheadField(
              hideOnEmpty: true,
              textFieldConfiguration: TextFieldConfiguration(
                  autofocus: false,
                  decoration: InputDecoration(border: OutlineInputBorder())),
              suggestionsCallback: (pattern) async {
                var ur =
                    await sclient.searchUserDirectory(pattern);
                List<User> following = List<User>.empty();
                await sclient.following.forEach((key, SMatrixRoom sroom) {
                  following.add(sroom.user);
                });

                return ur.results
                    .where((element) =>
                        following.firstWhere(
                            (friend) => friend.id == element.userId,
                            orElse: () => null) ==
                        null)
                    .toList(); // exclude the users we are currently following
              },
              itemBuilder: (context, suggestion) {
                Profile profile = suggestion;
                return ListTile(
                  leading: profile.avatarUrl == null
                      ? Icon(Icons.person)
                      : MinesTrixUserImage(url: profile.avatarUrl),
                  title: Text(profile.displayName),
                  subtitle: Text(profile.userId),
                );
              },
              onSuggestionSelected: (suggestion) async {
                Profile p = suggestion;
                setState(() {
                  profiles.add(p);
                });
              },
            ),
          ),
          for (Profile p in profiles)
            ListTile(
                title: Text(p.displayName),
                leading: MinesTrixUserImage(url: p.avatarUrl, thumnail: true),
                subtitle: Text(p.userId)),
        ]));
  }
}