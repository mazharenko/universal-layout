$ErrorActionPreference = "Stop";

$layouts = @(
	"RU-UL"
	"EN-UL"
)
$platforms = @(
	@{ Name = "i386"; Switch = "-x" }
	@{ Name = "amd64"; Switch = "-m" }
	@{ Name = "ia64"; Switch = "-i" }
	@{ Name = "wow64"; Switch = "-o" }
)

foreach ($layout in $layouts) {

	Set-Location (Join-Path $PSScriptRoot "build/msi/$layout")

	&dotnet fsi (Join-Path $PSScriptRoot "src/render.fsx") -- "$layout" --layout-version 1.0
	if (!($?)) {
		throw "render.fsx failed"	
	}
	
	foreach ($platform in $platforms) {
		mkdir (Join-Path $PSScriptRoot "build/msi/$layout/$($platform.Name)") -Force
		Set-Location "$($platform.Name)"
		&(Join-Path $PSScriptRoot "build/tools/msklc/bin/i386/kbdutool.exe") -v $($platform.Switch) (Join-Path $PSScriptRoot "src/$layout.klc")
		if (!($?)) {
			throw "kbdutool failed"	
		}
		Set-Location ..
	}
}

