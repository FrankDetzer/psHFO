function FormatTo-HumanFriendlyOutput {
    param (
        [parameter(ValueFromPipeline)]
        [psobject]$InputObject
        #     [parameter()]
        #     [ValidateSet('Stack', 'Comma')]
        #     [string]$OutputPropertyType = 'Stack'
        #     [string]$Name,
        #     [int]$Length
        #     [switch]$DataMagnitude = 'byte'
    )

    begin {
        $AllItems = @()
    }
    process {
        # Write-Progress -Activity "Search in Progress" # -Status "$i% Complete:" -PercentComplete $i;

        $AllItems += [PSCustomObject][ordered]@{
            'LengthInBytes'        = $InputObject.Length
            'SizeInPercent'        = $null
            'SizeInPercentRounded' = $null
            'SizeVisualised'       = $null
            'Name'                 = $InputObject.Name
            'IsFolder'             = $InputObject.PSIsContainer
        }
    }

    end {
        $TotalSize = ($AllItems | Measure-Object -Property LengthInBytes -Sum).Sum

        $AllItems | ForEach-Object -Process {
            $SizeInPercent = $_.LengthInBytes / $TotalSize * 100
            $SizeInPercentRounded = ([math]::round(([math]::round($SizeInPercent) / 10)))

            if ($SizeInPercentRounded -ge 1) {
                $SizeVisualised = ($SizeInPercentRounded..1 | ForEach-Object -Process { '#' }) -join ''
            }
            else {
                $SizeVisualised = $null
            }

            $_.SizeInPercent = $SizeInPercent
            $_.SizeInPercentRounded = $SizeInPercentRounded
            $_.SizeVisualised = $SizeVisualised
        }

        # foreach ($Item in $AllItems) {
        #     $Item.LengthInBytes
        # }

        $AllItems | Sort-Object LengthInBytes -Descending
    }

}