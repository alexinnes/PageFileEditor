#H1 Change Computers Pagefile Size Programatically

This script will allow you to target computers and update their pagefile initial value and max value.
The script can target multiple computers in the "Computer" parameter.

```Powershell
Set-PageFileSize -Computer TestComputer -InitialSize 2046 -MaximumSize 4096
```

There is some error reporting, it will write an error to the screen but it will also write to a log (Useful if you are targeting multiple machines). By default it will put the errorlog to:
C:\PageFileScript\failedPageFile.log
Yet this can be overwritten by using the -ErrorFolder parameter.