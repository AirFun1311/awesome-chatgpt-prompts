Describe 'Update_BND_Matrix' {
    BeforeAll {
        $TestRoot = Join-Path -Path $env:TMP -ChildPath "BND_Matrix_Test_$(Get-Random)"
        $Script = Join-Path -Path (Split-Path -Parent $PSCommandPath) -ChildPath '..\Update_BND_Matrix.ps1'
    }

    AfterAll {
        if (Test-Path -LiteralPath $TestRoot) { Remove-Item -LiteralPath $TestRoot -Recurse -Force -ErrorAction SilentlyContinue }
    }

    It 'creates 11_BLACKBOX structure' {
        $dirs = & $Script -RootPath $TestRoot
        $base = Join-Path $TestRoot '11_BLACKBOX'
        Test-Path -LiteralPath $base | Should -BeTrue
        'SNIPPETS','TOOLS','DOCS','LOGS' | ForEach-Object {
            Test-Path -LiteralPath (Join-Path $base $_) | Should -BeTrue
        }
    }

    It 'is idempotent on second run' {
        & $Script -RootPath $TestRoot | Out-Null
        & $Script -RootPath $TestRoot | Out-Null
        Test-Path -LiteralPath (Join-Path $TestRoot '11_BLACKBOX') | Should -BeTrue
    }
}

