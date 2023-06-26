import 'dart:async';

import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:minestrix_chat/utils/client_information.dart';

import '../../components/fake_text_field.dart';
import '../../matrix/matrix_image_avatar.dart';
import '../search/matrix_chats_search.dart';
import 'room_list_filter/room_list_filter.dart';

class RoomListSearchButton extends StatelessWidget {
  const RoomListSearchButton({
    Key? key,
    required this.client,
    required this.onSelection,
    required this.onUserTap,
  }) : super(key: key);

  final Client client;
  final Function(String p1) onSelection;
  final VoidCallback? onUserTap;

  @override
  Widget build(BuildContext context) {
    return FakeTextField(
        onPressed: () async {
          String? roomId = await MatrixChatsSearch.show(context, client);

          if (roomId != null) {
            onSelection(roomId);
          }
        },
        text: "Search",
        icon: Icons.search,
        trailing: IconButton(
          onPressed: onUserTap,
          padding: EdgeInsets.zero,
          icon: FutureBuilder(
              future: client.getProfileFromUserId(client.userID!),
              builder: (BuildContext context, AsyncSnapshot<Profile> p) {
                return p.data?.avatarUrl != null
                    ? Padding(
                        padding: const EdgeInsets.only(right: 2),
                        child: CircleAvatar(
                          radius: 19,
                          child: MatrixImageAvatar(
                              client: client,
                              url: p.data!.avatarUrl,
                              fit: true,
                              width: 34,
                              height: 34),
                        ),
                      )
                    : const Icon(Icons.person);
              }),
        ));
  }
}

class MobileSearchBar extends StatelessWidget {
  const MobileSearchBar({
    required this.client,
    required this.onAppBarClicked,
    super.key,
  });
  final Client client;
  final VoidCallback? onAppBarClicked;

  @override
  Widget build(BuildContext context) {
    final lastOpened = client.lastContacted();

    return SearchAnchor.bar(
      barHintText: "Search",
      barLeading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () {
          Scaffold.of(context).openDrawer();
        },
      ),
      onTap: () async {},
      barTrailing: [
        FutureBuilder(
            future: client.getProfileFromUserId(client.userID!),
            builder: (BuildContext context, AsyncSnapshot<Profile> p) {
              return IconButton(
                onPressed: onAppBarClicked,
                icon: CircleAvatar(
                  child: p.data?.avatarUrl != null
                      ? MatrixImageAvatar(
                          client: client, url: p.data!.avatarUrl)
                      : const Icon(Icons.person),
                ),
              );
            }),
      ],
      suggestionsBuilder: (BuildContext context, SearchController controller) {
        final s = StreamController<String>();

        return [
          RoomListFilter(client: client),
          if (controller.text.isNotEmpty != true)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Contacted recently"),
            ),
          if (controller.text.isNotEmpty != true)
            FutureBuilder<List<String>>(
                future: lastOpened,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final user in snapshot.data!)
                          Builder(builder: (context) {
                            final room = client.getRoomById(user);
                            final name = room?.getLocalizedDisplayname(
                                const MatrixDefaultLocalizations());
                            if (room != null) {
                              return Card(
                                child: InkWell(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(12.0)),
                                  onTap: () {
                                    Navigator.pop(context, room.id);
                                  },
                                  child: SizedBox(
                                    width: 90,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          MatrixImageAvatar(
                                            url: room.avatar,
                                            client: room.client,
                                            defaultText: name,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            name ?? "Room",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }
                            return Container();
                          })
                      ],
                    ),
                  );
                }),
          Divider()
        ];
        return [
          ListTile(title: Text("yes")),
          ListTile(title: Text("no")),
          ListTile(title: Text("maybe"))
        ];
      },
    );
  }
}
