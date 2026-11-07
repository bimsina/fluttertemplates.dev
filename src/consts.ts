export const SITE_TITLE = "Flutter Templates";
export const SITE_DESCRIPTION =
  "An open-source library of Flutter UI. Preview every widget and full-app template live in your browser, then copy the source — free and MIT-licensed.";
export const GITHUB_URL = "https://github.com/bimsina/fluttertemplates.dev";
export const AGENT_PROMPT = `Set up Flutter Templates in this project.

1. Run: dart pub global activate fluttertemplates_dev
2. Add an MCP server named "fluttertemplates" to this tool's config.
   Command: fluttertemplates mcp
3. Add a short note to this project's agent instructions: check
   fluttertemplates before building a new screen from scratch.
4. Confirm it works by searching for "login". Don't add anything yet.

When I ask for a screen, search first and show me the closest matches.
Add it with the add_widget tool, or \`fluttertemplates add <id>\`, adapt it
to our theme and architecture, then run \`flutter analyze\`.

If the CLI can't be installed, use https://fluttertemplates.dev/llms.txt
to find screens and copy their source from the linked files.`;

export function addPrompt(title: string, id: string) {
  return `Add ${title} from Flutter Templates to this project.

Run: fluttertemplates add ${id}
If the command is missing, run: dart pub global activate fluttertemplates_dev
If that fails, copy the source from https://fluttertemplates.dev/r/${id}.md

Then adapt it to our theme and architecture, connect it to our existing code,
and run \`flutter analyze\`.`;
}
