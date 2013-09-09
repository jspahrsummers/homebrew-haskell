# Homebrew-Haskell
Haskell related formulæ for [Homebrew](http://brew.sh).

### How do I install these formulæ?
Just `brew tap darinmorrison/haskell` then `brew install <formula>`.

_Read more about how Homebrew taps work [here](https://github.com/mxcl/homebrew/wiki/brew-tap)._

##### NOTE:
Some of these formulæ may have name conflicts with existing formulæ from other tapped repositories or from the main Homebrew repository at [mxcl/homebrew][]. When that happens, you can still install the versions from this repository by using the fully qualified name `darinmorrison/haskell/<formula>`.

### Can I install these formulæ without tapping the repository?
Of course! You can install any individual formula by specifying its URL:

    brew install https://raw.github.com/darinmorrison/homebrew-haskell/master/<formula>.rb

### Why the duplicates of  [mxcl/homebrew][] formulæ?
This repository is part of a project undertaken to help improve the state of Haskell formulæ for all Homebrew users. Much of the work here takes the form of patches to existing formulæ to fix bugs, compatibility issues, port new versions, etc.

These patches mostly find their way back to the main Homebrew repository but that can take time. We have to to work through the pull requests, discussion, refactors, merges, etc. before making new stuff available there. Here, people can play around with new stuff immediately! :grinning:

However, not all of the changes and improvements from here get merged into the main Homebrew repository. This can happen for a variety of reasons, ranging from stylistic to philosophical to practical, etc.. In those cases, I often still find it worthwhile to have somewhere to offer the unabridged, uncut, original submissions.

This repository is also intended to hold Haskell related formulæ, functionality, and tools that perhaps don't fit within the main Homebrew repository. Examples may include formulæ with added configuration options useful especially to developers or researchers but where the complexity trade off is not deemed worthwhile in general.

### Docs
`brew help`, `man brew`, or the Homebrew [wiki][].

[mxcl/homebrew]:https://github.com/mxcl/homebrew
[wiki]:http://wiki.github.com/mxcl/homebrew
