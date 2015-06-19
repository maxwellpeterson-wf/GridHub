# GridHub
> Multi-repository grid view

Currently hosted at [http://gridhub.club](http://gridhub.club). Uses local storage, so no GridHub data persists beyond your browser. 

_Will need a Github username and access token to access private repositories. The access token only needs the default access permissions (repo, public_repo, user)._

![screenshot](https://www.dropbox.com/s/9duh4v49mm4dedo/Screenshot%202015-01-30%2013.46.05.png?dl=1)

## Keyboard Shortcuts

Shortcut  | What it does
------------ | ------------------
**`1`** ... **`0`**   | Switch pages _(press `3` to go to the third page)_
**`R`**            | Refresh
**`A`**           | Readme pane
**`S`**           | Tags pane
**`D`**           | Issues pane
**`F`**           | Pull Requests pane
**`G`**          | Unreleased PRs pane
**`H`**          | Milestones pane
**`O`**          | Open
**`P`**          | Closed

## Setup

You'll need the Dart SDK if you don't already have it:

```bash
brew tap dart-lang/dart && brew install dart
```

Open command line to the root of this repo:

1. `bower install`
2. `pub get`
3. `pub build`
4. `pub serve`
5. Enjoy.

