import fs from "fs";
import path from "path";
import { execSync } from "child_process";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Function to ensure directory exists
function ensureDirectoryExists(dirPath) {
  if (!fs.existsSync(dirPath)) {
    fs.mkdirSync(dirPath, { recursive: true });
  }
}

// Main build function
async function buildFlutterApps() {
  const flutterAppsDir = path.join(__dirname, "..", "flutter_apps");
  const publicDir = path.join(__dirname, "..", "public", "flutter_apps");

  // Ensure public directory exists
  ensureDirectoryExists(publicDir);

  // Get all directories in flutter_apps
  const folders = fs
    .readdirSync(flutterAppsDir)
    .filter((item) =>
      fs.statSync(path.join(flutterAppsDir, item)).isDirectory()
    );

  console.log("Found Flutter apps:", folders);

  // Build each Flutter app
  for (const folder of folders) {
    console.log(`\nBuilding ${folder}...`);
    const appPath = path.join(flutterAppsDir, folder);

    try {
      // Build Flutter web app
      execSync(
        `cd ${appPath} && flutter build web --wasm --base-href="/flutter_apps/${folder}/"`,
        {
          stdio: "inherit",
        }
      );

      // Copy build output to public directory
      const buildOutput = path.join(appPath, "build", "web");
      const targetDir = path.join(publicDir, folder);

      // Remove existing directory if it exists
      if (fs.existsSync(targetDir)) {
        fs.rmSync(targetDir, { recursive: true, force: true });
      }

      // Copy the build output
      fs.cpSync(buildOutput, targetDir, { recursive: true });
      console.log(
        `Successfully built and copied ${folder} to public/flutter_apps/${folder}`
      );
    } catch (error) {
      console.error(`Error building ${folder}:`, error.message);
    }
  }
}

// Run the build process
buildFlutterApps().catch(console.error);
