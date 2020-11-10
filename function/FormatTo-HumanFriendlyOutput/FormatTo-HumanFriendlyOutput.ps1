﻿function FormatTo-HumanFriendlyOutput {
    param (
        [parameter(ValueFromPipeline)]
        [psobject]$InputObjectCollection,
        [parameter(ValueFromPipeline)]
        [string]$PropertyName1 = "PropertyName1",
        [parameter(ValueFromPipeline)]
        [string]$PropertyName2 = "PropertyName2",
        [parameter(ValueFromPipeline)]
        [string]$PropertyName3 = "PropertyName3",
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
    }

    process {
        foreach ($InputObject in $InputObjectCollection) {
            $AllItems += [PSCustomObject][ordered]@{
               # 'Length'          = "{0:n2} $($Magnitude)" -f ($InputObject.Length / $MagnitudeCalc)
                 'Length'          = $InputObject.Length
                'SizeInPercent'   = $null
                'SizeInOneTenths' = $null
                'SizeVisualised'  = $null
                'Name'            = $InputObject.Name
                $PropertyName1    = $InputObject.PropertyName1
                $PropertyName2    = $InputObject.PropertyName2
                $PropertyName3    = $InputObject.PropertyName3
                'IsContainer'     = $InputObject.IsContainer
            }
        }
    }

    end {
        $TotalSize = ($AllItems | Measure-Object -Property Length -Sum).Sum

        $AllItems | ForEach-Object -Process {
            $SizeInPercent = $_.Length / $TotalSize * 100
            $SizeInOneTenths = ([math]::round(([math]::round($SizeInPercent) / 10)))

            if ($SizeInOneTenths -ge 1) {
                $SizeInOneTenths..1 | ForEach-Object -Begin { $SizeVisualised = '[' }  -Process { $SizeVisualised += $VisualisationFull } -End {
                    if ($SizeInOneTenths -lt 10) { (10 - $SizeInOneTenths)..1 | ForEach-Object -Process { $SizeVisualised += $VisualisationEmpty } }
                    $SizeVisualised += ']'
                }
            }
            else {
                if ($DisplayUnderOneTenthInVisualisation) {
                    $SizeVisualised = '[<10%      ]'
                }
                else {
                    10..1 | ForEach-Object -Begin { $SizeVisualised = '[' }  -Process { $SizeVisualised += $VisualisationEmpty } -End { $SizeVisualised += ']' }
                }
            }
            $_.SizeInOneTenths = $SizeInOneTenths
            $_.SizeVisualised = $SizeVisualised
            $_.SizeInPercent = $SizeInPercent
        }

        $AllItems = $AllItems | Sort-Object Length -Descending
        $AllItems | ForEach-Object -Process {

            # $_.SizeInPercent = ($_.SizeInPercent).ToString().Substring(0,5) + ' %'
            $_.SizeInPercent = [string][math]::round($_.SizeInPercent, 2) + ' %'
            $_.Length = "{0:n2} $($Magnitude)" -f ($_.Length / $MagnitudeCalc)
        }

        $AllItems | Format-Table -AutoSize
    }
}