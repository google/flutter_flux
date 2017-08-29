// Copyright 2016 The Chromium Authors. All rights reserved.
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

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'store.dart';

/// Signature for a function the lets the caller listen to a store.
typedef Store ListenToStore(StoreToken token, [ValueChanged<Store> onStoreChanged]);

/// A widget that rebuilds when the [Store]s it is listening to change.
abstract class StoreWatcher extends StatefulWidget {
  /// Creates a widget that watches stores.
  StoreWatcher({ Key key }) : super(key: key);

  /// Override this function to build widgets that depend on the current value
  /// of the store.
  @protected
  Widget build(BuildContext context, Map<StoreToken, Store> stores);

  /// Override this function to configure which stores to listen to.
  ///
  /// This function is called by [StoreWatcherState] during its
  /// [State.initState] lifecycle callback, which means it is called once per
  /// inflation of the widget. As a result, the set of stores you listen to
  /// should not depend on any constructor parameters for this object because
  /// if the parent rebuilds and supplies new constructor arguments, this
  /// function will not be called again.
  @protected
  void initStores(ListenToStore listenToStore);

  @override
  StoreWatcherState createState() => new StoreWatcherState();
}

/// State for a [StoreWatcher] widget.
class StoreWatcherState extends State<StoreWatcher> with StoreWatcherMixin<StoreWatcher> {

  final Map<StoreToken, Store> _storeTokens = <StoreToken, Store>{};

  @override
  void initState() {
    widget.initStores(listenToStore);
    super.initState();
  }

  /// Start receiving notifications from the given store, optionally routed
  /// to the given function.
  ///
  /// The default action is to call setState(). In general, you want to use the
  /// default function, which rebuilds everything, and let the framework figure
  /// out the delta of what changed.
  @override
  Store listenToStore(StoreToken token, [ValueChanged<Store> onStoreChanged]) {
    final Store store = super.listenToStore(token, onStoreChanged);
    _storeTokens[token] = store;
    return store;
  }

  @override
  Widget build(BuildContext context) {
    return widget.build(context, _storeTokens);
  }
}

/// Listens to changes in a number of different stores.
///
/// Used by [StoreWatcher] to track which stores the widget is listening to.
abstract class StoreWatcherMixin<T extends StatefulWidget> implements State<T>{
  final Map<Store, StreamSubscription<Store>> _streamSubscriptions = <Store, StreamSubscription<Store>>{};

  /// Start receiving notifications from the given store, optionally routed
  /// to the given function.
  ///
  /// By default, [onStoreChanged] will be called when the store changes.
  @protected
  Store listenToStore(StoreToken token, [ValueChanged<Store> onStoreChanged]) {
    final Store store = token._value;
    _streamSubscriptions[store] = store.listen(onStoreChanged ?? _handleStoreChanged);
    return store;
  }

  /// Stop receiving notifications from the given store.
  @protected
  void unlistenFromStore(Store store) {
    _streamSubscriptions[store]?.cancel();
    _streamSubscriptions.remove(store);
  }

  /// Cancel all store subscriptions.
  @override
  void dispose() {
    final Iterable<StreamSubscription<Store>> subscriptions =
      _streamSubscriptions.values;
    for (final StreamSubscription<Store> subscription in subscriptions)
      subscription.cancel();
    _streamSubscriptions.clear();
    super.dispose();
  }

  void _handleStoreChanged(Store store) {
    // TODO(abarth): We cancel our subscriptions in [dispose], which means we
    // shouldn't receive this callback when we're not mounted. If that's the
    // case, we should change this check into an assert that we are mounted.
    if (!mounted)
      return;
    setState(() { });
  }
}

/// Represent a store so it can be returned by [StoreListener.listenToStore].
///
/// Used to make sure that callers never reference the store without calling
/// listen() first. In the example below, _itemStore would not be globally
/// available:
///
/// ```dart
/// final _itemStore = new AppStore(actions);
/// final itemStoreToken = new StoreToken(_itemStore);
/// ```
class StoreToken {
  /// Creates a store token for the given store.
  StoreToken(this._value);

  final Store _value;

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType)
      return false;
    final StoreToken typedOther = other;
    return identical(_value, typedOther._value);
  }

  @override
  int get hashCode => identityHashCode(_value);

  @override
  String toString() => '[${_value.runtimeType}(${_value.hashCode})]';
}
