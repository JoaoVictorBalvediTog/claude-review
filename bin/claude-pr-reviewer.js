import { init } from "../src/cli/init.js";

async function main() {
  const [, , command, ...args] = process.argv;

  if (!command || command === "--help" || command === "-h") {
    printHelp();
    return;
  }

  if (command === "init") {
    await init(args);
    return;
  }

  console.error(`Unknown command: ${command}`);
  printHelp();
  process.exit(1);
}

function printHelp() {
  console.log(`
Claude PR Reviewer

Usage:
  claude-pr-reviewer init [options]

Options:
  --force                 Overwrite existing workflow file.
  --action-repo <repo>    GitHub Action repository. Default: JoaoVictorBalvediTog/Reviewer
  --action-ref <ref>      GitHub Action ref. Default: v1
  --workflow-name <name>  Workflow file name. Default: claude-pr-review.yml

Examples:
  npx claude-pr-reviewer init
  npx claude-pr-reviewer init --action-repo JoaoVictorBalvediTog/Reviewer --action-ref v1
  npx claude-pr-reviewer init --force
`);
}

main().catch((error) => {
  console.error(error.message || error);
  process.exit(1);
});