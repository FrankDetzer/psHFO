# HumanFriendlyOutput - a ncdu clone for powershell
![25p-version-1 00-brightgreen](https://user-images.githubusercontent.com/57404682/102818919-cf987380-43d2-11eb-9ccb-2ec6b24ed667.png)![tested-pwsh 5 1-brightgreen](https://user-images.githubusercontent.com/57404682/102818921-d0310a00-43d2-11eb-9544-efd82a15a434.png)
![Output](https://user-images.githubusercontent.com/57404682/102819648-23f02300-43d4-11eb-8946-309b626738e2.png)

## SYNOPSIS
This module is intended for on-premises servers and in cloud-based service. 

Use the Get-HumanFriendlyFileList cmdlet to view items and folders and their respective size and attributes. 

## SYNTAX

```
Get-HumanFriendlyFileList 
 [-Path]
 [-SizeUnit]
```

## DESCRIPTION
Currently the HumanFriendlyOutput module provbides the Get-HumanFriendlyFileList which is a clone from the well known "ncdu" (NCurses Disk Usage) on linux.

You can run this module with and without the appropiate permissions for the folder you try to view. If Get-HumanFriendlyFileList cannot read the file or folder a warning will be displayed.

## EXAMPLES

### Example 1
```powershell
ncdu /
```

This example returns a summary list of all the files and folders in the Root folder of your computer using the alias.

### Example 2
```powershell
Get-HumanFriendlyFileList -SizeUnit MB
```

This example returns a list of all the files and folders in the current dictionary and formats them to MB.

## PARAMETERS

### -Path
This parameter can be used to specify a path other than the current location of your shell.

### -SizeUnit
This parameter formats the output according to the input. 

You can specify: Bytes, KB, MB, GB, TB and PB.

## INPUTS

###  
Currently the module accepts text input and no pipe input.

## OUTPUTS

###  
The Output of this module is text only. It cannot be used to pipe to other cmdlets.

## ALIASES
```
ncdu
ghffl
```

## NOTES

## RELATED LINKS
https://frankdetzer.com/release-of-my-ncdu-clone-for-powershell

