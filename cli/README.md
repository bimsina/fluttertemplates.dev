# fluttertemplates

Find Flutter screens from [fluttertemplates.dev](https://fluttertemplates.dev)
and copy them into your project. You get plain source files that you own and
can edit, not a package to depend on.

```sh
dart pub global activate fluttertemplates_dev
```

## Usage

```sh
fluttertemplates list                     # everything, by category
fluttertemplates list --category auth
fluttertemplates search login form        # by title, description, category, Flutter widgets
fluttertemplates info auth/signup_terms
fluttertemplates add auth/signup_terms    # run inside a Flutter project
```

### Adding widgets

```sh
fluttertemplates add <id>... [--dir lib/fluttertemplates] [--force] [--dry-run]
```

`add` works from anywhere inside a Flutter project. Files go under `--dir`,
which is relative to the project root, and keep their path from the library, so
relative imports between the files of a template stay valid:

```text
$ fluttertemplates add navigation/bottom_navigation/google_bottom_bar
created: lib/fluttertemplates/navigation/bottom_nav/google_bottom_bar.dart
created: lib/fluttertemplates/LICENSE
ran: flutter pub add salomon_bottom_bar:^3.3.2

Use GoogleBottomBar from navigation/bottom_navigation/google_bottom_bar:
  import 'package:my_app/fluttertemplates/navigation/bottom_nav/google_bottom_bar.dart';

  home: const GoogleBottomBar(),
```

- `add` is all or nothing. An unknown id or a conflict stops it before anything
  changes. If `flutter pub add` or a file write fails, `pubspec.yaml`,
  `pubspec.lock` and every file it touched are put back. Files that Flutter
  generates, such as `.dart_tool`, are not: `flutter pub get` refreshes them.
  A process that is killed outright cannot undo anything.
- The library is MIT licensed, and its notice has to stay with the code, so
  `add` writes a `LICENSE` file from the registry at the top of `--dir`, once.
  One that is already there is left alone if identical, and is otherwise a
  conflict that only `--force` replaces. `info` shows the license too.
- Existing files with different content are conflicts, and are only replaced
  with `--force`. Files that are already identical are left alone, so running
  `add` twice is safe.
- Missing packages are installed with `flutter pub add`, as a caret constraint
  on the version the library was tested with. Packages already under
  `dependencies:` are not touched, whatever their version.
- `--dry-run` reports all of this without changing anything.

## MCP server

`fluttertemplates mcp` is a [Model Context Protocol](https://modelcontextprotocol.io)
server on stdio, so coding agents can use the library. Its tools are
`search_widgets`, `get_widget`, `list_categories` and `add_widget`, which copies
widgets into a project the same way `add` does. The `addCommand` from
`get_widget` names the registry when it is not the default one, and the
catalogue is cached for five minutes.

```json
{
  "mcpServers": {
    "fluttertemplates": {
      "command": "fluttertemplates",
      "args": ["mcp"]
    }
  }
}
```

## Choosing a registry

Every command reads from `https://fluttertemplates.dev/r` unless told otherwise:

```sh
fluttertemplates --registry ./public/r list         # a local directory
FLUTTERTEMPLATES_REGISTRY=https://example.com/r fluttertemplates list
```

`--registry` wins over the environment variable, and works before or after the
command name. A registry that declares a `license` has to serve a `LICENSE` file
next to `index.json`.

## Exit codes

| Code | Meaning                                                        |
| ---- | -------------------------------------------------------------- |
| 0    | Success, including a search with no results                    |
| 1    | Failure: unknown id, conflict, network, registry or install    |
| 64   | Wrong usage                                                    |

## License

MIT
