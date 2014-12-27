@echo off

set STYLESHEET="%~f1"
set TEST_STYLESHEET="%~d1%~p1test-%~n1.xsl"
set RESULT="%~d1%~p1test-%~n1-result.xml"
set HTML="%~d1%~p1test-%~n1-result.html"

echo Creating Test Stylesheet...
java net.sf.saxon.Transform -o %TEST_STYLESHEET% %STYLESHEET% generate-tests.xsl
echo.
echo Running Tests...
java net.sf.saxon.Transform -o %RESULT% -it main %TEST_STYLESHEET%
echo.
echo Formatting Report...
java net.sf.saxon.Transform -o %HTML% %RESULT% format-report.xsl
%HTML%