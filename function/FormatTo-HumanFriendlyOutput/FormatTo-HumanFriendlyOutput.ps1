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
        $AllItems += [PSCustomObject][ordered]@{
            'LengthInBytes'        = $InputObject.Length
            'SizeInPercent'        = $null
            'SizeInPercentRounded' = $null
            'SizeVisualised'       = $null
            'Name'                 = $InputObject.Name
        }
    }

    end {
        $TotalSize = ($AllItems | Measure-Object -Property LengthInBytes -Sum).Sum

        $AllItems | ForEach-Object -Process {
            $SizeInPercent = $_.LengthInBytes / $TotalSize * 100
            $SizeInPercentRounded = ([math]::round(([math]::round($SizeInPercent) / 10)))

            $_.SizeInPercent = $SizeInPercent
            $_.SizeInPercentRounded = $SizeInPercentRounded
            $_.SizeVisualised = ($SizeInPercentRounded..0 | ForEach-Object { '#' }) -join ''
        }

        # foreach ($Item in $AllItems) {
        #     $Item.LengthInBytes
        # }

        $AllItems | Sort-Object LengthInBytes -Descending
    }

}