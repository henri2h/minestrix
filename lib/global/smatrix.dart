/*
  Here is the main code of the smatrix client
 */

import 'dart:async';

import 'package:famedlysdk/famedlysdk.dart';

class SClient extends Client {
  static String SMatrixRoomPrefix = "smatrix_";
  static String SMatrixUserRoomPrefix = SMatrixRoomPrefix + "@";
  StreamSubscription onSyncUpdate;
  StreamSubscription onEventUpdate;
  StreamController<String> onTimelineUpdate = StreamController.broadcast();

  List<SMatrixRoom> srooms = [];
  List<Event> stimeline = [];

  SClient(String clientName,
      {bool enableE2eeRecovery,
      Set verificationMethods,
      Future<Database> Function(Client client) databaseBuilder})
      : super(clientName,
            verificationMethods: verificationMethods,
            databaseBuilder: databaseBuilder);

  Future<void> initSMatrix() async {
    // initialisation
    await loadSRooms();
    await loadNewTimeline();

    onEventUpdate ??= this.onEvent.stream.listen((EventUpdate eUp) async {
      /*   print("Event update");
      print(eUp.eventType);
      print(eUp.roomID);
      print(eUp.content);
      print(" ");*/

      if (eUp.eventType == "m.room.message") {
        await loadNewTimeline();
      }
    });
  }

  Future<void> loadNewTimeline() async {
    await loadSTimeline();
    sortTimeline();
    onTimelineUpdate.add("Update");
  }

  Future<void> loadSRooms() async {
    srooms.clear(); // clear rooms
    for (var i = 0; i < rooms.length; i++) {
      SMatrixRoom rs = SMatrixRoom();
      if (await rs
          .init(rooms[i])) // if class is correctly initialisated, we can add it
        srooms.add(rs);
    }
  }

  Future<void> loadSTimeline() async {
    stimeline.clear();
    for (SMatrixRoom sroom in srooms) {
      Timeline t = await sroom.room.getTimeline();
      final filteredEvents = t.events
          .where((e) =>
              !{RelationshipTypes.Edit, RelationshipTypes.Reaction}
                  .contains(e.relationshipType) &&
              {EventTypes.Message, EventTypes.Encrypted}.contains(e.type))
          .toList();

      for (var i = 0; i < filteredEvents.length; i++) {
        filteredEvents[i] = filteredEvents[i].getDisplayEvent(t);
      }
      stimeline.addAll(filteredEvents);
    }
  }

  void sortTimeline() {
    stimeline.sort((a, b) {
      return b.originServerTs.compareTo(a.originServerTs);
    });
  }

  @override
  Future<void> dispose({bool closeDatabase = true}) async {
    onSyncUpdate?.cancel();
    onEventUpdate?.cancel();
    onTimelineUpdate?.close();
    await super.dispose(closeDatabase: closeDatabase);
  }

  static String getUserIdFromRoomName(String name) {
    return name.replaceFirst(SMatrixRoomPrefix, "");
  }

  Future<Profile> getUserFromRoom(Room room) async {
    String userId = getUserIdFromRoomName(room.name);
    print(userId);
    return getProfileFromUserId(userId);
  }
}

class SMatrixRoom {
  // would have liked to extends Room type, but couldn't manage to get Down Casting to work properly...
  // initialize the class, return false, if it could not generate the classes
  // i.e, it is not a valid class
  User user;
  Room room;
  bool _validSRoom = false;
  Future<bool> init(Room r) async {
    try {
      if (isValidSRoom(r)) {
        room = r;
        String userId = SClient.getUserIdFromRoomName(room.name);

        // find local on local users
        List<User> users = room.getParticipants();
        user = findUser(users, userId);

        // or in the server ones
        if (user == null) {
          users = await room.requestParticipants();
          user = findUser(users, userId);
        }

        if (user != null) {
          /* if (room.powerLevels != null)
            print(room.powerLevels[user.id]); // throw an error....
          else
            print("error reading power levels");
          print(room.ownPowerLevel);*/
          _validSRoom = true;
          return true;
        }
      }
    } catch (e) {}
    return false;
  }

  static User findUser(List<User> users, String userId) {
    try {
      return users.firstWhere((User u) => userId == u.id);
    } catch (_) {
      // return null if no element

    }
    return null;
  }

  static bool isValidSRoom(Room room) {
    if (room.name.startsWith(SClient.SMatrixRoomPrefix)) {
      // check if is a use room, in which case, it's user must be admin
      if (room.name.startsWith(SClient.SMatrixUserRoomPrefix)) {
        String userid = SClient.getUserIdFromRoomName(room.name);
        print(userid);
        return true;
      }

      return false; // we don't support other room types yet
    }
    return false;
  }
}
