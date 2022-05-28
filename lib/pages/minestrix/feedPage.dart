import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';

import 'package:minestrix/partials/components/quickLinksList.dart';
import 'package:minestrix/partials/feed/minestrixFeed.dart';
import 'package:minestrix/partials/home/rightbar.dart';
import 'package:minestrix_chat/utils/matrix_widget.dart';
import 'package:minestrix/utils/minestrix/minestrix_notifications.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({Key? key}) : super(key: key);

  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  @override
  Widget build(BuildContext context) {
    Client client = Matrix.of(context).client;

    return LayoutBuilder(builder: (context, constraints) {
      return StreamBuilder(
        stream: client.onMinestrixUpdate,
        builder: (context, _) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (constraints.maxWidth > 900)
                Flexible(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Text("Groups",
                                style: TextStyle(
                                    fontSize: 22, letterSpacing: 1.1)),
                          ),
                          Expanded(child: QuickLinksBar())
                        ],
                      ),
                    )),
              Flexible(
                flex: 12,
                child: Container(
                    constraints: BoxConstraints(maxWidth: 680),
                    child: MinestrixFeed()),
              ),
              if (constraints.maxWidth > 900)
                Flexible(
                  flex: 4,
                  fit: FlexFit.loose,
                  child: RightBar(),
                ),
            ],
          );
        },
      );
    });
  }
}
