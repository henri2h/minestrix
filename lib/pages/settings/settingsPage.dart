import 'package:flutter/material.dart';

import 'package:auto_route/src/router/auto_router_x.dart';
import 'package:matrix/matrix.dart';
import 'package:minestrix_chat/partials/matrix_image_avatar.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:minestrix/pages/account/accountsDetailsPage.dart';
import 'package:minestrix/pages/debugPage.dart';
import 'package:minestrix/partials/components/layouts/customHeader.dart';
import 'package:minestrix/router.gr.dart';

import '../../utils/matrixWidget.dart';
import '../../utils/minestrix/minestrixClient.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    MinestrixClient client = Matrix.of(context).sclient!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ListView(
        children: [
          CustomHeader("Settings"),
          FutureBuilder(
              future: client.getUserProfile(client.userID!),
              builder: (context, AsyncSnapshot<ProfileInformation> p) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      MatrixImageAvatar(
                        client: Matrix.of(context).sclient,
                        url: p.data?.avatarUrl,
                        width: 120,
                        height: 120,
                        thumnail: true,
                        defaultText: p.data?.displayname ?? client.userID,
                        defaultIcon: Icon(Icons.person, size: 32),
                      ),
                      SizedBox(height: 30),
                      Text(p.data?.displayname ?? client.userID!,
                          style: TextStyle(
                              fontSize: 28, fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              }),
          SizedBox(height: 20),
          ListTile(
            title: Text("Account"),
            subtitle: Text("Change display name..."),
            trailing: Icon(Icons.arrow_forward),
            leading: Icon(Icons.person),
            onTap: () {
              context.navigateTo(SettingsAccountRoute());
            },
          ),
          ListTile(
            title: Text("Theme"),
            subtitle: Text("Customize the app."),
            trailing: Icon(Icons.arrow_forward),
            leading: Icon(Icons.color_lens),
            onTap: () {
              context.navigateTo(SettingsThemeRoute());
            },
          ),
          ListTile(
            title: Text("Profiles"),
            subtitle: Text("Control your accounts."),
            trailing: Icon(Icons.arrow_forward),
            leading: Icon(Icons.people),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => Scaffold(body: AccountsDetailsPage())));
            },
          ),
          ListTile(
            title: Text("Security"),
            subtitle: Text("Encryption, verify your devices..."),
            trailing: Icon(Icons.arrow_forward),
            leading: Icon(Icons.lock),
            onTap: () {
              context.navigateTo(SettingsSecurityRoute());
            },
          ),
          ListTile(
              title: Text("Labs"),
              subtitle: Text("Experimental features, use with caution."),
              trailing: Icon(Icons.arrow_forward),
              leading: Icon(Icons.warning),
              onTap: () {
                context.navigateTo(SettingsLabsRoute());
              }),
          ListTile(
            title: Text("Debug"),
            subtitle: Text("Oups, something went wrong ?"),
            trailing: Icon(Icons.arrow_forward),
            leading: Icon(Icons.bug_report),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => Scaffold(body: DebugPage())));
            },
          ),
          SizedBox(height: 40),
          ListTile(
              iconColor: Colors.red,
              title: Text("Logout"),
              trailing: Icon(Icons.logout),
              onTap: () async {
                await client.logout();
                if (Navigator.of(context).canPop()) Navigator.of(context).pop();
              }),
          ListTile(
            title: Text("About"),
            subtitle: FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (context, snap) {
                  if (!snap.hasData) return Container();
                  return Text("Version " + (snap.data?.version ?? 'null'));
                }),
          ),
        ],
      ),
    );
  }
}