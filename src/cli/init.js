const fs = require("fs");
const path = require("path");

function parseArgs(args) {
  const options = {
    force: false,
    actionRepo: "empresa/claude-pr-reviewer",
    actionRef: "v1",
    workflowName: "claude-pr-review.yml",
  };

  for (let index = 0; index < args.length; index += 1) {
    const arg = args[index];

    if (arg === "--force") {
      options.force = true;
      continue;
    }

    if (arg === "--action-repo") {
      options.actionRepo = readRequiredValue(args, index, arg);
      index += 1;
      continue;
    }

    if (arg === "--action-ref") {
      options.actionRef = readRequiredValue(args, index, arg);
      index += 1;
      continue;
    }

    if (arg === "--workflow-name") {
      options.workflowName = readRequiredValue(args, index, arg);
      index += 1;
      continue;
    }

    throw new Error(`Unknown option: ${arg}`);
  }

  return options;
}

function readRequiredValue(args, index, optionName) {
  const value = args[index + 1];

  if (!value || value.startsWith("--")) {
    throw new Error(`Missing value for ${optionName}`);
  }

  return value;
}

function renderWorkflow({ actionRepo, actionRef }) {
  return `name: Claude PR Review

on:
  pull_request:
    types: [opened, synchronize, reopened]

permissions:
  contents: read
  pull-requests: write

jobs:
  claude-review:
    runs-on: ubuntu-latest

    steps:
      - name: Run Claude PR Reviewer
        uses: ${actionRepo}@${actionRef}
        with:
          repository: \${{ github.repository }}
          pull_request_number: \${{ github.event.pull_request.number }}
          run_mode: comment_review
        env:
          ANTHROPIC_API_KEY: \${{ secrets.ANTHROPIC_API_KEY }}
          GITHUB_TOKEN: \${{ secrets.GITHUB_TOKEN }}
`;
}

async function init(args) {
  const options = parseArgs(args);

  const rootDir = process.cwd();
  const workflowsDir = path.join(rootDir, ".github", "workflows");
  const workflowPath = path.join(workflowsDir, options.workflowName);

  if (fs.existsSync(workflowPath) && !options.force) {
    throw new Error(
      [
        `Workflow already exists: ${relative(workflowPath)}`,
        "Use --force to overwrite it.",
      ].join("\n")
    );
  }

  fs.mkdirSync(workflowsDir, { recursive: true });

  const workflow = renderWorkflow({
    actionRepo: options.actionRepo,
    actionRef: options.actionRef,
  });

  fs.writeFileSync(workflowPath, workflow, "utf8");

  console.log("");
  console.log("Claude PR Reviewer installed.");
  console.log("");
  console.log("Created:");
  console.log(`- ${relative(workflowPath)}`);
  console.log("");
  console.log("Required GitHub secret:");
  console.log("- ANTHROPIC_API_KEY");
  console.log("");
  console.log("The workflow uses:");
  console.log(`- ${options.actionRepo}@${options.actionRef}`);
  console.log("");
  console.log("Next steps:");
  console.log("1. Commit the generated workflow.");
  console.log("2. Add ANTHROPIC_API_KEY in GitHub repository or organization secrets.");
  console.log("3. Open or update a pull request to trigger the reviewer.");
  console.log("");
}

function relative(filePath) {
  return path.relative(process.cwd(), filePath).replaceAll(path.sep, "/");
}

module.exports = {
  init,
};