if( -Not (Test-Path -Path "C:\devops" ) )
{
    New-Item -ItemType directory -Path "C:\devops"
}

Configuration JreSetup {

    # Import the module that contains the resources we're using.
    Import-DscResource -ModuleName PsDesiredStateConfiguration

    # The Node statement specifies which targets this configuration will be applied to.
    Node 'localhost' {

        Script DownloadJre {
            GetScript =
            {
                @{
                    GetScript = $GetScript
                    SetScript = $SetScript
                    TestScript = $TestScript
                    Result = ('True' -in (Test-Path c:\devops\jre-8u171-windows-x64.exe))
                }
            }

            SetScript =
            {
                Invoke-WebRequest -Uri "https://s3-ap-southeast-1.amazonaws.com/sl1729/installable/jre-8u171-windows-x64.exe" -OutFile "c:\devops\jre-8u171-windows-x64.exe"
            }

            TestScript =
            {
                $Status = ('True' -in (Test-Path "c:\devops\jre-8u171-windows-x64.exe"))
                $Status -eq $True
            }
        }

        Package InstallJre
        {
            Ensure      = "Present"
            Path        = "c:\devops\jre-8u171-windows-x64.exe"
            Name        = "Java 8 Update 171 (64-bit)"
            ProductId   = "26A24AE4-039D-4CA4-87B4-2F64180171F0"
        }
    }
}
