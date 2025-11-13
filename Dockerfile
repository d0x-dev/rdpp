# Windows RDP Server for Railway
FROM mcr.microsoft.com/windows/servercore:ltsc2022

# Set shell to PowerShell
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Enable RDP
RUN Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0; \
    Enable-NetFirewallRule -DisplayGroup "Remote Desktop"; \
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name "UserAuthentication" -Value 0

# Create user and set password
RUN net user Administrator Darkboy336 /add /y && \
    net localgroup administrators Administrator /add && \
    wmic useraccount where "name='Administrator'" set PasswordExpires=False

# Install basic tools (optional)
RUN Invoke-WebRequest -Uri "https://github.com/PowerShell/PowerShell/releases/download/v7.3.9/PowerShell-7.3.9-win-x64.msi" -OutFile "powershell7.msi"; \
    Start-Process msiexec.exe -ArgumentList '/i', 'powershell7.msi', '/quiet', '/norestart' -Wait; \
    Remove-Item powershell7.msi

# Expose RDP port
EXPOSE 3389

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD powershell -Command "try { \$result = Get-Service -Name TermService -ErrorAction Stop; if (\$result.Status -eq 'Running') { exit 0 } else { exit 1 } } catch { exit 1 }"

# Start RDP services
CMD powershell -Command "Start-Service -Name TermService; Start-Service -Name SessionEnv; while (\$true) { Start-Sleep -Seconds 60 }"
