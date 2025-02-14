$csv = foreach ($i in (Get-Content C:\Users\abrubeck\Downloads\HarborGrief\365JustUPNs-Test.csv)) {

    # Grab user properties and generate id
    $user = Get-MgUser -UserId $i -Property "UserPrincipalName,AccountEnabled,onPremisesExtensionAttributes,SynchronizationDetails,Id"
    $id = (Get-MgUser -UserId $i).Id
    
    # Get license info
    $licenses = (Get-MgUserLicenseDetail -UserId $i).SkuPartNumber -join "; "

    # Grab ADSync status
    if ($user.SynchronizationDetails.Count -gt 0) {
        $syncstatus = "ADSync"
    } else {
        $syncstatus = "Cloud"
    }

    # Grab last auth time
    $signin = Get-MgUser -UserId $id -Property SignInActivity | Select-Object -ExpandProperty SignInActivity
    $lastsignin = $signInData.LastSignInDateTime


    # Generate PSCustomObject output
    [PSCustomObject]@{
        UserPrincipalName   = $user.UserPrincipalName
        AccountEnabled      = $user.AccountEnabled
        ExtensionAttribute2 = $user.onPremisesExtensionAttributes.extensionAttribute2
        AD_SyncStatus       = $syncstatus
        LicenseAssigned     = $licenses
        LastLogonTime       = $lastsignin
    }
}

# CSV Export
$csv | Export-Csv -Path C:\temp\Final.csv -NoTypeInformation
