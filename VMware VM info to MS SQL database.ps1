#VMware virtual machine info to MS SQL database
$ViServer = 'Vi1111.BGELOV.RU'

Import-Module VMware.VimAutomation.Core
Connect-VIServer $ViServer

#ODBC
#DB Server
$dbServer = "dbserver" 
#DB Name
$dbName = "database"
#DB User
$dbUser = "domain\user"
#DB Pass
$dbPass = "*************"
[string]$szConnect = "Driver={SQL Server};Server=$dbServer;Database=$dbName;user id=$dbUser;password=$dbPass;trusted_connection=true;"
# and you need to create table VM

$cnDB = New-Object System.Data.Odbc.OdbcConnection($szConnect)
$dsDB = New-Object System.Data.DataSet



foreach ($cl in (Get-Cluster)) {
    
    $farm = $cl.name #[farmName]

    foreach ($vm in ($cl | Get-VM)) {

       $VMhost = $vm.Name 

       #[ObjectID]
       #[farmID]

       $VMhostName = $vm.VMHost.Name #[Host]
       $VMmemsize = $vm.MemoryMB #[MEM_SIZE_MB]
       $VMcpu = $vm.NumCpu       #[NUM_VCPU]
       $VMpower = $vm.PowerState #[POWER_STATE]
       $VMguest = $vm.GuestId    #[GUEST_OS]
       $VMnotes = $vm.Notes      #[DESCRIPTION] 

        foreach ($VMg in (Get-VMGuest $VMhost)) {

            $VMip = $VMg.IPAddress[0]   #[IP_ADDRESS]
            $VMhostname = $VMg.HostName #[DNS_NAME]
            $VMdisk = $VMg.disks.count  #[NUM_DISK]
            $VMcapacity = [math]::Round(($VMg.disks | where { $_.path -eq 'C:\'}).CapacityGB, 0) #[diskGB]

            try
            {
                $cnDB.Open()
                $adDB = New-Object System.Data.Odbc.OdbcDataAdapter 

                $sql = "INSERT INTO [dbo].[VM]
                   ([ObjectID]
                   ,[Host]
                   ,[MEM_SIZE_MB]
                   ,[NUM_VCPU]
                   ,[POWER_STATE]
                   ,[GUEST_OS]
                   ,[DNS_NAME]
                   ,[IP_ADDRESS]
                   ,[NUM_DISK]
                   ,[DESCRIPTION]
                   ,[diskGB]
                   ,[farmID]
                   ,[farmName])
                 VALUES
                       (NULL, '" + $VMhostName + "', '" + $VMmemsize + "', '" + $VMcpu + "', '" + $VMpower + "', '" + $VMguest + "', '" + $VMhost + "', '" + $VMip + "', '" + $VMdisk + "', '" + $VMnotes + "', '" + $VMcapacity + "', NULL, '" + $farm + "')"     
                $adDB.SelectCommand = New-Object System.Data.Odbc.OdbcCommand($sql, $cnDB) 

                $adDB.Fill($dsDB) 
                $cnDB.Close() 


            }
            catch [System.Data.Odbc.OdbcException]
            {
                $_.Exception
                $_.Exception.Message
                $_.Exception.ItemName
            }

        } #foreach VMGuest

    }

}


Disconnect-VIServer -Confirm:$false
