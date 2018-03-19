// Copyright 2016, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';
import 'stores.dart';

void main() {
  runApp(new MaterialApp(
      title: 'Chat',
      theme: new ThemeData(
          primarySwatch: Colors.purple, accentColor: Colors.orangeAccent[400]),
      home: new ChatScreen()));
}

class ChatScreen extends StatefulWidget {
  /// Creates a widget that watches stores.
  ChatScreen({Key key}) : super(key: key);

  @override
  ChatScreenState createState() => new ChatScreenState();
}

// To use StoreWatcherMixin in your widget's State class:
// 1. Add "with StoreWatcherMixin<yyy>" to the class declaration where yyy is
//    the type of your StatefulWidget.
// 2. Add the Store declarations to your class.
// 3. Add initState() function that calls listenToStore() for each store to
//    be monitored.
// 4. Use the information from your store(s) in your build() function.

class ChatScreenState extends State<ChatScreen>
    with StoreWatcherMixin<ChatScreen> {
  // Never write to these stores directly. Use Actions.
  ChatMessageStore messageStore;
  ChatUserStore chatUserStore;

  final TextEditingController msgController = new TextEditingController();

  /// Override this function to configure which stores to listen to.
  ///
  /// This function is called by [StoreWatcherState] during its
  /// [State.initState] lifecycle callback, which means it is called once per
  /// inflation of the widget. As a result, the set of stores you listen to
  /// should not depend on any constructor parameters for this object because
  /// if the parent rebuilds and supplies new constructor arguments, this
  /// function will not be called again.
  @override
  void initState() {
    super.initState();

    // Demonstrates using a custom change handler.
    messageStore =
        listenToStore(messageStoreToken, handleChatMessageStoreChanged);

    // Demonstrates using the default handler, which just calls setState().
    chatUserStore = listenToStore(userStoreToken);
  }

  void handleChatMessageStoreChanged(Store store) {
    ChatMessageStore messageStore = store;
    if (messageStore.currentMessage.isEmpty) {
        msgController.clear();
    }
    setState(() {});
  }

  Widget _buildTextComposer(BuildContext context, ChatMessageStore messageStore,
      ChatUserStore userStore) {
    final ValueChanged<String> commitMessage = (String _) {
      commitCurrentMessageAction(userStore.me);
    };

    ThemeData themeData = Theme.of(context);
    return new Row(children: <Widget>[
      new Flexible(
          child: new TextField(
              key: const Key("msgField"),
              controller: msgController,
              decoration: const InputDecoration(hintText: 'Enter message'),
              onSubmitted: commitMessage,
              onChanged: setCurrentMessageAction)),
      new Container(
          margin: new EdgeInsets.symmetric(horizontal: 4.0),
          child: new IconButton(
              icon: new Icon(Icons.send),
              onPressed:
                  messageStore.isComposing ? () => commitMessage(null) : null,
              color: messageStore.isComposing
                  ? themeData.accentColor
                  : themeData.disabledColor))
    ]);
  }

  Widget build(BuildContext context) {
    return new Scaffold(
        appBar:
            new AppBar(title: new Text('Chatting as ${chatUserStore.me.name}')),
        body: new Column(children: <Widget>[
          new Flexible(
              child: new ListView(
                  padding: new EdgeInsets.symmetric(horizontal: 8.0),
                  children: messageStore.messages
                      .map((ChatMessage m) => new ChatMessageListItem(m))
                      .toList())),
          _buildTextComposer(context, messageStore, chatUserStore),
        ]));
  }
}

class ChatMessageListItem extends StatefulWidget {
  ChatMessageListItem(ChatMessage m)
      : message = m,
        super(key: new ObjectKey(m));

  final ChatMessage message;

  @override
  State createState() => new ChatMessageListItemState();
}

class ChatMessageListItemState extends State<ChatMessageListItem>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = new AnimationController(
        vsync: this, duration: new Duration(milliseconds: 700));
    _animation = new CurvedAnimation(
        parent: _animationController, curve: Curves.easeOut);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ChatMessage message = widget.message;
    return new SizeTransition(
        sizeFactor: _animation,
        axisAlignment: 0.0,
        child: new ListTile(
            dense: true,
            leading: new CircleAvatar(
                child: new Text(message.sender.name[0]),
                backgroundColor: message.sender.color),
            title: new Text(message.sender.name),
            subtitle: new Text(message.text)));
  }
}
