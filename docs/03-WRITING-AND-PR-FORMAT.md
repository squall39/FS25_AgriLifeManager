# Writing and PR format

## Voice

Use plain, human wording. Keep sentences short and clear when possible.

Never use the em dash character anywhere in the project. Use a normal hyphen, a comma, parentheses, or split the sentence instead.

This rule applies to:

- commits;
- pull requests;
- release notes;
- README and documentation;
- code comments;
- in-game text;
- changelogs;
- ledger entries.

Before shipping a change, run `python3 tests/writing_style_spec.py`.

## Attribution and branding

Do not add automated authorship trailers, generator signatures, vendor branding, or vendor links to public project content.

Do not add these elements to:

- commits;
- pull requests;
- code comments;
- release notes;
- README files;
- public documentation;
- in-game text.

The project remains attributed to its human author. Internal agent notes may identify their source only where the project explicitly reserves a private ledger for that purpose.

## Review checklist

Before merge or release:

1. Scan for the em dash character.
2. Scan for automated attribution trailers.
3. Scan for vendor links or generator branding.
4. Keep the public author attribution unchanged.
5. Run the writing style test.
