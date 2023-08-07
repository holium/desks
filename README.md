# Desks

The public source code for our urbit desks/agents. Uses the urbit repo as a submodule.

# Setup

```
# have `git pull` also get the pinned commit of the Urbit submodule
$: git config --global submodule.recurse true
# init submodule, and then pull it
$: git submodule update --init --recursive
$: git pull
```
