@echo off
cd /d "C:\Users\Lenovo\Desktop\admin_platform\admin_backend"
set "JAVA_HOME=C:\Program Files\Java\jdk-25.0.2"
set "PATH=%JAVA_HOME%\bin;%PATH%"

echo ===== Java ?? =====
java -version

echo ===== ????? =====
rmdir /s /q target 2>nul
if exist target (
    echo target ?????????? target ??????
    pause
    exit /b 1
)

echo ===== Maven ?? =====
call C:\Users\Lenovo\.m2\wrapper\dists\apache-maven-3.9.10\a38810a491b03367137adfdfbe7d14c4\bin\mvn.cmd package -DskipTests -s C:\Users\Lenovo\Desktop\admin_platform\admin_backend\settings.xml

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ===== ?????????????? =====
    pause
    exit /b 1
)

echo ===== ????????? =====
java -jar target\admin_backend-0.0.1-SNAPSHOT.jar
pause
