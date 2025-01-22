@echo off
echo Empaquetando servidor Node.js...
cd server
call pkg . --targets node16-win-x64 --output server.exe
if errorlevel 1 goto error

echo Empaquetando aplicación Flutter...
cd ..
flutter build windows
if errorlevel 1 goto error

echo Copiando servidor al directorio de la aplicación...
mkdir build\windows\runner\Release\server
copy server\server.exe build\windows\runner\Release\server\
copy server\package.json build\windows\runner\Release\server\
xcopy /E /I server\uploads build\windows\runner\Release\server\uploads

echo ¡Empaquetado completado!
echo La aplicación está en: build\windows\runner\Release
goto :eof

:error
echo Error durante el empaquetado
exit /b 1
