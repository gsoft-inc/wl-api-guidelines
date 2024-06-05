# Workleap API design guidelines

## How to test the Spectral ruleset

Follow the instructions on [this link for installing spectral](https://docs.stoplight.io/docs/spectral/b8391e051b7d8-installation) to install Spectral.
Once that installation completes, you may test the Spectral ruleset through the terminal with the command:

For Backend to Backend OpenAPI spec:

```bash
spectral lint --ruleset .spectral.backend.yaml <path to the openapi.yaml file>
```

For Backend For Frontend OpenAPI spec:

```bash
spectral lint --ruleset .spectral.frontend.yaml <path to the openapi.yaml file>
```

You can also run the PowerShell Core script `test.ps1` to run all tests.
