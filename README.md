# Workleap API design guidelines

## How to test the Spectral ruleset

Follow the instructions on [this link for installing spectral](https://docs.stoplight.io/docs/spectral/b8391e051b7d8-installation) to install Spectral.
Once that installation completes, you may test the Spectral ruleset through the terminal with the command:

```bash
spectral lint --ruleset .spectral.yaml <path to the openapi.yaml file>
```

You can also run the PowerShell Core script `test.ps1` to run all tests.
