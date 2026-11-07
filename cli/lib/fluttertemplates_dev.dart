/// The `fluttertemplates` command line tool.
///
/// This package is meant to be used as an executable; [run] is exposed so the
/// tool can be embedded and tested without spawning a process.
library;

export 'src/cli.dart' show CliContext, run;
export 'src/errors.dart' show CliException;
export 'src/version.dart' show packageVersion;
