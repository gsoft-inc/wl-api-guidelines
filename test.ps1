# Stop the script when a cmdlet or a native command fails
$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true

npm install --global @stoplight/spectral-cli
spectral --version

$ruleset = Join-Path $PSScriptRoot ".workleap.rules.yaml"

$testSpecs = @(
    @{ rule = "items-must-have-a-type"; expectError = $false; filename = "items-must-have-a-type-valid.yaml" },
    @{ rule = "items-must-have-a-type"; expectError = $true; filename = "items-must-have-a-type-invalid.yaml" },
    @{ rule = "must-accept-content-types"; expectError = $false; filename = "must-accept-content-types-valid.yaml" },
    @{ rule = "must-accept-content-types"; expectError = $true; filename = "must-accept-content-types-invalid.yaml" },
    @{ rule = "must-not-use-base-server-url"; expectError = $false; filename = "must-not-use-base-server-url-valid.yaml" },
    @{ rule = "must-not-use-base-server-url"; expectError = $true; filename = "must-not-use-base-server-url-invalid.yaml" },
    @{ rule = "must-return-content-types"; expectError = $false; filename = "must-return-content-types-valid.yaml" },
    @{ rule = "must-return-content-types"; expectError = $true; filename = "must-return-content-types-invalid.yaml" },
    @{ rule = "must-support-client-credentials-oauth2"; expectError = $false; filename = "must-support-client-credentials-oauth2-valid.yaml" },
    @{ rule = "must-support-client-credentials-oauth2"; expectError = $true; filename = "must-support-client-credentials-oauth2-invalid.yaml" },
    @{ rule = "path-schema-properties-must-have-a-type"; expectError = $false; filename = "path-schema-properties-must-have-a-type-valid.yaml" },
    @{ rule = "path-schema-properties-must-have-a-type"; expectError = $true; filename = "path-schema-properties-must-have-a-type-invalid.yaml" },
    @{ rule = "schemas-properties-must-have-a-type"; expectError = $false; filename = "schemas-properties-must-have-a-type-valid.yaml" },
    @{ rule = "schemas-properties-must-have-a-type"; expectError = $true; filename = "schemas-properties-must-have-a-type-invalid.yaml" },
    @{ rule = "schema-ids-must-have-alphanumeric-characters-only"; expectError = $false; filename = "schema-ids-must-have-alphanumeric-characters-only-valid.yaml" },
    @{ rule = "schema-ids-must-have-alphanumeric-characters-only"; expectError = $true; filename = "schema-ids-must-have-alphanumeric-characters-only-invalid.yaml" },
    @{ rule = "schema-object-must-have-a-type"; expectError = $false; filename = "schema-object-must-have-a-type-valid.yaml" },
    @{ rule = "schema-object-must-have-a-type"; expectError = $true; filename = "schema-object-must-have-a-type-invalid.yaml" },
    @{ rule = "schema-name-length-must-be-short"; expectError = $false; filename = "schema-name-length-must-be-short-valid.yaml" },
    @{ rule = "schema-name-length-must-be-short"; expectError = $true; filename = "schema-name-length-must-be-short-invalid.yaml" }
)



function RunSpectralTests($ruleset, $tests, $testSpecsPath)
{
    $fileCount = Get-ChildItem (Join-Path $PSScriptRoot $testSpecsPath) | Measure-Object | Select-Object -ExpandProperty Count
    if ($tests.Count -ne $fileCount) {
        throw "Number of tests does not match number of specs. Add the missing specs to the `$tests variable. Files: $fileCount, Tests: $($tests.Count)"
    }

    # We expect spectral to fail, so we need to capture the error
    foreach ($test in $tests) {
        $expectedError = $test.expectError
        $rule = $test.rule
        $spec = Join-Path $PSScriptRoot $testSpecsPath $test.filename

        if (!(Test-Path $spec)) {
            Write-Error "Spec file not found: $spec"
        }

        # Run spectral on a spec and capture the output to a temp json file
        $outputPath = [System.IO.Path]::GetTempFileName()
        spectral lint $spec --verbose --ruleset $ruleset --format json --output $outputPath
        $spectralOutput = Get-Content $outputPath

        # Parse the output file and count the number of errors for the rule
        $errorCount = $spectralOutput | ConvertFrom-Json | Where-Object { $_.code -eq "$rule" } | Measure-Object | Select-Object -ExpandProperty Count

        # Assert the result
        if ($errorCount -eq 0 -and $expectedError) {
            Write-Error "Expected error '$Rule' not found in $spec`n`n$($spectralOutput | ConvertFrom-Json | ConvertTo-Json)"
            exit 1
        }
        else {
            if ($errorCount -ne 0 -and -not $expectedError) {
                Write-Error "Unexpected error '$Rule' found in $spec`n`n$($spectralOutput | ConvertFrom-Json | ConvertTo-Json)"
                exit 1
            }
        }
    }
}

$PSNativeCommandUseErrorActionPreference = $false

RunSpectralTests $ruleset $testSpecs "TestSpecs"

Write-Host -ForegroundColor Green "All tests passed"

exit 0