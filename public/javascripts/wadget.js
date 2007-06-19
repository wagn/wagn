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
var Prototype={Version:"1.5.0",BrowserFeatures:{XPath:!!document.evaluate},ScriptFragment:"(?:<script.*?>)((\n|\r|.)*?)(?:</script>)",emptyFunction:function(){
},K:function(x){
return x;
}};
var Class={create:function(){
return function(){
this.initialize.apply(this,arguments);
};
}};
var Abstract=new Object();
Object.extend=function(_307,_308){
for(var _309 in _308){
_307[_309]=_308[_309];
}
return _307;
};
Object.extend(Object,{inspect:function(_30a){
try{
if(_30a===undefined){
return "undefined";
}
if(_30a===null){
return "null";
}
return _30a.inspect?_30a.inspect():_30a.toString();
}
catch(e){
if(e instanceof RangeError){
return "...";
}
throw e;
}
},keys:function(_30b){
var keys=[];
for(var _30d in _30b){
keys.push(_30d);
}
return keys;
},values:function(_30e){
var _30f=[];
for(var _310 in _30e){
_30f.push(_30e[_310]);
}
return _30f;
},clone:function(_311){
return Object.extend({},_311);
}});
Function.prototype.bind=function(){
var _312=this,args=$A(arguments),_314=args.shift();
return function(){
return _312.apply(_314,args.concat($A(arguments)));
};
};
Function.prototype.bindAsEventListener=function(_315){
var _316=this,args=$A(arguments),_315=args.shift();
return function(_318){
return _316.apply(_315,[(_318||window.event)].concat(args).concat($A(arguments)));
};
};
Object.extend(Number.prototype,{toColorPart:function(){
var _319=this.toString(16);
if(this<16){
return "0"+_319;
}
return _319;
},succ:function(){
return this+1;
},times:function(_31a){
$R(0,this,true).each(_31a);
return this;
}});
var Try={these:function(){
var _31b;
for(var i=0,_31d=arguments.length;i<_31d;i++){
var _31e=arguments[i];
try{
_31b=_31e();
break;
}
catch(e){
}
}
return _31b;
}};
var PeriodicalExecuter=Class.create();
PeriodicalExecuter.prototype={initialize:function(_31f,_320){
this.callback=_31f;
this.frequency=_320;
this.currentlyExecuting=false;
this.registerCallback();
},registerCallback:function(){
this.timer=setInterval(this.onTimerEvent.bind(this),this.frequency*1000);
},stop:function(){
if(!this.timer){
return;
}
clearInterval(this.timer);
this.timer=null;
},onTimerEvent:function(){
if(!this.currentlyExecuting){
try{
this.currentlyExecuting=true;
this.callback(this);
}
finally{
this.currentlyExecuting=false;
}
}
}};
String.interpret=function(_321){
return _321==null?"":String(_321);
};
Object.extend(String.prototype,{gsub:function(_322,_323){
var _324="",_325=this,_326;
_323=arguments.callee.prepareReplacement(_323);
while(_325.length>0){
if(_326=_325.match(_322)){
_324+=_325.slice(0,_326.index);
_324+=String.interpret(_323(_326));
_325=_325.slice(_326.index+_326[0].length);
}else{
_324+=_325,_325="";
}
}
return _324;
},sub:function(_327,_328,_329){
_328=this.gsub.prepareReplacement(_328);
_329=_329===undefined?1:_329;
return this.gsub(_327,function(_32a){
if(--_329<0){
return _32a[0];
}
return _328(_32a);
});
},scan:function(_32b,_32c){
this.gsub(_32b,_32c);
return this;
},truncate:function(_32d,_32e){
_32d=_32d||30;
_32e=_32e===undefined?"...":_32e;
return this.length>_32d?this.slice(0,_32d-_32e.length)+_32e:this;
},strip:function(){
return this.replace(/^\s+/,"").replace(/\s+$/,"");
},stripTags:function(){
return this.replace(/<\/?[^>]+>/gi,"");
},stripScripts:function(){
return this.replace(new RegExp(Prototype.ScriptFragment,"img"),"");
},extractScripts:function(){
var _32f=new RegExp(Prototype.ScriptFragment,"img");
var _330=new RegExp(Prototype.ScriptFragment,"im");
return (this.match(_32f)||[]).map(function(_331){
return (_331.match(_330)||["",""])[1];
});
},evalScripts:function(){
return this.extractScripts().map(function(_332){
return eval(_332);
});
},escapeHTML:function(){
var div=document.createElement("div");
var text=document.createTextNode(this);
div.appendChild(text);
return div.innerHTML;
},unescapeHTML:function(){
var div=document.createElement("div");
div.innerHTML=this.stripTags();
return div.childNodes[0]?(div.childNodes.length>1?$A(div.childNodes).inject("",function(memo,node){
return memo+node.nodeValue;
}):div.childNodes[0].nodeValue):"";
},toQueryParams:function(_338){
var _339=this.strip().match(/([^?#]*)(#.*)?$/);
if(!_339){
return {};
}
return _339[1].split(_338||"&").inject({},function(hash,pair){
if((pair=pair.split("="))[0]){
var name=decodeURIComponent(pair[0]);
var _33d=pair[1]?decodeURIComponent(pair[1]):undefined;
if(hash[name]!==undefined){
if(hash[name].constructor!=Array){
hash[name]=[hash[name]];
}
if(_33d){
hash[name].push(_33d);
}
}else{
hash[name]=_33d;
}
}
return hash;
});
},toArray:function(){
return this.split("");
},succ:function(){
return this.slice(0,this.length-1)+String.fromCharCode(this.charCodeAt(this.length-1)+1);
},camelize:function(){
var _33e=this.split("-"),len=_33e.length;
if(len==1){
return _33e[0];
}
var _340=this.charAt(0)=="-"?_33e[0].charAt(0).toUpperCase()+_33e[0].substring(1):_33e[0];
for(var i=1;i<len;i++){
_340+=_33e[i].charAt(0).toUpperCase()+_33e[i].substring(1);
}
return _340;
},capitalize:function(){
return this.charAt(0).toUpperCase()+this.substring(1).toLowerCase();
},underscore:function(){
return this.gsub(/::/,"/").gsub(/([A-Z]+)([A-Z][a-z])/,"#{1}_#{2}").gsub(/([a-z\d])([A-Z])/,"#{1}_#{2}").gsub(/-/,"_").toLowerCase();
},dasherize:function(){
return this.gsub(/_/,"-");
},inspect:function(_342){
var _343=this.replace(/\\/g,"\\\\");
if(_342){
return "\""+_343.replace(/"/g,"\\\"")+"\"";
}else{
return "'"+_343.replace(/'/g,"\\'")+"'";
}
}});
String.prototype.gsub.prepareReplacement=function(_344){
if(typeof _344=="function"){
return _344;
}
var _345=new Template(_344);
return function(_346){
return _345.evaluate(_346);
};
};
String.prototype.parseQuery=String.prototype.toQueryParams;
var Template=Class.create();
Template.Pattern=/(^|.|\r|\n)(#\{(.*?)\})/;
Template.prototype={initialize:function(_347,_348){
this.template=_347.toString();
this.pattern=_348||Template.Pattern;
},evaluate:function(_349){
return this.template.gsub(this.pattern,function(_34a){
var _34b=_34a[1];
if(_34b=="\\"){
return _34a[2];
}
return _34b+String.interpret(_349[_34a[3]]);
});
}};
var $break=new Object();
var $continue=new Object();
var Enumerable={each:function(_34c){
var _34d=0;
try{
this._each(function(_34e){
try{
_34c(_34e,_34d++);
}
catch(e){
if(e!=$continue){
throw e;
}
}
});
}
catch(e){
if(e!=$break){
throw e;
}
}
return this;
},eachSlice:function(_34f,_350){
var _351=-_34f,_352=[],_353=this.toArray();
while((_351+=_34f)<_353.length){
_352.push(_353.slice(_351,_351+_34f));
}
return _352.map(_350);
},all:function(_354){
var _355=true;
this.each(function(_356,_357){
_355=_355&&!!(_354||Prototype.K)(_356,_357);
if(!_355){
throw $break;
}
});
return _355;
},any:function(_358){
var _359=false;
this.each(function(_35a,_35b){
if(_359=!!(_358||Prototype.K)(_35a,_35b)){
throw $break;
}
});
return _359;
},collect:function(_35c){
var _35d=[];
this.each(function(_35e,_35f){
_35d.push((_35c||Prototype.K)(_35e,_35f));
});
return _35d;
},detect:function(_360){
var _361;
this.each(function(_362,_363){
if(_360(_362,_363)){
_361=_362;
throw $break;
}
});
return _361;
},findAll:function(_364){
var _365=[];
this.each(function(_366,_367){
if(_364(_366,_367)){
_365.push(_366);
}
});
return _365;
},grep:function(_368,_369){
var _36a=[];
this.each(function(_36b,_36c){
var _36d=_36b.toString();
if(_36d.match(_368)){
_36a.push((_369||Prototype.K)(_36b,_36c));
}
});
return _36a;
},include:function(_36e){
var _36f=false;
this.each(function(_370){
if(_370==_36e){
_36f=true;
throw $break;
}
});
return _36f;
},inGroupsOf:function(_371,_372){
_372=_372===undefined?null:_372;
return this.eachSlice(_371,function(_373){
while(_373.length<_371){
_373.push(_372);
}
return _373;
});
},inject:function(memo,_375){
this.each(function(_376,_377){
memo=_375(memo,_376,_377);
});
return memo;
},invoke:function(_378){
var args=$A(arguments).slice(1);
return this.map(function(_37a){
return _37a[_378].apply(_37a,args);
});
},max:function(_37b){
var _37c;
this.each(function(_37d,_37e){
_37d=(_37b||Prototype.K)(_37d,_37e);
if(_37c==undefined||_37d>=_37c){
_37c=_37d;
}
});
return _37c;
},min:function(_37f){
var _380;
this.each(function(_381,_382){
_381=(_37f||Prototype.K)(_381,_382);
if(_380==undefined||_381<_380){
_380=_381;
}
});
return _380;
},partition:function(_383){
var _384=[],_385=[];
this.each(function(_386,_387){
((_383||Prototype.K)(_386,_387)?_384:_385).push(_386);
});
return [_384,_385];
},pluck:function(_388){
var _389=[];
this.each(function(_38a,_38b){
_389.push(_38a[_388]);
});
return _389;
},reject:function(_38c){
var _38d=[];
this.each(function(_38e,_38f){
if(!_38c(_38e,_38f)){
_38d.push(_38e);
}
});
return _38d;
},sortBy:function(_390){
return this.map(function(_391,_392){
return {value:_391,criteria:_390(_391,_392)};
}).sort(function(left,_394){
var a=left.criteria,b=_394.criteria;
return a<b?-1:a>b?1:0;
}).pluck("value");
},toArray:function(){
return this.map();
},zip:function(){
var _397=Prototype.K,args=$A(arguments);
if(typeof args.last()=="function"){
_397=args.pop();
}
var _399=[this].concat(args).map($A);
return this.map(function(_39a,_39b){
return _397(_399.pluck(_39b));
});
},size:function(){
return this.toArray().length;
},inspect:function(){
return "#<Enumerable:"+this.toArray().inspect()+">";
}};
Object.extend(Enumerable,{map:Enumerable.collect,find:Enumerable.detect,select:Enumerable.findAll,member:Enumerable.include,entries:Enumerable.toArray});
var $A=Array.from=function(_39c){
if(!_39c){
return [];
}
if(_39c.toArray){
return _39c.toArray();
}else{
var _39d=[];
for(var i=0,_39f=_39c.length;i<_39f;i++){
_39d.push(_39c[i]);
}
return _39d;
}
};
Object.extend(Array.prototype,Enumerable);
if(!Array.prototype._reverse){
Array.prototype._reverse=Array.prototype.reverse;
}
Object.extend(Array.prototype,{_each:function(_3a0){
for(var i=0,_3a2=this.length;i<_3a2;i++){
_3a0(this[i]);
}
},clear:function(){
this.length=0;
return this;
},first:function(){
return this[0];
},last:function(){
return this[this.length-1];
},compact:function(){
return this.select(function(_3a3){
return _3a3!=null;
});
},flatten:function(){
return this.inject([],function(_3a4,_3a5){
return _3a4.concat(_3a5&&_3a5.constructor==Array?_3a5.flatten():[_3a5]);
});
},without:function(){
var _3a6=$A(arguments);
return this.select(function(_3a7){
return !_3a6.include(_3a7);
});
},indexOf:function(_3a8){
for(var i=0,_3aa=this.length;i<_3aa;i++){
if(this[i]==_3a8){
return i;
}
}
return -1;
},reverse:function(_3ab){
return (_3ab!==false?this:this.toArray())._reverse();
},reduce:function(){
return this.length>1?this:this[0];
},uniq:function(){
return this.inject([],function(_3ac,_3ad){
return _3ac.include(_3ad)?_3ac:_3ac.concat([_3ad]);
});
},clone:function(){
return [].concat(this);
},size:function(){
return this.length;
},inspect:function(){
return "["+this.map(Object.inspect).join(", ")+"]";
}});
Array.prototype.toArray=Array.prototype.clone;
function $w(_3ae){
_3ae=_3ae.strip();
return _3ae?_3ae.split(/\s+/):[];
}
if(window.opera){
Array.prototype.concat=function(){
var _3af=[];
for(var i=0,_3b1=this.length;i<_3b1;i++){
_3af.push(this[i]);
}
for(var i=0,_3b1=arguments.length;i<_3b1;i++){
if(arguments[i].constructor==Array){
for(var j=0,_3b3=arguments[i].length;j<_3b3;j++){
_3af.push(arguments[i][j]);
}
}else{
_3af.push(arguments[i]);
}
}
return _3af;
};
}
var Hash=function(obj){
Object.extend(this,obj||{});
};
Object.extend(Hash,{toQueryString:function(obj){
var _3b6=[];
this.prototype._each.call(obj,function(pair){
if(!pair.key){
return;
}
if(pair.value&&pair.value.constructor==Array){
var _3b8=pair.value.compact();
if(_3b8.length<2){
pair.value=_3b8.reduce();
}else{
key=encodeURIComponent(pair.key);
_3b8.each(function(_3b9){
_3b9=_3b9!=undefined?encodeURIComponent(_3b9):"";
_3b6.push(key+"="+encodeURIComponent(_3b9));
});
return;
}
}
if(pair.value==undefined){
pair[1]="";
}
_3b6.push(pair.map(encodeURIComponent).join("="));
});
return _3b6.join("&");
}});
Object.extend(Hash.prototype,Enumerable);
Object.extend(Hash.prototype,{_each:function(_3ba){
for(var key in this){
var _3bc=this[key];
if(_3bc&&_3bc==Hash.prototype[key]){
continue;
}
var pair=[key,_3bc];
pair.key=key;
pair.value=_3bc;
_3ba(pair);
}
},keys:function(){
return this.pluck("key");
},values:function(){
return this.pluck("value");
},merge:function(hash){
return $H(hash).inject(this,function(_3bf,pair){
_3bf[pair.key]=pair.value;
return _3bf;
});
},remove:function(){
var _3c1;
for(var i=0,_3c3=arguments.length;i<_3c3;i++){
var _3c4=this[arguments[i]];
if(_3c4!==undefined){
if(_3c1===undefined){
_3c1=_3c4;
}else{
if(_3c1.constructor!=Array){
_3c1=[_3c1];
}
_3c1.push(_3c4);
}
}
delete this[arguments[i]];
}
return _3c1;
},toQueryString:function(){
return Hash.toQueryString(this);
},inspect:function(){
return "#<Hash:{"+this.map(function(pair){
return pair.map(Object.inspect).join(": ");
}).join(", ")+"}>";
}});
function $H(_3c6){
if(_3c6&&_3c6.constructor==Hash){
return _3c6;
}
return new Hash(_3c6);
}
ObjectRange=Class.create();
Object.extend(ObjectRange.prototype,Enumerable);
Object.extend(ObjectRange.prototype,{initialize:function(_3c7,end,_3c9){
this.start=_3c7;
this.end=end;
this.exclusive=_3c9;
},_each:function(_3ca){
var _3cb=this.start;
while(this.include(_3cb)){
_3ca(_3cb);
_3cb=_3cb.succ();
}
},include:function(_3cc){
if(_3cc<this.start){
return false;
}
if(this.exclusive){
return _3cc<this.end;
}
return _3cc<=this.end;
}});
var $R=function(_3cd,end,_3cf){
return new ObjectRange(_3cd,end,_3cf);
};
var Ajax={getTransport:function(){
return Try.these(function(){
return new XMLHttpRequest();
},function(){
return new ActiveXObject("Msxml2.XMLHTTP");
},function(){
return new ActiveXObject("Microsoft.XMLHTTP");
})||false;
},activeRequestCount:0};
Ajax.Responders={responders:[],_each:function(_3d0){
this.responders._each(_3d0);
},register:function(_3d1){
if(!this.include(_3d1)){
this.responders.push(_3d1);
}
},unregister:function(_3d2){
this.responders=this.responders.without(_3d2);
},dispatch:function(_3d3,_3d4,_3d5,json){
this.each(function(_3d7){
if(typeof _3d7[_3d3]=="function"){
try{
_3d7[_3d3].apply(_3d7,[_3d4,_3d5,json]);
}
catch(e){
}
}
});
}};
Object.extend(Ajax.Responders,Enumerable);
Ajax.Responders.register({onCreate:function(){
Ajax.activeRequestCount++;
},onComplete:function(){
Ajax.activeRequestCount--;
}});
Ajax.Base=function(){
};
Ajax.Base.prototype={setOptions:function(_3d8){
this.options={method:"post",asynchronous:true,contentType:"application/x-www-form-urlencoded",encoding:"UTF-8",parameters:""};
Object.extend(this.options,_3d8||{});
this.options.method=this.options.method.toLowerCase();
if(typeof this.options.parameters=="string"){
this.options.parameters=this.options.parameters.toQueryParams();
}
}};
Ajax.Request=Class.create();
Ajax.Request.Events=["Uninitialized","Loading","Loaded","Interactive","Complete"];
Ajax.Request.prototype=Object.extend(new Ajax.Base(),{_complete:false,initialize:function(url,_3da){
this.transport=Ajax.getTransport();
this.setOptions(_3da);
this.request(url);
},request:function(url){
this.url=url;
this.method=this.options.method;
var _3dc=this.options.parameters;
if(!["get","post"].include(this.method)){
_3dc["_method"]=this.method;
this.method="post";
}
_3dc=Hash.toQueryString(_3dc);
if(_3dc&&/Konqueror|Safari|KHTML/.test(navigator.userAgent)){
_3dc+="&_=";
}
if(this.method=="get"&&_3dc){
this.url+=(this.url.indexOf("?")>-1?"&":"?")+_3dc;
}
try{
Ajax.Responders.dispatch("onCreate",this,this.transport);
this.transport.open(this.method.toUpperCase(),this.url,this.options.asynchronous);
if(this.options.asynchronous){
setTimeout(function(){
this.respondToReadyState(1);
}.bind(this),10);
}
this.transport.onreadystatechange=this.onStateChange.bind(this);
this.setRequestHeaders();
var body=this.method=="post"?(this.options.postBody||_3dc):null;
this.transport.send(body);
if(!this.options.asynchronous&&this.transport.overrideMimeType){
this.onStateChange();
}
}
catch(e){
this.dispatchException(e);
}
},onStateChange:function(){
var _3de=this.transport.readyState;
if(_3de>1&&!((_3de==4)&&this._complete)){
this.respondToReadyState(this.transport.readyState);
}
},setRequestHeaders:function(){
var _3df={"X-Requested-With":"XMLHttpRequest","X-Prototype-Version":Prototype.Version,"Accept":"text/javascript, text/html, application/xml, text/xml, */*"};
if(this.method=="post"){
_3df["Content-type"]=this.options.contentType+(this.options.encoding?"; charset="+this.options.encoding:"");
if(this.transport.overrideMimeType&&(navigator.userAgent.match(/Gecko\/(\d{4})/)||[0,2005])[1]<2005){
_3df["Connection"]="close";
}
}
if(typeof this.options.requestHeaders=="object"){
var _3e0=this.options.requestHeaders;
if(typeof _3e0.push=="function"){
for(var i=0,_3e2=_3e0.length;i<_3e2;i+=2){
_3df[_3e0[i]]=_3e0[i+1];
}
}else{
$H(_3e0).each(function(pair){
_3df[pair.key]=pair.value;
});
}
}
for(var name in _3df){
this.transport.setRequestHeader(name,_3df[name]);
}
},success:function(){
return !this.transport.status||(this.transport.status>=200&&this.transport.status<300);
},respondToReadyState:function(_3e5){
var _3e6=Ajax.Request.Events[_3e5];
var _3e7=this.transport,json=this.evalJSON();
if(_3e6=="Complete"){
try{
this._complete=true;
(this.options["on"+this.transport.status]||this.options["on"+(this.success()?"Success":"Failure")]||Prototype.emptyFunction)(_3e7,json);
}
catch(e){
this.dispatchException(e);
}
if((this.getHeader("Content-type")||"text/javascript").strip().match(/^(text|application)\/(x-)?(java|ecma)script(;.*)?$/i)){
this.evalResponse();
}
}
try{
(this.options["on"+_3e6]||Prototype.emptyFunction)(_3e7,json);
Ajax.Responders.dispatch("on"+_3e6,this,_3e7,json);
}
catch(e){
this.dispatchException(e);
}
if(_3e6=="Complete"){
this.transport.onreadystatechange=Prototype.emptyFunction;
}
},getHeader:function(name){
try{
return this.transport.getResponseHeader(name);
}
catch(e){
return null;
}
},evalJSON:function(){
try{
var json=this.getHeader("X-JSON");
return json?eval("("+json+")"):null;
}
catch(e){
return null;
}
},evalResponse:function(){
try{
return eval(this.transport.responseText);
}
catch(e){
this.dispatchException(e);
}
},dispatchException:function(_3eb){
(this.options.onException||Prototype.emptyFunction)(this,_3eb);
Ajax.Responders.dispatch("onException",this,_3eb);
}});
Ajax.Updater=Class.create();
Object.extend(Object.extend(Ajax.Updater.prototype,Ajax.Request.prototype),{initialize:function(_3ec,url,_3ee){
this.container={success:(_3ec.success||_3ec),failure:(_3ec.failure||(_3ec.success?null:_3ec))};
this.transport=Ajax.getTransport();
this.setOptions(_3ee);
var _3ef=this.options.onComplete||Prototype.emptyFunction;
this.options.onComplete=(function(_3f0,_3f1){
this.updateContent();
_3ef(_3f0,_3f1);
}).bind(this);
this.request(url);
},updateContent:function(){
var _3f2=this.container[this.success()?"success":"failure"];
var _3f3=this.transport.responseText;
if(!this.options.evalScripts){
_3f3=_3f3.stripScripts();
}
if(_3f2=$(_3f2)){
if(this.options.insertion){
new this.options.insertion(_3f2,_3f3);
}else{
_3f2.update(_3f3);
}
}
if(this.success()){
if(this.onComplete){
setTimeout(this.onComplete.bind(this),10);
}
}
}});
Ajax.PeriodicalUpdater=Class.create();
Ajax.PeriodicalUpdater.prototype=Object.extend(new Ajax.Base(),{initialize:function(_3f4,url,_3f6){
this.setOptions(_3f6);
this.onComplete=this.options.onComplete;
this.frequency=(this.options.frequency||2);
this.decay=(this.options.decay||1);
this.updater={};
this.container=_3f4;
this.url=url;
this.start();
},start:function(){
this.options.onComplete=this.updateComplete.bind(this);
this.onTimerEvent();
},stop:function(){
this.updater.options.onComplete=undefined;
clearTimeout(this.timer);
(this.onComplete||Prototype.emptyFunction).apply(this,arguments);
},updateComplete:function(_3f7){
if(this.options.decay){
this.decay=(_3f7.responseText==this.lastText?this.decay*this.options.decay:1);
this.lastText=_3f7.responseText;
}
this.timer=setTimeout(this.onTimerEvent.bind(this),this.decay*this.frequency*1000);
},onTimerEvent:function(){
this.updater=new Ajax.Updater(this.container,this.url,this.options);
}});
function $(_3f8){
if(arguments.length>1){
for(var i=0,_3fa=[],_3fb=arguments.length;i<_3fb;i++){
_3fa.push($(arguments[i]));
}
return _3fa;
}
if(typeof _3f8=="string"){
_3f8=document.getElementById(_3f8);
}
return Element.extend(_3f8);
}
if(Prototype.BrowserFeatures.XPath){
document._getElementsByXPath=function(_3fc,_3fd){
var _3fe=[];
var _3ff=document.evaluate(_3fc,$(_3fd)||document,null,XPathResult.ORDERED_NODE_SNAPSHOT_TYPE,null);
for(var i=0,_401=_3ff.snapshotLength;i<_401;i++){
_3fe.push(_3ff.snapshotItem(i));
}
return _3fe;
};
}
document.getElementsByClassName=function(_402,_403){
if(Prototype.BrowserFeatures.XPath){
var q=".//*[contains(concat(' ', @class, ' '), ' "+_402+" ')]";
return document._getElementsByXPath(q,_403);
}else{
var _405=($(_403)||document.body).getElementsByTagName("*");
var _406=[],_407;
for(var i=0,_409=_405.length;i<_409;i++){
_407=_405[i];
if(Element.hasClassName(_407,_402)){
_406.push(Element.extend(_407));
}
}
return _406;
}
};
if(!window.Element){
var Element=new Object();
}
Element.extend=function(_40a){
if(!_40a||_nativeExtensions||_40a.nodeType==3){
return _40a;
}
if(!_40a._extended&&_40a.tagName&&_40a!=window){
var _40b=Object.clone(Element.Methods),_40c=Element.extend.cache;
if(_40a.tagName=="FORM"){
Object.extend(_40b,Form.Methods);
}
if(["INPUT","TEXTAREA","SELECT"].include(_40a.tagName)){
Object.extend(_40b,Form.Element.Methods);
}
Object.extend(_40b,Element.Methods.Simulated);
for(var _40d in _40b){
var _40e=_40b[_40d];
if(typeof _40e=="function"&&!(_40d in _40a)){
_40a[_40d]=_40c.findOrStore(_40e);
}
}
}
_40a._extended=true;
return _40a;
};
Element.extend.cache={findOrStore:function(_40f){
return this[_40f]=this[_40f]||function(){
return _40f.apply(null,[this].concat($A(arguments)));
};
}};
Element.Methods={visible:function(_410){
return $(_410).style.display!="none";
},toggle:function(_411){
_411=$(_411);
Element[Element.visible(_411)?"hide":"show"](_411);
return _411;
},hide:function(_412){
$(_412).style.display="none";
return _412;
},show:function(_413){
$(_413).style.display="";
return _413;
},remove:function(_414){
_414=$(_414);
_414.parentNode.removeChild(_414);
return _414;
},update:function(_415,html){
html=typeof html=="undefined"?"":html.toString();
$(_415).innerHTML=html.stripScripts();
setTimeout(function(){
html.evalScripts();
},10);
return _415;
},replace:function(_417,html){
_417=$(_417);
html=typeof html=="undefined"?"":html.toString();
if(_417.outerHTML){
_417.outerHTML=html.stripScripts();
}else{
var _419=_417.ownerDocument.createRange();
_419.selectNodeContents(_417);
_417.parentNode.replaceChild(_419.createContextualFragment(html.stripScripts()),_417);
}
setTimeout(function(){
html.evalScripts();
},10);
return _417;
},inspect:function(_41a){
_41a=$(_41a);
var _41b="<"+_41a.tagName.toLowerCase();
$H({"id":"id","className":"class"}).each(function(pair){
var _41d=pair.first(),_41e=pair.last();
var _41f=(_41a[_41d]||"").toString();
if(_41f){
_41b+=" "+_41e+"="+_41f.inspect(true);
}
});
return _41b+">";
},recursivelyCollect:function(_420,_421){
_420=$(_420);
var _422=[];
while(_420=_420[_421]){
if(_420.nodeType==1){
_422.push(Element.extend(_420));
}
}
return _422;
},ancestors:function(_423){
return $(_423).recursivelyCollect("parentNode");
},descendants:function(_424){
return $A($(_424).getElementsByTagName("*"));
},immediateDescendants:function(_425){
if(!(_425=$(_425).firstChild)){
return [];
}
while(_425&&_425.nodeType!=1){
_425=_425.nextSibling;
}
if(_425){
return [_425].concat($(_425).nextSiblings());
}
return [];
},previousSiblings:function(_426){
return $(_426).recursivelyCollect("previousSibling");
},nextSiblings:function(_427){
return $(_427).recursivelyCollect("nextSibling");
},siblings:function(_428){
_428=$(_428);
return _428.previousSiblings().reverse().concat(_428.nextSiblings());
},match:function(_429,_42a){
if(typeof _42a=="string"){
_42a=new Selector(_42a);
}
return _42a.match($(_429));
},up:function(_42b,_42c,_42d){
return Selector.findElement($(_42b).ancestors(),_42c,_42d);
},down:function(_42e,_42f,_430){
return Selector.findElement($(_42e).descendants(),_42f,_430);
},previous:function(_431,_432,_433){
return Selector.findElement($(_431).previousSiblings(),_432,_433);
},next:function(_434,_435,_436){
return Selector.findElement($(_434).nextSiblings(),_435,_436);
},getElementsBySelector:function(){
var args=$A(arguments),_438=$(args.shift());
return Selector.findChildElements(_438,args);
},getElementsByClassName:function(_439,_43a){
return document.getElementsByClassName(_43a,_439);
},readAttribute:function(_43b,name){
_43b=$(_43b);
if(document.all&&!window.opera){
var t=Element._attributeTranslations;
if(t.values[name]){
return t.values[name](_43b,name);
}
if(t.names[name]){
name=t.names[name];
}
var _43e=_43b.attributes[name];
if(_43e){
return _43e.nodeValue;
}
}
return _43b.getAttribute(name);
},getHeight:function(_43f){
return $(_43f).getDimensions().height;
},getWidth:function(_440){
return $(_440).getDimensions().width;
},classNames:function(_441){
return new Element.ClassNames(_441);
},hasClassName:function(_442,_443){
if(!(_442=$(_442))){
return;
}
var _444=_442.className;
if(_444.length==0){
return false;
}
if(_444==_443||_444.match(new RegExp("(^|\\s)"+_443+"(\\s|$)"))){
return true;
}
return false;
},addClassName:function(_445,_446){
if(!(_445=$(_445))){
return;
}
Element.classNames(_445).add(_446);
return _445;
},removeClassName:function(_447,_448){
if(!(_447=$(_447))){
return;
}
Element.classNames(_447).remove(_448);
return _447;
},toggleClassName:function(_449,_44a){
if(!(_449=$(_449))){
return;
}
Element.classNames(_449)[_449.hasClassName(_44a)?"remove":"add"](_44a);
return _449;
},observe:function(){
Event.observe.apply(Event,arguments);
return $A(arguments).first();
},stopObserving:function(){
Event.stopObserving.apply(Event,arguments);
return $A(arguments).first();
},cleanWhitespace:function(_44b){
_44b=$(_44b);
var node=_44b.firstChild;
while(node){
var _44d=node.nextSibling;
if(node.nodeType==3&&!/\S/.test(node.nodeValue)){
_44b.removeChild(node);
}
node=_44d;
}
return _44b;
},empty:function(_44e){
return $(_44e).innerHTML.match(/^\s*$/);
},descendantOf:function(_44f,_450){
_44f=$(_44f),_450=$(_450);
while(_44f=_44f.parentNode){
if(_44f==_450){
return true;
}
}
return false;
},scrollTo:function(_451){
_451=$(_451);
var pos=Position.cumulativeOffset(_451);
window.scrollTo(pos[0],pos[1]);
return _451;
},getStyle:function(_453,_454){
_453=$(_453);
if(["float","cssFloat"].include(_454)){
_454=(typeof _453.style.styleFloat!="undefined"?"styleFloat":"cssFloat");
}
_454=_454.camelize();
var _455=_453.style[_454];
if(!_455){
if(document.defaultView&&document.defaultView.getComputedStyle){
var css=document.defaultView.getComputedStyle(_453,null);
_455=css?css[_454]:null;
}else{
if(_453.currentStyle){
_455=_453.currentStyle[_454];
}
}
}
if((_455=="auto")&&["width","height"].include(_454)&&(_453.getStyle("display")!="none")){
_455=_453["offset"+_454.capitalize()]+"px";
}
if(window.opera&&["left","top","right","bottom"].include(_454)){
if(Element.getStyle(_453,"position")=="static"){
_455="auto";
}
}
if(_454=="opacity"){
if(_455){
return parseFloat(_455);
}
if(_455=(_453.getStyle("filter")||"").match(/alpha\(opacity=(.*)\)/)){
if(_455[1]){
return parseFloat(_455[1])/100;
}
}
return 1;
}
return _455=="auto"?null:_455;
},setStyle:function(_457,_458){
_457=$(_457);
for(var name in _458){
var _45a=_458[name];
if(name=="opacity"){
if(_45a==1){
_45a=(/Gecko/.test(navigator.userAgent)&&!/Konqueror|Safari|KHTML/.test(navigator.userAgent))?0.999999:1;
if(/MSIE/.test(navigator.userAgent)&&!window.opera){
_457.style.filter=_457.getStyle("filter").replace(/alpha\([^\)]*\)/gi,"");
}
}else{
if(_45a==""){
if(/MSIE/.test(navigator.userAgent)&&!window.opera){
_457.style.filter=_457.getStyle("filter").replace(/alpha\([^\)]*\)/gi,"");
}
}else{
if(_45a<0.00001){
_45a=0;
}
if(/MSIE/.test(navigator.userAgent)&&!window.opera){
_457.style.filter=_457.getStyle("filter").replace(/alpha\([^\)]*\)/gi,"")+"alpha(opacity="+_45a*100+")";
}
}
}
}else{
if(["float","cssFloat"].include(name)){
name=(typeof _457.style.styleFloat!="undefined")?"styleFloat":"cssFloat";
}
}
_457.style[name.camelize()]=_45a;
}
return _457;
},getDimensions:function(_45b){
_45b=$(_45b);
var _45c=$(_45b).getStyle("display");
if(_45c!="none"&&_45c!=null){
return {width:_45b.offsetWidth,height:_45b.offsetHeight};
}
var els=_45b.style;
var _45e=els.visibility;
var _45f=els.position;
var _460=els.display;
els.visibility="hidden";
els.position="absolute";
els.display="block";
var _461=_45b.clientWidth;
var _462=_45b.clientHeight;
els.display=_460;
els.position=_45f;
els.visibility=_45e;
return {width:_461,height:_462};
},makePositioned:function(_463){
_463=$(_463);
var pos=Element.getStyle(_463,"position");
if(pos=="static"||!pos){
_463._madePositioned=true;
_463.style.position="relative";
if(window.opera){
_463.style.top=0;
_463.style.left=0;
}
}
return _463;
},undoPositioned:function(_465){
_465=$(_465);
if(_465._madePositioned){
_465._madePositioned=undefined;
_465.style.position=_465.style.top=_465.style.left=_465.style.bottom=_465.style.right="";
}
return _465;
},makeClipping:function(_466){
_466=$(_466);
if(_466._overflow){
return _466;
}
_466._overflow=_466.style.overflow||"auto";
if((Element.getStyle(_466,"overflow")||"visible")!="hidden"){
_466.style.overflow="hidden";
}
return _466;
},undoClipping:function(_467){
_467=$(_467);
if(!_467._overflow){
return _467;
}
_467.style.overflow=_467._overflow=="auto"?"":_467._overflow;
_467._overflow=null;
return _467;
}};
Object.extend(Element.Methods,{childOf:Element.Methods.descendantOf});
Element._attributeTranslations={};
Element._attributeTranslations.names={colspan:"colSpan",rowspan:"rowSpan",valign:"vAlign",datetime:"dateTime",accesskey:"accessKey",tabindex:"tabIndex",enctype:"encType",maxlength:"maxLength",readonly:"readOnly",longdesc:"longDesc"};
Element._attributeTranslations.values={_getAttr:function(_468,_469){
return _468.getAttribute(_469,2);
},_flag:function(_46a,_46b){
return $(_46a).hasAttribute(_46b)?_46b:null;
},style:function(_46c){
return _46c.style.cssText.toLowerCase();
},title:function(_46d){
var node=_46d.getAttributeNode("title");
return node.specified?node.nodeValue:null;
}};
Object.extend(Element._attributeTranslations.values,{href:Element._attributeTranslations.values._getAttr,src:Element._attributeTranslations.values._getAttr,disabled:Element._attributeTranslations.values._flag,checked:Element._attributeTranslations.values._flag,readonly:Element._attributeTranslations.values._flag,multiple:Element._attributeTranslations.values._flag});
Element.Methods.Simulated={hasAttribute:function(_46f,_470){
var t=Element._attributeTranslations;
_470=t.names[_470]||_470;
return $(_46f).getAttributeNode(_470).specified;
}};
if(document.all&&!window.opera){
Element.Methods.update=function(_472,html){
_472=$(_472);
html=typeof html=="undefined"?"":html.toString();
var _474=_472.tagName.toUpperCase();
if(["THEAD","TBODY","TR","TD"].include(_474)){
var div=document.createElement("div");
switch(_474){
case "THEAD":
case "TBODY":
div.innerHTML="<table><tbody>"+html.stripScripts()+"</tbody></table>";
depth=2;
break;
case "TR":
div.innerHTML="<table><tbody><tr>"+html.stripScripts()+"</tr></tbody></table>";
depth=3;
break;
case "TD":
div.innerHTML="<table><tbody><tr><td>"+html.stripScripts()+"</td></tr></tbody></table>";
depth=4;
}
$A(_472.childNodes).each(function(node){
_472.removeChild(node);
});
depth.times(function(){
div=div.firstChild;
});
$A(div.childNodes).each(function(node){
_472.appendChild(node);
});
}else{
_472.innerHTML=html.stripScripts();
}
setTimeout(function(){
html.evalScripts();
},10);
return _472;
};
}
Object.extend(Element,Element.Methods);
var _nativeExtensions=false;
if(/Konqueror|Safari|KHTML/.test(navigator.userAgent)){
["","Form","Input","TextArea","Select"].each(function(tag){
var _479="HTML"+tag+"Element";
if(window[_479]){
return;
}
var _47a=window[_479]={};
_47a.prototype=document.createElement(tag?tag.toLowerCase():"div").__proto__;
});
}
Element.addMethods=function(_47b){
Object.extend(Element.Methods,_47b||{});
function copy(_47c,_47d,_47e){
_47e=_47e||false;
var _47f=Element.extend.cache;
for(var _480 in _47c){
var _481=_47c[_480];
if(!_47e||!(_480 in _47d)){
_47d[_480]=_47f.findOrStore(_481);
}
}
}
if(typeof HTMLElement!="undefined"){
copy(Element.Methods,HTMLElement.prototype);
copy(Element.Methods.Simulated,HTMLElement.prototype,true);
copy(Form.Methods,HTMLFormElement.prototype);
[HTMLInputElement,HTMLTextAreaElement,HTMLSelectElement].each(function(_482){
copy(Form.Element.Methods,_482.prototype);
});
_nativeExtensions=true;
}
};
var Toggle=new Object();
Toggle.display=Element.toggle;
Abstract.Insertion=function(_483){
this.adjacency=_483;
};
Abstract.Insertion.prototype={initialize:function(_484,_485){
this.element=$(_484);
this.content=_485.stripScripts();
if(this.adjacency&&this.element.insertAdjacentHTML){
try{
this.element.insertAdjacentHTML(this.adjacency,this.content);
}
catch(e){
var _486=this.element.tagName.toUpperCase();
if(["TBODY","TR"].include(_486)){
this.insertContent(this.contentFromAnonymousTable());
}else{
throw e;
}
}
}else{
this.range=this.element.ownerDocument.createRange();
if(this.initializeRange){
this.initializeRange();
}
this.insertContent([this.range.createContextualFragment(this.content)]);
}
setTimeout(function(){
_485.evalScripts();
},10);
},contentFromAnonymousTable:function(){
var div=document.createElement("div");
div.innerHTML="<table><tbody>"+this.content+"</tbody></table>";
return $A(div.childNodes[0].childNodes[0].childNodes);
}};
var Insertion=new Object();
Insertion.Before=Class.create();
Insertion.Before.prototype=Object.extend(new Abstract.Insertion("beforeBegin"),{initializeRange:function(){
this.range.setStartBefore(this.element);
},insertContent:function(_488){
_488.each((function(_489){
this.element.parentNode.insertBefore(_489,this.element);
}).bind(this));
}});
Insertion.Top=Class.create();
Insertion.Top.prototype=Object.extend(new Abstract.Insertion("afterBegin"),{initializeRange:function(){
this.range.selectNodeContents(this.element);
this.range.collapse(true);
},insertContent:function(_48a){
_48a.reverse(false).each((function(_48b){
this.element.insertBefore(_48b,this.element.firstChild);
}).bind(this));
}});
Insertion.Bottom=Class.create();
Insertion.Bottom.prototype=Object.extend(new Abstract.Insertion("beforeEnd"),{initializeRange:function(){
this.range.selectNodeContents(this.element);
this.range.collapse(this.element);
},insertContent:function(_48c){
_48c.each((function(_48d){
this.element.appendChild(_48d);
}).bind(this));
}});
Insertion.After=Class.create();
Insertion.After.prototype=Object.extend(new Abstract.Insertion("afterEnd"),{initializeRange:function(){
this.range.setStartAfter(this.element);
},insertContent:function(_48e){
_48e.each((function(_48f){
this.element.parentNode.insertBefore(_48f,this.element.nextSibling);
}).bind(this));
}});
Element.ClassNames=Class.create();
Element.ClassNames.prototype={initialize:function(_490){
this.element=$(_490);
},_each:function(_491){
this.element.className.split(/\s+/).select(function(name){
return name.length>0;
})._each(_491);
},set:function(_493){
this.element.className=_493;
},add:function(_494){
if(this.include(_494)){
return;
}
this.set($A(this).concat(_494).join(" "));
},remove:function(_495){
if(!this.include(_495)){
return;
}
this.set($A(this).without(_495).join(" "));
},toString:function(){
return $A(this).join(" ");
}};
Object.extend(Element.ClassNames.prototype,Enumerable);
var Selector=Class.create();
Selector.prototype={initialize:function(_496){
this.params={classNames:[]};
this.expression=_496.toString().strip();
this.parseExpression();
this.compileMatcher();
},parseExpression:function(){
function abort(_497){
throw "Parse error in selector: "+_497;
}
if(this.expression==""){
abort("empty expression");
}
var _498=this.params,expr=this.expression,_49a,_49b,_49c,rest;
while(_49a=expr.match(/^(.*)\[([a-z0-9_:-]+?)(?:([~\|!]?=)(?:"([^"]*)"|([^\]\s]*)))?\]$/i)){
_498.attributes=_498.attributes||[];
_498.attributes.push({name:_49a[2],operator:_49a[3],value:_49a[4]||_49a[5]||""});
expr=_49a[1];
}
if(expr=="*"){
return this.params.wildcard=true;
}
while(_49a=expr.match(/^([^a-z0-9_-])?([a-z0-9_-]+)(.*)/i)){
_49b=_49a[1],_49c=_49a[2],rest=_49a[3];
switch(_49b){
case "#":
_498.id=_49c;
break;
case ".":
_498.classNames.push(_49c);
break;
case "":
case undefined:
_498.tagName=_49c.toUpperCase();
break;
default:
abort(expr.inspect());
}
expr=rest;
}
if(expr.length>0){
abort(expr.inspect());
}
},buildMatchExpression:function(){
var _49e=this.params,_49f=[],_4a0;
if(_49e.wildcard){
_49f.push("true");
}
if(_4a0=_49e.id){
_49f.push("element.readAttribute(\"id\") == "+_4a0.inspect());
}
if(_4a0=_49e.tagName){
_49f.push("element.tagName.toUpperCase() == "+_4a0.inspect());
}
if((_4a0=_49e.classNames).length>0){
for(var i=0,_4a2=_4a0.length;i<_4a2;i++){
_49f.push("element.hasClassName("+_4a0[i].inspect()+")");
}
}
if(_4a0=_49e.attributes){
_4a0.each(function(_4a3){
var _4a4="element.readAttribute("+_4a3.name.inspect()+")";
var _4a5=function(_4a6){
return _4a4+" && "+_4a4+".split("+_4a6.inspect()+")";
};
switch(_4a3.operator){
case "=":
_49f.push(_4a4+" == "+_4a3.value.inspect());
break;
case "~=":
_49f.push(_4a5(" ")+".include("+_4a3.value.inspect()+")");
break;
case "|=":
_49f.push(_4a5("-")+".first().toUpperCase() == "+_4a3.value.toUpperCase().inspect());
break;
case "!=":
_49f.push(_4a4+" != "+_4a3.value.inspect());
break;
case "":
case undefined:
_49f.push("element.hasAttribute("+_4a3.name.inspect()+")");
break;
default:
throw "Unknown operator "+_4a3.operator+" in selector";
}
});
}
return _49f.join(" && ");
},compileMatcher:function(){
this.match=new Function("element","if (!element.tagName) return false;       element = $(element);       return "+this.buildMatchExpression());
},findElements:function(_4a7){
var _4a8;
if(_4a8=$(this.params.id)){
if(this.match(_4a8)){
if(!_4a7||Element.childOf(_4a8,_4a7)){
return [_4a8];
}
}
}
_4a7=(_4a7||document).getElementsByTagName(this.params.tagName||"*");
var _4a9=[];
for(var i=0,_4ab=_4a7.length;i<_4ab;i++){
if(this.match(_4a8=_4a7[i])){
_4a9.push(Element.extend(_4a8));
}
}
return _4a9;
},toString:function(){
return this.expression;
}};
Object.extend(Selector,{matchElements:function(_4ac,_4ad){
var _4ae=new Selector(_4ad);
return _4ac.select(_4ae.match.bind(_4ae)).map(Element.extend);
},findElement:function(_4af,_4b0,_4b1){
if(typeof _4b0=="number"){
_4b1=_4b0,_4b0=false;
}
return Selector.matchElements(_4af,_4b0||"*")[_4b1||0];
},findChildElements:function(_4b2,_4b3){
return _4b3.map(function(_4b4){
return _4b4.match(/[^\s"]+(?:"[^"]*"[^\s"]+)*/g).inject([null],function(_4b5,expr){
var _4b7=new Selector(expr);
return _4b5.inject([],function(_4b8,_4b9){
return _4b8.concat(_4b7.findElements(_4b9||_4b2));
});
});
}).flatten();
}});
function $$(){
return Selector.findChildElements(document,$A(arguments));
}
var Form={reset:function(form){
$(form).reset();
return form;
},serializeElements:function(_4bb,_4bc){
var data=_4bb.inject({},function(_4be,_4bf){
if(!_4bf.disabled&&_4bf.name){
var key=_4bf.name,_4c1=$(_4bf).getValue();
if(_4c1!=undefined){
if(_4be[key]){
if(_4be[key].constructor!=Array){
_4be[key]=[_4be[key]];
}
_4be[key].push(_4c1);
}else{
_4be[key]=_4c1;
}
}
}
return _4be;
});
return _4bc?data:Hash.toQueryString(data);
}};
Form.Methods={serialize:function(form,_4c3){
return Form.serializeElements(Form.getElements(form),_4c3);
},getElements:function(form){
return $A($(form).getElementsByTagName("*")).inject([],function(_4c5,_4c6){
if(Form.Element.Serializers[_4c6.tagName.toLowerCase()]){
_4c5.push(Element.extend(_4c6));
}
return _4c5;
});
},getInputs:function(form,_4c8,name){
form=$(form);
var _4ca=form.getElementsByTagName("input");
if(!_4c8&&!name){
return $A(_4ca).map(Element.extend);
}
for(var i=0,_4cc=[],_4cd=_4ca.length;i<_4cd;i++){
var _4ce=_4ca[i];
if((_4c8&&_4ce.type!=_4c8)||(name&&_4ce.name!=name)){
continue;
}
_4cc.push(Element.extend(_4ce));
}
return _4cc;
},disable:function(form){
form=$(form);
form.getElements().each(function(_4d0){
_4d0.blur();
_4d0.disabled="true";
});
return form;
},enable:function(form){
form=$(form);
form.getElements().each(function(_4d2){
_4d2.disabled="";
});
return form;
},findFirstElement:function(form){
return $(form).getElements().find(function(_4d4){
return _4d4.type!="hidden"&&!_4d4.disabled&&["input","select","textarea"].include(_4d4.tagName.toLowerCase());
});
},focusFirstElement:function(form){
form=$(form);
form.findFirstElement().activate();
return form;
}};
Object.extend(Form,Form.Methods);
Form.Element={focus:function(_4d6){
$(_4d6).focus();
return _4d6;
},select:function(_4d7){
$(_4d7).select();
return _4d7;
}};
Form.Element.Methods={serialize:function(_4d8){
_4d8=$(_4d8);
if(!_4d8.disabled&&_4d8.name){
var _4d9=_4d8.getValue();
if(_4d9!=undefined){
var pair={};
pair[_4d8.name]=_4d9;
return Hash.toQueryString(pair);
}
}
return "";
},getValue:function(_4db){
_4db=$(_4db);
var _4dc=_4db.tagName.toLowerCase();
return Form.Element.Serializers[_4dc](_4db);
},clear:function(_4dd){
$(_4dd).value="";
return _4dd;
},present:function(_4de){
return $(_4de).value!="";
},activate:function(_4df){
_4df=$(_4df);
_4df.focus();
if(_4df.select&&(_4df.tagName.toLowerCase()!="input"||!["button","reset","submit"].include(_4df.type))){
_4df.select();
}
return _4df;
},disable:function(_4e0){
_4e0=$(_4e0);
_4e0.disabled=true;
return _4e0;
},enable:function(_4e1){
_4e1=$(_4e1);
_4e1.blur();
_4e1.disabled=false;
return _4e1;
}};
Object.extend(Form.Element,Form.Element.Methods);
var Field=Form.Element;
var $F=Form.Element.getValue;
Form.Element.Serializers={input:function(_4e2){
switch(_4e2.type.toLowerCase()){
case "checkbox":
case "radio":
return Form.Element.Serializers.inputSelector(_4e2);
default:
return Form.Element.Serializers.textarea(_4e2);
}
},inputSelector:function(_4e3){
return _4e3.checked?_4e3.value:null;
},textarea:function(_4e4){
return _4e4.value;
},select:function(_4e5){
return this[_4e5.type=="select-one"?"selectOne":"selectMany"](_4e5);
},selectOne:function(_4e6){
var _4e7=_4e6.selectedIndex;
return _4e7>=0?this.optionValue(_4e6.options[_4e7]):null;
},selectMany:function(_4e8){
var _4e9,_4ea=_4e8.length;
if(!_4ea){
return null;
}
for(var i=0,_4e9=[];i<_4ea;i++){
var opt=_4e8.options[i];
if(opt.selected){
_4e9.push(this.optionValue(opt));
}
}
return _4e9;
},optionValue:function(opt){
return Element.extend(opt).hasAttribute("value")?opt.value:opt.text;
}};
Abstract.TimedObserver=function(){
};
Abstract.TimedObserver.prototype={initialize:function(_4ee,_4ef,_4f0){
this.frequency=_4ef;
this.element=$(_4ee);
this.callback=_4f0;
this.lastValue=this.getValue();
this.registerCallback();
},registerCallback:function(){
setInterval(this.onTimerEvent.bind(this),this.frequency*1000);
},onTimerEvent:function(){
var _4f1=this.getValue();
var _4f2=("string"==typeof this.lastValue&&"string"==typeof _4f1?this.lastValue!=_4f1:String(this.lastValue)!=String(_4f1));
if(_4f2){
this.callback(this.element,_4f1);
this.lastValue=_4f1;
}
}};
Form.Element.Observer=Class.create();
Form.Element.Observer.prototype=Object.extend(new Abstract.TimedObserver(),{getValue:function(){
return Form.Element.getValue(this.element);
}});
Form.Observer=Class.create();
Form.Observer.prototype=Object.extend(new Abstract.TimedObserver(),{getValue:function(){
return Form.serialize(this.element);
}});
Abstract.EventObserver=function(){
};
Abstract.EventObserver.prototype={initialize:function(_4f3,_4f4){
this.element=$(_4f3);
this.callback=_4f4;
this.lastValue=this.getValue();
if(this.element.tagName.toLowerCase()=="form"){
this.registerFormCallbacks();
}else{
this.registerCallback(this.element);
}
},onElementEvent:function(){
var _4f5=this.getValue();
if(this.lastValue!=_4f5){
this.callback(this.element,_4f5);
this.lastValue=_4f5;
}
},registerFormCallbacks:function(){
Form.getElements(this.element).each(this.registerCallback.bind(this));
},registerCallback:function(_4f6){
if(_4f6.type){
switch(_4f6.type.toLowerCase()){
case "checkbox":
case "radio":
Event.observe(_4f6,"click",this.onElementEvent.bind(this));
break;
default:
Event.observe(_4f6,"change",this.onElementEvent.bind(this));
break;
}
}
}};
Form.Element.EventObserver=Class.create();
Form.Element.EventObserver.prototype=Object.extend(new Abstract.EventObserver(),{getValue:function(){
return Form.Element.getValue(this.element);
}});
Form.EventObserver=Class.create();
Form.EventObserver.prototype=Object.extend(new Abstract.EventObserver(),{getValue:function(){
return Form.serialize(this.element);
}});
if(!window.Event){
var Event=new Object();
}
Object.extend(Event,{KEY_BACKSPACE:8,KEY_TAB:9,KEY_RETURN:13,KEY_ESC:27,KEY_LEFT:37,KEY_UP:38,KEY_RIGHT:39,KEY_DOWN:40,KEY_DELETE:46,KEY_HOME:36,KEY_END:35,KEY_PAGEUP:33,KEY_PAGEDOWN:34,element:function(_4f7){
return _4f7.target||_4f7.srcElement;
},isLeftClick:function(_4f8){
return (((_4f8.which)&&(_4f8.which==1))||((_4f8.button)&&(_4f8.button==1)));
},pointerX:function(_4f9){
return _4f9.pageX||(_4f9.clientX+(document.documentElement.scrollLeft||document.body.scrollLeft));
},pointerY:function(_4fa){
return _4fa.pageY||(_4fa.clientY+(document.documentElement.scrollTop||document.body.scrollTop));
},stop:function(_4fb){
if(_4fb.preventDefault){
_4fb.preventDefault();
_4fb.stopPropagation();
}else{
_4fb.returnValue=false;
_4fb.cancelBubble=true;
}
},findElement:function(_4fc,_4fd){
var _4fe=Event.element(_4fc);
while(_4fe.parentNode&&(!_4fe.tagName||(_4fe.tagName.toUpperCase()!=_4fd.toUpperCase()))){
_4fe=_4fe.parentNode;
}
return _4fe;
},observers:false,_observeAndCache:function(_4ff,name,_501,_502){
if(!this.observers){
this.observers=[];
}
if(_4ff.addEventListener){
this.observers.push([_4ff,name,_501,_502]);
_4ff.addEventListener(name,_501,_502);
}else{
if(_4ff.attachEvent){
this.observers.push([_4ff,name,_501,_502]);
_4ff.attachEvent("on"+name,_501);
}
}
},unloadCache:function(){
if(!Event.observers){
return;
}
for(var i=0,_504=Event.observers.length;i<_504;i++){
Event.stopObserving.apply(this,Event.observers[i]);
Event.observers[i][0]=null;
}
Event.observers=false;
},observe:function(_505,name,_507,_508){
_505=$(_505);
_508=_508||false;
if(name=="keypress"&&(navigator.appVersion.match(/Konqueror|Safari|KHTML/)||_505.attachEvent)){
name="keydown";
}
Event._observeAndCache(_505,name,_507,_508);
},stopObserving:function(_509,name,_50b,_50c){
_509=$(_509);
_50c=_50c||false;
if(name=="keypress"&&(navigator.appVersion.match(/Konqueror|Safari|KHTML/)||_509.detachEvent)){
name="keydown";
}
if(_509.removeEventListener){
_509.removeEventListener(name,_50b,_50c);
}else{
if(_509.detachEvent){
try{
_509.detachEvent("on"+name,_50b);
}
catch(e){
}
}
}
}});
if(navigator.appVersion.match(/\bMSIE\b/)){
Event.observe(window,"unload",Event.unloadCache,false);
}
var Position={includeScrollOffsets:false,prepare:function(){
this.deltaX=window.pageXOffset||document.documentElement.scrollLeft||document.body.scrollLeft||0;
this.deltaY=window.pageYOffset||document.documentElement.scrollTop||document.body.scrollTop||0;
},realOffset:function(_50d){
var _50e=0,_50f=0;
do{
_50e+=_50d.scrollTop||0;
_50f+=_50d.scrollLeft||0;
_50d=_50d.parentNode;
}while(_50d);
return [_50f,_50e];
},cumulativeOffset:function(_510){
var _511=0,_512=0;
do{
_511+=_510.offsetTop||0;
_512+=_510.offsetLeft||0;
_510=_510.offsetParent;
}while(_510);
return [_512,_511];
},positionedOffset:function(_513){
var _514=0,_515=0;
do{
_514+=_513.offsetTop||0;
_515+=_513.offsetLeft||0;
_513=_513.offsetParent;
if(_513){
if(_513.tagName=="BODY"){
break;
}
var p=Element.getStyle(_513,"position");
if(p=="relative"||p=="absolute"){
break;
}
}
}while(_513);
return [_515,_514];
},offsetParent:function(_517){
if(_517.offsetParent){
return _517.offsetParent;
}
if(_517==document.body){
return _517;
}
while((_517=_517.parentNode)&&_517!=document.body){
if(Element.getStyle(_517,"position")!="static"){
return _517;
}
}
return document.body;
},within:function(_518,x,y){
if(this.includeScrollOffsets){
return this.withinIncludingScrolloffsets(_518,x,y);
}
this.xcomp=x;
this.ycomp=y;
this.offset=this.cumulativeOffset(_518);
return (y>=this.offset[1]&&y<this.offset[1]+_518.offsetHeight&&x>=this.offset[0]&&x<this.offset[0]+_518.offsetWidth);
},withinIncludingScrolloffsets:function(_51b,x,y){
var _51e=this.realOffset(_51b);
this.xcomp=x+_51e[0]-this.deltaX;
this.ycomp=y+_51e[1]-this.deltaY;
this.offset=this.cumulativeOffset(_51b);
return (this.ycomp>=this.offset[1]&&this.ycomp<this.offset[1]+_51b.offsetHeight&&this.xcomp>=this.offset[0]&&this.xcomp<this.offset[0]+_51b.offsetWidth);
},overlap:function(mode,_520){
if(!mode){
return 0;
}
if(mode=="vertical"){
return ((this.offset[1]+_520.offsetHeight)-this.ycomp)/_520.offsetHeight;
}
if(mode=="horizontal"){
return ((this.offset[0]+_520.offsetWidth)-this.xcomp)/_520.offsetWidth;
}
},page:function(_521){
var _522=0,_523=0;
var _524=_521;
do{
_522+=_524.offsetTop||0;
_523+=_524.offsetLeft||0;
if(_524.offsetParent==document.body){
if(Element.getStyle(_524,"position")=="absolute"){
break;
}
}
}while(_524=_524.offsetParent);
_524=_521;
do{
if(!window.opera||_524.tagName=="BODY"){
_522-=_524.scrollTop||0;
_523-=_524.scrollLeft||0;
}
}while(_524=_524.parentNode);
return [_523,_522];
},clone:function(_525,_526){
var _527=Object.extend({setLeft:true,setTop:true,setWidth:true,setHeight:true,offsetTop:0,offsetLeft:0},arguments[2]||{});
_525=$(_525);
var p=Position.page(_525);
_526=$(_526);
var _529=[0,0];
var _52a=null;
if(Element.getStyle(_526,"position")=="absolute"){
_52a=Position.offsetParent(_526);
_529=Position.page(_52a);
}
if(_52a==document.body){
_529[0]-=document.body.offsetLeft;
_529[1]-=document.body.offsetTop;
}
if(_527.setLeft){
_526.style.left=(p[0]-_529[0]+_527.offsetLeft)+"px";
}
if(_527.setTop){
_526.style.top=(p[1]-_529[1]+_527.offsetTop)+"px";
}
if(_527.setWidth){
_526.style.width=_525.offsetWidth+"px";
}
if(_527.setHeight){
_526.style.height=_525.offsetHeight+"px";
}
},absolutize:function(_52b){
_52b=$(_52b);
if(_52b.style.position=="absolute"){
return;
}
Position.prepare();
var _52c=Position.positionedOffset(_52b);
var top=_52c[1];
var left=_52c[0];
var _52f=_52b.clientWidth;
var _530=_52b.clientHeight;
_52b._originalLeft=left-parseFloat(_52b.style.left||0);
_52b._originalTop=top-parseFloat(_52b.style.top||0);
_52b._originalWidth=_52b.style.width;
_52b._originalHeight=_52b.style.height;
_52b.style.position="absolute";
_52b.style.top=top+"px";
_52b.style.left=left+"px";
_52b.style.width=_52f+"px";
_52b.style.height=_530+"px";
},relativize:function(_531){
_531=$(_531);
if(_531.style.position=="relative"){
return;
}
Position.prepare();
_531.style.position="relative";
var top=parseFloat(_531.style.top||0)-(_531._originalTop||0);
var left=parseFloat(_531.style.left||0)-(_531._originalLeft||0);
_531.style.top=top+"px";
_531.style.left=left+"px";
_531.style.height=_531._originalHeight;
_531.style.width=_531._originalWidth;
}};
if(/Konqueror|Safari|KHTML/.test(navigator.userAgent)){
Position.cumulativeOffset=function(_534){
var _535=0,_536=0;
do{
_535+=_534.offsetTop||0;
_536+=_534.offsetLeft||0;
if(_534.offsetParent==document.body){
if(Element.getStyle(_534,"position")=="absolute"){
break;
}
}
_534=_534.offsetParent;
}while(_534);
return [_536,_535];
};
}
Element.addMethods();
String.prototype.parseColor=function(){
var _537="#";
if(this.slice(0,4)=="rgb("){
var cols=this.slice(4,this.length-1).split(",");
var i=0;
do{
_537+=parseInt(cols[i]).toColorPart();
}while(++i<3);
}else{
if(this.slice(0,1)=="#"){
if(this.length==4){
for(var i=1;i<4;i++){
_537+=(this.charAt(i)+this.charAt(i)).toLowerCase();
}
}
if(this.length==7){
_537=this.toLowerCase();
}
}
}
return (_537.length==7?_537:(arguments[0]||this));
};
Element.collectTextNodes=function(_53a){
return $A($(_53a).childNodes).collect(function(node){
return (node.nodeType==3?node.nodeValue:(node.hasChildNodes()?Element.collectTextNodes(node):""));
}).flatten().join("");
};
Element.collectTextNodesIgnoreClass=function(_53c,_53d){
return $A($(_53c).childNodes).collect(function(node){
return (node.nodeType==3?node.nodeValue:((node.hasChildNodes()&&!Element.hasClassName(node,_53d))?Element.collectTextNodesIgnoreClass(node,_53d):""));
}).flatten().join("");
};
Element.setContentZoom=function(_53f,_540){
_53f=$(_53f);
_53f.setStyle({fontSize:(_540/100)+"em"});
if(navigator.appVersion.indexOf("AppleWebKit")>0){
window.scrollBy(0,0);
}
return _53f;
};
Element.getOpacity=function(_541){
_541=$(_541);
var _542;
if(_542=_541.getStyle("opacity")){
return parseFloat(_542);
}
if(_542=(_541.getStyle("filter")||"").match(/alpha\(opacity=(.*)\)/)){
if(_542[1]){
return parseFloat(_542[1])/100;
}
}
return 1;
};
Element.setOpacity=function(_543,_544){
_543=$(_543);
if(_544==1){
_543.setStyle({opacity:(/Gecko/.test(navigator.userAgent)&&!/Konqueror|Safari|KHTML/.test(navigator.userAgent))?0.999999:1});
if(/MSIE/.test(navigator.userAgent)&&!window.opera){
_543.setStyle({filter:Element.getStyle(_543,"filter").replace(/alpha\([^\)]*\)/gi,"")});
}
}else{
if(_544<0.00001){
_544=0;
}
_543.setStyle({opacity:_544});
if(/MSIE/.test(navigator.userAgent)&&!window.opera){
_543.setStyle({filter:_543.getStyle("filter").replace(/alpha\([^\)]*\)/gi,"")+"alpha(opacity="+_544*100+")"});
}
}
return _543;
};
Element.getInlineOpacity=function(_545){
return $(_545).style.opacity||"";
};
Element.forceRerendering=function(_546){
try{
_546=$(_546);
var n=document.createTextNode(" ");
_546.appendChild(n);
_546.removeChild(n);
}
catch(e){
}
};
Array.prototype.call=function(){
var args=arguments;
this.each(function(f){
f.apply(this,args);
});
};
var Effect={_elementDoesNotExistError:{name:"ElementDoesNotExistError",message:"The specified DOM element does not exist, but is required for this effect to operate"},tagifyText:function(_54a){
if(typeof Builder=="undefined"){
throw ("Effect.tagifyText requires including script.aculo.us' builder.js library");
}
var _54b="position:relative";
if(/MSIE/.test(navigator.userAgent)&&!window.opera){
_54b+=";zoom:1";
}
_54a=$(_54a);
$A(_54a.childNodes).each(function(_54c){
if(_54c.nodeType==3){
_54c.nodeValue.toArray().each(function(_54d){
_54a.insertBefore(Builder.node("span",{style:_54b},_54d==" "?String.fromCharCode(160):_54d),_54c);
});
Element.remove(_54c);
}
});
},multiple:function(_54e,_54f){
var _550;
if(((typeof _54e=="object")||(typeof _54e=="function"))&&(_54e.length)){
_550=_54e;
}else{
_550=$(_54e).childNodes;
}
var _551=Object.extend({speed:0.1,delay:0},arguments[2]||{});
var _552=_551.delay;
$A(_550).each(function(_553,_554){
new _54f(_553,Object.extend(_551,{delay:_554*_551.speed+_552}));
});
},PAIRS:{"slide":["SlideDown","SlideUp"],"blind":["BlindDown","BlindUp"],"appear":["Appear","Fade"]},toggle:function(_555,_556){
_555=$(_555);
_556=(_556||"appear").toLowerCase();
var _557=Object.extend({queue:{position:"end",scope:(_555.id||"global"),limit:1}},arguments[2]||{});
Effect[_555.visible()?Effect.PAIRS[_556][1]:Effect.PAIRS[_556][0]](_555,_557);
}};
var Effect2=Effect;
Effect.Transitions={linear:Prototype.K,sinoidal:function(pos){
return (-Math.cos(pos*Math.PI)/2)+0.5;
},reverse:function(pos){
return 1-pos;
},flicker:function(pos){
return ((-Math.cos(pos*Math.PI)/4)+0.75)+Math.random()/4;
},wobble:function(pos){
return (-Math.cos(pos*Math.PI*(9*pos))/2)+0.5;
},pulse:function(pos,_55d){
_55d=_55d||5;
return (Math.round((pos%(1/_55d))*_55d)==0?((pos*_55d*2)-Math.floor(pos*_55d*2)):1-((pos*_55d*2)-Math.floor(pos*_55d*2)));
},none:function(pos){
return 0;
},full:function(pos){
return 1;
}};
Effect.ScopedQueue=Class.create();
Object.extend(Object.extend(Effect.ScopedQueue.prototype,Enumerable),{initialize:function(){
this.effects=[];
this.interval=null;
},_each:function(_560){
this.effects._each(_560);
},add:function(_561){
var _562=new Date().getTime();
var _563=(typeof _561.options.queue=="string")?_561.options.queue:_561.options.queue.position;
switch(_563){
case "front":
this.effects.findAll(function(e){
return e.state=="idle";
}).each(function(e){
e.startOn+=_561.finishOn;
e.finishOn+=_561.finishOn;
});
break;
case "with-last":
_562=this.effects.pluck("startOn").max()||_562;
break;
case "end":
_562=this.effects.pluck("finishOn").max()||_562;
break;
}
_561.startOn+=_562;
_561.finishOn+=_562;
if(!_561.options.queue.limit||(this.effects.length<_561.options.queue.limit)){
this.effects.push(_561);
}
if(!this.interval){
this.interval=setInterval(this.loop.bind(this),40);
}
},remove:function(_566){
this.effects=this.effects.reject(function(e){
return e==_566;
});
if(this.effects.length==0){
clearInterval(this.interval);
this.interval=null;
}
},loop:function(){
var _568=new Date().getTime();
this.effects.invoke("loop",_568);
}});
Effect.Queues={instances:$H(),get:function(_569){
if(typeof _569!="string"){
return _569;
}
if(!this.instances[_569]){
this.instances[_569]=new Effect.ScopedQueue();
}
return this.instances[_569];
}};
Effect.Queue=Effect.Queues.get("global");
Effect.DefaultOptions={transition:Effect.Transitions.sinoidal,duration:1,fps:25,sync:false,from:0,to:1,delay:0,queue:"parallel"};
Effect.Base=function(){
};
Effect.Base.prototype={position:null,start:function(_56a){
this.options=Object.extend(Object.extend({},Effect.DefaultOptions),_56a||{});
this.currentFrame=0;
this.state="idle";
this.startOn=this.options.delay*1000;
this.finishOn=this.startOn+(this.options.duration*1000);
this.event("beforeStart");
if(!this.options.sync){
Effect.Queues.get(typeof this.options.queue=="string"?"global":this.options.queue.scope).add(this);
}
},loop:function(_56b){
if(_56b>=this.startOn){
if(_56b>=this.finishOn){
this.render(1);
this.cancel();
this.event("beforeFinish");
if(this.finish){
this.finish();
}
this.event("afterFinish");
return;
}
var pos=(_56b-this.startOn)/(this.finishOn-this.startOn);
var _56d=Math.round(pos*this.options.fps*this.options.duration);
if(_56d>this.currentFrame){
this.render(pos);
this.currentFrame=_56d;
}
}
},render:function(pos){
if(this.state=="idle"){
this.state="running";
this.event("beforeSetup");
if(this.setup){
this.setup();
}
this.event("afterSetup");
}
if(this.state=="running"){
if(this.options.transition){
pos=this.options.transition(pos);
}
pos*=(this.options.to-this.options.from);
pos+=this.options.from;
this.position=pos;
this.event("beforeUpdate");
if(this.update){
this.update(pos);
}
this.event("afterUpdate");
}
},cancel:function(){
if(!this.options.sync){
Effect.Queues.get(typeof this.options.queue=="string"?"global":this.options.queue.scope).remove(this);
}
this.state="finished";
},event:function(_56f){
if(this.options[_56f+"Internal"]){
this.options[_56f+"Internal"](this);
}
if(this.options[_56f]){
this.options[_56f](this);
}
},inspect:function(){
return "#<Effect:"+$H(this).inspect()+",options:"+$H(this.options).inspect()+">";
}};
Effect.Parallel=Class.create();
Object.extend(Object.extend(Effect.Parallel.prototype,Effect.Base.prototype),{initialize:function(_570){
this.effects=_570||[];
this.start(arguments[1]);
},update:function(_571){
this.effects.invoke("render",_571);
},finish:function(_572){
this.effects.each(function(_573){
_573.render(1);
_573.cancel();
_573.event("beforeFinish");
if(_573.finish){
_573.finish(_572);
}
_573.event("afterFinish");
});
}});
Effect.Event=Class.create();
Object.extend(Object.extend(Effect.Event.prototype,Effect.Base.prototype),{initialize:function(){
var _574=Object.extend({duration:0},arguments[0]||{});
this.start(_574);
},update:Prototype.emptyFunction});
Effect.Opacity=Class.create();
Object.extend(Object.extend(Effect.Opacity.prototype,Effect.Base.prototype),{initialize:function(_575){
this.element=$(_575);
if(!this.element){
throw (Effect._elementDoesNotExistError);
}
if(/MSIE/.test(navigator.userAgent)&&!window.opera&&(!this.element.currentStyle.hasLayout)){
this.element.setStyle({zoom:1});
}
var _576=Object.extend({from:this.element.getOpacity()||0,to:1},arguments[1]||{});
this.start(_576);
},update:function(_577){
this.element.setOpacity(_577);
}});
Effect.Move=Class.create();
Object.extend(Object.extend(Effect.Move.prototype,Effect.Base.prototype),{initialize:function(_578){
this.element=$(_578);
if(!this.element){
throw (Effect._elementDoesNotExistError);
}
var _579=Object.extend({x:0,y:0,mode:"relative"},arguments[1]||{});
this.start(_579);
},setup:function(){
this.element.makePositioned();
this.originalLeft=parseFloat(this.element.getStyle("left")||"0");
this.originalTop=parseFloat(this.element.getStyle("top")||"0");
if(this.options.mode=="absolute"){
this.options.x=this.options.x-this.originalLeft;
this.options.y=this.options.y-this.originalTop;
}
},update:function(_57a){
this.element.setStyle({left:Math.round(this.options.x*_57a+this.originalLeft)+"px",top:Math.round(this.options.y*_57a+this.originalTop)+"px"});
}});
Effect.MoveBy=function(_57b,_57c,_57d){
return new Effect.Move(_57b,Object.extend({x:_57d,y:_57c},arguments[3]||{}));
};
Effect.Scale=Class.create();
Object.extend(Object.extend(Effect.Scale.prototype,Effect.Base.prototype),{initialize:function(_57e,_57f){
this.element=$(_57e);
if(!this.element){
throw (Effect._elementDoesNotExistError);
}
var _580=Object.extend({scaleX:true,scaleY:true,scaleContent:true,scaleFromCenter:false,scaleMode:"box",scaleFrom:100,scaleTo:_57f},arguments[2]||{});
this.start(_580);
},setup:function(){
this.restoreAfterFinish=this.options.restoreAfterFinish||false;
this.elementPositioning=this.element.getStyle("position");
this.originalStyle={};
["top","left","width","height","fontSize"].each(function(k){
this.originalStyle[k]=this.element.style[k];
}.bind(this));
this.originalTop=this.element.offsetTop;
this.originalLeft=this.element.offsetLeft;
var _582=this.element.getStyle("font-size")||"100%";
["em","px","%","pt"].each(function(_583){
if(_582.indexOf(_583)>0){
this.fontSize=parseFloat(_582);
this.fontSizeType=_583;
}
}.bind(this));
this.factor=(this.options.scaleTo-this.options.scaleFrom)/100;
this.dims=null;
if(this.options.scaleMode=="box"){
this.dims=[this.element.offsetHeight,this.element.offsetWidth];
}
if(/^content/.test(this.options.scaleMode)){
this.dims=[this.element.scrollHeight,this.element.scrollWidth];
}
if(!this.dims){
this.dims=[this.options.scaleMode.originalHeight,this.options.scaleMode.originalWidth];
}
},update:function(_584){
var _585=(this.options.scaleFrom/100)+(this.factor*_584);
if(this.options.scaleContent&&this.fontSize){
this.element.setStyle({fontSize:this.fontSize*_585+this.fontSizeType});
}
this.setDimensions(this.dims[0]*_585,this.dims[1]*_585);
},finish:function(_586){
if(this.restoreAfterFinish){
this.element.setStyle(this.originalStyle);
}
},setDimensions:function(_587,_588){
var d={};
if(this.options.scaleX){
d.width=Math.round(_588)+"px";
}
if(this.options.scaleY){
d.height=Math.round(_587)+"px";
}
if(this.options.scaleFromCenter){
var topd=(_587-this.dims[0])/2;
var _58b=(_588-this.dims[1])/2;
if(this.elementPositioning=="absolute"){
if(this.options.scaleY){
d.top=this.originalTop-topd+"px";
}
if(this.options.scaleX){
d.left=this.originalLeft-_58b+"px";
}
}else{
if(this.options.scaleY){
d.top=-topd+"px";
}
if(this.options.scaleX){
d.left=-_58b+"px";
}
}
}
this.element.setStyle(d);
}});
Effect.Highlight=Class.create();
Object.extend(Object.extend(Effect.Highlight.prototype,Effect.Base.prototype),{initialize:function(_58c){
this.element=$(_58c);
if(!this.element){
throw (Effect._elementDoesNotExistError);
}
var _58d=Object.extend({startcolor:"#ffff99"},arguments[1]||{});
this.start(_58d);
},setup:function(){
if(this.element.getStyle("display")=="none"){
this.cancel();
return;
}
this.oldStyle={backgroundImage:this.element.getStyle("background-image")};
this.element.setStyle({backgroundImage:"none"});
if(!this.options.endcolor){
this.options.endcolor=this.element.getStyle("background-color").parseColor("#ffffff");
}
if(!this.options.restorecolor){
this.options.restorecolor=this.element.getStyle("background-color");
}
this._base=$R(0,2).map(function(i){
return parseInt(this.options.startcolor.slice(i*2+1,i*2+3),16);
}.bind(this));
this._delta=$R(0,2).map(function(i){
return parseInt(this.options.endcolor.slice(i*2+1,i*2+3),16)-this._base[i];
}.bind(this));
},update:function(_590){
this.element.setStyle({backgroundColor:$R(0,2).inject("#",function(m,v,i){
return m+(Math.round(this._base[i]+(this._delta[i]*_590)).toColorPart());
}.bind(this))});
},finish:function(){
this.element.setStyle(Object.extend(this.oldStyle,{backgroundColor:this.options.restorecolor}));
}});
Effect.ScrollTo=Class.create();
Object.extend(Object.extend(Effect.ScrollTo.prototype,Effect.Base.prototype),{initialize:function(_594){
this.element=$(_594);
this.start(arguments[1]||{});
},setup:function(){
Position.prepare();
var _595=Position.cumulativeOffset(this.element);
if(this.options.offset){
_595[1]+=this.options.offset;
}
var max=window.innerHeight?window.height-window.innerHeight:document.body.scrollHeight-(document.documentElement.clientHeight?document.documentElement.clientHeight:document.body.clientHeight);
this.scrollStart=Position.deltaY;
this.delta=(_595[1]>max?max:_595[1])-this.scrollStart;
},update:function(_597){
Position.prepare();
window.scrollTo(Position.deltaX,this.scrollStart+(_597*this.delta));
}});
Effect.Fade=function(_598){
_598=$(_598);
var _599=_598.getInlineOpacity();
var _59a=Object.extend({from:_598.getOpacity()||1,to:0,afterFinishInternal:function(_59b){
if(_59b.options.to!=0){
return;
}
_59b.element.hide().setStyle({opacity:_599});
}},arguments[1]||{});
return new Effect.Opacity(_598,_59a);
};
Effect.Appear=function(_59c){
_59c=$(_59c);
var _59d=Object.extend({from:(_59c.getStyle("display")=="none"?0:_59c.getOpacity()||0),to:1,afterFinishInternal:function(_59e){
_59e.element.forceRerendering();
},beforeSetup:function(_59f){
_59f.element.setOpacity(_59f.options.from).show();
}},arguments[1]||{});
return new Effect.Opacity(_59c,_59d);
};
Effect.Puff=function(_5a0){
_5a0=$(_5a0);
var _5a1={opacity:_5a0.getInlineOpacity(),position:_5a0.getStyle("position"),top:_5a0.style.top,left:_5a0.style.left,width:_5a0.style.width,height:_5a0.style.height};
return new Effect.Parallel([new Effect.Scale(_5a0,200,{sync:true,scaleFromCenter:true,scaleContent:true,restoreAfterFinish:true}),new Effect.Opacity(_5a0,{sync:true,to:0})],Object.extend({duration:1,beforeSetupInternal:function(_5a2){
Position.absolutize(_5a2.effects[0].element);
},afterFinishInternal:function(_5a3){
_5a3.effects[0].element.hide().setStyle(_5a1);
}},arguments[1]||{}));
};
Effect.BlindUp=function(_5a4){
_5a4=$(_5a4);
_5a4.makeClipping();
return new Effect.Scale(_5a4,0,Object.extend({scaleContent:false,scaleX:false,restoreAfterFinish:true,afterFinishInternal:function(_5a5){
_5a5.element.hide().undoClipping();
}},arguments[1]||{}));
};
Effect.BlindDown=function(_5a6){
_5a6=$(_5a6);
var _5a7=_5a6.getDimensions();
return new Effect.Scale(_5a6,100,Object.extend({scaleContent:false,scaleX:false,scaleFrom:0,scaleMode:{originalHeight:_5a7.height,originalWidth:_5a7.width},restoreAfterFinish:true,afterSetup:function(_5a8){
_5a8.element.makeClipping().setStyle({height:"0px"}).show();
},afterFinishInternal:function(_5a9){
_5a9.element.undoClipping();
}},arguments[1]||{}));
};
Effect.SwitchOff=function(_5aa){
_5aa=$(_5aa);
var _5ab=_5aa.getInlineOpacity();
return new Effect.Appear(_5aa,Object.extend({duration:0.4,from:0,transition:Effect.Transitions.flicker,afterFinishInternal:function(_5ac){
new Effect.Scale(_5ac.element,1,{duration:0.3,scaleFromCenter:true,scaleX:false,scaleContent:false,restoreAfterFinish:true,beforeSetup:function(_5ad){
_5ad.element.makePositioned().makeClipping();
},afterFinishInternal:function(_5ae){
_5ae.element.hide().undoClipping().undoPositioned().setStyle({opacity:_5ab});
}});
}},arguments[1]||{}));
};
Effect.DropOut=function(_5af){
_5af=$(_5af);
var _5b0={top:_5af.getStyle("top"),left:_5af.getStyle("left"),opacity:_5af.getInlineOpacity()};
return new Effect.Parallel([new Effect.Move(_5af,{x:0,y:100,sync:true}),new Effect.Opacity(_5af,{sync:true,to:0})],Object.extend({duration:0.5,beforeSetup:function(_5b1){
_5b1.effects[0].element.makePositioned();
},afterFinishInternal:function(_5b2){
_5b2.effects[0].element.hide().undoPositioned().setStyle(_5b0);
}},arguments[1]||{}));
};
Effect.Shake=function(_5b3){
_5b3=$(_5b3);
var _5b4={top:_5b3.getStyle("top"),left:_5b3.getStyle("left")};
return new Effect.Move(_5b3,{x:20,y:0,duration:0.05,afterFinishInternal:function(_5b5){
new Effect.Move(_5b5.element,{x:-40,y:0,duration:0.1,afterFinishInternal:function(_5b6){
new Effect.Move(_5b6.element,{x:40,y:0,duration:0.1,afterFinishInternal:function(_5b7){
new Effect.Move(_5b7.element,{x:-40,y:0,duration:0.1,afterFinishInternal:function(_5b8){
new Effect.Move(_5b8.element,{x:40,y:0,duration:0.1,afterFinishInternal:function(_5b9){
new Effect.Move(_5b9.element,{x:-20,y:0,duration:0.05,afterFinishInternal:function(_5ba){
_5ba.element.undoPositioned().setStyle(_5b4);
}});
}});
}});
}});
}});
}});
};
Effect.SlideDown=function(_5bb){
_5bb=$(_5bb).cleanWhitespace();
var _5bc=_5bb.down().getStyle("bottom");
var _5bd=_5bb.getDimensions();
return new Effect.Scale(_5bb,100,Object.extend({scaleContent:false,scaleX:false,scaleFrom:window.opera?0:1,scaleMode:{originalHeight:_5bd.height,originalWidth:_5bd.width},restoreAfterFinish:true,afterSetup:function(_5be){
_5be.element.makePositioned();
_5be.element.down().makePositioned();
if(window.opera){
_5be.element.setStyle({top:""});
}
_5be.element.makeClipping().setStyle({height:"0px"}).show();
},afterUpdateInternal:function(_5bf){
_5bf.element.down().setStyle({bottom:(_5bf.dims[0]-_5bf.element.clientHeight)+"px"});
},afterFinishInternal:function(_5c0){
_5c0.element.undoClipping().undoPositioned();
_5c0.element.down().undoPositioned().setStyle({bottom:_5bc});
}},arguments[1]||{}));
};
Effect.SlideUp=function(_5c1){
_5c1=$(_5c1).cleanWhitespace();
var _5c2=_5c1.down().getStyle("bottom");
return new Effect.Scale(_5c1,window.opera?0:1,Object.extend({scaleContent:false,scaleX:false,scaleMode:"box",scaleFrom:100,restoreAfterFinish:true,beforeStartInternal:function(_5c3){
_5c3.element.makePositioned();
_5c3.element.down().makePositioned();
if(window.opera){
_5c3.element.setStyle({top:""});
}
_5c3.element.makeClipping().show();
},afterUpdateInternal:function(_5c4){
_5c4.element.down().setStyle({bottom:(_5c4.dims[0]-_5c4.element.clientHeight)+"px"});
},afterFinishInternal:function(_5c5){
_5c5.element.hide().undoClipping().undoPositioned().setStyle({bottom:_5c2});
_5c5.element.down().undoPositioned();
}},arguments[1]||{}));
};
Effect.Squish=function(_5c6){
return new Effect.Scale(_5c6,window.opera?1:0,{restoreAfterFinish:true,beforeSetup:function(_5c7){
_5c7.element.makeClipping();
},afterFinishInternal:function(_5c8){
_5c8.element.hide().undoClipping();
}});
};
Effect.Grow=function(_5c9){
_5c9=$(_5c9);
var _5ca=Object.extend({direction:"center",moveTransition:Effect.Transitions.sinoidal,scaleTransition:Effect.Transitions.sinoidal,opacityTransition:Effect.Transitions.full},arguments[1]||{});
var _5cb={top:_5c9.style.top,left:_5c9.style.left,height:_5c9.style.height,width:_5c9.style.width,opacity:_5c9.getInlineOpacity()};
var dims=_5c9.getDimensions();
var _5cd,_5ce;
var _5cf,_5d0;
switch(_5ca.direction){
case "top-left":
_5cd=_5ce=_5cf=_5d0=0;
break;
case "top-right":
_5cd=dims.width;
_5ce=_5d0=0;
_5cf=-dims.width;
break;
case "bottom-left":
_5cd=_5cf=0;
_5ce=dims.height;
_5d0=-dims.height;
break;
case "bottom-right":
_5cd=dims.width;
_5ce=dims.height;
_5cf=-dims.width;
_5d0=-dims.height;
break;
case "center":
_5cd=dims.width/2;
_5ce=dims.height/2;
_5cf=-dims.width/2;
_5d0=-dims.height/2;
break;
}
return new Effect.Move(_5c9,{x:_5cd,y:_5ce,duration:0.01,beforeSetup:function(_5d1){
_5d1.element.hide().makeClipping().makePositioned();
},afterFinishInternal:function(_5d2){
new Effect.Parallel([new Effect.Opacity(_5d2.element,{sync:true,to:1,from:0,transition:_5ca.opacityTransition}),new Effect.Move(_5d2.element,{x:_5cf,y:_5d0,sync:true,transition:_5ca.moveTransition}),new Effect.Scale(_5d2.element,100,{scaleMode:{originalHeight:dims.height,originalWidth:dims.width},sync:true,scaleFrom:window.opera?1:0,transition:_5ca.scaleTransition,restoreAfterFinish:true})],Object.extend({beforeSetup:function(_5d3){
_5d3.effects[0].element.setStyle({height:"0px"}).show();
},afterFinishInternal:function(_5d4){
_5d4.effects[0].element.undoClipping().undoPositioned().setStyle(_5cb);
}},_5ca));
}});
};
Effect.Shrink=function(_5d5){
_5d5=$(_5d5);
var _5d6=Object.extend({direction:"center",moveTransition:Effect.Transitions.sinoidal,scaleTransition:Effect.Transitions.sinoidal,opacityTransition:Effect.Transitions.none},arguments[1]||{});
var _5d7={top:_5d5.style.top,left:_5d5.style.left,height:_5d5.style.height,width:_5d5.style.width,opacity:_5d5.getInlineOpacity()};
var dims=_5d5.getDimensions();
var _5d9,_5da;
switch(_5d6.direction){
case "top-left":
_5d9=_5da=0;
break;
case "top-right":
_5d9=dims.width;
_5da=0;
break;
case "bottom-left":
_5d9=0;
_5da=dims.height;
break;
case "bottom-right":
_5d9=dims.width;
_5da=dims.height;
break;
case "center":
_5d9=dims.width/2;
_5da=dims.height/2;
break;
}
return new Effect.Parallel([new Effect.Opacity(_5d5,{sync:true,to:0,from:1,transition:_5d6.opacityTransition}),new Effect.Scale(_5d5,window.opera?1:0,{sync:true,transition:_5d6.scaleTransition,restoreAfterFinish:true}),new Effect.Move(_5d5,{x:_5d9,y:_5da,sync:true,transition:_5d6.moveTransition})],Object.extend({beforeStartInternal:function(_5db){
_5db.effects[0].element.makePositioned().makeClipping();
},afterFinishInternal:function(_5dc){
_5dc.effects[0].element.hide().undoClipping().undoPositioned().setStyle(_5d7);
}},_5d6));
};
Effect.Pulsate=function(_5dd){
_5dd=$(_5dd);
var _5de=arguments[1]||{};
var _5df=_5dd.getInlineOpacity();
var _5e0=_5de.transition||Effect.Transitions.sinoidal;
var _5e1=function(pos){
return _5e0(1-Effect.Transitions.pulse(pos,_5de.pulses));
};
_5e1.bind(_5e0);
return new Effect.Opacity(_5dd,Object.extend(Object.extend({duration:2,from:0,afterFinishInternal:function(_5e3){
_5e3.element.setStyle({opacity:_5df});
}},_5de),{transition:_5e1}));
};
Effect.Fold=function(_5e4){
_5e4=$(_5e4);
var _5e5={top:_5e4.style.top,left:_5e4.style.left,width:_5e4.style.width,height:_5e4.style.height};
_5e4.makeClipping();
return new Effect.Scale(_5e4,5,Object.extend({scaleContent:false,scaleX:false,afterFinishInternal:function(_5e6){
new Effect.Scale(_5e4,1,{scaleContent:false,scaleY:false,afterFinishInternal:function(_5e7){
_5e7.element.hide().undoClipping().setStyle(_5e5);
}});
}},arguments[1]||{}));
};
Effect.Morph=Class.create();
Object.extend(Object.extend(Effect.Morph.prototype,Effect.Base.prototype),{initialize:function(_5e8){
this.element=$(_5e8);
if(!this.element){
throw (Effect._elementDoesNotExistError);
}
var _5e9=Object.extend({style:""},arguments[1]||{});
this.start(_5e9);
},setup:function(){
function parseColor(_5ea){
if(!_5ea||["rgba(0, 0, 0, 0)","transparent"].include(_5ea)){
_5ea="#ffffff";
}
_5ea=_5ea.parseColor();
return $R(0,2).map(function(i){
return parseInt(_5ea.slice(i*2+1,i*2+3),16);
});
}
this.transforms=this.options.style.parseStyle().map(function(_5ec){
var _5ed=this.element.getStyle(_5ec[0]);
return $H({style:_5ec[0],originalValue:_5ec[1].unit=="color"?parseColor(_5ed):parseFloat(_5ed||0),targetValue:_5ec[1].unit=="color"?parseColor(_5ec[1].value):_5ec[1].value,unit:_5ec[1].unit});
}.bind(this)).reject(function(_5ee){
return ((_5ee.originalValue==_5ee.targetValue)||(_5ee.unit!="color"&&(isNaN(_5ee.originalValue)||isNaN(_5ee.targetValue))));
});
},update:function(_5ef){
var _5f0=$H(),_5f1=null;
this.transforms.each(function(_5f2){
_5f1=_5f2.unit=="color"?$R(0,2).inject("#",function(m,v,i){
return m+(Math.round(_5f2.originalValue[i]+(_5f2.targetValue[i]-_5f2.originalValue[i])*_5ef)).toColorPart();
}):_5f2.originalValue+Math.round(((_5f2.targetValue-_5f2.originalValue)*_5ef)*1000)/1000+_5f2.unit;
_5f0[_5f2.style]=_5f1;
});
this.element.setStyle(_5f0);
}});
Effect.Transform=Class.create();
Object.extend(Effect.Transform.prototype,{initialize:function(_5f6){
this.tracks=[];
this.options=arguments[1]||{};
this.addTracks(_5f6);
},addTracks:function(_5f7){
_5f7.each(function(_5f8){
var data=$H(_5f8).values().first();
this.tracks.push($H({ids:$H(_5f8).keys().first(),effect:Effect.Morph,options:{style:data}}));
}.bind(this));
return this;
},play:function(){
return new Effect.Parallel(this.tracks.map(function(_5fa){
var _5fb=[$(_5fa.ids)||$$(_5fa.ids)].flatten();
return _5fb.map(function(e){
return new _5fa.effect(e,Object.extend({sync:true},_5fa.options));
});
}).flatten(),this.options);
}});
Element.CSS_PROPERTIES=["azimuth","backgroundAttachment","backgroundColor","backgroundImage","backgroundPosition","backgroundRepeat","borderBottomColor","borderBottomStyle","borderBottomWidth","borderCollapse","borderLeftColor","borderLeftStyle","borderLeftWidth","borderRightColor","borderRightStyle","borderRightWidth","borderSpacing","borderTopColor","borderTopStyle","borderTopWidth","bottom","captionSide","clear","clip","color","content","counterIncrement","counterReset","cssFloat","cueAfter","cueBefore","cursor","direction","display","elevation","emptyCells","fontFamily","fontSize","fontSizeAdjust","fontStretch","fontStyle","fontVariant","fontWeight","height","left","letterSpacing","lineHeight","listStyleImage","listStylePosition","listStyleType","marginBottom","marginLeft","marginRight","marginTop","markerOffset","marks","maxHeight","maxWidth","minHeight","minWidth","opacity","orphans","outlineColor","outlineOffset","outlineStyle","outlineWidth","overflowX","overflowY","paddingBottom","paddingLeft","paddingRight","paddingTop","page","pageBreakAfter","pageBreakBefore","pageBreakInside","pauseAfter","pauseBefore","pitch","pitchRange","position","quotes","richness","right","size","speakHeader","speakNumeral","speakPunctuation","speechRate","stress","tableLayout","textAlign","textDecoration","textIndent","textShadow","textTransform","top","unicodeBidi","verticalAlign","visibility","voiceFamily","volume","whiteSpace","widows","width","wordSpacing","zIndex"];
Element.CSS_LENGTH=/^(([\+\-]?[0-9\.]+)(em|ex|px|in|cm|mm|pt|pc|\%))|0$/;
String.prototype.parseStyle=function(){
var _5fd=Element.extend(document.createElement("div"));
_5fd.innerHTML="<div style=\""+this+"\"></div>";
var _5fe=_5fd.down().style,_5ff=$H();
Element.CSS_PROPERTIES.each(function(_600){
if(_5fe[_600]){
_5ff[_600]=_5fe[_600];
}
});
var _601=$H();
_5ff.each(function(pair){
var _603=pair[0],_604=pair[1],unit=null;
if(_604.parseColor("#zzzzzz")!="#zzzzzz"){
_604=_604.parseColor();
unit="color";
}else{
if(Element.CSS_LENGTH.test(_604)){
var _606=_604.match(/^([\+\-]?[0-9\.]+)(.*)$/),_604=parseFloat(_606[1]),unit=(_606.length==3)?_606[2]:null;
}
}
_601[_603.underscore().dasherize()]=$H({value:_604,unit:unit});
}.bind(this));
return _601;
};
Element.morph=function(_607,_608){
new Effect.Morph(_607,Object.extend({style:_608},arguments[2]||{}));
return _607;
};
["setOpacity","getOpacity","getInlineOpacity","forceRerendering","setContentZoom","collectTextNodes","collectTextNodesIgnoreClass","morph"].each(function(f){
Element.Methods[f]=Element[f];
});
Element.Methods.visualEffect=function(_60a,_60b,_60c){
s=_60b.gsub(/_/,"-").camelize();
effect_class=s.charAt(0).toUpperCase()+s.substring(1);
new Effect[effect_class](_60a,_60c);
return $(_60a);
};
Element.addMethods();
Wagn=new Object();
function warn(_60d){
if(typeof (console)!="undefined"){
console.log(_60d);
}
}
Wagn.CardTable=$H({});
Object.extend(Wagn.CardTable,{get:function(key){
return this[key];
}});
Wagn.Dummy=Class.create();
Wagn.Dummy.prototype={initialize:function(num){
this.number=num;
}};
var Cookie={set:function(name,_611,_612){
var _613="";
if(_612!=undefined){
var d=new Date();
d.setTime(d.getTime()+(86400000*parseFloat(_612)));
_613="; expires="+d.toGMTString();
}
return (document.cookie=escape(name)+"="+escape(_611||"")+_613);
},get:function(name){
var _616=document.cookie.match(new RegExp("(^|;)\\s*"+escape(name)+"=([^;\\s]*)"));
return (_616?unescape(_616[2]):null);
},erase:function(name){
var _618=Cookie.get(name)||true;
Cookie.set(name,"",-1);
return _618;
},accept:function(){
if(typeof navigator.cookieEnabled=="boolean"){
return navigator.cookieEnabled;
}
Cookie.set("_test","1");
return (Cookie.erase("_test")==="1");
}};
Wagn.Messenger={element:function(){
return $("alerts");
},alert:function(_619){
this.element().innerHTML="<span style=\"color:red font-weight: bold\">"+_619+"</span>";
new Effect.Highlight(this.element(),{startcolor:"#ffff00",endcolor:"#ffffaa",restorecolor:"#ffffaa",duration:1});
},note:function(_61a){
this.element().innerHTML=_61a;
new Effect.Highlight(this.element(),{startcolor:"#ffff00",endcolor:"#ffffaa",restorecolor:"#ffffaa",duration:1});
},log:function(_61b){
this.element().innerHTML=_61b;
new Effect.Highlight(this.element(),{startcolor:"#dddddd",endcolor:"#ffffaa",restorecolor:"#ffffaa",duration:1});
},flash:function(){
flash=$("notice").innerHTML+$("error").innerHTML;
if(flash!=""){
this.alert(flash);
}
}};
function openInNewWindow(){
var _61c=window.open(this.getAttribute("href"),"_blank");
_61c.focus();
return false;
}
function getNewWindowLinks(){
if(document.getElementById&&document.createElement&&document.appendChild){
var link;
var _61e=document.getElementsByTagName("a");
for(var i=0;i<_61e.length;i++){
link=_61e[i];
if(/\bexternal\b/.exec(link.className)){
link.onclick=openInNewWindow;
}
}
objWarningText=null;
}
}
var tt_db=(document.compatMode&&document.compatMode!="BackCompat")?document.documentElement:document.body?document.body:null,tt_n=navigator.userAgent.toLowerCase();
var tt_op=!!(window.opera&&document.getElementById),tt_op6=tt_op&&!document.defaultView,tt_ie=tt_n.indexOf("msie")!=-1&&document.all&&tt_db&&!tt_op,tt_n4=(document.layers&&typeof document.classes!="undefined"),tt_n6=(!tt_op&&document.defaultView&&typeof document.defaultView.getComputedStyle!="undefined"),tt_w3c=!tt_ie&&!tt_n6&&!tt_op&&document.getElementById;
tt_n="";
var DEBUGGING=false;
function copy_with_classes(_620){
copy=document.createElement("span");
copy.innerHTML=_620.innerHTML;
Element.classNames(_620).each(function(_621){
Element.addClassName(copy,_621);
});
copy.hide();
_620.parentNode.insertBefore(copy,_620);
return copy;
}
Object.extend(Wagn,{user:function(){
return $("user");
},card:function(){
return Wagn.Card;
},lister:function(){
return Wagn._lister;
},messenger:function(){
return Wagn.Messenger;
},cardTable:function(){
return Wagn.CardTable;
},title_mouseover:function(_622){
document.getElementsByClassName(_622).each(function(elem){
Element.addClassName(elem,"card-highlight");
Element.removeClassName(elem,"card");
});
},title_mouseout:function(_624){
document.getElementsByClassName(_624).each(function(elem){
Element.removeClassName(elem,"card-highlight");
Element.addClassName(elem,"card");
});
},line_to_paragraph:function(_626){
if(tt_n6){
var _627=_626.getDimensions();
copy=copy_with_classes(_626);
copy.removeClassName("line");
copy.addClassName("paragraph");
var _628=copy.getDimensions();
copy.viewHeight=_628.height;
copy.remove();
var _629=100*_627.height/_628.height;
var _62a=_628;
new Effect.BlindDown(_626,{duration:0.5,scaleFrom:_629,scaleMode:{originalHeight:_62a.height,originalWidth:_62a.width},afterSetup:function(_62b){
_62b.element.makeClipping();
_62b.element.setStyle({height:"0px"});
_62b.element.show();
_62b.element.removeClassName("line");
_62b.element.addClassName("paragraph");
}});
}else{
Element.removeClassName(_626,"line");
Element.addClassName(_626,"paragraph");
}
},paragraph_to_line:function(_62c){
if(tt_n6){
var _62d=_62c.getDimensions();
copy=copy_with_classes(_62c);
copy.removeClassName("paragraph");
copy.addClassName("line");
var _62e=copy.getDimensions();
copy.remove();
var _62f=100*_62e.height/_62d.height;
return new Effect.Scale(_62c,_62f,{duration:0.5,scaleContent:false,scaleX:false,scaleFrom:100,scaleMode:{originalHeight:_62d.height,originalWidth:_62d.width},restoreAfterFinish:true,afterSetup:function(_630){
_630.element.makeClipping();
_630.element.setStyle({height:"0px"});
_630.element.show();
},afterFinishInternal:function(_631){
_631.element.undoClipping();
_631.element.removeClassName("paragraph");
_631.element.addClassName("line");
}});
}else{
Element.removeClassName(_62c,"paragraph");
Element.addClassName(_62c,"line");
}
}});
Wagn.highlight=function(_632,id){
document.getElementsByClassName(_632).each(function(elem){
Element.removeClassName(elem.id,"current");
});
Element.addClassName(_632+"-"+id,"current");
};
Wagn.OnLoad=new Object;
Wagn.OnLoad.Queue=$A([]);
Object.extend(Wagn.OnLoad.Queue,{run:function(){
this.each(function(item){
item.fn.call();
});
}});
Wagn.OnLoad.Item=Class.create();
Wagn.OnLoad.Item.prototype={initialize:function(fn){
this.fn=fn;
Wagn.OnLoad.Queue.push(this);
}};
onload=function(){
Wagn.Card.setupAll();
Wagn.Messenger.flash();
setTimeout("Wagn.OnLoad.Queue.run()",100);
if(typeof (init_lister)!="undefined"){
Wagn._lister=init_lister();
Wagn._lister.update();
}
};
Wagn.CardSlot={init:function(_637){
return Object.extend($(_637),Wagn.CardSlot.prototype);
},find_all_by_class:function(_638){
if(_638=="all"){
_638="card-slot";
}
return document.getElementsByClassName(_638).collect(function(e){
return Wagn.CardSlot.init(e);
});
}};
Wagn.CardSlot.prototype={chunk:function(name){
return document.getElementsByClassName(name,this)[0];
},card:function(){
return Wagn.CardTable[this.id];
}};
Wagn.Card=Class.create();
Object.extend(Wagn.Card.prototype,{initialize:function(slot){
this.slot=Wagn.CardSlot.init(slot);
this.workspace=this.slot.chunk("workspace");
this.login_url=document.location.href.gsub("^(.*//[^/]+)/.*$","#{1}/account/login");
this._in_wadget=arguments[1];
this._editor_loaded=false;
this._viewmode="view";
if(!this._in_wadget){
this.setupDoubleClickToEdit();
if(Element.hasClassName(this.slot,"new-card")){
warn("setting up new card");
this.setupEditor();
}else{
if(Element.hasClassName(this.slot,"full")){
warn("about to load editor");
this.loadEditor();
}
}
}
Wagn.CardTable[slot.id]=this;
},loadEditor:function(){
if(this._in_wadget){
warn("bailing cuzof wadget");
return true;
}
force_reload=arguments[0];
edit_on_load=arguments[1];
warn("loading Editor");
if(force_reload){
this._editor_loaded=false;
}
if(this._editor_loaded){
if(edit_on_load){
this.edit();
}
return true;
}
var self=this;
on_complete=(edit_on_load=arguments[1])?function(_63d){
self.slowEdit();
}:function(_63e){
self.setupEditor();
};
url=this.id()?"/card/editor/"+this.id():"/card/new";
new Ajax.Updater(this.slot.id+"-editor",url,{parameters:this._common_parameters(),onComplete:on_complete});
this._editor_loaded=true;
},setupEditor:function(){
if(this.is_edit_ok()){
var _63f="new Wagn.Editor."+this.editor_type()+"(this)";
warn(this.slot.id+": "+_63f);
this.editor=eval(_63f);
}else{
if(this.slot.chunk("edit")){
this.slot.chunk("edit").onClick="";
if(!Wagn.user()){
this.slot.chunk("edit").href=this.login_url;
}else{
this.slot.chunk("edit").href="#";
this.slot.chunk("edit").innerHTML="<em>locked</em>";
}
}
}
},slowEdit:function(){
this.setupEditor();
setTimeout("Wagn.CardTable[\""+this.slot.id+"\"].edit()",250);
},is_new:function(){
return this.slot.chunk("new");
},is_edit_ok:function(){
return this.slot.chunk("edit-ok");
},is_connection:function(){
return this.slot.chunk("connection");
},in_popup:function(){
return $("popup").innerHTML.match(/true/);
},id:function(){
return this.slot.className.split(/\s+/).select(function(e){
return e.match(/^\d+$/);
})[0];
},name:function(){
if(this.is_new()){
return $("new-card-name-field").value;
}else{
return this.slot.chunk("name").innerHTML;
}
},content:function(){
if(arguments[0]){
this.raw(arguments[0]);
this.slot.chunk("cooked").innerHTML=arguments[0];
warn("Set "+this.name()+"content = "+arguments[0]);
}else{
return this.raw();
}
},raw:function(){
if(arguments[0]){
this.slot.chunk("raw").innerHTML=arguments[0];
}else{
return this.slot.chunk("raw").innerHTML;
}
},datatype:function(){
return this.slot.chunk("datatype").innerHTML;
},editor_type:function(){
return this.slot.chunk("editor-type").innerHTML;
},revision_id:function(){
return this.slot.chunk("revision-id").innerHTML;
},set_revision_id:function(_641){
this.slot.chunk("revision-id").innerHTML=_641;
},highlighted:function(){
return this.slot.getStyle("background-color")=="rgb(221, 221, 221)"||this.slot.getStyle("background-color")=="#dddddd";
},highlight:function(){
this.slot.setStyle({"background-color":"#dddddd"});
},dehighlight:function(){
if(this.highlighted()){
new Effect.Highlight(this.slot,{startcolor:"#dddddd",endcolor:"#ffffff",restorecolor:"#ffffff"});
}
},swap_line_and_paragraph:function(){
if(this.swapping){
return;
}
this.swapping=true;
if(Element.hasClassName(this.slot,"line")){
this.to_paragraph();
}else{
this.to_line();
}
setTimeout("$('"+this.slot.id+"').card().swapping=false",600);
},to_line:function(){
if(this._viewmode=="options"||this._viewmode=="changes"){
this.view();
}
if(this._viewmode=="view"){
Wagn.paragraph_to_line(this.slot);
}
},to_paragraph:function(){
this.loadEditor();
Wagn.line_to_paragraph(this.slot);
},set_blank_name_to:function(_642){
name=$("new-card-name-field");
if(name&&$F(name)==""){
name.value=_642;
}
},setupDoubleClickToEdit:function(){
var self=this;
Element.getElementsByClassName(this.slot,"editOnDoubleClick").each(function(el){
if(typeof (el.attributes["inPopup"])!="undefined"&&el.attributes["inPopup"].value=="true"){
el.ondblclick=function(_645){
if(card_id=Wagn.Card.getTranscludingCardId(Event.element(_645))){
Wagn.Card.editTransclusion(card_id);
Event.stop(_645);
}
};
}else{
el.ondblclick=function(_646){
Event.stop(_646);
self.loadEditor(false,true);
};
}
});
},view:function(){
this.highlight_tab("view");
this._viewmode="view";
if(this.is_edit_ok()){
this.editor.view();
this.slot.chunk("editor").hide();
}
this.slot.chunk("card-links").show();
this.slot.chunk("cooked").style.display="";
this.slot.removeClassName("editing");
if(this.slot.oldClass=="line"){
this.slot.oldClass=null;
Wagn.paragraph_to_line(this.slot);
}
},edit:function(){
this.slot.viewHeight=this.slot.offsetHeight;
this.highlight_tab("edit");
this._viewmode="edit";
if(this.slot.hasClassName("line")){
this.slot.oldClass="line";
this.slot.removeClassName("line");
this.slot.addClassName("paragraph");
}
if(this.is_edit_ok()){
this.slot.chunk("editor").show();
this.slot.addClassName("editing");
this.editor.edit();
}else{
alert("edit NOT ok");
}
},changes:function(){
this.update_workspace("revision",{rev:arguments[0]||"",mode:arguments[1]||""});
this._viewmode="changes";
this.highlight_tab("changes");
this.workspace.show();
},options:function(){
this._viewmode="options";
this.update_workspace("options");
this.highlight_tab("options");
this.workspace.show();
},cancel:function(){
this.highlight();
this.view();
if(this.editor.refresh_on_cancel()){
this.loadEditor(true);
}
this.dehighlight();
Windows.close("popup");
},save:function(){
if(this.editor.before_save){
if(this.editor.before_save()){
this.continueSave();
}
}
},continueSave:function(){
card_content=this.content();
if(this.is_new()){
$("new-card-content-field").value=card_content;
url=this.is_connection()?"/connection/create":"/card/create";
new Ajax.Request(url,{method:"post",asynchronous:true,evalScripts:true,parameters:Form.serialize($("new-card-form"))});
}else{
this.highlight();
Wagn.Messenger.log("saving "+this.name()+"...");
new Ajax.Request("/card/edit/"+this.id(),{method:"post",parameters:"card[old_revision_id]="+this.revision_id()+"&card[content]="+encodeURIComponent(card_content)});
Windows.close("popup");
}
},save_draft:function(){
if(this.is_new()){
return;
}
original_content=this.content();
new_content=this.editor.get_draft();
if(new_content!=original_content){
Wagn.Messenger.log("saving draft of "+this.name()+"...");
new Ajax.Request("/card/save_draft/"+this.id(),{method:"post",parameters:"card[content]="+encodeURIComponent(new_content)});
}
},after_edit:function(_647,_648,raw){
this.set_revision_id(_647);
this.slot.chunk("editor-message").innerHTML="";
this.slot.chunk("cooked").innerHTML=_648;
this.slot.chunk("raw").innerHTML=raw;
var self=this;
document.getElementsByClassName("transcludedContent").each(function(el){
if(el.attributes["cardId"].value==self.id()){
el.innerHTML=_648;
}
});
getNewWindowLinks();
this.setupDoubleClickToEdit();
},editConflict:function(_64c,_64d){
this.slot.chunk("editor-message").innerHTML=_64d;
this.set_revision_id(_64c);
},rename_form:function(name){
this.update_workspace("rename_form",{"card[name]":$(this.slot.id+"-name-field").value});
},update_workspace:function(_64f){
params=this._ajax_parameters(arguments[1]);
params["method"]="get";
new Ajax.Updater(this.workspace,"/card/"+_64f+"/"+this.id(),params);
},remove:function(){
this.standard_update("remove",{});
},rollback:function(_650){
this.standard_update("rollback",{rev:_650});
},update:function(_651){
this.standard_update("update",_651);
},update_writer:function(_652){
this.standard_update("update_writer",_652);
},update_reader:function(_653){
this.standard_update("update_reader",_653);
},standard_update:function(_654,_655){
new Ajax.Request("/card/"+_654+"/"+this.id(),this._ajax_parameters(_655));
},update_attribute:function(_656,_657){
var self=this;
var _656=_656;
new Ajax.Request($A(["/card/attribute",this.id(),_656]).join("/"),{parameters:this._common_parameters({value:_657}),onSuccess:function(_659){
Wagn.messenger().note(self.name()+" "+_656+" updated: "+_659.responseText);
},onFailure:function(_65a){
Wagn.messenger().alert(self.name()+" "+_656+" update failed:"+_65a.responseText);
}});
},update_private:function(_65b){
if(_65b=="edit"){
Element.addClassName(this.slot.chunk("private-edit"),"current");
Element.removeClassName(this.slot.chunk("private-view"),"current");
this.update({"card[private]":false});
}else{
Element.addClassName(this.slot.chunk("private-view"),"current");
Element.removeClassName(this.slot.chunk("private-edit"),"current");
this.update({"card[private]":true});
}
},_common_parameters:function(){
param_hash=arguments[0]?arguments[0]:{};
param_list=$A(["element="+encodeURIComponent(this.slot.id)]);
$H(param_hash).each(function(pair){
param_list.push(pair.key+"="+encodeURIComponent(pair.value));
});
return param_list.join("&");
},_ajax_parameters:function(){
return {asynchronous:true,evalScripts:true,parameters:this._common_parameters(arguments[0])};
},hide_all:function(){
if(this.editor){
this.editor.view();
}
this.workspace.hide();
this.slot.chunk("cooked").hide();
this.slot.chunk("card-links").hide();
if(this.is_edit_ok()){
this.slot.chunk("editor").hide();
}
},highlight_tab:function(tab){
if(Element.hasClassName(this.slot.chunk(tab),"current")){
return;
}
this.hide_all();
Element.removeClassName(this.slot.chunk("view"),"current");
Element.removeClassName(this.slot.chunk("edit"),"current");
Element.removeClassName(this.slot.chunk("changes"),"current");
Element.removeClassName(this.slot.chunk("options"),"current");
Element.addClassName(this.slot.chunk(tab),"current");
}});
Object.extend(Wagn.Card,{table:function(){
return Wagn.CardTable;
},find:function(_65e){
return $(_65e).card();
},findFirstById:function(_65f){
return Wagn.Card.find_all_by_class(_65f).first();
},findByElement:function(_660){
return $(_660).card();
},find_all_by_class:function(){
card_id=arguments[0]?arguments[0]:"card-slot";
return Wagn.CardSlot.find_all_by_class(card_id).collect(function(s){
return s.card();
});
},init:function(_662){
if(Wagn.CardTable[_662]){
card=Wagn.CardTable[_662];
return card;
}else{
slot=Wagn.CardSlot.init(_662);
return new Wagn.Card(slot);
}
},update:function(_663,_664,_665,raw){
Wagn.Card.find_all_by_class(_663).each(function(card){
card.after_edit(_664,_665,raw);
});
},dehighlightAll:function(_668){
Wagn.Card.find_all_by_class(_668).each(function(card){
card.dehighlight();
});
},view:function(_66a){
Wagn.Card.find_all_by_class(_66a).each(function(card){
card.view();
});
},editConflict:function(_66c,_66d,_66e){
Wagn.Card.find_all_by_class(_66c).each(function(card){
card.editConflict(_66d,_66e);
});
},openPopup:function(){
if(!Wagn.win){
Wagn.win=new Window("popup",{className:"mac_os_x",title:"Transclusion Editor",top:30,left:30,width:550,height:400,showEffectOptions:{duration:0.2},hideEffectOptions:{duration:0.2}});
}
$("popup_content").innerHTML="<div id=\"popup_target\"></div>";
if(arguments[0]){
$("popup_target").innerHTML=arguments[0];
}
Wagn.win.show();
},editTransclusion:function(_670){
Wagn.Card.openPopup("loading...");
new Ajax.Updater("popup_target","/card/edit_transclusion/"+_670);
},editInPopup:function(_671){
new Ajax.Updater("popup_target","/card/edit_form/"+_671,{asynchronous:true,evalScripts:true,onComplete:function(_672){
c=new Wagn.Card(Wagn.CardSlot.init("popup_cardslot"));
setTimeout("Wagn.Card.find( 'popup_cardslot' ).edit()",100);
}});
},setupAll:function(){
var _673=arguments[0];
Wagn.CardSlot.find_all_by_class("all").each(function(s){
if(!s.chunk("wikiwyg_toolbar")){
c=new Wagn.Card(s,_673);
}
});
},getTranscludingCardId:function(_675){
if(_675.hasAttribute("cardId")){
return _675.attributes["cardId"].value;
}else{
if(_675.parentNode){
return this.getTranscludingCardId(_675.parentNode);
}else{
return false;
}
}
}});
Wadget=Class.create();
Object.extend(Wadget.prototype,{initialize:function(_676){
this._element=$(_676);
},show:function(url){
this.url=url;
var self=this;
if(url.match("html")){
url=url.gsub(".html",".json");
}else{
url+=".json";
}
this._dojo_args={url:url,transport:"ScriptSrcTransport",jsonParamName:"callback",load:function(type,data,evt,_67c){
self.onLoadCard(data);
},mimetype:"text/json",timeout:function(){
self.onFailure();
},timeoutSeconds:3};
dojo.io.bind(this._dojo_args);
},onFailure:function(){
err_msg="Sorry, "+this.url+" didn't return valid wadget data";
Element.insert(this._element,err_msg);
},onLoadCard:function(data){
Element.replace(this._element,data);
Wagn.Card.setupAll("widget");
}});

