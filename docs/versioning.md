# ![DB Shepherd](/images/dbshepherd.png) DB Shepherd Versioning

DB Shepherd uses a versioning system called Gamever. It accepts naming
conventions from [Semver](https://semver.org), but without the rules for
version compatibility.

## Gamever Q&A
### Gamever's awesome! Why wouldn't I use it?
Gamever is not appropriate for software libraries or infrastructure projects.
Basically, anything that you build upon. For all of that stuff, please use
[Semver](https://semver.org). For everything else, Gamever is just more fun!

### What's the main idea behind Gamever?
With Gamever, instead of just bumping up the version at regular intervals, or
picking new versions on a calendar schedule, you decide whether work is
equivalent to a major, minor, or patch release and bump the version up to the
appropriate number.

It helps with making your roadmap a bit more transparent, as you have to plan
and publish version bounties. It also shines a light on your contributors,
which is always good with open source.

### Is there anything else? Why do versions jump?
**Yes!** While you reset lower versions like in any other versioning scheme
(e.g. from 2.7.1 to 3.0.0), with Gamever you add up the points with each
release.

For a concrete example, if you were at version 1.1.1, and your next release
contains two patch-level changes, then the next version released would be
1.1.3. If, after that the next release contained one major release feature and
one patch release feature, the new version would be 2.0.1.

### What does that mean for release schedules?
We recommend releasing early and often, but ultimately this is up to you and
your project. The more work that gets done between releases, the larger the
version jumps will be between releases.

### Doesn't this make it harder to do incremental work? Won't large features block releases?
We encourage you to break up major version work into a series of minor and/or
patch features as well. This way, anyone who completes one of the minor or
patch features gets credit for that work, and everyone shares credit for the
major milestone.

### That's it?
Yeah, pretty much.
