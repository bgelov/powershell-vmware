#Add User to Admin and log this to DB

#Group name
$Group = "Administrators"

#Domain name
$domain = "bgelov.ru"
$domain2 = "BGELOV"

$user = $computer = $null

#ODBC
$dbServer = "dbserver" 
$dbName = "dbname"
$dbUser = "dbuser"
$dbPass = "dbpass"
[string]$szConnect = "Driver={SQL Server};Server=$dbServer;Database=$dbName;user id=$dbUser;password=$dbPass;trusted_connection=true;"
# and you need create table VDI

$cnDB = New-Object System.Data.Odbc.OdbcConnection($szConnect)
$dsDB = New-Object System.Data.DataSet


#Очищаем таблицу
    try
    {
        $cnDB.Open()
        $adDB = New-Object System.Data.Odbc.OdbcDataAdapter 

        $sql = "Delete from [$dbName].[dbo].[VDI]"     
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



$DesktopVM = [Xml] (Get-Content -Path "C:\XML\VDI.xml")
$DesktopVM = $DesktopVM.'machine-list'.'machine-entry'



#Записываем в таблицу и добавляем в админы


foreach ($DVM in $DesktopVM) {

    $hostname = $DVM.'machine-name'

    if ($DVM.'assigned-user-account-name')  {

                $DVM.'assigned-user-account-name'

                if ($DVM.'assigned-user-account-name' -notlike 'S-*') { 

                    try
                    {
                        $cnDB.Open()
                        $adDB = New-Object System.Data.Odbc.OdbcDataAdapter 
       
                        $curDate = Get-Date -format "MM-dd-yyyy HH:mm:ss"
                        $computer = $DVM.'machine-name'

                        $urername = $DVM.'assigned-user-account-name'
                        $user = $urername.TrimStart("$domain\") 


                        $sql = "INSERT INTO [dbo].[VDI]
                               ([computer]
                               ,[login]
                               ,[cDate])
                         VALUES
                               ('" + $computer + "', '" + $user + "', '" + $curDate + "')"     
                        $adDB.SelectCommand = New-Object System.Data.Odbc.OdbcCommand($sql, $cnDB) 

                        $adDB.Fill($dsDB) 
                        $cnDB.Close() 
                  
			if  ((Test-Connection $hostname -Count 1) -and (Test-Path "\\$hostname\c$\")) {
	                $domain
                        $computer
	                $user
                        $de = [ADSI]"WinNT://$computer/$Group,group" 
	                $de
                        $de.psbase.Invoke("Add",([ADSI]"WinNT://$domain/$user").path)
			}
                    }
                    catch [System.Data.Odbc.OdbcException]
                    {
                        $_.Exception
                        $_.Exception.Message
                        $_.Exception.ItemName
                    }


                 } #end if

                if ($DVM.'assigned-user-account-name' -like 'S-*') { 

                    try
                    {
                        $cnDB.Open()
                        $adDB = New-Object System.Data.Odbc.OdbcDataAdapter 
       
                        $curDate = Get-Date -format "MM-dd-yyyy HH:mm:ss"
                        $computer = $DVM.'machine-name'
            
                        $userSID = $DVM.'assigned-user-account-name'

                        $objSID = New-Object System.Security.Principal.SecurityIdentifier ($userSID)
                        $objUser = $objSID.Translate( [System.Security.Principal.NTAccount])
                        $user = $objUser.Value.TrimStart("$domain2\") 
 

                        $sql = "INSERT INTO [dbo].[VDI]
                               ([computer]
                               ,[login]
                               ,[cDate])
                         VALUES
                               ('" + $computer + "', '" + $user + "', '" + $curDate + "')"     
                        $adDB.SelectCommand = New-Object System.Data.Odbc.OdbcCommand($sql, $cnDB) 

                        $adDB.Fill($dsDB) 
                        $cnDB.Close() 

                        if  ((Test-Connection $hostname -Count 1) -and (Test-Path "\\$hostname\c$\")) {
	                $domain
                        $computer
	                $user
                        $de = [ADSI]"WinNT://$computer/$Group,group" 
	                $de
                        $de.psbase.Invoke("Add",([ADSI]"WinNT://$domain/$user").path)
			}
                    }
                    catch [System.Data.Odbc.OdbcException]
                    {
                        $_.Exception
                        $_.Exception.Message
                        $_.Exception.ItemName
                    }

                 } #end if

    } #test connection

} #end foreach

