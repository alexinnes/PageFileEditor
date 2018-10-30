

Function Set-PageFileSize {
    <#
.Synopsis
    A script that can update multiple computers page file to be manual and set a initial and max value
.DESCRIPTION
    A script that can update multiple computers page file to be manual and set a initial and max value.
    If the script errors on trying to connect to the computer or if it fails to set the page file values it will error and create an error log.
    The default location for this log is (C:\PageFileScript\failedPageFile.log). This can be changed by using the -ErrorFolder parameter.
.EXAMPLE
    Set-PageFileSize -Computer TestComputer -InitialSize 2046 -MaximumSize 4096
#>
[CmdletBinding()]
    param (
            [#Default Param is the local computer.(Can be multiple computers)
            [Parameter(Mandatory=$false, Position=0)]
            [string[]]
            [Alias("Computer", "__SERVER", "IPAddress")]
            $Computers = $env:COMPUTERNAME,

            [#The intitial size of the page file needs to be set, default is 4GB
            [Parameter(Mandatory=$true, Position=1)]
            [int]
            $InitialSize = 4096],

            [#Max size of the page file needs to be set too.
            [Parameter(Mandatory=$true, Position=2)]
            [int]
            $maximumSize = 8192],

            [# Parameter help description
            [Parameter(Mandatory=$false, Position=3)]
            [Shell32.Folder]
            $errorFolder = "C:\PageFileScript"]
    )

    $dateTime = Get-Date

foreach($computers in $computer){

    #tests the connection to see if the computer is on.
        If(Test-Connection -ComputerName $computers -Count 2 -Quiet){
            Try{
                #updates the page file to not being managed
                $computerSystem = Get-WmiObject -Class Win32_ComputerSystem -EnableAllPrivileges -ComputerName $computers
                $computerSystem.AutomaticManagedPagefile = $false
                $computerSystem.Put()

                #Sets the values (min/max)
                $currentPageFile = Get-WmiObject -Class Win32_PageFileSetting -ComputerName $computers
                $currentPageFile.InitialSize = $InitialSize
                $currentPageFile.MaximumSize = $maximumSize

                #sets the values into the page file
                $currentPageFile.Put()
            }
            catch
            {
                #catch any errors while trying to set the page file values.
                $currentError = $error[0]
                Write-error "Unable to set Initial size or Maximum size: $($currentError.exception)"
                "$dateTime - $($currentError) --> $($computers)"| Out-File C:\$errorFolder\failedPageFile.log -Force -Append
            }
        }
        else{
            Write-Error -Message "Computer is showing as offline: $($computers)"
            "$dateTime - $($computers) is Offline"| Out-File C:\$errorFolder\failedPageFile.log -Force -Append
        }
    }
}

