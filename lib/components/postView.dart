import 'package:famedlysdk/famedlysdk.dart';
import 'package:flutter/material.dart';
import 'package:minestrix/global/matrix.dart';
import 'package:timeago/timeago.dart' as timeago;

class Post extends StatefulWidget {
  Post({Key key, @required this.event}) : super(key: key);
  final Event event;

  @override
  _PostState createState() => _PostState();
}

class _PostState extends State<Post> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        elevation: 10,
        borderRadius: BorderRadius.circular(5),
        child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
            ),
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                PostHeader(event: widget.event),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: PostContent(widget.event),
                ),
                PostFooter(event: widget.event),
              ],
            )),
      ),
    );
  }
}

class PostFooter extends StatelessWidget {
  const PostFooter({Key key, this.event}) : super(key: key);
  final Event event;
  @override
  Widget build(BuildContext context) {
    return Row(
        children: <Widget>[FlatButton(child: Text("react"), onPressed: () {})]);
  }
}

class PostHeader extends StatelessWidget {
  const PostHeader({Key key, this.event}) : super(key: key);
  final Event event;
  @override
  Widget build(BuildContext context) {
    final Client client = Matrix.of(context).client;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundImage: event.sender.avatarUrl == null
                    ? null
                    : NetworkImage(
                        event.sender.avatarUrl.getThumbnail(
                          client,
                          width: 64,
                          height: 64,
                        ),
                      ),
              ),
            ),
            Text(event.sender.displayName,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(" to ", style: TextStyle(fontSize: 20)),
            Text(event.room.name,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ]),
        ),
        Row(
          children: [
            Text(timeago.format(event.originServerTs),
                style: TextStyle(fontWeight: FontWeight.bold)),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.enhanced_encryption),
            ),
          ],
        )
      ],
    );
  }
}

class PostContent extends StatelessWidget {
  const PostContent(
    this.event, {
    Key key,
  }) : super(key: key);
  final Event event;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(event.body),
          ]),
    );
  }
}
