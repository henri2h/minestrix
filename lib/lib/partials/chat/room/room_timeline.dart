import 'dart:async';

import 'package:flutter/material.dart';
import 'package:infinite_list/infinite_list.dart';
import 'package:matrix/matrix.dart';
import 'package:minestrix_chat/partials/chat/message_composer/matrix_advanced_message_composer.dart';
import 'package:minestrix_chat/partials/matrix/matrix_image_avatar.dart';
import 'package:minestrix_chat/utils/extensions/datetime.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../../dialogs/adaptative_dialogs.dart';
import '../../infinite_custom_list_view.dart';
import '../event/message/matrix_message.dart';
import '../event/read_receipts/read_receipt_item.dart';
import '../event/read_receipts/read_receipts_list.dart';
import '../typing_indicator.dart';

class RoomTimeline extends StatefulWidget {
  final Room? room;
  final Client client;
  final String? userId;
  final Timeline? timeline;
  final Function(bool) setUpdating;
  final bool disableTimelinePadding;
  final bool isMobile;

  final void Function(Room)? onRoomCreate;

  final bool updating;
  const RoomTimeline(
      {Key? key,
      required this.room,
      required this.client,
      required this.isMobile,
      this.userId,
      this.disableTimelinePadding = false,
      this.onRoomCreate,
      required this.timeline,
      required this.updating,
      required this.setUpdating})
      : super(key: key);

  @override
  RoomTimelineState createState() => RoomTimelineState();
}

class RoomTimelineState extends State<RoomTimeline> {
  static const double bottomPadding = 60;

  late String? initialFullyReadEventId;
  String? fullyReadEventId;
  StreamController<String> onRelpySelected = StreamController.broadcast();
  Event? composerReplyToEvent;
  Room? room;

  List<Event> events = [];

  Future<void>? request;

  // scrolling logic
  final _scrollController = AutoScrollController(
    initialScrollOffset: -bottomPadding,
  ); // initial scroll offset due to list padding
  InfiniteListController? controller;

  @override
  void initState() {
    super.initState();
    room = widget.room ?? widget.timeline?.room;

    initialFullyReadEventId = room?.fullyRead;
    fullyReadEventId = initialFullyReadEventId;

    _scrollController.addListener(scrollListener);
    controller = InfiniteListController(
        items: events, scrollController: _scrollController);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (room != null) {
        markLastRead(room: room!);
      }
    });
  }

  @override
  void deactivate() {
    super.deactivate();
    _scrollController.removeListener(scrollListener);
  }

  bool get hasScrollReachedBottom =>
      _scrollController.position.pixels -
          _scrollController.position.minScrollExtent <
      10;

  void scrollListener() async {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 600) {
      if (widget.updating == false &&
          (widget.timeline?.canRequestHistory ?? false)) {
        widget.setUpdating(true);
        await widget.timeline?.requestHistory();
        widget.setUpdating(false);
      }
    }
    if (_scrollController.hasClients) {
      controller?.useFirstItemAsCenter = hasScrollReachedBottom;
    }
  }

  Future<void> requestHistoryIfNeeded() async {
    while ((widget.timeline?.canRequestHistory ?? false) &&
        _scrollController.hasClients &&
        _scrollController.position.hasContentDimensions &&
        _scrollController.position.maxScrollExtent == 0) {
      if (widget.timeline?.isRequestingHistory ?? false) {
        Future.delayed(const Duration(milliseconds: 200));
      } else {
        await widget.timeline?.requestHistory();
      }
    }
  }

  bool init = false;

  @override
  Widget build(BuildContext context) {
    if (!init) {
      if (widget.timeline?.events.isNotEmpty == true && room != null) {
        init = true;
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          if (room != null) markLastRead(room: room!);
        });
      }
    }

    if (request == null) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        if (_scrollController.hasClients &&
            _scrollController.position.hasContentDimensions &&
            widget.timeline != null) {
          request ??= requestHistoryIfNeeded();
        }
      });
    }

    final filteredEvents = widget.timeline?.events
        .where((e) =>
            !{RelationshipTypes.edit, RelationshipTypes.reaction}
                .contains(e.relationshipType) &&
            !{
              EventTypes.Reaction,
              EventTypes.Redaction,
              EventTypes.CallCandidates,
              EventTypes.CallHangup,
              EventTypes.CallReject,
              EventTypes.CallNegotiate,
              EventTypes.CallAnswer,
              "m.call.select_answer",
              "org.matrix.call.sdp_stream_metadata_changed"
            }.contains(e.type))
        .toList();

    events.clear();
    if (filteredEvents != null) {
      events.addAll(filteredEvents);
    }

    return Stack(children: [
      room != null
          ? widget.timeline != null
              ? Padding(
                  padding: EdgeInsets.only(
                      bottom: widget.isMobile ? 0 : bottomPadding),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: InfiniteCustomListViewWithEmoji(
                        controller: controller!,
                        reverse: true,
                        itemCount: filteredEvents!.length,
                        padding: EdgeInsets.only(
                            top: widget.disableTimelinePadding ? 0 : 52,
                            bottom: !widget.isMobile ? 0 : bottomPadding),
                        itemBuilder: (BuildContext context, int index,
                                ItemPositions position, onReact) =>
                            ItemBuilder(
                              key: index < filteredEvents.length
                                  ? Key("item_${filteredEvents[index].eventId}")
                                  : null,
                              room: room!,
                              filteredEvents: filteredEvents,
                              t: widget.timeline!,
                              i: index,
                              onReact: onReact,
                              position: position,
                              onReplyEventPressed: (event) async {
                                final index = widget.timeline!.events.indexOf(
                                    event.getDisplayEvent(widget.timeline!));
                                if (index != -1) {
                                  await controller?.scrollController
                                      .scrollToIndex(index);
                                  onRelpySelected.add(event.eventId);
                                } else {
                                  print(
                                      "Could not scroll to index, item not found");
                                }
                              },
                              onSelected: onRelpySelected.stream,
                              onReply: (Event oldEvent) => setState(() {
                                composerReplyToEvent = oldEvent;
                              }),
                              fullyReadEventId: initialFullyReadEventId,
                            )),
                  ),
                )
              : const Center(
                  child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(width: 16),
                    Text("Loading chat...")
                  ],
                ))
          : widget.userId?.isValidMatrixId == true
              ? FutureBuilder<Profile>(
                  future: widget.client.getProfileFromUserId(widget.userId!),
                  builder: (context, snap) {
                    return Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MatrixImageAvatar(
                            url: snap.data?.avatarUrl,
                            client: widget.client,
                            height: MinestrixAvatarSizeConstants.big,
                            width: MinestrixAvatarSizeConstants.big,
                            shape: MatrixImageAvatarShape.rounded,
                            defaultText: snap.data?.displayName,
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Expanded(
                              child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 34),
                            child: ListTile(
                              title: Text(
                                  snap.data?.displayName ?? widget.userId!,
                                  style: const TextStyle(fontSize: 24)),
                              subtitle: Text(widget.userId!,
                                  style: const TextStyle(fontSize: 18)),
                            ),
                          )),
                        ],
                      ),
                    );
                  })
              : const Center(child: Text("Send a message to create the room")),
      Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          for (User user in room?.typingUsers ?? [])
            TypingIndicator(room: room!, user: user),
          MatrixAdvancedMessageComposer(
              room: room,
              isMobile: widget.isMobile,
              userId: widget.userId,
              client: widget.client,
              onRoomCreate: widget.onRoomCreate,
              reply: composerReplyToEvent,
              removeReply: () {
                setState(() {
                  composerReplyToEvent = null;
                });
              }),
        ],
      )
    ]);
  }

  /// send a read event if we have read the last event
  Future<bool> markLastRead({required Room room}) async {
    if (widget.timeline?.events.isNotEmpty != true) return false;

    Event? lastEvent;

    // get last read item
    if (hasScrollReachedBottom) {
      lastEvent = widget.timeline?.events.first;
    } else {
      lastEvent = controller?.getClosestElementToAlignment();
    }

    if (lastEvent != null &&
        fullyReadEventId != lastEvent.eventId &&
        lastEvent.status.isSent) {
      final lastReadPos = widget.timeline!.events
          .indexWhere((element) => element.eventId == fullyReadEventId);
      final pos = widget.timeline!.events.indexOf(lastEvent);

      if (lastReadPos != -1 && pos >= lastReadPos) return false;

      final evId = lastEvent.eventId;
      fullyReadEventId = evId;

      await room.setReadMarker(evId, mRead: evId);
      return true;
    }
    return false;
  }
}

class ItemBuilder extends StatelessWidget {
  const ItemBuilder(
      {Key? key,
      this.displayAvatar = false,
      this.displayName = false,
      this.displayTime = false,
      this.displayPadding = false,
      required this.room,
      required this.t,
      required this.filteredEvents,
      required this.onReact,
      required this.position,
      required this.i,
      required this.onReplyEventPressed,
      required this.onReply,
      this.onSelected,
      this.fullyReadEventId})
      : super(key: key);

  final Room room;
  final Timeline t;
  final List<Event> filteredEvents;
  final bool displayAvatar;
  final bool displayName;
  final bool displayTime;
  final bool displayPadding;
  final void Function(Offset, Event) onReact;
  final ItemPositions position;
  final int i;
  final void Function(Event) onReplyEventPressed;
  final void Function(Event) onReply;
  final Stream<String>? onSelected;
  final String? fullyReadEventId;

  @override
  Widget build(BuildContext context) {
    // local overrides
    bool displayName = this.displayName;
    bool displayTime = this.displayTime;
    bool displayPadding = this.displayPadding;
    bool displayAvatar = this.displayAvatar;

    if (position != ItemPositions.item) return Container();
    Event event = filteredEvents[i];

    Set<Event> reactions =
        event.aggregatedEvents(t, RelationshipTypes.reaction);

    final prevEvent =
        i < filteredEvents.length - 1 ? filteredEvents[i + 1] : null;
    final nextEvent = i > 0 ? filteredEvents[i - 1] : null;

    if (prevEvent != null) {
      // check if the preceding message was sent by the same user
      // TODO : check dates
      if (event.type == EventTypes.Message) {
        if (event.senderId != prevEvent.senderId) {
          displayName = !room.isDirectChat;
          displayPadding = true;
        }

        if (event.originServerTs
                .difference(prevEvent.originServerTs)
                .inHours
                .abs() >
            2) {
          displayTime = true;
        }
      }

      if ((prevEvent.type == EventTypes.Message &&
              event.type != EventTypes.Message) ||
          (event.type == EventTypes.Message &&
              event.type != EventTypes.Message)) {
        displayPadding = true;
      }
    }

    if (nextEvent?.senderId != event.senderId ||
        nextEvent?.type != EventTypes.Message) {
      displayAvatar = true;
    }

    if (event.status.isError) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: MaterialButton(
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.restart_alt),
          ),
          onPressed: () async {
            await event.sendAgain();
          },
        ),
      );
    }
    final oldEvent = event;
    event = event.getDisplayEvent(t);
    final edited = event.eventId != oldEvent.eventId;

    if (displayTime) {
      // in case of we should display the time, we take care of the padding ourself
      displayPadding = false;
    }

    return Column(
      children: [
        if (displayTime)
          Padding(
            padding: const EdgeInsets.only(top: 20.0, bottom: 14),
            child: Text(event.originServerTs.timeSince,
                style: const TextStyle(fontSize: 14, color: Colors.grey)),
          ),
        MessageDisplay(
            key: Key("ed_${event.eventId}"),
            event: event,
            timeline: t,
            reactions: reactions,
            client: room.client,
            isLastMessage: i == 0,
            displayAvatar: displayAvatar,
            displayName: displayName,
            addPaddingTop: displayPadding,
            edited: edited,
            onEventSelectedStream:
                onSelected?.where((eventId) => eventId == event.eventId),
            onReact: (e) => onReact(e, event),
            onReplyEventPressed: onReplyEventPressed,
            onReply: () => onReply(oldEvent)),
        if (event.receipts.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 2, right: 2),
            child: GestureDetector(
              onTap: () async {
                await AdaptativeDialogs.show(
                    context: context,
                    title: "Seen by",
                    builder: (context) => ReadReceiptsList(event: event));
              },
              child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                for (Receipt r in event.receipts
                    .where((r) => r.user.id != room.client.userID)
                    .take(12))
                  ReadReceiptsItem(r: r, room: room),
                if (event.receipts.length >= 12)
                  const CircleAvatar(
                      radius: 10, child: Icon(Icons.more_horiz, size: 14))
              ]),
            ),
          ),
        if (event.eventId == fullyReadEventId && nextEvent != null)
          const Row(
            children: [
              Expanded(
                  child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Divider(),
              )),
              Text("Fully read"),
              Expanded(
                  child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Divider(),
              ))
            ],
          ),
      ],
    );
  }
}
