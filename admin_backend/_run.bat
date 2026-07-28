@echo off
cd /d "C:\Users\Lenovo\Desktop\admin_platform\admin_backend"
set "JAVA_HOME=C:\Users\Lenovo\Desktop\admin_platform\java21\jdk-21.0.2"
set "PATH=%JAVA_HOME%\bin;%PATH%"

echo === Java Version ===
java -version

echo === Building ===
call C:\Users\Lenovo\.m2\wrapper\dists\apache-maven-3.9.10\a38810a491b03367137adfdfbe7d14c4\bin\mvn.cmd clean package -s C:\Users\Lenovo\Desktop\admin_platform\admin_backend\settings.xml -DskipTests
if %ERRORLEVEL% NEQ 0 (echo === BUILD FAILED === & pause & exit /b 1)

echo.
echo ========================================
echo   Server starting on http://localhost:8080
echo   Keep this window open!
echo ========================================
echo.
java -jar target\admin_backend-0.0.1-SNAPSHOT.jar
pause
