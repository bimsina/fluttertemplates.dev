import 'dart:convert';
import 'dart:io';

import 'package:fluttertemplates/fluttertemplates.dart';

Future<void> main(List<String> args) async {
  // Widget sources and MCP payloads are UTF-8 whatever the console default is.
  stdout.encoding = utf8;
  stderr.encoding = utf8;

  try {
    exitCode = await run(args);
    await stdout.flush();
    await stderr.flush();
  } on FileSystemException catch (e) {
    // The reader went away, as in `fluttertemplates list | head`. Nobody is
    // left to tell, and it is no failure of ours.
    if (_isBrokenPipe(e)) exit(0);
    stderr.writeln('Error: $e');
    exitCode = 1;
  }
}

/// EPIPE on POSIX; ERROR_BROKEN_PIPE and ERROR_NO_DATA on Windows.
bool _isBrokenPipe(FileSystemException e) =>
    const {32, 109, 232}.contains(e.osError?.errorCode);
