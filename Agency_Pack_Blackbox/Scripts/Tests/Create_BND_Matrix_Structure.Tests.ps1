Describe 'Create_BND_Matrix_Structure' {
    BeforeAll {
        $TestRoot = Join-Path -Path $env:TMP -ChildPath "BND_Matrix_Test_$(Get-Random)"
        $Script = Join-Path -Path (Split-Path -Parent $PSCommandPath) -ChildPath '..\Create_BND_Matrix_Structure.ps1'
    }

    AfterAll {
        if (Test-Path -LiteralPath $TestRoot) { Remove-Item -LiteralPath $TestRoot -Recurse -Force -ErrorAction SilentlyContinue }
    }

    It 'creates root and top-level folders' {
        $result = & $Script -RootPath $TestRoot -TopLevelFolders @('A','B','C')
        Test-Path -LiteralPath $result | Should -BeTrue
        Test-Path -LiteralPath (Join-Path $result 'A') | Should -BeTrue
        Test-Path -LiteralPath (Join-Path $result 'B') | Should -BeTrue
        Test-Path -LiteralPath (Join-Path $result 'C') | Should -BeTrue
    }

    It 'is idempotent on second run' {
        & $Script -RootPath $TestRoot -TopLevelFolders @('A','B','C') | Out-Null
        & $Script -RootPath $TestRoot -TopLevelFolders @('A','B','C') | Out-Null
        Test-Path -LiteralPath (Join-Path $TestRoot 'A') | Should -BeTrue
    }
}

