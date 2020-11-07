function Get-HumanFriendlyFileList {
    [CmdletBinding()]
    param (
        $Path = $env:USERPROFILE
        [switch]$Recurse = $false
        [switch]$IncludeFolder = $true
        [switch]$ExpandIntoSubfoler = $false
    )
    
    begin {
       # $InputPath = Get-ChildItem -Path $Path -Recurse $Recurse | Group-Object Parent | Sort-Object Name
        $InputPath = Get-ChildItem -Path $Path -Recurse $Recurse
    
    process {
        foreach ($Item in $InputPath) {
        FormatTo-HumanFriendlyOutput -Name $Item.Name -Length $Item.Length

    }}

    
    end {
        
    }
}