#!/usr/bin/env node
// lint-skills.mjs — Structural linter for the test-automation-skills-agents repo.
//
// Verifies that every SKILL.md and its references conform to the repository's own
// anatomy standard (docs/skill-anatomy.md). This is the repo's "EVAL": a
// deterministic, dependency-free structural check that runs in CI and locally.
//
// Rules implemented (structural/syntactic only — no semantic judgments):
//   S1  Each skill folder has a SKILL.md.
//   S2  SKILL.md has YAML frontmatter with `name` and `description`.
//   S3  `name` matches the skill folder name.
//   S4  `description` <= 600 chars (rides in every consumer's system prompt).
//   S5  SKILL.md body <= 500 lines.
//   S6  Reference files <= 300 lines (WARNING, not a hard fail — large Java/POM
//       catalogs may be intentionally kept whole; flagged for review).
//   S7  Every reference file starts with a back-link header to SKILL.md.
//   S8  Intra-skill Markdown links resolve to existing files.
//   S9  No snake_case names for new reference/template `.md` files (kebab-case only).
//   S10 No `WebDriverManager` or `gradle` mentions in Selenium skills/agents/instructions.
//
// Exit code: 0 if zero ERRORS (warnings are allowed). Non-zero if any ERROR.

import { readFileSync, existsSync, readdirSync, statSync } from "node:fs";
import { join, dirname, basename, resolve, sep, normalize } from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const REPO_ROOT = resolve(__dirname, "..");

const ROOT = REPO_ROOT;
const SKILLS_DIR = join(ROOT, "skills");
const AGENTS_DIR = join(ROOT, "agents");
const INSTRUCTIONS_DIR = join(ROOT, "instructions");

const MAX_SKILL_LINES = 500;
const MAX_REF_LINES = 300; // advisory
const MAX_DESC_CHARS = 600;

let errors = 0;
let warnings = 0;
const findings = [];

function err(loc, rule, msg) {
  errors++;
  findings.push(`ERROR  ${rule}  ${loc}  — ${msg}`);
}
function warn(loc, rule, msg) {
  warnings++;
  findings.push(`WARN   ${rule}  ${loc}  — ${msg}`);
}

function rel(p) {
  return normalize(p).replace(REPO_ROOT + sep, "").replace(/\//g, "/");
}

function readLines(p) {
  return readFileSync(p, "utf8").replace(/\r\n/g, "\n").split("\n");
}

// --- Frontmatter extraction -------------------------------------------------
// Returns { raw, name, description, license } or null if no valid frontmatter.
function parseFrontmatter(filePath) {
  const text = readFileSync(filePath, "utf8").replace(/\r\n/g, "\n");
  const m = text.match(/^---\r?\n([\s\S]*?)\r?\n---/);
  if (!m) return null;
  const raw = m[1];
  const get = (key) => {
    // matches: key: 'value' | key: "value" | key: value | key: [ ... ]
    const re = new RegExp(`^${key}:\\s*(.+)$`, "m");
    const mm = raw.match(re);
    if (!mm) return null;
    let v = mm[1].trim();
    // strip surrounding quotes
    if (
      (v.startsWith("'") && v.endsWith("'")) ||
      (v.startsWith('"') && v.endsWith('"'))
    ) {
      v = v.slice(1, -1);
    }
    // strip trailing inline comment outside quotes
    return v;
  };
  return {
    raw,
    name: get("name"),
    description: get("description"),
    license: get("license"),
  };
}

// --- Collect skill folders --------------------------------------------------
function listSkillDirs() {
  return readdirSync(SKILLS_DIR)
    .map((d) => join(SKILLS_DIR, d))
    .filter((p) => statSync(p).isDirectory());
}

// --- Collect Markdown links inside a file, relative to that file ------------
const MD_LINK_RE = /\[[^\]]*\]\(([^)]+)\)/g;
function extractMarkdownLinks(filePath) {
  const text = readFileSync(filePath, "utf8").replace(/\r\n/g, "\n");
  const links = [];
  let m;
  while ((m = MD_LINK_RE.exec(text)) !== null) {
    let target = m[1].trim();
    // ignore external links and anchors
    if (/^https?:/i.test(target) || /^#/i.test(target) || target.startsWith("mailto:")) {
      continue;
    }
    // drop anchor fragments
    target = target.split("#")[0];
    if (!target) continue;
    links.push(target);
  }
  return links;
}

// --- S9: snake_case filename detection -------------------------------------
function isSnakeCase(name) {
  return /^[a-z]+(_[a-z0-9]+)+\.(md)$/i.test(name);
}

// ===========================================================================
// MAIN
// ===========================================================================

const skillDirs = listSkillDirs();

for (const skillDir of skillDirs) {
  const skillName = basename(skillDir);
  const skillMd = join(skillDir, "SKILL.md");
  const loc = rel(skillMd);

  // S1: SKILL.md exists
  if (!existsSync(skillMd)) {
    err(rel(skillDir), "S1", "skill folder has no SKILL.md");
    continue;
  }

  // S2/S3/S4: frontmatter
  const fm = parseFrontmatter(skillMd);
  if (!fm) {
    err(loc, "S2", "missing YAML frontmatter (--- name/description ---)");
    continue;
  }
  if (!fm.name) err(loc, "S2", "frontmatter missing `name`");
  if (!fm.description) err(loc, "S2", "frontmatter missing `description`");
  if (fm.name && fm.name !== skillName) {
    err(loc, "S3", `\`name\` ("${fm.name}") does not match folder ("${skillName}")`);
  }
  if (fm.description && fm.description.length > MAX_DESC_CHARS) {
    err(
      loc,
      "S4",
      `description is ${fm.description.length} chars (max ${MAX_DESC_CHARS})`
    );
  }

  // S5: SKILL.md line count
  const skillLines = readLines(skillMd).length;
  if (skillLines > MAX_SKILL_LINES) {
    err(loc, "S5", `SKILL.md is ${skillLines} lines (max ${MAX_SKILL_LINES})`);
  }

  // --- References ----------------------------------------------------------
  const refsDir = join(skillDir, "references");
  if (existsSync(refsDir)) {
    const refFiles = readdirSync(refsDir).filter((f) => f.endsWith(".md"));
    for (const rf of refFiles) {
      const refPath = join(refsDir, rf);
      const rloc = rel(refPath);

      // S6: reference line count (advisory)
      const rlines = readLines(refPath).length;
      if (rlines > MAX_REF_LINES) {
        warn(rloc, "S6", `reference is ${rlines} lines (target ${MAX_REF_LINES}) — consider splitting`);
      }

      // S7: back-link header in first 5 non-empty lines
      const head = readLines(refPath)
        .filter((l) => l.trim().length > 0)
        .slice(0, 5)
        .join("\n");
      if (!/SKILL\.md/i.test(head)) {
        err(rloc, "S7", "reference missing back-link header to SKILL.md (expected near top)");
      }

      // S9: snake_case reference name
      if (isSnakeCase(rf)) {
        err(rloc, "S9", `reference uses snake_case; rename to kebab-case ("${rf}")`);
      }
    }
  }

  // S8: intra-skill links resolve (check SKILL.md links)
  const links = extractMarkdownLinks(skillMd);
  for (const link of links) {
    const resolved = resolve(dirname(skillMd), link);
    if (!existsSync(resolved)) {
      err(loc, "S8", `broken link: "${link}"`);
    }
  }
  // S8: also check links inside each reference
  if (existsSync(refsDir)) {
    for (const rf of readdirSync(refsDir).filter((f) => f.endsWith(".md"))) {
      const refPath = join(refsDir, rf);
      for (const link of extractMarkdownLinks(refPath)) {
        const resolved = resolve(dirname(refPath), link);
        if (!existsSync(resolved)) {
          err(rel(refPath), "S8", `broken link: "${link}"`);
        }
      }
    }
  }
}

// --- S9: snake_case in templates/ ------------------------------------------
for (const skillDir of skillDirs) {
  const tplDir = join(skillDir, "templates");
  if (!existsSync(tplDir)) continue;
  for (const tf of readdirSync(tplDir)) {
    if (tf.endsWith(".md") && isSnakeCase(tf)) {
      err(rel(join(tplDir, tf)), "S9", `template uses snake_case; rename to kebab-case ("${tf}")`);
    }
  }
}

// --- S10: no WebDriverManager / gradle in Selenium content -----------------
// WebDriverManager is NEVER valid anywhere (Selenium 4.6+ has built-in Selenium
// Manager). Gradle is only forbidden in the two Selenium skills + the Selenium
// agent + the Selenium instructions (the repo standardizes Selenium Java on
// Maven only); Gradle remains legitimate for non-Selenium Java (e.g. REST Assured).
const GLOBAL_TERMS = [/WebDriverManager/gi];
const GRADLE_TERMS = [/\bgradle\b/gi];
const SELENIUM_GRADLE_DIRS = [
  join(SKILLS_DIR, "webapp-selenium-testing"),
  join(SKILLS_DIR, "accessibility-selenium-testing"),
  join(AGENTS_DIR, "selenium-test-specialist.agent.md"),
  join(INSTRUCTIONS_DIR, "selenium-webdriver-java.instructions.md"),
];
function scanFileForTerms(filePath, terms) {
  if (!existsSync(filePath)) return;
  const text = readFileSync(filePath, "utf8");
  const lines = text.replace(/\r\n/g, "\n").split("\n");
  lines.forEach((line, i) => {
    for (const re of terms) {
      if (re.test(line)) {
        err(`${rel(filePath)}:${i + 1}`, "S10", `forbidden Selenium term "${line.match(re)[0]}" (use Selenium Manager / Maven)`);
      }
      re.lastIndex = 0;
    }
  });
}
function walkMd(dir, terms) {
  if (!existsSync(dir)) return;
  const st = statSync(dir);
  if (!st.isDirectory()) {
    // single file path
    if (/\.(md|java|xml|ts|js|mjs)$/i.test(dir)) scanFileForTerms(dir, terms);
    return;
  }
  for (const entry of readdirSync(dir)) {
    const p = join(dir, entry);
    if (statSync(p).isDirectory()) {
      walkMd(p, terms);
    } else if (/\.(md|java|xml|ts|js|mjs)$/i.test(entry)) {
      scanFileForTerms(p, terms);
    }
  }
}
// WebDriverManager: forbidden repo-wide (skills + agents + instructions).
walkMd(SKILLS_DIR, GLOBAL_TERMS);
walkMd(AGENTS_DIR, GLOBAL_TERMS);
walkMd(INSTRUCTIONS_DIR, GLOBAL_TERMS);
// Gradle: forbidden only in Selenium-scoped locations.
for (const d of SELENIUM_GRADLE_DIRS) walkMd(d, GRADLE_TERMS);

// ===========================================================================
// REPORT
// ===========================================================================
findings.sort();
const label = (n, w) => `${n} error${n === 1 ? "" : "s"}`;
console.log("");
console.log("============================================================");
console.log(" lint-skills.mjs — structural audit of skills/agents/docs");
console.log("============================================================");
if (findings.length === 0) {
  console.log(" No findings. All structural checks passed.");
} else {
  for (const f of findings) console.log(" " + f);
}
console.log("------------------------------------------------------------");
console.log(` ${label(errors)} / ${warnings} warning${warnings === 1 ? "" : "s"} across ${skillDirs.length} skills`);
console.log("");

if (errors > 0) {
  process.exit(1);
}
process.exit(0);
