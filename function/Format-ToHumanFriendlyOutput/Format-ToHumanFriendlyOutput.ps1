function Format-ToHumanFriendlyOutput {
    param (
        [parameter(ValueFromPipeline)]
        [psobject]$InputObjectCollection,
        # [parameter(ValueFromPipeline)]
        # [string]$PropertyName1 = 'PropertyName1',
        # [parameter(ValueFromPipeline)]
        # [string]$PropertyName2 = 'PropertyName2',
        # [parameter(ValueFromPipeline)]
        # [string]$PropertyName3 = 'PropertyName3',
        [validateset('Auto', 'Bytes', 'KB', 'MB', 'GB', 'TB', 'PB')]
        [string]$SizeUnit = 'Auto',
        [validateset('#', '-', '_', '*', '+', '=', ' ')]
        [string]$VisualisationFull = '#',
        [validateset('#', '-', '_', '*', '+', '=', ' ')]
        [string]$VisualisationEmpty = ' ',
        [validateset('[]', '()', '{}')]
        [string]$Parentheses = '[]',
        [bool]$DisplayUnderOneTenthInVisualisation = $true,
        [bool]$EnableForwardSlashOnFolder = $true,
        [string]$Path = $null,
        [bool]$AllFilesReadable = $false
    )

    begin {
        $Output = @()
        $Output = [pscustomobject]@{
            Meta = @()
            Data = @()
        }            
    }

    process {
        foreach ($InputObject in $InputObjectCollection) {
            if ($SizeUnit -eq 'Auto') {
                if ($InputObject.Length -lt 1) {
                    $Size = $null
                }
                elseif ($InputObject.Length -lt 1KB) {
                    $Size = "{0:n0}     B" -f ($InputObject.Length / 1)
                }
                elseif ($InputObject.Length -lt 1MB) {
                    $Size = "{0:n2} KB" -f ($InputObject.Length / 1KB)
                }
                elseif ($InputObject.Length -lt 1GB) {
                    $Size = "{0:n2} MB" -f ($InputObject.Length / 1MB)
                }
                elseif ($InputObject.Length -lt 1TB) {
                    $Size = "{0:n2} GB" -f ($InputObject.Length / 1GB)
                }
                elseif ($InputObject.Length -lt 1PB) {
                    $Size = "{0:n2} TB" -f ($InputObject.Length / 1TB)
                }
                else {
                    $Size = "{0:n2} PB" -f ($InputObject.Length / 1PB)
                }
            }
            else {
                switch ($SizeUnit) {
                    'Bytes' {
                        $Size = $null
                    }
                    'KB' {
                        $Size = "{0:n2} KB" -f ($InputObject.Length / 1KB)
                    }
                    'MB' {
                        $Size = "{0:n2} MB" -f ($InputObject.Length / 1MB)
                    }
                    'GB' {
                        $Size = "{0:n2} GB" -f ($InputObject.Length / 1GB)
                    }
                    'TB' {
                        $Size = "{0:n2} TB" -f ($InputObject.Length / 1TB)
                    }
                    'PB' {
                        $Size = "{0:n2} PB" -f ($InputObject.Length / 1PB)
                    }
                }
            }

            $Output.Data += [PSCustomObject][ordered]@{
                'Length'         = $InputObject.Length
                'Mode'           = $InputObject.Mode
                'Size'           = $Size
                'SizeInPercent'  = $null
                'SizeVisualised' = $null
                'Name'           = $InputObject.Name
                # $PropertyName1    = $InputObject.PropertyName1
                # $PropertyName2    = $InputObject.PropertyName2
                # $PropertyName3    = $InputObject.PropertyName3
                'IsContainer'    = $InputObject.IsContainer
                'CompletelyReadable'       = $InputObject.Readable
            }
        }
    }

    end {
        $TotalSize = ($Output.Data | Measure-Object -Property Length -Sum).Sum

        $Output.Data | ForEach-Object {
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
            
        $TotalItemSize = ($Output.Data | Measure-Object Length -Sum).Sum
        if ($SizeUnit -eq 'Auto') {
            if ($TotalItemSize -lt 1) {
                $OutputSIze = $null
            }
            elseif ($TotalItemSize -lt 1KB) {
                $OutputSIze = "{0:n0}     B" -f ($TotalItemSize / 1)
            }
            elseif ($TotalItemSize -lt 1MB) {
                $OutputSIze = "{0:n2} KB" -f ($TotalItemSize / 1KB)
            }
            elseif ($TotalItemSize -lt 1GB) {
                $OutputSIze = "{0:n2} MB" -f ($TotalItemSize / 1MB)
            }
            elseif ($TotalItemSize -lt 1TB) {
                $OutputSIze = "{0:n2} GB" -f ($TotalItemSize / 1GB)
            }
            elseif ($TotalItemSize -lt 1PB) {
                $OutputSIze = "{0:n2} TB" -f ($TotalItemSize / 1TB)
            }
            else {
                $OutputSIze = "{0:n2} PB" -f ($TotalItemSize / 1PB)
            }
        }
        else {
            switch ($SizeUnit) {
                'Bytes' {
                    $OutputSIze = $null
                }
                'KB' {
                    $OutputSIze = "{0:n2} KB" -f ($TotalItemSize / 1KB)
                }
                'MB' {
                    $OutputSIze = "{0:n2} MB" -f ($TotalItemSize / 1MB)
                }
                'GB' {
                    $OutputSIze = "{0:n2} GB" -f ($TotalItemSize / 1GB)
                }
                'TB' {
                    $OutputSIze = "{0:n2} TB" -f ($TotalItemSize / 1TB)
                }
                'PB' {
                    $OutputSIze = "{0:n2} PB" -f ($TotalItemSize / 1PB)
                }
            }
        }

        $Output.Meta = (
            [pscustomobject]@{
                Path             = $Path
                SizeUnit         = $SizeUnit
                TotalItemCount   = $Output.Data.Count
                TotalItemSize    = $OutputSize
                FolderCount      = ($Output.Data | Where-Object { $_.IsContainer -eq $true }).Count
                ItemCount        = ($Output.Data | Where-Object { $_.IsContainer -eq $false }).Count
                AllFilesReadable = $AllFilesReadable
            }
        )

        $Output.Meta | Format-Table -AutoSize -Property Path, TotalItemCount, @{Name = 'TotalItemSize'; Expression = { $_.TotalItemSize }; Align = 'right' }, FolderCount, ItemCount
        if ($AllFilesReadable) {
            $Output.Data | Sort-Object IsContainer, Length -Descending | Format-Table -AutoSize -Property Name, Mode, SizeVisualised, @{Name = 'Size'; Expression = { $_.Size }; Align = 'right' }, @{Name = 'SizeInPercent'; Expression = { '{0:n2} %' -f ([math]::round($_.SizeInPercent, 2)) }; Align = 'right' }
        }
        else {
            Write-Warning 'Results unaccurate. Unable to read all files/folders. Restart with elevated privileges to receive accurate results.'
            $Output.Data | Sort-Object IsContainer, Length -Descending | Format-Table -AutoSize -Property Name, Mode, SizeVisualised, @{Name = 'Size'; Expression = { $_.Size }; Align = 'right' }, @{Name = 'SizeInPercent'; Expression = { '{0:n2} %' -f ([math]::round($_.SizeInPercent, 2)) }; Align = 'right' }, CompletelyReadable
        }
    }
}