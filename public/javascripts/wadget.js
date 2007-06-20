/*
	Copyright (c) 2004-2006, The Dojo Foundation
	All Rights Reserved.

	Licensed under the Academic Free License version 2.1 or above OR the
	modified BSD license. For more information on Dojo licensing, see:

		http://dojotoolkit.org/community/licensing.shtml
*/

/*
	This is a compiled version of Dojo, built for deployment and not for
	development. To get an editable version, please visit:

		http://dojotoolkit.org

	for documentation and information on getting the source.
*/

if(typeof dojo=="undefined"){
var dj_global=this;
var dj_currentContext=this;
function dj_undef(_1,_2){
return (typeof (_2||dj_currentContext)[_1]=="undefined");
}
if(dj_undef("djConfig",this)){
var djConfig={};
}
if(dj_undef("dojo",this)){
var dojo={};
}
dojo.global=function(){
return dj_currentContext;
};
dojo.locale=djConfig.locale;
dojo.version={major:0,minor:0,patch:0,flag:"dev",revision:Number("$Rev: 7460 $".match(/[0-9]+/)[0]),toString:function(){
with(dojo.version){
return major+"."+minor+"."+patch+flag+" ("+revision+")";
}
}};
dojo.getObject=function(_3,_4,_5,_6){
var _7,_8;
if(typeof _3!="string"){
return undefined;
}
_7=_5;
if(!_7){
_7=dojo.global();
}
var _9=_3.split("."),i=0,_b,_c,_d;
do{
_b=_7;
_d=_9[i];
_c=_7[_9[i]];
if((_4)&&(!_c)){
_c=_7[_9[i]]={};
}
_7=_c;
i++;
}while(i<_9.length&&_7);
_8=_7;
_7=_b;
return (_6)?{obj:_7,prop:_d}:_8;
};
dojo.exists=function(_e,_f){
if(typeof _f=="string"){
dojo.deprecated("dojo.exists(obj, name)","use dojo.exists(name, obj, /*optional*/create)","0.6");
var tmp=_e;
_e=_f;
_f=tmp;
}
return (!!dojo.getObject(_e,false,_f));
};
dojo.evalProp=function(_11,_12,_13){
dojo.deprecated("dojo.evalProp","just use hash syntax. Sheesh.","0.6");
return _12[_11]||(_13?(_12[_11]={}):undefined);
};
dojo.parseObjPath=function(_14,_15,_16){
dojo.deprecated("dojo.parseObjPath","use dojo.getObject(path, create, context, true)","0.6");
return dojo.getObject(_14,_16,_15,true);
};
dojo.evalObjPath=function(_17,_18){
dojo.deprecated("dojo.evalObjPath","use dojo.getObject(path, create)","0.6");
return dojo.getObject(_17,_18);
};
dojo.errorToString=function(_19){
return (_19["message"]||_19["description"]||_19);
};
dojo.raise=function(_1a,_1b){
if(_1b){
_1a=_1a+": "+dojo.errorToString(_1b);
}else{
_1a=dojo.errorToString(_1a);
}
try{
if(djConfig.isDebug){
dojo.hostenv.println("FATAL exception raised: "+_1a);
}
}
catch(e){
}
throw _1b||Error(_1a);
};
dojo.debug=function(){
};
dojo.debugShallow=function(obj){
};
dojo.profile={start:function(){
},end:function(){
},stop:function(){
},dump:function(){
}};
function dj_eval(_1d){
return dj_global.eval?dj_global.eval(_1d):eval(_1d);
}
dojo.unimplemented=function(_1e,_1f){
var _20="'"+_1e+"' not implemented";
if(_1f!=null){
_20+=" "+_1f;
}
dojo.raise(_20);
};
dojo.deprecated=function(_21,_22,_23){
var _24="DEPRECATED: "+_21;
if(_22){
_24+=" "+_22;
}
if(_23){
_24+=" -- will be removed in version: "+_23;
}
dojo.debug(_24);
};
dojo.render=(function(){
function vscaffold(_25,_26){
var tmp={capable:false,support:{builtin:false,plugin:false},prefixes:_25};
for(var i=0;i<_26.length;i++){
tmp[_26[i]]=false;
}
return tmp;
}
return {name:"",ver:dojo.version,os:{win:false,linux:false,osx:false},html:vscaffold(["html"],["ie","opera","khtml","safari","moz"]),svg:vscaffold(["svg"],["corel","adobe","batik"]),vml:vscaffold(["vml"],["ie"]),swf:vscaffold(["Swf","Flash","Mm"],["mm"]),swt:vscaffold(["Swt"],["ibm"])};
})();
dojo.hostenv=(function(){
var _29={isDebug:false,allowQueryConfig:false,baseScriptUri:"",baseRelativePath:"",libraryScriptUri:"",iePreventClobber:false,ieClobberMinimal:true,preventBackButtonFix:true,delayMozLoadingFix:false,searchIds:[],parseWidgets:true};
if(typeof djConfig=="undefined"){
djConfig=_29;
}else{
for(var _2a in _29){
if(typeof djConfig[_2a]=="undefined"){
djConfig[_2a]=_29[_2a];
}
}
}
return {name_:"(unset)",version_:"(unset)",getName:function(){
return this.name_;
},getVersion:function(){
return this.version_;
},getText:function(uri){
dojo.unimplemented("getText","uri="+uri);
}};
})();
dojo.hostenv.getBaseScriptUri=function(){
if(djConfig.baseScriptUri.length){
return djConfig.baseScriptUri;
}
var uri=new String(djConfig.libraryScriptUri||djConfig.baseRelativePath);
if(!uri){
dojo.raise("Nothing returned by getLibraryScriptUri(): "+uri);
}
djConfig.baseScriptUri=djConfig.baseRelativePath;
return djConfig.baseScriptUri;
};
(function(){
var _2d={pkgFileName:"__package__",loading_modules_:{},loaded_modules_:{},addedToLoadingCount:[],removedFromLoadingCount:[],inFlightCount:0,modulePrefixes_:{dojo:{name:"dojo",value:"src"}},registerModulePath:function(_2e,_2f){
this.modulePrefixes_[_2e]={name:_2e,value:_2f};
},moduleHasPrefix:function(_30){
var mp=this.modulePrefixes_;
return Boolean(mp[_30]&&mp[_30].value);
},getModulePrefix:function(_32){
if(this.moduleHasPrefix(_32)){
return this.modulePrefixes_[_32].value;
}
return _32;
},getTextStack:[],loadUriStack:[],loadedUris:[],post_load_:false,modulesLoadedListeners:[],unloadListeners:[],loadNotifying:false};
for(var _33 in _2d){
dojo.hostenv[_33]=_2d[_33];
}
})();
dojo.hostenv.loadPath=function(_34,_35,cb){
var uri;
if(_34.charAt(0)=="/"||_34.match(/^\w+:/)){
uri=_34;
}else{
uri=this.getBaseScriptUri()+_34;
}
if(djConfig.cacheBust&&dojo.render.html.capable){
uri+="?"+String(djConfig.cacheBust).replace(/\W+/g,"");
}
try{
return !_35?this.loadUri(uri,cb):this.loadUriAndCheck(uri,_35,cb);
}
catch(e){
dojo.debug(e);
return false;
}
};
dojo.hostenv.loadUri=function(uri,cb){
if(this.loadedUris[uri]){
return true;
}
var _3a=this.getText(uri,null,true);
if(!_3a){
return false;
}
this.loadedUris[uri]=true;
if(cb){
_3a="("+_3a+")";
}
var _3b=dj_eval(_3a);
if(cb){
cb(_3b);
}
return true;
};
dojo.hostenv.loadUriAndCheck=function(uri,_3d,cb){
var ok=true;
try{
ok=this.loadUri(uri,cb);
}
catch(e){
dojo.debug("failed loading ",uri," with error: ",e);
}
return Boolean(ok&&this.findModule(_3d,false));
};
dojo.loaded=function(){
};
dojo.unloaded=function(){
};
dojo.hostenv.loaded=function(){
this.loadNotifying=true;
this.post_load_=true;
var mll=this.modulesLoadedListeners;
for(var x=0;x<mll.length;x++){
mll[x]();
}
this.modulesLoadedListeners=[];
this.loadNotifying=false;
dojo.loaded();
};
dojo.hostenv.unloaded=function(){
var mll=this.unloadListeners;
while(mll.length){
(mll.pop())();
}
dojo.unloaded();
};
dojo.addOnLoad=function(obj,_44){
var dh=dojo.hostenv;
if(arguments.length==1){
dh.modulesLoadedListeners.push(obj);
}else{
if(arguments.length>1){
dh.modulesLoadedListeners.push(function(){
obj[_44]();
});
}
}
if(dh.post_load_&&dh.inFlightCount==0&&!dh.loadNotifying){
dh.callLoaded();
}
};
dojo.addOnUnload=function(obj,_47){
var dh=dojo.hostenv;
if(arguments.length==1){
dh.unloadListeners.push(obj);
}else{
if(arguments.length>1){
dh.unloadListeners.push(function(){
obj[_47]();
});
}
}
};
dojo.hostenv.modulesLoaded=function(){
if(this.post_load_){
return;
}
if(this.loadUriStack.length==0&&this.getTextStack.length==0){
if(this.inFlightCount>0){
dojo.debug("files still in flight!");
return;
}
dojo.hostenv.callLoaded();
}
};
dojo.hostenv.callLoaded=function(){
if(typeof setTimeout=="object"||(djConfig["useXDomain"]&&dojo.render.html.opera)){
setTimeout("dojo.hostenv.loaded();",0);
}else{
dojo.hostenv.loaded();
}
};
dojo.hostenv.getModuleSymbols=function(_49){
var _4a=_49.split(".");
for(var i=_4a.length;i>0;i--){
var _4c=_4a.slice(0,i).join(".");
if((i==1)&&!this.moduleHasPrefix(_4c)){
_4a[0]="../"+_4a[0];
}else{
var _4d=this.getModulePrefix(_4c);
if(_4d!=_4c){
_4a.splice(0,i,_4d);
break;
}
}
}
return _4a;
};
dojo.hostenv._global_omit_module_check=false;
dojo.hostenv.loadModule=function(_4e,_4f,_50){
if(!_4e){
return;
}
_50=this._global_omit_module_check||_50;
var _51=this.findModule(_4e,false);
if(_51){
return _51;
}
if(dj_undef(_4e,this.loading_modules_)){
this.addedToLoadingCount.push(_4e);
}
this.loading_modules_[_4e]=1;
var _52=_4e.replace(/\./g,"/")+".js";
var _53=_4e.split(".");
var _54=this.getModuleSymbols(_4e);
var _55=((_54[0].charAt(0)!="/")&&!_54[0].match(/^\w+:/));
var _56=_54[_54.length-1];
var ok;
if(_56=="*"){
_4e=_53.slice(0,-1).join(".");
while(_54.length){
_54.pop();
_54.push(this.pkgFileName);
_52=_54.join("/")+".js";
if(_55&&_52.charAt(0)=="/"){
_52=_52.slice(1);
}
ok=this.loadPath(_52,!_50?_4e:null);
if(ok){
break;
}
_54.pop();
}
}else{
_52=_54.join("/")+".js";
_4e=_53.join(".");
var _58=!_50?_4e:null;
ok=this.loadPath(_52,_58);
if(!ok&&!_4f){
_54.pop();
while(_54.length){
_52=_54.join("/")+".js";
ok=this.loadPath(_52,_58);
if(ok){
break;
}
_54.pop();
_52=_54.join("/")+"/"+this.pkgFileName+".js";
if(_55&&_52.charAt(0)=="/"){
_52=_52.slice(1);
}
ok=this.loadPath(_52,_58);
if(ok){
break;
}
}
}
if(!ok&&!_50){
dojo.raise("Could not load '"+_4e+"'; last tried '"+_52+"'");
}
}
if(!_50&&!this["isXDomain"]){
_51=this.findModule(_4e,false);
if(!_51){
dojo.raise("symbol '"+_4e+"' is not defined after loading '"+_52+"'");
}
}
return _51;
};
dojo.hostenv.startPackage=function(_59){
var _5a=String(_59);
var _5b=_5a;
var _5c=_59.split(/\./);
if(_5c[_5c.length-1]=="*"){
_5c.pop();
_5b=_5c.join(".");
}
var _5d=dojo.getObject(_5b,true);
this.loaded_modules_[_5a]=_5d;
this.loaded_modules_[_5b]=_5d;
return _5d;
};
dojo.hostenv.findModule=function(_5e,_5f){
var lmn=String(_5e);
if(this.loaded_modules_[lmn]){
return this.loaded_modules_[lmn];
}
if(_5f){
dojo.raise("no loaded module named '"+_5e+"'");
}
return null;
};
dojo.kwCompoundRequire=function(_61){
var _62=_61["common"]||[];
var _63=_62.concat(_61[dojo.hostenv.name_]||_61["default"]||[]);
for(var x=0;x<_63.length;x++){
var _65=_63[x];
if(_65.constructor==Array){
dojo.hostenv.loadModule.apply(dojo.hostenv,_65);
}else{
dojo.hostenv.loadModule(_65);
}
}
};
dojo.require=function(_66){
dojo.hostenv.loadModule.apply(dojo.hostenv,arguments);
};
dojo.requireIf=function(_67,_68){
var _69=arguments[0];
if((_69===true)||(_69=="common")||(_69&&dojo.render[_69].capable)){
var _6a=[];
for(var i=1;i<arguments.length;i++){
_6a.push(arguments[i]);
}
dojo.require.apply(dojo,_6a);
}
};
dojo.requireAfterIf=dojo.requireIf;
dojo.provide=function(_6c){
return dojo.hostenv.startPackage.apply(dojo.hostenv,arguments);
};
dojo.registerModulePath=function(_6d,_6e){
return dojo.hostenv.registerModulePath(_6d,_6e);
};
if(djConfig["modulePaths"]){
for(var param in djConfig["modulePaths"]){
dojo.registerModulePath(param,djConfig["modulePaths"][param]);
}
}
dojo.requireLocalization=function(_6f,_70,_71,_72){
dojo.require("dojo.i18n.loader");
dojo.i18n._requireLocalization.apply(dojo.hostenv,arguments);
};
}
if(typeof window!="undefined"){
(function(){
if(djConfig.allowQueryConfig){
var _73=document.location.toString();
var _74=_73.split("?",2);
if(_74.length>1){
var _75=_74[1];
var _76=_75.split("&");
for(var x in _76){
var sp=_76[x].split("=");
if((sp[0].length>9)&&(sp[0].substr(0,9)=="djConfig.")){
var opt=sp[0].substr(9);
try{
djConfig[opt]=eval(sp[1]);
}
catch(e){
djConfig[opt]=sp[1];
}
}
}
}
}
if(((djConfig["baseScriptUri"]=="")||(djConfig["baseRelativePath"]==""))&&(document&&document.getElementsByTagName)){
var _7a=document.getElementsByTagName("script");
var _7b=/(__package__|dojo|bootstrap1)\.js([\?\.]|$)/i;
for(var i=0;i<_7a.length;i++){
var src=_7a[i].getAttribute("src");
if(!src){
continue;
}
var m=src.match(_7b);
if(m){
var _7f=src.substring(0,m.index);
if(src.indexOf("bootstrap1")>-1){
_7f+="../";
}
if(!this["djConfig"]){
djConfig={};
}
if(djConfig["baseScriptUri"]==""){
djConfig["baseScriptUri"]=_7f;
}
if(djConfig["baseRelativePath"]==""){
djConfig["baseRelativePath"]=_7f;
}
break;
}
}
}
var dr=dojo.render;
var drh=dojo.render.html;
var drs=dojo.render.svg;
var dua=(drh.UA=navigator.userAgent);
var dav=(drh.AV=navigator.appVersion);
var t=true;
var f=false;
drh.capable=t;
drh.support.builtin=t;
dr.ver=parseFloat(drh.AV);
dr.os.mac=dav.indexOf("Macintosh")>=0;
dr.os.win=dav.indexOf("Windows")>=0;
dr.os.linux=dav.indexOf("X11")>=0;
drh.opera=dua.indexOf("Opera")>=0;
drh.khtml=(dav.indexOf("Konqueror")>=0)||(dav.indexOf("Safari")>=0);
drh.safari=dav.indexOf("Safari")>=0;
var _87=dua.indexOf("Gecko");
drh.mozilla=drh.moz=(_87>=0)&&(!drh.khtml);
if(drh.mozilla){
drh.geckoVersion=dua.substring(_87+6,_87+14);
}
drh.ie=(document.all)&&(!drh.opera);
drh.ie50=drh.ie&&dav.indexOf("MSIE 5.0")>=0;
drh.ie55=drh.ie&&dav.indexOf("MSIE 5.5")>=0;
drh.ie60=drh.ie&&dav.indexOf("MSIE 6.0")>=0;
drh.ie70=drh.ie&&dav.indexOf("MSIE 7.0")>=0;
var cm=document["compatMode"];
drh.quirks=(cm=="BackCompat")||(cm=="QuirksMode")||drh.ie55||drh.ie50;
dojo.locale=dojo.locale||(drh.ie?navigator.userLanguage:navigator.language).toLowerCase();
dr.vml.capable=drh.ie;
drs.capable=f;
drs.support.plugin=f;
drs.support.builtin=f;
var _89=window["document"];
var tdi=_89["implementation"];
if((tdi)&&(tdi["hasFeature"])&&(tdi.hasFeature("org.w3c.dom.svg","1.0"))){
drs.capable=t;
drs.support.builtin=t;
drs.support.plugin=f;
}
if(drh.safari){
var tmp=dua.split("AppleWebKit/")[1];
var ver=parseFloat(tmp.split(" ")[0]);
if(ver>=420){
drs.capable=t;
drs.support.builtin=t;
drs.support.plugin=f;
}
}else{
}
})();
dojo.hostenv.startPackage("dojo.hostenv");
dojo.render.name=dojo.hostenv.name_="browser";
dojo.hostenv.searchIds=[];
dojo.hostenv._XMLHTTP_PROGIDS=["Msxml2.XMLHTTP","Microsoft.XMLHTTP","Msxml2.XMLHTTP.4.0"];
dojo.hostenv.getXmlhttpObject=function(){
var _8d=null;
var _8e=null;
try{
_8d=new XMLHttpRequest();
}
catch(e){
}
if(!_8d){
for(var i=0;i<3;++i){
var _90=dojo.hostenv._XMLHTTP_PROGIDS[i];
try{
_8d=new ActiveXObject(_90);
}
catch(e){
_8e=e;
}
if(_8d){
dojo.hostenv._XMLHTTP_PROGIDS=[_90];
break;
}
}
}
if(!_8d){
return dojo.raise("XMLHTTP not available",_8e);
}
return _8d;
};
dojo.hostenv._blockAsync=false;
dojo.hostenv.getText=function(uri,_92,_93){
if(!_92){
this._blockAsync=true;
}
var _94=this.getXmlhttpObject();
function isDocumentOk(_95){
var _96=_95["status"];
return Boolean((!_96)||((200<=_96)&&(300>_96))||(_96==304));
}
if(_92){
var _97=this,_98=null,gbl=dojo.global();
var xhr=dojo.getObject("dojo.io.XMLHTTPTransport");
_94.onreadystatechange=function(){
if(_98){
gbl.clearTimeout(_98);
_98=null;
}
if(_97._blockAsync||(xhr&&xhr._blockAsync)){
_98=gbl.setTimeout(function(){
_94.onreadystatechange.apply(this);
},10);
}else{
if(4==_94.readyState){
if(isDocumentOk(_94)){
_92(_94.responseText);
}
}
}
};
}
_94.open("GET",uri,_92?true:false);
try{
_94.send(null);
if(_92){
return null;
}
if(!isDocumentOk(_94)){
var err=Error("Unable to load "+uri+" status:"+_94.status);
err.status=_94.status;
err.responseText=_94.responseText;
throw err;
}
}
catch(e){
this._blockAsync=false;
if((_93)&&(!_92)){
return null;
}else{
throw e;
}
}
this._blockAsync=false;
return _94.responseText;
};
dojo.hostenv.defaultDebugContainerId="dojoDebug";
dojo.hostenv._println_buffer=[];
dojo.hostenv._println_safe=false;
dojo.hostenv.println=function(_9c){
if(!dojo.hostenv._println_safe){
dojo.hostenv._println_buffer.push(_9c);
}else{
try{
var _9d=document.getElementById(djConfig.debugContainerId?djConfig.debugContainerId:dojo.hostenv.defaultDebugContainerId);
if(!_9d){
_9d=dojo.body();
}
var div=document.createElement("div");
div.appendChild(document.createTextNode(_9c));
_9d.appendChild(div);
}
catch(e){
try{
document.write("<div>"+_9c+"</div>");
}
catch(e2){
window.status=_9c;
}
}
}
};
dojo.addOnLoad(function(){
dojo.hostenv._println_safe=true;
while(dojo.hostenv._println_buffer.length>0){
dojo.hostenv.println(dojo.hostenv._println_buffer.shift());
}
});
function dj_addNodeEvtHdlr(_9f,_a0,fp){
var _a2=_9f["on"+_a0]||function(){
};
_9f["on"+_a0]=function(){
fp.apply(_9f,arguments);
_a2.apply(_9f,arguments);
};
return true;
}
dojo.hostenv._djInitFired=false;
function dj_load_init(e){
dojo.hostenv._djInitFired=true;
var _a4=(e&&e.type)?e.type.toLowerCase():"load";
if(arguments.callee.initialized||(_a4!="domcontentloaded"&&_a4!="load")){
return;
}
arguments.callee.initialized=true;
if(typeof (_timer)!="undefined"){
clearInterval(_timer);
delete _timer;
}
var _a5=function(){
if(dojo.render.html.ie){
dojo.hostenv.makeWidgets();
}
};
if(dojo.hostenv.inFlightCount==0){
_a5();
dojo.hostenv.modulesLoaded();
}else{
dojo.hostenv.modulesLoadedListeners.unshift(_a5);
}
}
if(document.addEventListener){
if(dojo.render.html.opera||(dojo.render.html.moz&&(djConfig["enableMozDomContentLoaded"]===true))){
document.addEventListener("DOMContentLoaded",dj_load_init,null);
}
window.addEventListener("load",dj_load_init,null);
}
if(dojo.render.html.ie&&dojo.render.os.win){
document.write("<scr"+"ipt defer src=\"//:\" "+"onreadystatechange=\"if(this.readyState=='complete'){dj_load_init();}\">"+"</scr"+"ipt>");
}
if(/(WebKit|khtml)/i.test(navigator.userAgent)){
var _timer=setInterval(function(){
if(/loaded|complete/.test(document.readyState)){
dj_load_init();
}
},10);
}
if(dojo.render.html.ie){
dj_addNodeEvtHdlr(window,"beforeunload",function(){
dojo.hostenv._unloading=true;
window.setTimeout(function(){
dojo.hostenv._unloading=false;
},0);
});
}
dj_addNodeEvtHdlr(window,"unload",function(){
if((!dojo.render.html.ie)||(dojo.render.html.ie&&dojo.hostenv._unloading)){
dojo.hostenv.unloaded();
}
});
dojo.hostenv.makeWidgets=function(){
var _a6=[];
if(djConfig.searchIds&&djConfig.searchIds.length>0){
_a6=_a6.concat(djConfig.searchIds);
}
if(dojo.hostenv.searchIds&&dojo.hostenv.searchIds.length>0){
_a6=_a6.concat(dojo.hostenv.searchIds);
}
if((djConfig.parseWidgets)||(_a6.length>0)){
if(dojo.getObject("dojo.widget.Parse")){
var _a7=new dojo.xml.Parse();
if(_a6.length>0){
for(var x=0;x<_a6.length;x++){
var _a9=document.getElementById(_a6[x]);
if(!_a9){
continue;
}
var _aa=_a7.parseElement(_a9,null,true);
dojo.widget.getParser().createComponents(_aa);
}
}else{
if(djConfig.parseWidgets){
var _aa=_a7.parseElement(dojo.body(),null,true);
dojo.widget.getParser().createComponents(_aa);
}
}
}
}
};
dojo.addOnLoad(function(){
if(!dojo.render.html.ie){
dojo.hostenv.makeWidgets();
}
});
try{
if(dojo.render.html.ie){
document.namespaces.add("v","urn:schemas-microsoft-com:vml");
document.createStyleSheet().addRule("v\\:*","behavior:url(#default#VML)");
}
}
catch(e){
}
dojo.hostenv.writeIncludes=function(){
};
if(!dj_undef("document",this)){
dj_currentDocument=this.document;
}
dojo.doc=function(){
return dj_currentDocument;
};
dojo.body=function(){
return dojo.doc().body||dojo.doc().getElementsByTagName("body")[0];
};
dojo.byId=function(id,doc){
if((id)&&((typeof id=="string")||(id instanceof String))){
if(!doc){
doc=dj_currentDocument;
}
var ele=doc.getElementById(id);
if(ele&&(ele.id!=id)&&doc.all){
ele=null;
eles=doc.all[id];
if(eles){
if(eles.length){
for(var i=0;i<eles.length;i++){
if(eles[i].id==id){
ele=eles[i];
break;
}
}
}else{
ele=eles;
}
}
}
return ele;
}
return id;
};
dojo.setContext=function(_af,_b0){
dj_currentContext=_af;
dj_currentDocument=_b0;
};
dojo._fireCallback=function(_b1,_b2,_b3){
if((_b2)&&((typeof _b1=="string")||(_b1 instanceof String))){
_b1=_b2[_b1];
}
return (_b2?_b1.apply(_b2,_b3||[]):_b1());
};
dojo.withGlobal=function(_b4,_b5,_b6,_b7){
var _b8;
var _b9=dj_currentContext;
var _ba=dj_currentDocument;
try{
dojo.setContext(_b4,_b4.document);
_b8=dojo._fireCallback(_b5,_b6,_b7);
}
finally{
dojo.setContext(_b9,_ba);
}
return _b8;
};
dojo.withDoc=function(_bb,_bc,_bd,_be){
var _bf;
var _c0=dj_currentDocument;
try{
dj_currentDocument=_bb;
_bf=dojo._fireCallback(_bc,_bd,_be);
}
finally{
dj_currentDocument=_c0;
}
return _bf;
};
}
dojo.requireIf((djConfig["isDebug"]||djConfig["debugAtAllCosts"]),"dojo.debug");
dojo.requireIf(djConfig["debugAtAllCosts"]&&!window.widget&&!djConfig["useXDomain"],"dojo.browser_debug");
dojo.requireIf(djConfig["debugAtAllCosts"]&&!window.widget&&djConfig["useXDomain"],"dojo.browser_debug_xd");
dojo.provide("dojo.string.common");
dojo.string.trim=function(str,wh){
if(!str.replace){
return str;
}
if(!str.length){
return str;
}
var re=(wh>0)?(/^\s+/):(wh<0)?(/\s+$/):(/^\s+|\s+$/g);
return str.replace(re,"");
};
dojo.string.trimStart=function(str){
return dojo.string.trim(str,1);
};
dojo.string.trimEnd=function(str){
return dojo.string.trim(str,-1);
};
dojo.string.repeat=function(str,_c7,_c8){
var out="";
for(var i=0;i<_c7;i++){
out+=str;
if(_c8&&i<_c7-1){
out+=_c8;
}
}
return out;
};
dojo.string.pad=function(str,len,c,dir){
var out=String(str);
if(!c){
c="0";
}
if(!dir){
dir=1;
}
while(out.length<len){
if(dir>0){
out=c+out;
}else{
out+=c;
}
}
return out;
};
dojo.string.padLeft=function(str,len,c){
return dojo.string.pad(str,len,c,1);
};
dojo.string.padRight=function(str,len,c){
return dojo.string.pad(str,len,c,-1);
};
dojo.provide("dojo.string");
dojo.provide("dojo.lang.common");
dojo.lang.inherits=function(_d6,_d7){
if(!dojo.lang.isFunction(_d7)){
dojo.raise("dojo.inherits: superclass argument ["+_d7+"] must be a function (subclass: ["+_d6+"']");
}
_d6.prototype=new _d7();
_d6.prototype.constructor=_d6;
_d6.superclass=_d7.prototype;
_d6["super"]=_d7.prototype;
};
dojo.lang._mixin=function(obj,_d9){
var _da={};
for(var x in _d9){
if((typeof _da[x]=="undefined")||(_da[x]!=_d9[x])){
obj[x]=_d9[x];
}
}
if(dojo.render.html.ie&&(typeof (_d9["toString"])=="function")&&(_d9["toString"]!=obj["toString"])&&(_d9["toString"]!=_da["toString"])){
obj.toString=_d9.toString;
}
return obj;
};
dojo.lang.mixin=function(obj,_dd){
for(var i=1,l=arguments.length;i<l;i++){
dojo.lang._mixin(obj,arguments[i]);
}
return obj;
};
dojo.lang.extend=function(_e0,_e1){
for(var i=1,l=arguments.length;i<l;i++){
dojo.lang._mixin(_e0.prototype,arguments[i]);
}
return _e0;
};
dojo.lang._delegate=function(obj,_e5){
function TMP(){
}
TMP.prototype=obj;
var tmp=new TMP();
if(_e5){
dojo.lang.mixin(tmp,_e5);
}
return tmp;
};
dojo.inherits=dojo.lang.inherits;
dojo.mixin=dojo.lang.mixin;
dojo.extend=dojo.lang.extend;
dojo.lang.find=function(_e7,_e8,_e9,_ea){
var _eb=dojo.lang.isString(_e7);
if(_eb){
_e7=_e7.split("");
}
if(_ea){
var _ec=-1;
var i=_e7.length-1;
var end=-1;
}else{
var _ec=1;
var i=0;
var end=_e7.length;
}
if(_e9){
while(i!=end){
if(_e7[i]===_e8){
return i;
}
i+=_ec;
}
}else{
while(i!=end){
if(_e7[i]==_e8){
return i;
}
i+=_ec;
}
}
return -1;
};
dojo.lang.indexOf=dojo.lang.find;
dojo.lang.findLast=function(_ef,_f0,_f1){
return dojo.lang.find(_ef,_f0,_f1,true);
};
dojo.lang.lastIndexOf=dojo.lang.findLast;
dojo.lang.inArray=function(_f2,_f3){
return dojo.lang.find(_f2,_f3)>-1;
};
dojo.lang.isObject=function(it){
if(typeof it=="undefined"){
return false;
}
return (typeof it=="object"||it===null||dojo.lang.isArray(it)||dojo.lang.isFunction(it));
};
dojo.lang.isArray=function(it){
return (it&&it instanceof Array||typeof it=="array");
};
dojo.lang.isArrayLike=function(it){
if((!it)||(dojo.lang.isUndefined(it))){
return false;
}
if(dojo.lang.isString(it)){
return false;
}
if(dojo.lang.isFunction(it)){
return false;
}
if(dojo.lang.isArray(it)){
return true;
}
if((it.tagName)&&(it.tagName.toLowerCase()=="form")){
return false;
}
if(dojo.lang.isNumber(it.length)&&isFinite(it.length)){
return true;
}
return false;
};
dojo.lang.isFunction=function(it){
return (it instanceof Function||typeof it=="function");
};
(function(){
if((dojo.render.html.capable)&&(dojo.render.html["safari"])){
dojo.lang.isFunction=function(it){
if((typeof (it)=="function")&&(it=="[object NodeList]")){
return false;
}
return (it instanceof Function||typeof it=="function");
};
}
})();
dojo.lang.isString=function(it){
return (typeof it=="string"||it instanceof String);
};
dojo.lang.isAlien=function(it){
if(!it){
return false;
}
return !dojo.lang.isFunction(it)&&/\{\s*\[native code\]\s*\}/.test(String(it));
};
dojo.lang.isBoolean=function(it){
return (it instanceof Boolean||typeof it=="boolean");
};
dojo.lang.isNumber=function(it){
return (it instanceof Number||typeof it=="number");
};
dojo.lang.isUndefined=function(it){
return ((typeof (it)=="undefined")&&(it==undefined));
};
dojo.provide("dojo.lang.extras");
dojo.lang.setTimeout=function(_fe,_ff){
var _100=window,_101=2;
if(!dojo.lang.isFunction(_fe)){
_100=_fe;
_fe=_ff;
_ff=arguments[2];
_101++;
}
if(dojo.lang.isString(_fe)){
_fe=_100[_fe];
}
var args=[];
for(var i=_101;i<arguments.length;i++){
args.push(arguments[i]);
}
return dojo.global().setTimeout(function(){
_fe.apply(_100,args);
},_ff);
};
dojo.lang.clearTimeout=function(_104){
dojo.global().clearTimeout(_104);
};
dojo.lang.getNameInObj=function(ns,item){
if(!ns){
ns=dj_global;
}
for(var x in ns){
if(ns[x]===item){
return new String(x);
}
}
return null;
};
dojo.lang.shallowCopy=function(obj,deep){
var i,ret;
if(obj===null){
return null;
}
if(dojo.lang.isObject(obj)){
ret=new obj.constructor();
for(i in obj){
if(dojo.lang.isUndefined(ret[i])){
ret[i]=deep?dojo.lang.shallowCopy(obj[i],deep):obj[i];
}
}
}else{
if(dojo.lang.isArray(obj)){
ret=[];
for(i=0;i<obj.length;i++){
ret[i]=deep?dojo.lang.shallowCopy(obj[i],deep):obj[i];
}
}else{
ret=obj;
}
}
return ret;
};
dojo.lang.firstValued=function(){
for(var i=0;i<arguments.length;i++){
if(typeof arguments[i]!="undefined"){
return arguments[i];
}
}
return undefined;
};
dojo.lang.getObjPathValue=function(_10d,_10e,_10f){
dojo.deprecated("dojo.lang.getObjPathValue","use dojo.getObject","0.6");
with(dojo.parseObjPath(_10d,_10e,_10f)){
return dojo.evalProp(prop,obj,_10f);
}
};
dojo.lang.setObjPathValue=function(_110,_111,_112,_113){
dojo.deprecated("dojo.lang.setObjPathValue","use dojo.parseObjPath and the '=' operator","0.6");
if(arguments.length<4){
_113=true;
}
with(dojo.parseObjPath(_110,_112,_113)){
if(obj&&(_113||(prop in obj))){
obj[prop]=_111;
}
}
};
dojo.provide("dojo.io.common");
dojo.io.transports=[];
dojo.io.hdlrFuncNames=["load","error","timeout"];
dojo.io.Request=function(url,_115,_116,_117){
if((arguments.length==1)&&(arguments[0].constructor==Object)){
this.fromKwArgs(arguments[0]);
}else{
this.url=url;
if(_115){
this.mimetype=_115;
}
if(_116){
this.transport=_116;
}
if(arguments.length>=4){
this.changeUrl=_117;
}
}
};
dojo.lang.extend(dojo.io.Request,{url:"",mimetype:"text/plain",method:"GET",content:undefined,transport:undefined,changeUrl:undefined,formNode:undefined,sync:false,bindSuccess:false,useCache:false,preventCache:false,jsonFilter:function(_118){
if((this.mimetype=="text/json-comment-filtered")||(this.mimetype=="application/json-comment-filtered")){
var _119=_118.indexOf("/*");
var _11a=_118.lastIndexOf("*/");
if((_119==-1)||(_11a==-1)){
dojo.debug("your JSON wasn't comment filtered!");
return "";
}
return _118.substring(_119+2,_11a);
}
dojo.debug("please consider using a mimetype of text/json-comment-filtered to avoid potential security issues with JSON endpoints");
return _118;
},load:function(type,data,_11d,_11e){
},error:function(type,_120,_121,_122){
},timeout:function(type,_124,_125,_126){
},handle:function(type,data,_129,_12a){
},timeoutSeconds:0,abort:function(){
},fromKwArgs:function(_12b){
if(_12b["url"]){
_12b.url=_12b.url.toString();
}
if(_12b["formNode"]){
_12b.formNode=dojo.byId(_12b.formNode);
}
if(!_12b["method"]&&_12b["formNode"]&&_12b["formNode"].method){
_12b.method=_12b["formNode"].method;
}
if(!_12b["handle"]&&_12b["handler"]){
_12b.handle=_12b.handler;
}
if(!_12b["load"]&&_12b["loaded"]){
_12b.load=_12b.loaded;
}
if(!_12b["changeUrl"]&&_12b["changeURL"]){
_12b.changeUrl=_12b.changeURL;
}
_12b.encoding=dojo.lang.firstValued(_12b["encoding"],djConfig["bindEncoding"],"");
_12b.sendTransport=dojo.lang.firstValued(_12b["sendTransport"],djConfig["ioSendTransport"],false);
var _12c=dojo.lang.isFunction;
for(var x=0;x<dojo.io.hdlrFuncNames.length;x++){
var fn=dojo.io.hdlrFuncNames[x];
if(_12b[fn]&&_12c(_12b[fn])){
continue;
}
if(_12b["handle"]&&_12c(_12b["handle"])){
_12b[fn]=_12b.handle;
}
}
dojo.lang.mixin(this,_12b);
}});
dojo.io.Error=function(msg,type,num){
this.message=msg;
this.type=type||"unknown";
this.number=num||0;
};
dojo.io.transports.addTransport=function(name){
this.push(name);
this[name]=dojo.io[name];
};
dojo.io.bind=function(_133){
if(!(_133 instanceof dojo.io.Request)){
try{
_133=new dojo.io.Request(_133);
}
catch(e){
dojo.debug(e);
}
}
var _134="";
if(_133["transport"]){
_134=_133["transport"];
if(!this[_134]){
dojo.io.sendBindError(_133,"No dojo.io.bind() transport with name '"+_133["transport"]+"'.");
return _133;
}
if(!this[_134].canHandle(_133)){
dojo.io.sendBindError(_133,"dojo.io.bind() transport with name '"+_133["transport"]+"' cannot handle this type of request.");
return _133;
}
}else{
for(var x=0;x<dojo.io.transports.length;x++){
var tmp=dojo.io.transports[x];
if((this[tmp])&&(this[tmp].canHandle(_133))){
_134=tmp;
break;
}
}
if(_134==""){
dojo.io.sendBindError(_133,"None of the loaded transports for dojo.io.bind()"+" can handle the request.");
return _133;
}
}
this[_134].bind(_133);
_133.bindSuccess=true;
return _133;
};
dojo.io.sendBindError=function(_137,_138){
if((typeof _137.error=="function"||typeof _137.handle=="function")&&(typeof setTimeout=="function"||typeof setTimeout=="object")){
var _139=new dojo.io.Error(_138);
setTimeout(function(){
_137[(typeof _137.error=="function")?"error":"handle"]("error",_139,null,_137);
},50);
}else{
dojo.raise(_138);
}
};
dojo.io.queueBind=function(_13a){
if(!(_13a instanceof dojo.io.Request)){
try{
_13a=new dojo.io.Request(_13a);
}
catch(e){
dojo.debug(e);
}
}
var _13b=_13a.load;
_13a.load=function(){
dojo.io._queueBindInFlight=false;
var ret=_13b.apply(this,arguments);
dojo.io._dispatchNextQueueBind();
return ret;
};
var _13d=_13a.error;
_13a.error=function(){
dojo.io._queueBindInFlight=false;
var ret=_13d.apply(this,arguments);
dojo.io._dispatchNextQueueBind();
return ret;
};
dojo.io._bindQueue.push(_13a);
dojo.io._dispatchNextQueueBind();
return _13a;
};
dojo.io._dispatchNextQueueBind=function(){
if(!dojo.io._queueBindInFlight){
dojo.io._queueBindInFlight=true;
if(dojo.io._bindQueue.length>0){
dojo.io.bind(dojo.io._bindQueue.shift());
}else{
dojo.io._queueBindInFlight=false;
}
}
};
dojo.io._bindQueue=[];
dojo.io._queueBindInFlight=false;
dojo.io.argsFromMap=function(map,_140,last){
var enc=/utf/i.test(_140||"")?encodeURIComponent:dojo.string.encodeAscii;
var _143=[];
var _144=new Object();
for(var name in map){
var _146=function(elt){
var val=enc(name)+"="+enc(elt);
_143[(last==name)?"push":"unshift"](val);
};
if(!_144[name]){
var _149=map[name];
if(dojo.lang.isArray(_149)){
dojo.lang.forEach(_149,_146);
}else{
_146(_149);
}
}
}
return _143.join("&");
};
dojo.io.setIFrameSrc=function(_14a,src,_14c){
try{
var r=dojo.render.html;
if(!_14c){
if(r.safari){
_14a.location=src;
}else{
frames[_14a.name].location=src;
}
}else{
var idoc;
if(r.ie){
idoc=_14a.contentWindow.document;
}else{
if(r.safari){
idoc=_14a.document;
}else{
idoc=_14a.contentWindow;
}
}
if(!idoc){
_14a.location=src;
return;
}else{
idoc.location.replace(src);
}
}
}
catch(e){
dojo.debug(e);
dojo.debug("setIFrameSrc: "+e);
}
};
dojo.provide("dojo.lang.array");
dojo.lang.mixin(dojo.lang,{has:function(obj,name){
try{
return typeof obj[name]!="undefined";
}
catch(e){
return false;
}
},isEmpty:function(obj){
if(dojo.lang.isArrayLike(obj)||dojo.lang.isString(obj)){
return obj.length===0;
}else{
if(dojo.lang.isObject(obj)){
var tmp={};
for(var x in obj){
if(obj[x]&&(!tmp[x])){
return false;
}
}
return true;
}
}
},map:function(arr,obj,_156){
var _157=dojo.lang.isString(arr);
if(_157){
arr=arr.split("");
}
if(dojo.lang.isFunction(obj)&&(!_156)){
_156=obj;
obj=dj_global;
}else{
if(dojo.lang.isFunction(obj)&&_156){
var _158=obj;
obj=_156;
_156=_158;
}
}
if(Array.map){
var _159=Array.map(arr,_156,obj);
}else{
var _159=[];
for(var i=0;i<arr.length;++i){
_159.push(_156.call(obj,arr[i]));
}
}
if(_157){
return _159.join("");
}else{
return _159;
}
},reduce:function(arr,_15c,_15d,_15e){
var _15f=_15d;
if(arguments.length==2){
_15f=arr[0];
arr=arr.slice(1);
}
var ob=_15e||dj_global;
dojo.lang.map(arr,function(val){
_15f=_15c.call(ob,_15f,val);
});
return _15f;
},forEach:function(_162,_163,_164){
if(dojo.lang.isString(_162)){
_162=_162.split("");
}
if(Array.forEach){
Array.forEach(_162,_163,_164);
}else{
if(!_164){
_164=dj_global;
}
for(var i=0,l=_162.length;i<l;i++){
_163.call(_164,_162[i],i,_162);
}
}
},_everyOrSome:function(_167,arr,_169,_16a){
if(dojo.lang.isString(arr)){
arr=arr.split("");
}
if(Array.every){
return Array[_167?"every":"some"](arr,_169,_16a);
}else{
if(!_16a){
_16a=dj_global;
}
for(var i=0,l=arr.length;i<l;i++){
var _16d=_169.call(_16a,arr[i],i,arr);
if(_167&&!_16d){
return false;
}else{
if((!_167)&&(_16d)){
return true;
}
}
}
return Boolean(_167);
}
},every:function(arr,_16f,_170){
return this._everyOrSome(true,arr,_16f,_170);
},some:function(arr,_172,_173){
return this._everyOrSome(false,arr,_172,_173);
},filter:function(arr,_175,_176){
var _177=dojo.lang.isString(arr);
if(_177){
arr=arr.split("");
}
var _178;
if(Array.filter){
_178=Array.filter(arr,_175,_176);
}else{
if(!_176){
if(arguments.length>=3){
dojo.raise("thisObject doesn't exist!");
}
_176=dj_global;
}
_178=[];
for(var i=0;i<arr.length;i++){
if(_175.call(_176,arr[i],i,arr)){
_178.push(arr[i]);
}
}
}
if(_177){
return _178.join("");
}else{
return _178;
}
},unnest:function(){
var out=[];
for(var i=0;i<arguments.length;i++){
if(dojo.lang.isArrayLike(arguments[i])){
var add=dojo.lang.unnest.apply(this,arguments[i]);
out=out.concat(add);
}else{
out.push(arguments[i]);
}
}
return out;
},toArray:function(_17d,_17e){
var _17f=[];
for(var i=_17e||0;i<_17d.length;i++){
_17f.push(_17d[i]);
}
return _17f;
}});
dojo.provide("dojo.lang.func");
dojo.lang.hitch=function(_181,_182){
var args=[];
for(var x=2;x<arguments.length;x++){
args.push(arguments[x]);
}
var fcn=(dojo.lang.isString(_182)?_181[_182]:_182)||function(){
};
return function(){
var ta=args.concat([]);
for(var x=0;x<arguments.length;x++){
ta.push(arguments[x]);
}
return fcn.apply(_181,ta);
};
};
dojo.lang.anonCtr=0;
dojo.lang.anon={};
dojo.lang.nameAnonFunc=function(_188,_189,_18a){
var isIE=(dojo.render.html.capable&&dojo.render.html["ie"]);
var jpn="$joinpoint";
var nso=(_189||dojo.lang.anon);
if(isIE){
var cn=_188["__dojoNameCache"];
if(cn&&nso[cn]===_188){
return _188["__dojoNameCache"];
}else{
if(cn){
var _18f=cn.indexOf(jpn);
if(_18f!=-1){
return cn.substring(0,_18f);
}
}
}
}
if((_18a)||((dj_global["djConfig"])&&(djConfig["slowAnonFuncLookups"]==true))){
for(var x in nso){
try{
if(nso[x]===_188){
if(isIE){
_188["__dojoNameCache"]=x;
var _18f=x.indexOf(jpn);
if(_18f!=-1){
x=x.substring(0,_18f);
}
}
return x;
}
}
catch(e){
}
}
}
var ret="__"+dojo.lang.anonCtr++;
while(typeof nso[ret]!="undefined"){
ret="__"+dojo.lang.anonCtr++;
}
nso[ret]=_188;
return ret;
};
dojo.lang.forward=function(_192){
return function(){
return this[_192].apply(this,arguments);
};
};
dojo.lang.curry=function(_193,func){
var _195=[];
_193=_193||dj_global;
if(dojo.lang.isString(func)){
func=_193[func];
}
for(var x=2;x<arguments.length;x++){
_195.push(arguments[x]);
}
var _197=(func["__preJoinArity"]||func.length)-_195.length;
function gather(_198,_199,_19a){
var _19b=_19a;
var _19c=_199.slice(0);
for(var x=0;x<_198.length;x++){
_19c.push(_198[x]);
}
_19a=_19a-_198.length;
if(_19a<=0){
var res=func.apply(_193,_19c);
_19a=_19b;
return res;
}else{
return function(){
return gather(arguments,_19c,_19a);
};
}
}
return gather([],_195,_197);
};
dojo.lang.curryArguments=function(_19f,func,args,_1a2){
var _1a3=[];
var x=_1a2||0;
for(x=_1a2;x<args.length;x++){
_1a3.push(args[x]);
}
return dojo.lang.curry.apply(dojo.lang,[_19f,func].concat(_1a3));
};
dojo.lang.tryThese=function(){
for(var x=0;x<arguments.length;x++){
try{
if(typeof arguments[x]=="function"){
var ret=(arguments[x]());
if(ret){
return ret;
}
}
}
catch(e){
dojo.debug(e);
}
}
};
dojo.lang.delayThese=function(farr,cb,_1a9,_1aa){
if(!farr.length){
if(typeof _1aa=="function"){
_1aa();
}
return;
}
if((typeof _1a9=="undefined")&&(typeof cb=="number")){
_1a9=cb;
cb=function(){
};
}else{
if(!cb){
cb=function(){
};
if(!_1a9){
_1a9=0;
}
}
}
setTimeout(function(){
(farr.shift())();
cb();
dojo.lang.delayThese(farr,cb,_1a9,_1aa);
},_1a9);
};
dojo.provide("dojo.string.extras");
dojo.string.substitute=function(_1ab,map,_1ad,_1ae){
return _1ab.replace(/\$\{([^\s\:\}]+)(?:\:(\S+))?\}/g,function(_1af,key,_1b1){
var _1b2=dojo.getObject(key,false,map).toString();
if(_1b1){
_1b2=dojo.getObject(_1b1,false,_1ae)(_1b2);
}
if(_1ad){
_1b2=_1ad(_1b2);
}
return _1b2;
});
};
dojo.string.capitalize=function(str){
if(!dojo.lang.isString(str)){
return "";
}
return str.replace(/[^\s]+/g,function(word){
return word.substring(0,1).toUpperCase()+word.substring(1);
});
};
dojo.string.isBlank=function(str){
if(!dojo.lang.isString(str)){
return true;
}
return (dojo.string.trim(str).length==0);
};
dojo.string.encodeAscii=function(str){
if(!dojo.lang.isString(str)){
return str;
}
var ret="";
var _1b8=escape(str);
var _1b9,re=/%u([0-9A-F]{4})/i;
while((_1b9=_1b8.match(re))){
var num=Number("0x"+_1b9[1]);
var _1bc=escape("&#"+num+";");
ret+=_1b8.substring(0,_1b9.index)+_1bc;
_1b8=_1b8.substring(_1b9.index+_1b9[0].length);
}
ret+=_1b8.replace(/\+/g,"%2B");
return ret;
};
dojo.string.escape=function(type,str){
var args=dojo.lang.toArray(arguments,1);
switch(type.toLowerCase()){
case "xml":
case "html":
case "xhtml":
return dojo.string.escapeXml.apply(this,args);
case "sql":
return dojo.string.escapeSql.apply(this,args);
case "regexp":
case "regex":
return dojo.string.escapeRegExp.apply(this,args);
case "javascript":
case "jscript":
case "js":
return dojo.string.escapeJavaScript.apply(this,args);
case "ascii":
return dojo.string.encodeAscii.apply(this,args);
default:
return str;
}
};
dojo.string.escapeXml=function(str,_1c1){
str=str.replace(/&/gm,"&amp;").replace(/</gm,"&lt;").replace(/>/gm,"&gt;").replace(/"/gm,"&quot;");
if(!_1c1){
str=str.replace(/'/gm,"&#39;");
}
return str;
};
dojo.string.escapeSql=function(str){
return str.replace(/'/gm,"''");
};
dojo.string.escapeRegExp=function(str,_1c4){
return str.replace(/([\.$?*!=:|{}\(\)\[\]\\\/^])/g,function(ch){
if(_1c4&&_1c4.indexOf(ch)!=-1){
return ch;
}
return "\\"+ch;
});
};
dojo.string.escapeJavaScript=function(str){
return str.replace(/(["'\f\b\n\t\r])/gm,"\\$1");
};
dojo.string.escapeString=function(str){
return ("\""+str.replace(/(["\\])/g,"\\$1")+"\"").replace(/[\f]/g,"\\f").replace(/[\b]/g,"\\b").replace(/[\n]/g,"\\n").replace(/[\t]/g,"\\t").replace(/[\r]/g,"\\r");
};
dojo.string.summary=function(str,len){
if(!len||str.length<=len){
return str;
}
return str.substring(0,len).replace(/\.+$/,"")+"...";
};
dojo.string.endsWith=function(str,end,_1cc){
if(_1cc){
str=str.toLowerCase();
end=end.toLowerCase();
}
if((str.length-end.length)<0){
return false;
}
return str.lastIndexOf(end)==str.length-end.length;
};
dojo.string.endsWithAny=function(str){
for(var i=1;i<arguments.length;i++){
if(dojo.string.endsWith(str,arguments[i])){
return true;
}
}
return false;
};
dojo.string.startsWith=function(str,_1d0,_1d1){
if(_1d1){
str=str.toLowerCase();
_1d0=_1d0.toLowerCase();
}
return str.indexOf(_1d0)==0;
};
dojo.string.startsWithAny=function(str){
for(var i=1;i<arguments.length;i++){
if(dojo.string.startsWith(str,arguments[i])){
return true;
}
}
return false;
};
dojo.string.has=function(str){
for(var i=1;i<arguments.length;i++){
if(str.indexOf(arguments[i])>-1){
return true;
}
}
return false;
};
dojo.string.normalizeNewlines=function(text,_1d7){
if(_1d7=="\n"){
text=text.replace(/\r\n/g,"\n");
text=text.replace(/\r/g,"\n");
}else{
if(_1d7=="\r"){
text=text.replace(/\r\n/g,"\r");
text=text.replace(/\n/g,"\r");
}else{
text=text.replace(/([^\r])\n/g,"$1\r\n").replace(/\r([^\n])/g,"\r\n$1");
}
}
return text;
};
dojo.string.splitEscaped=function(str,_1d9){
var _1da=[];
for(var i=0,_1dc=0;i<str.length;i++){
if(str.charAt(i)=="\\"){
i++;
continue;
}
if(str.charAt(i)==_1d9){
_1da.push(str.substring(_1dc,i));
_1dc=i+1;
}
}
_1da.push(str.substr(_1dc));
return _1da;
};
dojo.provide("dojo.dom");
dojo.dom.ELEMENT_NODE=1;
dojo.dom.ATTRIBUTE_NODE=2;
dojo.dom.TEXT_NODE=3;
dojo.dom.CDATA_SECTION_NODE=4;
dojo.dom.ENTITY_REFERENCE_NODE=5;
dojo.dom.ENTITY_NODE=6;
dojo.dom.PROCESSING_INSTRUCTION_NODE=7;
dojo.dom.COMMENT_NODE=8;
dojo.dom.DOCUMENT_NODE=9;
dojo.dom.DOCUMENT_TYPE_NODE=10;
dojo.dom.DOCUMENT_FRAGMENT_NODE=11;
dojo.dom.NOTATION_NODE=12;
dojo.dom.dojoml="http://www.dojotoolkit.org/2004/dojoml";
dojo.dom.xmlns={svg:"http://www.w3.org/2000/svg",smil:"http://www.w3.org/2001/SMIL20/",mml:"http://www.w3.org/1998/Math/MathML",cml:"http://www.xml-cml.org",xlink:"http://www.w3.org/1999/xlink",xhtml:"http://www.w3.org/1999/xhtml",xul:"http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul",xbl:"http://www.mozilla.org/xbl",fo:"http://www.w3.org/1999/XSL/Format",xsl:"http://www.w3.org/1999/XSL/Transform",xslt:"http://www.w3.org/1999/XSL/Transform",xi:"http://www.w3.org/2001/XInclude",xforms:"http://www.w3.org/2002/01/xforms",saxon:"http://icl.com/saxon",xalan:"http://xml.apache.org/xslt",xsd:"http://www.w3.org/2001/XMLSchema",dt:"http://www.w3.org/2001/XMLSchema-datatypes",xsi:"http://www.w3.org/2001/XMLSchema-instance",rdf:"http://www.w3.org/1999/02/22-rdf-syntax-ns#",rdfs:"http://www.w3.org/2000/01/rdf-schema#",dc:"http://purl.org/dc/elements/1.1/",dcq:"http://purl.org/dc/qualifiers/1.0","soap-env":"http://schemas.xmlsoap.org/soap/envelope/",wsdl:"http://schemas.xmlsoap.org/wsdl/",AdobeExtensions:"http://ns.adobe.com/AdobeSVGViewerExtensions/3.0/"};
dojo.dom.isNode=function(wh){
if(typeof Element=="function"){
try{
return wh instanceof Element;
}
catch(e){
}
}else{
return wh&&!isNaN(wh.nodeType);
}
};
dojo.dom.getUniqueId=function(){
var _1de=dojo.doc();
do{
var id="dj_unique_"+(++arguments.callee._idIncrement);
}while(_1de.getElementById(id));
return id;
};
dojo.dom.getUniqueId._idIncrement=0;
dojo.dom.firstElement=dojo.dom.getFirstChildElement=function(_1e0,_1e1){
var node=_1e0.firstChild;
while(node&&node.nodeType!=dojo.dom.ELEMENT_NODE){
node=node.nextSibling;
}
if(_1e1&&node&&node.tagName&&node.tagName.toLowerCase()!=_1e1.toLowerCase()){
node=dojo.dom.nextElement(node,_1e1);
}
return node;
};
dojo.dom.lastElement=dojo.dom.getLastChildElement=function(_1e3,_1e4){
var node=_1e3.lastChild;
while(node&&node.nodeType!=dojo.dom.ELEMENT_NODE){
node=node.previousSibling;
}
if(_1e4&&node&&node.tagName&&node.tagName.toLowerCase()!=_1e4.toLowerCase()){
node=dojo.dom.prevElement(node,_1e4);
}
return node;
};
dojo.dom.nextElement=dojo.dom.getNextSiblingElement=function(node,_1e7){
if(!node){
return null;
}
do{
node=node.nextSibling;
}while(node&&node.nodeType!=dojo.dom.ELEMENT_NODE);
if(node&&_1e7&&_1e7.toLowerCase()!=node.tagName.toLowerCase()){
return dojo.dom.nextElement(node,_1e7);
}
return node;
};
dojo.dom.prevElement=dojo.dom.getPreviousSiblingElement=function(node,_1e9){
if(!node){
return null;
}
if(_1e9){
_1e9=_1e9.toLowerCase();
}
do{
node=node.previousSibling;
}while(node&&node.nodeType!=dojo.dom.ELEMENT_NODE);
if(node&&_1e9&&_1e9.toLowerCase()!=node.tagName.toLowerCase()){
return dojo.dom.prevElement(node,_1e9);
}
return node;
};
dojo.dom.moveChildren=function(_1ea,_1eb,trim){
var _1ed=0;
if(trim){
while(_1ea.hasChildNodes()&&_1ea.firstChild.nodeType==dojo.dom.TEXT_NODE){
_1ea.removeChild(_1ea.firstChild);
}
while(_1ea.hasChildNodes()&&_1ea.lastChild.nodeType==dojo.dom.TEXT_NODE){
_1ea.removeChild(_1ea.lastChild);
}
}
while(_1ea.hasChildNodes()){
_1eb.appendChild(_1ea.firstChild);
_1ed++;
}
return _1ed;
};
dojo.dom.copyChildren=function(_1ee,_1ef,trim){
var _1f1=_1ee.cloneNode(true);
return this.moveChildren(_1f1,_1ef,trim);
};
dojo.dom.replaceChildren=function(node,_1f3){
var _1f4=[];
if(dojo.render.html.ie){
for(var i=0;i<node.childNodes.length;i++){
_1f4.push(node.childNodes[i]);
}
}
dojo.dom.removeChildren(node);
node.appendChild(_1f3);
for(var i=0;i<_1f4.length;i++){
dojo.dom.destroyNode(_1f4[i]);
}
};
dojo.dom.removeChildren=function(node){
var _1f7=node.childNodes.length;
while(node.hasChildNodes()){
dojo.dom.removeNode(node.firstChild);
}
return _1f7;
};
dojo.dom.replaceNode=function(node,_1f9){
return node.parentNode.replaceChild(_1f9,node);
};
dojo.dom.destroyNode=function(node){
if(node.parentNode){
node=dojo.dom.removeNode(node);
}
if(node.nodeType!=3){
if(dojo.exists("dojo.event.browser.clean")){
dojo.event.browser.clean(node);
}
if(dojo.render.html.ie){
node.outerHTML="";
}
}
};
dojo.dom.removeNode=function(node){
if(node&&node.parentNode){
return node.parentNode.removeChild(node);
}
};
dojo.dom.getAncestors=function(node,_1fd,_1fe){
var _1ff=[];
var _200=(_1fd&&(_1fd instanceof Function||typeof _1fd=="function"));
while(node){
if(!_200||_1fd(node)){
_1ff.push(node);
}
if(_1fe&&_1ff.length>0){
return _1ff[0];
}
node=node.parentNode;
}
if(_1fe){
return null;
}
return _1ff;
};
dojo.dom.getAncestorsByTag=function(node,tag,_203){
tag=tag.toLowerCase();
return dojo.dom.getAncestors(node,function(el){
return ((el.tagName)&&(el.tagName.toLowerCase()==tag));
},_203);
};
dojo.dom.getFirstAncestorByTag=function(node,tag){
return dojo.dom.getAncestorsByTag(node,tag,true);
};
dojo.dom.isDescendantOf=function(node,_208,_209){
if(_209&&node){
node=node.parentNode;
}
while(node){
if(node==_208){
return true;
}
node=node.parentNode;
}
return false;
};
dojo.dom.innerXML=function(node){
if(node.innerXML){
return node.innerXML;
}else{
if(node.xml){
return node.xml;
}else{
if(typeof XMLSerializer!="undefined"){
return (new XMLSerializer()).serializeToString(node);
}
}
}
};
dojo.dom.createDocument=function(){
var doc=null;
var _20c=dojo.doc();
if(!dj_undef("ActiveXObject")){
var _20d=["MSXML2","Microsoft","MSXML","MSXML3"];
for(var i=0;i<_20d.length;i++){
try{
doc=new ActiveXObject(_20d[i]+".XMLDOM");
}
catch(e){
}
if(doc){
break;
}
}
}else{
if((_20c.implementation)&&(_20c.implementation.createDocument)){
doc=_20c.implementation.createDocument("","",null);
}
}
return doc;
};
dojo.dom.createDocumentFromText=function(str,_210){
if(!_210){
_210="text/xml";
}
if(!dj_undef("DOMParser")){
var _211=new DOMParser();
return _211.parseFromString(str,_210);
}else{
if(!dj_undef("ActiveXObject")){
var _212=dojo.dom.createDocument();
if(_212){
_212.async=false;
_212.loadXML(str);
return _212;
}else{
dojo.debug("toXml didn't work?");
}
}else{
var _213=dojo.doc();
if(_213.createElement){
var tmp=_213.createElement("xml");
tmp.innerHTML=str;
if(_213.implementation&&_213.implementation.createDocument){
var _215=_213.implementation.createDocument("foo","",null);
for(var i=0;i<tmp.childNodes.length;i++){
_215.importNode(tmp.childNodes.item(i),true);
}
return _215;
}
return ((tmp.document)&&(tmp.document.firstChild?tmp.document.firstChild:tmp));
}
}
}
return null;
};
dojo.dom.prependChild=function(node,_218){
if(_218.firstChild){
_218.insertBefore(node,_218.firstChild);
}else{
_218.appendChild(node);
}
return true;
};
dojo.dom.insertBefore=function(node,ref,_21b){
if((_21b!=true)&&(node===ref||node.nextSibling===ref)){
return false;
}
var _21c=ref.parentNode;
_21c.insertBefore(node,ref);
return true;
};
dojo.dom.insertAfter=function(node,ref,_21f){
var pn=ref.parentNode;
if(ref==pn.lastChild){
if((_21f!=true)&&(node===ref)){
return false;
}
pn.appendChild(node);
}else{
return this.insertBefore(node,ref.nextSibling,_21f);
}
return true;
};
dojo.dom.insertAtPosition=function(node,ref,_223){
if((!node)||(!ref)||(!_223)){
return false;
}
switch(_223.toLowerCase()){
case "before":
return dojo.dom.insertBefore(node,ref);
case "after":
return dojo.dom.insertAfter(node,ref);
case "first":
if(ref.firstChild){
return dojo.dom.insertBefore(node,ref.firstChild);
}else{
ref.appendChild(node);
return true;
}
break;
default:
ref.appendChild(node);
return true;
}
};
dojo.dom.insertAtIndex=function(node,_225,_226){
var _227=_225.childNodes;
if(!_227.length||_227.length==_226){
_225.appendChild(node);
return true;
}
if(_226==0){
return dojo.dom.prependChild(node,_225);
}
return dojo.dom.insertAfter(node,_227[_226-1]);
};
dojo.dom.textContent=function(node,text){
if(arguments.length>1){
var _22a=dojo.doc();
dojo.dom.replaceChildren(node,_22a.createTextNode(text));
return text;
}else{
if(node["textContent"]!=undefined){
return node.textContent;
}
var _22b="";
if(node==null){
return _22b;
}
var i=0,n;
while(n=node.childNodes[i++]){
switch(n.nodeType){
case 1:
case 5:
_22b+=dojo.dom.textContent(n);
break;
case 3:
case 2:
case 4:
_22b+=n.nodeValue;
break;
default:
break;
}
}
return _22b;
}
};
dojo.dom.hasParent=function(node){
return Boolean(node&&node.parentNode&&dojo.dom.isNode(node.parentNode));
};
dojo.dom.isTag=function(node){
if(node&&node.tagName){
for(var i=1;i<arguments.length;i++){
if(node.tagName==String(arguments[i])){
return String(arguments[i]);
}
}
}
return "";
};
dojo.dom.setAttributeNS=function(elem,_232,_233,_234){
if(elem==null||((elem==undefined)&&(typeof elem=="undefined"))){
dojo.raise("No element given to dojo.dom.setAttributeNS");
}
if(!((elem.setAttributeNS==undefined)&&(typeof elem.setAttributeNS=="undefined"))){
elem.setAttributeNS(_232,_233,_234);
}else{
var _235=elem.ownerDocument;
var _236=_235.createNode(2,_233,_232);
_236.nodeValue=_234;
elem.setAttributeNode(_236);
}
};
dojo.provide("dojo.undo.browser");
try{
if((!djConfig["preventBackButtonFix"])&&(!dojo.hostenv.post_load_)){
document.write("<iframe style='border: 0px; width: 1px; height: 1px; position: absolute; bottom: 0px; right: 0px; visibility: visible;' name='djhistory' id='djhistory' src='"+(djConfig["dojoIframeHistoryUrl"]||dojo.hostenv.getBaseScriptUri()+"iframe_history.html")+"'></iframe>");
}
}
catch(e){
}
if(dojo.render.html.opera){
dojo.debug("Opera is not supported with dojo.undo.browser, so back/forward detection will not work.");
}
dojo.undo.browser={initialHref:(!dj_undef("window"))?window.location.href:"",initialHash:(!dj_undef("window"))?window.location.hash:"",moveForward:false,historyStack:[],forwardStack:[],historyIframe:null,bookmarkAnchor:null,locationTimer:null,setInitialState:function(args){
this.initialState=this._createState(this.initialHref,args,this.initialHash);
},addToHistory:function(args){
this.forwardStack=[];
var hash=null;
var url=null;
if(!this.historyIframe){
if(djConfig["useXDomain"]&&!djConfig["dojoIframeHistoryUrl"]){
dojo.debug("dojo.undo.browser: When using cross-domain Dojo builds,"+" please save iframe_history.html to your domain and set djConfig.dojoIframeHistoryUrl"+" to the path on your domain to iframe_history.html");
}
this.historyIframe=window.frames["djhistory"];
}
if(!this.bookmarkAnchor){
this.bookmarkAnchor=document.createElement("a");
dojo.body().appendChild(this.bookmarkAnchor);
this.bookmarkAnchor.style.display="none";
}
if(args["changeUrl"]){
hash="#"+((args["changeUrl"]!==true)?args["changeUrl"]:(new Date()).getTime());
if(this.historyStack.length==0&&this.initialState.urlHash==hash){
this.initialState=this._createState(url,args,hash);
return;
}else{
if(this.historyStack.length>0&&this.historyStack[this.historyStack.length-1].urlHash==hash){
this.historyStack[this.historyStack.length-1]=this._createState(url,args,hash);
return;
}
}
this.changingUrl=true;
setTimeout("window.location.href = '"+hash+"'; dojo.undo.browser.changingUrl = false;",1);
this.bookmarkAnchor.href=hash;
if(dojo.render.html.ie){
url=this._loadIframeHistory();
var _23b=args["back"]||args["backButton"]||args["handle"];
var tcb=function(_23d){
if(window.location.hash!=""){
setTimeout("window.location.href = '"+hash+"';",1);
}
_23b.apply(this,[_23d]);
};
if(args["back"]){
args.back=tcb;
}else{
if(args["backButton"]){
args.backButton=tcb;
}else{
if(args["handle"]){
args.handle=tcb;
}
}
}
var _23e=args["forward"]||args["forwardButton"]||args["handle"];
var tfw=function(_240){
if(window.location.hash!=""){
window.location.href=hash;
}
if(_23e){
_23e.apply(this,[_240]);
}
};
if(args["forward"]){
args.forward=tfw;
}else{
if(args["forwardButton"]){
args.forwardButton=tfw;
}else{
if(args["handle"]){
args.handle=tfw;
}
}
}
}else{
if(dojo.render.html.moz){
if(!this.locationTimer){
this.locationTimer=setInterval("dojo.undo.browser.checkLocation();",200);
}
}
}
}else{
url=this._loadIframeHistory();
}
this.historyStack.push(this._createState(url,args,hash));
},checkLocation:function(){
if(!this.changingUrl){
var hsl=this.historyStack.length;
if((window.location.hash==this.initialHash||window.location.href==this.initialHref)&&(hsl==1)){
this.handleBackButton();
return;
}
if(this.forwardStack.length>0){
if(this.forwardStack[this.forwardStack.length-1].urlHash==window.location.hash){
this.handleForwardButton();
return;
}
}
if((hsl>=2)&&(this.historyStack[hsl-2])){
if(this.historyStack[hsl-2].urlHash==window.location.hash){
this.handleBackButton();
return;
}
}
}
},iframeLoaded:function(evt,_243){
if(!dojo.render.html.opera){
var _244=this._getUrlQuery(_243.href);
if(_244==null){
if(this.historyStack.length==1){
this.handleBackButton();
}
return;
}
if(this.moveForward){
this.moveForward=false;
return;
}
if(this.historyStack.length>=2&&_244==this._getUrlQuery(this.historyStack[this.historyStack.length-2].url)){
this.handleBackButton();
}else{
if(this.forwardStack.length>0&&_244==this._getUrlQuery(this.forwardStack[this.forwardStack.length-1].url)){
this.handleForwardButton();
}
}
}
},handleBackButton:function(){
var _245=this.historyStack.pop();
if(!_245){
return;
}
var last=this.historyStack[this.historyStack.length-1];
if(!last&&this.historyStack.length==0){
last=this.initialState;
}
if(last){
if(last.kwArgs["back"]){
last.kwArgs["back"]();
}else{
if(last.kwArgs["backButton"]){
last.kwArgs["backButton"]();
}else{
if(last.kwArgs["handle"]){
last.kwArgs.handle("back");
}
}
}
}
this.forwardStack.push(_245);
},handleForwardButton:function(){
var last=this.forwardStack.pop();
if(!last){
return;
}
if(last.kwArgs["forward"]){
last.kwArgs.forward();
}else{
if(last.kwArgs["forwardButton"]){
last.kwArgs.forwardButton();
}else{
if(last.kwArgs["handle"]){
last.kwArgs.handle("forward");
}
}
}
this.historyStack.push(last);
},_createState:function(url,args,hash){
return {"url":url,"kwArgs":args,"urlHash":hash};
},_getUrlQuery:function(url){
var _24c=url.split("?");
if(_24c.length<2){
return null;
}else{
return _24c[1];
}
},_loadIframeHistory:function(){
var url=(djConfig["dojoIframeHistoryUrl"]||dojo.hostenv.getBaseScriptUri()+"iframe_history.html")+"?"+(new Date()).getTime();
this.moveForward=true;
dojo.io.setIFrameSrc(this.historyIframe,url,false);
return url;
}};
dojo.provide("dojo.io.BrowserIO");
if(!dj_undef("window")){
dojo.io.checkChildrenForFile=function(node){
var _24f=false;
var _250=node.getElementsByTagName("input");
dojo.lang.forEach(_250,function(_251){
if(_24f){
return;
}
if(_251.getAttribute("type")=="file"){
_24f=true;
}
});
return _24f;
};
dojo.io.formHasFile=function(_252){
return dojo.io.checkChildrenForFile(_252);
};
dojo.io.updateNode=function(node,_254){
node=dojo.byId(node);
var args=_254;
if(dojo.lang.isString(_254)){
args={url:_254};
}
args.mimetype="text/html";
args.load=function(t,d,e){
while(node.firstChild){
dojo.dom.destroyNode(node.firstChild);
}
node.innerHTML=d;
};
dojo.io.bind(args);
};
dojo.io.formFilter=function(node){
var type=(node.type||"").toLowerCase();
return !node.disabled&&node.name&&!dojo.lang.inArray(["file","submit","image","reset","button"],type);
};
dojo.io.encodeForm=function(_25b,_25c,_25d){
if((!_25b)||(!_25b.tagName)||(!_25b.tagName.toLowerCase()=="form")){
dojo.raise("Attempted to encode a non-form element.");
}
if(!_25d){
_25d=dojo.io.formFilter;
}
var enc=/utf/i.test(_25c||"")?encodeURIComponent:dojo.string.encodeAscii;
var _25f=[];
for(var i=0;i<_25b.elements.length;i++){
var elm=_25b.elements[i];
if(!elm||elm.tagName.toLowerCase()=="fieldset"||!_25d(elm)){
continue;
}
var name=enc(elm.name);
var type=elm.type.toLowerCase();
if(type=="select-multiple"){
for(var j=0;j<elm.options.length;j++){
if(elm.options[j].selected){
_25f.push(name+"="+enc(elm.options[j].value));
}
}
}else{
if(dojo.lang.inArray(["radio","checkbox"],type)){
if(elm.checked){
_25f.push(name+"="+enc(elm.value));
}
}else{
_25f.push(name+"="+enc(elm.value));
}
}
}
var _265=_25b.getElementsByTagName("input");
for(var i=0;i<_265.length;i++){
var _266=_265[i];
if(_266.type.toLowerCase()=="image"&&_266.form==_25b&&_25d(_266)){
var name=enc(_266.name);
_25f.push(name+"="+enc(_266.value));
_25f.push(name+".x=0");
_25f.push(name+".y=0");
}
}
return _25f.join("&")+"&";
};
dojo.io.FormBind=function(args){
this.bindArgs={};
if(args&&args.formNode){
this.init(args);
}else{
if(args){
this.init({formNode:args});
}
}
};
dojo.lang.extend(dojo.io.FormBind,{form:null,bindArgs:null,clickedButton:null,init:function(args){
var form=dojo.byId(args.formNode);
if(!form||!form.tagName||form.tagName.toLowerCase()!="form"){
throw new Error("FormBind: Couldn't apply, invalid form");
}else{
if(this.form==form){
return;
}else{
if(this.form){
throw new Error("FormBind: Already applied to a form");
}
}
}
dojo.lang.mixin(this.bindArgs,args);
this.form=form;
this.connect(form,"onsubmit","submit");
for(var i=0;i<form.elements.length;i++){
var node=form.elements[i];
if(node&&node.type&&dojo.lang.inArray(["submit","button"],node.type.toLowerCase())){
this.connect(node,"onclick","click");
}
}
var _26c=form.getElementsByTagName("input");
for(var i=0;i<_26c.length;i++){
var _26d=_26c[i];
if(_26d.type.toLowerCase()=="image"&&_26d.form==form){
this.connect(_26d,"onclick","click");
}
}
},onSubmit:function(form){
return true;
},submit:function(e){
e.preventDefault();
if(this.onSubmit(this.form)){
dojo.io.bind(dojo.lang.mixin(this.bindArgs,{formFilter:dojo.lang.hitch(this,"formFilter")}));
}
},click:function(e){
var node=e.currentTarget;
if(node.disabled){
return;
}
this.clickedButton=node;
},formFilter:function(node){
var type=(node.type||"").toLowerCase();
var _274=false;
if(node.disabled||!node.name){
_274=false;
}else{
if(dojo.lang.inArray(["submit","button","image"],type)){
if(!this.clickedButton){
this.clickedButton=node;
}
_274=node==this.clickedButton;
}else{
_274=!dojo.lang.inArray(["file","submit","reset","button"],type);
}
}
return _274;
},connect:function(_275,_276,_277){
if(dojo.getObject("dojo.event.connect")){
dojo.event.connect(_275,_276,this,_277);
}else{
var fcn=dojo.lang.hitch(this,_277);
_275[_276]=function(e){
if(!e){
e=window.event;
}
if(!e.currentTarget){
e.currentTarget=e.srcElement;
}
if(!e.preventDefault){
e.preventDefault=function(){
window.event.returnValue=false;
};
}
fcn(e);
};
}
}});
dojo.io.XMLHTTPTransport=new function(){
var _27a=this;
var _27b={};
this.useCache=false;
this.preventCache=false;
function getCacheKey(url,_27d,_27e){
return url+"|"+_27d+"|"+_27e.toLowerCase();
}
function addToCache(url,_280,_281,http){
_27b[getCacheKey(url,_280,_281)]=http;
}
function getFromCache(url,_284,_285){
return _27b[getCacheKey(url,_284,_285)];
}
this.clearCache=function(){
_27b={};
};
function doLoad(_286,http,url,_289,_28a){
if(((http.status>=200)&&(http.status<300))||(http.status==304)||(http.status==1223)||(location.protocol=="file:"&&(http.status==0||http.status==undefined))||(location.protocol=="chrome:"&&(http.status==0||http.status==undefined))){
var ret;
if(_286.method.toLowerCase()=="head"){
var _28c=http.getAllResponseHeaders();
ret={};
ret.toString=function(){
return _28c;
};
var _28d=_28c.split(/[\r\n]+/g);
for(var i=0;i<_28d.length;i++){
var pair=_28d[i].match(/^([^:]+)\s*:\s*(.+)$/i);
if(pair){
ret[pair[1]]=pair[2];
}
}
}else{
if(_286.mimetype=="text/javascript"){
try{
ret=dj_eval(http.responseText);
}
catch(e){
dojo.debug(e);
dojo.debug(http.responseText);
ret=null;
}
}else{
if(_286.mimetype.substr(0,9)=="text/json"||_286.mimetype.substr(0,16)=="application/json"){
try{
ret=dj_eval("("+_286.jsonFilter(http.responseText)+")");
}
catch(e){
dojo.debug(e);
dojo.debug(http.responseText);
ret=false;
}
}else{
if((_286.mimetype=="application/xml")||(_286.mimetype=="text/xml")){
ret=http.responseXML;
if(!ret||typeof ret=="string"||!http.getResponseHeader("Content-Type")){
ret=dojo.dom.createDocumentFromText(http.responseText);
}
}else{
ret=http.responseText;
}
}
}
}
if(_28a){
addToCache(url,_289,_286.method,http);
}
_286[(typeof _286.load=="function")?"load":"handle"]("load",ret,http,_286);
}else{
var _290=new dojo.io.Error("XMLHttpTransport Error: "+http.status+" "+http.statusText);
_286[(typeof _286.error=="function")?"error":"handle"]("error",_290,http,_286);
}
}
function setHeaders(http,_292){
if(_292["headers"]){
for(var _293 in _292["headers"]){
if(_293.toLowerCase()=="content-type"&&!_292["contentType"]){
_292["contentType"]=_292["headers"][_293];
}else{
http.setRequestHeader(_293,_292["headers"][_293]);
}
}
}
}
this.inFlight=[];
this.inFlightTimer=null;
this.startWatchingInFlight=function(){
if(!this.inFlightTimer){
this.inFlightTimer=setTimeout("dojo.io.XMLHTTPTransport.watchInFlight();",10);
}
};
this.watchInFlight=function(){
var now=null;
if(!dojo.hostenv._blockAsync&&!_27a._blockAsync){
for(var x=this.inFlight.length-1;x>=0;x--){
try{
var tif=this.inFlight[x];
if(!tif||tif.http._aborted||!tif.http.readyState){
this.inFlight.splice(x,1);
continue;
}
if(4==tif.http.readyState){
this.inFlight.splice(x,1);
doLoad(tif.req,tif.http,tif.url,tif.query,tif.useCache);
}else{
if(tif.startTime){
if(!now){
now=(new Date()).getTime();
}
if(tif.startTime+(tif.req.timeoutSeconds*1000)<now){
if(typeof tif.http.abort=="function"){
tif.http.abort();
}
this.inFlight.splice(x,1);
tif.req[(typeof tif.req.timeout=="function")?"timeout":"handle"]("timeout",null,tif.http,tif.req);
}
}
}
}
catch(e){
try{
var _297=new dojo.io.Error("XMLHttpTransport.watchInFlight Error: "+e);
tif.req[(typeof tif.req.error=="function")?"error":"handle"]("error",_297,tif.http,tif.req);
}
catch(e2){
dojo.debug("XMLHttpTransport error callback failed: "+e2);
}
}
}
}
clearTimeout(this.inFlightTimer);
if(this.inFlight.length==0){
this.inFlightTimer=null;
return;
}
this.inFlightTimer=setTimeout("dojo.io.XMLHTTPTransport.watchInFlight();",10);
};
var _298=dojo.hostenv.getXmlhttpObject()?true:false;
this.canHandle=function(_299){
var mlc=_299["mimetype"].toLowerCase()||"";
return _298&&((dojo.lang.inArray(["text/plain","text/html","application/xml","text/xml","text/javascript"],mlc))||(mlc.substr(0,9)=="text/json"||mlc.substr(0,16)=="application/json"))&&!(_299["formNode"]&&dojo.io.formHasFile(_299["formNode"]));
};
this.multipartBoundary="45309FFF-BD65-4d50-99C9-36986896A96F";
this.bind=function(_29b){
var url=_29b.url;
var _29d="";
if(_29b["formNode"]){
var ta=_29b.formNode.getAttribute("action");
if(typeof (ta)!="string"){
ta=_29b.formNode.attributes.action.value;
}
if((ta)&&(!_29b["url"])){
url=ta;
}
var tp=_29b.formNode.getAttribute("method");
if((tp)&&(!_29b["method"])){
_29b.method=tp;
}
_29d+=dojo.io.encodeForm(_29b.formNode,_29b.encoding,_29b["formFilter"]);
}
if(url.indexOf("#")>-1){
dojo.debug("Warning: dojo.io.bind: stripping hash values from url:",url);
url=url.split("#")[0];
}
if(_29b["file"]){
_29b.method="post";
}
if(!_29b["method"]){
_29b.method="get";
}
if(_29b.method.toLowerCase()=="get"){
_29b.multipart=false;
}else{
if(_29b["file"]){
_29b.multipart=true;
}else{
if(!_29b["multipart"]){
_29b.multipart=false;
}
}
}
if(_29b["backButton"]||_29b["back"]||_29b["changeUrl"]){
dojo.undo.browser.addToHistory(_29b);
}
var _2a0=_29b["content"]||{};
if(_29b.sendTransport){
_2a0["dojo.transport"]="xmlhttp";
}
do{
if(_29b.postContent){
_29d=_29b.postContent;
break;
}
if(_2a0){
_29d+=dojo.io.argsFromMap(_2a0,_29b.encoding);
}
if(_29b.method.toLowerCase()=="get"||!_29b.multipart){
break;
}
var t=[];
if(_29d.length){
var q=_29d.split("&");
for(var i=0;i<q.length;++i){
if(q[i].length){
var p=q[i].split("=");
t.push("--"+this.multipartBoundary,"Content-Disposition: form-data; name=\""+p[0]+"\"","",p[1]);
}
}
}
if(_29b.file){
if(dojo.lang.isArray(_29b.file)){
for(var i=0;i<_29b.file.length;++i){
var o=_29b.file[i];
t.push("--"+this.multipartBoundary,"Content-Disposition: form-data; name=\""+o.name+"\"; filename=\""+("fileName" in o?o.fileName:o.name)+"\"","Content-Type: "+("contentType" in o?o.contentType:"application/octet-stream"),"",o.content);
}
}else{
var o=_29b.file;
t.push("--"+this.multipartBoundary,"Content-Disposition: form-data; name=\""+o.name+"\"; filename=\""+("fileName" in o?o.fileName:o.name)+"\"","Content-Type: "+("contentType" in o?o.contentType:"application/octet-stream"),"",o.content);
}
}
if(t.length){
t.push("--"+this.multipartBoundary+"--","");
_29d=t.join("\r\n");
}
}while(false);
var _2a6=_29b["sync"]?false:true;
var _2a7=_29b["preventCache"]||(this.preventCache==true&&_29b["preventCache"]!=false);
var _2a8=_29b["useCache"]==true||(this.useCache==true&&_29b["useCache"]!=false);
if(!_2a7&&_2a8){
var _2a9=getFromCache(url,_29d,_29b.method);
if(_2a9){
doLoad(_29b,_2a9,url,_29d,false);
return;
}
}
var http=dojo.hostenv.getXmlhttpObject(_29b);
var _2ab=false;
if(_2a6){
var _2ac=this.inFlight.push({"req":_29b,"http":http,"url":url,"query":_29d,"useCache":_2a8,"startTime":_29b.timeoutSeconds?(new Date()).getTime():0});
this.startWatchingInFlight();
}else{
_27a._blockAsync=true;
}
if(_29b.method.toLowerCase()=="post"){
if(!_29b.user){
http.open("POST",url,_2a6);
}else{
http.open("POST",url,_2a6,_29b.user,_29b.password);
}
setHeaders(http,_29b);
http.setRequestHeader("Content-Type",_29b.multipart?("multipart/form-data; boundary="+this.multipartBoundary):(_29b.contentType||"application/x-www-form-urlencoded"));
try{
http.send(_29d);
}
catch(e){
if(typeof http.abort=="function"){
http.abort();
}
doLoad(_29b,{status:404},url,_29d,_2a8);
}
}else{
var _2ad=url;
if(_29d!=""){
_2ad+=(_2ad.indexOf("?")>-1?"&":"?")+_29d;
}
if(_2a7){
_2ad+=(dojo.string.endsWithAny(_2ad,"?","&")?"":(_2ad.indexOf("?")>-1?"&":"?"))+"dojo.preventCache="+new Date().valueOf();
}
if(!_29b.user){
http.open(_29b.method.toUpperCase(),_2ad,_2a6);
}else{
http.open(_29b.method.toUpperCase(),_2ad,_2a6,_29b.user,_29b.password);
}
setHeaders(http,_29b);
try{
http.send(null);
}
catch(e){
if(typeof http.abort=="function"){
http.abort();
}
doLoad(_29b,{status:404},url,_29d,_2a8);
}
}
if(!_2a6){
doLoad(_29b,http,url,_29d,_2a8);
_27a._blockAsync=false;
}
_29b.abort=function(){
try{
http._aborted=true;
}
catch(e){
}
return http.abort();
};
return;
};
dojo.io.transports.addTransport("XMLHTTPTransport");
};
}
dojo.provide("dojo.io.cookie");
dojo.io.cookie.setCookie=function(name,_2af,days,path,_2b2,_2b3){
var _2b4=-1;
if((typeof days=="number")&&(days>=0)){
var d=new Date();
d.setTime(d.getTime()+(days*24*60*60*1000));
_2b4=d.toGMTString();
}
_2af=escape(_2af);
document.cookie=name+"="+_2af+";"+(_2b4!=-1?" expires="+_2b4+";":"")+(path?"path="+path:"")+(_2b2?"; domain="+_2b2:"")+(_2b3?"; secure":"");
};
dojo.io.cookie.set=dojo.io.cookie.setCookie;
dojo.io.cookie.getCookie=function(name){
var idx=document.cookie.lastIndexOf(name+"=");
if(idx==-1){
return null;
}
var _2b8=document.cookie.substring(idx+name.length+1);
var end=_2b8.indexOf(";");
if(end==-1){
end=_2b8.length;
}
_2b8=_2b8.substring(0,end);
_2b8=unescape(_2b8);
return _2b8;
};
dojo.io.cookie.get=dojo.io.cookie.getCookie;
dojo.io.cookie.deleteCookie=function(name){
dojo.io.cookie.setCookie(name,"-",0);
};
dojo.io.cookie.setObjectCookie=function(name,obj,days,path,_2bf,_2c0,_2c1){
if(arguments.length==5){
_2c1=_2bf;
_2bf=null;
_2c0=null;
}
var _2c2=[],_2c3,_2c4="";
if(!_2c1){
_2c3=dojo.io.cookie.getObjectCookie(name);
}
if(days>=0){
if(!_2c3){
_2c3={};
}
for(var prop in obj){
if(obj[prop]==null){
delete _2c3[prop];
}else{
if((typeof obj[prop]=="string")||(typeof obj[prop]=="number")){
_2c3[prop]=obj[prop];
}
}
}
prop=null;
for(var prop in _2c3){
_2c2.push(escape(prop)+"="+escape(_2c3[prop]));
}
_2c4=_2c2.join("&");
}
dojo.io.cookie.setCookie(name,_2c4,days,path,_2bf,_2c0);
};
dojo.io.cookie.getObjectCookie=function(name){
var _2c7=null,_2c8=dojo.io.cookie.getCookie(name);
if(_2c8){
_2c7={};
var _2c9=_2c8.split("&");
for(var i=0;i<_2c9.length;i++){
var pair=_2c9[i].split("=");
var _2cc=pair[1];
if(isNaN(_2cc)){
_2cc=unescape(pair[1]);
}
_2c7[unescape(pair[0])]=_2cc;
}
}
return _2c7;
};
dojo.io.cookie.isSupported=function(){
if(typeof navigator.cookieEnabled!="boolean"){
dojo.io.cookie.setCookie("__TestingYourBrowserForCookieSupport__","CookiesAllowed",90,null);
var _2cd=dojo.io.cookie.getCookie("__TestingYourBrowserForCookieSupport__");
navigator.cookieEnabled=(_2cd=="CookiesAllowed");
if(navigator.cookieEnabled){
this.deleteCookie("__TestingYourBrowserForCookieSupport__");
}
}
return navigator.cookieEnabled;
};
if(!dojo.io.cookies){
dojo.io.cookies=dojo.io.cookie;
}
dojo.kwCompoundRequire({common:["dojo.io.common"],rhino:["dojo.io.RhinoIO"],browser:["dojo.io.BrowserIO","dojo.io.cookie"],dashboard:["dojo.io.BrowserIO","dojo.io.cookie"]});
dojo.provide("dojo.io.*");
dojo.provide("dojo.io.ScriptSrcIO");
dojo.io.ScriptSrcTransport=new function(){
this.preventCache=false;
this.maxUrlLength=1000;
this.inFlightTimer=null;
this.DsrStatusCodes={Continue:100,Ok:200,Error:500};
this.startWatchingInFlight=function(){
if(!this.inFlightTimer){
this.inFlightTimer=setInterval("dojo.io.ScriptSrcTransport.watchInFlight();",100);
}
};
this.watchInFlight=function(){
var _2ce=0;
var _2cf=0;
for(var _2d0 in this._state){
_2ce++;
var _2d1=this._state[_2d0];
if(_2d1.isDone){
_2cf++;
delete this._state[_2d0];
}else{
if(!_2d1.isFinishing){
var _2d2=_2d1.kwArgs;
try{
if(_2d1.checkString&&eval("typeof("+_2d1.checkString+") != 'undefined'")){
_2d1.isFinishing=true;
this._finish(_2d1,"load");
_2cf++;
delete this._state[_2d0];
}else{
if(_2d2.timeoutSeconds&&_2d2.timeout){
if(_2d1.startTime+(_2d2.timeoutSeconds*1000)<(new Date()).getTime()){
_2d1.isFinishing=true;
this._finish(_2d1,"timeout");
_2cf++;
delete this._state[_2d0];
}
}else{
if(!_2d2.timeoutSeconds){
_2cf++;
}
}
}
}
catch(e){
_2d1.isFinishing=true;
this._finish(_2d1,"error",{status:this.DsrStatusCodes.Error,response:e});
}
}
}
}
if(_2cf>=_2ce){
clearInterval(this.inFlightTimer);
this.inFlightTimer=null;
}
};
this.canHandle=function(_2d3){
return dojo.lang.inArray(["text/javascript","text/json","application/json"],(_2d3["mimetype"].toLowerCase()))&&(_2d3["method"].toLowerCase()=="get")&&!(_2d3["formNode"]&&dojo.io.formHasFile(_2d3["formNode"]))&&(!_2d3["sync"]||_2d3["sync"]==false)&&!_2d3["file"]&&!_2d3["multipart"];
};
this.removeScripts=function(){
var _2d4=document.getElementsByTagName("script");
for(var i=0;_2d4&&i<_2d4.length;i++){
var _2d6=_2d4[i];
if(_2d6.className=="ScriptSrcTransport"){
var _2d7=_2d6.parentNode;
_2d7.removeChild(_2d6);
i--;
}
}
};
this.bind=function(_2d8){
var url=_2d8.url;
var _2da="";
if(_2d8["formNode"]){
var ta=_2d8.formNode.getAttribute("action");
if((ta)&&(!_2d8["url"])){
url=ta;
}
var tp=_2d8.formNode.getAttribute("method");
if((tp)&&(!_2d8["method"])){
_2d8.method=tp;
}
_2da+=dojo.io.encodeForm(_2d8.formNode,_2d8.encoding,_2d8["formFilter"]);
}
if(url.indexOf("#")>-1){
dojo.debug("Warning: dojo.io.bind: stripping hash values from url:",url);
url=url.split("#")[0];
}
var _2dd=url.split("?");
if(_2dd&&_2dd.length==2){
url=_2dd[0];
_2da+=(_2da?"&":"")+_2dd[1];
}
if(_2d8["backButton"]||_2d8["back"]||_2d8["changeUrl"]){
dojo.undo.browser.addToHistory(_2d8);
}
var id=_2d8["apiId"]?_2d8["apiId"]:"id"+this._counter++;
var _2df=_2d8["content"];
var _2e0=_2d8.jsonParamName;
if(_2d8.sendTransport||_2e0){
if(!_2df){
_2df={};
}
if(_2d8.sendTransport){
_2df["dojo.transport"]="scriptsrc";
}
if(_2e0){
_2df[_2e0]="dojo.io.ScriptSrcTransport._state."+id+".jsonpCall";
}
}
if(_2d8.postContent){
_2da=_2d8.postContent;
}else{
if(_2df){
_2da+=((_2da)?"&":"")+dojo.io.argsFromMap(_2df,_2d8.encoding,_2e0);
}
}
if(_2d8["apiId"]){
_2d8["useRequestId"]=true;
}
var _2e1={"id":id,"idParam":"_dsrid="+id,"url":url,"query":_2da,"kwArgs":_2d8,"startTime":(new Date()).getTime(),"isFinishing":false};
if(!url){
this._finish(_2e1,"error",{status:this.DsrStatusCodes.Error,statusText:"url.none"});
return;
}
if(_2df&&_2df[_2e0]){
_2e1.jsonp=_2df[_2e0];
_2e1.jsonpCall=function(data){
if(data["Error"]||data["error"]){
if(dojo["json"]&&dojo["json"]["serialize"]){
dojo.debug(dojo.json.serialize(data));
}
dojo.io.ScriptSrcTransport._finish(this,"error",data);
}else{
dojo.io.ScriptSrcTransport._finish(this,"load",data);
}
};
}
if(_2d8["useRequestId"]||_2d8["checkString"]||_2e1["jsonp"]){
this._state[id]=_2e1;
}
if(_2d8["checkString"]){
_2e1.checkString=_2d8["checkString"];
}
_2e1.constantParams=(_2d8["constantParams"]==null?"":_2d8["constantParams"]);
if(_2d8["preventCache"]||(this.preventCache==true&&_2d8["preventCache"]!=false)){
_2e1.nocacheParam="dojo.preventCache="+new Date().valueOf();
}else{
_2e1.nocacheParam="";
}
var _2e3=_2e1.url.length+_2e1.query.length+_2e1.constantParams.length+_2e1.nocacheParam.length+this._extraPaddingLength;
if(_2d8["useRequestId"]){
_2e3+=_2e1.idParam.length;
}
if(!_2d8["checkString"]&&_2d8["useRequestId"]&&!_2e1["jsonp"]&&!_2d8["forceSingleRequest"]&&_2e3>this.maxUrlLength){
if(url>this.maxUrlLength){
this._finish(_2e1,"error",{status:this.DsrStatusCodes.Error,statusText:"url.tooBig"});
return;
}else{
this._multiAttach(_2e1,1);
}
}else{
var _2e4=[_2e1.constantParams,_2e1.nocacheParam,_2e1.query];
if(_2d8["useRequestId"]&&!_2e1["jsonp"]){
_2e4.unshift(_2e1.idParam);
}
var _2e5=this._buildUrl(_2e1.url,_2e4);
_2e1.finalUrl=_2e5;
this._attach(_2e1.id,_2e5);
}
this.startWatchingInFlight();
};
this._counter=1;
this._state={};
this._extraPaddingLength=16;
this._buildUrl=function(url,_2e7){
var _2e8=url;
var _2e9="?";
for(var i=0;i<_2e7.length;i++){
if(_2e7[i]){
_2e8+=_2e9+_2e7[i];
_2e9="&";
}
}
return _2e8;
};
this._attach=function(id,url){
var _2ed=document.createElement("script");
_2ed.type="text/javascript";
_2ed.src=url;
_2ed.id=id;
_2ed.className="ScriptSrcTransport";
document.getElementsByTagName("head")[0].appendChild(_2ed);
};
this._multiAttach=function(_2ee,part){
if(_2ee.query==null){
this._finish(_2ee,"error",{status:this.DsrStatusCodes.Error,statusText:"query.null"});
return;
}
if(!_2ee.constantParams){
_2ee.constantParams="";
}
var _2f0=this.maxUrlLength-_2ee.idParam.length-_2ee.constantParams.length-_2ee.url.length-_2ee.nocacheParam.length-this._extraPaddingLength;
var _2f1=_2ee.query.length<_2f0;
var _2f2;
if(_2f1){
_2f2=_2ee.query;
_2ee.query=null;
}else{
var _2f3=_2ee.query.lastIndexOf("&",_2f0-1);
var _2f4=_2ee.query.lastIndexOf("=",_2f0-1);
if(_2f3>_2f4||_2f4==_2f0-1){
_2f2=_2ee.query.substring(0,_2f3);
_2ee.query=_2ee.query.substring(_2f3+1,_2ee.query.length);
}else{
_2f2=_2ee.query.substring(0,_2f0);
var _2f5=_2f2.substring((_2f3==-1?0:_2f3+1),_2f4);
_2ee.query=_2f5+"="+_2ee.query.substring(_2f0,_2ee.query.length);
}
}
var _2f6=[_2f2,_2ee.idParam,_2ee.constantParams,_2ee.nocacheParam];
if(!_2f1){
_2f6.push("_part="+part);
}
var url=this._buildUrl(_2ee.url,_2f6);
this._attach(_2ee.id+"_"+part,url);
};
this._finish=function(_2f8,_2f9,_2fa){
if(_2f9!="partOk"&&!_2f8.kwArgs[_2f9]&&!_2f8.kwArgs["handle"]){
if(_2f9=="error"){
_2f8.isDone=true;
throw _2fa;
}
}else{
switch(_2f9){
case "load":
var _2fb=_2fa?_2fa.response:null;
if(!_2fb){
_2fb=_2fa;
}
_2f8.kwArgs[(typeof _2f8.kwArgs.load=="function")?"load":"handle"]("load",_2fb,_2fa,_2f8.kwArgs);
_2f8.isDone=true;
break;
case "partOk":
var part=parseInt(_2fa.response.part,10)+1;
if(_2fa.response.constantParams){
_2f8.constantParams=_2fa.response.constantParams;
}
this._multiAttach(_2f8,part);
_2f8.isDone=false;
break;
case "error":
_2f8.kwArgs[(typeof _2f8.kwArgs.error=="function")?"error":"handle"]("error",_2fa.response,_2fa,_2f8.kwArgs);
_2f8.isDone=true;
break;
default:
_2f8.kwArgs[(typeof _2f8.kwArgs[_2f9]=="function")?_2f9:"handle"](_2f9,_2fa,_2fa,_2f8.kwArgs);
_2f8.isDone=true;
}
}
};
dojo.io.transports.addTransport("ScriptSrcTransport");
};
if(typeof window!="undefined"){
window.onscriptload=function(_2fd){
var _2fe=null;
var _2ff=dojo.io.ScriptSrcTransport;
if(_2ff._state[_2fd.id]){
_2fe=_2ff._state[_2fd.id];
}else{
var _300;
for(var _301 in _2ff._state){
_300=_2ff._state[_301];
if(_300.finalUrl&&_300.finalUrl==_2fd.id){
_2fe=_300;
break;
}
}
if(_2fe==null){
var _302=document.getElementsByTagName("script");
for(var i=0;_302&&i<_302.length;i++){
var _304=_302[i];
if(_304.getAttribute("class")=="ScriptSrcTransport"&&_304.src==_2fd.id){
_2fe=_2ff._state[_304.id];
break;
}
}
}
if(_2fe==null){
throw "No matching state for onscriptload event.id: "+_2fd.id;
}
}
var _305="error";
switch(_2fd.status){
case dojo.io.ScriptSrcTransport.DsrStatusCodes.Continue:
_305="partOk";
break;
case dojo.io.ScriptSrcTransport.DsrStatusCodes.Ok:
_305="load";
break;
}
_2ff._finish(_2fe,_305,_2fd);
};
}
if(!this["dojo"]){
alert("\"dojo/__package__.js\" is now located at \"dojo/dojo.js\". Please update your includes accordingly");
}

