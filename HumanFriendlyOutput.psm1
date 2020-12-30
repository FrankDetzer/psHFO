#
# Module Github Page:   https://github.com/FrankDetzer/psHFO
# Module Release Page:  https://frankdetzer.com/release-of-pshfo/
# Module Version:       1.10
# Module Date:          2020-12-30
#
# Author Website:       https://frankdetzer.com
# Author Twitter:       https://twitter.com/frankdetzer

foreach ($Function in (Get-ChildItem -Path ($PSScriptRoot + '\function') -Recurse -Filter '*.ps1').FullName) {
    . $Function
}


Set-Alias -Name 'gfl' -Value 'Get-HumanFriendlyFileList'
Set-Alias -Name 'ncdu' -Value 'Get-HumanFriendlyFileList'