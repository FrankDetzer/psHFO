function Get-HumanFriendlyFileList {
    param (
        $Path = (Get-Location).Path,
        [validateset('Auto', 'Bytes', 'KB', 'MB', 'GB', 'TB', 'PB')]
        [string]$SizeUnit = 'Auto'
    )

    begin {
        $InputPath = Get-ChildItem -Path $Path -Recurse:$false
        $PreparedDataForEngine = @()
        $Counter = 1
        $AllFilesReadable = $true
    }

    process {
        foreach ($Item in $InputPath) {
            $PercentComplete = $Counter / $InputPath.Count * 100
            Write-Progress -Activity 'Indexing in Progress' -Status ([string]$Counter + '/' + [string]$InputPath.Count + ' (' + '{0:n2} %)' -f ($PercentComplete) + ' items indexed') -PercentComplete $PercentComplete

            if ($Item.PSIsContainer) {
                try {
                    $Length = (Get-ChildItem -Path $Item.FullName -Recurse:$true -File -ErrorAction Stop | Measure-Object Length -Sum).Sum 
                    $Readable = $true
                }
                catch {
                    $Readable = $false
                    $AllFilesReadable = $false
                }

            }
            else {
                $Length = $Item.Length
            }

            if ($null -eq $Length) {
                $Length = 0
            }


            $PreparedDataForEngine += [PSCustomObject][ordered]@{
                'Name'             = $Item.Name
                'Length'           = $Length
                'Mode'             = $Item.Mode
                'IsContainer'      = $Item.PSIsContainer
                'Readable'         = $Readable
                'AllFilesReadable' = $AllFilesReadable
            }
            $Counter++
        }
    }

    end {
        Format-ToHumanFriendlyOutput -InputObjectCollection $PreparedDataForEngine -Path $Path -SizeUnit $SizeUnit -AllFilesReadable $AllFilesReadable
    }
}