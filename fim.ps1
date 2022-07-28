 
Function Calculate-File-Hash($Filepath){ 
     $filehash = Get-FileHash -Path $filepath -Algorithm SHA512 
     return $filehash 
} 
 
Function Erase-Baseline-If-exists(){ 
     $baselineExists = Test-path -Path .\baseline.txt 
 
    If($baselineExists){ 
        #Delete  
         Remove-Item -Path .\baseline.txt 
   } 
} 




Write-host "What would you like to do?" 
Write-host "A) Collect new baseline ?" 
Write-host "B) begin monitoring files with saved baseline? " 
 
 
$resp = Read-host -Prompt "Please enter 'A' or 'B' " 
 
Write-host "User entered $($resp))" 

#Restrictions about input
 if ($resp -ne "A" -or "B"){
    Write-host "You can enter only A or B!"
 }

 
if ($resp -eq "A". ToUpper()) { 
    #Delete baseline.txt if it aslready exists 
    Erase-Baseline-If-exists 

 
# calculate hash from the target files and store in baseline.txt 
# collect all files in the target folder 
    $files = Get-ChildItem -Path .\files 
   
#for each file, calculate the hash and write it to baseline.txt 
foreach ($f in $files){ 
    $hash = Calculate-File-Hash $f.FullName 
    "$($hash.Path)| $($hash.Hash)" | Out-File -FilePath .\baseline.txt -Append 
   } 
} 
 
elseif ($resp -eq "B". ToUpper() ){ 
   $fileHashDictionary = @{} 
 
    #Load file|hash from baseline.txt and store them in a dictionary 
    $filePathsAndHashes = Get-Content -Path .\baseline.txt 
 
    foreach ($f in $filePathsAndHashes){ 
   $fileHashDictionary.add( $f.Split("|")[0], $f.Split("|")[1]) 
    } 

 
# Begin (continiously) monitoring files with saved Baseline 
while($true){ 
    Start-Sleep -Seconds 1 
 
    $files= Get-ChildItem -Path .\files 
      
    #Foreach file, calculate the hash, and write to baseline.txt 
    foreach ($f in $files){ 
        $hash = Calculate-File-Hash $f.FullName 

 
#Notify if a new file has been created 
if($fileHashDictionary[$hash.Path] -eq $null){ 
#A new file has been created 
    Write-Host "$($hash.Path) has been created!"  
   } 
   else{ 

   #Notify if a new file has been changed 
if ($fileHashDictionary[$hash.Path] -eq $hash.Hash){ 
#The file has not changed 
   }
else  { 
#The file has changed
Write-Host "$($hash.Path) has been changed!"  
     } 
   } 
} 

#Notify that file was deleted
foreach ($key in $fileHashDictionary.Keys) {
            $baselineFileStillExists = Test-Path -Path $key
            if (-Not $baselineFileStillExists) {
                # One of the baseline files must have been deleted, notify the user
                Write-Host "$($key) has been deleted!"  -BackgroundColor Black
     } 
}
}
}