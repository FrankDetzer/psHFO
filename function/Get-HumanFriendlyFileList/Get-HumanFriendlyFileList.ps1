function Get-HumanFriendlyFileList {
    [CmdletBinding()]
    [alias("ncdu")]
    param (
        $Path = (Get-Location).Path
        # $Path = $env:USERPROFILE
    )

    begin {
        $InputPath = Get-ChildItem -Path $Path -Recurse:$false
        $PreparedDataForEngine = @()
        $i = 1
    }

    process {
        foreach ($Item in $InputPath) {
            $i++
            Write-Progress -Activity 'Search in Progress'  -Status "$i% Complete:" -PercentComplete $i;

            if ($Item.PSIsContainer) {
                $Length = (Get-ChildItem -Path $Item.FullName -Recurse:$true -File | Measure-Object Length -Sum).Sum

            }
            else {
                $Length = $Item.Length
            }

            if ($null -eq $Length) {
                $Length = 0
            }

            $PreparedDataForEngine += [PSCustomObject][ordered]@{
                'Name'          = $Item.Name
                'Length'        = $Length
                'IsContainer'   = $Item.PSIsContainer
                'PropertyName1' = $null
                'PropertyName2' = $null
                'PropertyName3' = $null
            }
        }
    }

    end {
        FormatTo-HumanFriendlyOutput -InputObjectCollection $PreparedDataForEngine
    }
}