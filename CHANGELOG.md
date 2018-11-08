## 4.1.3

Fixed in the library:
* Add support for new mixin syntax from Dart 2
* Modified triggerOnConditionalAction() so that `onAction()` more accurately
  describes its behavior by returning `FutureOr<bool>` instead of `bool`.

## 4.1.2

* Fixed dependencies versions

## 4.1.1

* Updated iOS and Android build resources for Flutter beta.

## 4.1.0

Fix build errors with Flutter beta.

Fixed in the library:
* Error: A value of type '(dart.core::String) → dart.core::Null'
  can't be assigned to a variable of type '(dynamic) → dynamic'.
* Version in pubspec.yaml needs to be bumped.
* Error from `flutter analyze`: fix mixin_inherits_from_not_object.
  (Added analysis_options.)

Fixed in the example:
* Text editor for the message was broken because insert cursor was at
  the wrong position.

Finally, removed ThrottledStore from README and test - it's not used.

## 4.0.1

Rewrote the sample code to use StoreWatcherMixin

The StoreWatcher class has proved to be confusing to use. Most developers want
to add the Store functionality into an existing class, not add something else
into the hierarchy. Rewrote the sample code to show how to use StoreWatcherMixin
to add notifications to your own widget.
