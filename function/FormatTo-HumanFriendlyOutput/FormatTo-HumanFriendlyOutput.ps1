function FormatTo-HumanFriendlyOutput {
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
        [string]$VisualisationEmpty = ' ',
        [validateset('[]', '()', '{}')]
        [string]$Parentheses = '[]',
        [bool]$DisplayUnderOneTenthInVisualisation = $true,
        [bool]$EnableForwardSlashOnFolder = $true
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
                'Length'          = $InputObject.Length
                'LengthInBytes'   = $InputObject.Length
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
            [int]$SimplePercent = $SizeInPercent / 10

            $_.SizeVisualised = $Parentheses.Substring(0, 1) + ($VisualisationFull * $SimplePercent) + ($VisualisationEmpty * (10 - $SimplePercent)) + $Parentheses.Substring(1, 1)
            $_.SizeInPercent = $SizeInPercent
        }

        $AllItems = $AllItems | Sort-Object Length -Descending
        $AllItems | ForEach-Object -Process {

            $_.SizeInPercent = "{0:n2} %" -f ([math]::round($_.SizeInPercent, 2))
            $_.Length = "{0:n2} $($Magnitude)" -f ($_.Length / $MagnitudeCalc)

            if ($EnableForwardSlashOnFolder) {
                if ($_.IsContainer) {
                    $_.Name = $_.Name + '/'
                }
            }
        }

        $AllItems | Sort-Object IsContainer, LengthInBytes -Descending | Format-Table -AutoSize -Property Name, SizeVisualised, @{Name = "Length"; Expression = { $_.Length }; Align = "right" }, @{Name = "SizeInPercent"; Expression = { $_.SizeInPercent }; Align = "right" }, IsContainer
    }
}
