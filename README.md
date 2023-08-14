# Desks

The public source code for Holium's urbit desks/agents. Uses the urbit repo as a submodule.

## Setup

```
# have `git pull` also get the pinned commit of the Urbit submodule
$: git config --global submodule.recurse true
# init submodule, and then pull it
$: git submodule update --init --recursive
$: git pull
```

## Agents

- `%bazaar`: handles app installs, the app suite, and recommended apps
- `%bedrock`: a common database system for p2p apps
  - `%api-store`: pulls from `%s3-store` or `%storage` and stores the bucket credentials in `%bedrock` 
- `%bulletin`: an agent for storing featured spaces and featured chats
- `%chat-db`: the chat agent for Realm and Courier
  - `%realm-chat`: a simple interface into `%chat-db` for dms and group chats
  - `%spaces-chat`: a simple interface into `%chat-db` for chats created for a space.
- `%friends`: syncs with `%pals` and stores friends and contact metadata.
- `%notif-db`: the notification backend for Realm.
- `%os-trove`: a shared filesystem for spaces
- `%realm-wallet`: an agent that stores wallet metadata and basic wallet permissioning (but never stores the private keys -- those are always stored on device)
- `%spaces`: our group primitive for Realm, manages invites, themes, member permissions, and other metadata.
