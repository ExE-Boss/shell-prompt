# ExE Boss’s Shell Prompt <https://github.com/ExE-Boss/shell-prompt>
# Copyright (C) 2017 ExE Boss
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

if (!$EBPromptSettings) { $EBPromptSettings = @{}; }

try { $EBPromptSettings.Add("AbbreviateHomeDirectory",	$false);	} catch {}
try { $EBPromptSettings.Add("PathOS",	$null);	} catch {}
try { $EBPromptSettings.Add("PathColor",	$null);	} catch {}
try { $EBPromptSettings.Add("Host",	$null);	} catch {}
try { $EBPromptSettings.Add("HostColor",	$null);	} catch {}
try { $EBPromptSettings.Add("Prefix",	$null);	} catch {}
try { $EBPromptSettings.Add("PrefixColor",	$null);	} catch {}
try { $EBPromptSettings.Add("Suffix",	$null);	} catch {}
try { $EBPromptSettings.Add("SuffixColor",	$null);	} catch {}

function prompt {
	function Write-Prompt {
		param(
			[String]	$Text	= $args[0],
			[String]	$Color	= "",
			[Boolean]	$Pad	= $False
		);

		$result = "";
		$text	= $Text;
		$textPad	= 0;
		$written	= $false;
		if ($Pad) {
			$textPad	= $text.Length;
			$text	= $text.TrimEnd();
			$textPad	-= $text.Length;
		}

		if (($PSVersionTable.PSVersion -ge 5.1) -and ($Host.UI.SupportsVirtualTerminal)) {
			function ColorToANSI {
				param (
					$Color = $args[0]
				);

				switch ($Color) {
					"Black"	{ return "$([char]0x1b)[0;30m"	}
					"DarkRed"	{ return "$([char]0x1b)[0;31m"	}
					"DarkGreen"	{ return "$([char]0x1b)[0;32m"	}
					"DarkYellow"	{ return "$([char]0x1b)[0;33m"	}
					"DarkBlue"	{ return "$([char]0x1b)[0;34m"	}
					"DarkMagenta"	{ return "$([char]0x1b)[0;35m"	}
					"DarkCyan"	{ return "$([char]0x1b)[0;36m"	}
					"DarkGray"	{ return "$([char]0x1b)[0;37m"	}
					"Gray"	{ return "$([char]0x1b)[1;30m"	}
					"Red"	{ return "$([char]0x1b)[1;31m"	}
					"Green"	{ return "$([char]0x1b)[1;32m"	}
					"Yellow"	{ return "$([char]0x1b)[1;33m"	}
					"Blue"	{ return "$([char]0x1b)[1;34m"	}
					"Magenta"	{ return "$([char]0x1b)[1;35m"	}
					"Cyan"	{ return "$([char]0x1b)[1;36m"	}
					"Reset"	{ return "$([char]0x1b)[39;49m"	}
					default	{ return "$([char]0x1b)[1;37m"	}
				}
			}

			if ($Color) {
				$result = (ColorToANSI $Color) + $text + (ColorToANSI "Reset");
			} else {
				$result = $text;
			}
			if ($Pad) {
				$result += " ".PadRight($textPad, " ");
			}
			return $result;
		} else {
			if ($Color) {
				try {
					Write-Host $text -NoNewline -ForegroundColor $Color;
					$written = $true;
				} catch {}
			}

			if (!$written) {
				Write-Host $text -NoNewline;
			}

			if ($Pad) {
				Write-Host " ".PadRight($textPad, " ") -NoNewline;
			}
			return "";
		}
	}

	$origLastExitCode = $global:LASTEXITCODE;
	$result = "";

	# Display default prompt prefix.
	$promptPrefix	= "PS ";
	$promptColor	= "White";
	if ($EBPromptSettings.Prefix) {
		$promptPrefix = $EBPromptSettings.Prefix;
	}
	if ($EBPromptSettings.PrefixColor) {
		$promptColor = $EBPromptSettings.PrefixColor;
	}
	$result += Write-Prompt $promptPrefix -Color $promptColor -Pad $true;

	if ($EBPromptSettings.Host) {
		$username = $env:USERNAME;
		if ($IsLinux) {
			$username = $env:USER;
		}
		$pcname = $env:COMPUTERNAME;
		if ($IsLinux) {
			$pcname = $env:NAME;
		}
		$promptHost = $EBPromptSettings.Host.replace("\u", $username).replace("\h", $pcname);
		$result += Write-Prompt $promptHost -Color $EBPromptSettings.HostColor -Pad $true;
	}

	$currentPath = $ExecutionContext.SessionState.Path.CurrentLocation.ToString();

	# File system paths are case-sensitive on Linux and case-insensitive on Windows
	if (($PSVersionTable.PSVersion.Major -ge 6) -and $IsLinux) {
		$stringComparison = [System.StringComparison]::Ordinal;
	} else {
		$stringComparison = [System.StringComparison]::OrdinalIgnoreCase;
	}

	# Abbreviate path by replacing beginning of path with ~ if the path is in the user’s home directory and the OS is Linux
	$abbrevHomeDir = $EBPromptSettings.AbbreviateHomeDirectory
	if (($abbrevHomeDir -eq $null) -and $IsLinux) {
		$abbrevHomeDir = $IsLinux;
	}
	if ($abbrevHomeDir -and $currentPath -and $currentPath.StartsWith($Home, $stringComparison)) {
		$currentPath = "~" + $currentPath.SubString($Home.Length);
	}
	if ($EBPromptSettings.PathOS) {
		if ("WIN".Equals($EBPromptSettings.PathOS, [System.StringComparison]::OrdinalIgnoreCase)) {
			$currentPath = $currentPath.Replace('/', '\');
		} elseif ("NIX".Equals($EBPromptSettings.PathOS, [System.StringComparison]::OrdinalIgnoreCase) -or
			"*NIX".Equals($EBPromptSettings.PathOS, [System.StringComparison]::OrdinalIgnoreCase) -or
			"UNIX".Equals($EBPromptSettings.PathOS, [System.StringComparison]::OrdinalIgnoreCase) -or
			"LINUX".Equals($EBPromptSettings.PathOS, [System.StringComparison]::OrdinalIgnoreCase) -or
			"MAC".Equals($EBPromptSettings.PathOS, [System.StringComparison]::OrdinalIgnoreCase) -or
			"OSX".Equals($EBPromptSettings.PathOS, [System.StringComparison]::OrdinalIgnoreCase)) {
			$currentPath = $currentPath.Replace('\', '/');
		}
	}
	$result += Write-Prompt $currentPath -Color $EBPromptSettings.PathColor;

	# Add compatibility with posh-git
	if (Get-Command Write-VcsStatus -ErrorAction SilentlyContinue) {
		Write-Host $result -NoNewline;
		Write-VcsStatus;
		$result = "";
	}

	$promptSuffix = $EBPromptSettings.Suffix;
	$promptSuffixEndPadding = 0;
	if (!$promptSuffix) {
		$promptSuffix = '>';
	} else {
		$promptSuffixEndPadding	= $promptSuffix.Length;
		$promptSuffix	= $promptSuffix.TrimEnd();
		$promptSuffixEndPadding	-= $promptSuffix.Length;
	}
	$result += Write-Prompt $promptSuffix -Color $EBPromptSettings.SuffixColor;

	$padding = " ".PadRight($promptSuffixEndPadding, " ");
	$global:LASTEXITCODE = $origLastExitCode;
	return $result + $padding;
}
