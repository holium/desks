## Troubleshooting app installations using %bazaar

### No apps found on ship

Installing apps from another ship is a multi-step process:

- Form alliance with remote ship
- Draw-up treaties thru alliance
- Install docket (ship/desk) once treaties available

#### Forming an alliance with a ship

When a valid patp is entered into the bazaar our/space search bar, bazaar will make the remote ship an ally. During this step:

- A temporary conduit is established
- UI issues an ally-update-0 poke (add) to the treaty agent and waits
- bazaar subscribes to treaty/treaties watch path to get treaty updates

In step 2, once the ally record is added to treaty, the treaty agent will connect to the remote ship, form an alliance, and "download" treaties (apps available for download) from the remote ship's directory. Much of this happens "behind-the-scenes" on the backend. When treaties (app contracts) are added to the local ship, step 3 commences and the UI displays apps as they are added to the treaty store.

If adding an ally and/or forming an alliance fails for whatever reason, and no treaties are retrieved from the remote ship within a set time period, the UI will show a message indicating no apps are available for installation.

In testing, there are two common causes for this: 1) the remote ship is not online (either the ship is not running or it is running in a breached state) which makes it unavailable to form an alliance, or 2) apps have not been published to the treaty agent.

1. Remote Ship Not Available

**Not Running**
To test if a remote ship is online, simply run `|hi <ship>` (be sure to include the `~` in front of the ship name). If the ship is running and available on the network, you should see a message similiar to the following: `; ~<ship-name> is your neighbor`. If you do not get this message in the dojo, your ship is either not running or has been breached.

**Breach**
If your ship has been breached, and cannot be located on the network, you will need to do a factory reset. If you are running moons, check out this documentation for more information: https://operators.urbit.org/manual/os/basics#restoring-moons.

2. Apps Not Published
   In order for apps to made available for download/installation, they must be published using the treaty agent. To publish an app using the treaty agent, run the following command:

`:treaty|publish <desk>`

e.g. `:treaty|publish %hello`

## Notes

- If a remote ship is successfully added as an ally, but the alliance/treaties are not processed completely, you do not need to take further action. In this case, the treaty agent will watch the remote ship and, if the ship is brought back online and/or new treaties are published, the local treaty agent will pick up updates as they are generated.

To ensure that an ally is added to the local ship, run the following command: `:treaty +dbug [%state %allies]` and look for the remote ship in the treaties store that is printed in the dojo.

Here is a sample output from the command:

```
{ [p=~misbud-windus-lodlev-migdev q={[ship=~misbud-windus-lodlev-migdev desk=%hello]}]
  [ p=~dister-dozzod-dozzod
      q
    { [ship=~lander-dister-dozzod-dozzod desk=%landscape]
      [ship=~mister-dister-dozzod-dozzod desk=%webterm]
      [ship=~mister-dister-dozzod-dozzod desk=%bitcoin]
    }
  ]
}
```

Looking at this, we can see that `~misbud-windus-lodlev-migdev` and `~dister-dozzod-dozzod` are allies with our local ship.
