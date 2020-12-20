function Get-HumanFriendlyFileList {
    [alias('ncdu')]
    param (
        $Path = (Get-Location).Path,
        [validateset('Bytes', 'KB', 'MB', 'GB', 'TB')]
        [string]$Magnitude = 'MB'
    )

    begin {
        $InputPath = Get-ChildItem -Path $Path -Recurse:$false
        $PreparedDataForEngine = @()
        $Counter = 1
    }

    process {
        foreach ($Item in $InputPath) {
            $Counter++
            $PercentComplete = $Counter * $InputPath.Count / 100
            Write-Progress -Activity 'Search in Progress' -Status ([string]$Counter + '/' + [string]$InputPath.Count + ' (' + '{0:n2} %)' -f ($PercentComplete) + ' files indexed') -PercentComplete $PercentComplete

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
                'Name'        = $Item.Name
                'Length'      = $Length
                'Mode'        = $Item.Mode
                'IsContainer' = $Item.PSIsContainer
            }
        }
    }

    end {
        FormatTo-HumanFriendlyOutput -InputObjectCollection $PreparedDataForEngine -Magnitude $Magnitude -Path $Path
    }
}