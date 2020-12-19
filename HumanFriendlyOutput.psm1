#
# Module Github Page:   https://github.com/FrankDetzer/HumanFriendlyOutput
# Module Release Page:  https://frankdetzer.com/release-of-my-ncdu-clone-for-powershell
# Module Version:       1.00
# Module Date:          2020-12-20
#
# Author Website:       https://frankdetzer.com
# Author Twitter:       https://twitter.com/frankdetzer



foreach ($Function in (Get-ChildItem -Path ($PSScriptRoot + '\function') -Recurse -Filter '*.ps1').FullName) {
    . $Function
}