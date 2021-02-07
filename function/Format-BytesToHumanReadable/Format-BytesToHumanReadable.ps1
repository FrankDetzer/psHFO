function Format-BytesToHumanReadable {
    param (
        [uint64]$Length,
        [validateset('Auto', 'Bytes', 'KB', 'MB', 'GB', 'TB', 'PB')]
        [string]$SizeUnit = 'Auto'
    )

    process {
        if ($SizeUnit -eq 'Auto') {
            if ($Length -lt 1) {
                $Output = $null
            }
            elseif ($Length -lt 1KB) {
                $Output = "{0:n0}     B" -f $Length
            }
            elseif ($Length -lt 1MB) {
                $Output = "{0:n2} KB" -f ($Length / 1KB)
            }
            elseif ($Length -lt 1GB) {
                $Output = "{0:n2} MB" -f ($Length / 1MB)
            }
            elseif ($Length -lt 1TB) {
                $Output = "{0:n2} GB" -f ($Length / 1GB)
            }
            elseif ($Length -lt 1PB) {
                $Output = "{0:n2} TB" -f ($Length / 1TB)
            }
            else {
                $Output = "{0:n2} PB" -f ($Length / 1PB)
            }
        }
        else {
            switch ($SizeUnit) {
                'Bytes' {
                    $Output = "{0:n0}     B" -f $Length
                }
                'KB' {
                    $Output = "{0:n2} KB" -f ($Length / 1KB)
                }
                'MB' {
                    $Output = "{0:n2} MB" -f ($Length / 1MB)
                }
                'GB' {
                    $Output = "{0:n2} GB" -f ($Length / 1GB)
                }
                'TB' {
                    $Output = "{0:n2} TB" -f ($Length / 1TB)
                }
                'PB' {
                    $Output = "{0:n2} PB" -f ($Length / 1PB)
                }
            }
        }
    }
    end {
        return ($Output)
    }
}