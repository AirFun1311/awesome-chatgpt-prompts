Describe 'Assign_Agency_Icons' {
    BeforeAll {
        $TestRoot = Join-Path -Path $env:TMP -ChildPath "BND_Matrix_Test_$(Get-Random)"
        $Script = Join-Path -Path (Split-Path -Parent $PSCommandPath) -ChildPath '..\Assign_Agency_Icons.ps1'
        # Minimal structure
        New-Item -ItemType Directory -Path (Join-Path $TestRoot '11_BLACKBOX') -Force | Out-Null
    }

    AfterAll {
        if (Test-Path -LiteralPath $TestRoot) { Remove-Item -LiteralPath $TestRoot -Recurse -Force -ErrorAction SilentlyContinue }
    }

    It 'returns failure when icon not found' {
        $map = @{ '11_BLACKBOX' = (Join-Path $TestRoot 'missing.ico') }
        $res = & $Script -RootPath $TestRoot -FolderToIconMap $map -CreateIfMissing
        $item = $res | Where-Object { $_.Folder -like "*11_BLACKBOX" }
        $item.Applied | Should -BeFalse
    }
}

