param([Parameter(Mandatory)] [String] $version) 

$ErrorActionPreference = "Stop";

$layouts = @(
	"RU-UL"
	"EN-UL"
	"UK-UL"
)
$platforms = @(
	@{ Name = "i386"; Switch = "-x" }
	@{ Name = "amd64"; Switch = "-m" }
	@{ Name = "ia64"; Switch = "-i" }
	@{ Name = "wow64"; Switch = "-o" }
)

foreach ($layout in $layouts) {

	Set-Location (Join-Path $PSScriptRoot "msi/$layout")

	&dotnet fsi (Join-Path $PSScriptRoot "../src/render.fsx") -- "$layout" --layout-version $version
	if (!($?)) {
		throw "render.fsx failed"	
	}
	
	foreach ($platform in $platforms) {
		mkdir (Join-Path $PSScriptRoot "msi/$layout/$($platform.Name)") -Force
		Set-Location "$($platform.Name)"
		&(Join-Path $PSScriptRoot "tools/msklc/bin/i386/kbdutool.exe") -v $($platform.Switch) (Join-Path $PSScriptRoot "../src/$layout.klc")
		if (!($?)) {
			throw "kbdutool failed"	
		}
		Set-Location ..
	}
}

