#Get info about VMhost

#Import-Module VMware.VimAutomation.Core
#Connect-VIServer SERVER-NAME

foreach ($cl in (Get-Cluster)) {
    
    $farm = $cl.name #[farmName]

    foreach ($vm in ($cl | Get-VM)) {

       $VMhost = $vm.Name         

       #[ObjectID]
       #[farmID]

       $vm.VMHost     #[Host]
       $vm.MemoryMB   #[MEM_SIZE_MB]
       $vm.NumCpu     #[NUM_VCPU]
       $vm.PowerState #[POWER_STATE]
       $vm.GuestId    #[GUEST_OS]
       $vm.Notes      #[DESCRIPTION]
       $vm.Id

        foreach ($VMg in (Get-VMGuest $VMhost)) {

            $VMg.IPAddress[0]   #[IP_ADDRESS]
            $VMg.HostName       #[DNS_NAME]
            $VMg.disks.count    #[NUM_DISK]
            ($VMg.disks | where { $_.path -eq 'C:\'}).CapacityGB #[diskGB]


        }
  


    }

}

