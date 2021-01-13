import 'package:famedlysdk/famedlysdk.dart';
import 'package:flutter/material.dart';
import 'package:minestrix/global/smatrixWidget.dart';
import 'package:minestrix/screens/home/screen.dart';
import 'package:minestrix/global/smatrix.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: ListView(
        children: <Widget>[
          LoginTitle(),
          LoginCard(),
        ],
      )),
    );
  }
}

class LoginTitle extends StatelessWidget {
  const LoginTitle({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(50),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("Mines'Trix",
            style: TextStyle(fontSize: 50, fontWeight: FontWeight.w800)),
        Text("An alternative social media based on MATRIX",
            style: TextStyle(fontSize: 30))
      ]),
    );
  }
}

class LoginCard extends StatefulWidget {
  LoginCard({Key key}) : super(key: key);
  @override
  LoginCardState createState() => LoginCardState();
}

class LoginCardState extends State<LoginCard> {
  final TextEditingController _usernameController = TextEditingController(),
      _passwordController = TextEditingController();

  String _errorText;
  bool _isLoading = false;
  String password = "";
  String domain = "";
  bool canTryLogIn = false;

  void _loginAction(SClient client) async {
    if (mounted)
      setState(() {
        _isLoading = true;
        _errorText = null;
      });
    try {
      await client.checkHomeserver(domain);
      await client.login(
          user: _usernameController.text,
          password: _passwordController.text,
          initialDeviceDisplayName: client.clientName);
    } catch (error) {
      if (mounted) setState(() => _errorText = error.toString());
    }
    if (mounted) setState(() => _isLoading = false);
  }

// according to the matrix specification https://matrix.org/docs/spec/appendices#id9
  RegExp userRegex = RegExp(
      r"@((([a-z]|\.|_|-|=|\/|[0-9])+):(((.+)\.(.+))|\[((([0-9]|[a-f]|[A-F])+):){2,7}:?([0-9]|[a-f]|[A-F])+\]))(:([0-9]+))?");
  @override
  Widget build(BuildContext context) {
    SClient client = Matrix.of(context).sclient;
    return SizedBox(
        child: Container(
            child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(children: <Widget>[
                  LoginInput(
                      name: "userid",
                      icon: Icons.account_circle,
                      onChanged: (String userid) async {
                        try {
                          RegExpMatch reguserIdMatched =
                              userRegex.firstMatch(userid);

                          if (reguserIdMatched != null) {
                            String userIdMatched = reguserIdMatched.group(0);
                            WellKnownInformations infos =
                                await client.getWellKnownInformationsByUserId(
                                    userIdMatched);
                            if (infos?.mHomeserver?.baseUrl != null) {
                              setState(() {
                                domain = infos.mHomeserver.baseUrl;
                                canTryLogIn = true;
                              });
                            } else {
                              setState(() {
                                domain = "";
                                canTryLogIn = false;
                              });
                            }
                          }
                        } catch (e) {
                          setState(() {
                            domain = "";
                            canTryLogIn = false;
                          });
                          print("error : " + userid);
                          print(e);
                        }
                      },
                      tController: _usernameController),
                  LoginInput(
                      name: "password",
                      icon: Icons.lock_outline,
                      tController: _passwordController,
                      obscureText: true),
                  Text("Domain : "),
                  Text(domain),
                  if (_errorText != null) Text(_errorText),
                  if (_isLoading)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: LinearProgressIndicator(),
                    ),
                  FloatingActionButton.extended(
                      icon: const Icon(Icons.login),
                      label: Text('Login'),
                      onPressed: _isLoading || !canTryLogIn
                          ? null
                          : () => _loginAction(client)),
                ]))));
  }

  void changePage(BuildContext context) {
    print(_usernameController.text);
    print(_passwordController.text);
    if (2 == 3)
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(),
          ));
  }
}

class LoginInput extends StatelessWidget {
  const LoginInput(
      {Key key,
      this.name,
      this.icon,
      this.tController,
      this.errorText,
      this.obscureText = false,
      this.onChanged})
      : super(key: key);
  final String name;
  final IconData icon;
  final TextEditingController tController;
  final String errorText;
  final bool obscureText;
  final Function onChanged;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        keyboardType: TextInputType.emailAddress,
        controller: tController,
        obscureText: obscureText,
        onChanged: onChanged,
        decoration: InputDecoration(
          errorText: errorText,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(20))),
          filled: true,
          icon: Icon(icon),
          labelText: name,
        ),
      ),
    );
  }
}
