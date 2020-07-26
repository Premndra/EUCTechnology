[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')

[xml]$XAML = @'

<Window Name = "Window"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="EUC Technology SOE Image Deployment Wizard" Height="510" Width="760" ResizeMode="NoResize" FontSize="14" FontWeight="Bold" WindowStartupLocation="CenterScreen" Topmost="True">
    <Grid Name="Grid">
        <ComboBox Name="LocaleComboBox" HorizontalAlignment="Left" Height="42" Margin="151,147,0,0" VerticalAlignment="Top" Width="479"/>
        <TextBox Name="ComputerNameTextBox" HorizontalAlignment="Left" Height="38" Margin="151,53,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="479" BorderThickness="5" FontSize="14" FontWeight="Bold" MaxLength="15"/>
        <ComboBox Name="KeyboardComboBox" HorizontalAlignment="Left" Height="42" Margin="151,239,0,0" VerticalAlignment="Top" Width="479"/>
        <ComboBox Name="TimeZoneComboBox" HorizontalAlignment="Left" Height="42" Margin="151,334,0,0" VerticalAlignment="Top" Width="479"/>
        <Button Name="OkButton" Content="OK" HorizontalAlignment="Left" Height="42" Margin="315,409,0,0" VerticalAlignment="Top" Width="123" FontWeight="Bold" FontSize="14"/>
        <Label Name="ComputerNameLabel" Content="Computer Name:" HorizontalAlignment="Left" Height="30" Margin="149,18,0,0" VerticalAlignment="Top" Width="128" FontWeight="Bold" FontSize="14"/>
        <Label Name="LocaleLabel" Content="Currency and locale:" HorizontalAlignment="Left" Height="30" Margin="151,112,0,0" VerticalAlignment="Top" Width="150" FontWeight="Bold" FontSize="14"/>
        <Label Name="KeyboardLabel" Content="Keyboard layout:" HorizontalAlignment="Left" Height="30" Margin="151,204,0,0" VerticalAlignment="Top" Width="126" FontWeight="Bold" FontSize="14"/>
        <Label Name="TimeZoneLabel" Content="Time zone:" HorizontalAlignment="Left" Height="30" Margin="151,299,0,0" VerticalAlignment="Top" Width="108" FontWeight="Bold" FontSize="14"/>

    </Grid>
</Window>

'@

$global:SelectedKeyboard = "en-US"
$global:SelectedLocale = "en-US"
$global:SelectedTimezone = "Eastern Standard Time"


$reader=(New-Object System.Xml.XmlNodeReader $xaml) 
try{$Form=[Windows.Markup.XamlReader]::Load( $reader )}
catch{ Write-Host "Unable to load Windows.Markup.XamlReader. invalid XAML code was encountered or .NET FrameWork is missing."; exit}
$xaml.SelectNodes("//*[@Name]") | %{Set-Variable -Name ($_.Name) -Value $Form.FindName($_.Name) -Scope global } 

$LocaleCsv = Import-Csv Locale.csv

$TimeZoneCsv = Import-Csv TimeZone.csv

Foreach($LocaleValues in $LocaleCsv.DisplayName)

{
    $LocaleComboBox.Items.Add("$LocaleValues") | Out-Null

    $KeyboardComboBox.Items.Add("$LocaleValues") | Out-Null

}

Foreach ($Timezones in $TimeZoneCsv.DisplayName)

{
    $TimeZoneComboBox.Items.Add("$Timezones") | Out-Null
}

$TimeZoneComboBox.SelectedValue = "(UTC-05:00) Eastern Time (US ; Canada)"

$LocaleComboBox.SelectedValue = "English (United States)"

$KeyboardComboBox.SelectedValue = "English (United States)"

$TimeZoneComboBox.add_SelectionChanged({$global:SelectedTimezone = $TimeZoneCsv.TImeZoneCode[$TimeZoneComboBox.SelectedIndex]})

$LocaleComboBox.add_SelectionChanged({$global:SelectedLocale= $LocaleCsv.LocaleCode[$LocaleComboBox.SelectedIndex]})

$KeyboardComboBox.add_SelectionChanged({$global:SelectedKeyboard = $LocaleCsv.LocaleCode[$KeyboardComboBox.SelectedIndex]})

function Set-OSDTaskSequenceVariables

{ 
    if($ComputerNameTextBox.Text.Length -eq 0 -or 
    
       $ComputerNameTextBox.Text.Contains('`') -or $ComputerNameTextBox.Text.Contains("~") -or $ComputerNameTextBox.Text.Contains("@") -or $ComputerNameTextBox.Text.Contains("#") -or $ComputerNameTextBox.Text.Contains("$") -or 
       
       $ComputerNameTextBox.Text.Contains('%') -or $ComputerNameTextBox.Text.Contains("^") -or $ComputerNameTextBox.Text.Contains("&") -or $ComputerNameTextBox.Text.Contains("*") -or $ComputerNameTextBox.Text.Contains("(") -or

       $ComputerNameTextBox.Text.Contains(')') -or $ComputerNameTextBox.Text.Contains("_") -or $ComputerNameTextBox.Text.Contains("+") -or $ComputerNameTextBox.Text.Contains("=") -or $ComputerNameTextBox.Text.Contains("[") -or

       $ComputerNameTextBox.Text.Contains(']') -or $ComputerNameTextBox.Text.Contains("{") -or $ComputerNameTextBox.Text.Contains("}") -or $ComputerNameTextBox.Text.Contains("\") -or $ComputerNameTextBox.Text.Contains("/") -or

       $ComputerNameTextBox.Text.Contains('|') -or $ComputerNameTextBox.Text.Contains(";") -or $ComputerNameTextBox.Text.Contains(":") -or $ComputerNameTextBox.Text.Contains(",") -or $ComputerNameTextBox.Text.Contains(".") -or

       $ComputerNameTextBox.Text.Contains('>') -or $ComputerNameTextBox.Text.Contains("<") -or $ComputerNameTextBox.Text.Contains("?") -or $ComputerNameTextBox.Text.Contains(" ") -or $ComputerNameTextBox.Text.Contains("'") -or

       $ComputerNameTextBox.Text.Contains('"') )

        {
           
            $ComputerNameTextBox.BorderBrush = 'red'
        }


    else 

        {    
            $global:OSDComputerName = $ComputerNameTextBox.Text

            $TSEnv = New-Object -COMObject Microsoft.SMS.TSEnvironment

            $TSEnv.Value("OSDComputerName") = "$($OSDComputerName)"
	
	    $($OSDComputerName) | Out-File X:\Windows\Temp\Var.txt

            $TSEnv.Value("OSDUserLocale") = "$($global:SelectedLocale)"
        $($global:SelectedLocale) | Out-File X:\Windows\Temp\Var.txt -append
                        
            $TSEnv.Value("OSDInputLocale") = "$($global:SelectedLocale)"

 $($global:SelectedLocale) | Out-File X:\Windows\Temp\Var.txt -append

            $TSEnv.Value("OSDTimeZone") = "$($global:SelectedTimezone)"

 "$($global:SelectedTimezone)" | Out-File X:\Windows\Temp\Var.txt -append

            $TSEnv.Value("OSDSystemLocale") = "$($global:SelectedKeyboard)"

 "$($global:SelectedKeyboard)" | Out-File X:\Windows\Temp\Var.txt -append

               
            
            $Form.Close()
            
        }

}


$OkButton.Add_Click({Set-OSDTaskSequenceVariables})

$Form.ShowDialog() | out-null
