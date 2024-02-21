# Workleap API design guidelines

## How to test the Spectral ruleset

Follow the instructions on [this link for installing spectral](https://docs.stoplight.io/docs/spectral/b8391e051b7d8-installation).

If using windows, we recommend running `npm install --global @stoplight/spectral-cli`. Once that installation completes, you may test the Spectral ruleset through the terminal with the command

```bash
spectral lint --ruleset .spectral.yaml <path to the openapi.yaml file>
```

This would trigger the validation of the openapi spec with the spectral ruleset.
