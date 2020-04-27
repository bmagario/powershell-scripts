try {
    $test = Invoke-WebRequest -URI "https://endpoints.office.com/endpoints/Worldwide?ClientRequestId=aa79d030-edc2-4464-9bb5-d1afa433109a"
	Write-host $test
}catch {
	Write-host $ErrResp
}