# fitbit

`MyFitbitData.zip` is a one-off Fitbit takeout export. `nix build` turns it into
`result/fitbit.db`, which Datasette serves at <https://fitbit.jamesst.one>.

```sh
nix build
nix develop -c sqlite-utils tables --counts result/fitbit.db
```

There is no live data source: refreshing the site means committing a newer
export and re-running the `Build DB` workflow.
