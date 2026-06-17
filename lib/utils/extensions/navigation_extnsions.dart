// import 'package:flutter/material.dart';

// abstract base class RouteArgs {
//   const RouteArgs();
// }

// extension NavigationExtension on BuildContext {
//   void pop<T extends Object?>([T? result]) => Navigator.of(this).pop<T>(result);
//   bool get canPop => Navigator.of(this).canPop();

//   void shouldPop<T extends Object?>([T? result]) {
//     if (canPop) pop<T>(result);
//   }

//   Future<T?> pushNamed<T extends Object?, A extends RouteArgs>(String routeName, {A? arguments}) {
//     return Navigator.of(this).pushNamed<T>(routeName, arguments: arguments);
//   }

//   Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?, A extends RouteArgs>(String routeName, {A? arguments, TO? result}) {
//     return Navigator.of(this).pushReplacementNamed<T, TO>(routeName, arguments: arguments, result: result);
//   }

//   Future<T?> pushNamedAndRemoveUntil<T extends Object?, A extends RouteArgs>(String routeName, {A? arguments, bool Function(Route<dynamic>)? predicate}) {
//     return Navigator.of(this).pushNamedAndRemoveUntil<T>(routeName, predicate ?? (route) => false, arguments: arguments);
//   }

//   Future<T?> push<T extends Object?>(Route<T> route) => Navigator.of(this).push<T>(route);
// }

// extension RouteSettingsExtension on RouteSettings {
//   T args<T extends RouteArgs>() {
//     assert(arguments != null, 'Expected $T, Route arguments are null');
//     assert(arguments is T, 'Expected $T, got ${arguments.runtimeType}');
//     return arguments! as T;
//   }
// }
