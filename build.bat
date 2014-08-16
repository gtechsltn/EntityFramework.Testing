@echo off

reg.exe query "HKLM\SOFTWARE\Microsoft\MSBuild\ToolsVersions\4.0" /v MSBuildToolsPath > nul 2>&1
if ERRORLEVEL 1 goto MissingMSBuildRegistry

for /f "skip=2 tokens=2,*" %%A in ('reg.exe query "HKLM\SOFTWARE\Microsoft\MSBuild\ToolsVersions\4.0" /v MSBuildToolsPath') do SET MSBUILDDIR=%%B

IF NOT EXIST %MSBUILDDIR%nul goto MissingMSBuildToolsPath
IF NOT EXIST %MSBUILDDIR%msbuild.exe goto MissingMSBuildExe

::BUILD
"tools\nuget.exe" restore EntityFramework.Testing.sln 
"%MSBUILDDIR%msbuild.exe" "src\EntityFramework.Testing\EntityFramework.Testing.csproj" /t:ReBuild /p:Configuration=Release;TargetFrameworkVersion=v4.0;DefineConstants="TRACE;NET40";FrameworkFolder=net40;OutPutPath=bin\Release\net40\
"%MSBUILDDIR%msbuild.exe" "src\EntityFramework.Testing\EntityFramework.Testing.csproj" /t:ReBuild /p:Configuration=Release;TargetFrameworkVersion=v4.5;DefineConstants="TRACE;NET45";FrameworkFolder=net45;OutPutPath=bin\Release\net45\
"%MSBUILDDIR%msbuild.exe" "src\EntityFramework.Testing.Moq\EntityFramework.Testing.Moq.csproj" /t:ReBuild /p:Configuration=Release;TargetFrameworkVersion=v4.0;DefineConstants="TRACE;NET40";FrameworkFolder=net40;OutPutPath=bin\Release\net40\
"%MSBUILDDIR%msbuild.exe" "src\EntityFramework.Testing.Moq\EntityFramework.Testing.Moq.csproj" /t:ReBuild /p:Configuration=Release;TargetFrameworkVersion=v4.5;DefineConstants="TRACE;NET45";FrameworkFolder=net45;OutPutPath=bin\Release\net45\

mkdir build
del "build\*.nupkg"

::PACK
"tools\nuget.exe" pack "src\EntityFramework.Testing\EntityFramework.Testing.nuspec" -OutputDirectory build
"tools\nuget.exe" pack "src\EntityFramework.Testing.Moq\EntityFramework.Testing.Moq.nuspec" -OutputDirectory build

::DEPLOY
"tools\nuget.exe" push "build\*.nupkg"

goto:eof
::ERRORS
::---------------------
:MissingMSBuildRegistry
echo Cannot obtain path to MSBuild tools from registry
goto:eof
:MissingMSBuildToolsPath
echo The MSBuild tools path from the registry '%MSBUILDDIR%' does not exist
goto:eof
:MissingMSBuildExe
echo The MSBuild executable could not be found at '%MSBUILDDIR%'
goto:eof