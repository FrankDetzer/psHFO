﻿function Get-HumanFriendlyVolumeList {
    [CmdletBinding()]

    begin {
        $InputPath = Get-Volume
        $obj = @()
        $i = 1
    }

    process {
        foreach ($Item in $InputPath) {
            $i++
            Write-Progress -Activity 'Search in Progress'  -Status "$i% Complete:" -PercentComplete $i;

            if ($Item.PSIsContainer) {
                $LengthInBytes = (Get-ChildItem -Path $Item.FullName -Recurse:$Recurse2 -File | Measure-Object Length -Sum).Sum

            }
            else {
                $LengthInBytes = $Item.Length
            }

            if ($null -eq $LengthInBytes) {
                $LengthInBytes = 0
            }


            $obj += [PSCustomObject][ordered]@{
                'Name'          = $Item.Name
                'LengthInBytes' = $LengthInBytes
                'IsContainer'   = $Item.PSIsContainer
            }
        }
    }

    end {
        FormatTo-HumanFriendlyOutput -InputObjectCollection $obj
    }
}