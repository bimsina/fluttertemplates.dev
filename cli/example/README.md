# Example

Add a login screen to a new Flutter app.

```sh
dart pub global activate fluttertemplates

flutter create my_app
cd my_app

fluttertemplates search login
fluttertemplates add auth/login_hero
```

`add` copies the source into your project and prints how to use it:

```text
created: lib/fluttertemplates/auth/login_hero.dart
created: lib/fluttertemplates/LICENSE

Use LoginHero from auth/login_hero:
  import 'package:my_app/fluttertemplates/auth/login_hero.dart';

  home: const LoginHero(),
```

Show it from `lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:my_app/fluttertemplates/auth/login_hero.dart';

void main() => runApp(const MaterialApp(home: LoginHero()));
```

## With a coding agent

Register the MCP server. In Claude Code:

```sh
claude mcp add fluttertemplates -- fluttertemplates mcp
```

Then ask for a screen:

> Use fluttertemplates to find a sign-up screen with a terms checkbox and add
> it to this project.
