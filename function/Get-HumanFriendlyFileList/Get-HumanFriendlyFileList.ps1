function Get-HumanFriendlyFileList {
    [CmdletBinding()]
    param (
        $Path = $env:USERPROFILE,
        [switch]$Recurse2 = $true
        # [switch]$IncludeFolder = $true
        # [switch]$ExpandIntoSubfoler = $false
    )

    begin {
        $InputPath = Get-ChildItem -Path $Path #-Recurse $Recurse
        $obj = @()
        $i = 1
        Set-Alias -Name 'ncdu' -Value 'Get-HumanFriendlyFileList'
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


            # $obj += [PSCustomObject][ordered]@{
            #     'Name'          = $Item.Name
            #     'LengthInBytes' = $LengthInBytes
            #     'IsContainer'   = $Item.PSIsContainer
            # }

            FormatTo-HumanFriendlyOutput -Name $Item.Name -LengthInBytes $LengthInBytes -IsContainer $Item.PSIsContainer
        }
    }

    end {
        # $obj
    }
}