# Stop the script when a cmdlet or a native command fails
$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true

npm install --global @stoplight/spectral-cli
spectral --version

$ruleset = Join-Path $PSScriptRoot ".spectral.yaml"

$tests = @(
    @{ rule = "must-accept-content-types"; expectError = $false; filename = "must-accept-content-types-valid.yaml" },
    @{ rule = "must-accept-content-types"; expectError = $true; filename = "must-accept-content-types-invalid.yaml" },
    @{ rule = "must-have-security-schemes"; expectError = $false; filename = "must-have-security-schemes-valid.yaml" },
    @{ rule = "must-have-security-schemes"; expectError = $true; filename = "must-have-security-schemes-invalid.yaml" },
    @{ rule = "must-return-content-types"; expectError = $false; filename = "must-return-content-types-valid.yaml" },
    @{ rule = "must-return-content-types"; expectError = $true; filename = "must-return-content-types-invalid.yaml" },
    @{ rule = "must-support-client-credentials-oauth2"; expectError = $false; filename = "must-support-client-credentials-oauth2-valid.yaml" },
    @{ rule = "must-support-client-credentials-oauth2"; expectError = $true; filename = "must-support-client-credentials-oauth2-invalid.yaml" },
    @{ rule = "properties-must-have-a-type"; expectError = $false; filename = "properties-must-have-a-type-in-path-valid.yaml" },
    @{ rule = "properties-must-have-a-type"; expectError = $false; filename = "properties-must-have-a-type-in-schema-valid.yaml" },
    @{ rule = "properties-must-have-a-type"; expectError = $true; filename = "properties-must-have-a-type-in-path-invalid.yaml" },
    @{ rule = "properties-must-have-a-type"; expectError = $true; filename = "properties-must-have-a-type-in-schema-invalid.yaml" },
    @{ rule = "schema-ids-must-have-alphanumeric-characters-only"; expectError = $false; filename = "schema-ids-must-have-alphanumeric-characters-only-valid.yaml" },
    @{ rule = "schema-ids-must-have-alphanumeric-characters-only"; expectError = $true; filename = "schema-ids-must-have-alphanumeric-characters-only-invalid.yaml" },
    @{ rule = "schema-object-must-have-a-type"; expectError = $false; filename = "schema-object-must-have-a-type-valid.yaml" },
    @{ rule = "schema-object-must-have-a-type"; expectError = $true; filename = "schema-object-must-have-a-type-invalid.yaml" },
    @{ rule = "unexpected-error-default-response"; expectError = $false; filename = "unexpected-error-default-response-valid.yaml" },
    @{ rule = "unexpected-error-default-response"; expectError = $true; filename = "unexpected-error-default-response-invalid.yaml" }
)

$fileCount = Get-ChildItem (Join-Path $PSScriptRoot "TestSpecs") | Measure-Object | Select-Object -ExpandProperty Count
if ($tests.Count -ne $fileCount) {
    throw "Number of tests does not match number of specs. Add the missing specs to the `$tests variable. Files: $fileCount, Tests: $($tests.Count)"
}

# We expect spectral to fail, so we need to capture the error
$PSNativeCommandUseErrorActionPreference = $false
foreach ($test in $tests) {
    $expectedError = $test.expectError
    $rule = $test.rule
    $spec = Join-Path $PSScriptRoot "TestSpecs" $test.filename

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

Write-Host -ForegroundColor Green "All tests passed"