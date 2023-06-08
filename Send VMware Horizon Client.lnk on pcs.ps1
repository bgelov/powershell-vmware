#Send VMware Horizon Client.lnk on pcs

$Computer = Get-Content D:\vmware_comp.txt 

Foreach ($Comp in $Computer) {
if (test-path "\\$Comp\c$\Users\$Comp\Desktop\") { 
    Write-Host "$Comp" -ForegroundColor Green 
	#username = computername
    Copy-Item "\\fileshare\VMware\lnk\VMware Horizon Client.lnk" -Destination "\\$Comp\c$\Users\$Comp\Desktop\"  -Recurse
    } 
    else { Write-Warning("$Comp not available") }
}



