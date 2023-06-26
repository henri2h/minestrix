import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:auto_route/auto_route.dart';
import 'package:matrix/matrix.dart';
import 'package:minestrix/router.dart';
import 'package:minestrix_chat/utils/login/login_extension.dart';
import 'package:minestrix_chat/utils/matrix_widget.dart';
import 'package:provider/provider.dart';

import 'router.gr.dart';
import 'utils/managers/theme_manager.dart';

class Minestrix extends StatefulWidget {
  const Minestrix({Key? key, required this.clients}) : super(key: key);

  final List<Client> clients;
  @override
  MinestrixState createState() => MinestrixState();
}

class MinestrixState extends State<Minestrix> {
  final _appRouter = AppRouter();
  bool _initLock = false;
  Future<void> initMatrix(Client m) async {
    if (_initLock) return;

    if (!m.isLogged()) {
      Logs().i("[ logged ] [ ${m.clientName} ]: ${m.isLogged()}");
      _initLock = true;
      await m.init(
          waitForFirstSync: false, waitUntilLoadCompletedLoaded: false);
    }
    return;
  }

  Future<bool>? webLogin;

  @override
  Widget build(BuildContext context) {
    return Matrix(
      applicationName: 'MinesTRIX',
      context: context,
      clients: widget.clients,
      child: Builder(
        builder: (context) => Consumer<ThemeNotifier>(
          builder: (context, theme, _) => StreamBuilder<LoginState?>(
              stream: Matrix.of(context).client.onLoginStateChanged.stream,
              builder: (context, AsyncSnapshot<LoginState?> state) {
                Client client = Matrix.of(context).client;

                if (kIsWeb && client.shouldSSOLogin) {
                  webLogin ??= client.ssoLogin();
                }

                return FutureBuilder<bool>(
                    future: webLogin,
                    builder: (context, snapshot) {
                      // Progress indicator while login in on web
                      if (webLogin != null && !snapshot.hasData) {
                        return const MaterialApp(
                          home: Scaffold(
                            body: Center(
                                child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(
                                  width: 12,
                                ),
                                Text("Loading")
                              ],
                            )),
                          ),
                        );
                      }

                      return FutureBuilder(
                          future: initMatrix(client),
                          builder: (context, snap) {
                            return MaterialApp.router(
                              routerDelegate: AutoRouterDelegate.declarative(
                                _appRouter,
                                routes: (_) {
                                  final isLogged = client.isLogged();
                                  return [
                                    if (isLogged)
                                      const AppWrapperRoute()

                                    // if they are not logged in, bring them to the Login page
                                    else
                                      LoginRoute()
                                  ];
                                },
                              ),

                              routeInformationParser:
                                  _appRouter.defaultRouteParser(),
                              debugShowCheckedModeBanner: false,
                              // theme :
                              theme: theme.theme,
                            );
                          });
                    });
              }),
        ),
      ),
    );
  }
}
