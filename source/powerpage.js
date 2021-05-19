//========================================================================
// PB interface. 
// 20210301. ck.  pb.callback(), run commands, and all basic features
// 20210505. ck.  pb.session()
// 20210507. ck.  pb.console(), pb.eval() for console support
//========================================================================
// pb main function, pb('varname') = js.varname, pb('#div') = getElementById
var pb = function (n) { return n[0]=='#'? document.getElementById(n.substr(2)) : window[n]; }

//=== show message for microhelp, internal error 
pb.microhelp = function (msg) { document.title='pb://microhelp/'+ msg } 
pb.error = function(code,msg) { pb.microhelp( '[error='+ code +'] ' + msg ) }

//=== router function for Powerbuilder, divert to callback 
pb.router = function ( name, result, type, url ) {
  if (typeof window[name] === "function") {
      window[name]( result, type, url );
  } else if (name) {
      alert( 'callback function ' + name + '() not found!\n\n type:' + type + ' from url: ' + url 
             + '\n function: '+name + '\n Result: \n\n' + result )
  } else if (type=='json'||type=='table'||type=='sql'||type=='file') {
      alert( 'callback (default)\n\n type:' + type + ' from url: ' + url 
             + '\n function: '+name + '\n Result: \n\n' + result )
  }  
}

//=== console support 
if (typeof console=="undefined") var console = { }

console.log = pb.console = function () {
  var i, msg = ''
  for (i=0; i < arguments.length; i++) {
    if (typeof arguments[i] === "object") {
      msg += (i==0?'':', ') + JSON.stringify(arguments[i])
    } else {  
      msg += (i==0?'':', ') + arguments[i]
    }
  }
  pb.microhelp( '> ' + msg )   
}

pb.eval = function (exp) {
  try {
    var result = eval(exp)
    pb.microhelp( exp  + (typeof result=="undefined"? '' : '|n= ' + (typeof result=='object'? JSON.stringify(result) : result ) ) )
  } catch (e) {
    pb.microhelp( exp  + '|nError: ' + e.message )      
  }  
}

//=== secure protocol support
pb.cmd = { protocol:'pb://' }
pb.secure = function() { pb.cmd.protocol = 'ps://' ; return pb }

//=== add Prompt to parepare queue
pb.prompt = pb.confirm = function (msg) { 
  pb.cmd.prompt = msg; 
  return pb 
}

//=== add callback to prepare queue
pb.callback = function (funcname) { 
  pb.cmd.callback = funcname; 
  return pb 
}
 
//=== submit command to Powerbuilder. (support cmd history later)
pb.submit = function (cmd) {
  window.location = pb.cmd.command = cmd
}

//=== prepare command prefix with Prompt and callback
pb.cmd.prepare = function(callback) {
   pb.cmd.prefix = pb.cmd.protocol
   pb.cmd.prefix += (pb.cmd.prompt? '?' + pb.cmd.prompt + '?/' : '' )
   pb.cmd.callback = (callback||pb.cmd.callback)
   pb.cmd.prefix += (pb.cmd.callback? 'callback/'+pb.cmd.callback+'/' : '' )
   pb.cmd.prompt = pb.cmd.callback = null  
   return pb.cmd.prefix
}

//=== generate parameter string
pb.cmd.parameters = function(args) {
  if (!args) {
    return ''
  } else if (typeof args === "string" || typeof args === "number") {
    return "/" + args
  } else if (typeof args === "object") {
    var i, key='/';
    for (i=0; i<args.length; i++) { key += args[i]; }
    return key;
  } else {  
    pb.error( '01', "[error] unknow type of arguments! " + args )
  } 
}

//=== call run() commands
pb.run = function ( cmd, callback ) { pb.submit( pb.cmd.prepare(callback) + 'run/' + cmd ) }
pb.runat = function ( cmd, callback ) { pb.submit( pb.cmd.prepare(callback) + 'run@/' + cmd ) }   

//=== shell functions
pb.shell = { name: 'shell functions' }
pb.shell.open = function (path,callback) { pb.submit( pb.cmd.prepare(callback) + 'shell/open/' + path ) };
pb.shell.max  = function (path,callback) { pb.submit( pb.cmd.prepare(callback) + 'shell/max/' + path ) };
pb.shell.print = function (path,callback) { pb.submit( pb.cmd.prepare(callback) + 'shell/print/' + path ) }; 
pb.shell.run = function (path,callback) { pb.submit( pb.cmd.prepare(callback) + 'shell/run/' + path ) };

//=== call Powerbuilder dialog, window, function
pb.dialog = function (win, args, callback) { pb.submit( pb.cmd.prepare(callback) + 'dialog/' + win + pb.cmd.parameters(args) ) }
pb.window = function (win, args, callback) { pb.submit( pb.cmd.prepare(callback) + 'window/' + win + pb.cmd.parameters(args) ) }
pb.function = function (win, args, callback) { pb.submit( pb.cmd.prepare(callback) + 'function/' + win + pb.cmd.parameters(args) ) }
pb.popup = function (url,callback) { pb.submit( pb.cmd.prepare(callback) + 'popup/' + url ) }

//=== database function
pb.db = { name: 'database functions' }
pb.db.json  = function ( sql, callback ) { pb.submit( pb.cmd.prepare(callback) + 'json/' + sql ) };
pb.db.table = pb.db.html  = function ( sql, callback ) { pb.submit( pb.cmd.prepare(callback) + 'table/' + sql ) };
pb.db.query = pb.db.select = function ( sql, callback ) { pb.submit( pb.cmd.prepare(callback) + 'json/' + sql ) };  
pb.db.execute = pb.db.update = function ( sql, callback ) { pb.submit( pb.cmd.prepare(callback) + 'sql/execute/' + sql ) };
pb.db.confirm = pb.db.prompt = function ( sql, callback ) { pb.submit( pb.cmd.prepare(callback) + 'sql/prompt/' + sql ) };

//=== file functions
pb.file = { name: 'file functions' }
pb.file.copy = function (from, to, callback) { pb.submit( pb.cmd.prepare(callback) + 'file/copy/' + from + '/' + to ) }
pb.file.move = function (from, to, callback) { pb.submit( pb.cmd.prepare(callback) + 'file/move/' + from + '/' + to ) }
pb.file.read = function (file, callback) { pb.submit( pb.cmd.prepare(callback) + 'file/read/' + file ) }
pb.file.write = function (file, text, callback) { pb.submit( pb.cmd.prepare(callback) + 'file/write/' + file + '/' +  text ) }
pb.file.append = function (file, text, callback) { pb.submit( pb.cmd.prepare(callback) + 'file/append/' + file + '/' +  text ) }
pb.file.delete = function (file, callback) { pb.submit( pb.cmd.prepare(callback) + 'file/delete/' + file ) }
pb.file.select = function (ext, callback) { pb.submit( pb.cmd.prepare(callback) + 'file/select/' + ext ) }

//==== pb session. 
// session(name) -> get value
// session(name,value) -> set value and sync to pb
// session(name,value,'init') -> call from pb, init value (no call back)    
pb.session = function ( name, value, from ) {
   if (arguments.length == 1) {
      return pb.session[name]
   } else if (arguments.length == 2) {
      pb.session[name] = (value.substr(0,1)=='{'? JSON.parse(value) : value )
      window.location='pb://session/'+ name + '/' + value;
   } else {
      pb.session[name] = (value.substr(0,1)=='{'? JSON.parse(value) : value )
   }
}

//disable right-click
document.addEventListener("contextmenu", function(e){ e.preventDefault();}, false);

