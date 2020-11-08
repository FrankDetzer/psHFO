function FormatTo-HumanFriendlyOutput {
    param (
        [parameter(ValueFromPipeline)]
        [psobject]$InputObject,
        [validateset('Bytes', 'KB', 'MB', 'GB', 'TB')]
        [string]$Magnitude = 'MB',
        [validateset('#', '-', '_', '*', '+', '=', ' ')]
        [string]$VisualisationFull = '#',
        [validateset('#', '-', '_', '*', '+', '=', ' ')]
        [string]$VisualisationEmpty = '-',
        [bool]$DisplayUnderOneTenthInVisualisation = $true
    )

    begin {

        switch ($Magnitude) {
            'Bytes' { $MagnitudeCalc = 1 }
            'KB' { $MagnitudeCalc = 1KB }
            'MB' { $MagnitudeCalc = 1MB }
            'GB' { $MagnitudeCalc = 1GB }
            'TB' { $MagnitudeCalc = 1TB }
        }

        $AllItems = @()
        $LengthInMagnitude = 'LengthIn' + $Magnitude
    }
    process {
        # Write-Progress -Activity 'Search in Progress' # -Status '$i% Complete:' -PercentComplete $i;

        $AllItems += [PSCustomObject][ordered]@{
            'LengthInBytes'    = $InputObject.Length
            $LengthInMagnitude = $InputObject.Length / $MagnitudeCalc
            'SizeInPercent'    = $null
            'SizeInOneTenths'  = $null
            'SizeVisualised'   = $null
            'Name'             = $InputObject.Name
            'IsFolder'         = $InputObject.PSIsContainer
        }
    }

    end {
        $TotalSize = ($AllItems | Measure-Object -Property LengthInBytes -Sum).Sum

        $AllItems | ForEach-Object -Process {
            $SizeInPercent = $_.LengthInBytes / $TotalSize * 100
            $SizeInOneTenths = ([math]::round(([math]::round($SizeInPercent) / 10)))

            if ($SizeInOneTenths -ge 1) {
                $SizeInOneTenths..1 | ForEach-Object -Begin { $SizeVisualised = '[' }  -Process { $SizeVisualised += $VisualisationFull } -End { (10 - $SizeInOneTenths)..1 | ForEach-Object -Process { $SizeVisualised += $VisualisationEmpty }; $SizeVisualised += ']' }
            }
            else {
                if ($DisplayUnderOneTenthInVisualisation) {
                    $SizeVisualised = '[<1%       ]'
                }else {
                    10..1 | ForEach-Object -Begin { $SizeVisualised = '[' }  -Process { $SizeVisualised += $VisualisationEmpty } -End {$SizeVisualised += ']' }
                }
            }

            $_.SizeInPercent = $SizeInPercent
            $_.SizeInOneTenths = $SizeInOneTenths
            $_.SizeVisualised = $SizeVisualised
        }

        $AllItems | Sort-Object LengthInBytes -Descending
    }

}

Set-Alias -Name 'ncdu' -Value 'FormatTo-HumanFriendlyOutput'