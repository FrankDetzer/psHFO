$global:LangPath = $PSScriptRoot + '\lang'
$global:FunctionList = (Get-ChildItem -Path ($PSScriptRoot + '\function') -Recurse -Filter '*.ps1').FullName

foreach ($Function in $global:FunctionList) {
    . $Function
}