Here live monolithic repositories as submodules which contain dependencies that are extracted to `components`.
Submodules cannot be deleted because that stops Git tracking.
As a consequence `git submodule update` doesn't pull the submodules.