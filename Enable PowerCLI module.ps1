#Enable PowerCLI module
$p = [Environment]::GetEnvironmentVariable("PSModulePath")
$p += ";C:\Program Files (x86)\VMware\Infrastructure\PowerCLI\Modules\"
[Environment]::SetEnvironmentVariable("PSModulePath",$p)

Import-Module VMware.VimAutomation.Core