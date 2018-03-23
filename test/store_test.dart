// Copyright 2015 Workiva Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

@TestOn('vm')
import 'dart:async';

import 'package:flutter_flux/src/action.dart';
import 'package:flutter_flux/src/store.dart';
import 'package:quiver/testing/async.dart';
import 'package:test/test.dart';

void main() {
  group('Store', () {
    Store store;
    Action<Null> action;

    setUp(() {
      store = new Store();
      action = new Action<Null>();
    });

    tearDown(() {
      action.clearListeners();
      store.dispose();
    });

    test('should trigger with itself as the payload', () async {
      store.listen(expectAsync1((Store listenedStore) {
        expect(listenedStore, equals(store));
      }));

      store.trigger();
    });

    test('should trigger in response to an action', () {
      store.triggerOnAction(action);
      store.listen(expectAsync1((Store listenedStore) {
        expect(listenedStore, equals(store));
      }));
      action();
    });

    test(
        'should execute a given method and then trigger in response to an action',
        () async {
      bool wasTriggered = false;
      void onAction(Null _) {
        wasTriggered = true;
      }
      store.triggerOnAction(action, onAction);
      store.listen(expectAsync1((Store listenedStore) {
        expect(listenedStore, equals(store));
        expect(wasTriggered, isTrue);
      }));
      action();
    });

    test(
        'should execute a given method and then trigger in response to a conditional action',
        () {
      bool wasTriggered = false;
      bool onAction(Null _) {
        wasTriggered = true;
        return true;
      }
      store.triggerOnConditionalAction(action, onAction);
      store.listen(expectAsync1((Store listenedStore) {
        expect(listenedStore, equals(store));
        expect(wasTriggered, isTrue);
      }));
      action();
    });

    test(
        'should execute a given method but NOT trigger in response to a conditional action',
        () {
      new FakeAsync().run((FakeAsync async) {
        bool onAction(Null _) => false;
        store.triggerOnConditionalAction(action, onAction);
        store.listen((Store listenedStore) {
          fail('Event should not have been triggered');
        });
        action();
        async.flushMicrotasks();
      });
    });

    test(
        'should execute a given async method and then trigger in response to an action',
        () {
      bool afterTimer = false;
      Future<Null> asyncCallback(Null _) async {
        await new Future<Null>.delayed(new Duration(milliseconds: 30));
        afterTimer = true;
      }
      store.triggerOnAction(action, asyncCallback);
      store.listen(expectAsync1((Store listenedStore) {
        expect(listenedStore, equals(store));
        expect(afterTimer, isTrue);
      }));
      action();
    });

    test(
        'should execute a given method and then trigger in response to an action with payload',
        () {
      final Action<int> _action = new Action<int>();
      int counter = 0;
      store.triggerOnAction(_action, (int payload) => counter = payload);
      store.listen(expectAsync1((Store listenedStore) {
        expect(listenedStore, equals(store));
        expect(counter, equals(17));
      }));
      return _action(17);
    });
  });
}
