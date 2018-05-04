## Description:This script downloads the databags and decrypts it for you
# Hope it works for you!
#



#
# Variable Section
#

$chefRepoLocation = "C:\temp\chef-repo"
 
 
# 
# Functions Section
#

function invoke-decrypt_dbag($dbag) 
{
$dbagitems = ((Get-Item ".\data_bags\$dbag").GetFiles()).Name
    foreach ($item in $dbagitems)
    {
    #output file to json
    $json = knife data bag show $dbag $item.split('.')[0] --secret-file ./secrets/encrypted_data_bag_secret -F json
 
    #cleanup spam
    $fileout = '{'+$json.Split('{')[-1]
 

    #save file
    $json | Out-File .\data_bags\$dbag\$item -Force
    }
}
 
 

#Upload the databags function 
function invoke-upload_dbags{
    $dbagitems = ((Get-Item ".\data_bags\$dbag").GetFiles()).Name
    foreach ($dbagitem in $dbagitems)
    {
    knife data bag from file $dbag $dbagitem --secret-file ./secrets/encrypted_data_bag_secret
    }
}
 
 
# 
# Process Section
#

 
$dbag = Read-Host -Prompt "Which Data Bag do you want to run this for?"

#Navigate to the Repo path
Set-Location $chefRepoLocation
 
#download databags (this is so we can see what Databag items we have online to decrypt, these are then overwritten with the decrypted ones later)
knife download data_bags/$dbag

#Run Databag Decryption Function
invoke-decrypt_dbag -dbag $dbag

Write-Host "Download and Decryption Complete!"

#Wait for changes to be made before reuploading them
write-host "Now would be a good time to make any changes and save them before I upload them"
 
$upload = read-host -Prompt "are you ready to upload changes? yes or no"
 
#If Ready then upload the edited databags
Switch ($upload)
{
"yes" {write-host "Uploading Databags";invoke-upload_dbags}
"no" {write-error "Okay!"}
default {Write-error "Oh god, all you had to do was say yes or no"}
}
