::Window+R %appdata% create youtube-dl folder, create config.txt with comman: -o 'D:\youtube-dl\%(id)s\%(title)s-%(id)s.%(ext)s'
::Ctrl+C to stop
::youtube-dl --list-format url
::youtube-dl -f (formatcode1/formatcode2/formatcode3) url
::download lossless(flac) audio from youtube (-x is short for --extract-audio)
::youtube-dl -x --audio-format flac url
::ffmpeg -i "input.mp4" -ss 00:00:00 -to 00:41:31 -c copy "output.mp4"
::ffmpeg -i "input.mp4" -ss 00:00:00 -to 00:41:31 -c copy "output.mp4" -ss 00:41:31 -to 00:50:00 -c copy "output.mp4"

@ECHO OFF

if not -%1-==-- SET Destination=%*
if -%1-==-- goto fopNew

if not -%1-==-- SET URL=%*
if -%1-==-- goto fopNew

:top
CLS
ECHO Destination: %Destination%
ECHO URL: %URL%
ECHO ---------------------
ECHO Available operations
ECHO ---------------------

::This prints the list of the operations
ECHO 1. Download best video quality
ECHO 2. Download custom video quality
ECHO 3. Convert video to mp4 high quality
ECHO 4. Convert video to mp4 quicktime
ECHO 5. Download lossless audio from video
ECHO 6. Take thumbnail picture from video
ECHO 7. Make gif from video
ECHO 8. Split video into 2 parts
ECHO 9. Convert videos to mp4 quicktime
ECHO 10. Concat videos
ECHO -
ECHO f. List all possible formats video
ECHO n. Process New File
ECHO n1. New Destination
ECHO n2. New URL
ECHO -
ECHO u. Auto update youtube-dl
ECHO x. Quit
ECHO -

::Ask the user to choose the operation they want

SET /P operation=Which operation would you like to do?:
if "%operation%"=="1" goto fop1
if "%operation%"=="2" goto fop2
if "%operation%"=="3" goto fop3
if "%operation%"=="4" goto fop4
if "%operation%"=="5" goto fop5
if "%operation%"=="6" goto fop6
if "%operation%"=="7" goto fop7
if "%operation%"=="8" goto fop8
if "%operation%"=="9" goto fop9
if "%operation%"=="10" goto fop10
if "%operation%"=="n" goto fopNew
if "%operation%"=="N" goto fopNew
if "%operation%"=="n1" goto fopNewDestination
if "%operation%"=="N1" goto fopNewDestination
if "%operation%"=="n2" goto fopNewURL
if "%operation%"=="N2" goto fopNewURL
if "%operation%"=="f" goto fopFormat
if "%operation%"=="F" goto fopFormat
if "%operation%"=="u" goto fopUpdate
if "%operation%"=="U" goto fopUpdate
goto fopQuit


:fop1
CLS
ECHO -------------
ECHO Best quality
ECHO -------------
youtube-dl -f best %URL%
::timeout /t 30
pause
goto top

:fop2
CLS
ECHO ---------------
ECHO Custom quality
ECHO ---------------
ECHO n. Return
SET /P FORMAT=Please enter format code(3/2/1/0):
if "%FORMAT%"=="n" goto top
if "%FORMAT%"=="N" goto top
youtube-dl -f %FORMAT% %URL%
pause
goto top

:fop3
CLS
ECHO ----------------------------
ECHO Convert to mp4 high quality
ECHO ----------------------------
SET /P TYPE= Type of inputvideo (ts/mkv/webm):
ffmpeg -i "%Destination%\%URL%.%TYPE%" -c:v libx264 -c:a aac "%Destination%\%URL%.mp4"
SET /P ASK= Do you want to delete original video(y/n)?:
if "%ASK%"=="y" del "%Destination%\%URL%.%TYPE%"
if "%ASK%"=="Y" del "%Destination%\%URL%.%TYPE%"
pause
goto top

:fop4
CLS
ECHO ---------------
ECHO Convert to mp4
ECHO ---------------
SET /P TYPE= Type of input video(ts/mkv/webm):
::ffmpeg -i "%Destination%\%URL%.%TYPE%" -c copy "%Destination%\%URL%.mp4"
ffmpeg -i "%Destination%\%URL%.%TYPE%" -acodec copy -vcodec copy "%Destination%\%URL%.mp4"
SET /P ASK= Do you want to delete original video(y/n)?:
if "%ASK%"=="y" del "%Destination%\%URL%.%TYPE%"
if "%ASK%"=="Y" del "%Destination%\%URL%.%TYPE%"
pause
goto top


:fop5
CLS
ECHO ---------------
ECHO Lossless audio
ECHO ---------------
youtube-dl -x --audio-format flac %URL%
pause
goto top

:fop6
CLS
ECHO ------------------
ECHO Thumbnail picture
ECHO ------------------
SET /P TYPE= Type of input video(ts/mkv/webm/mp4):
SET /P TIME=Please enter time(hh:mm:ss):
ffmpeg -i "%Destination%\%URL%.%TYPE%" -ss %TIME% -vframes 1 "%Destination%\%URL%.png"
timeout /t 2
goto top

:fop7
CLS
ECHO ----
ECHO GIF
ECHO ----
SET /P TYPE= Type of input video(ts/mkv/webm/mp4):
SET /P TIMEBEGIN=Please enter time begin(hh:mm:ss or ss):
SET /P TIMEFINISH=Please enter time finish(hh:mm:ss or ss):
SET /P SCALE=Please enter scale:
::scale(1280/340..)
ffmpeg -ss %TIMEBEGIN% -t %TIMEFINISH% -i "%Destination%\%URL%.%TYPE%" -vf "fps=30,scale=%SCALE%:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" -loop 0 "%Destination%\output.gif"
pause
goto top

:fop8
CLS
ECHO ---------------------------
ECHO Split video into two parts
ECHO ---------------------------
SET /P TIMEBEGIN=Please enter time begin(hh:mm:ss):
SET /P TIMEFINISH=Please enter time finish(hh:mm:ss):
ffmpeg -i "%Destination%\%URL%.mp4" -ss %TIMEBEGIN% -to %TIMEFINISH% -c copy "%Destination%\%URL%(1).mp4" -ss %TIMEFINISH% -c copy "%Destination%\%URL%(2).mp4"
timeout /t 2
goto top

:fop9
CLS
ECHO ----------------------
ECHO Convert videos to mp4
ECHO ----------------------
SET root=/d %Destination%
cd %root%
for %%i in (*.ts,*.webm,*.mkv,*.mov) do (
    ffmpeg -i "%%i" -c copy "%%~ni.mp4"
    if not errorlevel 1 if exist "%%~ni.mp4" del "%%i"
)
timeout /t 2
goto top

:fop10
ECHO --------------
ECHO Concat videos
ECHO --------------
(for %%i in (*.mp4,*.ts) do echo file '%%i') > mylist.txt
ffmpeg -f concat -i mylist.txt -c copy output.mp4
if exist "output.mp4" del "mylist.txt"
timeout /t 2
goto top

:fopFormat
CLS
ECHO -----------------------------
ECHO List of all possible formats
ECHO -----------------------------
youtube-dl -F %URL%
pause
goto top

:fopUpdate
CLS
ECHO --------
ECHO Updates
ECHO --------
youtube-dl -U
pause
goto top

:fopNew
CLS
SET /P Destination=Please enter destination:
SET /P URL=Please enter the video URL:
goto top

:fopNewDestination
CLS
SET /P Destination=Please enter destination:
goto top

:fopNewURL
CLS
SET /P URL=Please enter the video URL:
goto top

:fopQuit