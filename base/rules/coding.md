---
description: Code style, language conventions, testing requirements
---

# Coding Standards

## General

- Write code that reads like prose. Clear names > clever tricks.
- Follow the language's community conventions (PEP 8 for Python, StandardJS for JS, etc.).
- Match the existing codebase style. Don't introduce a new pattern when one already exists.
- Prefer standard library over third-party when the difference is marginal.

## Testing

- Write tests for new functionality. No exceptions.
- Test behavior, not implementation. Tests should survive refactoring.
- Name tests descriptively: `test_returns_empty_list_when_no_matches`.
- Keep test files next to source or in a parallel `tests/` tree — match the project convention.

## Error Handling

- Handle errors at the boundary where you can do something useful.
- Don't catch exceptions just to re-raise them.
- Fail loudly on unexpected states — silent failures compound.

## Dependencies

- Justify every new dependency. Prefer fewer, well-maintained packages.
- Pin versions in lock files. Use ranges in manifest files only when appropriate.
- Check license compatibility before adding a dependency.
