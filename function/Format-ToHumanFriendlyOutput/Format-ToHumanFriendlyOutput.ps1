function Format-ToHumanFriendlyOutput {
    param (
        [validateset('Path', 'Partition')]
        [string]$Mode = 'Path',
        [string]$Parameter = (Get-Location).Path,
        [validateset('Auto', 'Bytes', 'KB', 'MB', 'GB', 'TB', 'PB')]
        [string]$SizeUnit = 'Auto',
        [validateset('#', '-', '_', '*', '+', '=', ' ')]
        [string]$VisualisationFull = '#',
        [validateset('#', '-', '_', '*', '+', '=', ' ')]
        [string]$VisualisationEmpty = ' ',
        [validateset('[]', '()', '{}')]
        [string]$Parentheses = '[]',
        [bool]$EnableUnderOneTenthInVisualisation = $true,
        [bool]$EnableForwardSlashOnPath = $true
    )

    begin {
        [uint64]$TotalItemLength = 0
        $AllFilesReadable = $true
        $Output = @()
        $Readable = $true
        $Counter = 1

        if ($Mode -eq 'Path') {
            if ($Parameter.Length -eq 1){
                $Parameter = $Parameter + ':'
            }

            $List = Get-ChildItem -Path $Parameter -Recurse:$false
            $Disk = Get-PSDrive $List[0].PSDrive
            $DiskTotalSpaceInBytes = $Disk.Used + $Disk.Free

            foreach ($Item in $List) {
                $PercentComplete = $Counter / $List.Count * 100
                Write-Progress -Activity 'Indexing in Progress' -Status ([string]$Counter + '/' + [string]$List.Count + ' (' + '{0:n2} %)' -f ($PercentComplete) + ' items indexed') -PercentComplete $PercentComplete

                if ($Item.PSIsContainer) {
                    try {
                        $Length = (Get-ChildItem -Path $Item.FullName -Recurse:$true -File -ErrorAction Stop | Measure-Object Length -Sum).Sum 
                    }
                    catch {
                        $Readable = $false
                        $AllFilesReadable = $false
                        $Length = 0
                    }
                }
                else {
                    $Length = $Item.Length
                }

                if ($null -eq $Length) {
                    $Length = 0
                }


                $Output += [PSCustomObject][ordered]@{
                    'Name'           = $Item.Name
                    'SizeVisualised' = $null
                    'Mode'           = $Item.Mode
                    'Length'         = $Length
                    'SizeInPercent'  = $null
                    'Readable'       = $Readable
                    'IsContainer'    = $Item.PSIsContainer
                }

                $TotalItemLength += $Length
                $Counter++
            }

            $Meta = (
                [pscustomobject]@{
                    Path           = $List[0].Parent
                    TotalItemCount = $Output.Count
                    TotalItemSize  = $TotalItemLength
                    FolderCount    = ($Output | Where-Object { $_.IsContainer -eq $true }).Count
                    ItemCount      = ($Output | Where-Object { $_.IsContainer -eq $false }).Count
                    UsageInPercent  = '{0:n2} %' -f ([math]::round($TotalItemLength / $DiskTotalSpaceInBytes * 100, 2)) 
                }
            )    
        }
        if ($Mode -eq 'Partition') {

        }
    }

    process {
        $Output = $Output | Sort-Object IsContainer, Length -Descending 
        $Output | ForEach-Object {
            $SizeInPercent = $_.Length / $TotalItemLength * 100
            [int]$SimplePercent = $SizeInPercent / 10

            $_.SizeVisualised = $Parentheses.Substring(0, 1) + ($VisualisationFull * $SimplePercent) + ($VisualisationEmpty * (10 - $SimplePercent)) + $Parentheses.Substring(1, 1)
            $_.SizeInPercent = '{0:n2} %' -f ([math]::round($SizeInPercent, 2)) 
            $_.Length = Format-BytesToHumanReadable -Length $_.Length -SizeUnit $SizeUnit

            if ($EnableForwardSlashOnPath) {
                if ($_.IsContainer) {
                    $_.Name = $_.Name + '/'
                }
            }
        }
        
    }

    end {
        $Disk | Format-Table -AutoSize -Property @{Name = 'Disk'; Expression = { $_.Name } }, @{Name = 'Used'; Expression = { Format-BytesToHumanReadable -Length $_.Used -SizeUnit $SizeUnit }; Align = 'right' }, @{Name = 'Free'; Expression = { Format-BytesToHumanReadable -Length $_.Free -SizeUnit $SizeUnit }; Align = 'right' }, @{Name = 'Total'; Expression = { Format-BytesToHumanReadable -Length $DiskTotalSpaceInBytes -SizeUnit $SizeUnit }; Align = 'right' }
        $Meta | Format-Table -AutoSize -Property Path, TotalItemCount, @{Name = 'TotalItemSize'; Expression = { Format-BytesToHumanReadable -Length $_.TotalItemSize -SizeUnit $SizeUnit }; Align = 'right' }, @{Name = 'UsageInPercent'; Expression = { $_.UsageInPercent }; Align = 'right' }, FolderCount, ItemCount


        if ($AllFilesReadable) {
            $Output | Format-Table -AutoSize -Property Name, Mode, SizeVisualised, @{Name = 'Length'; Expression = { $_.Length }; Align = 'right' }
        }
        else {
            Write-Warning 'Results unaccurate. Unable to read all files/Paths. Restart with elevated privileges to receive accurate results.'
            $Output | Format-Table -AutoSize -Property Name, Mode, SizeVisualised, @{Name = 'Length'; Expression = { $_.Length }; Align = 'right' }, Readable
        }
    }
}