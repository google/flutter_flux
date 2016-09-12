// Copyright 2016, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:math' show Random;

import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';

class ChatUser {
  ChatUser({this.name, this.color});
  final String name;
  final Color color;
}

class ChatMessage {
  ChatMessage({this.sender, this.text});
  final ChatUser sender;
  final String text;
}

class ChatMessageStore extends Store {
  ChatMessageStore() {
    triggerOnAction(setCurrentMessageAction, (InputValue value) {
      _currentMessage = value;
    });
    triggerOnAction(commitCurrentMessageAction, (ChatUser me) {
      final ChatMessage message =
          new ChatMessage(sender: me, text: _currentMessage.text);
      _messages.add(message);
      _currentMessage = InputValue.empty;
    });
  }

  final List<ChatMessage> _messages = <ChatMessage>[];
  InputValue _currentMessage = InputValue.empty;

  List<ChatMessage> get messages =>
      new List<ChatMessage>.unmodifiable(_messages);
  InputValue get currentMessage => _currentMessage;

  bool get isComposing => _currentMessage.text.isNotEmpty;
}

class ChatUserStore extends Store {
  ChatUserStore() {
    final String name = "Guest${new Random().nextInt(1000)}";
    final Color color =
        Colors.accents[new Random().nextInt(Colors.accents.length)][700];
    _me = new ChatUser(name: name, color: color);
    // This store does not currently handle any actions.
  }

  ChatUser _me;
  ChatUser get me => _me;
}

final StoreToken messageStoreToken = new StoreToken(new ChatMessageStore());
final StoreToken userStoreToken = new StoreToken(new ChatUserStore());

final Action<InputValue> setCurrentMessageAction = new Action<InputValue>();
final Action<ChatUser> commitCurrentMessageAction = new Action<ChatUser>();
