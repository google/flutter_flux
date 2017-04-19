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

class ChatScreen extends StoreWatcher {
  ChatScreen({Key key}) : super(key: key);

  @override
  void initStores(ListenToStore listenToStore) {
    listenToStore(messageStoreToken);
    listenToStore(userStoreToken);
  }

  Widget _buildTextComposer(BuildContext context, ChatMessageStore messageStore,
      ChatUserStore userStore) {
    final ValueChanged<InputValue> commitMessage = (InputValue _) {
      commitCurrentMessageAction(userStore.me);
    };

    ThemeData themeData = Theme.of(context);
    return new Row(children: <Widget>[
      new Flexible(
          child: new Input(
              value: messageStore.currentMessage,
              hintText: 'Enter message',
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

  @override
  Widget build(BuildContext context, Map<StoreToken, Store> stores) {
    final ChatMessageStore messageStore = stores[messageStoreToken];
    final ChatUserStore chatUserStore = stores[userStoreToken];

    return new Scaffold(
        appBar:
            new AppBar(title: new Text('Chatting as ${chatUserStore.me.name}')),
        body: new Column(children: <Widget>[
          new Flexible(
              child: new Block(
                  padding: new EdgeInsets.symmetric(horizontal: 8.0),
                  scrollAnchor: ViewportAnchor.end,
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
        child: new ListItem(
            dense: true,
            leading: new CircleAvatar(
                child: new Text(message.sender.name[0]),
                backgroundColor: message.sender.color),
            title: new Text(message.sender.name),
            subtitle: new Text(message.text)));
  }
}
