import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:matrix/matrix.dart';
import 'package:minestrix_chat/partials/matrix_image_avatar.dart';

import 'package:minestrix/partials/components/layouts/customHeader.dart';
import 'package:minestrix/utils/matrix_widget.dart';
import 'package:minestrix/router.gr.dart';

class SettingsAccountPage extends StatefulWidget {
  const SettingsAccountPage({Key? key}) : super(key: key);

  @override
  _SettingsAccountPageState createState() => _SettingsAccountPageState();
}

class _SettingsAccountPageState extends State<SettingsAccountPage> {
  TextEditingController? displayNameController;
  bool savingDisplayName = false;

  @override
  Widget build(BuildContext context) {
    Client sclient = Matrix.of(context).client;
    final m = Matrix.of(context);

    return ListView(
      children: [
        CustomHeader("Account"),
        FutureBuilder(
            future: sclient.getUserProfile(sclient.userID!),
            builder: (context, AsyncSnapshot<ProfileInformation> p) {
              if (displayNameController == null && p.hasData == true) {
                displayNameController = new TextEditingController(
                    text: (p.data?.displayname ?? sclient.userID!));
              }

              return ListTile(
                  leading: savingDisplayName
                      ? CircularProgressIndicator()
                      : MatrixImageAvatar(
                          client: Matrix.of(context).client,
                          url: p.data?.avatarUrl,
                          width: 48,
                          height: 48,
                          thumnail: true,
                          defaultIcon: Icon(Icons.person, size: 32),
                        ),
                  title: Text("Edit display name"),
                  trailing: Icon(Icons.edit),
                  subtitle: Text(p.data?.displayname ?? sclient.userID!),
                  onTap: () async {
                    List<String>? results = await showTextInputDialog(
                      context: context,
                      textFields: [
                        DialogTextField(
                            hintText: "Your display name",
                            initialText: p.data?.displayname ?? "")
                      ],
                      title: "Set display name",
                    );
                    if (results?.isNotEmpty == true) {
                      setState(() {
                        savingDisplayName = true;
                      });
                      await sclient.setDisplayName(
                          sclient.userID!, results![0]);
                      setState(() {
                        savingDisplayName = false;
                      });
                    }
                  });
            }),
        ListTile(
            title: Text("Your user ID:"),
            subtitle: Text(sclient.userID ?? "null")),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Clients"),
              Text("Multi account ${m.isMultiAccount}"),
              for (final c in m.widget.clients)
                ListTile(
                    title: Text(c.clientName), subtitle: Text(c.userID ?? '')),
              ListTile(
                  title: Text("Add client"),
                  trailing: Icon(Icons.add),
                  onTap: () async {
                    context.pushRoute(LoginRoute());
                  }),
            ],
          ),
        ),
      ],
    );
  }
}
