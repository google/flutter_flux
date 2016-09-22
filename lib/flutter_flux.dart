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

/// The flutter_flux library implements a unidirectional data flow pattern
/// comprised of [Action]s, [Store]s, and [StoreWatcher]s.
///
/// - [Action]s initiate mutation of app data that resides in [Store]s.
/// - Data mutations within [Store]s trigger re-rendering of a widget (defined
///   in [StoreWatcher]s).
/// - [StoreWatcher]s dispatch [Action]s in response to user interaction.

export 'src/action.dart';
export 'src/store.dart';
export 'src/store_watcher.dart';
