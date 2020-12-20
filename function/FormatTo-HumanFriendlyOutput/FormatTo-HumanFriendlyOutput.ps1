function FormatTo-HumanFriendlyOutput {
    param (
        [parameter(ValueFromPipeline)]
        [psobject]$InputObjectCollection,
        # [parameter(ValueFromPipeline)]
        # [string]$PropertyName1 = 'PropertyName1',
        # [parameter(ValueFromPipeline)]
        # [string]$PropertyName2 = 'PropertyName2',
        # [parameter(ValueFromPipeline)]
        # [string]$PropertyName3 = 'PropertyName3',
        [validateset('Bytes', 'KB', 'MB', 'GB', 'TB')]
        [string]$Magnitude = 'MB',
        [validateset('#', '-', '_', '*', '+', '=', ' ')]
        [string]$VisualisationFull = '#',
        [validateset('#', '-', '_', '*', '+', '=', ' ')]
        [string]$VisualisationEmpty = ' ',
        [validateset('[]', '()', '{}')]
        [string]$Parentheses = '[]',
        [bool]$DisplayUnderOneTenthInVisualisation = $true,
        [bool]$EnableForwardSlashOnFolder = $true,
        [string]$Path = $null
    )

    begin {
        switch ($Magnitude) {
            'Bytes' { $MagnitudeCalc = 1 }
            'KB' { $MagnitudeCalc = 1KB }
            'MB' { $MagnitudeCalc = 1MB }
            'GB' { $MagnitudeCalc = 1GB }
            'TB' { $MagnitudeCalc = 1TB }
        }
    }

    process {
        $AllItems = @()
        foreach ($InputObject in $InputObjectCollection) {
            $AllItems += [PSCustomObject][ordered]@{
                'Length'         = $InputObject.Length
                'Mode'           = $InputObject.Mode
                'SizeInPercent'  = $null
                'SizeVisualised' = $null
                'Name'           = $InputObject.Name
                # $PropertyName1    = $InputObject.PropertyName1
                # $PropertyName2    = $InputObject.PropertyName2
                # $PropertyName3    = $InputObject.PropertyName3
                'IsContainer'    = $InputObject.IsContainer
            }
        }
    }

    end {
        $TotalSize = ($AllItems | Measure-Object -Property Length -Sum).Sum

        $AllItems | ForEach-Object {
            $SizeInPercent = $_.Length / $TotalSize * 100
            [int]$SimplePercent = $SizeInPercent / 10

            $_.SizeVisualised = $Parentheses.Substring(0, 1) + ($VisualisationFull * $SimplePercent) + ($VisualisationEmpty * (10 - $SimplePercent)) + $Parentheses.Substring(1, 1)
            $_.SizeInPercent = $SizeInPercent

            if ($EnableForwardSlashOnFolder) {
                if ($_.IsContainer) {
                    $_.Name = $_.Name + '/'
                }
            }
        }
        $AllItems | Sort-Object IsContainer, Length -Descending | Format-Table -AutoSize -Property Name, Mode, SizeVisualised, @{Name = 'Length'; Expression = { "{0:n2} $($Magnitude.ToUpper())" -f ($_.Length / $MagnitudeCalc) }; Align = 'right' }, @{Name = 'SizeInPercent'; Expression = { '{0:n2} %' -f ([math]::round($_.SizeInPercent, 2)) }; Align = 'right' }

        Write-Output ('Path:             ' + $Path)
        Write-Output ('Total Item Count: ' + $AllItems.Count)
        # Write-Output ('Total Item Size   ' + {0:n2} $($Magnitude.ToUpper())" -f (($_.Length )/ $MagnitudeCal
    }
}