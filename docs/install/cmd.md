Windows Command Prompt Installation
===================================

Preliminary step
----------------

You can skip this if you already have a `cmd` startup file
or equivalent thereof.

Installation in the Windows Command Prompt is by far the most annoying,
because adding the entry to the Environment Variables directly causes
`%USERNAME%` to be parsed as `SYSTEM` instead of the user’s actual name,
so we instead have to run the script using the `AutoRun` registry key.

Save the following as a `.reg` file and run it, or add the entry
manually if you don’t trust random scripts on the internet,
which you really shouldn’t be doing in the first place:
```ini
Windows Registry Editor Version 5.00

[HKEY_CURRENT_USER\Software\Microsoft\Command Processor]
; REG_EXPAND_SZ: "AutoRun"="\"%USERPROFILE%\\.cmd"\"
"AutoRun"=hex(2):22,00,25,00,55,00,53,00,45,00,52,00,50,00,52,00,4f,00,46,00,\
  49,00,4c,00,45,00,25,00,5c,00,2e,00,63,00,6d,00,64,00,22,00,00,00
```

This will run the batch script called `.cmd` in the user’s home
directory every time a Windows Command Prompt instance is opened,
similarly to the Unix `.bashrc` file.

`.cmd` file contents
--------------------

Add the following to the newly created `.cmd` file:
```cmd
:: Disable echoing of executed commands
@ECHO off

:: Replace `\absolute\path\to\shell-prompt` with the actual path
:: The `> NUL` redirection is used to silence the standard output
"\absolute\path\to\shell-prompt\src\cmd.bat" > NUL
```
