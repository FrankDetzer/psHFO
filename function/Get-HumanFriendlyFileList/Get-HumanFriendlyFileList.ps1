function Get-HumanFriendlyFileList {
    [CmdletBinding()]
    param (
        $Path = $env:USERPROFILE
        [switch]$Recurse = $false
        [switch]$ExpandSubfoler = $false
    )
    
    begin {
        $InputPath = Get-ChildItem -Path $Path -Recurse $Recurse | Group-Object Parent | Sort-Object Name
    
    process {
        
    }
    
    end {
        
    }
}