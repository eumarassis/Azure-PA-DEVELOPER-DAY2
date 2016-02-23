#--------------------------------------------------------------------------------- 
#The sample scripts are not supported under any Microsoft standard support program or service. The sample scripts are provided AS IS without warranty  
#of any kind. Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for 
#a particular purpose. The entire risk arising out of the use or performance of  the sample scripts and documentation remains with you. In no event shall 
#Microsoft, its authors, or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption,loss of business information, or other pecuniary loss) arising out of the use 
#of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages 
#--------------------------------------------------------------------------------- 
#requires -Version 3.0
<#
     .SYNOPSIS
       This script can be create stored access policy of a container in Windows Azure and generates a Create Credentials Statement for SQL to use.
    .PARAMETER  PublishSettingsFile
        Specifies the PublishSettings FIle downloaded after running Get-AzurePublishSettingsFile.
    .PARAMETER  SubscriptionName
        Specifies the Azure Subscription Name.
    .PARAMETER  StorageAccountName
        Specifies the name of the storage account to be connected.
    .PARAMETER  ContainerName
        Specifies the name of container.
    .PARAMETER  NumContainers
        Number of containers which uses the Container Name followed by a number ( Example : Sqlcontainer1, SqlContainer2 )
    .PARAMETER  StoredAccessPolicy
        Specifies one or more specified name of stored access policy.
    .PARAMETER  StartTime
        Specifies Start Time for the StoredAccessPolicy applied to the container
    .PARAMETER  ExpiryTime
        Specifies Expiriy Time for the StoredAccessPolicy applied to the container
    .PARAMETER  LogFilePath
        Specifies the path to the log file which logs the Create Credential Statements.    
    .EXAMPLE
        .\SASPolicyTokens.ps1 -PublishSettingsFile "c:\temp\AzureSettings.publishsettings" -SubscriptionName "AzureAcct" -StorageAccountName "denzilrstorage1" -ContainerName "sqlcontainer" -NumContainers 2 -StoredAccessPolicy "TestPolicy" -StartTime "1/1/2015" -ExpiryTime "1/1/2016" -LogFilePath "D:\Temp\creds.txt"
        
#>

# Run Get-AzurePublishSettings to save the PublishSettings file
# or go to https://manage.windowsazure.com/publishsettings

Param
(

    [Parameter(Mandatory=$true)]
    [String]$SubscriptionName,

    [Parameter(Mandatory=$true)]
    [String]$StorageAccountName,

    [Parameter(Mandatory=$true)]
    [String]$ContainerName,

    [Parameter(Mandatory=$true)]
    [int]$NumContainers,

    [Parameter(Mandatory=$true)]
    [String]$StoredAccessPolicy,

    [Parameter(Mandatory=$true)]
    [DateTime]$StartTime,

    [Parameter(Mandatory=$true)]
    [DateTime]$ExpiryTime,

    [Parameter(Mandatory=$false)]
    [String]$LogFilePath
)

If((Get-Module -Name Azure) -eq $null)
{
    Import-Module Azure
}

#Check if Windows Azure PowerShell Module is avaliable
If((Get-Module -Name Azure) -eq $null)
{
    Write-Warning "Install Windows Azure Powershell from http://www.windowsazure.com/en-us/downloads/#cmd-line-tools"
}
Else
{

                
    if ($LogFilePath) 
    {
         If (Test-Path $LogFilePath)
        {
            Remove-Item $LogFilePath
        }
    }
    
    Add-AzureAccount

    Select-AzureSubscription $SubscriptionName -ErrorAction SilentlyContinue -ErrorVariable IsSubscriptionExist | Out-Null
    If($IsSubscriptionExist.Exception -ne $null)
    { 
        Write-Host "Incorrect Subscription entered: $SubscriptionName" 
        Write-Host $IsSubscriptionExist
        exit $LASTEXITCODE
    }

    Get-AzureStorageAccount -StorageAccountName $StorageAccountName -ErrorAction SilentlyContinue -ErrorVariable IsStorageExists | Out-Null
    #Check existance of storage account
    If($IsStorageExists.Exception -ne $null)
    {
        Write-Host "Invalid Storage account: " $IsStorageExists
        exit $LASTEXITCODE
    }
                   
    $StorageAccountKey = (Get-AzureStorageKey -StorageAccountName $StorageAccountName).Primary
    $Creds = New-Object Microsoft.WindowsAzure.Storage.Auth.StorageCredentials("$StorageAccountName","$StorageAccountKey")
    $CloudStorageAccount = New-Object Microsoft.WindowsAzure.Storage.CloudStorageAccount($creds, $true)
    $CloudBlobClient = $CloudStorageAccount.CreateCloudBlobClient()

    For ($i=1; $i -le $NumContainers; $i++)  
    {
        Write-Verbose "Getting the container object named $ContainerName."
        $NewContainer = $ContainerName +  [string] $i
        $BlobContainer = $CloudBlobClient.GetContainerReference($NewContainer)
        $ContainerCreated = $BlobContainer.CreateIfNotExists();
                        
        #Create an access policy instance
        $SharedAccessBlobPolicy = New-Object Microsoft.WindowsAzure.Storage.Blob.SharedAccessBlobPolicy
                                        
        #Sets start time and expiry time for access policy
        $SharedAccessBlobPolicy.SharedAccessStartTime = $StartTime
        $SharedAccessBlobPolicy.SharedAccessExpiryTime = $ExpiryTime
        $PermissionValue = 0
        $PermissionValue += [Int][Microsoft.WindowsAzure.Storage.Blob.SharedAccessBlobPermissions]::Read
        $PermissionValue += [Int][Microsoft.WindowsAzure.Storage.Blob.SharedAccessBlobPermissions]::Write
        $PermissionValue += [Int][Microsoft.WindowsAzure.Storage.Blob.SharedAccessBlobPermissions]::List
        $PermissionValue += [Int][Microsoft.WindowsAzure.Storage.Blob.SharedAccessBlobPermissions]::Delete
                   
        #Sets permission of stored access policy
        $SharedAccessBlobPolicy.Permissions = $PermissionValue
        $ContainerPermission = $BlobContainer.GetPermissions()
                    
        Write-Verbose "--Create a stored access policy '$StoredAccessPolicy'."
        $ContainerPermission.SharedAccessPolicies.Clear()
        $ContainerPermission.SharedAccessPolicies.Add($StoredAccessPolicy,$SharedAccessBlobPolicy)
        $ContainerPermission.PublicAccess = [Microsoft.WindowsAzure.Storage.Blob.BlobContainerPublicAccessType]::Off
        $BlobContainer.SetPermissions($ContainerPermission)

        Write-Verbose "Getting Shared Access Signature."
        $SasContainerToken = $BlobContainer.GetSharedAccessSignature($null,$StoredAccessPolicy);

        $token = $SasContainerToken.SubString(1)
        [string] $CreateCredentialString = "Create Credential [" + [string] $BlobContainer.Uri +"] With identity='Shared Access Signature',SECRET = '$token'"
        Write-Host $CreateCredentialString
        Write-Host "GO"
                    
        if($LogFilePath)
        {
            Write-Output $CreateCredentialString | Out-File $LogFilePath -Append 
            Write-Output "GO" | Out-File $LogFilePath -Append 
        }
                    
   }               
    
}