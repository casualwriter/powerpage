# Development Guide

Powerpage is a ready-make Electron-like solution. No install, no compile, no packing. Just open editor to start coding.

A electon like solution make use of HTML for GUI, and javascript for business rule. Powerpage, as the  host engine, work out the rest requirement of application.

Requirement | Provider | Description
------------|-----------|-----------
(M) Data model | DBMS | Powerpage provide database accessbility for javascript.
(V) Visual GUI |  HTML | make use of HTML powerful presentation ability
(C) Control    | javascript   | Code business rule in js, with all kind of js library
Share Informaiton | powerpage  | Powerpage provide pb.session object to share information between html pages.
Shell Accessbility    | powerpage | Powerpage provide file accessibility, and run/shell command forjavacript
File Accessbility    | powerpage | Read/write fileby javascript    
Debug| Powerpage | Console, Log, etc.

## How Powerpage work

Powerpage is very simple. It is a window with MS webbrowser control. html talk to powerpage when there is any additional requirement which browser cannot handle.

For example, 

* read a file, call ``javascript:pb.file.read()``
* run a program, call ``javascript:pb.run()``
* run sql to get data. call ``javascript:pb.db.query(sql,callback)``
* execute sql to update db,call ``javascript:pb.db.execute(sql,callback)``

## Intreface / API

Powerpage provides "pb protocol command" to talk to html pages. the command isalso packaged as javascript object ``pb`` as interface service provider.

for details, please refer to interface  guide.


## Deployment


## Samples

* Markdown editor
* Database Schema (Oracle)
* Database Browser
* Display Board
* Web Scarper
* PowerJsMonkey 
* Application Framework

## Senario

to-be-continue...
