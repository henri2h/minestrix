import 'dart:async';
import 'package:famedlysdk/encryption/utils/key_verification.dart';
import 'package:famedlysdk/famedlysdk.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';
import 'package:minestrix/components/dialogs/keyVerificationDialog.dart';
import 'package:minestrix/global/smatrix.dart';
import 'package:minestrix/utils/fameldysdk_store.dart';
import 'package:minestrix/utils/platforms_info.dart';

class Matrix extends StatefulWidget {
  final Widget child;

  Matrix({Key key, this.child}) : super(key: key);

  @override
  MatrixState createState() => MatrixState();

  /// Returns the (nearest) Client instance of your application.
  static MatrixState of(BuildContext context) {
    var newState =
        (context.dependOnInheritedWidgetOfExactType<_InheritedMatrix>()).data;
    newState.context = context;
    return newState;
  }
}

class MatrixState extends State<Matrix> {
  final log = Logger("MatrixState");

  SClient sclient;
  @override
  BuildContext context;

  StreamSubscription<KeyVerification> onKeyVerificationRequestSub;
  StreamSubscription<EventUpdate> onEvent;

  @deprecated
  Future<void> connect() async {
    sclient.onLoginStateChanged.stream.listen((LoginState loginState) {
      print("LoginState: ${loginState.toString()}");
    });
  }

  @override
  void initState() {
    super.initState();
    initMatrix();
  }

  void initMatrix() {
    final Set verificationMethods = <KeyVerificationMethod>{
      KeyVerificationMethod.numbers
    };

    if (PlatformInfos.isMobile) {
      // emojis don't show in web somehow
      verificationMethods.add(KeyVerificationMethod.emoji);
    }

    String clientName = "minestrix";
    sclient = SClient(clientName,
        enableE2eeRecovery: true,
        verificationMethods: verificationMethods,
        databaseBuilder: getDatabase);

    onKeyVerificationRequestSub ??= sclient.onKeyVerificationRequest.stream
        .listen((KeyVerification request) async {
      print("KeyVerification");
      print(request.deviceId);
      print(request.isDone);

      var hidPopup = false;
      request.onUpdate = () {
        if (!hidPopup &&
            {KeyVerificationState.done, KeyVerificationState.error}
                .contains(request.state)) {
          Navigator.of(context, rootNavigator: true).pop('dialog');
        }
        hidPopup = true;
      };

      /*if (await showOkCancelAlertDialog(
            context: context,
            title: L10n.of(context).newVerificationRequest,
            message: L10n.of(context).askVerificationRequest(request.userId),
          ) ==
          OkCancelResult.ok) {*/
      request.onUpdate = null;
      hidPopup = true;
      await request.acceptVerification();
      await KeyVerificationDialog(request: request).show(context);
      /* } else {
        request.onUpdate = null;
        hidPopup = true;
        await request.rejectVerification();
      }*/
    });

    onEvent ??= sclient.onEvent.stream
        .where((event) =>
            [EventTypes.Message, EventTypes.Encrypted]
                .contains(event.content['type']) &&
            event.content['sender'] != sclient.userID)
        .listen((EventUpdate eventUpdate) async {
      // we should react differently depending on wether the event is a smatrix one or not...
      // get event object
      Room room = sclient.getRoomById(eventUpdate.roomID);
      Event event = Event.fromJson(eventUpdate.content, room);

      // don't throw a notification for old events
      if (event.originServerTs
              .compareTo(DateTime.now().subtract(Duration(seconds: 5))) >
          0) {
        // check if it is a minestrix event or a message
        // This method works only for already recognised SRooms
        bool isSRoom = sclient.srooms.containsKey(eventUpdate.roomID);
        if (isSRoom) {
          Profile profile = await sclient.getUserFromRoom(room);
          Flushbar(
            title: "New post from " + profile.displayname,
            message: event.body,
            duration: Duration(seconds: 3),
            flushbarPosition: FlushbarPosition.TOP,
          )..show(context);
        } else {
          // bah.... dirty

          double mWidth = 500;
          double margin_left = MediaQuery.of(context).size.width - mWidth - 20;
          if (margin_left < 8) margin_left = 8;
          Flushbar(
            margin: EdgeInsets.only(bottom: 8, right: 8, left: margin_left),
            borderRadius: 8,
            maxWidth: mWidth,
            title: event.sender.displayName + "@" + room.name,
            dismissDirection: FlushbarDismissDirection.HORIZONTAL,
            icon: Icon(Icons.info, color: Colors.white),
            message: event.body,
            duration: Duration(seconds: 5),
            flushbarPosition: FlushbarPosition.BOTTOM,
          )..show(context);
        }
      }
    });

    log.info("Matrix state initialisated");
    _initWithStore();
  }

  void _initWithStore() async {
    var initLoginState = sclient.onLoginStateChanged.stream.first;
    try {
      sclient.init();

      final firstLoginState = await initLoginState;
      if (firstLoginState == LoginState.logged) {
        await sclient.initSMatrix();
      } else {
        log.warning("Not logged in");
      }
    } catch (e) {
      log.severe("error : Could not initWithStore", e);
    }
  }

  @override
  void dispose() {
    onKeyVerificationRequestSub?.cancel();
    onEvent?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    log.info("build");
    return _InheritedMatrix(data: this, child: widget.child);
  }
}

class _InheritedMatrix extends InheritedWidget {
  final MatrixState data;

  _InheritedMatrix({Key key, this.data, Widget child})
      : super(key: key, child: child);

  @override
  bool updateShouldNotify(_InheritedMatrix old) {
    var update = old.data.sclient.accessToken != data.sclient.accessToken ||
        old.data.sclient.userID != data.sclient.userID ||
        old.data.sclient.deviceID != data.sclient.deviceID ||
        old.data.sclient.deviceName != data.sclient.deviceName ||
        old.data.sclient.homeserver != data.sclient.homeserver;
    return update;
  }
}
