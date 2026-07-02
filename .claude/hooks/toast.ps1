param(
    [string]$Title = "Claude Code",
    [string]$Message = "Агент завершил работу",
    [string]$Sound = "ms-winsoundevent:Notification.Default"
)

$ErrorActionPreference = "Stop"

[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
[Windows.UI.Notifications.ToastNotification, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
[Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime] | Out-Null

$titleEsc = [Security.SecurityElement]::Escape($Title)
$msgEsc = [Security.SecurityElement]::Escape($Message)
$soundEsc = [Security.SecurityElement]::Escape($Sound)

if ($Sound -eq "silent") {
    $audioXml = '<audio silent="true"/>'
} else {
    $audioXml = "<audio src=`"$soundEsc`"/>"
}

$template = @"
<toast>
  <visual>
    <binding template="ToastText02">
      <text id="1">$titleEsc</text>
      <text id="2">$msgEsc</text>
    </binding>
  </visual>
  $audioXml
</toast>
"@

$xml = New-Object Windows.Data.Xml.Dom.XmlDocument
$xml.LoadXml($template)

$toast = New-Object Windows.UI.Notifications.ToastNotification $xml
$notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("Claude Code")
$notifier.Show($toast)
