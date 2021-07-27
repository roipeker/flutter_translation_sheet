import 'package:dcli/dcli.dart';

/// Prints message to console using optional arguments to avoid
/// complex string interpolation.
void trace(
  dynamic arg1, [
  dynamic arg2 = '',
  dynamic arg3 = '',
  dynamic arg4 = '',
  dynamic arg5 = '',
  dynamic arg6 = '',
  dynamic arg7 = '',
  dynamic arg8 = '',
  dynamic arg9 = '',
  dynamic arg10 = '',
]) {
  final o =
      _getArgs(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10);
  print(o);
}

/// prints messages to console with optional arguments using "orange" pen.
void warning(
  dynamic arg1, [
  dynamic arg2 = '',
  dynamic arg3 = '',
  dynamic arg4 = '',
  dynamic arg5 = '',
]) {
  final o = _getArgs(arg1, arg2, arg3, arg4, arg5);
  print(orange(o));
}

/// prints messages to console with optional arguments using "red" pen.
void error(
  dynamic arg1, [
  dynamic arg2 = '',
  dynamic arg3 = '',
  dynamic arg4 = '',
  dynamic arg5 = '',
  dynamic arg6 = '',
  dynamic arg7 = '',
  dynamic arg8 = '',
  dynamic arg9 = '',
  dynamic arg10 = '',
]) {
  final o =
      _getArgs(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10);
  print(red(o));
}

String argsJoiner = '';

/// resolves the [trace] arguments as a unique String message to be printed
/// in console.
String _getArgs(
  dynamic arg1, [
  dynamic arg2 = '',
  dynamic arg3 = '',
  dynamic arg4 = '',
  dynamic arg5 = '',
  dynamic arg6 = '',
  dynamic arg7 = '',
  dynamic arg8 = '',
  dynamic arg9 = '',
  dynamic arg10 = '',
]) {
  return <dynamic>[
    '$arg1',
    if (arg2 != '') arg2,
    if (arg3 != '') arg3,
    if (arg4 != '') arg4,
    if (arg5 != '') arg5,
    if (arg6 != '') arg6,
    if (arg7 != '') arg7,
    if (arg8 != '') arg8,
    if (arg9 != '') arg9,
    if (arg10 != '') arg10,
  ].join(argsJoiner);
}
