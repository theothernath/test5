$computersFile = "computers.txt"
$computers = Get-Content $computersFile
$outFile = "portscan.txt"

# Ensure the output file is empty before starting
Clear-Content $outFile

foreach($computer in $computers) {
    Write-Host "Checking if $computer is online..."
    
    # Check if the computer is online by pinging it (Test-Connection)
    $isOnline = Test-Connection -ComputerName $computer -Count 1 -Quiet
    
    if ($isOnline) {
        Write-Host "$computer is online. Scanning ports..."
        22,80,443,445,3306,3389 | % {
            #Write-Host "  Testing port $_"
            try {
                # Try connecting to the port
                $tcpClient = New-Object Net.Sockets.TcpClient
                $tcpClient.Connect($computer, $_)
                Write-Host "    Port $_ open" | Out-File $outFile -Append
                # Save computer and open port to output file
                "$computer,$_" | Out-File $outFile -Append
                $tcpClient.Close()
            } catch {
                # Handle the specific error of connection refusal
                if ($_.Exception.Message -match "actively refused") {
                    Write-Host "    Port $_ actively refused on $computer" | Out-File $outFile -Append
                } else {
                    Write-Host "    Port $_ closed or unreachable on $computer" | Out-File $outFile -Append
                }
            }
        }
        Write-Host ""
    } else {
        Write-Host "$computer is offline. Skipping port scan." | Out-File $outFile -Append
    }
}
