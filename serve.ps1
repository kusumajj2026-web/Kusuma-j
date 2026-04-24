$port = 8080
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")
$listener.Start()
Write-Host "Server started at http://localhost:$port/"

try {
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $response = $context.Response
        
        $localPath = $context.Request.Url.LocalPath
        if ($localPath -eq "/") { $localPath = "/index.html" }
        
        # Remove leading slash and decode URL
        $relativePath = [uri]::UnescapeDataString($localPath.TrimStart('/'))
        $filePath = Join-Path $PWD.Path $relativePath
        
        if (Test-Path $filePath -PathType Leaf) {
            $content = [System.IO.File]::ReadAllBytes($filePath)
            $response.SendChunked = $true
            
            if ($filePath -match "\.html$") { $response.ContentType = "text/html" }
            elseif ($filePath -match "\.css$") { $response.ContentType = "text/css" }
            elseif ($filePath -match "\.js$") { $response.ContentType = "application/javascript" }
            elseif ($filePath -match "\.jpeg$") { $response.ContentType = "image/jpeg" }
            elseif ($filePath -match "\.pdf$") { $response.ContentType = "application/pdf" }
            
            $response.OutputStream.Write($content, 0, $content.Length)
        } else {
            $response.StatusCode = 404
        }
        $response.Close()
    }
}
finally {
    $listener.Stop()
}
