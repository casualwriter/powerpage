# Development Guide

Powerpage is portable, lightweight, ready-make javascript application solution. 
No install, no compile, no packing. Just open editor to start coding.

Powerpage is very simple. It is a window with MS webbrowser control (best-run/equivalent to IE11). 
HTML Page talka to Powerpage when there is any additional requirement which web-browser cannot handle.

For example, 

* read a file, call ``javascript:pb.file.read()``
* run a program, call ``javascript:pb.run()``
* run sql to get data. call ``javascript:pb.db.query(sql,callback)``
* execute sql to update db,call ``javascript:pb.db.execute(sql,callback)``

## Intreface / API

Powerpage provides API called "pb-protocol" to talk to html pages. When html page loaded, 
javascript object ``pb`` is provided as interface service provider.

for details, please refer to [interface  guide](interface.md).

## Start page

Start page can be defined by commandline, or ini. Powerpage load the start html by the following sequence

1. from commandline. ``powerpage.exe your-start-page.html``

2. from powerpage.ini if no commandline option is found
```
[system]
start=your-start-page.html
```

3. if not defined in ini file, by default, powerpage load index.html if found or load powerpage.html if found. 


## Command Line

Powerpage support the following commandline parameters.

       powerpage.exe /ini={ini-file} /url={start-url} /print /fullscreen /save={save-html} /pdf={output-pdf-file} /delay={1000} /watch={watch}

* ``/ini={ini-file}`` specifies ini setting file.   
* ``/url={start-url}`` is used to specify startup link
* ``/print`` will load startup url, print and close program.
* ``/fullscreen`` or ``kiosk`` will run in fullscreen mode, useful for kiosk, or display board.
* ``/save={save-html}`` will load startup url, save to html file, and close program
* ``/pdf={output-pdf-file}`` will load startup url, generate PDF file, and close program
* ``delay={1000}`` specifies delay time (by milliseconds) for print/save/pdf options
* ``watch={watch}`` specifies "watch" setting for debug console output
 

## INI Setting

The following setting can be customized for your application.

~~~
[system]
start   = app-start-page.html
script  = powerpage.js
version = version-info-of-about-dialog
credit  = copyright-info-of-about-dialog
about   = brief-description-of-applicaiton
github  = url-of-github
home    = url-of-app-home
title   = fix-title ( or [html] for show html title, [file]to show url)
extLibrary=Powerbuilder Extend Library (e.g. powerExt1.pbl,powerExt2.pbl)
watch   = [cmd][ole][parm]

[database]
DBMS      = ODBC | O90 | etc..
DbParm    = db-connection-parameter
SeverName = db-server-name (or @encrypted-string)
LogId     = db-login-id (or @encrypted-string)
LogPass   = db-login-passowrd (or @encrypted-string)

[browser]
icon   = iconfile (or pbicon!)
title  = [html] | file | {fix-title} 
button = ABC  (a-about, b-goback, c-console)
silent = yes| no (show error of js script)
status = [yes] | pure | noweb | hide | no
status.backcolor=status-background-color (default=67108864)
status.textcolor=status-text-color (default=0)
left  = left-position
right = right-position
width = window-width
height= window-height
~~~

## Samples

Several sample applications are provided to demonstrate powerpage javascript application:

* [Powerpage Markdown editor](https://github.com/casualwriter/powerpage-markdown)
* [Powerpage Web Crawler](https://github.com/casualwriter/powerpage-web-crawler)
* Powerpage DB Schema (Oracle)
* Powerpage DB Report
* Powerpage js monkey 
* Display Board
* Application Framework

## Senario

to-be-continue...

