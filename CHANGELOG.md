## 1.0.0-alpha.5

- Add route validation.
- Improve code structure and formatting.

## 1.0.0-alpha.4

- Fix typos in `README.md`.

## 1.0.0-alpha.3

- Improve `README.md`.
- Fix a typo in `CHANGELOG.md`.

## 1.0.0-alpha.2

- Use `build_runner` instead of `webdev` for building.

## 1.0.0-alpha.1

- Hide inactive routes and fix route resolution.
- Add a guard for an extreme case in interaction with the navigator when `pop`
  is called quickly and in a row.
- Improve command-line tool
  - Force the command-line tool for the exits of child processes.
  - Remove the unnecessary pipes.

## 0.3.4

- Add `serve` and `build` commands.

## 0.3.3

- Improve `CHANGELOG.md`.

## 0.3.2

- Add a condition to avoid emptying the route entries when the history is
  popped.

## 0.3.1

- Fixe inconsistencies in the behavior of `Navigator`.

## 0.3.0

- Fix the unexpected behaviors of the Navigation API.
- Remove unnecessary errors thrown at runtime.

### Breaking Changes

- Switch to async functions for Navigation.

## 0.2.2

- Improve formatting.
- Improve the boilerplate.
- Improve the documentation.
- Fix a few typos in the documentation.

## 0.2.1

- Move the documentation from `README.md` to Navand's wiki.

## 0.2.0

- Update the boilerplate.
- Update the example.
- Update `README.md` and add documentation to it.
- Update the license.

### Breaking Changes

- Rename `PaintedNode.initializeElement` to `assembleElement`.
- Rename `PaintedNode.disposeElement` to `disassembleElement`.

## 0.1.0

- First **unstable** release.
