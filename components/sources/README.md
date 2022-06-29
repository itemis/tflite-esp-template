Here live monolithic repositories as submodules which contain dependencies that are extracted to `components`.
Submodules from which code is extracted are kept in sources instead of deleting them after extraction.
This is done in order to preserve Git tracking.
This is necessary to be able to repeatedly execute `update_components.sh` which runs `git submodule update` such that latest updates are pulled.