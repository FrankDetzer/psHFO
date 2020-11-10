function Get-HumanFriendlyVolumeList {
    begin {
        $InputPath = Get-Volume
        $PreparedDataForEngine = @()
        $i = 1

    }

    process {
        foreach ($Item in $InputPath) {
            $i++
            Write-Progress -Activity 'Search in Progress'  -Status "$i% Complete:" -PercentComplete $i;

            $PreparedDataForEngine += [PSCustomObject][ordered]@{
                'Name'          = $Item.FriendlyName
                'Length'        = $Item.Length
                'SizeRemaining' = $Item.SizeRemaining
                'IsContainer'   = $null
                'FriendlyName1' = $Item.DriveLetter
                'FriendlyName2' = $Item.FriendlyName
                'FriendlyName3' = $null
            }
        }
    }

    end {
        FormatTo-HumanFriendlyOutput -InputObjectCollection $PreparedDataForEngine -FriendlyName1 'DriveLetter' -FriendlyName2 'FriendlyName'
    }
}