import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:matrix/matrix.dart';
import 'package:minestrix/partials/components/layouts/customHeader.dart';
import 'package:minestrix/utils/matrixWidget.dart';
import 'package:minestrix/utils/minestrix/minestrixClient.dart';
import 'package:minestrix/utils/minestrix/minestrixRoom.dart';
import 'package:minestrix_chat/partials/matrix_user_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:minestrix_chat/utils/room_feed_extension.dart';

class PostEditorPage extends StatefulWidget {
  PostEditorPage({Key? key, this.sroom}) : super(key: key);
  final MinestrixRoom? sroom;
  @override
  _PostEditorPageState createState() => _PostEditorPageState();
}

class _PostEditorPageState extends State<PostEditorPage>
    with SingleTickerProviderStateMixin {
  FilePickerCross? file;

  TextEditingController _t = TextEditingController();
  bool _sending = false;

  MinestrixRoom? sroom;

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    MinestrixClient sclient = Matrix.of(context).sclient!;

    sroom = widget.sroom;
    if (sroom == null) sroom = sclient.userRoom;

    return SafeArea(
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            CustomHeader(
              "What's up ?",
              actionButton: [
                Card(
                  color: _t.text.isEmpty ? null : Colors.green,
                  child: IconButton(
                      icon: _sending
                          ? Center(
                              child: CircularProgressIndicator(
                                  color: Colors.white))
                          : Icon(Icons.send, color: Colors.white),
                      onPressed: _sending || _t.text.isEmpty
                          ? null
                          : () async {
                              setState(() {
                                _sending = true;
                              });

                              MatrixImageFile? f;
                              if (file != null)
                                f = MatrixImageFile(
                                    bytes: file!.toUint8List(),
                                    name: file!.fileName ?? 'null');

                              await sroom?.room.sendPost(_t.text, image: f);

                              setState(() {
                                _sending = false;
                              });
                              Navigator.of(context).pop();
                            }),
                )
              ],
            ),
            Expanded(
              child: Container(
                  padding: const EdgeInsets.all(8.0),
                  child: TabBarView(
                    children: [
                      ListView(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              MatrixUserImage(
                                  client: sclient,
                                  url: sroom!.room.avatar,
                                  defaultText: sroom!.room.topic,
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  width: 48,
                                  thumnail: true,
                                  height: 48),
                              SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Post on " + sroom!.name,
                                        style: TextStyle(fontSize: 22)),
                                    SizedBox(height: 4),
                                    Text(sroom!.room.topic)
                                  ],
                                ),
                              ),
                              Card(
                                child: IconButton(
                                    icon: Icon(Icons.add_a_photo),
                                    onPressed: () async {
                                      FilePickerCross f = await FilePickerCross
                                          .importFromStorage(
                                              type: FileTypeCross.image);
                                      setState(() {
                                        file = f;
                                      });
                                    }),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MatrixUserImage(
                                  client: sclient,
                                  url: sclient.userRoom!.user?.avatarUrl,
                                  defaultText:
                                      sclient.userRoom!.user?.displayName,
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  width: 48,
                                  thumnail: true,
                                  height: 48),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextField(
                                      minLines: 3,
                                      controller: _t,
                                      cursorColor: Colors.grey,
                                      //controller: _searchController,
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 15, horizontal: 12),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(15),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(15),
                                          ),
                                        ),
                                        prefixIcon: Icon(Icons.edit,
                                            color: Colors.grey),
                                        filled: true,
                                        hintStyle:
                                            TextStyle(color: Colors.grey),
                                        labelText: "Post content",
                                        labelStyle:
                                            TextStyle(color: Colors.grey),
                                        alignLabelWithHint: true,
                                        hintText: "Post content",
                                      ),
                                      keyboardType: TextInputType.multiline,
                                      maxLines: null,
                                      onChanged: (_) => setState(() {})),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      ListView(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("Post preview",
                                style: TextStyle(fontSize: 20)),
                          ),
                          if (file != null) Image.memory(file!.toUint8List()),
                          if (file != null)
                            IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  setState(() {
                                    file = null;
                                  });
                                }),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: MarkdownBody(
                                data: _t.text,
                                styleSheet: MarkdownStyleSheet.fromTheme(
                                        Theme.of(context))
                                    .copyWith(
                                        blockquotePadding:
                                            const EdgeInsets.only(left: 14),
                                        blockquoteDecoration:
                                            const BoxDecoration(
                                                border: Border(
                                                    left: BorderSide(
                                                        color: Colors.white70,
                                                        width: 4)))),
                                onTapLink: (text, href, title) async {
                                  if (href != null) {
                                    await _launchURL(href);
                                  }
                                }),
                          )
                        ],
                      )
                    ],
                  )),
            ),
            const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.edit)),
                Tab(icon: Icon(Icons.preview)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
