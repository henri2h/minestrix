import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:minestrix/partials/minestrix_title.dart';
import 'package:minestrix_chat/utils/matrix_widget.dart';
import 'package:minestrix_chat/partials/login/login_card.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key, this.title, this.onLogin, this.popOnLogin = false})
      : super(key: key);
  final String? title;
  final Function(bool isLoggedIn)? onLogin;

  final bool popOnLogin;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 900)
        return buildDesktop();
      else
        return buildMobile();
    });
  }

  Widget buildDesktop() {
    Client client = Matrix.of(context).getLoginClient();

    final radius = Radius.circular(8);

    return Scaffold(
      body: Stack(fit: StackFit.expand, children: [
        Image.asset("assets/bg_paris.jpg", fit: BoxFit.cover),
        Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: IntrinsicHeight(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 180,
                            child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                      topLeft: radius, bottomLeft: radius)),
                              margin: EdgeInsets.zero,
                              color: Theme.of(context).primaryColor,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 40.0),
                                    child: Image.asset("assets/icon_512.png",
                                        width: 80, height: 80),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(14.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("MinesTRIX",
                                            style: TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.w800)),
                                        Text(
                                            "A privacy focused social media based on MATRIX",
                                            style: TextStyle(fontSize: 14))
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                    topRight: radius, bottomRight: radius)),
                            margin: EdgeInsets.zero,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 15.0),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Container(
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(maxWidth: 450),
                                    child: LoginMatrixCard(
                                        client: client,
                                        popOnLogin: widget.popOnLogin),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Card(
              color: Theme.of(context).cardColor.withAlpha(120),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 6, horizontal: 15.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () async =>
                          await _launchURL(Uri.parse("https://matrix.org")),
                      child: new Text('The matrix protocol'),
                    ),
                    TextButton(
                      onPressed: () async => await _launchURL(Uri.parse(
                          "https://gitlab.com/minestrix/minestrix-flutter")),
                      child: new Text('MinesTRIX code'),
                    ),
                    SizedBox(width: 20),
                    FutureBuilder<PackageInfo>(
                        future: PackageInfo.fromPlatform(),
                        builder: (context, snap) {
                          if (!snap.hasData) return Container();
                          return Text(
                              "Version " + (snap.data?.version ?? 'null'));
                        }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ]),
    );
  }

  bool advancedView = false;

  Widget buildMobile() {
    Client client = Matrix.of(context).getLoginClient();

    return Scaffold(
      body: Container(
        color: Colors.grey[200],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            MinestrixTitle(),
            Expanded(
                child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(40))),
                    child: LoginMatrixCard(client: client)))
          ],
        ),
      ),
    );
  }

  Future<void> _launchURL(Uri url) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}