@echo off
cd /d C:\Users\Lenovo\Desktop\admin_platform\admin_backend
set "JAVA_HOME=C:\Program Files\Java\jdk-25.0.2"
set "PATH=%JAVA_HOME%\bin;%PATH%"
echo JAVA_HOME=%JAVA_HOME%
java -version
C:\Users\Lenovo\.m2\wrapper\dists\apache-maven-3.9.10\a38810a491b03367137adfdfbe7d14c4\bin\mvn.cmd package -DskipTests -s C:\Users\Lenovo\Desktop\admin_platform\admin_backend\settings.xml
