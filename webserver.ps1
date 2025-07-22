Hi Greg,

Our team is responsible for creating bulk claims for the Operations Training team, which we currently handle through the UI.

To improve efficiency and automation, I’m planning to transition this process to use APIs instead of the UI. My setup is already working successfully in DV1, but I need a Client ID for TR1 to proceed with the implementation in that environment.

Could you please provide an existing Client ID for TR1, or help provision a new one?

Appreciate your support!

Best regards,
Harish Kumar



# Simple HTTP server to serve HTML and execute batch file with parameters
$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add("http://localhost:8080/")
$listener.Start()

while ($true) {
    $context = $listener.GetContext()
    $request = $context.Request
    $response = $context.Response

    if ($request.Url.AbsolutePath -eq "/") {
        # Serve the HTML form
        $response.ContentType = "text/html"
        $response.StatusCode = 200
        $response.OutputStream.Write(
            [System.Text.Encoding]::UTF8.GetBytes((Get-Content "form.html" -Raw)),
            0,
            (Get-Content "form.html" -Raw).Length
        )
    } elseif ($request.Url.AbsolutePath -eq "/submit") {
        # Read parameters from the request
        $reader = New-Object System.IO.StreamReader($request.InputStream)
        $body = $reader.ReadToEnd()
        $params = @{}
		Write-Output $params
        foreach ($param in $body -split '&') {
            $keyValue = $param -split '='
            if ($keyValue.Count -eq 2) {
                $params[$keyValue[0]] = [System.Net.WebUtility]::UrlDecode($keyValue[1])
				
            }
        }

        # Construct the command to run the batch file with parameters
        $batchFilePath = "script.bat"  # Update this path
        $param1 = $params['param1']
        $param2 = $params['param2']
		Write-Output $param1
        Start-Process -FilePath $batchFilePath -ArgumentList "$param1", "$param2" -NoNewWindow -Wait
        
        # Respond back to the client
        $response.StatusCode = 200
    } else {
        $response.StatusCode = 404
    }

    $response.Close()
}
