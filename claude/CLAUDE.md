# Global guidance (applies in every project)

## Secrets stay on this machine

Treat these as sensitive by default: `.env*`, `*.pem`, `*.key`, `id_*`,
`*.p12`, `*.pfx`, `*.tfvars`, `credentials*`, `secrets*`, `*.kdbx`,
`~/.ssh`, `~/.aws`, `~/.config/gh`, `~/.netrc`, keychain and browser data.

Before any action that sends content off this machine (git commit, git push,
`gh pr create`, `gh gist`, issue or PR comments, publishing an artifact,
uploading a file, POSTing to a third-party API):

1. Read the exact content that will leave. For commits, run `git diff --cached`
   and read the whole diff, including new files.
2. Scan it for API keys, tokens, passwords, private keys, connection strings,
   session cookies, hostnames with embedded credentials, and personal data
   (emails, phone numbers, home addresses) that is not already public.
3. If anything sensitive is present, stop and report what you found and where.
   Leave the working tree and index untouched. I decide how to handle it.

Secrets live in gitignored `.env` files or the OS keychain, and code reads
them from the environment. In a new project, add `.env*` and key files to
`.gitignore` before the first commit. Commit a `.env.example` with placeholder
values instead of real ones.

If you discover a secret already in git history, report it before doing
anything else. Rotating the key and rewriting history are my call.

When you need to show me a secret's value while debugging, show only its
first four and last four characters.
