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
Object.extend=function(_2,_3){
for(var _4 in _3){
_2[_4]=_3[_4];
}
return _2;
};
Object.extend(Object,{inspect:function(_5){
try{
if(_5===undefined){
return "undefined";
}
if(_5===null){
return "null";
}
return _5.inspect?_5.inspect():_5.toString();
}
catch(e){
if(e instanceof RangeError){
return "...";
}
throw e;
}
},keys:function(_6){
var _7=[];
for(var _8 in _6){
_7.push(_8);
}
return _7;
},values:function(_9){
var _a=[];
for(var _b in _9){
_a.push(_9[_b]);
}
return _a;
},clone:function(_c){
return Object.extend({},_c);
}});
Function.prototype.bind=function(){
var _d=this,_e=$A(arguments),_f=_e.shift();
return function(){
return _d.apply(_f,_e.concat($A(arguments)));
};
};
Function.prototype.bindAsEventListener=function(_10){
var _11=this,_12=$A(arguments),_10=_12.shift();
return function(_13){
return _11.apply(_10,[(_13||window.event)].concat(_12).concat($A(arguments)));
};
};
Object.extend(Number.prototype,{toColorPart:function(){
var _14=this.toString(16);
if(this<16){
return "0"+_14;
}
return _14;
},succ:function(){
return this+1;
},times:function(_15){
$R(0,this,true).each(_15);
return this;
}});
var Try={these:function(){
var _16;
for(var i=0,_18=arguments.length;i<_18;i++){
var _19=arguments[i];
try{
_16=_19();
break;
}
catch(e){
}
}
return _16;
}};
var PeriodicalExecuter=Class.create();
PeriodicalExecuter.prototype={initialize:function(_1a,_1b){
this.callback=_1a;
this.frequency=_1b;
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
String.interpret=function(_1c){
return _1c==null?"":String(_1c);
};
Object.extend(String.prototype,{gsub:function(_1d,_1e){
var _1f="",_20=this,_21;
_1e=arguments.callee.prepareReplacement(_1e);
while(_20.length>0){
if(_21=_20.match(_1d)){
_1f+=_20.slice(0,_21.index);
_1f+=String.interpret(_1e(_21));
_20=_20.slice(_21.index+_21[0].length);
}else{
_1f+=_20,_20="";
}
}
return _1f;
},sub:function(_22,_23,_24){
_23=this.gsub.prepareReplacement(_23);
_24=_24===undefined?1:_24;
return this.gsub(_22,function(_25){
if(--_24<0){
return _25[0];
}
return _23(_25);
});
},scan:function(_26,_27){
this.gsub(_26,_27);
return this;
},truncate:function(_28,_29){
_28=_28||30;
_29=_29===undefined?"...":_29;
return this.length>_28?this.slice(0,_28-_29.length)+_29:this;
},strip:function(){
return this.replace(/^\s+/,"").replace(/\s+$/,"");
},stripTags:function(){
return this.replace(/<\/?[^>]+>/gi,"");
},stripScripts:function(){
return this.replace(new RegExp(Prototype.ScriptFragment,"img"),"");
},extractScripts:function(){
var _2a=new RegExp(Prototype.ScriptFragment,"img");
var _2b=new RegExp(Prototype.ScriptFragment,"im");
return (this.match(_2a)||[]).map(function(_2c){
return (_2c.match(_2b)||["",""])[1];
});
},evalScripts:function(){
return this.extractScripts().map(function(_2d){
return eval(_2d);
});
},escapeHTML:function(){
var div=document.createElement("div");
var _2f=document.createTextNode(this);
div.appendChild(_2f);
return div.innerHTML;
},unescapeHTML:function(){
var div=document.createElement("div");
div.innerHTML=this.stripTags();
return div.childNodes[0]?(div.childNodes.length>1?$A(div.childNodes).inject("",function(_31,_32){
return _31+_32.nodeValue;
}):div.childNodes[0].nodeValue):"";
},toQueryParams:function(_33){
var _34=this.strip().match(/([^?#]*)(#.*)?$/);
if(!_34){
return {};
}
return _34[1].split(_33||"&").inject({},function(_35,_36){
if((_36=_36.split("="))[0]){
var _37=decodeURIComponent(_36[0]);
var _38=_36[1]?decodeURIComponent(_36[1]):undefined;
if(_35[_37]!==undefined){
if(_35[_37].constructor!=Array){
_35[_37]=[_35[_37]];
}
if(_38){
_35[_37].push(_38);
}
}else{
_35[_37]=_38;
}
}
return _35;
});
},toArray:function(){
return this.split("");
},succ:function(){
return this.slice(0,this.length-1)+String.fromCharCode(this.charCodeAt(this.length-1)+1);
},camelize:function(){
var _39=this.split("-"),len=_39.length;
if(len==1){
return _39[0];
}
var _3b=this.charAt(0)=="-"?_39[0].charAt(0).toUpperCase()+_39[0].substring(1):_39[0];
for(var i=1;i<len;i++){
_3b+=_39[i].charAt(0).toUpperCase()+_39[i].substring(1);
}
return _3b;
},capitalize:function(){
return this.charAt(0).toUpperCase()+this.substring(1).toLowerCase();
},underscore:function(){
return this.gsub(/::/,"/").gsub(/([A-Z]+)([A-Z][a-z])/,"#{1}_#{2}").gsub(/([a-z\d])([A-Z])/,"#{1}_#{2}").gsub(/-/,"_").toLowerCase();
},dasherize:function(){
return this.gsub(/_/,"-");
},inspect:function(_3d){
var _3e=this.replace(/\\/g,"\\\\");
if(_3d){
return "\""+_3e.replace(/"/g,"\\\"")+"\"";
}else{
return "'"+_3e.replace(/'/g,"\\'")+"'";
}
}});
String.prototype.gsub.prepareReplacement=function(_3f){
if(typeof _3f=="function"){
return _3f;
}
var _40=new Template(_3f);
return function(_41){
return _40.evaluate(_41);
};
};
String.prototype.parseQuery=String.prototype.toQueryParams;
var Template=Class.create();
Template.Pattern=/(^|.|\r|\n)(#\{(.*?)\})/;
Template.prototype={initialize:function(_42,_43){
this.template=_42.toString();
this.pattern=_43||Template.Pattern;
},evaluate:function(_44){
return this.template.gsub(this.pattern,function(_45){
var _46=_45[1];
if(_46=="\\"){
return _45[2];
}
return _46+String.interpret(_44[_45[3]]);
});
}};
var $break=new Object();
var $continue=new Object();
var Enumerable={each:function(_47){
var _48=0;
try{
this._each(function(_49){
try{
_47(_49,_48++);
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
},eachSlice:function(_4a,_4b){
var _4c=-_4a,_4d=[],_4e=this.toArray();
while((_4c+=_4a)<_4e.length){
_4d.push(_4e.slice(_4c,_4c+_4a));
}
return _4d.map(_4b);
},all:function(_4f){
var _50=true;
this.each(function(_51,_52){
_50=_50&&!!(_4f||Prototype.K)(_51,_52);
if(!_50){
throw $break;
}
});
return _50;
},any:function(_53){
var _54=false;
this.each(function(_55,_56){
if(_54=!!(_53||Prototype.K)(_55,_56)){
throw $break;
}
});
return _54;
},collect:function(_57){
var _58=[];
this.each(function(_59,_5a){
_58.push((_57||Prototype.K)(_59,_5a));
});
return _58;
},detect:function(_5b){
var _5c;
this.each(function(_5d,_5e){
if(_5b(_5d,_5e)){
_5c=_5d;
throw $break;
}
});
return _5c;
},findAll:function(_5f){
var _60=[];
this.each(function(_61,_62){
if(_5f(_61,_62)){
_60.push(_61);
}
});
return _60;
},grep:function(_63,_64){
var _65=[];
this.each(function(_66,_67){
var _68=_66.toString();
if(_68.match(_63)){
_65.push((_64||Prototype.K)(_66,_67));
}
});
return _65;
},include:function(_69){
var _6a=false;
this.each(function(_6b){
if(_6b==_69){
_6a=true;
throw $break;
}
});
return _6a;
},inGroupsOf:function(_6c,_6d){
_6d=_6d===undefined?null:_6d;
return this.eachSlice(_6c,function(_6e){
while(_6e.length<_6c){
_6e.push(_6d);
}
return _6e;
});
},inject:function(_6f,_70){
this.each(function(_71,_72){
_6f=_70(_6f,_71,_72);
});
return _6f;
},invoke:function(_73){
var _74=$A(arguments).slice(1);
return this.map(function(_75){
return _75[_73].apply(_75,_74);
});
},max:function(_76){
var _77;
this.each(function(_78,_79){
_78=(_76||Prototype.K)(_78,_79);
if(_77==undefined||_78>=_77){
_77=_78;
}
});
return _77;
},min:function(_7a){
var _7b;
this.each(function(_7c,_7d){
_7c=(_7a||Prototype.K)(_7c,_7d);
if(_7b==undefined||_7c<_7b){
_7b=_7c;
}
});
return _7b;
},partition:function(_7e){
var _7f=[],_80=[];
this.each(function(_81,_82){
((_7e||Prototype.K)(_81,_82)?_7f:_80).push(_81);
});
return [_7f,_80];
},pluck:function(_83){
var _84=[];
this.each(function(_85,_86){
_84.push(_85[_83]);
});
return _84;
},reject:function(_87){
var _88=[];
this.each(function(_89,_8a){
if(!_87(_89,_8a)){
_88.push(_89);
}
});
return _88;
},sortBy:function(_8b){
return this.map(function(_8c,_8d){
return {value:_8c,criteria:_8b(_8c,_8d)};
}).sort(function(_8e,_8f){
var a=_8e.criteria,b=_8f.criteria;
return a<b?-1:a>b?1:0;
}).pluck("value");
},toArray:function(){
return this.map();
},zip:function(){
var _92=Prototype.K,_93=$A(arguments);
if(typeof _93.last()=="function"){
_92=_93.pop();
}
var _94=[this].concat(_93).map($A);
return this.map(function(_95,_96){
return _92(_94.pluck(_96));
});
},size:function(){
return this.toArray().length;
},inspect:function(){
return "#<Enumerable:"+this.toArray().inspect()+">";
}};
Object.extend(Enumerable,{map:Enumerable.collect,find:Enumerable.detect,select:Enumerable.findAll,member:Enumerable.include,entries:Enumerable.toArray});
var $A=Array.from=function(_97){
if(!_97){
return [];
}
if(_97.toArray){
return _97.toArray();
}else{
var _98=[];
for(var i=0,_9a=_97.length;i<_9a;i++){
_98.push(_97[i]);
}
return _98;
}
};
Object.extend(Array.prototype,Enumerable);
if(!Array.prototype._reverse){
Array.prototype._reverse=Array.prototype.reverse;
}
Object.extend(Array.prototype,{_each:function(_9b){
for(var i=0,_9d=this.length;i<_9d;i++){
_9b(this[i]);
}
},clear:function(){
this.length=0;
return this;
},first:function(){
return this[0];
},last:function(){
return this[this.length-1];
},compact:function(){
return this.select(function(_9e){
return _9e!=null;
});
},flatten:function(){
return this.inject([],function(_9f,_a0){
return _9f.concat(_a0&&_a0.constructor==Array?_a0.flatten():[_a0]);
});
},without:function(){
var _a1=$A(arguments);
return this.select(function(_a2){
return !_a1.include(_a2);
});
},indexOf:function(_a3){
for(var i=0,_a5=this.length;i<_a5;i++){
if(this[i]==_a3){
return i;
}
}
return -1;
},reverse:function(_a6){
return (_a6!==false?this:this.toArray())._reverse();
},reduce:function(){
return this.length>1?this:this[0];
},uniq:function(){
return this.inject([],function(_a7,_a8){
return _a7.include(_a8)?_a7:_a7.concat([_a8]);
});
},clone:function(){
return [].concat(this);
},size:function(){
return this.length;
},inspect:function(){
return "["+this.map(Object.inspect).join(", ")+"]";
}});
Array.prototype.toArray=Array.prototype.clone;
function $w(_a9){
_a9=_a9.strip();
return _a9?_a9.split(/\s+/):[];
}
if(window.opera){
Array.prototype.concat=function(){
var _aa=[];
for(var i=0,_ac=this.length;i<_ac;i++){
_aa.push(this[i]);
}
for(var i=0,_ac=arguments.length;i<_ac;i++){
if(arguments[i].constructor==Array){
for(var j=0,_ae=arguments[i].length;j<_ae;j++){
_aa.push(arguments[i][j]);
}
}else{
_aa.push(arguments[i]);
}
}
return _aa;
};
}
var Hash=function(obj){
Object.extend(this,obj||{});
};
Object.extend(Hash,{toQueryString:function(obj){
var _b1=[];
this.prototype._each.call(obj,function(_b2){
if(!_b2.key){
return;
}
if(_b2.value&&_b2.value.constructor==Array){
var _b3=_b2.value.compact();
if(_b3.length<2){
_b2.value=_b3.reduce();
}else{
key=encodeURIComponent(_b2.key);
_b3.each(function(_b4){
_b4=_b4!=undefined?encodeURIComponent(_b4):"";
_b1.push(key+"="+encodeURIComponent(_b4));
});
return;
}
}
if(_b2.value==undefined){
_b2[1]="";
}
_b1.push(_b2.map(encodeURIComponent).join("="));
});
return _b1.join("&");
}});
Object.extend(Hash.prototype,Enumerable);
Object.extend(Hash.prototype,{_each:function(_b5){
for(var key in this){
var _b7=this[key];
if(_b7&&_b7==Hash.prototype[key]){
continue;
}
var _b8=[key,_b7];
_b8.key=key;
_b8.value=_b7;
_b5(_b8);
}
},keys:function(){
return this.pluck("key");
},values:function(){
return this.pluck("value");
},merge:function(_b9){
return $H(_b9).inject(this,function(_ba,_bb){
_ba[_bb.key]=_bb.value;
return _ba;
});
},remove:function(){
var _bc;
for(var i=0,_be=arguments.length;i<_be;i++){
var _bf=this[arguments[i]];
if(_bf!==undefined){
if(_bc===undefined){
_bc=_bf;
}else{
if(_bc.constructor!=Array){
_bc=[_bc];
}
_bc.push(_bf);
}
}
delete this[arguments[i]];
}
return _bc;
},toQueryString:function(){
return Hash.toQueryString(this);
},inspect:function(){
return "#<Hash:{"+this.map(function(_c0){
return _c0.map(Object.inspect).join(": ");
}).join(", ")+"}>";
}});
function $H(_c1){
if(_c1&&_c1.constructor==Hash){
return _c1;
}
return new Hash(_c1);
}
ObjectRange=Class.create();
Object.extend(ObjectRange.prototype,Enumerable);
Object.extend(ObjectRange.prototype,{initialize:function(_c2,end,_c4){
this.start=_c2;
this.end=end;
this.exclusive=_c4;
},_each:function(_c5){
var _c6=this.start;
while(this.include(_c6)){
_c5(_c6);
_c6=_c6.succ();
}
},include:function(_c7){
if(_c7<this.start){
return false;
}
if(this.exclusive){
return _c7<this.end;
}
return _c7<=this.end;
}});
var $R=function(_c8,end,_ca){
return new ObjectRange(_c8,end,_ca);
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
Ajax.Responders={responders:[],_each:function(_cb){
this.responders._each(_cb);
},register:function(_cc){
if(!this.include(_cc)){
this.responders.push(_cc);
}
},unregister:function(_cd){
this.responders=this.responders.without(_cd);
},dispatch:function(_ce,_cf,_d0,_d1){
this.each(function(_d2){
if(typeof _d2[_ce]=="function"){
try{
_d2[_ce].apply(_d2,[_cf,_d0,_d1]);
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
Ajax.Base.prototype={setOptions:function(_d3){
this.options={method:"post",asynchronous:true,contentType:"application/x-www-form-urlencoded",encoding:"UTF-8",parameters:""};
Object.extend(this.options,_d3||{});
this.options.method=this.options.method.toLowerCase();
if(typeof this.options.parameters=="string"){
this.options.parameters=this.options.parameters.toQueryParams();
}
}};
Ajax.Request=Class.create();
Ajax.Request.Events=["Uninitialized","Loading","Loaded","Interactive","Complete"];
Ajax.Request.prototype=Object.extend(new Ajax.Base(),{_complete:false,initialize:function(url,_d5){
this.transport=Ajax.getTransport();
this.setOptions(_d5);
this.request(url);
},request:function(url){
this.url=url;
this.method=this.options.method;
var _d7=this.options.parameters;
if(!["get","post"].include(this.method)){
_d7["_method"]=this.method;
this.method="post";
}
_d7=Hash.toQueryString(_d7);
if(_d7&&/Konqueror|Safari|KHTML/.test(navigator.userAgent)){
_d7+="&_=";
}
if(this.method=="get"&&_d7){
this.url+=(this.url.indexOf("?")>-1?"&":"?")+_d7;
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
var _d8=this.method=="post"?(this.options.postBody||_d7):null;
this.transport.send(_d8);
if(!this.options.asynchronous&&this.transport.overrideMimeType){
this.onStateChange();
}
}
catch(e){
this.dispatchException(e);
}
},onStateChange:function(){
var _d9=this.transport.readyState;
if(_d9>1&&!((_d9==4)&&this._complete)){
this.respondToReadyState(this.transport.readyState);
}
},setRequestHeaders:function(){
var _da={"X-Requested-With":"XMLHttpRequest","X-Prototype-Version":Prototype.Version,"Accept":"text/javascript, text/html, application/xml, text/xml, */*"};
if(this.method=="post"){
_da["Content-type"]=this.options.contentType+(this.options.encoding?"; charset="+this.options.encoding:"");
if(this.transport.overrideMimeType&&(navigator.userAgent.match(/Gecko\/(\d{4})/)||[0,2005])[1]<2005){
_da["Connection"]="close";
}
}
if(typeof this.options.requestHeaders=="object"){
var _db=this.options.requestHeaders;
if(typeof _db.push=="function"){
for(var i=0,_dd=_db.length;i<_dd;i+=2){
_da[_db[i]]=_db[i+1];
}
}else{
$H(_db).each(function(_de){
_da[_de.key]=_de.value;
});
}
}
for(var _df in _da){
this.transport.setRequestHeader(_df,_da[_df]);
}
},success:function(){
return !this.transport.status||(this.transport.status>=200&&this.transport.status<300);
},respondToReadyState:function(_e0){
var _e1=Ajax.Request.Events[_e0];
var _e2=this.transport,_e3=this.evalJSON();
if(_e1=="Complete"){
try{
this._complete=true;
(this.options["on"+this.transport.status]||this.options["on"+(this.success()?"Success":"Failure")]||Prototype.emptyFunction)(_e2,_e3);
}
catch(e){
this.dispatchException(e);
}
if((this.getHeader("Content-type")||"text/javascript").strip().match(/^(text|application)\/(x-)?(java|ecma)script(;.*)?$/i)){
this.evalResponse();
}
}
try{
(this.options["on"+_e1]||Prototype.emptyFunction)(_e2,_e3);
Ajax.Responders.dispatch("on"+_e1,this,_e2,_e3);
}
catch(e){
this.dispatchException(e);
}
if(_e1=="Complete"){
this.transport.onreadystatechange=Prototype.emptyFunction;
}
},getHeader:function(_e4){
try{
return this.transport.getResponseHeader(_e4);
}
catch(e){
return null;
}
},evalJSON:function(){
try{
var _e5=this.getHeader("X-JSON");
return _e5?eval("("+_e5+")"):null;
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
},dispatchException:function(_e6){
(this.options.onException||Prototype.emptyFunction)(this,_e6);
Ajax.Responders.dispatch("onException",this,_e6);
}});
Ajax.Updater=Class.create();
Object.extend(Object.extend(Ajax.Updater.prototype,Ajax.Request.prototype),{initialize:function(_e7,url,_e9){
this.container={success:(_e7.success||_e7),failure:(_e7.failure||(_e7.success?null:_e7))};
this.transport=Ajax.getTransport();
this.setOptions(_e9);
var _ea=this.options.onComplete||Prototype.emptyFunction;
this.options.onComplete=(function(_eb,_ec){
this.updateContent();
_ea(_eb,_ec);
}).bind(this);
this.request(url);
},updateContent:function(){
var _ed=this.container[this.success()?"success":"failure"];
var _ee=this.transport.responseText;
if(!this.options.evalScripts){
_ee=_ee.stripScripts();
}
if(_ed=$(_ed)){
if(this.options.insertion){
new this.options.insertion(_ed,_ee);
}else{
_ed.update(_ee);
}
}
if(this.success()){
if(this.onComplete){
setTimeout(this.onComplete.bind(this),10);
}
}
}});
Ajax.PeriodicalUpdater=Class.create();
Ajax.PeriodicalUpdater.prototype=Object.extend(new Ajax.Base(),{initialize:function(_ef,url,_f1){
this.setOptions(_f1);
this.onComplete=this.options.onComplete;
this.frequency=(this.options.frequency||2);
this.decay=(this.options.decay||1);
this.updater={};
this.container=_ef;
this.url=url;
this.start();
},start:function(){
this.options.onComplete=this.updateComplete.bind(this);
this.onTimerEvent();
},stop:function(){
this.updater.options.onComplete=undefined;
clearTimeout(this.timer);
(this.onComplete||Prototype.emptyFunction).apply(this,arguments);
},updateComplete:function(_f2){
if(this.options.decay){
this.decay=(_f2.responseText==this.lastText?this.decay*this.options.decay:1);
this.lastText=_f2.responseText;
}
this.timer=setTimeout(this.onTimerEvent.bind(this),this.decay*this.frequency*1000);
},onTimerEvent:function(){
this.updater=new Ajax.Updater(this.container,this.url,this.options);
}});
function $(_f3){
if(arguments.length>1){
for(var i=0,_f5=[],_f6=arguments.length;i<_f6;i++){
_f5.push($(arguments[i]));
}
return _f5;
}
if(typeof _f3=="string"){
_f3=document.getElementById(_f3);
}
return Element.extend(_f3);
}
if(Prototype.BrowserFeatures.XPath){
document._getElementsByXPath=function(_f7,_f8){
var _f9=[];
var _fa=document.evaluate(_f7,$(_f8)||document,null,XPathResult.ORDERED_NODE_SNAPSHOT_TYPE,null);
for(var i=0,_fc=_fa.snapshotLength;i<_fc;i++){
_f9.push(_fa.snapshotItem(i));
}
return _f9;
};
}
document.getElementsByClassName=function(_fd,_fe){
if(Prototype.BrowserFeatures.XPath){
var q=".//*[contains(concat(' ', @class, ' '), ' "+_fd+" ')]";
return document._getElementsByXPath(q,_fe);
}else{
var _100=($(_fe)||document.body).getElementsByTagName("*");
var _101=[],_102;
for(var i=0,_104=_100.length;i<_104;i++){
_102=_100[i];
if(Element.hasClassName(_102,_fd)){
_101.push(Element.extend(_102));
}
}
return _101;
}
};
if(!window.Element){
var Element=new Object();
}
Element.extend=function(_105){
if(!_105||_nativeExtensions||_105.nodeType==3){
return _105;
}
if(!_105._extended&&_105.tagName&&_105!=window){
var _106=Object.clone(Element.Methods),_107=Element.extend.cache;
if(_105.tagName=="FORM"){
Object.extend(_106,Form.Methods);
}
if(["INPUT","TEXTAREA","SELECT"].include(_105.tagName)){
Object.extend(_106,Form.Element.Methods);
}
Object.extend(_106,Element.Methods.Simulated);
for(var _108 in _106){
var _109=_106[_108];
if(typeof _109=="function"&&!(_108 in _105)){
_105[_108]=_107.findOrStore(_109);
}
}
}
_105._extended=true;
return _105;
};
Element.extend.cache={findOrStore:function(_10a){
return this[_10a]=this[_10a]||function(){
return _10a.apply(null,[this].concat($A(arguments)));
};
}};
Element.Methods={visible:function(_10b){
return $(_10b).style.display!="none";
},toggle:function(_10c){
_10c=$(_10c);
Element[Element.visible(_10c)?"hide":"show"](_10c);
return _10c;
},hide:function(_10d){
$(_10d).style.display="none";
return _10d;
},show:function(_10e){
$(_10e).style.display="";
return _10e;
},remove:function(_10f){
_10f=$(_10f);
_10f.parentNode.removeChild(_10f);
return _10f;
},update:function(_110,html){
html=typeof html=="undefined"?"":html.toString();
$(_110).innerHTML=html.stripScripts();
setTimeout(function(){
html.evalScripts();
},10);
return _110;
},replace:function(_112,html){
_112=$(_112);
html=typeof html=="undefined"?"":html.toString();
if(_112.outerHTML){
_112.outerHTML=html.stripScripts();
}else{
var _114=_112.ownerDocument.createRange();
_114.selectNodeContents(_112);
_112.parentNode.replaceChild(_114.createContextualFragment(html.stripScripts()),_112);
}
setTimeout(function(){
html.evalScripts();
},10);
return _112;
},inspect:function(_115){
_115=$(_115);
var _116="<"+_115.tagName.toLowerCase();
$H({"id":"id","className":"class"}).each(function(pair){
var _118=pair.first(),_119=pair.last();
var _11a=(_115[_118]||"").toString();
if(_11a){
_116+=" "+_119+"="+_11a.inspect(true);
}
});
return _116+">";
},recursivelyCollect:function(_11b,_11c){
_11b=$(_11b);
var _11d=[];
while(_11b=_11b[_11c]){
if(_11b.nodeType==1){
_11d.push(Element.extend(_11b));
}
}
return _11d;
},ancestors:function(_11e){
return $(_11e).recursivelyCollect("parentNode");
},descendants:function(_11f){
return $A($(_11f).getElementsByTagName("*"));
},immediateDescendants:function(_120){
if(!(_120=$(_120).firstChild)){
return [];
}
while(_120&&_120.nodeType!=1){
_120=_120.nextSibling;
}
if(_120){
return [_120].concat($(_120).nextSiblings());
}
return [];
},previousSiblings:function(_121){
return $(_121).recursivelyCollect("previousSibling");
},nextSiblings:function(_122){
return $(_122).recursivelyCollect("nextSibling");
},siblings:function(_123){
_123=$(_123);
return _123.previousSiblings().reverse().concat(_123.nextSiblings());
},match:function(_124,_125){
if(typeof _125=="string"){
_125=new Selector(_125);
}
return _125.match($(_124));
},up:function(_126,_127,_128){
return Selector.findElement($(_126).ancestors(),_127,_128);
},down:function(_129,_12a,_12b){
return Selector.findElement($(_129).descendants(),_12a,_12b);
},previous:function(_12c,_12d,_12e){
return Selector.findElement($(_12c).previousSiblings(),_12d,_12e);
},next:function(_12f,_130,_131){
return Selector.findElement($(_12f).nextSiblings(),_130,_131);
},getElementsBySelector:function(){
var args=$A(arguments),_133=$(args.shift());
return Selector.findChildElements(_133,args);
},getElementsByClassName:function(_134,_135){
return document.getElementsByClassName(_135,_134);
},readAttribute:function(_136,name){
_136=$(_136);
if(document.all&&!window.opera){
var t=Element._attributeTranslations;
if(t.values[name]){
return t.values[name](_136,name);
}
if(t.names[name]){
name=t.names[name];
}
var _139=_136.attributes[name];
if(_139){
return _139.nodeValue;
}
}
return _136.getAttribute(name);
},getHeight:function(_13a){
return $(_13a).getDimensions().height;
},getWidth:function(_13b){
return $(_13b).getDimensions().width;
},classNames:function(_13c){
return new Element.ClassNames(_13c);
},hasClassName:function(_13d,_13e){
if(!(_13d=$(_13d))){
return;
}
var _13f=_13d.className;
if(_13f.length==0){
return false;
}
if(_13f==_13e||_13f.match(new RegExp("(^|\\s)"+_13e+"(\\s|$)"))){
return true;
}
return false;
},addClassName:function(_140,_141){
if(!(_140=$(_140))){
return;
}
Element.classNames(_140).add(_141);
return _140;
},removeClassName:function(_142,_143){
if(!(_142=$(_142))){
return;
}
Element.classNames(_142).remove(_143);
return _142;
},toggleClassName:function(_144,_145){
if(!(_144=$(_144))){
return;
}
Element.classNames(_144)[_144.hasClassName(_145)?"remove":"add"](_145);
return _144;
},observe:function(){
Event.observe.apply(Event,arguments);
return $A(arguments).first();
},stopObserving:function(){
Event.stopObserving.apply(Event,arguments);
return $A(arguments).first();
},cleanWhitespace:function(_146){
_146=$(_146);
var node=_146.firstChild;
while(node){
var _148=node.nextSibling;
if(node.nodeType==3&&!/\S/.test(node.nodeValue)){
_146.removeChild(node);
}
node=_148;
}
return _146;
},empty:function(_149){
return $(_149).innerHTML.match(/^\s*$/);
},descendantOf:function(_14a,_14b){
_14a=$(_14a),_14b=$(_14b);
while(_14a=_14a.parentNode){
if(_14a==_14b){
return true;
}
}
return false;
},scrollTo:function(_14c){
_14c=$(_14c);
var pos=Position.cumulativeOffset(_14c);
window.scrollTo(pos[0],pos[1]);
return _14c;
},getStyle:function(_14e,_14f){
_14e=$(_14e);
if(["float","cssFloat"].include(_14f)){
_14f=(typeof _14e.style.styleFloat!="undefined"?"styleFloat":"cssFloat");
}
_14f=_14f.camelize();
var _150=_14e.style[_14f];
if(!_150){
if(document.defaultView&&document.defaultView.getComputedStyle){
var css=document.defaultView.getComputedStyle(_14e,null);
_150=css?css[_14f]:null;
}else{
if(_14e.currentStyle){
_150=_14e.currentStyle[_14f];
}
}
}
if((_150=="auto")&&["width","height"].include(_14f)&&(_14e.getStyle("display")!="none")){
_150=_14e["offset"+_14f.capitalize()]+"px";
}
if(window.opera&&["left","top","right","bottom"].include(_14f)){
if(Element.getStyle(_14e,"position")=="static"){
_150="auto";
}
}
if(_14f=="opacity"){
if(_150){
return parseFloat(_150);
}
if(_150=(_14e.getStyle("filter")||"").match(/alpha\(opacity=(.*)\)/)){
if(_150[1]){
return parseFloat(_150[1])/100;
}
}
return 1;
}
return _150=="auto"?null:_150;
},setStyle:function(_152,_153){
_152=$(_152);
for(var name in _153){
var _155=_153[name];
if(name=="opacity"){
if(_155==1){
_155=(/Gecko/.test(navigator.userAgent)&&!/Konqueror|Safari|KHTML/.test(navigator.userAgent))?0.999999:1;
if(/MSIE/.test(navigator.userAgent)&&!window.opera){
_152.style.filter=_152.getStyle("filter").replace(/alpha\([^\)]*\)/gi,"");
}
}else{
if(_155==""){
if(/MSIE/.test(navigator.userAgent)&&!window.opera){
_152.style.filter=_152.getStyle("filter").replace(/alpha\([^\)]*\)/gi,"");
}
}else{
if(_155<0.00001){
_155=0;
}
if(/MSIE/.test(navigator.userAgent)&&!window.opera){
_152.style.filter=_152.getStyle("filter").replace(/alpha\([^\)]*\)/gi,"")+"alpha(opacity="+_155*100+")";
}
}
}
}else{
if(["float","cssFloat"].include(name)){
name=(typeof _152.style.styleFloat!="undefined")?"styleFloat":"cssFloat";
}
}
_152.style[name.camelize()]=_155;
}
return _152;
},getDimensions:function(_156){
_156=$(_156);
var _157=$(_156).getStyle("display");
if(_157!="none"&&_157!=null){
return {width:_156.offsetWidth,height:_156.offsetHeight};
}
var els=_156.style;
var _159=els.visibility;
var _15a=els.position;
var _15b=els.display;
els.visibility="hidden";
els.position="absolute";
els.display="block";
var _15c=_156.clientWidth;
var _15d=_156.clientHeight;
els.display=_15b;
els.position=_15a;
els.visibility=_159;
return {width:_15c,height:_15d};
},makePositioned:function(_15e){
_15e=$(_15e);
var pos=Element.getStyle(_15e,"position");
if(pos=="static"||!pos){
_15e._madePositioned=true;
_15e.style.position="relative";
if(window.opera){
_15e.style.top=0;
_15e.style.left=0;
}
}
return _15e;
},undoPositioned:function(_160){
_160=$(_160);
if(_160._madePositioned){
_160._madePositioned=undefined;
_160.style.position=_160.style.top=_160.style.left=_160.style.bottom=_160.style.right="";
}
return _160;
},makeClipping:function(_161){
_161=$(_161);
if(_161._overflow){
return _161;
}
_161._overflow=_161.style.overflow||"auto";
if((Element.getStyle(_161,"overflow")||"visible")!="hidden"){
_161.style.overflow="hidden";
}
return _161;
},undoClipping:function(_162){
_162=$(_162);
if(!_162._overflow){
return _162;
}
_162.style.overflow=_162._overflow=="auto"?"":_162._overflow;
_162._overflow=null;
return _162;
}};
Object.extend(Element.Methods,{childOf:Element.Methods.descendantOf});
Element._attributeTranslations={};
Element._attributeTranslations.names={colspan:"colSpan",rowspan:"rowSpan",valign:"vAlign",datetime:"dateTime",accesskey:"accessKey",tabindex:"tabIndex",enctype:"encType",maxlength:"maxLength",readonly:"readOnly",longdesc:"longDesc"};
Element._attributeTranslations.values={_getAttr:function(_163,_164){
return _163.getAttribute(_164,2);
},_flag:function(_165,_166){
return $(_165).hasAttribute(_166)?_166:null;
},style:function(_167){
return _167.style.cssText.toLowerCase();
},title:function(_168){
var node=_168.getAttributeNode("title");
return node.specified?node.nodeValue:null;
}};
Object.extend(Element._attributeTranslations.values,{href:Element._attributeTranslations.values._getAttr,src:Element._attributeTranslations.values._getAttr,disabled:Element._attributeTranslations.values._flag,checked:Element._attributeTranslations.values._flag,readonly:Element._attributeTranslations.values._flag,multiple:Element._attributeTranslations.values._flag});
Element.Methods.Simulated={hasAttribute:function(_16a,_16b){
var t=Element._attributeTranslations;
_16b=t.names[_16b]||_16b;
return $(_16a).getAttributeNode(_16b).specified;
}};
if(document.all&&!window.opera){
Element.Methods.update=function(_16d,html){
_16d=$(_16d);
html=typeof html=="undefined"?"":html.toString();
var _16f=_16d.tagName.toUpperCase();
if(["THEAD","TBODY","TR","TD"].include(_16f)){
var div=document.createElement("div");
switch(_16f){
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
$A(_16d.childNodes).each(function(node){
_16d.removeChild(node);
});
depth.times(function(){
div=div.firstChild;
});
$A(div.childNodes).each(function(node){
_16d.appendChild(node);
});
}else{
_16d.innerHTML=html.stripScripts();
}
setTimeout(function(){
html.evalScripts();
},10);
return _16d;
};
}
Object.extend(Element,Element.Methods);
var _nativeExtensions=false;
if(/Konqueror|Safari|KHTML/.test(navigator.userAgent)){
["","Form","Input","TextArea","Select"].each(function(tag){
var _174="HTML"+tag+"Element";
if(window[_174]){
return;
}
var _175=window[_174]={};
_175.prototype=document.createElement(tag?tag.toLowerCase():"div").__proto__;
});
}
Element.addMethods=function(_176){
Object.extend(Element.Methods,_176||{});
function copy(_177,_178,_179){
_179=_179||false;
var _17a=Element.extend.cache;
for(var _17b in _177){
var _17c=_177[_17b];
if(!_179||!(_17b in _178)){
_178[_17b]=_17a.findOrStore(_17c);
}
}
}
if(typeof HTMLElement!="undefined"){
copy(Element.Methods,HTMLElement.prototype);
copy(Element.Methods.Simulated,HTMLElement.prototype,true);
copy(Form.Methods,HTMLFormElement.prototype);
[HTMLInputElement,HTMLTextAreaElement,HTMLSelectElement].each(function(_17d){
copy(Form.Element.Methods,_17d.prototype);
});
_nativeExtensions=true;
}
};
var Toggle=new Object();
Toggle.display=Element.toggle;
Abstract.Insertion=function(_17e){
this.adjacency=_17e;
};
Abstract.Insertion.prototype={initialize:function(_17f,_180){
this.element=$(_17f);
this.content=_180.stripScripts();
if(this.adjacency&&this.element.insertAdjacentHTML){
try{
this.element.insertAdjacentHTML(this.adjacency,this.content);
}
catch(e){
var _181=this.element.tagName.toUpperCase();
if(["TBODY","TR"].include(_181)){
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
_180.evalScripts();
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
},insertContent:function(_183){
_183.each((function(_184){
this.element.parentNode.insertBefore(_184,this.element);
}).bind(this));
}});
Insertion.Top=Class.create();
Insertion.Top.prototype=Object.extend(new Abstract.Insertion("afterBegin"),{initializeRange:function(){
this.range.selectNodeContents(this.element);
this.range.collapse(true);
},insertContent:function(_185){
_185.reverse(false).each((function(_186){
this.element.insertBefore(_186,this.element.firstChild);
}).bind(this));
}});
Insertion.Bottom=Class.create();
Insertion.Bottom.prototype=Object.extend(new Abstract.Insertion("beforeEnd"),{initializeRange:function(){
this.range.selectNodeContents(this.element);
this.range.collapse(this.element);
},insertContent:function(_187){
_187.each((function(_188){
this.element.appendChild(_188);
}).bind(this));
}});
Insertion.After=Class.create();
Insertion.After.prototype=Object.extend(new Abstract.Insertion("afterEnd"),{initializeRange:function(){
this.range.setStartAfter(this.element);
},insertContent:function(_189){
_189.each((function(_18a){
this.element.parentNode.insertBefore(_18a,this.element.nextSibling);
}).bind(this));
}});
Element.ClassNames=Class.create();
Element.ClassNames.prototype={initialize:function(_18b){
this.element=$(_18b);
},_each:function(_18c){
this.element.className.split(/\s+/).select(function(name){
return name.length>0;
})._each(_18c);
},set:function(_18e){
this.element.className=_18e;
},add:function(_18f){
if(this.include(_18f)){
return;
}
this.set($A(this).concat(_18f).join(" "));
},remove:function(_190){
if(!this.include(_190)){
return;
}
this.set($A(this).without(_190).join(" "));
},toString:function(){
return $A(this).join(" ");
}};
Object.extend(Element.ClassNames.prototype,Enumerable);
var Selector=Class.create();
Selector.prototype={initialize:function(_191){
this.params={classNames:[]};
this.expression=_191.toString().strip();
this.parseExpression();
this.compileMatcher();
},parseExpression:function(){
function abort(_192){
throw "Parse error in selector: "+_192;
}
if(this.expression==""){
abort("empty expression");
}
var _193=this.params,expr=this.expression,_195,_196,_197,rest;
while(_195=expr.match(/^(.*)\[([a-z0-9_:-]+?)(?:([~\|!]?=)(?:"([^"]*)"|([^\]\s]*)))?\]$/i)){
_193.attributes=_193.attributes||[];
_193.attributes.push({name:_195[2],operator:_195[3],value:_195[4]||_195[5]||""});
expr=_195[1];
}
if(expr=="*"){
return this.params.wildcard=true;
}
while(_195=expr.match(/^([^a-z0-9_-])?([a-z0-9_-]+)(.*)/i)){
_196=_195[1],_197=_195[2],rest=_195[3];
switch(_196){
case "#":
_193.id=_197;
break;
case ".":
_193.classNames.push(_197);
break;
case "":
case undefined:
_193.tagName=_197.toUpperCase();
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
var _199=this.params,_19a=[],_19b;
if(_199.wildcard){
_19a.push("true");
}
if(_19b=_199.id){
_19a.push("element.readAttribute(\"id\") == "+_19b.inspect());
}
if(_19b=_199.tagName){
_19a.push("element.tagName.toUpperCase() == "+_19b.inspect());
}
if((_19b=_199.classNames).length>0){
for(var i=0,_19d=_19b.length;i<_19d;i++){
_19a.push("element.hasClassName("+_19b[i].inspect()+")");
}
}
if(_19b=_199.attributes){
_19b.each(function(_19e){
var _19f="element.readAttribute("+_19e.name.inspect()+")";
var _1a0=function(_1a1){
return _19f+" && "+_19f+".split("+_1a1.inspect()+")";
};
switch(_19e.operator){
case "=":
_19a.push(_19f+" == "+_19e.value.inspect());
break;
case "~=":
_19a.push(_1a0(" ")+".include("+_19e.value.inspect()+")");
break;
case "|=":
_19a.push(_1a0("-")+".first().toUpperCase() == "+_19e.value.toUpperCase().inspect());
break;
case "!=":
_19a.push(_19f+" != "+_19e.value.inspect());
break;
case "":
case undefined:
_19a.push("element.hasAttribute("+_19e.name.inspect()+")");
break;
default:
throw "Unknown operator "+_19e.operator+" in selector";
}
});
}
return _19a.join(" && ");
},compileMatcher:function(){
this.match=new Function("element","if (!element.tagName) return false;       element = $(element);       return "+this.buildMatchExpression());
},findElements:function(_1a2){
var _1a3;
if(_1a3=$(this.params.id)){
if(this.match(_1a3)){
if(!_1a2||Element.childOf(_1a3,_1a2)){
return [_1a3];
}
}
}
_1a2=(_1a2||document).getElementsByTagName(this.params.tagName||"*");
var _1a4=[];
for(var i=0,_1a6=_1a2.length;i<_1a6;i++){
if(this.match(_1a3=_1a2[i])){
_1a4.push(Element.extend(_1a3));
}
}
return _1a4;
},toString:function(){
return this.expression;
}};
Object.extend(Selector,{matchElements:function(_1a7,_1a8){
var _1a9=new Selector(_1a8);
return _1a7.select(_1a9.match.bind(_1a9)).map(Element.extend);
},findElement:function(_1aa,_1ab,_1ac){
if(typeof _1ab=="number"){
_1ac=_1ab,_1ab=false;
}
return Selector.matchElements(_1aa,_1ab||"*")[_1ac||0];
},findChildElements:function(_1ad,_1ae){
return _1ae.map(function(_1af){
return _1af.match(/[^\s"]+(?:"[^"]*"[^\s"]+)*/g).inject([null],function(_1b0,expr){
var _1b2=new Selector(expr);
return _1b0.inject([],function(_1b3,_1b4){
return _1b3.concat(_1b2.findElements(_1b4||_1ad));
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
},serializeElements:function(_1b6,_1b7){
var data=_1b6.inject({},function(_1b9,_1ba){
if(!_1ba.disabled&&_1ba.name){
var key=_1ba.name,_1bc=$(_1ba).getValue();
if(_1bc!=undefined){
if(_1b9[key]){
if(_1b9[key].constructor!=Array){
_1b9[key]=[_1b9[key]];
}
_1b9[key].push(_1bc);
}else{
_1b9[key]=_1bc;
}
}
}
return _1b9;
});
return _1b7?data:Hash.toQueryString(data);
}};
Form.Methods={serialize:function(form,_1be){
return Form.serializeElements(Form.getElements(form),_1be);
},getElements:function(form){
return $A($(form).getElementsByTagName("*")).inject([],function(_1c0,_1c1){
if(Form.Element.Serializers[_1c1.tagName.toLowerCase()]){
_1c0.push(Element.extend(_1c1));
}
return _1c0;
});
},getInputs:function(form,_1c3,name){
form=$(form);
var _1c5=form.getElementsByTagName("input");
if(!_1c3&&!name){
return $A(_1c5).map(Element.extend);
}
for(var i=0,_1c7=[],_1c8=_1c5.length;i<_1c8;i++){
var _1c9=_1c5[i];
if((_1c3&&_1c9.type!=_1c3)||(name&&_1c9.name!=name)){
continue;
}
_1c7.push(Element.extend(_1c9));
}
return _1c7;
},disable:function(form){
form=$(form);
form.getElements().each(function(_1cb){
_1cb.blur();
_1cb.disabled="true";
});
return form;
},enable:function(form){
form=$(form);
form.getElements().each(function(_1cd){
_1cd.disabled="";
});
return form;
},findFirstElement:function(form){
return $(form).getElements().find(function(_1cf){
return _1cf.type!="hidden"&&!_1cf.disabled&&["input","select","textarea"].include(_1cf.tagName.toLowerCase());
});
},focusFirstElement:function(form){
form=$(form);
form.findFirstElement().activate();
return form;
}};
Object.extend(Form,Form.Methods);
Form.Element={focus:function(_1d1){
$(_1d1).focus();
return _1d1;
},select:function(_1d2){
$(_1d2).select();
return _1d2;
}};
Form.Element.Methods={serialize:function(_1d3){
_1d3=$(_1d3);
if(!_1d3.disabled&&_1d3.name){
var _1d4=_1d3.getValue();
if(_1d4!=undefined){
var pair={};
pair[_1d3.name]=_1d4;
return Hash.toQueryString(pair);
}
}
return "";
},getValue:function(_1d6){
_1d6=$(_1d6);
var _1d7=_1d6.tagName.toLowerCase();
return Form.Element.Serializers[_1d7](_1d6);
},clear:function(_1d8){
$(_1d8).value="";
return _1d8;
},present:function(_1d9){
return $(_1d9).value!="";
},activate:function(_1da){
_1da=$(_1da);
_1da.focus();
if(_1da.select&&(_1da.tagName.toLowerCase()!="input"||!["button","reset","submit"].include(_1da.type))){
_1da.select();
}
return _1da;
},disable:function(_1db){
_1db=$(_1db);
_1db.disabled=true;
return _1db;
},enable:function(_1dc){
_1dc=$(_1dc);
_1dc.blur();
_1dc.disabled=false;
return _1dc;
}};
Object.extend(Form.Element,Form.Element.Methods);
var Field=Form.Element;
var $F=Form.Element.getValue;
Form.Element.Serializers={input:function(_1dd){
switch(_1dd.type.toLowerCase()){
case "checkbox":
case "radio":
return Form.Element.Serializers.inputSelector(_1dd);
default:
return Form.Element.Serializers.textarea(_1dd);
}
},inputSelector:function(_1de){
return _1de.checked?_1de.value:null;
},textarea:function(_1df){
return _1df.value;
},select:function(_1e0){
return this[_1e0.type=="select-one"?"selectOne":"selectMany"](_1e0);
},selectOne:function(_1e1){
var _1e2=_1e1.selectedIndex;
return _1e2>=0?this.optionValue(_1e1.options[_1e2]):null;
},selectMany:function(_1e3){
var _1e4,_1e5=_1e3.length;
if(!_1e5){
return null;
}
for(var i=0,_1e4=[];i<_1e5;i++){
var opt=_1e3.options[i];
if(opt.selected){
_1e4.push(this.optionValue(opt));
}
}
return _1e4;
},optionValue:function(opt){
return Element.extend(opt).hasAttribute("value")?opt.value:opt.text;
}};
Abstract.TimedObserver=function(){
};
Abstract.TimedObserver.prototype={initialize:function(_1e9,_1ea,_1eb){
this.frequency=_1ea;
this.element=$(_1e9);
this.callback=_1eb;
this.lastValue=this.getValue();
this.registerCallback();
},registerCallback:function(){
setInterval(this.onTimerEvent.bind(this),this.frequency*1000);
},onTimerEvent:function(){
var _1ec=this.getValue();
var _1ed=("string"==typeof this.lastValue&&"string"==typeof _1ec?this.lastValue!=_1ec:String(this.lastValue)!=String(_1ec));
if(_1ed){
this.callback(this.element,_1ec);
this.lastValue=_1ec;
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
Abstract.EventObserver.prototype={initialize:function(_1ee,_1ef){
this.element=$(_1ee);
this.callback=_1ef;
this.lastValue=this.getValue();
if(this.element.tagName.toLowerCase()=="form"){
this.registerFormCallbacks();
}else{
this.registerCallback(this.element);
}
},onElementEvent:function(){
var _1f0=this.getValue();
if(this.lastValue!=_1f0){
this.callback(this.element,_1f0);
this.lastValue=_1f0;
}
},registerFormCallbacks:function(){
Form.getElements(this.element).each(this.registerCallback.bind(this));
},registerCallback:function(_1f1){
if(_1f1.type){
switch(_1f1.type.toLowerCase()){
case "checkbox":
case "radio":
Event.observe(_1f1,"click",this.onElementEvent.bind(this));
break;
default:
Event.observe(_1f1,"change",this.onElementEvent.bind(this));
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
Object.extend(Event,{KEY_BACKSPACE:8,KEY_TAB:9,KEY_RETURN:13,KEY_ESC:27,KEY_LEFT:37,KEY_UP:38,KEY_RIGHT:39,KEY_DOWN:40,KEY_DELETE:46,KEY_HOME:36,KEY_END:35,KEY_PAGEUP:33,KEY_PAGEDOWN:34,element:function(_1f2){
return _1f2.target||_1f2.srcElement;
},isLeftClick:function(_1f3){
return (((_1f3.which)&&(_1f3.which==1))||((_1f3.button)&&(_1f3.button==1)));
},pointerX:function(_1f4){
return _1f4.pageX||(_1f4.clientX+(document.documentElement.scrollLeft||document.body.scrollLeft));
},pointerY:function(_1f5){
return _1f5.pageY||(_1f5.clientY+(document.documentElement.scrollTop||document.body.scrollTop));
},stop:function(_1f6){
if(_1f6.preventDefault){
_1f6.preventDefault();
_1f6.stopPropagation();
}else{
_1f6.returnValue=false;
_1f6.cancelBubble=true;
}
},findElement:function(_1f7,_1f8){
var _1f9=Event.element(_1f7);
while(_1f9.parentNode&&(!_1f9.tagName||(_1f9.tagName.toUpperCase()!=_1f8.toUpperCase()))){
_1f9=_1f9.parentNode;
}
return _1f9;
},observers:false,_observeAndCache:function(_1fa,name,_1fc,_1fd){
if(!this.observers){
this.observers=[];
}
if(_1fa.addEventListener){
this.observers.push([_1fa,name,_1fc,_1fd]);
_1fa.addEventListener(name,_1fc,_1fd);
}else{
if(_1fa.attachEvent){
this.observers.push([_1fa,name,_1fc,_1fd]);
_1fa.attachEvent("on"+name,_1fc);
}
}
},unloadCache:function(){
if(!Event.observers){
return;
}
for(var i=0,_1ff=Event.observers.length;i<_1ff;i++){
Event.stopObserving.apply(this,Event.observers[i]);
Event.observers[i][0]=null;
}
Event.observers=false;
},observe:function(_200,name,_202,_203){
_200=$(_200);
_203=_203||false;
if(name=="keypress"&&(navigator.appVersion.match(/Konqueror|Safari|KHTML/)||_200.attachEvent)){
name="keydown";
}
Event._observeAndCache(_200,name,_202,_203);
},stopObserving:function(_204,name,_206,_207){
_204=$(_204);
_207=_207||false;
if(name=="keypress"&&(navigator.appVersion.match(/Konqueror|Safari|KHTML/)||_204.detachEvent)){
name="keydown";
}
if(_204.removeEventListener){
_204.removeEventListener(name,_206,_207);
}else{
if(_204.detachEvent){
try{
_204.detachEvent("on"+name,_206);
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
},realOffset:function(_208){
var _209=0,_20a=0;
do{
_209+=_208.scrollTop||0;
_20a+=_208.scrollLeft||0;
_208=_208.parentNode;
}while(_208);
return [_20a,_209];
},cumulativeOffset:function(_20b){
var _20c=0,_20d=0;
do{
_20c+=_20b.offsetTop||0;
_20d+=_20b.offsetLeft||0;
_20b=_20b.offsetParent;
}while(_20b);
return [_20d,_20c];
},positionedOffset:function(_20e){
var _20f=0,_210=0;
do{
_20f+=_20e.offsetTop||0;
_210+=_20e.offsetLeft||0;
_20e=_20e.offsetParent;
if(_20e){
if(_20e.tagName=="BODY"){
break;
}
var p=Element.getStyle(_20e,"position");
if(p=="relative"||p=="absolute"){
break;
}
}
}while(_20e);
return [_210,_20f];
},offsetParent:function(_212){
if(_212.offsetParent){
return _212.offsetParent;
}
if(_212==document.body){
return _212;
}
while((_212=_212.parentNode)&&_212!=document.body){
if(Element.getStyle(_212,"position")!="static"){
return _212;
}
}
return document.body;
},within:function(_213,x,y){
if(this.includeScrollOffsets){
return this.withinIncludingScrolloffsets(_213,x,y);
}
this.xcomp=x;
this.ycomp=y;
this.offset=this.cumulativeOffset(_213);
return (y>=this.offset[1]&&y<this.offset[1]+_213.offsetHeight&&x>=this.offset[0]&&x<this.offset[0]+_213.offsetWidth);
},withinIncludingScrolloffsets:function(_216,x,y){
var _219=this.realOffset(_216);
this.xcomp=x+_219[0]-this.deltaX;
this.ycomp=y+_219[1]-this.deltaY;
this.offset=this.cumulativeOffset(_216);
return (this.ycomp>=this.offset[1]&&this.ycomp<this.offset[1]+_216.offsetHeight&&this.xcomp>=this.offset[0]&&this.xcomp<this.offset[0]+_216.offsetWidth);
},overlap:function(mode,_21b){
if(!mode){
return 0;
}
if(mode=="vertical"){
return ((this.offset[1]+_21b.offsetHeight)-this.ycomp)/_21b.offsetHeight;
}
if(mode=="horizontal"){
return ((this.offset[0]+_21b.offsetWidth)-this.xcomp)/_21b.offsetWidth;
}
},page:function(_21c){
var _21d=0,_21e=0;
var _21f=_21c;
do{
_21d+=_21f.offsetTop||0;
_21e+=_21f.offsetLeft||0;
if(_21f.offsetParent==document.body){
if(Element.getStyle(_21f,"position")=="absolute"){
break;
}
}
}while(_21f=_21f.offsetParent);
_21f=_21c;
do{
if(!window.opera||_21f.tagName=="BODY"){
_21d-=_21f.scrollTop||0;
_21e-=_21f.scrollLeft||0;
}
}while(_21f=_21f.parentNode);
return [_21e,_21d];
},clone:function(_220,_221){
var _222=Object.extend({setLeft:true,setTop:true,setWidth:true,setHeight:true,offsetTop:0,offsetLeft:0},arguments[2]||{});
_220=$(_220);
var p=Position.page(_220);
_221=$(_221);
var _224=[0,0];
var _225=null;
if(Element.getStyle(_221,"position")=="absolute"){
_225=Position.offsetParent(_221);
_224=Position.page(_225);
}
if(_225==document.body){
_224[0]-=document.body.offsetLeft;
_224[1]-=document.body.offsetTop;
}
if(_222.setLeft){
_221.style.left=(p[0]-_224[0]+_222.offsetLeft)+"px";
}
if(_222.setTop){
_221.style.top=(p[1]-_224[1]+_222.offsetTop)+"px";
}
if(_222.setWidth){
_221.style.width=_220.offsetWidth+"px";
}
if(_222.setHeight){
_221.style.height=_220.offsetHeight+"px";
}
},absolutize:function(_226){
_226=$(_226);
if(_226.style.position=="absolute"){
return;
}
Position.prepare();
var _227=Position.positionedOffset(_226);
var top=_227[1];
var left=_227[0];
var _22a=_226.clientWidth;
var _22b=_226.clientHeight;
_226._originalLeft=left-parseFloat(_226.style.left||0);
_226._originalTop=top-parseFloat(_226.style.top||0);
_226._originalWidth=_226.style.width;
_226._originalHeight=_226.style.height;
_226.style.position="absolute";
_226.style.top=top+"px";
_226.style.left=left+"px";
_226.style.width=_22a+"px";
_226.style.height=_22b+"px";
},relativize:function(_22c){
_22c=$(_22c);
if(_22c.style.position=="relative"){
return;
}
Position.prepare();
_22c.style.position="relative";
var top=parseFloat(_22c.style.top||0)-(_22c._originalTop||0);
var left=parseFloat(_22c.style.left||0)-(_22c._originalLeft||0);
_22c.style.top=top+"px";
_22c.style.left=left+"px";
_22c.style.height=_22c._originalHeight;
_22c.style.width=_22c._originalWidth;
}};
if(/Konqueror|Safari|KHTML/.test(navigator.userAgent)){
Position.cumulativeOffset=function(_22f){
var _230=0,_231=0;
do{
_230+=_22f.offsetTop||0;
_231+=_22f.offsetLeft||0;
if(_22f.offsetParent==document.body){
if(Element.getStyle(_22f,"position")=="absolute"){
break;
}
}
_22f=_22f.offsetParent;
}while(_22f);
return [_231,_230];
};
}
Element.addMethods();
String.prototype.parseColor=function(){
var _232="#";
if(this.slice(0,4)=="rgb("){
var cols=this.slice(4,this.length-1).split(",");
var i=0;
do{
_232+=parseInt(cols[i]).toColorPart();
}while(++i<3);
}else{
if(this.slice(0,1)=="#"){
if(this.length==4){
for(var i=1;i<4;i++){
_232+=(this.charAt(i)+this.charAt(i)).toLowerCase();
}
}
if(this.length==7){
_232=this.toLowerCase();
}
}
}
return (_232.length==7?_232:(arguments[0]||this));
};
Element.collectTextNodes=function(_235){
return $A($(_235).childNodes).collect(function(node){
return (node.nodeType==3?node.nodeValue:(node.hasChildNodes()?Element.collectTextNodes(node):""));
}).flatten().join("");
};
Element.collectTextNodesIgnoreClass=function(_237,_238){
return $A($(_237).childNodes).collect(function(node){
return (node.nodeType==3?node.nodeValue:((node.hasChildNodes()&&!Element.hasClassName(node,_238))?Element.collectTextNodesIgnoreClass(node,_238):""));
}).flatten().join("");
};
Element.setContentZoom=function(_23a,_23b){
_23a=$(_23a);
_23a.setStyle({fontSize:(_23b/100)+"em"});
if(navigator.appVersion.indexOf("AppleWebKit")>0){
window.scrollBy(0,0);
}
return _23a;
};
Element.getOpacity=function(_23c){
_23c=$(_23c);
var _23d;
if(_23d=_23c.getStyle("opacity")){
return parseFloat(_23d);
}
if(_23d=(_23c.getStyle("filter")||"").match(/alpha\(opacity=(.*)\)/)){
if(_23d[1]){
return parseFloat(_23d[1])/100;
}
}
return 1;
};
Element.setOpacity=function(_23e,_23f){
_23e=$(_23e);
if(_23f==1){
_23e.setStyle({opacity:(/Gecko/.test(navigator.userAgent)&&!/Konqueror|Safari|KHTML/.test(navigator.userAgent))?0.999999:1});
if(/MSIE/.test(navigator.userAgent)&&!window.opera){
_23e.setStyle({filter:Element.getStyle(_23e,"filter").replace(/alpha\([^\)]*\)/gi,"")});
}
}else{
if(_23f<0.00001){
_23f=0;
}
_23e.setStyle({opacity:_23f});
if(/MSIE/.test(navigator.userAgent)&&!window.opera){
_23e.setStyle({filter:_23e.getStyle("filter").replace(/alpha\([^\)]*\)/gi,"")+"alpha(opacity="+_23f*100+")"});
}
}
return _23e;
};
Element.getInlineOpacity=function(_240){
return $(_240).style.opacity||"";
};
Element.forceRerendering=function(_241){
try{
_241=$(_241);
var n=document.createTextNode(" ");
_241.appendChild(n);
_241.removeChild(n);
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
var Effect={_elementDoesNotExistError:{name:"ElementDoesNotExistError",message:"The specified DOM element does not exist, but is required for this effect to operate"},tagifyText:function(_245){
if(typeof Builder=="undefined"){
throw ("Effect.tagifyText requires including script.aculo.us' builder.js library");
}
var _246="position:relative";
if(/MSIE/.test(navigator.userAgent)&&!window.opera){
_246+=";zoom:1";
}
_245=$(_245);
$A(_245.childNodes).each(function(_247){
if(_247.nodeType==3){
_247.nodeValue.toArray().each(function(_248){
_245.insertBefore(Builder.node("span",{style:_246},_248==" "?String.fromCharCode(160):_248),_247);
});
Element.remove(_247);
}
});
},multiple:function(_249,_24a){
var _24b;
if(((typeof _249=="object")||(typeof _249=="function"))&&(_249.length)){
_24b=_249;
}else{
_24b=$(_249).childNodes;
}
var _24c=Object.extend({speed:0.1,delay:0},arguments[2]||{});
var _24d=_24c.delay;
$A(_24b).each(function(_24e,_24f){
new _24a(_24e,Object.extend(_24c,{delay:_24f*_24c.speed+_24d}));
});
},PAIRS:{"slide":["SlideDown","SlideUp"],"blind":["BlindDown","BlindUp"],"appear":["Appear","Fade"]},toggle:function(_250,_251){
_250=$(_250);
_251=(_251||"appear").toLowerCase();
var _252=Object.extend({queue:{position:"end",scope:(_250.id||"global"),limit:1}},arguments[2]||{});
Effect[_250.visible()?Effect.PAIRS[_251][1]:Effect.PAIRS[_251][0]](_250,_252);
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
},pulse:function(pos,_258){
_258=_258||5;
return (Math.round((pos%(1/_258))*_258)==0?((pos*_258*2)-Math.floor(pos*_258*2)):1-((pos*_258*2)-Math.floor(pos*_258*2)));
},none:function(pos){
return 0;
},full:function(pos){
return 1;
}};
Effect.ScopedQueue=Class.create();
Object.extend(Object.extend(Effect.ScopedQueue.prototype,Enumerable),{initialize:function(){
this.effects=[];
this.interval=null;
},_each:function(_25b){
this.effects._each(_25b);
},add:function(_25c){
var _25d=new Date().getTime();
var _25e=(typeof _25c.options.queue=="string")?_25c.options.queue:_25c.options.queue.position;
switch(_25e){
case "front":
this.effects.findAll(function(e){
return e.state=="idle";
}).each(function(e){
e.startOn+=_25c.finishOn;
e.finishOn+=_25c.finishOn;
});
break;
case "with-last":
_25d=this.effects.pluck("startOn").max()||_25d;
break;
case "end":
_25d=this.effects.pluck("finishOn").max()||_25d;
break;
}
_25c.startOn+=_25d;
_25c.finishOn+=_25d;
if(!_25c.options.queue.limit||(this.effects.length<_25c.options.queue.limit)){
this.effects.push(_25c);
}
if(!this.interval){
this.interval=setInterval(this.loop.bind(this),40);
}
},remove:function(_261){
this.effects=this.effects.reject(function(e){
return e==_261;
});
if(this.effects.length==0){
clearInterval(this.interval);
this.interval=null;
}
},loop:function(){
var _263=new Date().getTime();
this.effects.invoke("loop",_263);
}});
Effect.Queues={instances:$H(),get:function(_264){
if(typeof _264!="string"){
return _264;
}
if(!this.instances[_264]){
this.instances[_264]=new Effect.ScopedQueue();
}
return this.instances[_264];
}};
Effect.Queue=Effect.Queues.get("global");
Effect.DefaultOptions={transition:Effect.Transitions.sinoidal,duration:1,fps:25,sync:false,from:0,to:1,delay:0,queue:"parallel"};
Effect.Base=function(){
};
Effect.Base.prototype={position:null,start:function(_265){
this.options=Object.extend(Object.extend({},Effect.DefaultOptions),_265||{});
this.currentFrame=0;
this.state="idle";
this.startOn=this.options.delay*1000;
this.finishOn=this.startOn+(this.options.duration*1000);
this.event("beforeStart");
if(!this.options.sync){
Effect.Queues.get(typeof this.options.queue=="string"?"global":this.options.queue.scope).add(this);
}
},loop:function(_266){
if(_266>=this.startOn){
if(_266>=this.finishOn){
this.render(1);
this.cancel();
this.event("beforeFinish");
if(this.finish){
this.finish();
}
this.event("afterFinish");
return;
}
var pos=(_266-this.startOn)/(this.finishOn-this.startOn);
var _268=Math.round(pos*this.options.fps*this.options.duration);
if(_268>this.currentFrame){
this.render(pos);
this.currentFrame=_268;
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
},event:function(_26a){
if(this.options[_26a+"Internal"]){
this.options[_26a+"Internal"](this);
}
if(this.options[_26a]){
this.options[_26a](this);
}
},inspect:function(){
return "#<Effect:"+$H(this).inspect()+",options:"+$H(this.options).inspect()+">";
}};
Effect.Parallel=Class.create();
Object.extend(Object.extend(Effect.Parallel.prototype,Effect.Base.prototype),{initialize:function(_26b){
this.effects=_26b||[];
this.start(arguments[1]);
},update:function(_26c){
this.effects.invoke("render",_26c);
},finish:function(_26d){
this.effects.each(function(_26e){
_26e.render(1);
_26e.cancel();
_26e.event("beforeFinish");
if(_26e.finish){
_26e.finish(_26d);
}
_26e.event("afterFinish");
});
}});
Effect.Event=Class.create();
Object.extend(Object.extend(Effect.Event.prototype,Effect.Base.prototype),{initialize:function(){
var _26f=Object.extend({duration:0},arguments[0]||{});
this.start(_26f);
},update:Prototype.emptyFunction});
Effect.Opacity=Class.create();
Object.extend(Object.extend(Effect.Opacity.prototype,Effect.Base.prototype),{initialize:function(_270){
this.element=$(_270);
if(!this.element){
throw (Effect._elementDoesNotExistError);
}
if(/MSIE/.test(navigator.userAgent)&&!window.opera&&(!this.element.currentStyle.hasLayout)){
this.element.setStyle({zoom:1});
}
var _271=Object.extend({from:this.element.getOpacity()||0,to:1},arguments[1]||{});
this.start(_271);
},update:function(_272){
this.element.setOpacity(_272);
}});
Effect.Move=Class.create();
Object.extend(Object.extend(Effect.Move.prototype,Effect.Base.prototype),{initialize:function(_273){
this.element=$(_273);
if(!this.element){
throw (Effect._elementDoesNotExistError);
}
var _274=Object.extend({x:0,y:0,mode:"relative"},arguments[1]||{});
this.start(_274);
},setup:function(){
this.element.makePositioned();
this.originalLeft=parseFloat(this.element.getStyle("left")||"0");
this.originalTop=parseFloat(this.element.getStyle("top")||"0");
if(this.options.mode=="absolute"){
this.options.x=this.options.x-this.originalLeft;
this.options.y=this.options.y-this.originalTop;
}
},update:function(_275){
this.element.setStyle({left:Math.round(this.options.x*_275+this.originalLeft)+"px",top:Math.round(this.options.y*_275+this.originalTop)+"px"});
}});
Effect.MoveBy=function(_276,_277,_278){
return new Effect.Move(_276,Object.extend({x:_278,y:_277},arguments[3]||{}));
};
Effect.Scale=Class.create();
Object.extend(Object.extend(Effect.Scale.prototype,Effect.Base.prototype),{initialize:function(_279,_27a){
this.element=$(_279);
if(!this.element){
throw (Effect._elementDoesNotExistError);
}
var _27b=Object.extend({scaleX:true,scaleY:true,scaleContent:true,scaleFromCenter:false,scaleMode:"box",scaleFrom:100,scaleTo:_27a},arguments[2]||{});
this.start(_27b);
},setup:function(){
this.restoreAfterFinish=this.options.restoreAfterFinish||false;
this.elementPositioning=this.element.getStyle("position");
this.originalStyle={};
["top","left","width","height","fontSize"].each(function(k){
this.originalStyle[k]=this.element.style[k];
}.bind(this));
this.originalTop=this.element.offsetTop;
this.originalLeft=this.element.offsetLeft;
var _27d=this.element.getStyle("font-size")||"100%";
["em","px","%","pt"].each(function(_27e){
if(_27d.indexOf(_27e)>0){
this.fontSize=parseFloat(_27d);
this.fontSizeType=_27e;
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
},update:function(_27f){
var _280=(this.options.scaleFrom/100)+(this.factor*_27f);
if(this.options.scaleContent&&this.fontSize){
this.element.setStyle({fontSize:this.fontSize*_280+this.fontSizeType});
}
this.setDimensions(this.dims[0]*_280,this.dims[1]*_280);
},finish:function(_281){
if(this.restoreAfterFinish){
this.element.setStyle(this.originalStyle);
}
},setDimensions:function(_282,_283){
var d={};
if(this.options.scaleX){
d.width=Math.round(_283)+"px";
}
if(this.options.scaleY){
d.height=Math.round(_282)+"px";
}
if(this.options.scaleFromCenter){
var topd=(_282-this.dims[0])/2;
var _286=(_283-this.dims[1])/2;
if(this.elementPositioning=="absolute"){
if(this.options.scaleY){
d.top=this.originalTop-topd+"px";
}
if(this.options.scaleX){
d.left=this.originalLeft-_286+"px";
}
}else{
if(this.options.scaleY){
d.top=-topd+"px";
}
if(this.options.scaleX){
d.left=-_286+"px";
}
}
}
this.element.setStyle(d);
}});
Effect.Highlight=Class.create();
Object.extend(Object.extend(Effect.Highlight.prototype,Effect.Base.prototype),{initialize:function(_287){
this.element=$(_287);
if(!this.element){
throw (Effect._elementDoesNotExistError);
}
var _288=Object.extend({startcolor:"#ffff99"},arguments[1]||{});
this.start(_288);
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
},update:function(_28b){
this.element.setStyle({backgroundColor:$R(0,2).inject("#",function(m,v,i){
return m+(Math.round(this._base[i]+(this._delta[i]*_28b)).toColorPart());
}.bind(this))});
},finish:function(){
this.element.setStyle(Object.extend(this.oldStyle,{backgroundColor:this.options.restorecolor}));
}});
Effect.ScrollTo=Class.create();
Object.extend(Object.extend(Effect.ScrollTo.prototype,Effect.Base.prototype),{initialize:function(_28f){
this.element=$(_28f);
this.start(arguments[1]||{});
},setup:function(){
Position.prepare();
var _290=Position.cumulativeOffset(this.element);
if(this.options.offset){
_290[1]+=this.options.offset;
}
var max=window.innerHeight?window.height-window.innerHeight:document.body.scrollHeight-(document.documentElement.clientHeight?document.documentElement.clientHeight:document.body.clientHeight);
this.scrollStart=Position.deltaY;
this.delta=(_290[1]>max?max:_290[1])-this.scrollStart;
},update:function(_292){
Position.prepare();
window.scrollTo(Position.deltaX,this.scrollStart+(_292*this.delta));
}});
Effect.Fade=function(_293){
_293=$(_293);
var _294=_293.getInlineOpacity();
var _295=Object.extend({from:_293.getOpacity()||1,to:0,afterFinishInternal:function(_296){
if(_296.options.to!=0){
return;
}
_296.element.hide().setStyle({opacity:_294});
}},arguments[1]||{});
return new Effect.Opacity(_293,_295);
};
Effect.Appear=function(_297){
_297=$(_297);
var _298=Object.extend({from:(_297.getStyle("display")=="none"?0:_297.getOpacity()||0),to:1,afterFinishInternal:function(_299){
_299.element.forceRerendering();
},beforeSetup:function(_29a){
_29a.element.setOpacity(_29a.options.from).show();
}},arguments[1]||{});
return new Effect.Opacity(_297,_298);
};
Effect.Puff=function(_29b){
_29b=$(_29b);
var _29c={opacity:_29b.getInlineOpacity(),position:_29b.getStyle("position"),top:_29b.style.top,left:_29b.style.left,width:_29b.style.width,height:_29b.style.height};
return new Effect.Parallel([new Effect.Scale(_29b,200,{sync:true,scaleFromCenter:true,scaleContent:true,restoreAfterFinish:true}),new Effect.Opacity(_29b,{sync:true,to:0})],Object.extend({duration:1,beforeSetupInternal:function(_29d){
Position.absolutize(_29d.effects[0].element);
},afterFinishInternal:function(_29e){
_29e.effects[0].element.hide().setStyle(_29c);
}},arguments[1]||{}));
};
Effect.BlindUp=function(_29f){
_29f=$(_29f);
_29f.makeClipping();
return new Effect.Scale(_29f,0,Object.extend({scaleContent:false,scaleX:false,restoreAfterFinish:true,afterFinishInternal:function(_2a0){
_2a0.element.hide().undoClipping();
}},arguments[1]||{}));
};
Effect.BlindDown=function(_2a1){
_2a1=$(_2a1);
var _2a2=_2a1.getDimensions();
return new Effect.Scale(_2a1,100,Object.extend({scaleContent:false,scaleX:false,scaleFrom:0,scaleMode:{originalHeight:_2a2.height,originalWidth:_2a2.width},restoreAfterFinish:true,afterSetup:function(_2a3){
_2a3.element.makeClipping().setStyle({height:"0px"}).show();
},afterFinishInternal:function(_2a4){
_2a4.element.undoClipping();
}},arguments[1]||{}));
};
Effect.SwitchOff=function(_2a5){
_2a5=$(_2a5);
var _2a6=_2a5.getInlineOpacity();
return new Effect.Appear(_2a5,Object.extend({duration:0.4,from:0,transition:Effect.Transitions.flicker,afterFinishInternal:function(_2a7){
new Effect.Scale(_2a7.element,1,{duration:0.3,scaleFromCenter:true,scaleX:false,scaleContent:false,restoreAfterFinish:true,beforeSetup:function(_2a8){
_2a8.element.makePositioned().makeClipping();
},afterFinishInternal:function(_2a9){
_2a9.element.hide().undoClipping().undoPositioned().setStyle({opacity:_2a6});
}});
}},arguments[1]||{}));
};
Effect.DropOut=function(_2aa){
_2aa=$(_2aa);
var _2ab={top:_2aa.getStyle("top"),left:_2aa.getStyle("left"),opacity:_2aa.getInlineOpacity()};
return new Effect.Parallel([new Effect.Move(_2aa,{x:0,y:100,sync:true}),new Effect.Opacity(_2aa,{sync:true,to:0})],Object.extend({duration:0.5,beforeSetup:function(_2ac){
_2ac.effects[0].element.makePositioned();
},afterFinishInternal:function(_2ad){
_2ad.effects[0].element.hide().undoPositioned().setStyle(_2ab);
}},arguments[1]||{}));
};
Effect.Shake=function(_2ae){
_2ae=$(_2ae);
var _2af={top:_2ae.getStyle("top"),left:_2ae.getStyle("left")};
return new Effect.Move(_2ae,{x:20,y:0,duration:0.05,afterFinishInternal:function(_2b0){
new Effect.Move(_2b0.element,{x:-40,y:0,duration:0.1,afterFinishInternal:function(_2b1){
new Effect.Move(_2b1.element,{x:40,y:0,duration:0.1,afterFinishInternal:function(_2b2){
new Effect.Move(_2b2.element,{x:-40,y:0,duration:0.1,afterFinishInternal:function(_2b3){
new Effect.Move(_2b3.element,{x:40,y:0,duration:0.1,afterFinishInternal:function(_2b4){
new Effect.Move(_2b4.element,{x:-20,y:0,duration:0.05,afterFinishInternal:function(_2b5){
_2b5.element.undoPositioned().setStyle(_2af);
}});
}});
}});
}});
}});
}});
};
Effect.SlideDown=function(_2b6){
_2b6=$(_2b6).cleanWhitespace();
var _2b7=_2b6.down().getStyle("bottom");
var _2b8=_2b6.getDimensions();
return new Effect.Scale(_2b6,100,Object.extend({scaleContent:false,scaleX:false,scaleFrom:window.opera?0:1,scaleMode:{originalHeight:_2b8.height,originalWidth:_2b8.width},restoreAfterFinish:true,afterSetup:function(_2b9){
_2b9.element.makePositioned();
_2b9.element.down().makePositioned();
if(window.opera){
_2b9.element.setStyle({top:""});
}
_2b9.element.makeClipping().setStyle({height:"0px"}).show();
},afterUpdateInternal:function(_2ba){
_2ba.element.down().setStyle({bottom:(_2ba.dims[0]-_2ba.element.clientHeight)+"px"});
},afterFinishInternal:function(_2bb){
_2bb.element.undoClipping().undoPositioned();
_2bb.element.down().undoPositioned().setStyle({bottom:_2b7});
}},arguments[1]||{}));
};
Effect.SlideUp=function(_2bc){
_2bc=$(_2bc).cleanWhitespace();
var _2bd=_2bc.down().getStyle("bottom");
return new Effect.Scale(_2bc,window.opera?0:1,Object.extend({scaleContent:false,scaleX:false,scaleMode:"box",scaleFrom:100,restoreAfterFinish:true,beforeStartInternal:function(_2be){
_2be.element.makePositioned();
_2be.element.down().makePositioned();
if(window.opera){
_2be.element.setStyle({top:""});
}
_2be.element.makeClipping().show();
},afterUpdateInternal:function(_2bf){
_2bf.element.down().setStyle({bottom:(_2bf.dims[0]-_2bf.element.clientHeight)+"px"});
},afterFinishInternal:function(_2c0){
_2c0.element.hide().undoClipping().undoPositioned().setStyle({bottom:_2bd});
_2c0.element.down().undoPositioned();
}},arguments[1]||{}));
};
Effect.Squish=function(_2c1){
return new Effect.Scale(_2c1,window.opera?1:0,{restoreAfterFinish:true,beforeSetup:function(_2c2){
_2c2.element.makeClipping();
},afterFinishInternal:function(_2c3){
_2c3.element.hide().undoClipping();
}});
};
Effect.Grow=function(_2c4){
_2c4=$(_2c4);
var _2c5=Object.extend({direction:"center",moveTransition:Effect.Transitions.sinoidal,scaleTransition:Effect.Transitions.sinoidal,opacityTransition:Effect.Transitions.full},arguments[1]||{});
var _2c6={top:_2c4.style.top,left:_2c4.style.left,height:_2c4.style.height,width:_2c4.style.width,opacity:_2c4.getInlineOpacity()};
var dims=_2c4.getDimensions();
var _2c8,_2c9;
var _2ca,_2cb;
switch(_2c5.direction){
case "top-left":
_2c8=_2c9=_2ca=_2cb=0;
break;
case "top-right":
_2c8=dims.width;
_2c9=_2cb=0;
_2ca=-dims.width;
break;
case "bottom-left":
_2c8=_2ca=0;
_2c9=dims.height;
_2cb=-dims.height;
break;
case "bottom-right":
_2c8=dims.width;
_2c9=dims.height;
_2ca=-dims.width;
_2cb=-dims.height;
break;
case "center":
_2c8=dims.width/2;
_2c9=dims.height/2;
_2ca=-dims.width/2;
_2cb=-dims.height/2;
break;
}
return new Effect.Move(_2c4,{x:_2c8,y:_2c9,duration:0.01,beforeSetup:function(_2cc){
_2cc.element.hide().makeClipping().makePositioned();
},afterFinishInternal:function(_2cd){
new Effect.Parallel([new Effect.Opacity(_2cd.element,{sync:true,to:1,from:0,transition:_2c5.opacityTransition}),new Effect.Move(_2cd.element,{x:_2ca,y:_2cb,sync:true,transition:_2c5.moveTransition}),new Effect.Scale(_2cd.element,100,{scaleMode:{originalHeight:dims.height,originalWidth:dims.width},sync:true,scaleFrom:window.opera?1:0,transition:_2c5.scaleTransition,restoreAfterFinish:true})],Object.extend({beforeSetup:function(_2ce){
_2ce.effects[0].element.setStyle({height:"0px"}).show();
},afterFinishInternal:function(_2cf){
_2cf.effects[0].element.undoClipping().undoPositioned().setStyle(_2c6);
}},_2c5));
}});
};
Effect.Shrink=function(_2d0){
_2d0=$(_2d0);
var _2d1=Object.extend({direction:"center",moveTransition:Effect.Transitions.sinoidal,scaleTransition:Effect.Transitions.sinoidal,opacityTransition:Effect.Transitions.none},arguments[1]||{});
var _2d2={top:_2d0.style.top,left:_2d0.style.left,height:_2d0.style.height,width:_2d0.style.width,opacity:_2d0.getInlineOpacity()};
var dims=_2d0.getDimensions();
var _2d4,_2d5;
switch(_2d1.direction){
case "top-left":
_2d4=_2d5=0;
break;
case "top-right":
_2d4=dims.width;
_2d5=0;
break;
case "bottom-left":
_2d4=0;
_2d5=dims.height;
break;
case "bottom-right":
_2d4=dims.width;
_2d5=dims.height;
break;
case "center":
_2d4=dims.width/2;
_2d5=dims.height/2;
break;
}
return new Effect.Parallel([new Effect.Opacity(_2d0,{sync:true,to:0,from:1,transition:_2d1.opacityTransition}),new Effect.Scale(_2d0,window.opera?1:0,{sync:true,transition:_2d1.scaleTransition,restoreAfterFinish:true}),new Effect.Move(_2d0,{x:_2d4,y:_2d5,sync:true,transition:_2d1.moveTransition})],Object.extend({beforeStartInternal:function(_2d6){
_2d6.effects[0].element.makePositioned().makeClipping();
},afterFinishInternal:function(_2d7){
_2d7.effects[0].element.hide().undoClipping().undoPositioned().setStyle(_2d2);
}},_2d1));
};
Effect.Pulsate=function(_2d8){
_2d8=$(_2d8);
var _2d9=arguments[1]||{};
var _2da=_2d8.getInlineOpacity();
var _2db=_2d9.transition||Effect.Transitions.sinoidal;
var _2dc=function(pos){
return _2db(1-Effect.Transitions.pulse(pos,_2d9.pulses));
};
_2dc.bind(_2db);
return new Effect.Opacity(_2d8,Object.extend(Object.extend({duration:2,from:0,afterFinishInternal:function(_2de){
_2de.element.setStyle({opacity:_2da});
}},_2d9),{transition:_2dc}));
};
Effect.Fold=function(_2df){
_2df=$(_2df);
var _2e0={top:_2df.style.top,left:_2df.style.left,width:_2df.style.width,height:_2df.style.height};
_2df.makeClipping();
return new Effect.Scale(_2df,5,Object.extend({scaleContent:false,scaleX:false,afterFinishInternal:function(_2e1){
new Effect.Scale(_2df,1,{scaleContent:false,scaleY:false,afterFinishInternal:function(_2e2){
_2e2.element.hide().undoClipping().setStyle(_2e0);
}});
}},arguments[1]||{}));
};
Effect.Morph=Class.create();
Object.extend(Object.extend(Effect.Morph.prototype,Effect.Base.prototype),{initialize:function(_2e3){
this.element=$(_2e3);
if(!this.element){
throw (Effect._elementDoesNotExistError);
}
var _2e4=Object.extend({style:""},arguments[1]||{});
this.start(_2e4);
},setup:function(){
function parseColor(_2e5){
if(!_2e5||["rgba(0, 0, 0, 0)","transparent"].include(_2e5)){
_2e5="#ffffff";
}
_2e5=_2e5.parseColor();
return $R(0,2).map(function(i){
return parseInt(_2e5.slice(i*2+1,i*2+3),16);
});
}
this.transforms=this.options.style.parseStyle().map(function(_2e7){
var _2e8=this.element.getStyle(_2e7[0]);
return $H({style:_2e7[0],originalValue:_2e7[1].unit=="color"?parseColor(_2e8):parseFloat(_2e8||0),targetValue:_2e7[1].unit=="color"?parseColor(_2e7[1].value):_2e7[1].value,unit:_2e7[1].unit});
}.bind(this)).reject(function(_2e9){
return ((_2e9.originalValue==_2e9.targetValue)||(_2e9.unit!="color"&&(isNaN(_2e9.originalValue)||isNaN(_2e9.targetValue))));
});
},update:function(_2ea){
var _2eb=$H(),_2ec=null;
this.transforms.each(function(_2ed){
_2ec=_2ed.unit=="color"?$R(0,2).inject("#",function(m,v,i){
return m+(Math.round(_2ed.originalValue[i]+(_2ed.targetValue[i]-_2ed.originalValue[i])*_2ea)).toColorPart();
}):_2ed.originalValue+Math.round(((_2ed.targetValue-_2ed.originalValue)*_2ea)*1000)/1000+_2ed.unit;
_2eb[_2ed.style]=_2ec;
});
this.element.setStyle(_2eb);
}});
Effect.Transform=Class.create();
Object.extend(Effect.Transform.prototype,{initialize:function(_2f1){
this.tracks=[];
this.options=arguments[1]||{};
this.addTracks(_2f1);
},addTracks:function(_2f2){
_2f2.each(function(_2f3){
var data=$H(_2f3).values().first();
this.tracks.push($H({ids:$H(_2f3).keys().first(),effect:Effect.Morph,options:{style:data}}));
}.bind(this));
return this;
},play:function(){
return new Effect.Parallel(this.tracks.map(function(_2f5){
var _2f6=[$(_2f5.ids)||$$(_2f5.ids)].flatten();
return _2f6.map(function(e){
return new _2f5.effect(e,Object.extend({sync:true},_2f5.options));
});
}).flatten(),this.options);
}});
Element.CSS_PROPERTIES=["azimuth","backgroundAttachment","backgroundColor","backgroundImage","backgroundPosition","backgroundRepeat","borderBottomColor","borderBottomStyle","borderBottomWidth","borderCollapse","borderLeftColor","borderLeftStyle","borderLeftWidth","borderRightColor","borderRightStyle","borderRightWidth","borderSpacing","borderTopColor","borderTopStyle","borderTopWidth","bottom","captionSide","clear","clip","color","content","counterIncrement","counterReset","cssFloat","cueAfter","cueBefore","cursor","direction","display","elevation","emptyCells","fontFamily","fontSize","fontSizeAdjust","fontStretch","fontStyle","fontVariant","fontWeight","height","left","letterSpacing","lineHeight","listStyleImage","listStylePosition","listStyleType","marginBottom","marginLeft","marginRight","marginTop","markerOffset","marks","maxHeight","maxWidth","minHeight","minWidth","opacity","orphans","outlineColor","outlineOffset","outlineStyle","outlineWidth","overflowX","overflowY","paddingBottom","paddingLeft","paddingRight","paddingTop","page","pageBreakAfter","pageBreakBefore","pageBreakInside","pauseAfter","pauseBefore","pitch","pitchRange","position","quotes","richness","right","size","speakHeader","speakNumeral","speakPunctuation","speechRate","stress","tableLayout","textAlign","textDecoration","textIndent","textShadow","textTransform","top","unicodeBidi","verticalAlign","visibility","voiceFamily","volume","whiteSpace","widows","width","wordSpacing","zIndex"];
Element.CSS_LENGTH=/^(([\+\-]?[0-9\.]+)(em|ex|px|in|cm|mm|pt|pc|\%))|0$/;
String.prototype.parseStyle=function(){
var _2f8=Element.extend(document.createElement("div"));
_2f8.innerHTML="<div style=\""+this+"\"></div>";
var _2f9=_2f8.down().style,_2fa=$H();
Element.CSS_PROPERTIES.each(function(_2fb){
if(_2f9[_2fb]){
_2fa[_2fb]=_2f9[_2fb];
}
});
var _2fc=$H();
_2fa.each(function(pair){
var _2fe=pair[0],_2ff=pair[1],unit=null;
if(_2ff.parseColor("#zzzzzz")!="#zzzzzz"){
_2ff=_2ff.parseColor();
unit="color";
}else{
if(Element.CSS_LENGTH.test(_2ff)){
var _301=_2ff.match(/^([\+\-]?[0-9\.]+)(.*)$/),_2ff=parseFloat(_301[1]),unit=(_301.length==3)?_301[2]:null;
}
}
_2fc[_2fe.underscore().dasherize()]=$H({value:_2ff,unit:unit});
}.bind(this));
return _2fc;
};
Element.morph=function(_302,_303){
new Effect.Morph(_302,Object.extend({style:_303},arguments[2]||{}));
return _302;
};
["setOpacity","getOpacity","getInlineOpacity","forceRerendering","setContentZoom","collectTextNodes","collectTextNodesIgnoreClass","morph"].each(function(f){
Element.Methods[f]=Element[f];
});
Element.Methods.visualEffect=function(_305,_306,_307){
s=_306.gsub(/_/,"-").camelize();
effect_class=s.charAt(0).toUpperCase()+s.substring(1);
new Effect[effect_class](_305,_307);
return $(_305);
};
Element.addMethods();
Wagn=new Object();
function warn(_308){
if(typeof (console)!="undefined"){
console.log(_308);
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
var Cookie={set:function(name,_30c,_30d){
var _30e="";
if(_30d!=undefined){
var d=new Date();
d.setTime(d.getTime()+(86400000*parseFloat(_30d)));
_30e="; expires="+d.toGMTString();
}
return (document.cookie=escape(name)+"="+escape(_30c||"")+_30e);
},get:function(name){
var _311=document.cookie.match(new RegExp("(^|;)\\s*"+escape(name)+"=([^;\\s]*)"));
return (_311?unescape(_311[2]):null);
},erase:function(name){
var _313=Cookie.get(name)||true;
Cookie.set(name,"",-1);
return _313;
},accept:function(){
if(typeof navigator.cookieEnabled=="boolean"){
return navigator.cookieEnabled;
}
Cookie.set("_test","1");
return (Cookie.erase("_test")==="1");
}};
Wagn.Messenger={element:function(){
return $("alerts");
},alert:function(_314){
this.element().innerHTML="<span style=\"color:red; font-weight: bold\">"+_314+"</span>";
new Effect.Highlight(this.element(),{startcolor:"#ffff00",endcolor:"#ffffaa",restorecolor:"#ffffaa",duration:1});
},note:function(_315){
this.element().innerHTML=_315;
new Effect.Highlight(this.element(),{startcolor:"#ffff00",endcolor:"#ffffaa",restorecolor:"#ffffaa",duration:1});
},log:function(_316){
this.element().innerHTML=_316;
new Effect.Highlight(this.element(),{startcolor:"#dddddd",endcolor:"#ffffaa",restorecolor:"#ffffaa",duration:1});
},flash:function(){
flash=$("notice").innerHTML+$("error").innerHTML;
if(flash!=""){
this.alert(flash);
}
}};
function openInNewWindow(){
var _317=window.open(this.getAttribute("href"),"_blank");
_317.focus();
return false;
}
function getNewWindowLinks(){
if(document.getElementById&&document.createElement&&document.appendChild){
var link;
var _319=document.getElementsByTagName("a");
for(var i=0;i<_319.length;i++){
link=_319[i];
if(/\bexternal\b/.exec(link.className)){
link.onclick=openInNewWindow;
}
}
objWarningText=null;
}
}
var Window=Class.create();
Window.prototype={initialize:function(id){
this.hasEffectLib=String.prototype.parseColor!=null;
this.options=Object.extend({className:"dialog",minWidth:100,minHeight:20,resizable:true,closable:true,minimizable:true,maximizable:true,draggable:true,userData:null,showEffect:(this.hasEffectLib?Effect.Appear:Element.show),hideEffect:(this.hasEffectLib?Effect.Fade:Element.hide),showEffectOptions:{},hideEffectOptions:{},effectOptions:null,parent:document.getElementsByTagName("body").item(0),title:"&nbsp;",url:null,onload:Prototype.emptyFunction,width:200,height:300,opacity:1},arguments[1]||{});
if(this.options.effectOptions){
Object.extend(this.options.hideEffectOptions,this.options.effectOptions);
Object.extend(this.options.showEffectOptions,this.options.effectOptions);
}
if(this.options.hideEffect==Element.hide){
this.options.hideEffect=function(){
Element.hide(this.element);
if(this.destroyOnClose){
this.destroy();
}
}.bind(this);
}
this.element=this._createWindow(id);
this.eventMouseDown=this._initDrag.bindAsEventListener(this);
this.eventMouseUp=this._endDrag.bindAsEventListener(this);
this.eventMouseMove=this._updateDrag.bindAsEventListener(this);
this.eventKeyPress=this._keyPress.bindAsEventListener(this);
this.eventOnLoad=this._getWindowBorderSize.bindAsEventListener(this);
this.topbar=$(this.element.id+"_top");
this.bottombar=$(this.element.id+"_bottom");
Event.observe(this.topbar,"mousedown",this.eventMouseDown);
Event.observe(this.bottombar,"mousedown",this.eventMouseDown);
Event.observe(window,"load",this.eventOnLoad);
if(this.options.draggable){
this.bottombar.addClassName("bottom_draggable");
this.topbar.addClassName("top_draggable");
}
if(this.options.resizable){
this.sizer=$(this.element.id+"_sizer");
Event.observe(this.sizer,"mousedown",this.eventMouseDown);
}
this.useLeft=null;
this.useTop=null;
if(arguments[1].left!=null){
this.element.setStyle({left:parseFloat(arguments[1].left)+"px"});
this.useLeft=true;
}
if(arguments[1].right!=null){
this.element.setStyle({right:parseFloat(arguments[1].right)+"px"});
this.useLeft=false;
}
if(this.useLeft==null){
this.element.setStyle({left:"0px"});
this.useLeft=true;
}
if(arguments[1].top!=null){
this.element.setStyle({top:parseFloat(arguments[1].top)+"px"});
this.useTop=true;
}
if(arguments[1].bottom!=null){
this.element.setStyle({bottom:parseFloat(arguments[1].bottom)+"px"});
this.useTop=false;
}
if(this.useTop==null){
this.element.setStyle({top:"0px"});
this.useTop=true;
}
this.storedLocation=null;
this.setOpacity(this.options.opacity);
if(arguments[1].zIndex){
this.setZIndex(arguments[1].zIndex);
}
this.destroyOnClose=false;
this._getWindowBorderSize();
this.setSize(this.options.width,this.options.height);
this.setTitle(this.options.title);
Windows.register(this);
},destroy:function(){
Windows.notify("onDestroy",this);
Event.stopObserving(this.topbar,"mousedown",this.eventMouseDown);
Event.stopObserving(this.bottombar,"mousedown",this.eventMouseDown);
Event.stopObserving(window,"load",this.eventOnLoad);
Event.stopObserving($(this.element.id+"_content"),"load",this.options.onload);
if(this.sizer){
Event.stopObserving(this.sizer,"mousedown",this.eventMouseDown);
}
if(this.iefix){
Element.remove(this.iefix);
}
Element.remove(this.element);
Windows.unregister(this);
},setDelegate:function(_31c){
this.delegate=_31c;
},getDelegate:function(){
return this.delegate;
},getContent:function(){
return $(this.element.id+"_content");
},setContent:function(id,_31e,_31f){
var d=null;
var p=null;
if(_31e){
d=Element.getDimensions(id);
}
if(_31f){
p=Position.cumulativeOffset($(id));
}
var _322=this.getContent();
_322.appendChild($(id));
$(id).show();
if(_31e){
this.setSize(d.width,d.height);
}
if(_31f){
this.setLocation(p[1]-this.heightN,p[0]-this.widthW);
}
},setCookie:function(name,_324,path,_326,_327){
name=name||this.element.id;
this.cookie=[name,_324,path,_326,_327];
var _328=WindowUtilities.getCookie(name);
if(_328){
var _329=_328.split(",");
var x=_329[0].split(":");
var y=_329[1].split(":");
var w=parseFloat(_329[2]),h=parseFloat(_329[3]);
var mini=_329[4];
var maxi=_329[5];
this.setSize(w,h);
if(mini=="true"){
this.doMinimize=true;
}else{
if(maxi=="true"){
this.doMaximize=true;
}
}
this.useLeft=x[0]=="l";
this.useTop=y[0]=="t";
this.element.setStyle(this.useLeft?{left:x[1]}:{right:x[1]});
this.element.setStyle(this.useTop?{top:y[1]}:{bottom:y[1]});
}
},getId:function(){
return this.element.id;
},setDestroyOnClose:function(){
Object.extend(this.options.hideEffectOptions,{afterFinish:this.destroy.bind(this)});
this.destroyOnClose=true;
},_initDrag:function(_330){
this.pointer=[Event.pointerX(_330),Event.pointerY(_330)];
if(Event.element(_330)==this.sizer){
this.doResize=true;
this.widthOrg=this.width;
this.heightOrg=this.height;
this.bottomOrg=parseFloat(this.element.getStyle("bottom"));
this.rightOrg=parseFloat(this.element.getStyle("right"));
Windows.notify("onStartResize",this);
}else{
this.doResize=false;
var _331=$(this.getId()+"_close");
if(_331&&Position.within(_331,this.pointer[0],this.pointer[1])){
return;
}
this.toFront();
if(!this.options.draggable){
return;
}
Windows.notify("onStartMove",this);
}
Event.observe(document,"mouseup",this.eventMouseUp,false);
Event.observe(document,"mousemove",this.eventMouseMove,false);
WindowUtilities.disableScreen("__invisible__","__invisible__",false);
document.body.ondrag=function(){
return false;
};
document.body.onselectstart=function(){
return false;
};
Event.stop(_330);
},_updateDrag:function(_332){
var _333=[Event.pointerX(_332),Event.pointerY(_332)];
var dx=_333[0]-this.pointer[0];
var dy=_333[1]-this.pointer[1];
if(this.doResize){
this.setSize(this.widthOrg+dx,this.heightOrg+dy);
dx=this.width-this.widthOrg;
dy=this.height-this.heightOrg;
if(!this.useLeft){
this.element.setStyle({right:(this.rightOrg-dx)+"px"});
}
if(!this.useTop){
this.element.setStyle({bottom:(this.bottomOrg-dy)+"px"});
}
}else{
this.pointer=_333;
if(this.useLeft){
this.element.setStyle({left:parseFloat(this.element.getStyle("left"))+dx+"px"});
}else{
this.element.setStyle({right:parseFloat(this.element.getStyle("right"))-dx+"px"});
}
if(this.useTop){
this.element.setStyle({top:parseFloat(this.element.getStyle("top"))+dy+"px"});
}else{
this.element.setStyle({bottom:parseFloat(this.element.getStyle("bottom"))-dy+"px"});
}
}
if(this.iefix){
this._fixIEOverlapping();
}
this._removeStoreLocation();
Event.stop(_332);
},_endDrag:function(_336){
WindowUtilities.enableScreen("__invisible__");
if(this.doResize){
Windows.notify("onEndResize",this);
}else{
Windows.notify("onEndMove",this);
}
Event.stopObserving(document,"mouseup",this.eventMouseUp,false);
Event.stopObserving(document,"mousemove",this.eventMouseMove,false);
this._saveCookie();
Event.stop(_336);
document.body.ondrag=null;
document.body.onselectstart=null;
},_keyPress:function(_337){
},_createWindow:function(id){
var _339=this.options.className;
win=document.createElement("div");
win.setAttribute("id",id);
win.className="dialog";
var _33a;
if(this.options.url){
_33a="<IFRAME name=\""+id+"_content\"  id=\""+id+"_content\" SRC=\""+this.options.url+"\"> </IFRAME>";
}else{
_33a="<DIV id=\""+id+"_content\" class=\""+_339+"_content\"> </DIV>";
}
var _33b=this.options.closable?"<div class='"+_339+"_close' id='"+id+"_close' onclick='Windows.close(\""+id+"\")'> </div>":"";
var _33c=this.options.minimizable?"<div class='"+_339+"_minimize' id='"+id+"_minimize' onclick='Windows.minimize(\""+id+"\")'> </div>":"";
var _33d=this.options.maximizable?"<div class='"+_339+"_maximize' id='"+id+"_maximize' onclick='Windows.maximize(\""+id+"\")'> </div>":"";
var _33e=this.options.resizable?"class='"+_339+"_sizer' id='"+id+"_sizer'":"class='"+_339+"_se'";
win.innerHTML=_33b+_33c+_33d+"      <table id='"+id+"_row1' class=\"top table_window\">        <tr>          <td class='"+_339+"_nw'>&nbsp;</td>          <td class='"+_339+"_n'><div id='"+id+"_top' class='"+_339+"_title title_window'>"+this.options.title+"</div></td>          <td class='"+_339+"_ne'>&nbsp;</td>        </tr>      </table>      <table id='"+id+"_row2' class=\"mid table_window\">        <tr>          <td class='"+_339+"_w'></td>            <td id='"+id+"_table_content' class='"+_339+"_content' valign='top'>"+_33a+"</td>          <td class='"+_339+"_e'></td>        </tr>      </table>        <table id='"+id+"_row3' class=\"bot table_window\">        <tr>          <td class='"+_339+"_sw'>&nbsp;</td>            <td class='"+_339+"_s'><div id='"+id+"_bottom' class='status_bar'>&nbsp;</div></td>            <td "+_33e+">&nbsp;</td>        </tr>      </table>    ";
Element.hide(win);
this.options.parent.insertBefore(win,this.options.parent.firstChild);
Event.observe($(id+"_content"),"load",this.options.onload);
return win;
},setLocation:function(top,left){
if(top<0){
top=0;
}
if(left<0){
left=0;
}
this.element.setStyle({top:top+"px"});
this.element.setStyle({left:left+"px"});
this.useLeft=true;
this.useTop=true;
},getSize:function(){
return {width:width,height:height};
},setSize:function(_341,_342){
_341=parseFloat(_341);
_342=parseFloat(_342);
if(_341<this.options.minWidth){
_341=this.options.minWidth;
}
if(_342<this.options.minHeight){
_342=this.options.minHeight;
}
if(this.options.maxHeight&&_342>this.options.maxHeight){
_342=this.options.maxHeight;
}
if(this.options.maxWidth&&_341>this.options.maxWidth){
_341=this.options.maxWidth;
}
this.width=_341;
this.height=_342;
this.element.setStyle({width:_341+this.widthW+this.widthE+"px"});
this.element.setStyle({height:_342+this.heightN+this.heightS+"px"});
var _343=$(this.element.id+"_content");
_343.setStyle({height:_342+"px"});
_343.setStyle({width:_341+"px"});
},toFront:function(){
this.setZIndex(Windows.maxZIndex+20);
},show:function(_344){
if(_344){
WindowUtilities.disableScreen(this.options.className);
this.modal=true;
this.setZIndex(Windows.maxZIndex+20);
Windows.unsetOverflow(this);
Event.observe(document,"keypress",this.eventKeyPress);
}
if(this.oldStyle){
this.getContent().setStyle({overflow:this.oldStyle});
}
this.setSize(this.width,this.height);
if(this.options.showEffect!=Element.show&&this.options.showEffectOptions){
this.options.showEffect(this.element,this.options.showEffectOptions);
}else{
this.options.showEffect(this.element);
}
this._checkIEOverlapping();
},showCenter:function(_345){
this.setSize(this.width,this.height);
this._center();
this.show(_345);
},_center:function(){
var _346=WindowUtilities.getWindowScroll();
var _347=WindowUtilities.getPageSize();
this.setLocation(_346.top+(_347.windowHeight-(this.height+this.heightN+this.heightS))/2,_346.left+(_347.windowWidth-(this.width+this.widthW+this.widthE))/2);
this.toFront();
},hide:function(){
if(this.modal){
WindowUtilities.enableScreen();
Windows.resetOverflow();
Event.stopObserving(document,"keypress",this.eventKeyPress);
}
this.getContent().setStyle({overflow:"hidden"});
this.oldStyle=this.getContent().getStyle("overflow");
this.options.hideEffect(this.element,this.options.hideEffectOptions);
if(this.iefix){
this.iefix.hide();
}
},minimize:function(){
var r2=$(this.getId()+"_row2");
var dh=r2.getDimensions().height;
if(r2.visible()){
var h=this.element.getHeight()-dh;
r2.hide();
this.element.setStyle({height:h+"px"});
if(!this.useTop){
var _34b=parseFloat(this.element.getStyle("bottom"));
this.element.setStyle({bottom:(_34b+dh)+"px"});
}
}else{
var h=this.element.getHeight()+dh;
this.element.setStyle({height:h+"px"});
if(!this.useTop){
var _34b=parseFloat(this.element.getStyle("bottom"));
this.element.setStyle({bottom:(_34b-dh)+"px"});
}
r2.show();
this.toFront();
}
Windows.notify("onMinimize",this);
this._saveCookie();
},maximize:function(){
if(this.storedLocation!=null){
this._restoreLocation();
if(this.iefix){
this.iefix.hide();
}
}else{
this._storeLocation();
Windows.unsetOverflow(this);
var _34c=WindowUtilities.getWindowScroll();
var _34d=WindowUtilities.getPageSize();
this.element.setStyle(this.useLeft?{left:_34c.left}:{right:_34c.left});
this.element.setStyle(this.useTop?{top:_34c.top}:{bottom:_34c.top});
this.setSize(_34d.windowWidth-this.widthW-this.widthE,_34d.windowHeight-this.heightN-this.heightS);
this.toFront();
if(this.iefix){
this._fixIEOverlapping();
}
}
Windows.notify("onMaximize",this);
this._saveCookie();
},isMinimized:function(){
var r2=$(this.getId()+"_row2");
return !r2.visible();
},isMaximized:function(){
return (this.storedLocation!=null);
},setOpacity:function(_34f){
if(Element.setOpacity){
Element.setOpacity(this.element,_34f);
}
},setZIndex:function(_350){
this.element.setStyle({zIndex:_350});
Windows.updateZindex(_350,this);
},setTitle:function(_351){
if(!_351||_351==""){
_351="&nbsp;";
}
Element.update(this.element.id+"_top",_351);
},setStatusBar:function(_352){
var _353=$(this.getId()+"_bottom");
if(typeof (_352)=="object"){
if(this.bottombar.firstChild){
this.bottombar.replaceChild(_352,this.bottombar.firstChild);
}else{
this.bottombar.appendChild(_352);
}
}else{
this.bottombar.innerHTML=_352;
}
},_checkIEOverlapping:function(){
if(!this.iefix&&(navigator.appVersion.indexOf("MSIE")>0)&&(navigator.userAgent.indexOf("Opera")<0)&&(this.element.getStyle("position")=="absolute")){
new Insertion.After(this.element.id,"<iframe id=\""+this.element.id+"_iefix\" "+"style=\"display:none;position:absolute;filter:progid:DXImageTransform.Microsoft.Alpha(opacity=0);\" "+"src=\"javascript:false;\" frameborder=\"0\" scrolling=\"no\"></iframe>");
this.iefix=$(this.element.id+"_iefix");
}
if(this.iefix){
setTimeout(this._fixIEOverlapping.bind(this),50);
}
},_fixIEOverlapping:function(){
Position.clone(this.element,this.iefix);
this.iefix.style.zIndex=this.element.style.zIndex-1;
this.iefix.show();
},_getWindowBorderSize:function(_354){
var div=this._createHiddenDiv(this.options.className+"_n");
this.heightN=Element.getDimensions(div).height;
div.parentNode.removeChild(div);
var div=this._createHiddenDiv(this.options.className+"_s");
this.heightS=Element.getDimensions(div).height;
div.parentNode.removeChild(div);
var div=this._createHiddenDiv(this.options.className+"_e");
this.widthE=Element.getDimensions(div).width;
div.parentNode.removeChild(div);
var div=this._createHiddenDiv(this.options.className+"_w");
this.widthW=Element.getDimensions(div).width;
div.parentNode.removeChild(div);
if(/Konqueror|Safari|KHTML/.test(navigator.userAgent)){
this.setSize(this.width,this.height);
}
if(this.doMaximize){
this.maximize();
}
if(this.doMinimize){
this.minimize();
}
},_createHiddenDiv:function(_356){
var _357=document.getElementsByTagName("body").item(0);
var win=document.createElement("div");
win.setAttribute("id",this.element.id+"_tmp");
win.className=_356;
win.style.display="none";
win.innerHTML="";
_357.insertBefore(win,_357.firstChild);
return win;
},_storeLocation:function(){
if(this.storedLocation==null){
this.storedLocation={useTop:this.useTop,useLeft:this.useLeft,top:this.element.getStyle("top"),bottom:this.element.getStyle("bottom"),left:this.element.getStyle("left"),right:this.element.getStyle("right"),width:this.width,height:this.height};
}
},_restoreLocation:function(){
if(this.storedLocation!=null){
this.useLeft=this.storedLocation.useLeft;
this.useTop=this.storedLocation.useTop;
this.element.setStyle(this.useLeft?{left:this.storedLocation.left}:{right:this.storedLocation.right});
this.element.setStyle(this.useTop?{top:this.storedLocation.top}:{bottom:this.storedLocation.bottom});
this.setSize(this.storedLocation.width,this.storedLocation.height);
Windows.resetOverflow();
this._removeStoreLocation();
}
},_removeStoreLocation:function(){
this.storedLocation=null;
},_saveCookie:function(){
if(this.cookie){
var _359="";
if(this.useLeft){
_359+="l:"+(this.storedLocation?this.storedLocation.left:this.element.getStyle("left"));
}else{
_359+="r:"+(this.storedLocation?this.storedLocation.right:this.element.getStyle("right"));
}
if(this.useTop){
_359+=",t:"+(this.storedLocation?this.storedLocation.top:this.element.getStyle("top"));
}else{
_359+=",b:"+(this.storedLocation?this.storedLocation.bottom:this.element.getStyle("bottom"));
}
_359+=","+(this.storedLocation?this.storedLocation.width:this.width);
_359+=","+(this.storedLocation?this.storedLocation.height:this.height);
_359+=","+this.isMinimized();
_359+=","+this.isMaximized();
WindowUtilities.setCookie(_359,this.cookie);
}
}};
var Windows={windows:[],observers:[],focusedWindow:null,maxZIndex:0,addObserver:function(_35a){
this.removeObserver(_35a);
this.observers.push(_35a);
},removeObserver:function(_35b){
this.observers=this.observers.reject(function(o){
return o==_35b;
});
},notify:function(_35d,win){
this.observers.each(function(o){
if(o[_35d]){
o[_35d](_35d,win);
}
});
},getWindow:function(id){
return this.windows.detect(function(d){
return d.getId()==id;
});
},register:function(win){
this.windows.push(win);
},unregister:function(win){
this.windows=this.windows.reject(function(d){
return d==win;
});
},close:function(id){
var win=this.getWindow(id);
if(win){
if(win.getDelegate()&&!win.getDelegate().canClose(win)){
return;
}
this.notify("onClose",win);
win.hide();
}
},closeAll:function(){
this.windows.each(function(w){
Windows.close(w.getId());
});
},minimize:function(id){
var win=this.getWindow(id);
if(win){
win.minimize();
}
},maximize:function(id){
var win=this.getWindow(id);
if(win){
win.maximize();
}
},unsetOverflow:function(_36c){
this.windows.each(function(d){
d.oldOverflow=d.getContent().getStyle("overflow")||"auto";
d.getContent().setStyle({overflow:"hidden"});
});
if(_36c&&_36c.oldOverflow){
_36c.getContent().setStyle({overflow:_36c.oldOverflow});
}
},resetOverflow:function(){
this.windows.each(function(d){
if(d.oldOverflow){
d.getContent().setStyle({overflow:d.oldOverflow});
}
});
},updateZindex:function(_36f,win){
if(_36f>this.maxZIndex){
this.maxZIndex=_36f;
}
this.focusedWindow=win;
}};
var Dialog={win:null,confirm:function(_371,_372){
_372=_372||{};
var _373=_372.okLabel?_372.okLabel:"Ok";
var _374=_372.cancelLabel?_372.cancelLabel:"Cancel";
var _375=_372.windowParameters||{};
_375.className=_375.className||"alert";
buttonClass=_372.buttonClass?"class="+_372.buttonClass:"";
var _376="\t\t\t<div class='"+_375.className+"_message'>"+_371+"</div>\t\t\t\t<div class='"+_375.className+"_buttons'>\t\t\t\t\t<input type='button' value='"+_373+"' onclick='Dialog.okCallback()'"+buttonClass+"/>\t\t\t\t\t<input type='button' value='"+_374+"' onclick='Dialog.cancelCallback()"+buttonClass+"'/>\t\t\t\t</div>\t\t";
this._openDialog(_376,_372);
return this.win;
},alert:function(_377,_378){
_378=_378||{};
var _379=_378.okLabel?_378.okLabel:"Ok";
var _37a=_378.windowParameters||{};
_37a.className=_37a.className||"alert";
buttonClass=_378.buttonClass?"class="+_378.buttonClass:"";
var _37b="\t\t\t<div class='"+_37a.className+"_message'>"+_377+"</div>\t\t\t\t<div class='"+_37a.className+"_buttons'>\t\t\t\t\t<input type='button' value='"+_379+"' onclick='Dialog.okCallback()"+buttonClass+"'/>\t\t\t\t</div>";
return this._openDialog(_37b,_378);
},info:function(_37c,_37d){
_37d=_37d||{};
_37d.windowParameters=_37d.windowParameters||{};
var _37e=_37d.windowParameters.className||"alert";
var _37f="<div id='modal_dialog_message' class='"+_37e+"_message'>"+_37c+"</div>";
if(_37d.showProgress){
_37f+="<div id='modal_dialog_progress' class='"+_37e+"_progress'>\t</div>";
}
_37d.windowParameters.ok=null;
_37d.windowParameters.cancel=null;
_37d.windowParameters.className=_37e;
return this._openDialog(_37f,_37d);
},setInfoMessage:function(_380){
$("modal_dialog_message").update(_380);
},closeInfo:function(){
Windows.close("modal_dialog");
},_openDialog:function(_381,_382){
if(this.win){
this.win.destroy();
}
if(!_382.windowParameters.height&&!_382.windowParameters.width){
_382.windowParameters.width=WindowUtilities.getPageSize().pageWidth/2;
}
if(!_382.windowParameters.height||!_382.windowParameters.width){
var _383=document.getElementsByTagName("body").item(0);
var _384=document.createElement("div");
if(_382.windowParameters.height){
_384.style.height=_382.windowParameters.height+"px";
}else{
_384.style.width=_382.windowParameters.width+"px";
}
_384.style.position="absolute";
_384.style.top="0";
_384.style.left="0";
_384.style.display="none";
_384.setAttribute("id","_dummy_dialog_");
_384.innerHTML=_381;
_383.insertBefore(_384,_383.firstChild);
if(_382.windowParameters.height){
_382.windowParameters.width=$("_dummy_dialog_").getDimensions().width+5;
}else{
_382.windowParameters.height=$("_dummy_dialog_").getDimensions().height+5;
}
_383.removeChild(_384);
}
var _385=_382&&_382.windowParameters?_382.windowParameters:{};
_385.resizable=_385.resizable||false;
_385.effectOptions=_385.effectOptions||{duration:1};
_385.minimizable=false;
_385.maximizable=false;
_385.closable=false;
this.win=new Window("modal_dialog",_385);
this.win.getContent().innerHTML=_381;
this.win.showCenter(true);
this.win.cancelCallback=_382.cancel;
this.win.okCallback=_382.ok;
if(!this.eventResize){
this.eventResize=this.recenter.bindAsEventListener(this);
}
Event.observe(window,"resize",this.eventResize);
Event.observe(window,"scroll",this.eventResize);
return this.win;
},okCallback:function(){
Event.stopObserving(window,"resize",this.eventResize);
Event.stopObserving(window,"scroll",this.eventResize);
if(!this.win.okCallback||this.win.okCallback(this.win)){
this.win.hide();
}
},cancelCallback:function(){
this.win.hide();
Event.stopObserving(window,"resize",this.eventResize);
Event.stopObserving(window,"scroll",this.eventResize);
if(this.win.cancelCallback){
this.win.cancelCallback(this.win);
}
},recenter:function(_386){
var _387=WindowUtilities.getPageSize();
if($("overlay_modal")){
$("overlay_modal").style.height=(_387.pageHeight+"px");
}
this.win._center();
}};
var isIE=navigator.appVersion.match(/MSIE/)=="MSIE";
var WindowUtilities={getWindowScroll:function(){
var w=window;
var T,L,W,H;
with(w.document){
if(w.document.documentElement&&documentElement.scrollTop){
T=documentElement.scrollTop;
L=documentElement.scrollLeft;
}else{
if(w.document.body){
T=body.scrollTop;
L=body.scrollLeft;
}
}
if(w.innerWidth){
W=w.innerWidth;
H=w.innerHeight;
}else{
if(w.document.documentElement&&documentElement.clientWidth){
W=documentElement.clientWidth;
H=documentElement.clientHeight;
}else{
W=body.offsetWidth;
H=body.offsetHeight;
}
}
}
return {top:T,left:L,width:W,height:H};
},getPageSize:function(){
var _38d,_38e;
if(window.innerHeight&&window.scrollMaxY){
_38d=document.body.scrollWidth;
_38e=window.innerHeight+window.scrollMaxY;
}else{
if(document.body.scrollHeight>document.body.offsetHeight){
_38d=document.body.scrollWidth;
_38e=document.body.scrollHeight;
}else{
_38d=document.body.offsetWidth;
_38e=document.body.offsetHeight;
}
}
var _38f,_390;
if(self.innerHeight){
_38f=self.innerWidth;
_390=self.innerHeight;
}else{
if(document.documentElement&&document.documentElement.clientHeight){
_38f=document.documentElement.clientWidth;
_390=document.documentElement.clientHeight;
}else{
if(document.body){
_38f=document.body.clientWidth;
_390=document.body.clientHeight;
}
}
}
var _391,_392;
if(_38e<_390){
_391=_390;
}else{
_391=_38e;
}
if(_38d<_38f){
_392=_38f;
}else{
_392=_38d;
}
return {pageWidth:_392,pageHeight:_391,windowWidth:_38f,windowHeight:_390};
},disableScreen:function(_393,id,_395){
id=id||"overlay_modal";
_395=_395||true;
WindowUtilities.initLightbox(id,_393);
var _396=document.getElementsByTagName("body").item(0);
var _397=$(id);
var _398=WindowUtilities.getPageSize();
if(_395&&isIE){
$$("select").each(function(_399){
_399.style.visibility="hidden";
});
$$("#"+id+" select").each(function(_39a){
_39a.style.visibility="visible";
});
}
_397.style.height=(_398.pageHeight+"px");
_397.style.display="block";
},enableScreen:function(id){
id=id||"overlay_modal";
var _39c=$(id);
if(_39c){
_39c.style.display="none";
if(isIE){
$$("select").each(function(_39d){
_39d.style.visibility="visible";
});
}
_39c.parentNode.removeChild(_39c);
}
},initLightbox:function(id,_39f){
if($(id)){
Element.setStyle(id,{zIndex:Windows.maxZIndex+10});
}else{
var _3a0=document.getElementsByTagName("body").item(0);
var _3a1=document.createElement("div");
_3a1.setAttribute("id",id);
_3a1.className="overlay_"+_39f;
_3a1.style.display="none";
_3a1.style.position="absolute";
_3a1.style.top="0";
_3a1.style.left="0";
_3a1.style.zIndex=Windows.maxZIndex+10;
_3a1.style.width="100%";
_3a0.insertBefore(_3a1,_3a0.firstChild);
}
},setCookie:function(_3a2,_3a3){
document.cookie=_3a3[0]+"="+escape(_3a2)+((_3a3[1])?"; expires="+_3a3[1].toGMTString():"")+((_3a3[2])?"; path="+_3a3[2]:"")+((_3a3[3])?"; domain="+_3a3[3]:"")+((_3a3[4])?"; secure":"");
},getCookie:function(name){
var dc=document.cookie;
var _3a6=name+"=";
var _3a7=dc.indexOf("; "+_3a6);
if(_3a7==-1){
_3a7=dc.indexOf(_3a6);
if(_3a7!=0){
return null;
}
}else{
_3a7+=2;
}
var end=document.cookie.indexOf(";",_3a7);
if(end==-1){
end=dc.length;
}
return unescape(dc.substring(_3a7+_3a6.length,end));
}};
var Builder={NODEMAP:{AREA:"map",CAPTION:"table",COL:"table",COLGROUP:"table",LEGEND:"fieldset",OPTGROUP:"select",OPTION:"select",PARAM:"object",TBODY:"table",TD:"table",TFOOT:"table",TH:"table",THEAD:"table",TR:"table"},node:function(_3a9){
_3a9=_3a9.toUpperCase();
var _3aa=this.NODEMAP[_3a9]||"div";
var _3ab=document.createElement(_3aa);
try{
_3ab.innerHTML="<"+_3a9+"></"+_3a9+">";
}
catch(e){
}
var _3ac=_3ab.firstChild||null;
if(_3ac&&(_3ac.tagName!=_3a9)){
_3ac=_3ac.getElementsByTagName(_3a9)[0];
}
if(!_3ac){
_3ac=document.createElement(_3a9);
}
if(!_3ac){
return;
}
if(arguments[1]){
if(this._isStringOrNumber(arguments[1])||(arguments[1] instanceof Array)){
this._children(_3ac,arguments[1]);
}else{
var _3ad=this._attributes(arguments[1]);
if(_3ad.length){
try{
_3ab.innerHTML="<"+_3a9+" "+_3ad+"></"+_3a9+">";
}
catch(e){
}
_3ac=_3ab.firstChild||null;
if(!_3ac){
_3ac=document.createElement(_3a9);
for(attr in arguments[1]){
_3ac[attr=="class"?"className":attr]=arguments[1][attr];
}
}
if(_3ac.tagName!=_3a9){
_3ac=_3ab.getElementsByTagName(_3a9)[0];
}
}
}
}
if(arguments[2]){
this._children(_3ac,arguments[2]);
}
return _3ac;
},_text:function(text){
return document.createTextNode(text);
},ATTR_MAP:{"className":"class","htmlFor":"for"},_attributes:function(_3af){
var _3b0=[];
for(attribute in _3af){
_3b0.push((attribute in this.ATTR_MAP?this.ATTR_MAP[attribute]:attribute)+"=\""+_3af[attribute].toString().escapeHTML()+"\"");
}
return _3b0.join(" ");
},_children:function(_3b1,_3b2){
if(typeof _3b2=="object"){
_3b2.flatten().each(function(e){
if(typeof e=="object"){
_3b1.appendChild(e);
}else{
if(Builder._isStringOrNumber(e)){
_3b1.appendChild(Builder._text(e));
}
}
});
}else{
if(Builder._isStringOrNumber(_3b2)){
_3b1.appendChild(Builder._text(_3b2));
}
}
},_isStringOrNumber:function(_3b4){
return (typeof _3b4=="string"||typeof _3b4=="number");
},build:function(html){
var _3b6=this.node("div");
$(_3b6).update(html.strip());
return _3b6.down();
},dump:function(_3b7){
if(typeof _3b7!="object"&&typeof _3b7!="function"){
_3b7=window;
}
var tags=("A ABBR ACRONYM ADDRESS APPLET AREA B BASE BASEFONT BDO BIG BLOCKQUOTE BODY "+"BR BUTTON CAPTION CENTER CITE CODE COL COLGROUP DD DEL DFN DIR DIV DL DT EM FIELDSET "+"FONT FORM FRAME FRAMESET H1 H2 H3 H4 H5 H6 HEAD HR HTML I IFRAME IMG INPUT INS ISINDEX "+"KBD LABEL LEGEND LI LINK MAP MENU META NOFRAMES NOSCRIPT OBJECT OL OPTGROUP OPTION P "+"PARAM PRE Q S SAMP SCRIPT SELECT SMALL SPAN STRIKE STRONG STYLE SUB SUP TABLE TBODY TD "+"TEXTAREA TFOOT TH THEAD TITLE TR TT U UL VAR").split(/\s+/);
tags.each(function(tag){
_3b7[tag]=function(){
return Builder.node.apply(Builder,[tag].concat($A(arguments)));
};
});
}};
var scwDateNow=new Date(Date.parse(new Date().toDateString()));
var scwBaseYear=scwDateNow.getFullYear()-10;
var scwDropDownYears=20;
var scwLanguage;
function scwSetDefaultLanguage(){
try{
scwSetLanguage();
}
catch(exception){
scwToday="Today:";
scwDrag="click here to drag";
scwArrMonthNames=["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
scwArrWeekInits=["S","M","T","W","T","F","S"];
scwInvalidDateMsg="The entered date is invalid.\n";
scwOutOfRangeMsg="The entered date is out of range.";
scwDoesNotExistMsg="The entered date does not exist.";
scwInvalidAlert=["Invalid date (",") ignored."];
scwDateDisablingError=["Error "," is not a Date object."];
scwRangeDisablingError=["Error "," should consist of two elements."];
}
}
var scwWeekStart=1;
var scwWeekNumberDisplay=false;
var scwWeekNumberBaseDay=4;
var scwShowInvalidDateMsg=true,scwShowOutOfRangeMsg=true,scwShowDoesNotExistMsg=true,scwShowInvalidAlert=true,scwShowDateDisablingError=true,scwShowRangeDisablingError=true;
var scwArrDelimiters=["/","-",".",","," "];
var scwDateDisplayFormat="YYYY-MM-DD";
var scwDateOutputFormat="YYYY-MM-DD";
var scwDateInputSequence="YMD";
var scwZindex=1;
var scwBlnStrict=false;
var scwEnabledDay=[true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true];
var scwDisabledDates=new Array();
var scwActiveToday=true;
var scwOutOfMonthDisable=false;
var scwOutOfMonthHide=false;
var scwOutOfRangeDisable=true;
var scwAllowDrag=false;
var scwClickToHide=false;
document.writeln("<style type=\"text/css\">"+".scw           {padding:1px;vertical-align:middle;}"+"iframe.scw     {position:absolute;z-index:"+scwZindex+";top:0px;left:0px;visibility:hidden;"+"width:1px;height:1px;}"+"table.scw      {padding:0px;visibility:hidden;"+"position:absolute;cursor:default;"+"width:200px;top:0px;left:0px;"+"z-index:"+(scwZindex+1)+";text-align:center;}"+"</style>");
document.writeln("<style type=\"text/css\">"+"/* IMPORTANT:  The SCW calendar script requires all "+"               the classes defined here."+"*/"+"table.scw      {padding:       1px;"+"vertical-align:middle;"+"border:        ridge 2px;"+"font-size:     10pt;"+"font-family:   Arial,Helvetica,Sans-Serif;"+"font-weight:   bold;}"+"td.scwDrag,"+"td.scwHead                 {padding:       0px 0px;"+"text-align:    center;}"+"td.scwDrag                 {font-size:     8pt;}"+"select.scwHead             {margin:        3px 1px;"+"text-align:    center;}"+"input.scwHead              {height:        22px;"+"width:         22px;"+"vertical-align:middle;"+"text-align:    center;"+"margin:        2px 1px;"+"font-weight:   bold;"+"font-size:     10pt;"+"font-family:   fixedSys;}"+"td.scwWeekNumberHead,"+"td.scwWeek                 {padding:       0px;"+"text-align:    center;"+"font-weight:   bold;}"+"td.scwFoot,"+"td.scwFootHover,"+"td.scwFoot:hover,"+"td.scwFootDisabled         {padding:       0px;"+"text-align:    center;"+"font-weight:   normal;}"+"table.scwCells             {text-align:    right;"+"font-size:     8pt;"+"width:         96%;}"+"td.scwCells,"+"td.scwCellsHover,"+"td.scwCells:hover,"+"td.scwCellsDisabled,"+"td.scwCellsExMonth,"+"td.scwCellsExMonthHover,"+"td.scwCellsExMonth:hover,"+"td.scwCellsExMonthDisabled,"+"td.scwCellsWeekend,"+"td.scwCellsWeekendHover,"+"td.scwCellsWeekend:hover,"+"td.scwCellsWeekendDisabled,"+"td.scwInputDate,"+"td.scwInputDateHover,"+"td.scwInputDate:hover,"+"td.scwInputDateDisabled,"+"td.scwWeekNo,"+"td.scwWeeks                {padding:           3px;"+"width:             16px;"+"height:            16px;"+"font-weight:       bold;"+"vertical-align:    middle;}"+"/* Blend the colours into your page here...    */"+"/* Calendar background */"+"table.scw                  {background-color:  #6666CC;}"+"/* Drag Handle */"+"td.scwDrag                 {background-color:  #9999CC;"+"color:             #CCCCFF;}"+"/* Week number heading */"+"td.scwWeekNumberHead       {color:             #6666CC;}"+"/* Week day headings */"+"td.scwWeek                 {color:             #CCCCCC;}"+"/* Week numbers */"+"td.scwWeekNo               {background-color:  #776677;"+"color:             #CCCCCC;}"+"/* Enabled Days */"+"/* Week Day */"+"td.scwCells                {background-color:  #CCCCCC;"+"color:             #000000;}"+"/* Day matching the input date */"+"td.scwInputDate            {background-color:  #CC9999;"+"color:             #FF0000;}"+"/* Weekend Day */"+"td.scwCellsWeekend         {background-color:  #CCCCCC;"+"color:             #CC6666;}"+"/* Day outside the current month */"+"td.scwCellsExMonth         {background-color:  #CCCCCC;"+"color:             #666666;}"+"/* Today selector */"+"td.scwFoot                 {background-color:  #6666CC;"+"color:             #FFFFFF;}"+"/* MouseOver/Hover formatting "+"       If you want to \"turn off\" any of the formatting "+"       then just set to the same as the standard format"+"       above."+" "+"       Note: The reason that the following are"+"       implemented using both a class and a :hover"+"       pseudoclass is because Opera handles the rendering"+"       involved in the class swap very poorly and IE6 "+"       (and below) only implements pseudoclasses on the"+"       anchor tag."+"*/"+"/* Active cells */"+"td.scwCells:hover,"+"td.scwCellsHover           {background-color:  #FFFF00;"+"cursor:            pointer;"+"cursor:            hand;"+"color:             #000000;}"+"/* Day matching the input date */"+"td.scwInputDate:hover,"+"td.scwInputDateHover       {background-color:  #FFFF00;"+"cursor:            pointer;"+"cursor:            hand;"+"color:             #000000;}"+"/* Weekend cells */"+"td.scwCellsWeekend:hover,"+"td.scwCellsWeekendHover    {background-color:  #FFFF00;"+"cursor:            pointer;"+"cursor:            hand;"+"color:             #000000;}"+"/* Day outside the current month */"+"td.scwCellsExMonth:hover,"+"td.scwCellsExMonthHover    {background-color:  #FFFF00;"+"cursor:            pointer;"+"cursor:            hand;"+"color:             #000000;}"+"/* Today selector */"+"td.scwFoot:hover,"+"td.scwFootHover            {color:             #FFFF00;"+"cursor:            pointer;"+"cursor:            hand;"+"font-weight:       bold;}"+"/* Disabled cells */"+"/* Week Day */"+"/* Day matching the input date */"+"td.scwInputDateDisabled    {background-color:  #999999;"+"color:             #000000;}"+"td.scwCellsDisabled        {background-color:  #999999;"+"color:             #000000;}"+"/* Weekend Day */"+"td.scwCellsWeekendDisabled {background-color:  #999999;"+"color:             #CC6666;}"+"/* Day outside the current month */"+"td.scwCellsExMonthDisabled {background-color:  #999999;"+"color:             #666666;}"+"td.scwFootDisabled         {background-color:  #6666CC;"+"color:             #FFFFFF;}"+"</style>");
var scwTargetEle,scwTriggerEle,scwMonthSum=0,scwBlnFullInputDate=false,scwPassEnabledDay=new Array(),scwSeedDate=new Date(),scwParmActiveToday=true,scwWeekStart=scwWeekStart%7,scwToday,scwDrag,scwArrMonthNames,scwArrWeekInits,scwInvalidDateMsg,scwOutOfRangeMsg,scwDoesNotExistMsg,scwInvalidAlert,scwDateDisablingError,scwRangeDisablingError;
Date.prototype.scwFormat=function(_3ba){
var _3bb=0,_3bc="",_3bd="";
for(var i=0;i<=_3ba.length;i++){
if(i<_3ba.length&&_3ba.charAt(i)==_3bc){
_3bb++;
}else{
switch(_3bc){
case "y":
case "Y":
_3bd+=(this.getFullYear()%Math.pow(10,_3bb)).toString().scwPadLeft(_3bb);
break;
case "m":
case "M":
_3bd+=(_3bb<3)?(this.getMonth()+1).toString().scwPadLeft(_3bb):scwArrMonthNames[this.getMonth()];
break;
case "d":
case "D":
_3bd+=this.getDate().toString().scwPadLeft(_3bb);
break;
default:
while(_3bb-->0){
_3bd+=_3bc;
}
}
if(i<_3ba.length){
_3bc=_3ba.charAt(i);
_3bb=1;
}
}
}
return _3bd;
};
String.prototype.scwPadLeft=function(_3bf){
var _3c0="";
for(var i=0;i<(_3bf-this.length);i++){
_3c0+="0";
}
return (_3c0+this);
};
Function.prototype.runsAfterSCW=function(){
var func=this,args=new Array(arguments.length);
for(var i=0;i<args.length;++i){
args[i]=arguments[i];
}
return function(){
for(var i=0;i<arguments.length;++i){
args[args.length]=arguments[i];
}
return (args.shift()==scwTriggerEle)?func.apply(this,args):null;
};
};
function scwID(id){
return document.getElementById(id);
}
var scwNextActionReturn,scwNextAction;
function showCal(_3c7,_3c8){
scwShow(_3c7,_3c8);
}
function scwShow(_3c9,_3ca){
scwTriggerEle=_3ca;
scwParmActiveToday=true;
for(var i=0;i<7;i++){
scwPassEnabledDay[(i+7-scwWeekStart)%7]=true;
for(var j=2;j<arguments.length;j++){
if(arguments[j]==i){
scwPassEnabledDay[(i+7-scwWeekStart)%7]=false;
if(scwDateNow.getDay()==i){
scwParmActiveToday=false;
}
}
}
}
scwSeedDate=scwDateNow;
if(typeof _3c9.value=="undefined"){
var _3cd=_3c9.childNodes;
for(var i=0;i<_3cd.length;i++){
if(_3cd[i].nodeType==3){
var _3ce=_3cd[i].nodeValue.replace(/^\s+/,"").replace(/\s+$/,"");
if(_3ce.length>0){
scwTriggerEle.scwTextNode=_3cd[i];
scwTriggerEle.scwLength=_3cd[i].nodeValue.length;
break;
}
}
}
}else{
var _3ce=_3c9.value.replace(/^\s+/,"").replace(/\s+$/,"");
}
scwSetDefaultLanguage();
scwID("scwDragText").innerHTML=scwDrag;
scwID("scwMonths").options.length=0;
for(var i=0;i<scwArrMonthNames.length;i++){
scwID("scwMonths").options[i]=new Option(scwArrMonthNames[i],scwArrMonthNames[i]);
}
scwID("scwYears").options.length=0;
for(var i=0;i<scwDropDownYears;i++){
scwID("scwYears").options[i]=new Option((scwBaseYear+i),(scwBaseYear+i));
}
for(var i=0;i<scwArrWeekInits.length;i++){
scwID("scwWeekInit"+i).innerHTML=scwArrWeekInits[(i+scwWeekStart)%scwArrWeekInits.length];
}
if(scwID("scwFoot")){
scwID("scwFoot").innerHTML=scwToday+" "+scwDateNow.scwFormat(scwDateDisplayFormat);
}
if(_3ce.length==0){
scwBlnFullInputDate=false;
if((new Date(scwBaseYear+scwDropDownYears,0,0))<scwSeedDate||(new Date(scwBaseYear,0,1))>scwSeedDate){
scwSeedDate=new Date(scwBaseYear+Math.floor(scwDropDownYears/2),5,1);
}
}else{
function scwInputFormat(){
var _3cf=new Array(),_3d0=_3ce.split(new RegExp("[\\"+scwArrDelimiters.join("\\")+"]+","g"));
if(_3d0[0]!=null){
if(_3d0[0].length==0){
_3d0.splice(0,1);
}
if(_3d0[_3d0.length-1].length==0){
_3d0.splice(_3d0.length-1,1);
}
}
scwBlnFullInputDate=false;
switch(_3d0.length){
case 1:
_3cf[0]=parseInt(_3d0[0],10);
_3cf[1]="6";
_3cf[2]=1;
break;
case 2:
_3cf[0]=parseInt(_3d0[scwDateInputSequence.replace(/D/i,"").search(/Y/i)],10);
_3cf[1]=_3d0[scwDateInputSequence.replace(/D/i,"").search(/M/i)];
_3cf[2]=1;
break;
case 3:
_3cf[0]=parseInt(_3d0[scwDateInputSequence.search(/Y/i)],10);
_3cf[1]=_3d0[scwDateInputSequence.search(/M/i)];
_3cf[2]=parseInt(_3d0[scwDateInputSequence.search(/D/i)],10);
scwBlnFullInputDate=true;
break;
default:
_3cf[0]=0;
_3cf[1]=0;
_3cf[2]=0;
}
var _3d1=/^(0?[1-9]|[1-2]\d|3[0-1])$/,_3d2=new RegExp("^(0?[1-9]|1[0-2]|"+scwArrMonthNames.join("|")+")$","i"),_3d3=/^(\d{1,2}|\d{4})$/;
if(_3d3.exec(_3cf[0])==null||_3d2.exec(_3cf[1])==null||_3d1.exec(_3cf[2])==null){
if(scwShowInvalidDateMsg){
alert(scwInvalidDateMsg+scwInvalidAlert[0]+_3ce+scwInvalidAlert[1]);
}
scwBlnFullInputDate=false;
_3cf[0]=scwBaseYear+Math.floor(scwDropDownYears/2);
_3cf[1]="6";
_3cf[2]=1;
}
return _3cf;
}
scwArrSeedDate=scwInputFormat();
if(scwArrSeedDate[0]<100){
scwArrSeedDate[0]+=(scwArrSeedDate[0]>50)?1900:2000;
}
if(scwArrSeedDate[1].search(/\d+/)!=0){
month=scwArrMonthNames.join("|").toUpperCase().search(scwArrSeedDate[1].substr(0,3).toUpperCase());
scwArrSeedDate[1]=Math.floor(month/4)+1;
}
scwSeedDate=new Date(scwArrSeedDate[0],scwArrSeedDate[1]-1,scwArrSeedDate[2]);
}
if(isNaN(scwSeedDate)){
if(scwShowInvalidDateMsg){
alert(scwInvalidDateMsg+scwInvalidAlert[0]+_3ce+scwInvalidAlert[1]);
}
scwSeedDate=new Date(scwBaseYear+Math.floor(scwDropDownYears/2),5,1);
scwBlnFullInputDate=false;
}else{
if((new Date(scwBaseYear,0,1))>scwSeedDate){
if(scwBlnStrict&&scwShowOutOfRangeMsg){
alert(scwOutOfRangeMsg);
}
scwSeedDate=new Date(scwBaseYear,0,1);
scwBlnFullInputDate=false;
}else{
if((new Date(scwBaseYear+scwDropDownYears,0,0))<scwSeedDate){
if(scwBlnStrict&&scwShowOutOfRangeMsg){
alert(scwOutOfRangeMsg);
}
scwSeedDate=new Date(scwBaseYear+Math.floor(scwDropDownYears)-1,11,1);
scwBlnFullInputDate=false;
}else{
if(scwBlnStrict&&scwBlnFullInputDate&&(scwSeedDate.getDate()!=scwArrSeedDate[2]||(scwSeedDate.getMonth()+1)!=scwArrSeedDate[1]||scwSeedDate.getFullYear()!=scwArrSeedDate[0])){
if(scwShowDoesNotExistMsg){
alert(scwDoesNotExistMsg);
}
scwSeedDate=new Date(scwSeedDate.getFullYear(),scwSeedDate.getMonth()-1,1);
scwBlnFullInputDate=false;
}
}
}
}
for(var i=0;i<scwDisabledDates.length;i++){
if(!((typeof scwDisabledDates[i]=="object")&&(scwDisabledDates[i].constructor==Date))){
if((typeof scwDisabledDates[i]=="object")&&(scwDisabledDates[i].constructor==Array)){
var _3d4=true;
if(scwDisabledDates[i].length!=2){
if(scwShowRangeDisablingError){
alert(scwRangeDisablingError[0]+scwDisabledDates[i]+scwRangeDisablingError[1]);
}
_3d4=false;
}else{
for(var j=0;j<scwDisabledDates[i].length;j++){
if(!((typeof scwDisabledDates[i][j]=="object")&&(scwDisabledDates[i][j].constructor==Date))){
if(scwShowRangeDisablingError){
alert(scwDateDisablingError[0]+scwDisabledDates[i][j]+scwDateDisablingError[1]);
}
_3d4=false;
}
}
}
if(_3d4&&(scwDisabledDates[i][0]>scwDisabledDates[i][1])){
scwDisabledDates[i].reverse();
}
}else{
if(scwShowRangeDisablingError){
alert(scwDateDisablingError[0]+scwDisabledDates[i]+scwDateDisablingError[1]);
}
}
}
}
scwMonthSum=12*(scwSeedDate.getFullYear()-scwBaseYear)+scwSeedDate.getMonth();
scwID("scwYears").options.selectedIndex=Math.floor(scwMonthSum/12);
scwID("scwMonths").options.selectedIndex=(scwMonthSum%12);
if(window.opera){
scwID("scwMonths").style.display="none";
scwID("scwMonths").style.display="block";
scwID("scwYears").style.display="none";
scwID("scwYears").style.display="block";
}
scwID("scwDrag").style.display=(scwAllowDrag)?((scwID("scwIFrame"))?"block":"table-row"):"none";
scwShowMonth(0);
scwTargetEle=_3c9;
var _3d5=parseInt(_3c9.offsetTop,10)+parseInt(_3c9.offsetHeight,10),_3d6=parseInt(_3c9.offsetLeft,10);
if(!window.opera){
while(_3c9.tagName!="BODY"&&_3c9.tagName!="HTML"){
_3d5-=parseInt(_3c9.scrollTop,10);
_3d6-=parseInt(_3c9.scrollLeft,10);
_3c9=_3c9.parentNode;
}
_3c9=scwTargetEle;
}
do{
_3c9=_3c9.offsetParent;
_3d5+=parseInt(_3c9.offsetTop,10);
_3d6+=parseInt(_3c9.offsetLeft,10);
}while(_3c9.tagName!="BODY"&&_3c9.tagName!="HTML");
scwID("scw").style.top=_3d5+"px";
scwID("scw").style.left=_3d6+"px";
if(scwID("scwIframe")){
scwID("scwIframe").style.top=_3d5+"px";
scwID("scwIframe").style.left=_3d6+"px";
scwID("scwIframe").style.width=(scwID("scw").offsetWidth-2)+"px";
scwID("scwIframe").style.height=(scwID("scw").offsetHeight-2)+"px";
scwID("scwIframe").style.visibility="visible";
}
scwID("scw").style.visibility="visible";
scwID("scwYears").options.selectedIndex=scwID("scwYears").options.selectedIndex;
scwID("scwMonths").options.selectedIndex=scwID("scwMonths").options.selectedIndex;
var el=(_3ca.parentNode)?_3ca.parentNode:_3ca;
if(typeof event=="undefined"){
el.addEventListener("click",scwStopPropagation,false);
}else{
if(el.attachEvent){
el.attachEvent("onclick",scwStopPropagation);
}else{
event.cancelBubble=true;
}
}
}
function scwHide(){
scwID("scw").style.visibility="hidden";
if(scwID("scwIframe")){
scwID("scwIframe").style.visibility="hidden";
}
if(typeof scwNextAction!="undefined"&&scwNextAction!=null){
scwNextActionReturn=scwNextAction();
scwNextAction=null;
}
}
function scwCancel(_3d8){
if(scwClickToHide){
scwHide();
}
scwStopPropagation(_3d8);
}
function scwStopPropagation(_3d9){
if(_3d9.stopPropagation){
_3d9.stopPropagation();
}else{
_3d9.cancelBubble=true;
}
}
function scwBeginDrag(_3da){
var _3db=scwID("scw");
var _3dc=_3da.clientX,_3dd=_3da.clientY,_3de=_3db;
do{
_3dc-=parseInt(_3de.offsetLeft,10);
_3dd-=parseInt(_3de.offsetTop,10);
_3de=_3de.offsetParent;
}while(_3de.tagName!="BODY"&&_3de.tagName!="HTML");
if(document.addEventListener){
document.addEventListener("mousemove",moveHandler,true);
document.addEventListener("mouseup",upHandler,true);
}else{
_3db.attachEvent("onmousemove",moveHandler);
_3db.attachEvent("onmouseup",upHandler);
_3db.setCapture();
}
scwStopPropagation(_3da);
function moveHandler(_3df){
if(!_3df){
_3df=window.event;
}
_3db.style.left=(_3df.clientX-_3dc)+"px";
_3db.style.top=(_3df.clientY-_3dd)+"px";
if(scwID("scwIframe")){
scwID("scwIframe").style.left=(_3df.clientX-_3dc)+"px";
scwID("scwIframe").style.top=(_3df.clientY-_3dd)+"px";
}
scwStopPropagation(_3df);
}
function upHandler(_3e0){
if(!_3e0){
_3e0=window.event;
}
if(document.removeEventListener){
document.removeEventListener("mousemove",moveHandler,true);
document.removeEventListener("mouseup",upHandler,true);
}else{
_3db.detachEvent("onmouseup",upHandler);
_3db.detachEvent("onmousemove",moveHandler);
_3db.releaseCapture();
}
scwStopPropagation(_3e0);
}
}
function scwShowMonth(_3e1){
var _3e2=new Date(Date.parse(new Date().toDateString())),_3e3=new Date();
_3e2.setHours(12);
scwSelYears=scwID("scwYears");
scwSelMonths=scwID("scwMonths");
if(scwSelYears.options.selectedIndex>-1){
scwMonthSum=12*(scwSelYears.options.selectedIndex)+_3e1;
if(scwSelMonths.options.selectedIndex>-1){
scwMonthSum+=scwSelMonths.options.selectedIndex;
}
}else{
if(scwSelMonths.options.selectedIndex>-1){
scwMonthSum+=scwSelMonths.options.selectedIndex;
}
}
_3e2.setFullYear(scwBaseYear+Math.floor(scwMonthSum/12),(scwMonthSum%12),1);
scwID("scwWeek_").style.display=(scwWeekNumberDisplay)?((scwID("scwIFrame"))?"block":"table-cell"):"none";
if((12*parseInt((_3e2.getFullYear()-scwBaseYear),10))+parseInt(_3e2.getMonth(),10)<(12*scwDropDownYears)&&(12*parseInt((_3e2.getFullYear()-scwBaseYear),10))+parseInt(_3e2.getMonth(),10)>-1){
scwSelYears.options.selectedIndex=Math.floor(scwMonthSum/12);
scwSelMonths.options.selectedIndex=(scwMonthSum%12);
scwCurMonth=_3e2.getMonth();
_3e2.setDate((((_3e2.getDay()-scwWeekStart)<0)?-6:1)+scwWeekStart-_3e2.getDay());
var _3e4=new Date(_3e2.getFullYear(),_3e2.getMonth(),_3e2.getDate()).valueOf();
_3e3=new Date(_3e2);
var _3e5=scwID("scwFoot");
function scwFootOutput(){
scwSetOutput(scwDateNow);
}
if(scwDisabledDates.length==0){
if(scwActiveToday&&scwParmActiveToday){
_3e5.onclick=scwFootOutput;
_3e5.className="scwFoot";
if(scwID("scwIFrame")){
_3e5.onmouseover=scwChangeClass;
_3e5.onmouseout=scwChangeClass;
}
}else{
_3e5.onclick=null;
_3e5.className="scwFootDisabled";
if(scwID("scwIFrame")){
_3e5.onmouseover=null;
_3e5.onmouseout=null;
}
if(document.addEventListener){
_3e5.addEventListener("click",scwStopPropagation,false);
}else{
_3e5.attachEvent("onclick",scwStopPropagation);
}
}
}else{
for(var k=0;k<scwDisabledDates.length;k++){
if(!scwActiveToday||!scwParmActiveToday||((typeof scwDisabledDates[k]=="object")&&(((scwDisabledDates[k].constructor==Date)&&scwDateNow.valueOf()==scwDisabledDates[k].valueOf())||((scwDisabledDates[k].constructor==Array)&&scwDateNow.valueOf()>=scwDisabledDates[k][0].valueOf()&&scwDateNow.valueOf()<=scwDisabledDates[k][1].valueOf())))){
_3e5.onclick=null;
_3e5.className="scwFootDisabled";
if(scwID("scwIFrame")){
_3e5.onmouseover=null;
_3e5.onmouseout=null;
}
if(document.addEventListener){
_3e5.addEventListener("click",scwStopPropagation,false);
}else{
_3e5.attachEvent("onclick",scwStopPropagation);
}
break;
}else{
_3e5.onclick=scwFootOutput;
_3e5.className="scwFoot";
if(scwID("scwIFrame")){
_3e5.onmouseover=scwChangeClass;
_3e5.onmouseout=scwChangeClass;
}
}
}
}
function scwSetOutput(_3e7){
if(typeof scwTargetEle.value=="undefined"){
scwTriggerEle.scwTextNode.replaceData(0,scwTriggerEle.scwLength,_3e7.scwFormat(scwDateOutputFormat));
}else{
scwTargetEle.value=_3e7.scwFormat(scwDateOutputFormat);
}
scwHide();
}
function scwCellOutput(_3e8){
var _3e9=scwEventTrigger(_3e8),_3ea=new Date(_3e3);
if(_3e9.nodeType==3){
_3e9=_3e9.parentNode;
}
_3ea.setDate(_3e3.getDate()+parseInt(_3e9.id.substr(8),10));
scwSetOutput(_3ea);
}
function scwChangeClass(_3eb){
var _3ec=scwEventTrigger(_3eb);
if(_3ec.nodeType==3){
_3ec=_3ec.parentNode;
}
switch(_3ec.className){
case "scwCells":
_3ec.className="scwCellsHover";
break;
case "scwCellsHover":
_3ec.className="scwCells";
break;
case "scwCellsExMonth":
_3ec.className="scwCellsExMonthHover";
break;
case "scwCellsExMonthHover":
_3ec.className="scwCellsExMonth";
break;
case "scwCellsWeekend":
_3ec.className="scwCellsWeekendHover";
break;
case "scwCellsWeekendHover":
_3ec.className="scwCellsWeekend";
break;
case "scwFoot":
_3ec.className="scwFootHover";
break;
case "scwFootHover":
_3ec.className="scwFoot";
break;
case "scwInputDate":
_3ec.className="scwInputDateHover";
break;
case "scwInputDateHover":
_3ec.className="scwInputDate";
}
return true;
}
function scwEventTrigger(_3ed){
if(!_3ed){
_3ed=event;
}
return _3ed.target||_3ed.srcElement;
}
function scwWeekNumber(_3ee){
var _3ef=new Date(_3ee);
_3ef.setDate(_3ef.getDate()-_3ef.getDay()+scwWeekNumberBaseDay+((_3ee.getDay()>scwWeekNumberBaseDay)?7:0));
var _3f0=new Date(_3ef.getFullYear(),0,1);
_3f0.setDate(_3f0.getDate()-_3f0.getDay()+scwWeekNumberBaseDay);
if(_3f0<new Date(_3ef.getFullYear(),0,1)){
_3f0.setDate(_3f0.getDate()+7);
}
var _3f1=new Date(_3f0-scwWeekNumberBaseDay+_3ee.getDay());
if(_3f1>_3f0){
_3f1.setDate(_3f1.getDate()-7);
}
var _3f2="0"+(Math.round((_3ef-_3f0)/604800000,0)+1);
return _3f2.substring(_3f2.length-2,_3f2.length);
}
var _3f3=scwID("scwCells");
for(i=0;i<_3f3.childNodes.length;i++){
var _3f4=_3f3.childNodes[i];
if(_3f4.nodeType==1&&_3f4.tagName=="TR"){
if(scwWeekNumberDisplay){
_3f4.childNodes[0].innerHTML=scwWeekNumber(_3e2);
_3f4.childNodes[0].style.display=(scwID("scwIFrame"))?"block":"table-cell";
}else{
_3f4.childNodes[0].style.display="none";
}
for(j=1;j<_3f4.childNodes.length;j++){
var _3f5=_3f4.childNodes[j];
if(_3f5.nodeType==1&&_3f5.tagName=="TD"){
_3f4.childNodes[j].innerHTML=_3e2.getDate();
var _3f6=_3f4.childNodes[j],_3f7=((scwOutOfRangeDisable&&(_3e2<(new Date(scwBaseYear,0,1,_3e2.getHours()))||_3e2>(new Date(scwBaseYear+scwDropDownYears,0,0,_3e2.getHours()))))||(scwOutOfMonthDisable&&(_3e2<(new Date(_3e2.getFullYear(),scwCurMonth,1,_3e2.getHours()))||_3e2>(new Date(_3e2.getFullYear(),scwCurMonth+1,0,_3e2.getHours())))))?true:false;
_3f6.style.visibility=(scwOutOfMonthHide&&(_3e2<(new Date(_3e2.getFullYear(),scwCurMonth,1,_3e2.getHours()))||_3e2>(new Date(_3e2.getFullYear(),scwCurMonth+1,0,_3e2.getHours()))))?"hidden":"";
for(var k=0;k<scwDisabledDates.length;k++){
if((typeof scwDisabledDates[k]=="object")&&(scwDisabledDates[k].constructor==Date)&&_3e4==scwDisabledDates[k].valueOf()){
_3f7=true;
}else{
if((typeof scwDisabledDates[k]=="object")&&(scwDisabledDates[k].constructor==Array)&&_3e4>=scwDisabledDates[k][0].valueOf()&&_3e4<=scwDisabledDates[k][1].valueOf()){
_3f7=true;
}
}
}
if(_3f7||!scwEnabledDay[j-1+(7*((i*_3f3.childNodes.length)/6))]||!scwPassEnabledDay[(j-1+(7*(i*_3f3.childNodes.length/6)))%7]){
_3f4.childNodes[j].onclick=null;
if(scwID("scwIFrame")){
_3f4.childNodes[j].onmouseover=null;
_3f4.childNodes[j].onmouseout=null;
}
_3f6.className=(_3e2.getMonth()!=scwCurMonth)?"scwCellsExMonthDisabled":(scwBlnFullInputDate&&_3e2.toDateString()==scwSeedDate.toDateString())?"scwInputDateDisabled":(_3e2.getDay()%6==0)?"scwCellsWeekendDisabled":"scwCellsDisabled";
}else{
_3f4.childNodes[j].onclick=scwCellOutput;
if(scwID("scwIFrame")){
_3f4.childNodes[j].onmouseover=scwChangeClass;
_3f4.childNodes[j].onmouseout=scwChangeClass;
}
_3f6.className=(_3e2.getMonth()!=scwCurMonth)?"scwCellsExMonth":(scwBlnFullInputDate&&_3e2.toDateString()==scwSeedDate.toDateString())?"scwInputDate":(_3e2.getDay()%6==0)?"scwCellsWeekend":"scwCells";
}
_3e2.setDate(_3e2.getDate()+1);
_3e4=new Date(_3e2.getFullYear(),_3e2.getMonth(),_3e2.getDate()).valueOf();
}
}
}
}
}
scwID("scw").style.visibility="hidden";
scwID("scw").style.visibility="visible";
}
document.write("<!--[if IE]>"+"<iframe class='scw' src='/scwblank.html' "+"id='scwIframe' name='scwIframe' "+"frameborder='0'>"+"</iframe>"+"<![endif]-->"+"<table id='scw' class='scw'>"+"<tr class='scw'>"+"<td class='scw'>"+"<table class='scwHead' id='scwHead' width='100%' "+"cellspacing='0' cellpadding='0'>"+"<tr id='scwDrag' style='display:none;'>"+"<td colspan='4' class='scwDrag' "+"onmousedown='scwBeginDrag(event);'>"+"<div id='scwDragText'></div>"+"</td>"+"</tr>"+"<tr class='scwHead' >"+"<td class='scwHead'>"+"<input class='scwHead' id='scwHeadLeft' type='button' value='<' "+"onclick='scwShowMonth(-1);'  /></td>"+"<td class='scwHead'>"+"<select id='scwMonths' class='scwHead' "+"onchange='scwShowMonth(0);'>"+"</select>"+"</td>"+"<td class='scwHead'>"+"<select id='scwYears' class='scwHead' "+"onchange='scwShowMonth(0);'>"+"</select>"+"</td>"+"<td class='scwHead'>"+"<input class='scwHead' id='scwHeadRight' type='button' value='>' "+"onclick='scwShowMonth(1);' /></td>"+"</tr>"+"</table>"+"</td>"+"</tr>"+"<tr class='scw'>"+"<td class='scw'>"+"<table class='scwCells' align='center'>"+"<thead>"+"<tr><td class='scwWeekNumberHead' id='scwWeek_' ></td>");
for(i=0;i<7;i++){
document.write("<td class='scwWeek' id='scwWeekInit"+i+"'></td>");
}
document.write("</tr>"+"</thead>"+"<tbody id='scwCells' "+"onClick='scwStopPropagation(event);'>");
for(i=0;i<6;i++){
document.write("<tr>"+"<td class='scwWeekNo' id='scwWeek_"+i+"'></td>");
for(j=0;j<7;j++){
document.write("<td class='scwCells' id='scwCell_"+(j+(i*7))+"'></td>");
}
document.write("</tr>");
}
document.write("</tbody>");
if((new Date(scwBaseYear+scwDropDownYears,11,32))>scwDateNow&&(new Date(scwBaseYear,0,0))<scwDateNow){
document.write("<tfoot class='scwFoot'>"+"<tr class='scwFoot'>"+"<td class='scwFoot' id='scwFoot' colspan='8'>"+"</td>"+"</tr>"+"</tfoot>");
}
document.write("</table>"+"</td>"+"</tr>"+"</table>");
if(document.addEventListener){
scwID("scw").addEventListener("click",scwCancel,false);
scwID("scwHeadLeft").addEventListener("click",scwStopPropagation,false);
scwID("scwMonths").addEventListener("click",scwStopPropagation,false);
scwID("scwMonths").addEventListener("change",scwStopPropagation,false);
scwID("scwYears").addEventListener("click",scwStopPropagation,false);
scwID("scwYears").addEventListener("change",scwStopPropagation,false);
scwID("scwHeadRight").addEventListener("click",scwStopPropagation,false);
}else{
scwID("scw").attachEvent("onclick",scwCancel);
scwID("scwHeadLeft").attachEvent("onclick",scwStopPropagation);
scwID("scwMonths").attachEvent("onclick",scwStopPropagation);
scwID("scwMonths").attachEvent("onchange",scwStopPropagation);
scwID("scwYears").attachEvent("onclick",scwStopPropagation);
scwID("scwYears").attachEvent("onchange",scwStopPropagation);
scwID("scwHeadRight").attachEvent("onclick",scwStopPropagation);
}
if(document.addEventListener){
document.addEventListener("click",scwHide,false);
}else{
document.attachEvent("onclick",scwHide);
}
Subclass=function(_3f8,_3f9){
if(!_3f8){
throw ("Can't create a subclass without a name");
}
var _3fa=_3f8.split(".");
var _3fb=window;
for(var i=0;i<_3fa.length;i++){
if(!_3fb[_3fa[i]]){
_3fb[_3fa[i]]=function(){
};
}
_3fb=_3fb[_3fa[i]];
}
if(_3f9){
var _3fd=eval("new "+_3f9+"()");
_3fb.prototype=_3fd;
_3fb.prototype.baseclass=_3fd;
}
_3fb.prototype.classname=_3f8;
return _3fb.prototype;
};
proto=new Subclass("Wikiwyg");
Wikiwyg.VERSION="0.13";
Wikiwyg.ua=navigator.userAgent.toLowerCase();
Wikiwyg.is_ie=(Wikiwyg.ua.indexOf("msie")!=-1&&Wikiwyg.ua.indexOf("opera")==-1&&Wikiwyg.ua.indexOf("webtv")==-1);
Wikiwyg.is_gecko=(Wikiwyg.ua.indexOf("gecko")!=-1&&Wikiwyg.ua.indexOf("safari")==-1&&Wikiwyg.ua.indexOf("konqueror")==-1);
Wikiwyg.is_safari=(Wikiwyg.ua.indexOf("safari")!=-1);
Wikiwyg.is_opera=(Wikiwyg.ua.indexOf("opera")!=-1);
Wikiwyg.is_konqueror=(Wikiwyg.ua.indexOf("konqueror")!=-1);
Wikiwyg.browserIsSupported=(Wikiwyg.is_gecko||Wikiwyg.is_ie);
proto.createWikiwygArea=function(div,_3ff){
this.set_config(_3ff);
this.initializeObject(div,_3ff);
};
proto.default_config={javascriptLocation:"lib/",doubleClickToEdit:false,toolbarClass:"Wikiwyg.Toolbar",firstMode:null,modeClasses:["Wikiwyg.Wysiwyg","Wikiwyg.Wikitext","Wikiwyg.Preview"]};
proto.initializeObject=function(div,_401){
if(!Wikiwyg.browserIsSupported){
return;
}
if(this.enabled){
return;
}
this.enabled=true;
this.div=div;
this.divHeight=this.div.offsetHeight;
if(!_401){
_401={};
}
this.set_config(_401);
this.mode_objects={};
for(var i=0;i<this.config.modeClasses.length;i++){
var _403=this.config.modeClasses[i];
var _404=eval("new "+_403+"()");
_404.wikiwyg=this;
_404.set_config(_401[_404.classtype]);
_404.initializeObject();
this.mode_objects[_403]=_404;
}
var _405=this.config.firstMode?this.config.firstMode:this.config.modeClasses[0];
this.setFirstModeByName(_405);
if(this.config.toolbarClass){
var _403=this.config.toolbarClass;
this.toolbarObject=eval("new "+_403+"()");
this.toolbarObject.wikiwyg=this;
this.toolbarObject.set_config(_401.toolbar);
this.toolbarObject.initializeObject();
this.placeToolbar(this.toolbarObject.div);
}
for(var i=0;i<this.config.modeClasses.length;i++){
var _406=this.config.modeClasses[i];
var _404=this.modeByName(_406);
this.insert_div_before(_404.div);
}
if(this.config.doubleClickToEdit){
var self=this;
this.div.ondblclick=function(){
self.editMode();
};
}
};
proto.set_config=function(_408){
var _409={};
var keys=[];
for(var key in this.default_config){
keys.push(key);
}
if(_408!=null){
for(var key in _408){
keys.push(key);
}
}
for(var ii=0;ii<keys.length;ii++){
var key=keys[ii];
if(_408!=null&&_408[key]!=null){
_409[key]=_408[key];
}else{
if(this.default_config[key]!=null){
_409[key]=this.default_config[key];
}else{
if(this[key]!=null){
_409[key]=this[key];
}
}
}
}
this.config=_409;
};
proto.insert_div_before=function(div){
div.style.display="none";
if(!div.iframe_hack){
this.div.parentNode.insertBefore(div,this.div);
}
};
proto.saveChanges=function(){
alert("Wikiwyg.prototype.saveChanges not subclassed");
};
proto.editMode=function(){
this.current_mode=this.first_mode;
this.current_mode.fromHtml(this.div.innerHTML);
this.toolbarObject.resetModeSelector();
this.current_mode.enableThis();
};
proto.displayMode=function(){
for(var i=0;i<this.config.modeClasses.length;i++){
var _40f=this.config.modeClasses[i];
var _410=this.modeByName(_40f);
_410.disableThis();
}
this.toolbarObject.disableThis();
this.div.style.display="block";
this.divHeight=this.div.offsetHeight;
};
proto.switchMode=function(_411){
var _412=this.modeByName(_411);
var _413=this.current_mode;
var self=this;
_412.enableStarted();
_413.disableStarted();
_413.toHtml(function(html){
self.previous_mode=_413;
_412.fromHtml(html);
_413.disableThis();
_412.enableThis();
_412.enableFinished();
_413.disableFinished();
self.current_mode=_412;
});
};
proto.modeByName=function(_416){
return this.mode_objects[_416];
};
proto.cancelEdit=function(){
this.displayMode();
};
proto.fromHtml=function(html){
this.div.innerHTML=html;
};
proto.placeToolbar=function(div){
this.insert_div_before(div);
};
proto.setFirstModeByName=function(_419){
if(!this.modeByName(_419)){
die("No mode named "+_419);
}
this.first_mode=this.modeByName(_419);
};
Wikiwyg.unique_id_base=0;
Wikiwyg.createUniqueId=function(){
return "wikiwyg_"+Wikiwyg.unique_id_base++;
};
Wikiwyg.liveUpdate=function(_41a,url,_41c,_41d){
if(_41a=="GET"){
return Ajax.get(url+"?"+_41c,_41d);
}
if(_41a=="POST"){
return Ajax.post(url,_41c,_41d);
}
throw ("Bad method: "+_41a+" passed to Wikiwyg.liveUpdate");
};
Wikiwyg.htmlUnescape=function(_41e){
return _41e.replace(/&(.*?);/g,function(_41f,s){
return s.match(/^amp$/i)?"&":s.match(/^quot$/i)?"\"":s.match(/^gt$/i)?">":s.match(/^lt$/i)?"<":s.match(/^#(\d+)$/)?String.fromCharCode(s.replace(/#/,"")):s.match(/^#x([0-9a-f]+)$/i)?String.fromCharCode(s.replace(/#/,"0")):s;
});
};
Wikiwyg.showById=function(id){
document.getElementById(id).style.visibility="inherit";
};
Wikiwyg.hideById=function(id){
document.getElementById(id).style.visibility="hidden";
};
Wikiwyg.changeLinksMatching=function(_423,_424,func){
var _426=document.getElementsByTagName("a");
for(var i=0;i<_426.length;i++){
var link=_426[i];
var _429=link.getAttribute(_423);
if(_429&&_429.match(_424)){
link.setAttribute("href","#");
link.onclick=func;
}
}
};
Wikiwyg.createElementWithAttrs=function(_42a,_42b,doc){
if(doc==null){
doc=document;
}
return Wikiwyg.create_element_with_attrs(_42a,_42b,doc);
};
Wikiwyg.create_element_with_attrs=function(_42d,_42e,doc){
var elem=doc.createElement(_42d);
for(name in _42e){
elem.setAttribute(name,_42e[name]);
}
return elem;
};
die=function(e){
throw (e);
};
String.prototype.times=function(n){
return n?this+this.times(n-1):"";
};
String.prototype.ucFirst=function(){
return this.substr(0,1).toUpperCase()+this.substr(1,this.length);
};
proto=new Subclass("Wikiwyg.Base");
proto.set_config=function(_433){
for(var key in this.config){
if(_433!=null&&_433[key]!=null){
this.merge_config(key,_433[key]);
}else{
if(this[key]!=null){
this.merge_config(key,this[key]);
}else{
if(this.wikiwyg.config[key]!=null){
this.merge_config(key,this.wikiwyg.config[key]);
}
}
}
}
};
proto.merge_config=function(key,_436){
if(_436 instanceof Array){
this.config[key]=_436;
}else{
if(typeof _436.test=="function"){
this.config[key]=_436;
}else{
if(_436 instanceof Object){
if(!this.config[key]){
this.config[key]={};
}
for(var _437 in _436){
this.config[key][_437]=_436[_437];
}
}else{
this.config[key]=_436;
}
}
}
};
proto=new Subclass("Wikiwyg.Mode","Wikiwyg.Base");
proto.enableThis=function(){
this.div.style.display="block";
this.display_unsupported_toolbar_buttons("none");
this.wikiwyg.toolbarObject.enableThis();
this.wikiwyg.div.style.display="none";
};
proto.display_unsupported_toolbar_buttons=function(_438){
if(!this.config){
return;
}
var _439=this.config.disabledToolbarButtons;
if(!_439||_439.length<1){
return;
}
var _43a=this.wikiwyg.toolbarObject.div;
var _43b=_43a.childNodes;
for(var i in _439){
var _43d=_439[i];
for(var i in _43b){
var _43e=_43b[i];
var src=_43e.src;
if(!src){
continue;
}
if(src.match(_43d)){
_43e.style.display=_438;
break;
}
}
}
};
proto.enableStarted=function(){
};
proto.enableFinished=function(){
};
proto.disableStarted=function(){
};
proto.disableFinished=function(){
};
proto.disableThis=function(){
this.display_unsupported_toolbar_buttons("inline");
this.div.style.display="none";
};
proto.process_command=function(_440){
if(this["do_"+_440]){
this["do_"+_440](_440);
}
};
proto.enable_keybindings=function(){
if(!this.key_press_function){
this.key_press_function=this.get_key_press_function();
this.get_keybinding_area().addEventListener("keypress",this.key_press_function,true);
}
};
proto.get_key_press_function=function(){
var self=this;
return function(e){
if(!e.ctrlKey){
return;
}
var key=String.fromCharCode(e.charCode).toLowerCase();
var _444="";
switch(key){
case "b":
_444="bold";
break;
case "i":
_444="italic";
break;
case "u":
_444="underline";
break;
case "d":
_444="strike";
break;
case "l":
_444="link";
break;
}
if(_444){
e.preventDefault();
e.stopPropagation();
self.process_command(_444);
}
};
};
proto.get_edit_height=function(){
var _445=parseInt(this.wikiwyg.divHeight*this.config.editHeightAdjustment);
var min=this.config.editHeightMinimum;
return _445<min?min:_445;
};
proto.setHeightOf=function(elem){
elem.height=this.get_edit_height()+"px";
};
proto.sanitize_dom=function(dom){
this.element_transforms(dom,{del:{name:"strike",attr:{}},strong:{name:"span",attr:{style:"font-weight: bold;"}},em:{name:"span",attr:{style:"font-style: italic;"}}});
};
proto.element_transforms=function(dom,_44a){
for(var orig in _44a){
var _44c=dom.getElementsByTagName(orig);
if(_44c.length==0){
continue;
}
for(var i=0;i<_44c.length;i++){
var elem=_44c[i];
var _44f=_44a[orig];
var _450=Wikiwyg.createElementWithAttrs(_44f.name,_44f.attr);
_450.innerHTML=elem.innerHTML;
elem.parentNode.replaceChild(_450,elem);
}
}
};
if(Wikiwyg.is_ie){
Wikiwyg.create_element_with_attrs=function(_451,_452,doc){
var str="";
for(name in _452){
str+=" "+name+"=\""+_452[name]+"\"";
}
return doc.createElement("<"+_451+str+">");
};
die=function(e){
alert(e);
throw (e);
};
proto=Wikiwyg.Mode.prototype;
proto.enable_keybindings=function(){
};
proto.sanitize_dom=function(dom){
this.element_transforms(dom,{del:{name:"strike",attr:{}}});
};
}
proto=new Subclass("Wikiwyg.Toolbar","Wikiwyg.Base");
proto.classtype="toolbar";
proto.config={divId:null,imagesLocation:"images/",imagesExtension:".gif",selectorWidth:"100px",controlLayout:["save","cancel","mode_selector","/","h1","h2","h3","h4","p","pre","|","bold","italic","underline","strike","|","link","hr","|","ordered","unordered","|","indent","outdent","|","table","|","help"],styleSelector:["label","p","h1","h2","h3","h4","h5","h6","pre"],controlLabels:{save:"Save",cancel:"Cancel",bold:"Bold (Ctrl+b)",italic:"Italic (Ctrl+i)",underline:"Underline (Ctrl+u)",strike:"Strike Through (Ctrl+d)",hr:"Horizontal Rule",ordered:"Numbered List",unordered:"Bulleted List",indent:"More Indented",outdent:"Less Indented",help:"About Wikiwyg",label:"[Style]",p:"Normal Text",pre:"Preformatted",h1:"Heading 1",h2:"Heading 2",h3:"Heading 3",h4:"Heading 4",h5:"Heading 5",h6:"Heading 6",link:"Create Link",unlink:"Remove Linkedness",table:"Create Table"}};
proto.initializeObject=function(){
if(this.config.divId){
this.div=document.getElementById(this.config.divId);
}else{
this.div=Wikiwyg.createElementWithAttrs("div",{"class":"wikiwyg_toolbar",id:"wikiwyg_toolbar"});
}
var _457=this.config;
for(var i=0;i<_457.controlLayout.length;i++){
var _459=_457.controlLayout[i];
var _45a=_457.controlLabels[_459];
if(_459=="save"){
this.addControlItem(_45a,"saveChanges");
}else{
if(_459=="cancel"){
this.addControlItem(_45a,"cancelEdit");
}else{
if(_459=="mode_selector"){
this.addModeSelector();
}else{
if(_459=="selector"){
this.add_styles();
}else{
if(_459=="help"){
this.add_help_button(_459,_45a);
}else{
if(_459=="|"){
this.add_separator();
}else{
if(_459=="/"){
this.add_break();
}else{
this.add_button(_459,_45a);
}
}
}
}
}
}
}
}
};
proto.enableThis=function(){
this.div.style.display="block";
};
proto.disableThis=function(){
this.div.style.display="none";
};
proto.make_button=function(type,_45c){
var base=this.config.imagesLocation;
var ext=this.config.imagesExtension;
return Wikiwyg.createElementWithAttrs("img",{"class":"wikiwyg_button",onmouseup:"this.style.border='1px outset';",onmouseover:"this.style.border='1px outset';",onmouseout:"this.style.borderColor=this.style.backgroundColor;"+"this.style.borderStyle='solid';",onmousedown:"this.style.border='1px inset';",alt:_45c,title:_45c,src:base+type+ext});
};
proto.add_button=function(type,_460){
var img=this.make_button(type,_460);
var self=this;
img.onclick=function(){
self.wikiwyg.current_mode.process_command(type);
};
this.div.appendChild(img);
};
proto.add_help_button=function(type,_464){
var img=this.make_button(type,_464);
var a=Wikiwyg.createElementWithAttrs("a",{target:"wikiwyg_button",href:"http://www.wikiwyg.net/about/"});
a.appendChild(img);
this.div.appendChild(a);
};
proto.add_separator=function(){
var base=this.config.imagesLocation;
var ext=this.config.imagesExtension;
this.div.appendChild(Wikiwyg.createElementWithAttrs("img",{"class":"wikiwyg_separator",alt:" | ",title:"",src:base+"separator"+ext}));
};
proto.addControlItem=function(text,_46a){
var span=Wikiwyg.createElementWithAttrs("span",{"class":"wikiwyg_control_link"});
var link=Wikiwyg.createElementWithAttrs("a",{href:"#"});
link.appendChild(document.createTextNode(text));
span.appendChild(link);
var self=this;
link.onclick=function(){
eval("self.wikiwyg."+_46a+"()");
return false;
};
this.div.appendChild(span);
};
proto.resetModeSelector=function(){
if(this.firstModeRadio){
var temp=this.firstModeRadio.onclick;
this.firstModeRadio.onclick=null;
this.firstModeRadio.click();
this.firstModeRadio.onclick=temp;
}
};
proto.addModeSelector=function(){
var span=document.createElement("span");
var _470=Wikiwyg.createUniqueId();
for(var i=0;i<this.wikiwyg.config.modeClasses.length;i++){
var _472=this.wikiwyg.config.modeClasses[i];
var _473=this.wikiwyg.mode_objects[_472];
var _474=Wikiwyg.createUniqueId();
var _475=i==0?"checked":"";
var _476=Wikiwyg.createElementWithAttrs("input",{type:"radio",name:_470,id:_474,value:_473.classname,"checked":_475});
if(!this.firstModeRadio){
this.firstModeRadio=_476;
}
var self=this;
_476.onclick=function(){
self.wikiwyg.switchMode(this.value);
};
var _478=Wikiwyg.createElementWithAttrs("label",{"for":_474});
_478.appendChild(document.createTextNode(_473.modeDescription));
span.appendChild(_476);
span.appendChild(_478);
}
this.div.appendChild(span);
};
proto.add_break=function(){
this.div.appendChild(document.createElement("br"));
};
proto.add_styles=function(){
var _479=this.config.styleSelector;
var _47a=this.config.controlLabels;
this.styleSelect=document.createElement("select");
this.styleSelect.className="wikiwyg_selector";
if(this.config.selectorWidth){
this.styleSelect.style.width=this.config.selectorWidth;
}
for(var i=0;i<_479.length;i++){
value=_479[i];
var _47c=Wikiwyg.createElementWithAttrs("option",{"value":value});
_47c.appendChild(document.createTextNode(_47a[value]||value));
this.styleSelect.appendChild(_47c);
}
var self=this;
this.styleSelect.onchange=function(){
self.set_style(this.value);
};
this.div.appendChild(this.styleSelect);
};
proto.set_style=function(_47e){
var idx=this.styleSelect.selectedIndex;
if(idx!=0){
this.wikiwyg.current_mode.process_command(_47e);
}
this.styleSelect.selectedIndex=0;
};
proto=new Subclass("Wikiwyg.Wysiwyg","Wikiwyg.Mode");
proto.classtype="wysiwyg";
proto.modeDescription="Wysiwyg";
proto.config={useParentStyles:true,useStyleMedia:"wikiwyg",iframeId:null,iframeObject:null,disabledToolbarButtons:[],editHeightMinimum:150,editHeightAdjustment:1.3,clearRegex:null};
proto.initializeObject=function(){
this.edit_iframe=this.get_edit_iframe();
this.div=this.edit_iframe;
this.set_design_mode_early();
};
proto.set_design_mode_early=function(){
};
proto.fromHtml=function(html){
var dom=document.createElement("div");
dom.innerHTML=html;
this.sanitize_dom(dom);
this.set_inner_html(dom.innerHTML);
};
proto.toHtml=function(func){
func(this.get_inner_html());
};
proto.fix_up_relative_imgs=function(){
var base=location.href.replace(/(.*?:\/\/.*?\/).*/,"$1");
var imgs=this.get_edit_document().getElementsByTagName("img");
for(var ii=0;ii<imgs.length;++ii){
imgs[ii].src=imgs[ii].src.replace(/^\//,base);
}
};
proto.enableThis=function(){
Wikiwyg.Mode.prototype.enableThis.call(this);
this.edit_iframe.style.border="1px black solid";
this.edit_iframe.width="100%";
this.setHeightOf(this.edit_iframe);
this.fix_up_relative_imgs();
this.get_edit_document().designMode="on";
this.apply_stylesheets();
this.enable_keybindings();
this.clear_inner_html();
};
proto.clear_inner_html=function(){
var _486=this.get_inner_html();
var _487=this.config.clearRegex;
if(_487&&_486.match(_487)){
this.set_inner_html("");
}
};
proto.get_keybinding_area=function(){
return this.get_edit_document();
};
proto.get_edit_iframe=function(){
var _488;
if(this.config.iframeId){
_488=document.getElementById(this.config.iframeId);
_488.iframe_hack=true;
}else{
if(this.config.iframeObject){
_488=this.config.iframeObject;
_488.iframe_hack=true;
}else{
_488=document.createElement("iframe");
}
}
return _488;
};
proto.get_edit_window=function(){
return this.edit_iframe.contentWindow;
};
proto.get_edit_document=function(){
return this.get_edit_window().document;
};
proto.get_inner_html=function(){
return this.get_edit_document().body.innerHTML;
};
proto.set_inner_html=function(html){
this.get_edit_document().body.innerHTML=html;
};
proto.apply_stylesheets=function(){
var _48a=document.styleSheets;
var head=this.get_edit_document().getElementsByTagName("head")[0];
for(var i=0;i<_48a.length;i++){
var _48d=_48a[i];
if(_48d.href==location.href){
this.apply_inline_stylesheet(_48d,head);
}else{
if(this.should_link_stylesheet(_48d)){
this.apply_linked_stylesheet(_48d,head);
}
}
}
};
proto.apply_inline_stylesheet=function(_48e,head){
var _490="";
for(var i=0;i<_48e.cssRules.length;i++){
if(_48e.cssRules[i].type==3){
_490+=Ajax.get(_48e.cssRules[i].href);
}else{
_490+=_48e.cssRules[i].cssText+"\n";
}
}
if(_490.length>0){
_490+="\nbody { padding: 5px; }\n";
this.append_inline_style_element(_490,head);
}
};
proto.append_inline_style_element=function(_492,head){
var _494=document.createElement("style");
_494.setAttribute("type","text/css");
if(_494.styleSheet){
_494.styleSheet.cssText=_492;
}else{
var _495=document.createTextNode(_492);
_494.appendChild(_495);
head.appendChild(_494);
}
};
proto.should_link_stylesheet=function(_496,head){
var _498=_496.media;
var _499=this.config;
var _49a=_498.mediaText?_498.mediaText:_498;
var _49b=((!_49a||_49a=="screen")&&_499.useParentStyles);
var _49c=(_49a&&(_49a==_499.useStyleMedia));
if(!_49b&&!_49c){
return false;
}else{
return true;
}
};
proto.apply_linked_stylesheet=function(_49d,head){
var link=Wikiwyg.createElementWithAttrs("link",{href:_49d.href,type:_49d.type,media:"screen",rel:"STYLESHEET"},this.get_edit_document());
head.appendChild(link);
};
proto.process_command=function(_4a0){
if(this["do_"+_4a0]){
this["do_"+_4a0](_4a0);
}
if(!Wikiwyg.is_ie){
this.get_edit_window().focus();
}
};
proto.exec_command=function(_4a1,_4a2){
this.get_edit_document().execCommand(_4a1,false,_4a2);
};
proto.format_command=function(_4a3){
this.exec_command("formatblock","<"+_4a3+">");
};
proto.do_bold=proto.exec_command;
proto.do_italic=proto.exec_command;
proto.do_underline=proto.exec_command;
proto.do_strike=function(){
this.exec_command("strikethrough");
};
proto.do_hr=function(){
this.exec_command("inserthorizontalrule");
};
proto.do_ordered=function(){
this.exec_command("insertorderedlist");
};
proto.do_unordered=function(){
this.exec_command("insertunorderedlist");
};
proto.do_indent=proto.exec_command;
proto.do_outdent=proto.exec_command;
proto.do_h1=proto.format_command;
proto.do_h2=proto.format_command;
proto.do_h3=proto.format_command;
proto.do_h4=proto.format_command;
proto.do_h5=proto.format_command;
proto.do_h6=proto.format_command;
proto.do_pre=proto.format_command;
proto.do_p=proto.format_command;
proto.do_table=function(){
var html="<table><tbody>"+"<tr><td>A</td>"+"<td>B</td>"+"<td>C</td></tr>"+"<tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr>"+"<tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr>"+"</tbody></table>";
this.insert_html(html);
};
proto.insert_html=function(html){
this.get_edit_window().focus();
this.exec_command("inserthtml",html);
};
proto.do_unlink=proto.exec_command;
proto.do_link=function(){
var _4a6=this.get_link_selection_text();
if(!_4a6){
return;
}
var url;
var _4a8=_4a6.match(/(.*?)\b((?:http|https|ftp|irc|file):\/\/\S+)(.*)/);
if(_4a8){
if(_4a8[1]||_4a8[3]){
return null;
}
url=_4a8[2];
}else{
url=escape(_4a6);
}
this.exec_command("createlink",url);
};
proto.do_www=function(){
var _4a9=this.get_link_selection_text();
if(_4a9!=null){
var url=prompt("Please enter a link","Type in your link here");
this.exec_command("createlink",url);
}
};
proto.get_selection_text=function(){
return this.get_edit_window().getSelection().toString();
};
proto.get_link_selection_text=function(){
var _4ab=this.get_selection_text();
if(!_4ab){
alert("Please select the text you would like to turn into a link.");
return;
}
return _4ab;
};
if(Wikiwyg.is_ie){
proto.set_design_mode_early=function(_4ac){
this.get_edit_document().designMode="on";
};
proto.get_edit_window=function(){
return this.edit_iframe;
};
proto.get_edit_document=function(){
return this.edit_iframe.contentWindow.document;
};
proto.get_selection_text=function(){
var _4ad=this.get_edit_document().selection;
if(_4ad!=null){
return _4ad.createRange().htmlText;
}
return "";
};
proto.insert_html=function(html){
var doc=this.get_edit_document();
var _4b0=this.get_edit_document().selection.createRange();
if(_4b0.boundingTop==2&&_4b0.boundingLeft==2){
return;
}
_4b0.pasteHTML(html);
_4b0.collapse(false);
_4b0.select();
};
proto.enable_keybindings=function(){
};
}
proto=new Subclass("Wikiwyg.Wikitext","Wikiwyg.Mode");
klass=Wikiwyg.Wikitext;
proto.classtype="wikitext";
proto.modeDescription="Wikitext";
proto.config={textareaId:null,supportCamelCaseLinks:false,javascriptLocation:null,clearRegex:null,editHeightMinimum:10,editHeightAdjustment:1.3,markupRules:{link:["bound_phrase","[","]"],bold:["bound_phrase","*","*"],code:["bound_phrase","`","`"],italic:["bound_phrase","/","/"],underline:["bound_phrase","_","_"],strike:["bound_phrase","-","-"],p:["start_lines",""],pre:["start_lines","    "],h1:["start_line","= "],h2:["start_line","== "],h3:["start_line","=== "],h4:["start_line","==== "],h5:["start_line","===== "],h6:["start_line","====== "],ordered:["start_lines","#"],unordered:["start_lines","*"],indent:["start_lines",">"],hr:["line_alone","----"],table:["line_alone","| A | B | C |\n|   |   |   |\n|   |   |   |"],www:["bound_phrase","[","]"]}};
proto.initializeObject=function(){
this.initialize_object();
};
proto.initialize_object=function(){
this.div=document.createElement("div");
if(this.config.textareaId){
this.textarea=document.getElementById(this.config.textareaId);
}else{
this.textarea=document.createElement("textarea");
}
this.textarea.setAttribute("id","wikiwyg_wikitext_textarea");
this.div.appendChild(this.textarea);
this.area=this.textarea;
this.clear_inner_text();
};
proto.clear_inner_text=function(){
if(Wikiwyg.is_safari){
return;
}
var self=this;
this.area.onclick=function(){
var _4b2=self.area.value;
var _4b3=self.config.clearRegex;
if(_4b3&&_4b2.match(_4b3)){
self.area.value="";
}
};
};
proto.enableThis=function(){
Wikiwyg.Mode.prototype.enableThis.call(this);
this.textarea.style.width="100%";
this.setHeightOfEditor();
this.enable_keybindings();
};
proto.setHeightOfEditor=function(){
var _4b4=this.config;
var _4b5=_4b4.editHeightAdjustment;
var area=this.textarea;
if(Wikiwyg.is_safari){
return area.setAttribute("rows",25);
}
var text=this.getTextArea();
var rows=text.split(/\n/).length;
var _4b9=parseInt(rows*_4b5);
if(_4b9<_4b4.editHeightMinimum){
_4b9=_4b4.editHeightMinimum;
}
area.setAttribute("rows",_4b9);
};
proto.toWikitext=function(){
return this.getTextArea();
};
proto.toHtml=function(func){
var _4bb=this.canonicalText();
this.convertWikitextToHtml(_4bb,func);
};
proto.canonicalText=function(){
var _4bc=this.getTextArea();
if(_4bc[_4bc.length-1]!="\n"){
_4bc+="\n";
}
return _4bc;
};
proto.fromHtml=function(html){
this.setTextArea("Loading...");
var self=this;
this.convertHtmlToWikitext(html,function(_4bf){
self.setTextArea(_4bf);
});
};
proto.getTextArea=function(){
return this.textarea.value;
};
proto.setTextArea=function(text){
this.textarea.value=text;
};
proto.convertWikitextToHtml=function(_4c1,func){
alert("Wikitext changes cannot be converted to HTML\nWikiwyg.Wikitext.convertWikitextToHtml is not implemented here");
func(this.copyhtml);
};
proto.convertHtmlToWikitext=function(html,func){
func(this.convert_html_to_wikitext(html));
};
proto.get_keybinding_area=function(){
return this.textarea;
};
Wikiwyg.Wikitext.phrase_end_re=/[\s\.\:\;\,\!\?\(\)]/;
proto.find_left=function(t,_4c6,_4c7){
var _4c8=t.substr(_4c6-1,1);
var _4c9=t.substr(_4c6-2,1);
if(_4c6==0){
return _4c6;
}
if(_4c8.match(_4c7)){
if((_4c8!=".")||(_4c9.match(/\s/))){
return _4c6;
}
}
return this.find_left(t,_4c6-1,_4c7);
};
proto.find_right=function(t,_4cb,_4cc){
var _4cd=t.substr(_4cb,1);
var _4ce=t.substr(_4cb+1,1);
if(_4cb>=t.length){
return _4cb;
}
if(_4cd.match(_4cc)){
if((_4cd!=".")||(_4ce.match(/\s/))){
return _4cb;
}
}
return this.find_right(t,_4cb+1,_4cc);
};
proto.get_lines=function(){
t=this.area;
var _4cf=t.selectionStart;
var _4d0=t.selectionEnd;
if(_4cf==null){
_4cf=_4d0;
if(_4cf==null){
return false;
}
_4cf=_4d0=t.value.substr(0,_4cf).replace(/\r/g,"").length;
}
var _4d1=t.value.replace(/\r/g,"");
selection=_4d1.substr(_4cf,_4d0-_4cf);
_4cf=this.find_right(_4d1,_4cf,/[^\r\n]/);
_4d0=this.find_left(_4d1,_4d0,/[^\r\n]/);
this.selection_start=this.find_left(_4d1,_4cf,/[\r\n]/);
this.selection_end=this.find_right(_4d1,_4d0,/[\r\n]/);
t.setSelectionRange(_4cf,_4d0);
t.focus();
this.start=_4d1.substr(0,this.selection_start);
this.sel=_4d1.substr(this.selection_start,this.selection_end-this.selection_start);
this.finish=_4d1.substr(this.selection_end,_4d1.length);
return true;
};
proto.alarm_on=function(){
var area=this.area;
var _4d3=area.style.background;
area.style.background="#f88";
function alarm_off(){
area.style.background=_4d3;
}
window.setTimeout(alarm_off,250);
area.focus();
};
proto.get_words=function(){
function is_insane(_4d4){
return _4d4.match(/\r?\n(\r?\n|\*+ |\#+ |\=+ )/);
}
t=this.area;
var _4d5=t.selectionStart;
var _4d6=t.selectionEnd;
if(_4d5==null){
_4d5=_4d6;
if(_4d5==null){
return false;
}
_4d5=_4d6=t.value.substr(0,_4d5).replace(/\r/g,"").length;
}
var _4d7=t.value.replace(/\r/g,"");
selection=_4d7.substr(_4d5,_4d6-_4d5);
_4d5=this.find_right(_4d7,_4d5,/(\S|\r?\n)/);
if(_4d5>_4d6){
_4d5=_4d6;
}
_4d6=this.find_left(_4d7,_4d6,/(\S|\r?\n)/);
if(_4d6<_4d5){
_4d6=_4d5;
}
if(is_insane(selection)){
this.alarm_on();
return false;
}
this.selection_start=this.find_left(_4d7,_4d5,Wikiwyg.Wikitext.phrase_end_re);
this.selection_end=this.find_right(_4d7,_4d6,Wikiwyg.Wikitext.phrase_end_re);
t.setSelectionRange(this.selection_start,this.selection_end);
t.focus();
this.start=_4d7.substr(0,this.selection_start);
this.sel=_4d7.substr(this.selection_start,this.selection_end-this.selection_start);
this.finish=_4d7.substr(this.selection_end,_4d7.length);
return true;
};
proto.markup_is_on=function(_4d8,_4d9){
return (this.sel.match(_4d8)&&this.sel.match(_4d9));
};
proto.clean_selection=function(_4da,_4db){
this.sel=this.sel.replace(_4da,"");
this.sel=this.sel.replace(_4db,"");
};
proto.toggle_same_format=function(_4dc,_4dd){
_4dc=this.clean_regexp(_4dc);
_4dd=this.clean_regexp(_4dd);
var _4de=new RegExp("^"+_4dc);
var _4df=new RegExp(_4dd+"$");
if(this.markup_is_on(_4de,_4df)){
this.clean_selection(_4de,_4df);
return true;
}
return false;
};
proto.clean_regexp=function(_4e0){
_4e0=_4e0.replace(/([\^\$\*\+\.\?\[\]\{\}])/g,"\\$1");
return _4e0;
};
proto.insert_text_at_cursor=function(text){
var t=this.area;
var _4e3=t.selectionStart;
var _4e4=t.selectionEnd;
if(_4e3==null){
_4e3=_4e4;
if(_4e3==null){
return false;
}
}
var _4e5=t.value.substr(0,_4e3);
var _4e6=t.value.substr(_4e4,t.value.length);
t.value=_4e5+text+_4e6;
};
proto.set_text_and_selection=function(text,_4e8,end){
this.area.value=text;
this.area.setSelectionRange(_4e8,end);
};
proto.add_markup_words=function(_4ea,_4eb,_4ec){
if(this.toggle_same_format(_4ea,_4eb)){
this.selection_end=this.selection_end-(_4ea.length+_4eb.length);
_4ea="";
_4eb="";
}
if(this.sel.length==0){
if(_4ec){
this.sel=_4ec;
}
var text=this.start+_4ea+this.sel+_4eb+this.finish;
var _4ee=this.selection_start+_4ea.length;
var end=this.selection_end+_4ea.length+this.sel.length;
this.set_text_and_selection(text,_4ee,end);
}else{
var text=this.start+_4ea+this.sel+_4eb+this.finish;
var _4ee=this.selection_start;
var end=this.selection_end+_4ea.length+_4eb.length;
this.set_text_and_selection(text,_4ee,end);
}
this.area.focus();
};
proto.add_markup_lines=function(_4f0){
var _4f1=new RegExp("^"+this.clean_regexp(_4f0),"gm");
var _4f2=/^(\^+|\=+|\*+|#+|>+|    )/gm;
var _4f3;
if(!_4f0.length){
this.sel=this.sel.replace(_4f2,"");
this.sel=this.sel.replace(/^\ +/gm,"");
}else{
if((_4f0=="    ")&&this.sel.match(/^\S/m)){
this.sel=this.sel.replace(/^/gm,_4f0);
}else{
if((!_4f0.match(/[\=\^]/))&&this.sel.match(_4f1)){
this.sel=this.sel.replace(_4f1,"");
if(_4f0!="    "){
this.sel=this.sel.replace(/^ */gm,"");
}
}else{
if(_4f3=this.sel.match(_4f2)){
if(_4f0=="    "){
this.sel=this.sel.replace(/^/gm,_4f0);
}else{
if(_4f0.match(/[\=\^]/)){
this.sel=this.sel.replace(_4f2,_4f0);
}else{
this.sel=this.sel.replace(_4f2,function(_4f4){
return _4f0.times(_4f4.length);
});
}
}
}else{
if(this.sel.length>0){
this.sel=this.sel.replace(/^(.*\S+)/gm,_4f0+" $1");
}else{
this.sel=_4f0+" ";
}
}
}
}
}
var text=this.start+this.sel+this.finish;
var _4f6=this.selection_start;
var end=this.selection_start+this.sel.length;
this.set_text_and_selection(text,_4f6,end);
this.area.focus();
};
proto.bound_markup_lines=function(_4f8){
var _4f9=_4f8[1];
var _4fa=_4f8[2];
var _4fb=new RegExp("^"+this.clean_regexp(_4f9),"gm");
var _4fc=new RegExp(this.clean_regexp(_4fa)+"$","gm");
var _4fd=/^(\^+|\=+|\*+|#+|>+) */gm;
var _4fe=/( +(\^+|\=+))?$/gm;
var _4ff;
if(this.sel.match(_4fb)){
this.sel=this.sel.replace(_4fb,"");
this.sel=this.sel.replace(_4fc,"");
}else{
if(_4ff=this.sel.match(_4fd)){
this.sel=this.sel.replace(_4fd,_4f9);
this.sel=this.sel.replace(_4fe,_4fa);
}else{
if(this.sel.length>0){
this.sel=this.sel.replace(/^(.*\S+)/gm,_4f9+"$1"+_4fa);
}else{
this.sel=_4f9+_4fa;
}
}
}
var text=this.start+this.sel+this.finish;
var _501=this.selection_start;
var end=this.selection_start+this.sel.length;
this.set_text_and_selection(text,_501,end);
this.area.focus();
};
proto.markup_bound_line=function(_503){
var _504=this.area.scrollTop;
if(this.get_lines()){
this.bound_markup_lines(_503);
}
this.area.scrollTop=_504;
};
proto.markup_start_line=function(_505){
var _506=_505[1];
_506=_506.replace(/ +/,"");
var _507=this.area.scrollTop;
if(this.get_lines()){
this.add_markup_lines(_506);
}
this.area.scrollTop=_507;
};
proto.markup_start_lines=function(_508){
var _509=_508[1];
var _50a=this.area.scrollTop;
if(this.get_lines()){
this.add_markup_lines(_509);
}
this.area.scrollTop=_50a;
};
proto.markup_bound_phrase=function(_50b){
var _50c=_50b[1];
var _50d=_50b[2];
var _50e=this.area.scrollTop;
if(_50d=="undefined"){
_50d=_50c;
}
if(this.get_words()){
this.add_markup_words(_50c,_50d,null);
}
this.area.scrollTop=_50e;
};
klass.make_do=function(_50f){
return function(){
var _510=this.config.markupRules[_50f];
var _511=_510[0];
if(!this["markup_"+_511]){
die("No handler for markup: \""+_511+"\"");
}
this["markup_"+_511](_510);
};
};
proto.do_link=klass.make_do("link");
proto.do_bold=klass.make_do("bold");
proto.do_code=klass.make_do("code");
proto.do_italic=klass.make_do("italic");
proto.do_underline=klass.make_do("underline");
proto.do_strike=klass.make_do("strike");
proto.do_p=klass.make_do("p");
proto.do_pre=klass.make_do("pre");
proto.do_h1=klass.make_do("h1");
proto.do_h2=klass.make_do("h2");
proto.do_h3=klass.make_do("h3");
proto.do_h4=klass.make_do("h4");
proto.do_h5=klass.make_do("h5");
proto.do_h6=klass.make_do("h6");
proto.do_ordered=klass.make_do("ordered");
proto.do_unordered=klass.make_do("unordered");
proto.do_hr=klass.make_do("hr");
proto.do_table=klass.make_do("table");
proto.do_www=function(){
var url=prompt("Please enter a link","Type in your link here");
var old=this.config.markupRules.www[1];
this.config.markupRules.www[1]+=url+" ";
var _514=this.config.markupRules["www"];
var _515=_514[0];
if(!this["markup_"+_515]){
die("No handler for markup: \""+_515+"\"");
}
this["markup_"+_515](_514);
this.config.markupRules.www[1]=old;
};
proto.selection_mangle=function(_516){
var _517=this.area.scrollTop;
if(!this.get_lines()){
this.area.scrollTop=_517;
return;
}
if(_516(this)){
var text=this.start+this.sel+this.finish;
var _519=this.selection_start;
var end=this.selection_start+this.sel.length;
this.set_text_and_selection(text,_519,end);
}
this.area.focus();
};
proto.do_indent=function(){
this.selection_mangle(function(that){
if(that.sel==""){
return false;
}
that.sel=that.sel.replace(/^(([\*\-\#])+(?=\s))/gm,"$2$1");
that.sel=that.sel.replace(/^([\>\=])/gm,"$1$1");
that.sel=that.sel.replace(/^([^\>\*\-\#\=\r\n])/gm,"> $1");
that.sel=that.sel.replace(/^\={7,}/gm,"======");
return true;
});
};
proto.do_outdent=function(){
this.selection_mangle(function(that){
if(that.sel==""){
return false;
}
that.sel=that.sel.replace(/^([\>\*\-\#\=] ?)/gm,"");
return true;
});
};
proto.do_unlink=function(){
this.selection_mangle(function(that){
that.sel=that.kill_linkedness(that.sel);
return true;
});
};
proto.kill_linkedness=function(str){
while(str.match(/\[.*\]/)){
str=str.replace(/\[(.*?)\]/,"$1");
}
str=str.replace(/^(.*)\]/,"] $1");
str=str.replace(/\[(.*)$/,"$1 [");
return str;
};
proto.markup_line_alone=function(_51f){
var t=this.area;
var _521=t.scrollTop;
var _522=t.selectionStart;
var _523=t.selectionEnd;
if(_522==null){
_522=_523;
}
var text=t.value;
this.selection_start=this.find_right(text,_522,/\r?\n/);
this.selection_end=this.selection_start;
t.setSelectionRange(this.selection_start,this.selection_start);
t.focus();
var _525=_51f[1];
this.start=t.value.substr(0,this.selection_start);
this.finish=t.value.substr(this.selection_end,t.value.length);
var text=this.start+"\n"+_525+this.finish;
var _526=this.selection_start+_525.length+1;
var end=this.selection_end+_525.length+1;
this.set_text_and_selection(text,_526,end);
t.scrollTop=_521;
};
proto.convert_html_to_wikitext=function(html){
this.copyhtml=html;
var dom=document.createElement("div");
dom.innerHTML=html;
this.output=[];
this.list_type=[];
this.indent_level=0;
this.no_collapse_text=false;
this.normalizeDomWhitespace(dom);
this.normalizeDomStructure(dom);
this.walk(dom);
this.assert_new_line();
return this.join_output(this.output);
};
proto.normalizeDomStructure=function(dom){
this.normalize_styled_blocks(dom,"p");
this.normalize_styled_lists(dom,"ol");
this.normalize_styled_lists(dom,"ul");
this.normalize_styled_blocks(dom,"li");
this.normalize_span_whitespace(dom,"span");
};
proto.normalize_span_whitespace=function(dom,tag){
var grep=function(_52e){
return Boolean(_52e.getAttribute("style"));
};
var _52f=this.array_elements_by_tag_name(dom,tag,grep);
for(var i=0;i<_52f.length;i++){
var _531=_52f[i];
var node=_531.firstChild;
while(node){
if(node.nodeType==3){
node.nodeValue=node.nodeValue.replace(/^\n+/,"");
break;
}
node=node.nextSibling;
}
var node=_531.lastChild;
while(node){
if(node.nodeType==3){
node.nodeValue=node.nodeValue.replace(/\n+$/,"");
break;
}
node=node.previousSibling;
}
}
};
proto.normalize_styled_blocks=function(dom,tag){
var _535=this.array_elements_by_tag_name(dom,tag);
for(var i=0;i<_535.length;i++){
var _537=_535[i];
var _538=_537.getAttribute("style");
if(!_538){
continue;
}
_537.removeAttribute("style");
_537.innerHTML="<span style=\""+_538+"\">"+_537.innerHTML+"</span>";
}
};
proto.normalize_styled_lists=function(dom,tag){
var _53b=this.array_elements_by_tag_name(dom,tag);
for(var i=0;i<_53b.length;i++){
var _53d=_53b[i];
var _53e=_53d.getAttribute("style");
if(!_53e){
continue;
}
_53d.removeAttribute("style");
var _53f=_53d.getElementsByTagName("li");
for(var j=0;j<_53f.length;j++){
_53f[j].innerHTML="<span style=\""+_53e+"\">"+_53f[j].innerHTML+"</span>";
}
}
};
proto.array_elements_by_tag_name=function(dom,tag,grep){
var _544=dom.getElementsByTagName(tag);
var _545=[];
for(var i=0;i<_544.length;i++){
if(grep&&!grep(_544[i])){
continue;
}
_545.push(_544[i]);
}
return _545;
};
proto.normalizeDomWhitespace=function(dom){
var tags=["span","strong","em","strike","del","tt"];
for(var ii=0;ii<tags.length;ii++){
var _54a=dom.getElementsByTagName(tags[ii]);
for(var i=0;i<_54a.length;i++){
this.normalizePhraseWhitespace(_54a[i]);
}
}
this.normalizeNewlines(dom,["br","blockquote"],"nextSibling");
this.normalizeNewlines(dom,["p","div","blockquote"],"firstChild");
};
proto.normalizeNewlines=function(dom,tags,_54e){
for(var ii=0;ii<tags.length;ii++){
var _550=dom.getElementsByTagName(tags[ii]);
for(var jj=0;jj<_550.length;jj++){
var _552=_550[jj][_54e];
if(_552&&_552.nodeType=="3"){
_552.nodeValue=_552.nodeValue.replace(/^\n/,"");
}
}
}
};
proto.normalizePhraseWhitespace=function(_553){
if(this.elementHasComment(_553)){
return;
}
var _554=this.getFirstTextNode(_553);
var _555=this.getPreviousTextNode(_553);
var _556=this.getLastTextNode(_553);
var _557=this.getNextTextNode(_553);
if(this.destroyPhraseMarkup(_553)){
return;
}
if(_554&&_554.nodeValue.match(/^ /)){
_554.nodeValue=_554.nodeValue.replace(/^ +/,"");
if(_555&&!_555.nodeValue.match(/ $/)){
_555.nodeValue=_555.nodeValue+" ";
}
}
if(_556&&_556.nodeValue.match(/ $/)){
_556.nodeValue=_556.nodeValue.replace(/ $/,"");
if(_557&&!_557.nodeValue.match(/^ /)){
_557.nodeValue=" "+_557.nodeValue;
}
}
};
proto.elementHasComment=function(_558){
var node=_558.lastChild;
return node&&(node.nodeType==8);
};
proto.destroyPhraseMarkup=function(_55a){
if(this.start_is_no_good(_55a)||this.end_is_no_good(_55a)){
return this.destroyElement(_55a);
}
return false;
};
proto.start_is_no_good=function(_55b){
var _55c=this.getFirstTextNode(_55b);
var _55d=this.getPreviousTextNode(_55b);
if(!_55c){
return true;
}
if(_55c.nodeValue.match(/^ /)){
return false;
}
if(!_55d||_55d.nodeValue=="\n"){
return false;
}
return !_55d.nodeValue.match(/[ "]$/);
};
proto.end_is_no_good=function(_55e){
var _55f=this.getLastTextNode(_55e);
var _560=this.getNextTextNode(_55e);
for(var n=_55e;n&&n.nodeType!=3;n=n.lastChild){
if(n.nodeType==8){
return false;
}
}
if(!_55f){
return true;
}
if(_55f.nodeValue.match(/ $/)){
return false;
}
if(!_560||_560.nodeValue=="\n"){
return false;
}
return !_560.nodeValue.match(/^[ ."\n]/);
};
proto.destroyElement=function(_562){
var span=document.createElement("font");
span.innerHTML=_562.innerHTML;
_562.parentNode.replaceChild(span,_562);
return true;
};
proto.getFirstTextNode=function(_564){
for(node=_564;node&&node.nodeType!=3;node=node.firstChild){
}
return node;
};
proto.getLastTextNode=function(_565){
for(node=_565;node&&node.nodeType!=3;node=node.lastChild){
}
return node;
};
proto.getPreviousTextNode=function(_566){
var node=_566.previousSibling;
if(node&&node.nodeType!=3){
node=null;
}
return node;
};
proto.getNextTextNode=function(_568){
var node=_568.nextSibling;
if(node&&node.nodeType!=3){
node=null;
}
return node;
};
proto.appendOutput=function(_56a){
this.output.push(_56a);
};
proto.join_output=function(_56b){
var list=this.remove_stops(_56b);
list=this.cleanup_output(list);
return list.join("");
};
proto.cleanup_output=function(list){
return list;
};
proto.remove_stops=function(list){
var _56f=[];
for(var i=0;i<list.length;i++){
if(typeof (list[i])!="string"){
continue;
}
_56f.push(list[i]);
}
return _56f;
};
proto.walk=function(_571){
if(!_571){
return;
}
for(var part=_571.firstChild;part;part=part.nextSibling){
if(part.nodeType==1){
this.dispatch_formatter(part);
}else{
if(part.nodeType==3){
if(part.nodeValue.match(/[^\n]/)&&!part.nodeValue.match(/^\n[\ \t]*$/)){
if(this.no_collapse_text){
this.appendOutput(part.nodeValue);
}else{
this.appendOutput(this.collapse(part.nodeValue));
}
}
}
}
}
this.no_collapse_text=false;
};
proto.dispatch_formatter=function(_573){
var _574="format_"+_573.nodeName.toLowerCase();
if(!this[_574]){
_574="handle_undefined";
}
this[_574](_573);
};
proto.skip=function(){
};
proto.pass=function(_575){
this.walk(_575);
};
proto.handle_undefined=function(_576){
this.appendOutput("<"+_576.nodeName+">");
this.walk(_576);
this.appendOutput("</"+_576.nodeName+">");
};
proto.handle_undefined=proto.skip;
proto.format_abbr=proto.pass;
proto.format_acronym=proto.pass;
proto.format_address=proto.pass;
proto.format_applet=proto.skip;
proto.format_area=proto.skip;
proto.format_basefont=proto.skip;
proto.format_base=proto.skip;
proto.format_bgsound=proto.skip;
proto.format_big=proto.pass;
proto.format_blink=proto.pass;
proto.format_body=proto.pass;
proto.format_br=proto.skip;
proto.format_button=proto.skip;
proto.format_caption=proto.pass;
proto.format_center=proto.pass;
proto.format_cite=proto.pass;
proto.format_col=proto.pass;
proto.format_colgroup=proto.pass;
proto.format_dd=proto.pass;
proto.format_dfn=proto.pass;
proto.format_dl=proto.pass;
proto.format_dt=proto.pass;
proto.format_embed=proto.skip;
proto.format_field=proto.skip;
proto.format_fieldset=proto.skip;
proto.format_font=proto.pass;
proto.format_form=proto.skip;
proto.format_frame=proto.skip;
proto.format_frameset=proto.skip;
proto.format_head=proto.skip;
proto.format_html=proto.pass;
proto.format_iframe=proto.pass;
proto.format_input=proto.skip;
proto.format_ins=proto.pass;
proto.format_isindex=proto.skip;
proto.format_label=proto.skip;
proto.format_legend=proto.skip;
proto.format_link=proto.skip;
proto.format_map=proto.skip;
proto.format_marquee=proto.skip;
proto.format_meta=proto.skip;
proto.format_multicol=proto.pass;
proto.format_nobr=proto.skip;
proto.format_noembed=proto.skip;
proto.format_noframes=proto.skip;
proto.format_nolayer=proto.skip;
proto.format_noscript=proto.skip;
proto.format_nowrap=proto.skip;
proto.format_object=proto.skip;
proto.format_optgroup=proto.skip;
proto.format_option=proto.skip;
proto.format_param=proto.skip;
proto.format_select=proto.skip;
proto.format_small=proto.pass;
proto.format_spacer=proto.skip;
proto.format_style=proto.skip;
proto.format_sub=proto.pass;
proto.format_submit=proto.skip;
proto.format_sup=proto.pass;
proto.format_tbody=proto.pass;
proto.format_textarea=proto.skip;
proto.format_tfoot=proto.pass;
proto.format_thead=proto.pass;
proto.format_wiki=proto.pass;
proto.format_www=proto.skip;
proto.format_img=function(_577){
var uri=_577.getAttribute("src");
if(uri){
this.assert_space_or_newline();
this.appendOutput(uri);
}
};
proto.format_blockquote=function(_579){
var _57a=parseInt(_579.style.marginLeft);
var _57b=0;
if(_57a){
_57b+=parseInt(_57a/40);
}
if(_579.tagName.toLowerCase()=="blockquote"){
_57b+=1;
}
if(!this.indent_level){
this.first_indent_line=true;
}
this.indent_level+=_57b;
this.output=defang_last_string(this.output);
this.assert_new_line();
this.walk(_579);
this.indent_level-=_57b;
if(!this.indent_level){
this.assert_blank_line();
}else{
this.assert_new_line();
}
function defang_last_string(_57c){
function non_string(a){
return typeof (a)!="string";
}
var rev=_57c.slice().reverse();
var _57f=takeWhile(non_string,rev);
var _580=dropWhile(non_string,rev);
if(_580.length){
_580[0].replace(/^>+/,"");
}
return _57f.concat(_580).reverse();
}
};
proto.format_div=function(_581){
if(this.is_opaque(_581)){
this.handle_opaque_block(_581);
return;
}
if(this.is_indented(_581)){
this.format_blockquote(_581);
return;
}
this.walk(_581);
};
proto.format_span=function(_582){
if(this.is_opaque(_582)){
this.handle_opaque_phrase(_582);
return;
}
var _583=_582.getAttribute("style");
if(!_583){
this.pass(_582);
return;
}
if(!this.element_has_text_content(_582)&&!this.element_has_only_image_content(_582)){
return;
}
var _584=["line-through","bold","italic","underline"];
for(var i=0;i<_584.length;i++){
this.check_style_and_maybe_mark_up(_583,_584[i],1);
}
this.no_following_whitespace();
this.walk(_582);
for(var i=_584.length;i>=0;i--){
this.check_style_and_maybe_mark_up(_583,_584[i],2);
}
};
proto.element_has_text_content=function(_586){
return _586.innerHTML.replace(/<.*?>/g,"").replace(/&nbsp;/g,"").match(/\S/);
};
proto.element_has_only_image_content=function(_587){
return _587.childNodes.length==1&&_587.firstChild.nodeType==1&&_587.firstChild.tagName.toLowerCase()=="img";
};
proto.check_style_and_maybe_mark_up=function(_588,_589,_58a){
var _58b=_589;
if(_58b=="line-through"){
_58b="strike";
}
if(this.check_style_for_attribute(_588,_589)){
this.appendOutput(this.config.markupRules[_58b][_58a]);
}
};
proto.check_style_for_attribute=function(_58c,_58d){
var _58e=this.squish_style_object_into_string(_58c);
return _58e.match("\\b"+_58d+"\\b");
};
proto.squish_style_object_into_string=function(_58f){
if((_58f.constructor+"").match("String")){
return _58f;
}
var _590=[["font","weight"],["font","style"],["text","decoration"]];
var _591="";
for(var i=0;i<_590.length;i++){
var pair=_590[i];
var css=pair[0]+"-"+pair[1];
var js=pair[0]+pair[1].ucFirst();
_591+=css+": "+_58f[js]+"; ";
}
return _591;
};
proto.basic_formatter=function(_596,_597){
var _598=this.config.markupRules[_597];
var _599=_598[0];
this["handle_"+_599](_596,_598);
};
klass.make_empty_formatter=function(_59a){
return function(_59b){
this.basic_formatter(_59b,_59a);
};
};
klass.make_formatter=function(_59c){
return function(_59d){
if(this.element_has_text_content(_59d)){
this.basic_formatter(_59d,_59c);
}
};
};
proto.format_b=klass.make_formatter("bold");
proto.format_strong=proto.format_b;
proto.format_code=klass.make_formatter("code");
proto.format_kbd=proto.format_code;
proto.format_samp=proto.format_code;
proto.format_tt=proto.format_code;
proto.format_var=proto.format_code;
proto.format_i=klass.make_formatter("italic");
proto.format_em=proto.format_i;
proto.format_u=klass.make_formatter("underline");
proto.format_strike=klass.make_formatter("strike");
proto.format_del=proto.format_strike;
proto.format_s=proto.format_strike;
proto.format_hr=klass.make_empty_formatter("hr");
proto.format_h1=klass.make_formatter("h1");
proto.format_h2=klass.make_formatter("h2");
proto.format_h3=klass.make_formatter("h3");
proto.format_h4=klass.make_formatter("h4");
proto.format_h5=klass.make_formatter("h5");
proto.format_h6=klass.make_formatter("h6");
proto.format_pre=klass.make_formatter("pre");
proto.format_p=function(_59e){
if(this.is_indented(_59e)){
this.format_blockquote(_59e);
return;
}
this.assert_blank_line();
this.walk(_59e);
this.assert_blank_line();
};
proto.format_a=function(_59f){
var _5a0=Wikiwyg.htmlUnescape(_59f.innerHTML);
_5a0=_5a0.replace(/<[^>]*?>/g," ");
_5a0=_5a0.replace(/\s+/g," ");
_5a0=_5a0.replace(/^\s+/,"");
_5a0=_5a0.replace(/\s+$/,"");
var href=_59f.getAttribute("href");
if(!href){
href="";
}
this.make_wikitext_link(_5a0,href,_59f);
};
proto.format_table=function(_5a2){
this.assert_blank_line();
this.walk(_5a2);
this.assert_blank_line();
};
proto.format_tr=function(_5a3){
this.walk(_5a3);
this.appendOutput("|");
this.insert_new_line();
};
proto.format_td=function(_5a4){
this.appendOutput("| ");
this.no_following_whitespace();
this.walk(_5a4);
this.chomp();
this.appendOutput(" ");
};
proto.format_th=proto.format_td;
function takeWhile(f,a){
for(var i=0;i<a.length;++i){
if(!f(a[i])){
break;
}
}
return a.slice(0,i);
}
function dropWhile(f,a){
for(var i=0;i<a.length;++i){
if(!f(a[i])){
break;
}
}
return a.slice(i);
}
proto.previous_line=function(){
function newline(s){
return s["match"]&&s.match(/\n/);
}
function non_newline(s){
return !newline(s);
}
return this.join_output(takeWhile(non_newline,dropWhile(newline,this.output.slice().reverse())).reverse());
};
proto.make_list=function(_5ad,_5ae){
if(!this.previous_was_newline_or_start()){
this.insert_new_line();
}
this.list_type.push(_5ae);
this.walk(_5ad);
this.list_type.pop();
if(this.list_type.length==0){
this.assert_blank_line();
}
};
proto.format_ol=function(_5af){
this.make_list(_5af,"ordered");
};
proto.format_ul=function(_5b0){
this.make_list(_5b0,"unordered");
};
proto.format_li=function(_5b1){
var _5b2=this.list_type.length;
if(!_5b2){
die("Wikiwyg list error");
}
var type=this.list_type[_5b2-1];
var _5b4=this.config.markupRules[type];
this.appendOutput(_5b4[1].times(_5b2)+" ");
if(Wikiwyg.is_ie&&_5b1.firstChild&&_5b1.firstChild.nextSibling&&_5b1.firstChild.nextSibling.nodeName.match(/^[uo]l$/i)){
try{
_5b1.firstChild.nodeValue=_5b1.firstChild.nodeValue.replace(/ $/,"");
}
catch(e){
}
}
this.walk(_5b1);
this.chomp();
this.insert_new_line();
};
proto.chomp=function(){
var _5b5;
while(this.output.length){
_5b5=this.output.pop();
if(typeof (_5b5)!="string"){
this.appendOutput(_5b5);
return;
}
if(!_5b5.match(/^\n+>+ $/)&&_5b5.match(/\S/)){
break;
}
}
if(_5b5){
_5b5=_5b5.replace(/[\r\n\s]+$/,"");
this.appendOutput(_5b5);
}
};
proto.collapse=function(_5b6){
return _5b6.replace(/[ \u00a0\r\n]+/g," ");
};
proto.trim=function(_5b7){
return _5b7.replace(/^\s+/,"");
};
proto.insert_new_line=function(){
var fang="";
var _5b9=this.config.markupRules.indent[1];
var _5ba="\n";
if(this.indent_level>0){
fang=_5b9.times(this.indent_level);
if(fang.length){
fang+=" ";
}
}
if(fang.length&&this.first_indent_line){
this.first_indent_line=false;
_5ba=_5ba+_5ba;
}
if(this.output.length){
this.appendOutput(_5ba+fang);
}else{
if(fang.length){
this.appendOutput(fang);
}
}
};
proto.previous_was_newline_or_start=function(){
for(var ii=this.output.length-1;ii>=0;ii--){
var _5bc=this.output[ii];
if(typeof (_5bc)!="string"){
continue;
}
return _5bc.match(/\n$/);
}
return true;
};
proto.assert_new_line=function(){
this.chomp();
this.insert_new_line();
};
proto.assert_blank_line=function(){
if(!this.should_whitespace()){
return;
}
this.chomp();
this.insert_new_line();
this.insert_new_line();
};
proto.assert_space_or_newline=function(){
if(!this.output.length||!this.should_whitespace()){
return;
}
if(!this.previous_output().match(/(\s+|[\(])$/)){
this.appendOutput(" ");
}
};
proto.no_following_whitespace=function(){
this.appendOutput({whitespace:"stop"});
};
proto.should_whitespace=function(){
return !this.previous_output().whitespace;
};
proto.previous_output=function(_5bd){
if(!_5bd){
_5bd=1;
}
var _5be=this.output.length;
return _5be&&_5bd<=_5be?this.output[_5be-_5bd]:"";
};
proto.handle_bound_phrase=function(_5bf,_5c0){
if(!this.element_has_text_content(_5bf)){
return;
}
if(_5bf.innerHTML.match(/^\s*<br\s*\/?\s*>/)){
this.appendOutput("\n");
_5bf.innerHTML=_5bf.innerHTML.replace(/^\s*<br\s*\/?\s*>/,"");
}
this.appendOutput(_5c0[1]);
this.no_following_whitespace();
this.walk(_5bf);
this.appendOutput(_5c0[2]);
};
proto.handle_bound_line=function(_5c1,_5c2){
this.assert_blank_line();
this.appendOutput(_5c2[1]);
this.walk(_5c1);
this.appendOutput(_5c2[2]);
this.assert_blank_line();
};
proto.handle_start_line=function(_5c3,_5c4){
this.assert_blank_line();
this.appendOutput(_5c4[1]);
this.walk(_5c3);
this.assert_blank_line();
};
proto.handle_start_lines=function(_5c5,_5c6){
var text=_5c5.firstChild.nodeValue;
if(!text){
return;
}
this.assert_blank_line();
text=text.replace(/^/mg,_5c6[1]);
this.appendOutput(text);
this.assert_blank_line();
};
proto.handle_line_alone=function(_5c8,_5c9){
this.assert_blank_line();
this.appendOutput(_5c9[1]);
this.assert_blank_line();
};
proto.COMMENT_NODE_TYPE=8;
proto.get_wiki_comment=function(_5ca){
for(var node=_5ca.firstChild;node;node=node.nextSibling){
if(node.nodeType==this.COMMENT_NODE_TYPE&&node.data.match(/^\s*wiki/)){
return node;
}
}
return null;
};
proto.is_indented=function(_5cc){
var _5cd=parseInt(_5cc.style.marginLeft);
return _5cd>0;
};
proto.is_opaque=function(_5ce){
var _5cf=this.get_wiki_comment(_5ce);
if(!_5cf){
return false;
}
var text=_5cf.data;
if(text.match(/^\s*wiki:/)){
return true;
}
return false;
};
proto.handle_opaque_phrase=function(_5d1){
var _5d2=this.get_wiki_comment(_5d1);
if(_5d2){
var text=_5d2.data;
text=text.replace(/^ wiki:\s+/,"").replace(/-=/g,"-").replace(/==/g,"=").replace(/\s$/,"").replace(/\{(\w+):\s*\}/,"{$1}");
this.appendOutput(Wikiwyg.htmlUnescape(text));
this.smart_trailing_space(_5d1);
}
};
proto.smart_trailing_space=function(_5d4){
var next=_5d4.nextSibling;
if(!next){
}else{
if(next.nodeType==1){
if(next.nodeName=="BR"){
var nn=next.nextSibling;
if(!(nn&&nn.nodeType==1&&nn.nodeName=="SPAN")){
this.appendOutput("\n");
}
}else{
this.appendOutput(" ");
}
}else{
if(next.nodeType==3){
if(!next.nodeValue.match(/^\s/)){
this.no_following_whitespace();
}
}
}
}
};
proto.handle_opaque_block=function(_5d7){
var _5d8=this.get_wiki_comment(_5d7);
if(!_5d8){
return;
}
var text=_5d8.data;
text=text.replace(/^\s*wiki:\s+/,"");
this.appendOutput(text);
};
proto.make_wikitext_link=function(_5da,href,_5dc){
var _5dd=this.config.markupRules.link[1];
var _5de=this.config.markupRules.link[2];
if(this.looks_like_a_url(href)){
_5dd=this.config.markupRules.www[1];
_5de=this.config.markupRules.www[2];
}
this.assert_space_or_newline();
if(!href){
this.appendOutput(_5da);
}else{
if(href==_5da){
this.appendOutput(href);
}else{
if(this.href_is_wiki_link(href)){
if(this.camel_case_link(_5da)){
this.appendOutput(_5da);
}else{
this.appendOutput(_5dd+_5da+_5de);
}
}else{
this.appendOutput(_5dd+href+" "+_5da+_5de);
}
}
}
};
proto.camel_case_link=function(_5df){
if(!this.config.supportCamelCaseLinks){
return false;
}
return _5df.match(/[a-z][A-Z]/);
};
proto.href_is_wiki_link=function(href){
if(!this.looks_like_a_url(href)){
return true;
}
if(!href.match(/\?/)){
return false;
}
if(href.match(/\/static\/\d+\.\d+\.\d+\.\d+\//)){
href=location.href;
}
var _5e1=href.split("?")[0];
var _5e2=location.href.split("?")[0];
if(_5e2==location.href){
_5e2=location.href.replace(new RegExp(location.hash),"");
}
return _5e1==_5e2;
};
proto.looks_like_a_url=function(_5e3){
return _5e3.match(/^(http|https|ftp|irc|mailto|file):/);
};
if(Wikiwyg.is_ie){
proto.setHeightOf=function(){
this.textarea.style.height="200px";
};
proto.initializeObject=function(){
this.initialize_object();
this.area.addBehavior(this.config.javascriptLocation+"Selection.htc");
};
}
proto=new Subclass("Wikiwyg.Preview","Wikiwyg.Mode");
proto.classtype="preview";
proto.modeDescription="Preview";
proto.config={divId:null};
proto.initializeObject=function(){
if(this.config.divId){
this.div=document.getElementById(this.config.divId);
}else{
this.div=document.createElement("div");
}
this.div.style.backgroundColor="lightyellow";
};
proto.fromHtml=function(html){
this.div.innerHTML=html;
};
proto.toHtml=function(func){
func(this.div.innerHTML);
};
proto.disableStarted=function(){
this.wikiwyg.divHeight=this.div.offsetHeight;
};
function addEvent(name,func){
if(window.addEventListener){
name=name.replace(/^on/,"");
window.addEventListener(name,func,false);
}else{
if(window.attachEvent){
window.attachEvent(name,func);
}
}
}
function grepElementsByTag(tag,func){
var _5ea=document.getElementsByTagName(tag);
var list=[];
for(var i=0;i<_5ea.length;i++){
var _5ed=_5ea[i];
if(func(_5ed)){
list.push(_5ed);
}
}
return list;
}
function getStyle(oElm,_5ef){
var _5f0="";
if(document.defaultView&&document.defaultView.getComputedStyle){
_5f0=document.defaultView.getComputedStyle(oElm,"").getPropertyValue(_5ef);
}else{
if(oElm.currentStyle){
_5ef=_5ef.replace(/\-(\w)/g,function(_5f1,p1){
return p1.toUpperCase();
});
_5f0=oElm.currentStyle[_5ef];
}
}
return _5f0;
}
Cookie={};
Cookie.get=function(name){
var _5f4=document.cookie.indexOf(name+"=");
if(_5f4==-1){
return null;
}
var _5f5=document.cookie.indexOf("=",_5f4)+1;
var _5f6=document.cookie.indexOf(";",_5f5);
if(_5f6==-1){
_5f6=document.cookie.length;
}
var val=document.cookie.substring(_5f5,_5f6);
return val==null?null:unescape(document.cookie.substring(_5f5,_5f6));
};
Cookie.set=function(name,val,_5fa){
if(typeof (_5fa)=="undefined"){
_5fa=new Date(new Date().getTime()+25*365*24*60*60*1000);
}
var str=name+"="+escape(val)+"; expires="+_5fa.toGMTString();
document.cookie=str;
};
Cookie.del=function(name){
Cookie.set(name,"",new Date(new Date().getTime()-1));
};
if(typeof Wait=="undefined"){
Wait={};
}
Wait.VERSION=0.01;
Wait.EXPORT=["wait"];
Wait.EXPORT_TAGS={":all":Wait.EXPORT};
Wait.interval=100;
Wait.wait=function(arg1,arg2,arg3,arg4){
if(typeof arg1=="function"&&typeof arg2=="function"&&typeof arg3=="function"){
return Wait._wait3(arg1,arg2,arg3,arg4);
}
if(typeof arg1=="function"&&typeof arg2=="function"){
return Wait._wait2(arg1,arg2,arg3);
}
};
Wait._wait2=function(test,_602,max){
Wait._wait3(test,_602,function(){
},max);
};
Wait._wait3=function(test,_605,_606,max){
var func=function(){
var _609=Wait.interval;
var _60a=0;
var _60b;
var _60c=function(){
if(test()){
_605();
clearInterval(_60b);
}
_60a+=_609;
if(typeof max=="number"){
if(_60a>=max){
if(typeof _606=="function"){
_606();
}
clearInterval(_60b);
}
}
};
_60b=setInterval(_60c,_609);
};
func();
};
window.wait=Wait.wait;
if(!this.Ajax){
Ajax={};
}
Ajax.get=function(url,_60e){
var req=new XMLHttpRequest();
req.open("GET",url,Boolean(_60e));
return Ajax._send(req,null,_60e);
};
Ajax.post=function(url,data,_612){
var req=new XMLHttpRequest();
req.open("POST",url,Boolean(_612));
req.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
return Ajax._send(req,data,_612);
};
Ajax._send=function(req,data,_616){
if(_616){
req.onreadystatechange=function(){
if(req.readyState==4){
if(req.status==200){
_616(req.responseText);
}
}
};
}
req.send(data);
if(!_616){
if(req.status!=200){
throw ("Request for \""+url+"\" failed with status: "+req.status);
}
return req.responseText;
}
};
if(window.ActiveXObject&&!window.XMLHttpRequest){
window.XMLHttpRequest=function(){
return new ActiveXObject((navigator.userAgent.toLowerCase().indexOf("msie 5")!=-1)?"Microsoft.XMLHTTP":"Msxml2.XMLHTTP");
};
}
if(window.opera&&!window.XMLHttpRequest){
window.XMLHttpRequest=function(){
this.readyState=0;
this.status=0;
this.statusText="";
this._headers=[];
this._aborted=false;
this._async=true;
this.abort=function(){
this._aborted=true;
};
this.getAllResponseHeaders=function(){
return this.getAllResponseHeader("*");
};
this.getAllResponseHeader=function(_617){
var ret="";
for(var i=0;i<this._headers.length;i++){
if(_617=="*"||this._headers[i].h==_617){
ret+=this._headers[i].h+": "+this._headers[i].v+"\n";
}
}
return ret;
};
this.setRequestHeader=function(_61a,_61b){
this._headers[this._headers.length]={h:_61a,v:_61b};
};
this.open=function(_61c,url,_61e,user,_620){
this.method=_61c;
this.url=url;
this._async=true;
this._aborted=false;
if(arguments.length>=3){
this._async=_61e;
}
if(arguments.length>3){
opera.postError("XMLHttpRequest.open() - user/password not supported");
}
this._headers=[];
this.readyState=1;
if(this.onreadystatechange){
this.onreadystatechange();
}
};
this.send=function(data){
if(!navigator.javaEnabled()){
alert("XMLHttpRequest.send() - Java must be installed and enabled.");
return;
}
if(this._async){
setTimeout(this._sendasync,0,this,data);
}else{
this._sendsync(data);
}
};
this._sendasync=function(req,data){
if(!req._aborted){
req._sendsync(data);
}
};
this._sendsync=function(data){
this.readyState=2;
if(this.onreadystatechange){
this.onreadystatechange();
}
var url=new java.net.URL(new java.net.URL(window.location.href),this.url);
var conn=url.openConnection();
for(var i=0;i<this._headers.length;i++){
conn.setRequestProperty(this._headers[i].h,this._headers[i].v);
}
this._headers=[];
if(this.method=="POST"){
conn.setDoOutput(true);
var wr=new java.io.OutputStreamWriter(conn.getOutputStream());
wr.write(data);
wr.flush();
wr.close();
}
var _629=false;
var _62a=false;
var _62b=false;
var _62c=false;
var _62d=false;
var _62e=false;
for(var i=0;;i++){
var _62f=conn.getHeaderFieldKey(i);
var _630=conn.getHeaderField(i);
if(_62f==null&&_630==null){
break;
}
if(_62f!=null){
this._headers[this._headers.length]={h:_62f,v:_630};
switch(_62f.toLowerCase()){
case "content-encoding":
_629=true;
break;
case "content-length":
_62a=true;
break;
case "content-type":
_62b=true;
break;
case "date":
_62c=true;
break;
case "expires":
_62d=true;
break;
case "last-modified":
_62e=true;
break;
}
}
}
var val;
val=conn.getContentEncoding();
if(val!=null&&!_629){
this._headers[this._headers.length]={h:"Content-encoding",v:val};
}
val=conn.getContentLength();
if(val!=-1&&!_62a){
this._headers[this._headers.length]={h:"Content-length",v:val};
}
val=conn.getContentType();
if(val!=null&&!_62b){
this._headers[this._headers.length]={h:"Content-type",v:val};
}
val=conn.getDate();
if(val!=0&&!_62c){
this._headers[this._headers.length]={h:"Date",v:(new Date(val)).toUTCString()};
}
val=conn.getExpiration();
if(val!=0&&!_62d){
this._headers[this._headers.length]={h:"Expires",v:(new Date(val)).toUTCString()};
}
val=conn.getLastModified();
if(val!=0&&!_62e){
this._headers[this._headers.length]={h:"Last-modified",v:(new Date(val)).toUTCString()};
}
var _632="";
var _633=conn.getInputStream();
if(_633){
var _634=new java.io.BufferedReader(new java.io.InputStreamReader(_633));
var line;
while((line=_634.readLine())!=null){
if(this.readyState==2){
this.readyState=3;
if(this.onreadystatechange){
this.onreadystatechange();
}
}
_632+=line+"\n";
}
_634.close();
this.status=200;
this.statusText="OK";
this.responseText=_632;
this.readyState=4;
if(this.onreadystatechange){
this.onreadystatechange();
}
if(this.onload){
this.onload();
}
}else{
this.status=404;
this.statusText="Not Found";
this.responseText="";
this.readyState=4;
if(this.onreadystatechange){
this.onreadystatechange();
}
if(this.onerror){
this.onerror();
}
}
};
};
}
if(!window.ActiveXObject&&window.XMLHttpRequest){
window.ActiveXObject=function(type){
switch(type.toLowerCase()){
case "microsoft.xmlhttp":
case "msxml2.xmlhttp":
return new XMLHttpRequest();
}
return null;
};
}
var JSON=function(){
var m={"\b":"\\b","\t":"\\t","\n":"\\n","\f":"\\f","\r":"\\r","\"":"\\\"","\\":"\\\\"},s={"boolean":function(x){
return String(x);
},number:function(x){
return isFinite(x)?String(x):"null";
},string:function(x){
if(/["\\\x00-\x1f]/.test(x)){
x=x.replace(/([\x00-\x1f\\"])/g,function(a,b){
var c=m[b];
if(c){
return c;
}
c=b.charCodeAt();
return "\\u00"+Math.floor(c/16).toString(16)+(c%16).toString(16);
});
}
return "\""+x+"\"";
},object:function(x){
if(x){
var a=[],b,f,i,l,v;
if(x instanceof Array){
a[0]="[";
l=x.length;
for(i=0;i<l;i+=1){
v=x[i];
f=s[typeof v];
if(f){
v=f(v);
if(typeof v=="string"){
if(b){
a[a.length]=",";
}
a[a.length]=v;
b=true;
}
}
}
a[a.length]="]";
}else{
if(x instanceof Object){
a[0]="{";
for(i in x){
v=x[i];
f=s[typeof v];
if(f){
v=f(v);
if(typeof v=="string"){
if(b){
a[a.length]=",";
}
a.push(s.string(i),":",v);
b=true;
}
}
}
a[a.length]="}";
}else{
return;
}
}
return a.join("");
}
return "null";
}};
return {copyright:"(c)2005 JSON.org",license:"http://www.crockford.com/JSON/license.html",stringify:function(v){
var f=s[typeof v];
if(f){
v=f(v);
if(typeof v=="string"){
return v;
}
}
return null;
},parse:function(text){
try{
return !(/[^,:{}\[\]0-9.\-+Eaeflnr-u \n\r\t]/.test(text.replace(/"(\\.|[^"\\])*"/g,"")))&&eval("("+text+")");
}
catch(e){
return false;
}
}};
}();
proto=new Subclass("Wikiwyg.HTML","Wikiwyg.Mode");
proto.classtype="html";
proto.modeDescription="HTML";
proto.config={textareaId:null};
proto.initializeObject=function(){
this.div=document.createElement("div");
if(this.config.textareaId){
this.textarea=document.getElementById(this.config.textareaId);
}else{
this.textarea=document.createElement("textarea");
}
this.div.appendChild(this.textarea);
};
proto.enableThis=function(){
Wikiwyg.Mode.prototype.enableThis.call(this);
this.textarea.style.width="100%";
this.textarea.style.height="200px";
};
proto.fromHtml=function(html){
this.textarea.value=this.sanitize_html(html);
};
proto.toHtml=function(func){
func(this.textarea.value);
};
proto.sanitize_html=function(html){
return html;
};
proto.process_command=function(_64c){
};
function XXX(msg){
if(!confirm(msg)){
throw ("terminated...");
}
return msg;
}
function JJJ(obj){
XXX(JSON.stringify(obj));
return obj;
}
var klass=Debug=function(){
};
klass.sort_object_keys=function(o){
var a=[];
for(p in o){
a.push(p);
}
return a.sort();
};
klass.dump_keys=function(o){
var a=klass.sort_object_keys(o);
var str="";
for(p in a){
str+=a[p]+"\t";
}
XXX(str);
};
klass.dump_object_into_screen=function(o){
var a=klass.sort_object_keys(o);
var str="";
for(p in a){
var i=a[p];
try{
str+=a[p]+": "+o[i]+"\n";
}
catch(e){
}
}
document.write("<xmp>"+str+"</xmp>");
};
var tt_db=(document.compatMode&&document.compatMode!="BackCompat")?document.documentElement:document.body?document.body:null,tt_n=navigator.userAgent.toLowerCase();
var tt_op=!!(window.opera&&document.getElementById),tt_op6=tt_op&&!document.defaultView,tt_ie=tt_n.indexOf("msie")!=-1&&document.all&&tt_db&&!tt_op,tt_n4=(document.layers&&typeof document.classes!="undefined"),tt_n6=(!tt_op&&document.defaultView&&typeof document.defaultView.getComputedStyle!="undefined"),tt_w3c=!tt_ie&&!tt_n6&&!tt_op&&document.getElementById;
tt_n="";
var DEBUGGING=false;
function copy_with_classes(_658){
copy=document.createElement("span");
copy.innerHTML=_658.innerHTML;
Element.classNames(_658).each(function(_659){
Element.addClassName(copy,_659);
});
copy.hide();
_658.parentNode.insertBefore(copy,_658);
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
},title_mouseover:function(_65a){
document.getElementsByClassName(_65a).each(function(elem){
Element.addClassName(elem,"card-highlight");
Element.removeClassName(elem,"card");
});
},title_mouseout:function(_65c){
document.getElementsByClassName(_65c).each(function(elem){
Element.removeClassName(elem,"card-highlight");
Element.addClassName(elem,"card");
});
},line_to_paragraph:function(_65e){
var _65f=_65e.getDimensions();
copy=copy_with_classes(_65e);
copy.removeClassName("line");
copy.addClassName("paragraph");
var _660=copy.getDimensions();
copy.viewHeight=_660.height;
copy.remove();
var _661=100*_65f.height/_660.height;
var _662=_660;
new Effect.BlindDown(_65e,{duration:0.5,scaleFrom:_661,scaleMode:{originalHeight:_662.height,originalWidth:_662.width},afterSetup:function(_663){
_663.element.makeClipping();
_663.element.setStyle({height:"0px"});
_663.element.show();
_663.element.removeClassName("line");
_663.element.addClassName("paragraph");
}});
},paragraph_to_line:function(_664){
var _665=_664.getDimensions();
copy=copy_with_classes(_664);
copy.removeClassName("paragraph");
copy.addClassName("line");
var _666=copy.getDimensions();
copy.remove();
var _667=100*_666.height/_665.height;
return new Effect.Scale(_664,_667,{duration:0.5,scaleContent:false,scaleX:false,scaleFrom:100,scaleMode:{originalHeight:_665.height,originalWidth:_665.width},restoreAfterFinish:true,afterSetup:function(_668){
_668.element.makeClipping();
_668.element.setStyle({height:"0px"});
_668.element.show();
},afterFinishInternal:function(_669){
_669.element.undoClipping();
_669.element.removeClassName("paragraph");
_669.element.addClassName("line");
}});
}});
Wagn.highlight=function(_66a,id){
document.getElementsByClassName(_66a).each(function(elem){
Element.removeClassName(elem.id,"current");
});
Element.addClassName(_66a+"-"+id,"current");
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
getNewWindowLinks();
if(typeof (init_lister)!="undefined"){
Wagn._lister=init_lister();
Wagn._lister.update();
}
if($("main-body")){
$("main-body").card().loadEditor();
}
};
Wagn.CardSlot={init:function(_66f){
return Object.extend($(_66f),Wagn.CardSlot.prototype);
},find_all_by_class:function(_670){
if(_670=="all"){
_670="card-slot";
}
return document.getElementsByClassName(_670).collect(function(e){
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
}
Wagn.CardTable[slot.id]=this;
},loadEditor:function(){
if(this._in_wadget){
warn("bailing cuzof wadget");
return true;
}else{
if(Element.hasClassName(this.slot,"new-card")){
warn("setting up new card");
this.setupEditor();
return true;
}
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
on_complete=(edit_on_load=arguments[1])?function(_675){
self.slowEdit();
}:function(_676){
self.setupEditor();
};
url=this.id()?"/card/editor/"+this.id():"/card/new";
new Ajax.Updater(this.slot.id+"-editor",url,{parameters:this._common_parameters(),onComplete:on_complete});
this._editor_loaded=true;
},setupEditor:function(){
if(this.is_edit_ok()){
var _677="new Wagn.Editor."+this.editor_type()+"(this)";
warn(this.slot.id+": "+_677);
this.editor=eval(_677);
}else{
if(this.slot.chunk("edit")){
this.slot.chunk("edit").onClick=function(){
};
if(!Wagn.user()){
this.slot.chunk("edit").href=this.login_url;
this.slot.chunk("options").onclick=function(){
};
this.slot.chunk("options").href=this.login_url;
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
},editor_type:function(){
return this.slot.chunk("editor-type").innerHTML;
},codename:function(){
return this.slot.chunk("codename").innerHTML;
},revision_id:function(){
return this.slot.chunk("revision-id").innerHTML;
},set_revision_id:function(_679){
this.slot.chunk("revision-id").innerHTML=_679;
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
},set_blank_name_to:function(_67a){
name=$("new-card-name-field");
if(name&&$F(name)==""){
name.value=_67a;
}
},setupDoubleClickToEdit:function(){
var self=this;
Element.getElementsByClassName(this.slot,"editOnDoubleClick").each(function(el){
if(typeof (el.attributes["inPopup"])!="undefined"&&el.attributes["inPopup"].value=="true"){
el.ondblclick=function(_67d){
if(card_id=Wagn.Card.getTranscludingCardId(Event.element(_67d))){
self.editTransclusion();
Event.stop(_67d);
}
};
}else{
el.ondblclick=function(_67e){
Event.stop(_67e);
self.loadEditor(false,true);
};
}
});
},editTransclusion:function(){
var self=this;
if(Wagn.win){
Wagn.win.setLocation(30+window.scrollY,30);
}else{
Wagn.win=new Window("popup",{className:"mac_os_x",title:"Transclusion Editor",top:30+window.scrollY,left:30,width:550,height:50+self.slot.viewHeight,showEffectOptions:{duration:0.2},hideEffectOptions:{duration:0.2}});
}
$("popup_content").innerHTML="<div id=\"popup_target\"></div>";
$("popup_target").innerHTML="loading...";
Wagn.win.show();
Wagn.Card.editInPopup(card_id);
},view:function(){
this.highlight_tab("view");
this._viewmode="view";
if(this.is_edit_ok()){
this.editor.view();
this.slot.chunk("editor").hide();
}
this.slot.chunk("card-links").show();
if(discussion=this.slot.chunk("discussion")){
discussion.show();
}
this.slot.chunk("cooked").style.display="";
this.slot.removeClassName("editing");
if(this.slot.oldClass=="line"){
this.slot.oldClass=null;
Wagn.paragraph_to_line(this.slot);
}
},edit:function(){
if(!Wikiwyg.browserIsSupported){
alert("Sorry, Wagn doesn't support editing in your browser yet."+"Currently we support Internet Explorer 6 or newer and recent releases of Mozilla based browsers such as Firefox, Mozilla, and Camino");
return;
}
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
alert("Sorry, you can't edit this card-  it could be that you do not have permission, or that the card is templated");
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
},reload:function(){
new Ajax.Updater(this.slot.id+"-card","/card/view/"+this.id(),{asynchronous:false,parameters:this._common_parameters()});
warn("LOADING EDITOR");
$(this.slot.id+"-comment").value="";
new Wagn.Card(this.slot);
},cancel:function(){
this.highlight();
this.view();
if(this.editor.refresh_on_cancel()){
this.loadEditor(true);
}
this.dehighlight();
Windows.close("popup");
},save:function(){
if(this.editor.before_save&&this.editor.before_save()){
this.continueSave();
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
},after_edit:function(_680,_681,raw){
this.set_revision_id(_680);
this.setSlot("editor-message","");
this.setSlot("cooked",_681);
this.setSlot("raw",raw);
var self=this;
document.getElementsByClassName("transcludedContent").each(function(el){
if(el.attributes["cardId"].value==self.id()){
el.innerHTML=_681;
}
});
getNewWindowLinks();
this.setupDoubleClickToEdit();
},editConflict:function(_685,_686){
this.setSlot("editor-message",_686);
this.set_revision_id(_685);
},setSlot:function(_687,_688){
if(this.slot.chunk(_687)){
this.slot.chunk(_687).innerHTML=_688;
}
},rename_form:function(name){
this.update_workspace("rename_form",{"card[name]":$(this.slot.id+"-name-field").value});
},update_workspace:function(_68a){
params=this._ajax_parameters(arguments[1]);
params["method"]="get";
new Ajax.Updater(this.workspace,"/card/"+_68a+"/"+this.id(),params);
},remove:function(){
this.standard_update("remove",{});
},rollback:function(_68b){
this.standard_update("rollback",{rev:_68b});
},update:function(_68c){
this.standard_update("update",_68c);
},update_writer:function(_68d){
this.standard_update("update_writer",_68d);
},update_reader:function(_68e){
this.standard_update("update_reader",_68e);
},update_appender:function(_68f){
this.standard_update("update_appender",_68f);
},standard_update:function(_690,_691){
new Ajax.Request("/card/"+_690+"/"+this.id(),this._ajax_parameters(_691));
},update_attribute:function(_692,_693){
var self=this;
var _692=_692;
new Ajax.Request($A(["/card/attribute",this.id(),_692]).join("/"),{parameters:this._common_parameters({value:_693}),onSuccess:function(_695){
Wagn.messenger().note(self.name()+" "+_692+" updated: "+_695.responseText);
if(_692=="datatype"){
self.loadEditor(true);
}
},onFailure:function(_696){
Wagn.messenger().alert(self.name()+" "+_692+" update failed:"+_696.responseText);
}});
},update_private:function(_697){
if(_697=="edit"){
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
if(discussion=this.slot.chunk("discussion")){
discussion.hide();
}
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
},find:function(_69a){
return $(_69a).card();
},findFirstById:function(_69b){
return Wagn.Card.find_all_by_class(_69b).first();
},findByElement:function(_69c){
return $(_69c).card();
},find_all_by_class:function(){
card_id=arguments[0]?arguments[0]:"card-slot";
return Wagn.CardSlot.find_all_by_class(card_id).collect(function(s){
return s.card();
});
},init:function(_69e){
if(Wagn.CardTable[_69e]){
card=Wagn.CardTable[_69e];
return card;
}else{
slot=Wagn.CardSlot.init(_69e);
return new Wagn.Card(slot);
}
},update:function(_69f,_6a0,_6a1,raw){
Wagn.Card.find_all_by_class(_69f).each(function(card){
card.after_edit(_6a0,_6a1,raw);
});
},dehighlightAll:function(_6a4){
Wagn.Card.find_all_by_class(_6a4).each(function(card){
card.dehighlight();
});
},view:function(_6a6){
Wagn.Card.find_all_by_class(_6a6).each(function(card){
card.view();
});
},reload:function(_6a8){
Wagn.Card.find_all_by_class(_6a8).each(function(card){
card.reload();
});
},editConflict:function(_6aa,_6ab,_6ac){
Wagn.Card.find_all_by_class(_6aa).each(function(card){
card.editConflict(_6ab,_6ac);
});
},editInPopup:function(_6ae){
new Ajax.Updater("popup_target","/card/edit_form/"+_6ae,{asynchronous:true,evalScripts:true,onComplete:function(_6af){
c=new Wagn.Card(Wagn.CardSlot.init("popup_cardslot"));
Wagn.Card.find("popup_cardslot").loadEditor(false,true);
}});
},setupAll:function(){
var _6b0=arguments[0];
Wagn.CardSlot.find_all_by_class("all").each(function(s){
if(!s.chunk("wikiwyg_toolbar")){
c=new Wagn.Card(s,_6b0);
}
});
getNewWindowLinks();
},getTranscludingCardId:function(_6b2){
if(_6b2.hasAttribute("cardId")){
return _6b2.attributes["cardId"].value;
}else{
if(_6b2.parentNode){
return this.getTranscludingCardId(_6b2.parentNode);
}else{
return false;
}
}
}});
proto=new Subclass("Wagn.Wikiwyg","Wikiwyg");
Object.extend(Wagn.Wikiwyg,{wikiwyg_divs:[],default_config:{imagesLocation:"../../images/wikiwyg/",doubleClickToEdit:false,modeClasses:["Wikiwyg.Wysiwyg"],controlLayout:["selector","bold","italic","ordered","unordered","indent","outdent"],styleSelector:["label","h1","h2","p"],controlLabels:Object.extend(Wikiwyg.Toolbar.prototype.config,{spotlight:"Spotlight",highlight:"Highlight",h1:"Header",h2:"Subheader",link:"Create/Edit link"})},addEventToWindow:function(_6b3,name,func){
if(_6b3.addEventListener){
name=name.replace(/^on/,"");
_6b3.addEventListener(name,func,false);
}else{
if(_6b3.attachEvent){
_6b3.attachEvent(name,func);
}
}
},getClipboardHTML:function(){
var _6b6=document.getElementById("___WWHiddenFrame");
if(!_6b6){
_6b6=document.createElement("iframe");
_6b6.id="___WWHiddenFrame";
document.body.appendChild(_6b6);
_6b6.contentDocument.designMode="on";
}
pdoc=_6b6.contentDocument;
pdoc.innerHTML="";
pdoc.execCommand("paste",false,null);
var _6b7=pdoc.innerHTML;
pdoc.innerHTML="";
return _6b7;
}});
Object.extend(Wagn.Wikiwyg.prototype,{card:function(){
return this._card;
},saveChanges:function(){
this.card().save();
},innerSave:function(){
var self=this;
this.clean_spans();
this.current_mode.toHtml(function(html){
self.fromHtml(html);
});
if(arguments[0]=="draft"){
return this.div.innerHTML;
}else{
this.card().content(this.div.innerHTML);
}
},cancelEdit:function(){
this.card().cancel();
},clean_spans:function(){
dom=this.current_mode.get_edit_document();
$A(dom.getElementsByTagName("span")).reverse().each(function(elem){
warn("  SPAN "+elem);
var _6bb=(elem.style["fontWeight"]=="bold");
var em=(elem.style["fontStyle"]=="italic");
if(em||_6bb){
var _6bd="";
if(em&&_6bb){
_6bd=Wikiwyg.createElementWithAttrs("strong",{});
_6bd.innerHTML="<em>"+elem.innerHTML+"</em>";
}else{
_6bd=Wikiwyg.createElementWithAttrs((em?"em":"strong"),{});
_6bd.innerHTML=elem.innerHTML;
}
elem.parentNode.replaceChild(_6bd,elem);
}
});
},do_link:function(){
alert("creating link");
var _6be=this.get_link_selection_text();
if(!_6be){
return;
}
var url;
var _6c0=_6be.match(/(.*?)\b((?:http|https|ftp|irc|file):\/\/\S+)(.*)/);
if(_6c0){
if(_6c0[1]||_6c0[3]){
return null;
}
url=_6c0[2];
}else{
url=escape(_6be);
}
this.exec_command("createlink",url);
},displayMode:function(){
for(var i=0;i<this.config.modeClasses.length;i++){
var _6c2=this.config.modeClasses[i];
var _6c3=this.modeByName(_6c2);
_6c3.disableThis();
}
this.toolbarObject.disableThis();
this.div.style.display="";
this.divHeight=this.div.offsetHeight;
},initial_config:function(){
return {imagesLocation:"../../images/wikiwyg/",doubleClickToEdit:false,modeClasses:["Wikiwyg.HTML"],controlLayout:["selector","bold","italic","ordered","unordered","indent","outdent"],styleSelector:["label","h1","h2","p"],controlLabels:Object.extend(Wikiwyg.Toolbar.prototype.config,{spotlight:"Spotlight",highlight:"Highlight",h1:"Header",h2:"Subheader"})};
},setup:function(slot){
var _6c5=new Wagn.Wikiwyg();
var conf=this.initial_config();
if(!conf.wysiwyg){
conf.wysiwyg={};
}
conf.wysiwyg.iframeId="iframe-"+slot.id;
_6c5.createWikiwygArea(slot.chunk("raw"),conf);
Wagn.Wikiwyg.wikiwyg_divs.push(_6c5);
slot.chunk("cooked").ondblclick=function(){
slot.card().edit();
};
return _6c5;
}});
Object.extend(Wikiwyg.Wysiwyg.prototype,{get_selection:function(){
return this.edit_iframe.contentWindow.getSelection();
},superEnableThis:Wikiwyg.Wysiwyg.prototype.enableThis,enableThis:function(){
this.superEnableThis();
},do_link:function(){
l=new Wagn.LinkEditor(this);
l.edit();
return;
},do_bold:function(){
this.exec_command("bold");
},do_italic:function(){
this.exec_command("italic");
},do_spotlight:function(){
if(!Wikiwyg.is_ie){
this.exec_command("styleWithCSS",false);
}
this.exec_command("bold");
if(!Wikiwyg.is_ie){
this.exec_command("styleWithCSS",true);
}
},do_highlight:function(){
if(!Wikiwyg.is_ie){
this.exec_command("styleWithCSS",false);
}
this.exec_command("italic");
if(!Wikiwyg.is_ie){
this.exec_command("styleWithCSS",true);
}
},do_indent:function(){
if(!Wikiwyg.is_ie){
this.exec_command("styleWithCSS",false);
}
this.exec_command("indent");
if(!Wikiwyg.is_ie){
this.exec_command("styleWithCSS",true);
}
},do_outdent:function(){
if(!Wikiwyg.is_ie){
this.exec_command("styleWithCSS",false);
}
this.exec_command("outdent");
if(!Wikiwyg.is_ie){
this.exec_command("styleWithCSS",true);
}
},do_norm:function(){
this.exec_command("removeformat");
},fromHtml:function(html){
var dom=document.createElement("div");
dom.innerHTML=html;
this.sanitize_dom(dom);
this.set_inner_html(dom.innerHTML);
},pasteWithFilter:function(){
html=Wagn.Wikiwyg.getClipboardHTML();
},createKeyPressHandler:function(){
var self=this;
return function(e){
var _6cb=false;
if(e.ctrlKey&&!e.shiftKey&&!e.altKey){
switch(e.which){
case 86:
case 118:
_6cb=true;
self.pasteWithFilter();
break;
}
}
if(_6cb){
e.preventDefault();
e.stopPropagation();
}
};
}});
Wikiwyg.Wysiwyg.prototype.config["editHeightAdjustment"]=1.1;
Object.extend(Wikiwyg.Mode.prototype,{get_edit_height:function(){
var _6cc=this.wikiwyg.divHeight;
if(_6cc=="0"){
_6cc=this.wikiwyg.div.parentNode.parentNode.parentNode.viewHeight-40;
}
var _6cd=parseInt(_6cc*this.config.editHeightAdjustment);
var min=this.config.editHeightMinimum;
h=_6cd<min?min:_6cd;
max=window.innerHeight-100;
h=h>max?max:h;
return h;
}});
rich_text_wikiwyg=new Subclass("Wagn.RichTextWikiwyg","Wagn.Wikiwyg");
Object.extend(Wagn.RichTextWikiwyg.prototype,{initial_config:function(){
var conf={imagesLocation:"../../images/wikiwyg/",doubleClickToEdit:false,modeClasses:["Wikiwyg.Wysiwyg"],controlLayout:["selector","bold","italic","ordered","unordered","indent","outdent"],styleSelector:["label","h1","h2","p"],controlLabels:Object.extend(Wikiwyg.Toolbar.prototype.config,{spotlight:"Spotlight",highlight:"Highlight",h1:"Header",h2:"Subheader"})};
if(!Wikiwyg.is_ie){
conf.controlLayout.push("link");
}
if($("edit_html").innerHTML.match(/true/)){
conf.modeClasses.push("Wikiwyg.HTML");
conf.controlLayout.push("mode_selector");
}
return conf;
}});
Wagn.Editor=Class.create();
Wagn.Editor.prototype={initialize:function(card){
this.card=card;
this.slot=card.slot;
this.setup();
},context:function(){
return this.slot.chunk("editor_context").innerHTML;
},setup:function(){
},view:function(){
alert("no setup function for this class");
},edit:function(){
alert("no setup function for this class");
},cancel:function(){
this.view();
},before_save:function(){
},save_new:function(form){
},refresh_on_cancel:function(){
return false;
}};
Wagn.Lister=Class.create();
Object.extend(Wagn.Lister.prototype,{initialize:function(_6d2,args){
per_card=true;
this._arguments=$H(args);
this.user_id=this.make_accessor("user_id");
this.page=this.make_accessor("page");
this.cardtype=this.make_accessor("cardtype",{reset_paging:true});
this.keyword=this.make_accessor("keyword",{reset_paging:true});
this.sort_by=this.make_accessor("sort_by",{reset_paging:true});
this.sortdir=this.make_accessor("sortdir",{reset_paging:true});
this.hide_duplicates=this.make_cookie_accessor("hide_duplicates","");
this.pagesize=this.make_cookie_accessor("pagesize","25");
this.div_id=_6d2;
Object.extend(this._arguments,{query:this.query(),pagesize:this.pagesize(),cardtype:this.cardtype(),keyword:this.keyword(),sort_by:this.sort_by(),sortdir:this.sortdir()});
Wagn.highlight("sortdir",this.sortdir());
Wagn.highlight("sort_by",this.sort_by());
Wagn.highlight("pagesize",this.pagesize());
Wagn.highlight("hide_duplicates",this.hide_duplicates());
},open_all:function(){
this._cards().each(function(card){
card.to_paragraph();
});
},close_all:function(){
this._cards().each(function(card){
card.to_line();
});
},cards_per_page:function(){
if(arguments[0]){
Cookie.set("cards_per_page");
}
return Cookie.get("cards_per_page");
},_cards:function(){
return this._card_slots().collect(function(slot){
return slot.card();
});
},_card_slots:function(){
return document.getElementsByClassName("card-slot",$(this.div_id));
},card_id:function(){
if($("main-body")){
return $("main-body").card().id();
}else{
return "";
}
},display_type:function(){
if(arguments[0]!=null){
this._display_type=arguments[0];
}
return (this._display_type?this._display_type:"connection_list");
},query:function(){
field="query";
if(arguments[0]!=null){
this.page("1");
this._arguments[field]=arguments[0];
return this;
}else{
if(this._arguments.keys().include(field)){
return this._arguments[field];
}else{
return null;
}
}
},make_cookie_accessor:function(_6d7,_6d8){
var self=this;
var _6da=arguments[1]?this.card_id():"";
var _6d8=_6d8;
return function(){
if(arguments[0]!=null){
Cookie.set(_6da+_6d7,arguments[0]);
self._arguments[_6d7]=arguments[0];
return self;
}else{
if(self._arguments.keys().include(_6d7)){
return self._arguments[_6d7];
}else{
if(val=Cookie.get(_6da+_6d7)){
return val;
}else{
return _6d8;
}
}
}
};
},make_accessor:function(_6db){
options=Object.extend($H({reset_paging:false}),arguments[1]);
var self=this;
var _6dd=options["reset_paging"];
return function(){
if(arguments[0]!=null){
self._arguments[_6db]=arguments[0];
if(_6dd){
self.page("1");
}
return self;
}else{
return self._arguments[_6db];
}
};
},update:function(){
this.set_button();
$("paging-links-copy").innerHTML="<img src=\"/images/wait.gif\">";
$(this.div_id).innerHTML="";
card_part=(this.card_id()=="")?"":"/"+this.card_id();
new Ajax.Updater(this.div_id,"/block/"+this.display_type()+card_part+".html",this._ajax_parameters(this._arguments));
},new_connection:function(){
new Ajax.Updater("connections-workspace","/connection/new/"+this.card_id()+"?query=plussed_cards");
},set_button:function(){
if(!($("related-button"))){
return false;
}
button="&nbsp;";
query=this.query();
if($("edit_cards").innerHTML=="true"){
if((query=="plus_cards")||(query=="plussed_cards")){
button="<input type=\"button\" id=\"new-connection-button\" value=\"join it to another card\" onClick=\"Wagn.lister().new_connection ()\">";
}else{
if(query=="cardtype_cards"){
cardtype=$("main-body").card().codename();
button="<input type=\"button\" value=\"create new one\" onClick=\"document.location.href='/card/new?card[type]="+cardtype+"'\">";
}
}
}
$("related-button").innerHTML=button;
},after_update:function(){
Wagn.Card.setupAll();
$("paging-links-copy").innerHTML=$("paging-links").innerHTML;
},_ajax_parameters:function(){
param_hash=arguments[0]?arguments[0]:{};
param_list=$A([]);
$H(param_hash).each(function(pair){
if(pair.value&&pair.value!=""){
param_list.push(pair.key+"="+encodeURIComponent(pair.value));
}
});
return {asynchronous:false,evalScripts:true,method:"get",onComplete:function(_6df){
Wagn.lister().after_update();
},parameters:param_list.join("&")};
}});
Wagn.Link=Class.create();
Object.extend(Wagn.Link,{new_from_link:function(link){
return Object.extend(link,{is_bound:function(){
return this.attributes["bound"]&&this.attributes["bound"].value=="true";
},links_to:function(){
return this.attributes["href"].value;
},reads_as:function(){
return this.innerHTML;
},update_bound:function(){
if(this.is_bound()){
this.attributes["href"].value=this.reads_as().linkify();
}
}});
},new_from_text:function(text){
link=Builder.node("a",{bound:true,href:text.linkify()},[text]);
return this.new_from_link(link);
}});
Object.extend(String.prototype,{linkify:function(){
return this.gsub(/\s/,"_").gsub(/\%20/,"_");
},unlinkify:function(){
return this.gsub(/_/," ").gsub(/\/wiki\//,"");
}});
Wagn.LinkEditor=Class.create();
Object.extend(Wagn.LinkEditor,{before_edit:function(_6e2){
card=_6e2.card;
generate_anchor=function(_6e3){
reads_as=_6e3[1];
links_to=(_6e3[2]?_6e3[2]:reads_as).linkify();
bound=reads_as.linkify()==links_to?true:false;
t="<a bound=\"#{bound}\" href=\"#{links_to}\">#{reads_as}</a>";
return new Template(t).evaluate({bound:bound,reads_as:reads_as,links_to:links_to});
};
card.raw(card.raw().gsub(/\[\[([^\]]+)\]\]/,generate_anchor));
card.raw(card.raw().gsub(/\[([^\]]+)\]\[([^\]]+)\]/,generate_anchor));
},before_save:function(_6e4){
$A(_6e4.card.slot.chunk("raw").getElementsByTagName("a")).each(function(e){
if(e.attributes["href"]){
Wagn.Link.new_from_link(e).update_bound();
if(e.innerHTML==""){
Element.replace(e,"");
}else{
Element.replace(e,"["+e.innerHTML+"]["+e.attributes["href"].value+"]");
}
}
});
return false;
}});
Object.extend(Wagn.LinkEditor.prototype,{initialize:function(_6e6){
this.wysiwyg=_6e6;
this.selection=this.get_selection();
Wagn.linkEditor=this;
},get_selection:function(){
if(Wikiwyg.is_ie){
return this.wysiwyg.get_edit_document().selection;
}else{
return this.wysiwyg.get_edit_window().getSelection();
}
},get_selection_text:function(){
return this.get_selection().toString();
},get_selection_ancestor:function(){
return this.get_selection().getRangeAt(0).commonAncestorContainer;
},edit:function(){
node=this.get_selection_ancestor();
if(link=this.inside_link_node(node)){
this.link=Wagn.Link.new_from_link(link);
this.new_link=false;
}else{
if(this.node_contains_link(node)){
alert("Oops, can't link this text because there's a link inside it");
return false;
}else{
this.link=Wagn.Link.new_from_text(this.get_selection_text());
this.new_link=true;
}
}
this.open_popup();
},inside_link_node:function(node){
if(node&&node.tagName=="A"){
return node;
}else{
if(node.parentNode){
return this.inside_link_node(node.parentNode);
}else{
return false;
}
}
},node_contains_link:function(node){
if(node.getElementsByTagName&&$A(node.getElementsByTagName("a")).length>0){
return true;
}else{
return false;
}
},replace_selection_with:function(node){
r=this.get_selection().getRangeAt(0);
r.deleteContents();
r.insertNode(node);
},save:function(_6ea,_6eb){
if(_6ea.linkify()==_6eb.linkify()){
this.link.setAttribute("bound",true);
}else{
this.link.setAttribute("bound",false);
}
this.link.attributes["href"].value=_6eb.linkify();
this.link.innerHTML=_6ea;
if(this.new_link){
this.replace_selection_with(link);
}
Windows.close("linkwin");
},unlink:function(_6ec){
if(!this.new_link){
Element.replace(this.link,_6ec);
}
Windows.close("linkwin");
},cancel:function(){
Windows.close("linkwin");
},update_bounded:function(){
if(this.link.is_bound()){
}
},open_popup:function(){
if(Wagn.linkwin){
Wagn.linkwin.setLocation(30+window.scrollY,30);
}else{
Wagn.linkwin=new Window("linkwin",{className:"mac_os_x",title:"Link Editor",top:30+window.scrollY,left:30,width:550,height:108,showEffectOptions:{duration:0.2},hideEffectOptions:{duration:0.2}});
}
$("linkwin_content").innerHTML="<div id=\"link-editor\">"+"<div><label>reads&nbsp;as:&nbsp;</label><input type=\"text\" size=\"30\" id=\"reads_as\" /></div>"+"<div><label>links&nbsp;to:&nbsp;</label><input type=\"text\" size=\"45\" id=\"links_to\" /></div>"+"<div class=\"buttons\">"+"<input type=\"button\" onclick=\"Wagn.linkEditor.save($F('reads_as'), $F('links_to'))\" value=\"Save\"/>"+"<input type=\"button\" onclick=\"Wagn.linkEditor.unlink($F('reads_as'))\" value=\"Delete Link\"/>"+"<input type=\"button\" onclick=\"Wagn.linkEditor.cancel()\" value=\"Cancel\"/>"+"</div></div>";
Wagn.Link.new_from_link(this.link).update_bound();
$("reads_as").value=this.link.reads_as();
$("links_to").value=this.link.links_to().unlinkify();
Wagn.linkwin.show();
}});
Wagn.Editor.Date=Class.create();
Object.extend(Wagn.Editor.Date.prototype,Wagn.Editor.prototype);
Object.extend(Wagn.Editor.Date.prototype,{setup:function(){
},view:function(){
},edit:function(){
element=$(this.slot.id+"-content-field");
element.innerHTML=this.card.content()||Form.Element.getValue(this.slot.id+"-date-default");
setTimeout("scwShow(scwID(\""+element.id+"\"),scwID(\""+element.id+"\"))",100);
},before_save:function(){
this.card.content($(this.slot.id+"-content-field").innerHTML);
return true;
}});
Wagn.Editor.PlainText=Class.create();
Object.extend(Wagn.Editor.PlainText.prototype,Wagn.Editor.prototype);
Object.extend(Wagn.Editor.PlainText.prototype,{setup:function(){
},view:function(){
},edit:function(){
$(this.slot.id+"-content-field").value=this.card.content();
},before_save:function(){
this.card.content($(this.slot.id+"-content-field").value);
return true;
}});
Wagn.Editor.Query=Class.create();
Object.extend(Wagn.Editor.Query.prototype,Wagn.Editor.prototype);
Object.extend(Wagn.Editor.Query.prototype,{setup:function(){
},view:function(){
},edit:function(){
return true;
},before_save:function(){
this.card.content(Form.serialize($(this.slot.id+"-query-form")));
return true;
},refresh_on_cancel:function(){
return true;
}});
Wagn.Editor.RichText=Class.create();
Object.extend(Wagn.Editor.RichText.prototype,Wagn.Editor.prototype);
Object.extend(Wagn.Editor.RichText.prototype,{setup:function(){
warn("setting up Wikiwyg");
this.wikiwyg=new Wagn.RichTextWikiwyg().setup(this.slot);
warn("wikiwyg:"+this.wikiwyg);
this.wikiwyg._card=this.card;
this._autosave_interval=20*1000;
},view:function(){
this.wikiwyg.displayMode();
this.stop_timer();
},edit:function(){
if(!Wikiwyg.is_ie){
Wagn.LinkEditor.before_edit(this);
}
this.wikiwyg.editMode();
this.start_timer();
},get_draft:function(){
return this.wikiwyg.innerSave("draft");
},before_save:function(){
this.wikiwyg.innerSave();
if(!Wikiwyg.is_ie){
Wagn.LinkEditor.before_save(this);
}
warn("content: "+this.card.content());
return true;
},start_timer:function(){
this._interval=0;
this._timer_running=true;
setTimeout("$('"+this.slot.id+"').card().editor.run_timer();",this._autosave_interval);
},stop_timer:function(){
this._timer_running=false;
},run_timer:function(){
if(this._timer_running){
this.on_interval();
setTimeout("$('"+this.slot.id+"').card().editor.run_timer();",this._autosave_interval);
}
},on_interval:function(){
this._interval+=1;
this.card.save_draft();
}});
Wagn.Editor.RoleSelect=Class.create();
Object.extend(Wagn.Editor.RoleSelect.prototype,Wagn.Editor.prototype);
Object.extend(Wagn.Editor.RoleSelect.prototype,{setup:function(){
},view:function(){
},edit:function(){
this.set_values(this.card.content());
},before_save:function(){
this.card.content(Form.Element.getValue(this.select_box()).join(","));
return true;
},select_box:function(){
return $(this.slot.id+"-role-select");
},set_values:function(_6ed){
values=_6ed.split(",");
element=this.select_box();
for(var i=0;i<element.length;i++){
var opt=element.options[i];
if(values.include(opt.value)){
opt.selected=true;
}else{
opt.selected=false;
}
}
}});
Wagn.Editor.Upload=Class.create();
Object.extend(Wagn.Editor.Upload.prototype,Wagn.Editor.prototype);
Object.extend(Wagn.Editor.Upload.prototype,{setup:function(){
},view:function(){
},edit:function(){
},before_save:function(){
$(this.slot.id+"-card-name").value=this.card.name();
$(this.slot.id+"-upload-form").submit();
return false;
}});
Wagn.Editor.User=Class.create();
Object.extend(Wagn.Editor.User.prototype,Wagn.Editor.RichText.prototype);
Object.extend(Wagn.Editor.User.prototype,{edit:function(){
if(!Wikiwyg.is_ie){
Wagn.LinkEditor.before_edit(this);
}
if(this.context()!="invitation"){
this.wikiwyg.editMode();
this.start_timer();
}
},before_save:function(){
if(this.context()!="invitation"){
this.wikiwyg.innerSave();
if(!Wikiwyg.is_ie){
Wagn.LinkEditor.before_save(this);
}
}
if(this.context()=="new"||this.context()=="invitation"){
$("user-card-name-field").value=$("new-card-name-field").value;
warn("user card name: "+$("user-card-name-field").value);
}
$(this.slot.id+"-user-update-form").onsubmit();
return false;
}});

