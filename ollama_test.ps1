# -----------------------------------------------------------------
#  Ollama API demo – PowerShell (works on any Windows 10/11 with
#  Ollama running locally on port 11434)
# -----------------------------------------------------------------

# 1️⃣ Build request body
$body = @{
    model  = 'llama3.1:8b'
    prompt = 'Say hello in JSON format'
    stream = $false
    format = 'json'
}

# 2️⃣ Send request
$response = Invoke-RestMethod `
    -Uri 'http://localhost:11434/api/generate' `
    -Method POST `
    -ContentType 'application/json' `
    -Body ($body | ConvertTo-Json -Depth 5)

# 3️⃣ Show result
Write-Host "`n=== Full Ollama response ===`n"
$response | ConvertTo-Json -Depth 10 | Write-Host

# 4️⃣ Extract the inner JSON string (the actual model answer)
Write-Host "`n=== Model answer (parsed) ===`n"
$answer = $response.response | ConvertFrom-Json
$answer | Format-Table -AutoSize
Write-Host "`n=== Raw model answer ===`n"
$response.response | Write-Host