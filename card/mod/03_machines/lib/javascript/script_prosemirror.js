!function(e){function r(e,r,o){return 4===arguments.length?t.apply(this,arguments):void n(e,{declarative:!0,deps:r,declare:o})}function t(e,r,t,o){n(e,{declarative:!1,deps:r,executingRequire:t,execute:o})}function n(e,r){r.name=e,e in g||(g[e]=r),r.normalizedDeps=r.deps}function o(e,r){if(r[e.groupIndex]=r[e.groupIndex]||[],-1==m.call(r[e.groupIndex],e)){r[e.groupIndex].push(e);for(var t=0,n=e.normalizedDeps.length;n>t;t++){var a=e.normalizedDeps[t],u=g[a];if(u&&!u.evaluated){var d=e.groupIndex+(u.declarative!=e.declarative);if(void 0===u.groupIndex||u.groupIndex<d){if(void 0!==u.groupIndex&&(r[u.groupIndex].splice(m.call(r[u.groupIndex],u),1),0==r[u.groupIndex].length))throw new TypeError("Mixed dependency cycle detected");u.groupIndex=d}o(u,r)}}}}function a(e){var r=g[e];r.groupIndex=0;var t=[];o(r,t);for(var n=!!r.declarative==t.length%2,a=t.length-1;a>=0;a--){for(var u=t[a],i=0;i<u.length;i++){var s=u[i];n?d(s):l(s)}n=!n}}function u(e){return D[e]||(D[e]={name:e,dependencies:[],exports:{},importers:[]})}function d(r){if(!r.module){var t=r.module=u(r.name),n=r.module.exports,o=r.declare.call(e,function(e,r){if(t.locked=!0,"object"==typeof e)for(var o in e)n[o]=e[o];else n[e]=r;for(var a=0,u=t.importers.length;u>a;a++){var d=t.importers[a];if(!d.locked)for(var i=0;i<d.dependencies.length;++i)d.dependencies[i]===t&&d.setters[i](n)}return t.locked=!1,r},r.name);t.setters=o.setters,t.execute=o.execute;for(var a=0,i=r.normalizedDeps.length;i>a;a++){var l,s=r.normalizedDeps[a],c=g[s],f=D[s];f?l=f.exports:c&&!c.declarative?l=c.esModule:c?(d(c),f=c.module,l=f.exports):l=v(s),f&&f.importers?(f.importers.push(t),t.dependencies.push(f)):t.dependencies.push(null),t.setters[a]&&t.setters[a](l)}}}function i(e){var r,t=g[e];if(t)t.declarative?p(e,[]):t.evaluated||l(t),r=t.module.exports;else if(r=v(e),!r)throw new Error("Unable to load dependency "+e+".");return(!t||t.declarative)&&r&&r.__useDefault?r["default"]:r}function l(r){if(!r.module){var t={},n=r.module={exports:t,id:r.name};if(!r.executingRequire)for(var o=0,a=r.normalizedDeps.length;a>o;o++){var u=r.normalizedDeps[o],d=g[u];d&&l(d)}r.evaluated=!0;var c=r.execute.call(e,function(e){for(var t=0,n=r.deps.length;n>t;t++)if(r.deps[t]==e)return i(r.normalizedDeps[t]);throw new TypeError("Module "+e+" not declared as a dependency.")},t,n);c&&(n.exports=c),t=n.exports,t&&t.__esModule?r.esModule=t:r.esModule=s(t)}}function s(e){var r={};if("object"==typeof e||"function"==typeof e){var t=e&&e.hasOwnProperty;if(h)for(var n in e)f(r,e,n)||c(r,e,n,t);else for(var n in e)c(r,e,n,t)}return r["default"]=e,y(r,"__useDefault",{value:!0}),r}function c(e,r,t,n){(!n||r.hasOwnProperty(t))&&(e[t]=r[t])}function f(e,r,t){try{var n;return(n=Object.getOwnPropertyDescriptor(r,t))&&y(e,t,n),!0}catch(o){return!1}}function p(r,t){var n=g[r];if(n&&!n.evaluated&&n.declarative){t.push(r);for(var o=0,a=n.normalizedDeps.length;a>o;o++){var u=n.normalizedDeps[o];-1==m.call(t,u)&&(g[u]?p(u,t):v(u))}n.evaluated||(n.evaluated=!0,n.module.execute.call(e))}}function v(e){if(I[e])return I[e];if("@node/"==e.substr(0,6))return _(e.substr(6));var r=g[e];if(!r)throw"Module "+e+" not present.";return a(e),p(e,[]),g[e]=void 0,r.declarative&&y(r.module.exports,"__esModule",{value:!0}),I[e]=r.declarative?r.module.exports:r.esModule}var g={},m=Array.prototype.indexOf||function(e){for(var r=0,t=this.length;t>r;r++)if(this[r]===e)return r;return-1},h=!0;try{Object.getOwnPropertyDescriptor({a:0},"a")}catch(x){h=!1}var y;!function(){try{Object.defineProperty({},"a",{})&&(y=Object.defineProperty)}catch(e){y=function(e,r,t){try{e[r]=t.value||t.get.call(e)}catch(n){}}}}();var D={},_="undefined"!=typeof System&&System._nodeRequire||"undefined"!=typeof require&&require.resolve&&"undefined"!=typeof process&&require,I={"@empty":{}};return function(e,n,o){return function(a){a(function(a){for(var u={_nodeRequire:_,register:r,registerDynamic:t,get:v,set:function(e,r){I[e]=r},newModule:function(e){return e}},d=0;d<n.length;d++)(function(e,r){r&&r.__esModule?I[e]=r:I[e]=s(r)})(n[d],arguments[d]);o(u);var i=v(e[0]);if(e.length>1)for(var d=1;d<e.length;d++)v(e[d]);return i.__useDefault?i["default"]:i})}}}("undefined"!=typeof self?self:global)

(["1"], [], function($__System) {
    var require = this.require, exports = this.exports, module = this.module;
    $__System.registerDynamic("2", ["3"], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        module.exports = $__require('3');
        return module.exports;
    });

    $__System.registerDynamic("4", ["3"], true, function($__require, exports, module) {
        "use strict";
        ;
        var define,
            global = this,
            GLOBAL = this;
        Object.defineProperty(exports, "__esModule", {value: true});
        exports.InputRule = undefined;
        var _createClass = function() {
            function defineProperties(target, props) {
                for (var i = 0; i < props.length; i++) {
                    var descriptor = props[i];
                    descriptor.enumerable = descriptor.enumerable || false;
                    descriptor.configurable = true;
                    if ("value" in descriptor)
                        descriptor.writable = true;
                    Object.defineProperty(target, descriptor.key, descriptor);
                }
            }
            return function(Constructor, protoProps, staticProps) {
                if (protoProps)
                    defineProperties(Constructor.prototype, protoProps);
                if (staticProps)
                    defineProperties(Constructor, staticProps);
                return Constructor;
            };
        }();
        exports.addInputRule = addInputRule;
        exports.removeInputRule = removeInputRule;
        var _edit = $__require('3');
        function _classCallCheck(instance, Constructor) {
            if (!(instance instanceof Constructor)) {
                throw new TypeError("Cannot call a class as a function");
            }
        }
        function addInputRule(pm, rule) {
            if (!pm.mod.interpretInput)
                pm.mod.interpretInput = new InputRules(pm);
            pm.mod.interpretInput.addRule(rule);
        }
        function removeInputRule(pm, rule) {
            var ii = pm.mod.interpretInput;
            if (!ii)
                return;
            ii.removeRule(rule);
            if (ii.rules.length == 0) {
                ii.unregister();
                pm.mod.interpretInput = null;
            }
        }
        var InputRule = exports.InputRule = function InputRule(match, filter, handler) {
            _classCallCheck(this, InputRule);
            this.filter = filter;
            this.match = match;
            this.handler = handler;
        };
        var InputRules = function() {
            function InputRules(pm) {
                var _this = this;
                _classCallCheck(this, InputRules);
                this.pm = pm;
                this.rules = [];
                this.cancelVersion = null;
                pm.on("selectionChange", this.onSelChange = function() {
                    return _this.cancelVersion = null;
                });
                pm.on("textInput", this.onTextInput = this.onTextInput.bind(this));
                pm.addKeymap(new _edit.Keymap({Backspace: function Backspace(pm) {
                    return _this.backspace(pm);
                }}, {name: "inputRules"}), 20);
            }
            _createClass(InputRules, [{
                key: "unregister",
                value: function unregister() {
                    this.pm.off("selectionChange", this.onSelChange);
                    this.pm.off("textInput", this.onTextInput);
                    this.pm.removeKeymap("inputRules");
                }
            }, {
                key: "addRule",
                value: function addRule(rule) {
                    this.rules.push(rule);
                }
            }, {
                key: "removeRule",
                value: function removeRule(rule) {
                    var found = this.rules.indexOf(rule);
                    if (found > -1) {
                        this.rules.splice(found, 1);
                        return true;
                    }
                }
            }, {
                key: "onTextInput",
                value: function onTextInput(text) {
                    var pos = this.pm.selection.head;
                    if (!pos)
                        return;
                    var textBefore = undefined,
                        isCode = undefined,
                        $pos = undefined;
                    var lastCh = text[text.length - 1];
                    for (var i = 0; i < this.rules.length; i++) {
                        var rule = this.rules[i],
                            match = undefined;
                        if (rule.filter && rule.filter != lastCh)
                            continue;
                        if (!$pos) {
                            $pos = this.pm.doc.resolve(pos);
                            var _getContext = getContext($pos);
                            textBefore = _getContext.textBefore;
                            isCode = _getContext.isCode;
                            if (isCode)
                                return;
                        }
                        if (match = rule.match.exec(textBefore)) {
                            var startVersion = this.pm.history.getVersion();
                            if (typeof rule.handler == "string") {
                                var start = pos - (match[1] || match[0]).length;
                                var marks = this.pm.doc.marksAt(pos);
                                this.pm.tr.delete(start, pos).insert(start, this.pm.schema.text(rule.handler, marks)).apply();
                            } else {
                                rule.handler(this.pm, match, pos);
                            }
                            this.cancelVersion = startVersion;
                            return;
                        }
                    }
                }
            }, {
                key: "backspace",
                value: function backspace() {
                    if (this.cancelVersion) {
                        this.pm.history.backToVersion(this.cancelVersion);
                        this.cancelVersion = null;
                    } else {
                        return false;
                    }
                }
            }]);
            return InputRules;
        }();
        function getContext($pos) {
            var parent = $pos.parent,
                isCode = parent.type.isCode;
            var textBefore = "";
            for (var i = 0,
                     rem = $pos.parentOffset; rem > 0; i++) {
                var child = parent.child(i);
                if (child.isText)
                    textBefore += child.text.slice(0, rem);
                else
                    textBefore += "￼";
                rem -= child.nodeSize;
                if (rem <= 0 && child.marks.some(function(st) {
                        return st.type.isCode;
                    }))
                    isCode = true;
            }
            return {
                textBefore: textBefore,
                isCode: isCode
            };
        }
        return module.exports;
    });

    $__System.registerDynamic("5", ["6", "3", "4"], true, function($__require, exports, module) {
        "use strict";
        ;
        var define,
            global = this,
            GLOBAL = this;
        Object.defineProperty(exports, "__esModule", {value: true});
        exports.autoInputRules = undefined;
        var _model = $__require('6');
        var _edit = $__require('3');
        var _inputrules = $__require('4');
        var autoInputRules = exports.autoInputRules = Object.create(null);
        (0, _edit.defineOption)("autoInput", false, function(pm, val) {
            if (pm.mod.autoInput) {
                pm.mod.autoInput.forEach(function(rule) {
                    return (0, _inputrules.removeInputRule)(pm, rule);
                });
                pm.mod.autoInput = null;
            }
            if (val) {
                (function() {
                    if (val === true)
                        val = ["schema", autoInputRules];
                    var rules = Object.create(null),
                        list = pm.mod.autoInput = [];
                    val.forEach(function(spec) {
                        if (spec === "schema") {
                            pm.schema.registry("autoInput", function(name, rule, type, typeName) {
                                var rname = typeName + ":" + name,
                                    handler = rule.handler;
                                if (handler.bind)
                                    handler = handler.bind(type);
                                rules[rname] = new _inputrules.InputRule(rule.match, rule.filter, handler);
                            });
                        } else {
                            for (var name in spec) {
                                var _val = spec[name];
                                if (_val == null)
                                    delete rules[name];
                                else
                                    rules[name] = _val;
                            }
                        }
                    });
                    for (var name in rules) {
                        (0, _inputrules.addInputRule)(pm, rules[name]);
                        list.push(rules[name]);
                    }
                })();
            }
        });
        autoInputRules.emDash = new _inputrules.InputRule(/--$/, "-", "—");
        autoInputRules.openDoubleQuote = new _inputrules.InputRule(/(?:^|[\s\{\[\(\<'"\u2018\u201C])(")$/, '"', "“");
        autoInputRules.closeDoubleQuote = new _inputrules.InputRule(/"$/, '"', "”");
        autoInputRules.openSingleQuote = new _inputrules.InputRule(/(?:^|[\s\{\[\(\<'"\u2018\u201C])(')$/, "'", "‘");
        autoInputRules.closeSingleQuote = new _inputrules.InputRule(/'$/, "'", "’");
        _model.BlockQuote.register("autoInput", "startBlockQuote", new _inputrules.InputRule(/^\s*> $/, " ", function(pm, _, pos) {
            wrapAndJoin(pm, pos, this);
        }));
        _model.OrderedList.register("autoInput", "startOrderedList", new _inputrules.InputRule(/^(\d+)\. $/, " ", function(pm, match, pos) {
            var order = +match[1];
            wrapAndJoin(pm, pos, this, {order: order || null}, function(node) {
                return node.childCount + +node.attrs.order == order;
            });
        }));
        _model.BulletList.register("autoInput", "startBulletList", new _inputrules.InputRule(/^\s*([-+*]) $/, " ", function(pm, match, pos) {
            var bullet = match[1];
            wrapAndJoin(pm, pos, this, null, function(node) {
                return node.attrs.bullet == bullet;
            });
        }));
        _model.CodeBlock.register("autoInput", "startCodeBlock", new _inputrules.InputRule(/^```$/, "`", function(pm, _, pos) {
            setAs(pm, pos, this, {params: ""});
        }));
        _model.Heading.registerComputed("autoInput", "startHeading", function(type) {
            var re = new RegExp("^(#{1," + type.maxLevel + "}) $");
            return new _inputrules.InputRule(re, " ", function(pm, match, pos) {
                setAs(pm, pos, this, {level: match[1].length});
            });
        });
        function wrapAndJoin(pm, pos, type) {
            var attrs = arguments.length <= 3 || arguments[3] === undefined ? null : arguments[3];
            var predicate = arguments.length <= 4 || arguments[4] === undefined ? null : arguments[4];
            var $pos = pm.doc.resolve(pos),
                d1 = $pos.depth - 1;
            var sibling = $pos.index(d1) > 0 && $pos.node(d1).child($pos.index(d1) - 1);
            var join = sibling && sibling.type == type && (!predicate || predicate(sibling));
            var start = pos - $pos.parentOffset;
            var tr = pm.tr.delete(start, pos).wrap(start, start, type, attrs);
            if (join)
                tr.join($pos.before($pos.depth));
            tr.apply();
        }
        function setAs(pm, pos, type, attrs) {
            var $pos = pm.doc.resolve(pos),
                start = pos - $pos.parentOffset;
            pm.tr.delete(start, pos).setBlockType(start, start, type, attrs).apply();
        }
        return module.exports;
    });

    $__System.registerDynamic("7", ["8"], true, function($__require, exports, module) {
        "use strict";
        ;
        var define,
            global = this,
            GLOBAL = this;
        Object.defineProperty(exports, "__esModule", {value: true});
        exports.Tooltip = undefined;
        var _createClass = function() {
            function defineProperties(target, props) {
                for (var i = 0; i < props.length; i++) {
                    var descriptor = props[i];
                    descriptor.enumerable = descriptor.enumerable || false;
                    descriptor.configurable = true;
                    if ("value" in descriptor)
                        descriptor.writable = true;
                    Object.defineProperty(target, descriptor.key, descriptor);
                }
            }
            return function(Constructor, protoProps, staticProps) {
                if (protoProps)
                    defineProperties(Constructor.prototype, protoProps);
                if (staticProps)
                    defineProperties(Constructor, staticProps);
                return Constructor;
            };
        }();
        var _dom = $__require('8');
        function _classCallCheck(instance, Constructor) {
            if (!(instance instanceof Constructor)) {
                throw new TypeError("Cannot call a class as a function");
            }
        }
        var prefix = "ProseMirror-tooltip";
        var Tooltip = exports.Tooltip = function() {
            function Tooltip(wrapper, options) {
                var _this = this;
                _classCallCheck(this, Tooltip);
                this.wrapper = wrapper;
                this.options = typeof options == "string" ? {direction: options} : options;
                this.dir = this.options.direction || "above";
                this.pointer = wrapper.appendChild((0, _dom.elt)("div", {class: prefix + "-pointer-" + this.dir + " " + prefix + "-pointer"}));
                this.pointerWidth = this.pointerHeight = null;
                this.dom = wrapper.appendChild((0, _dom.elt)("div", {class: prefix}));
                this.dom.addEventListener("transitionend", function() {
                    if (_this.dom.style.opacity == "0")
                        _this.dom.style.display = _this.pointer.style.display = "";
                });
                this.isOpen = false;
                this.lastLeft = this.lastTop = null;
            }
            _createClass(Tooltip, [{
                key: "detach",
                value: function detach() {
                    this.dom.parentNode.removeChild(this.dom);
                    this.pointer.parentNode.removeChild(this.pointer);
                }
            }, {
                key: "getSize",
                value: function getSize(node) {
                    var wrap = this.wrapper.appendChild((0, _dom.elt)("div", {
                        class: prefix,
                        style: "display: block; position: absolute"
                    }, node));
                    var size = {
                        width: wrap.offsetWidth + 1,
                        height: wrap.offsetHeight
                    };
                    wrap.parentNode.removeChild(wrap);
                    return size;
                }
            }, {
                key: "open",
                value: function open(node, pos) {
                    var left = this.lastLeft = pos ? pos.left : this.lastLeft;
                    var top = this.lastTop = pos ? pos.top : this.lastTop;
                    var size = this.getSize(node);
                    var around = this.wrapper.getBoundingClientRect();
                    var boundingRect = (this.options.getBoundingRect || windowRect)();
                    for (var child = this.dom.firstChild,
                             next; child; child = next) {
                        next = child.nextSibling;
                        if (child != this.pointer)
                            this.dom.removeChild(child);
                    }
                    this.dom.appendChild(node);
                    this.dom.style.display = this.pointer.style.display = "block";
                    if (this.pointerWidth == null) {
                        this.pointerWidth = this.pointer.offsetWidth - 1;
                        this.pointerHeight = this.pointer.offsetHeight - 1;
                    }
                    this.dom.style.width = size.width + "px";
                    this.dom.style.height = size.height + "px";
                    var margin = 5;
                    if (this.dir == "above" || this.dir == "below") {
                        var tipLeft = Math.max(boundingRect.left, Math.min(left - size.width / 2, boundingRect.right - size.width));
                        this.dom.style.left = tipLeft - around.left + "px";
                        this.pointer.style.left = left - around.left - this.pointerWidth / 2 + "px";
                        if (this.dir == "above") {
                            var tipTop = top - around.top - margin - this.pointerHeight - size.height;
                            this.dom.style.top = tipTop + "px";
                            this.pointer.style.top = tipTop + size.height + "px";
                        } else {
                            var tipTop = top - around.top + margin;
                            this.pointer.style.top = tipTop + "px";
                            this.dom.style.top = tipTop + this.pointerHeight + "px";
                        }
                    } else if (this.dir == "left" || this.dir == "right") {
                        this.dom.style.top = top - around.top - size.height / 2 + "px";
                        this.pointer.style.top = top - this.pointerHeight / 2 - around.top + "px";
                        if (this.dir == "left") {
                            var pointerLeft = left - around.left - margin - this.pointerWidth;
                            this.dom.style.left = pointerLeft - size.width + "px";
                            this.pointer.style.left = pointerLeft + "px";
                        } else {
                            var pointerLeft = left - around.left + margin;
                            this.dom.style.left = pointerLeft + this.pointerWidth + "px";
                            this.pointer.style.left = pointerLeft + "px";
                        }
                    } else if (this.dir == "center") {
                        var _top = Math.max(around.top, boundingRect.top),
                            bottom = Math.min(around.bottom, boundingRect.bottom);
                        var fromTop = (bottom - _top - size.height) / 2;
                        this.dom.style.left = (around.width - size.width) / 2 + "px";
                        this.dom.style.top = _top - around.top + fromTop + "px";
                    }
                    getComputedStyle(this.dom).opacity;
                    getComputedStyle(this.pointer).opacity;
                    this.dom.style.opacity = this.pointer.style.opacity = 1;
                    this.isOpen = true;
                }
            }, {
                key: "close",
                value: function close() {
                    if (this.isOpen) {
                        this.isOpen = false;
                        this.dom.style.opacity = this.pointer.style.opacity = 0;
                    }
                }
            }]);
            return Tooltip;
        }();
        function windowRect() {
            return {
                left: 0,
                right: window.innerWidth,
                top: 0,
                bottom: window.innerHeight
            };
        }
        (0, _dom.insertCSS)("\n\n." + prefix + " {\n  position: absolute;\n  display: none;\n  box-sizing: border-box;\n  -moz-box-sizing: border- box;\n  overflow: hidden;\n\n  -webkit-transition: width 0.4s ease-out, height 0.4s ease-out, left 0.4s ease-out, top 0.4s ease-out, opacity 0.2s;\n  -moz-transition: width 0.4s ease-out, height 0.4s ease-out, left 0.4s ease-out, top 0.4s ease-out, opacity 0.2s;\n  transition: width 0.4s ease-out, height 0.4s ease-out, left 0.4s ease-out, top 0.4s ease-out, opacity 0.2s;\n  opacity: 0;\n\n  border-radius: 5px;\n  padding: 3px 7px;\n  margin: 0;\n  background: white;\n  border: 1px solid #777;\n  color: #555;\n\n  z-index: 11;\n}\n\n." + prefix + "-pointer {\n  position: absolute;\n  display: none;\n  width: 0; height: 0;\n\n  -webkit-transition: left 0.4s ease-out, top 0.4s ease-out, opacity 0.2s;\n  -moz-transition: left 0.4s ease-out, top 0.4s ease-out, opacity 0.2s;\n  transition: left 0.4s ease-out, top 0.4s ease-out, opacity 0.2s;\n  opacity: 0;\n\n  z-index: 12;\n}\n\n." + prefix + "-pointer:after {\n  content: \"\";\n  position: absolute;\n  display: block;\n}\n\n." + prefix + "-pointer-above {\n  border-left: 6px solid transparent;\n  border-right: 6px solid transparent;\n  border-top: 6px solid #777;\n}\n\n." + prefix + "-pointer-above:after {\n  border-left: 6px solid transparent;\n  border-right: 6px solid transparent;\n  border-top: 6px solid white;\n  left: -6px; top: -7px;\n}\n\n." + prefix + "-pointer-below {\n  border-left: 6px solid transparent;\n  border-right: 6px solid transparent;\n  border-bottom: 6px solid #777;\n}\n\n." + prefix + "-pointer-below:after {\n  border-left: 6px solid transparent;\n  border-right: 6px solid transparent;\n  border-bottom: 6px solid white;\n  left: -6px; top: 1px;\n}\n\n." + prefix + "-pointer-right {\n  border-top: 6px solid transparent;\n  border-bottom: 6px solid transparent;\n  border-right: 6px solid #777;\n}\n\n." + prefix + "-pointer-right:after {\n  border-top: 6px solid transparent;\n  border-bottom: 6px solid transparent;\n  border-right: 6px solid white;\n  left: 1px; top: -6px;\n}\n\n." + prefix + "-pointer-left {\n  border-top: 6px solid transparent;\n  border-bottom: 6px solid transparent;\n  border-left: 6px solid #777;\n}\n\n." + prefix + "-pointer-left:after {\n  border-top: 6px solid transparent;\n  border-bottom: 6px solid transparent;\n  border-left: 6px solid white;\n  left: -7px; top: -6px;\n}\n\n." + prefix + " input[type=\"text\"],\n." + prefix + " textarea {\n  background: #eee;\n  border: none;\n  outline: none;\n}\n\n." + prefix + " input[type=\"text\"] {\n  padding: 0 4px;\n}\n\n");
        return module.exports;
    });

    $__System.registerDynamic("9", ["3", "8", "7", "a", "b"], true, function($__require, exports, module) {
        "use strict";
        ;
        var define,
            global = this,
            GLOBAL = this;
        var _createClass = function() {
            function defineProperties(target, props) {
                for (var i = 0; i < props.length; i++) {
                    var descriptor = props[i];
                    descriptor.enumerable = descriptor.enumerable || false;
                    descriptor.configurable = true;
                    if ("value" in descriptor)
                        descriptor.writable = true;
                    Object.defineProperty(target, descriptor.key, descriptor);
                }
            }
            return function(Constructor, protoProps, staticProps) {
                if (protoProps)
                    defineProperties(Constructor.prototype, protoProps);
                if (staticProps)
                    defineProperties(Constructor, staticProps);
                return Constructor;
            };
        }();
        var _edit = $__require('3');
        var _dom = $__require('8');
        var _tooltip = $__require('7');
        var _update = $__require('a');
        var _menu = $__require('b');
        function _classCallCheck(instance, Constructor) {
            if (!(instance instanceof Constructor)) {
                throw new TypeError("Cannot call a class as a function");
            }
        }
        var classPrefix = "ProseMirror-tooltipmenu";
        (0, _edit.defineOption)("tooltipMenu", false, function(pm, value) {
            if (pm.mod.tooltipMenu)
                pm.mod.tooltipMenu.detach();
            pm.mod.tooltipMenu = value ? new TooltipMenu(pm, value) : null;
        });
        var defaultInline = [_menu.inlineGroup, _menu.insertMenu];
        var defaultBlock = [[_menu.textblockMenu, _menu.blockGroup]];
        var TooltipMenu = function() {
            function TooltipMenu(pm, config) {
                var _this = this;
                _classCallCheck(this, TooltipMenu);
                this.pm = pm;
                this.config = config || {};
                this.showLinks = this.config.showLinks !== false;
                this.selectedBlockMenu = this.config.selectedBlockMenu;
                this.updater = new _update.UpdateScheduler(pm, "change selectionChange blur focus commandsChanged", function() {
                    return _this.update();
                });
                this.onContextMenu = this.onContextMenu.bind(this);
                pm.content.addEventListener("contextmenu", this.onContextMenu);
                this.tooltip = new _tooltip.Tooltip(pm.wrapper, "above");
                this.inlineContent = this.config.inlineContent || defaultInline;
                this.blockContent = this.config.blockContent || defaultBlock;
                this.selectedBlockContent = this.config.selectedBlockContent || this.inlineContent.concat(this.blockContent);
            }
            _createClass(TooltipMenu, [{
                key: "detach",
                value: function detach() {
                    this.updater.detach();
                    this.tooltip.detach();
                    this.pm.content.removeEventListener("contextmenu", this.onContextMenu);
                }
            }, {
                key: "show",
                value: function show(content, coords) {
                    this.tooltip.open((0, _dom.elt)("div", null, (0, _menu.renderGrouped)(this.pm, content)), coords);
                }
            }, {
                key: "update",
                value: function update() {
                    var _this2 = this;
                    var _pm$selection = this.pm.selection;
                    var empty = _pm$selection.empty;
                    var node = _pm$selection.node;
                    var from = _pm$selection.from;
                    var to = _pm$selection.to;
                    var link = undefined;
                    if (!this.pm.hasFocus()) {
                        this.tooltip.close();
                    } else if (node && node.isBlock) {
                        return function() {
                            var coords = topOfNodeSelection(_this2.pm);
                            return function() {
                                return _this2.show(_this2.blockContent, coords);
                            };
                        };
                    } else if (!empty) {
                        return function() {
                            var coords = node ? topOfNodeSelection(_this2.pm) : topCenterOfSelection(),
                                $from = undefined;
                            var showBlock = _this2.selectedBlockMenu && ($from = _this2.pm.doc.resolve(from)).parentOffset == 0 && $from.end($from.depth) == to;
                            return function() {
                                return _this2.show(showBlock ? _this2.selectedBlockContent : _this2.inlineContent, coords);
                            };
                        };
                    } else if (this.selectedBlockMenu && this.pm.doc.resolve(from).parent.content.size == 0) {
                        return function() {
                            var coords = _this2.pm.coordsAtPos(from);
                            return function() {
                                return _this2.show(_this2.blockContent, coords);
                            };
                        };
                    } else if (this.showLinks && (link = this.linkUnderCursor())) {
                        return function() {
                            var coords = _this2.pm.coordsAtPos(from);
                            return function() {
                                return _this2.showLink(link, coords);
                            };
                        };
                    } else {
                        this.tooltip.close();
                    }
                }
            }, {
                key: "linkUnderCursor",
                value: function linkUnderCursor() {
                    var head = this.pm.selection.head;
                    if (!head)
                        return null;
                    var marks = this.pm.doc.marksAt(head);
                    return marks.reduce(function(found, m) {
                        return found || m.type.name == "link" && m;
                    }, null);
                }
            }, {
                key: "showLink",
                value: function showLink(link, pos) {
                    var node = (0, _dom.elt)("div", {class: classPrefix + "-linktext"}, (0, _dom.elt)("a", {
                        href: link.attrs.href,
                        title: link.attrs.title
                    }, link.attrs.href));
                    this.tooltip.open(node, pos);
                }
            }, {
                key: "onContextMenu",
                value: function onContextMenu(e) {
                    if (!this.pm.selection.empty)
                        return;
                    var pos = this.pm.posAtCoords({
                        left: e.clientX,
                        top: e.clientY
                    });
                    if (!pos || !pos.isValid(this.pm.doc, true))
                        return;
                    this.pm.setTextSelection(pos, pos);
                    this.pm.flush();
                    this.show(this.inlineContent, topCenterOfSelection());
                }
            }]);
            return TooltipMenu;
        }();
        function topCenterOfSelection() {
            var range = window.getSelection().getRangeAt(0),
                rects = range.getClientRects();
            if (!rects.length)
                return range.getBoundingClientRect();
            var _rects$ = rects[0];
            var left = _rects$.left;
            var right = _rects$.right;
            var top = _rects$.top;
            var i = 1;
            while (left == right && rects.length > i) {
                ;
                var _rects = rects[i++];
                left = _rects.left;
                right = _rects.right;
                top = _rects.top;
            }
            for (; i < rects.length; i++) {
                if (rects[i].top < rects[0].bottom - 1 && (i == rects.length - 1 || Math.abs(rects[i + 1].left - rects[i].left) > 1)) {
                    left = Math.min(left, rects[i].left);
                    right = Math.max(right, rects[i].right);
                    top = Math.min(top, rects[i].top);
                }
            }
            return {
                top: top,
                left: (left + right) / 2
            };
        }
        function topOfNodeSelection(pm) {
            var selected = pm.content.querySelector(".ProseMirror-selectednode");
            if (!selected)
                return {
                    left: 0,
                    top: 0
                };
            var box = selected.getBoundingClientRect();
            return {
                left: Math.min((box.left + box.right) / 2, box.left + 20),
                top: box.top
            };
        }
        (0, _dom.insertCSS)("\n\n." + classPrefix + "-linktext a {\n  color: #444;\n  text-decoration: none;\n  padding: 0 5px;\n}\n\n." + classPrefix + "-linktext a:hover {\n  text-decoration: underline;\n}\n\n");
        return module.exports;
    });

    $__System.registerDynamic("c", ["8"], true, function($__require, exports, module) {
        "use strict";
        ;
        var define,
            global = this,
            GLOBAL = this;
        var _dom = $__require('8');
        (0, _dom.insertCSS)("\n\n.ProseMirror {\n  border: 1px solid silver;\n  position: relative;\n}\n\n.ProseMirror-content {\n  padding: 4px 8px 4px 14px;\n  white-space: pre-wrap;\n  line-height: 1.2;\n}\n\n.ProseMirror-drop-target {\n  position: absolute;\n  width: 1px;\n  background: #666;\n}\n\n.ProseMirror-content ul.tight p, .ProseMirror-content ol.tight p {\n  margin: 0;\n}\n\n.ProseMirror-content ul, .ProseMirror-content ol {\n  padding-left: 30px;\n  cursor: default;\n}\n\n.ProseMirror-content blockquote {\n  padding-left: 1em;\n  border-left: 3px solid #eee;\n  margin-left: 0; margin-right: 0;\n}\n\n.ProseMirror-content pre {\n  white-space: pre-wrap;\n}\n\n.ProseMirror-selectednode {\n  outline: 2px solid #8cf;\n}\n\n.ProseMirror-nodeselection *::selection { background: transparent; }\n.ProseMirror-nodeselection *::-moz-selection { background: transparent; }\n\n.ProseMirror-content p:first-child,\n.ProseMirror-content h1:first-child,\n.ProseMirror-content h2:first-child,\n.ProseMirror-content h3:first-child,\n.ProseMirror-content h4:first-child,\n.ProseMirror-content h5:first-child,\n.ProseMirror-content h6:first-child {\n  margin-top: .3em;\n}\n\n/* Add space around the hr to make clicking it easier */\n\n.ProseMirror-content hr {\n  position: relative;\n  height: 6px;\n  border: none;\n}\n\n.ProseMirror-content hr:after {\n  content: \"\";\n  position: absolute;\n  left: 10px;\n  right: 10px;\n  top: 2px;\n  border-top: 2px solid silver;\n}\n\n.ProseMirror-content img {\n  cursor: default;\n}\n\n/* Make sure li selections wrap around markers */\n\n.ProseMirror-content li {\n  position: relative;\n  pointer-events: none; /* Don't do weird stuff with marker clicks */\n}\n.ProseMirror-content li > * {\n  pointer-events: auto;\n}\n\nli.ProseMirror-selectednode {\n  outline: none;\n}\n\nli.ProseMirror-selectednode:after {\n  content: \"\";\n  position: absolute;\n  left: -32px;\n  right: -2px; top: -2px; bottom: -2px;\n  border: 2px solid #8cf;\n  pointer-events: none;\n}\n\n");
        return module.exports;
    });

    $__System.registerDynamic("d", [], true, function($__require, exports, module) {
        "use strict";
        ;
        var define,
            global = this,
            GLOBAL = this;
        Object.defineProperty(exports, "__esModule", {value: true});
        var _createClass = function() {
            function defineProperties(target, props) {
                for (var i = 0; i < props.length; i++) {
                    var descriptor = props[i];
                    descriptor.enumerable = descriptor.enumerable || false;
                    descriptor.configurable = true;
                    if ("value" in descriptor)
                        descriptor.writable = true;
                    Object.defineProperty(target, descriptor.key, descriptor);
                }
            }
            return function(Constructor, protoProps, staticProps) {
                if (protoProps)
                    defineProperties(Constructor.prototype, protoProps);
                if (staticProps)
                    defineProperties(Constructor, staticProps);
                return Constructor;
            };
        }();
        function _classCallCheck(instance, Constructor) {
            if (!(instance instanceof Constructor)) {
                throw new TypeError("Cannot call a class as a function");
            }
        }
        var Map = exports.Map = window.Map || function() {
                function _class() {
                    _classCallCheck(this, _class);
                    this.content = [];
                }
                _createClass(_class, [{
                    key: "set",
                    value: function set(key, value) {
                        var found = this.find(key);
                        if (found > -1)
                            this.content[found + 1] = value;
                        else
                            this.content.push(key, value);
                    }
                }, {
                    key: "get",
                    value: function get(key) {
                        var found = this.find(key);
                        return found == -1 ? undefined : this.content[found + 1];
                    }
                }, {
                    key: "has",
                    value: function has(key) {
                        return this.find(key) > -1;
                    }
                }, {
                    key: "find",
                    value: function find(key) {
                        for (var i = 0; i < this.content.length; i += 2) {
                            if (this.content[i] === key)
                                return i;
                        }
                    }
                }, {
                    key: "clear",
                    value: function clear() {
                        this.content.length = 0;
                    }
                }, {
                    key: "size",
                    get: function get() {
                        return this.content.length / 2;
                    }
                }]);
                return _class;
            }();
        return module.exports;
    });

    $__System.registerDynamic("e", ["f", "8", "10", "11"], true, function($__require, exports, module) {
        "use strict";
        ;
        var define,
            global = this,
            GLOBAL = this;
        Object.defineProperty(exports, "__esModule", {value: true});
        exports.draw = draw;
        exports.redraw = redraw;
        var _format = $__require('f');
        var _dom = $__require('8');
        var _main = $__require('10');
        var _dompos = $__require('11');
        function options(ranges) {
            return {
                pos: 0,
                preRenderContent: function preRenderContent() {
                    this.pos++;
                },
                postRenderContent: function postRenderContent() {
                    this.pos++;
                },
                onRender: function onRender(node, dom, offset) {
                    if (node.isBlock) {
                        if (offset != null)
                            dom.setAttribute("pm-offset", offset);
                        dom.setAttribute("pm-size", node.nodeSize);
                        if (node.isTextblock)
                            adjustTrailingHacks(dom, node);
                        if (dom.contentEditable == "false")
                            dom = (0, _dom.elt)("div", null, dom);
                        if (!node.type.contains)
                            this.pos++;
                    }
                    return dom;
                },
                onContainer: function onContainer(node) {
                    node.setAttribute("pm-container", true);
                },
                renderInlineFlat: function renderInlineFlat(node, dom, offset) {
                    ranges.advanceTo(this.pos);
                    var pos = this.pos,
                        end = pos + node.nodeSize;
                    var nextCut = ranges.nextChangeBefore(end);
                    var inner = dom,
                        wrapped = undefined;
                    for (var i = 0; i < node.marks.length; i++) {
                        inner = inner.firstChild;
                    }
                    if (dom.nodeType != 1) {
                        dom = (0, _dom.elt)("span", null, dom);
                        if (nextCut == -1)
                            wrapped = dom;
                    }
                    if (!wrapped && (nextCut > -1 || ranges.current.length)) {
                        wrapped = inner == dom ? dom = (0, _dom.elt)("span", null, inner) : inner.parentNode.appendChild((0, _dom.elt)("span", null, inner));
                    }
                    dom.setAttribute("pm-offset", offset);
                    dom.setAttribute("pm-size", node.nodeSize);
                    var inlineOffset = 0;
                    while (nextCut > -1) {
                        var size = nextCut - pos;
                        var split = splitSpan(wrapped, size);
                        if (ranges.current.length)
                            split.className = ranges.current.join(" ");
                        split.setAttribute("pm-inner-offset", inlineOffset);
                        inlineOffset += size;
                        ranges.advanceTo(nextCut);
                        nextCut = ranges.nextChangeBefore(end);
                        if (nextCut == -1)
                            wrapped.setAttribute("pm-inner-offset", inlineOffset);
                        pos += size;
                    }
                    if (ranges.current.length)
                        wrapped.className = ranges.current.join(" ");
                    this.pos += node.nodeSize;
                    return dom;
                },
                document: document
            };
        }
        function splitSpan(span, at) {
            var textNode = span.firstChild,
                text = textNode.nodeValue;
            var newNode = span.parentNode.insertBefore((0, _dom.elt)("span", null, text.slice(0, at)), span);
            textNode.nodeValue = text.slice(at);
            return newNode;
        }
        function draw(pm, doc) {
            pm.content.textContent = "";
            pm.content.appendChild((0, _format.toDOM)(doc, options(pm.ranges.activeRangeTracker())));
        }
        function adjustTrailingHacks(dom, node) {
            var needs = node.content.size == 0 || node.lastChild.type.isBR || node.type.isCode && node.lastChild.isText && /\n$/.test(node.lastChild.text) ? "br" : !node.lastChild.isText && node.lastChild.type.contains == null ? "text" : null;
            var last = dom.lastChild;
            var has = !last || last.nodeType != 1 || !last.hasAttribute("pm-ignore") ? null : last.nodeName == "BR" ? "br" : "text";
            if (needs != has) {
                if (has)
                    dom.removeChild(last);
                if (needs)
                    dom.appendChild(needs == "br" ? (0, _dom.elt)("br", {"pm-ignore": "trailing-break"}) : (0, _dom.elt)("span", {"pm-ignore": "cursor-text"}, ""));
            }
        }
        function findNodeIn(parent, i, node) {
            for (; i < parent.childCount; i++) {
                var child = parent.child(i);
                if (child == node)
                    return i;
            }
            return -1;
        }
        function movePast(dom) {
            var next = dom.nextSibling;
            dom.parentNode.removeChild(dom);
            return next;
        }
        function redraw(pm, dirty, doc, prev) {
            if (dirty.get(prev) == _main.DIRTY_REDRAW)
                return draw(pm, doc);
            var opts = options(pm.ranges.activeRangeTracker());
            function scan(dom, node, prev, pos) {
                var iPrev = 0,
                    pChild = prev.firstChild;
                var domPos = dom.firstChild;
                for (var iNode = 0,
                         offset = 0; iNode < node.childCount; iNode++) {
                    var child = node.child(iNode),
                        matching = undefined,
                        reuseDOM = undefined;
                    var found = pChild == child ? iPrev : findNodeIn(prev, iPrev + 1, child);
                    if (found > -1) {
                        matching = child;
                        while (iPrev != found) {
                            iPrev++;
                            domPos = movePast(domPos);
                        }
                    }
                    if (matching && !dirty.get(matching)) {
                        reuseDOM = true;
                    } else if (pChild && !child.isText && child.sameMarkup(pChild) && dirty.get(pChild) != _main.DIRTY_REDRAW) {
                        reuseDOM = true;
                        if (pChild.type.contains)
                            scan((0, _dompos.childContainer)(domPos), child, pChild, pos + offset + 1);
                    } else {
                        opts.pos = pos + offset;
                        var rendered = (0, _format.nodeToDOM)(child, opts, offset);
                        dom.insertBefore(rendered, domPos);
                        reuseDOM = false;
                    }
                    if (reuseDOM) {
                        domPos.setAttribute("pm-offset", offset);
                        domPos.setAttribute("pm-size", child.nodeSize);
                        domPos = domPos.nextSibling;
                        pChild = prev.maybeChild(++iPrev);
                    }
                    offset += child.nodeSize;
                }
                while (pChild) {
                    domPos = movePast(domPos);
                    pChild = prev.maybeChild(++iPrev);
                }
                if (node.isTextblock)
                    adjustTrailingHacks(dom, node);
            }
            scan(pm.content, doc, prev, 0);
        }
        return module.exports;
    });

    $__System.registerDynamic("12", ["14", "13", "8"], true, function($__require, exports, module) {
        "use strict";
        ;
        var define,
            global = this,
            GLOBAL = this;
        Object.defineProperty(exports, "__esModule", {value: true});
        exports.captureKeys = undefined;
        var _browserkeymap = $__require('14');
        var _browserkeymap2 = _interopRequireDefault(_browserkeymap);
        var _selection = $__require('13');
        var _dom = $__require('8');
        function _interopRequireDefault(obj) {
            return obj && obj.__esModule ? obj : {default: obj};
        }
        function nothing() {}
        function moveSelectionBlock(pm, dir) {
            var _pm$selection = pm.selection;
            var from = _pm$selection.from;
            var to = _pm$selection.to;
            var node = _pm$selection.node;
            var side = pm.doc.resolve(dir > 0 ? to : from);
            return (0, _selection.findSelectionFrom)(pm.doc, node && node.isBlock ? side.pos : dir > 0 ? side.after(side.depth) : side.before(side.depth), dir);
        }
        function selectNodeHorizontally(pm, dir) {
            var _pm$selection2 = pm.selection;
            var empty = _pm$selection2.empty;
            var node = _pm$selection2.node;
            var from = _pm$selection2.from;
            var to = _pm$selection2.to;
            if (!empty && !node)
                return false;
            if (node && node.isInline) {
                pm.setTextSelection(dir > 0 ? to : from);
                return true;
            }
            if (!node) {
                var $from = pm.doc.resolve(from);
                var _ref = dir > 0 ? $from.parent.childAfter($from.parentOffset) : $from.parent.childBefore($from.parentOffset);
                var nextNode = _ref.node;
                var offset = _ref.offset;
                if (nextNode) {
                    if (nextNode.type.selectable && offset == $from.parentOffset - (dir > 0 ? 0 : nextNode.nodeSize)) {
                        pm.setNodeSelection(dir < 0 ? from - nextNode.nodeSize : from);
                        return true;
                    }
                    return false;
                }
            }
            var next = moveSelectionBlock(pm, dir);
            if (next && (next instanceof _selection.NodeSelection || node)) {
                pm.setSelection(next);
                return true;
            }
            return false;
        }
        function horiz(dir) {
            return function(pm) {
                var done = selectNodeHorizontally(pm, dir);
                if (done)
                    pm.scrollIntoView();
                return done;
            };
        }
        function selectNodeVertically(pm, dir) {
            var _pm$selection3 = pm.selection;
            var empty = _pm$selection3.empty;
            var node = _pm$selection3.node;
            var from = _pm$selection3.from;
            var to = _pm$selection3.to;
            if (!empty && !node)
                return false;
            var leavingTextblock = true;
            if (!node || node.isInline) {
                pm.flush();
                leavingTextblock = (0, _selection.verticalMotionLeavesTextblock)(pm, dir > 0 ? to : from, dir);
            }
            if (leavingTextblock) {
                var next = moveSelectionBlock(pm, dir);
                if (next && next instanceof _selection.NodeSelection) {
                    pm.setSelection(next);
                    return true;
                }
            }
            if (!node || node.isInline)
                return false;
            var beyond = (0, _selection.findSelectionFrom)(pm.doc, dir < 0 ? from : to, dir);
            if (beyond)
                pm.setSelection(beyond);
            return true;
        }
        function vert(dir) {
            return function(pm) {
                var done = selectNodeVertically(pm, dir);
                if (done !== false)
                    pm.scrollIntoView();
                return done;
            };
        }
        var keys = {
            "Esc": nothing,
            "Enter": nothing,
            "Ctrl-Enter": nothing,
            "Mod-Enter": nothing,
            "Shift-Enter": nothing,
            "Backspace": nothing,
            "Delete": nothing,
            "Mod-B": nothing,
            "Mod-I": nothing,
            "Mod-Backspace": nothing,
            "Mod-Delete": nothing,
            "Shift-Backspace": nothing,
            "Shift-Delete": nothing,
            "Shift-Mod-Backspace": nothing,
            "Shift-Mod-Delete": nothing,
            "Mod-Z": nothing,
            "Mod-Y": nothing,
            "Shift-Mod-Z": nothing,
            "Ctrl-D": nothing,
            "Ctrl-H": nothing,
            "Ctrl-Alt-Backspace": nothing,
            "Alt-D": nothing,
            "Alt-Delete": nothing,
            "Alt-Backspace": nothing,
            "Left": horiz(-1),
            "Mod-Left": horiz(-1),
            "Right": horiz(1),
            "Mod-Right": horiz(1),
            "Up": vert(-1),
            "Down": vert(1)
        };
        if (_dom.browser.mac) {
            keys["Alt-Left"] = horiz(-1);
            keys["Alt-Right"] = horiz(1);
            keys["Ctrl-Backspace"] = keys["Ctrl-Delete"] = nothing;
        }
        var captureKeys = exports.captureKeys = new _browserkeymap2.default(keys);
        return module.exports;
    });

    $__System.registerDynamic("15", ["6", "f", "16", "13", "11"], true, function($__require, exports, module) {
        "use strict";
        ;
        var define,
            global = this,
            GLOBAL = this;
        Object.defineProperty(exports, "__esModule", {value: true});
        exports.readInputChange = readInputChange;
        exports.readCompositionChange = readCompositionChange;
        var _model = $__require('6');
        var _format = $__require('f');
        var _map = $__require('16');
        var _selection = $__require('13');
        var _dompos = $__require('11');
        function readInputChange(pm) {
            pm.ensureOperation({readSelection: false});
            return readDOMChange(pm, rangeAroundSelection(pm));
        }
        function readCompositionChange(pm, margin) {
            return readDOMChange(pm, rangeAroundComposition(pm, margin));
        }
        function parseBetween(pm, from, to) {
            var _DOMFromPos = (0, _dompos.DOMFromPos)(pm, from, true);
            var parent = _DOMFromPos.node;
            var startOff = _DOMFromPos.offset;
            var endOff = (0, _dompos.DOMFromPos)(pm, to, true).offset;
            while (startOff) {
                var prev = parent.childNodes[startOff - 1];
                if (prev.nodeType != 1 || !prev.hasAttribute("pm-offset"))
                    --startOff;
                else
                    break;
            }
            while (endOff < parent.childNodes.length) {
                var next = parent.childNodes[endOff];
                if (next.nodeType != 1 || !next.hasAttribute("pm-offset"))
                    ++endOff;
                else
                    break;
            }
            return (0, _format.fromDOM)(pm.schema, parent, {
                topNode: pm.doc.resolve(from).parent.copy(),
                from: startOff,
                to: endOff,
                preserveWhitespace: true,
                editableContent: true
            });
        }
        function isAtEnd($pos, depth) {
            for (var i = depth || 0; i < $pos.depth; i++) {
                if ($pos.index(i) + 1 < $pos.node(i).childCount)
                    return false;
            }
            return $pos.parentOffset == $pos.parent.content.size;
        }
        function isAtStart($pos, depth) {
            for (var i = depth || 0; i < $pos.depth; i++) {
                if ($pos.index(0) > 0)
                    return false;
            }
            return $pos.parentOffset == 0;
        }
        function rangeAroundSelection(pm) {
            var _pm$operation = pm.operation;
            var sel = _pm$operation.sel;
            var doc = _pm$operation.doc;
            var $from = doc.resolve(sel.from);
            var $to = doc.resolve(sel.to);
            if ($from.sameParent($to) && $from.parent.isTextblock && $from.parentOffset && $to.parentOffset < $to.parent.content.size)
                return rangeAroundComposition(pm, 0);
            for (var depth = 0; ; depth++) {
                var fromStart = isAtStart($from, depth + 1),
                    toEnd = isAtEnd($to, depth + 1);
                if (fromStart || toEnd || $from.index(depth) != $to.index(depth) || $to.node(depth).isTextblock) {
                    var from = $from.before(depth + 1),
                        to = $to.after(depth + 1);
                    if (fromStart && $from.index(depth) > 0)
                        from -= $from.node(depth).child($from.index(depth) - 1).nodeSize;
                    if (toEnd && $to.index(depth) + 1 < $to.node(depth).childCount)
                        to += $to.node(depth).child($to.index(depth) + 1).nodeSize;
                    return {
                        from: from,
                        to: to
                    };
                }
            }
        }
        function rangeAroundComposition(pm, margin) {
            var _pm$operation2 = pm.operation;
            var sel = _pm$operation2.sel;
            var doc = _pm$operation2.doc;
            var $from = doc.resolve(sel.from),
                $to = doc.resolve(sel.to);
            if (!$from.sameParent($to))
                return rangeAroundSelection(pm);
            var startOff = Math.max(0, $from.parentOffset - margin);
            var size = $from.parent.content.size;
            var endOff = Math.min(size, $to.parentOffset + margin);
            if (startOff > 0)
                startOff = $from.parent.childBefore(startOff).offset;
            if (endOff < size) {
                var after = $from.parent.childAfter(endOff);
                endOff = after.offset + after.node.nodeSize;
            }
            var nodeStart = $from.start($from.depth);
            return {
                from: nodeStart + startOff,
                to: nodeStart + endOff
            };
        }
        function readDOMChange(pm, range) {
            var op = pm.operation;
            if (op.docSet) {
                pm.markAllDirty();
                return;
            }
            var parsed = parseBetween(pm, range.from, range.to);
            var compare = op.doc.slice(range.from, range.to);
            var change = findDiff(compare.content, parsed.content, range.from, op.sel.from);
            if (!change)
                return;
            var fromMapped = (0, _map.mapThroughResult)(op.mappings, change.start);
            var toMapped = (0, _map.mapThroughResult)(op.mappings, change.endA);
            if (fromMapped.deleted && toMapped.deleted)
                return;
            markDirtyFor(pm, op.doc, change.start, change.endA);
            var $from = parsed.resolveNoCache(change.start - range.from);
            var $to = parsed.resolveNoCache(change.endB - range.from),
                nextSel = undefined,
                text = undefined;
            if (!$from.sameParent($to) && $from.pos < parsed.content.size && (nextSel = (0, _selection.findSelectionFrom)(parsed, $from.pos + 1, 1, true)) && nextSel.head == $to.pos) {
                pm.input.dispatchKey("Enter");
            } else if ($from.sameParent($to) && $from.parent.isTextblock && (text = uniformTextBetween(parsed, $from.pos, $to.pos)) != null) {
                pm.input.insertText(fromMapped.pos, toMapped.pos, text);
            } else {
                var slice = parsed.slice(change.start - range.from, change.endB - range.from);
                pm.tr.replace(fromMapped.pos, toMapped.pos, slice).apply(pm.apply.scroll);
            }
        }
        function uniformTextBetween(node, from, to) {
            var result = "",
                valid = true,
                marks = null;
            node.nodesBetween(from, to, function(node, pos) {
                if (!node.isInline && pos < from)
                    return;
                if (!node.isText)
                    return valid = false;
                if (!marks)
                    marks = node.marks;
                else if (!_model.Mark.sameSet(marks, node.marks))
                    valid = false;
                result += node.text.slice(Math.max(0, from - pos), to - pos);
            });
            return valid ? result : null;
        }
        function findDiff(a, b, pos, preferedStart) {
            var start = (0, _model.findDiffStart)(a, b, pos);
            if (!start)
                return null;
            var _findDiffEnd = (0, _model.findDiffEnd)(a, b, pos + a.size, pos + b.size);
            var endA = _findDiffEnd.a;
            var endB = _findDiffEnd.b;
            if (endA < start) {
                var move = preferedStart <= start && preferedStart >= endA ? start - preferedStart : 0;
                start -= move;
                endB = start + (endB - endA);
                endA = start;
            } else if (endB < start) {
                var move = preferedStart <= start && preferedStart >= endB ? start - preferedStart : 0;
                start -= move;
                endA = start + (endA - endB);
                endB = start;
            }
            return {
                start: start,
                endA: endA,
                endB: endB
            };
        }
        function markDirtyFor(pm, doc, start, end) {
            var $start = doc.resolve(start),
                $end = doc.resolve(end),
                same = $start.sameDepth($end);
            if (same == 0)
                pm.markAllDirty();
            else
                pm.markRangeDirty($start.before(same), $start.after(same), doc);
        }
        return module.exports;
    });

    $__System.registerDynamic("17", ["6", "14", "f", "12", "8", "15", "13", "11"], true, function($__require, exports, module) {
        "use strict";
        ;
        var define,
            global = this,
            GLOBAL = this;
        Object.defineProperty(exports, "__esModule", {value: true});
        exports.Input = undefined;
        var _createClass = function() {
            function defineProperties(target, props) {
                for (var i = 0; i < props.length; i++) {
                    var descriptor = props[i];
                    descriptor.enumerable = descriptor.enumerable || false;
                    descriptor.configurable = true;
                    if ("value" in descriptor)
                        descriptor.writable = true;
                    Object.defineProperty(target, descriptor.key, descriptor);
                }
            }
            return function(Constructor, protoProps, staticProps) {
                if (protoProps)
                    defineProperties(Constructor.prototype, protoProps);
                if (staticProps)
                    defineProperties(Constructor, staticProps);
                return Constructor;
            };
        }();
        var _model = $__require('6');
        var _browserkeymap = $__require('14');
        var _browserkeymap2 = _interopRequireDefault(_browserkeymap);
        var _format = $__require('f');
        var _capturekeys = $__require('12');
        var _dom = $__require('8');
        var _domchange = $__require('15');
        var _selection = $__require('13');
        var _dompos = $__require('11');
        function _interopRequireDefault(obj) {
            return obj && obj.__esModule ? obj : {default: obj};
        }
        function _classCallCheck(instance, Constructor) {
            if (!(instance instanceof Constructor)) {
                throw new TypeError("Cannot call a class as a function");
            }
        }
        var stopSeq = null;
        var handlers = {};
        var Input = exports.Input = function() {
            function Input(pm) {
                var _this = this;
                _classCallCheck(this, Input);
                this.pm = pm;
                this.baseKeymap = null;
                this.keySeq = null;
                this.mouseDown = null;
                this.dragging = null;
                this.dropTarget = null;
                this.shiftKey = false;
                this.finishComposing = null;
                this.keymaps = [];
                this.defaultKeymap = null;
                this.storedMarks = null;
                var _loop = function _loop(event) {
                    var handler = handlers[event];
                    pm.content.addEventListener(event, function(e) {
                        return handler(pm, e);
                    });
                };
                for (var event in handlers) {
                    _loop(event);
                }
                pm.on("selectionChange", function() {
                    return _this.storedMarks = null;
                });
            }
            _createClass(Input, [{
                key: "dispatchKey",
                value: function dispatchKey(name, e) {
                    var pm = this.pm,
                        seq = pm.input.keySeq;
                    if (seq) {
                        if (_browserkeymap2.default.isModifierKey(name))
                            return true;
                        clearTimeout(stopSeq);
                        stopSeq = setTimeout(function() {
                            if (pm.input.keySeq == seq)
                                pm.input.keySeq = null;
                        }, 50);
                        name = seq + " " + name;
                    }
                    var handle = function handle(bound) {
                        if (bound === false)
                            return "nothing";
                        if (bound == "...")
                            return "multi";
                        if (bound == null)
                            return false;
                        var result = false;
                        if (Array.isArray(bound)) {
                            for (var i = 0; result === false && i < bound.length; i++) {
                                result = handle(bound[i]);
                            }
                        } else if (typeof bound == "string") {
                            result = pm.execCommand(bound);
                        } else {
                            result = bound(pm);
                        }
                        return result == false ? false : "handled";
                    };
                    var result = undefined;
                    for (var i = 0; !result && i < pm.input.keymaps.length; i++) {
                        result = handle(pm.input.keymaps[i].map.lookup(name, pm));
                    }
                    if (!result)
                        result = handle(pm.input.baseKeymap.lookup(name, pm)) || handle(_capturekeys.captureKeys.lookup(name));
                    if (result == "multi")
                        pm.input.keySeq = name;
                    if ((result == "handled" || result == "multi") && e)
                        e.preventDefault();
                    if (seq && !result && /\'$/.test(name)) {
                        if (e)
                            e.preventDefault();
                        return true;
                    }
                    return !!result;
                }
            }, {
                key: "insertText",
                value: function insertText(from, to, text) {
                    if (from == to && !text)
                        return;
                    var pm = this.pm,
                        marks = pm.input.storedMarks || pm.doc.marksAt(from);
                    var tr = pm.tr.replaceWith(from, to, text ? pm.schema.text(text, marks) : null);
                    tr.apply({
                        scrollIntoView: true,
                        selection: (0, _selection.findSelectionNear)(tr.doc, tr.map(to), -1, true)
                    });
                    if (text)
                        pm.signal("textInput", text);
                }
            }, {
                key: "startComposition",
                value: function startComposition(dataLen, realStart) {
                    this.pm.ensureOperation({
                        noFlush: true,
                        readSelection: realStart
                    }).composing = {
                        ended: false,
                        applied: false,
                        margin: dataLen
                    };
                    this.pm.unscheduleFlush();
                }
            }, {
                key: "applyComposition",
                value: function applyComposition(andFlush) {
                    var composing = this.composing;
                    if (composing.applied)
                        return;
                    (0, _domchange.readCompositionChange)(this.pm, composing.margin);
                    composing.applied = true;
                    if (andFlush)
                        this.pm.flush();
                }
            }, {
                key: "composing",
                get: function get() {
                    return this.pm.operation && this.pm.operation.composing;
                }
            }]);
            return Input;
        }();
        handlers.keydown = function(pm, e) {
            if (!(0, _selection.hasFocus)(pm))
                return;
            pm.signal("interaction");
            if (e.keyCode == 16)
                pm.input.shiftKey = true;
            if (pm.input.composing)
                return;
            var name = _browserkeymap2.default.keyName(e);
            if (name && pm.input.dispatchKey(name, e))
                return;
            pm.sel.fastPoll();
        };
        handlers.keyup = function(pm, e) {
            if (e.keyCode == 16)
                pm.input.shiftKey = false;
        };
        handlers.keypress = function(pm, e) {
            if (!(0, _selection.hasFocus)(pm) || pm.input.composing || !e.charCode || e.ctrlKey && !e.altKey || _dom.browser.mac && e.metaKey)
                return;
            if (pm.input.dispatchKey(_browserkeymap2.default.keyName(e), e))
                return;
            var sel = pm.selection;
            if (!_dom.browser.ios) {
                pm.input.insertText(sel.from, sel.to, String.fromCharCode(e.charCode));
                e.preventDefault();
            }
        };
        function realTarget(pm, mouseEvent) {
            if (pm.operation && pm.flush())
                return document.elementFromPoint(mouseEvent.clientX, mouseEvent.clientY);
            else
                return mouseEvent.target;
        }
        function selectClickedNode(pm, e, target) {
            var pos = (0, _dompos.selectableNodeAbove)(pm, target, {
                left: e.clientX,
                top: e.clientY
            }, true);
            if (pos == null)
                return pm.sel.fastPoll();
            var _pm$selection = pm.selection;
            var node = _pm$selection.node;
            var from = _pm$selection.from;
            if (node) {
                var $pos = pm.doc.resolve(pos),
                    $from = pm.doc.resolve(from);
                if ($pos.depth >= $from.depth && $pos.before($from.depth) == from) {
                    if ($from.depth == 0)
                        return pm.sel.fastPoll();
                    pos = $pos.before($pos.depth);
                }
            }
            pm.setNodeSelection(pos);
            pm.focus();
            e.preventDefault();
        }
        var lastClick = 0,
            oneButLastClick = 0;
        function handleTripleClick(pm, e, target) {
            e.preventDefault();
            var pos = (0, _dompos.selectableNodeAbove)(pm, target, {
                left: e.clientX,
                top: e.clientY
            }, true);
            if (pos != null) {
                var $pos = pm.doc.resolve(pos),
                    node = $pos.nodeAfter;
                if (node.isBlock && !node.isTextblock)
                    pm.setNodeSelection(pos);
                else if (node.isInline)
                    pm.setTextSelection($pos.start($pos.depth), $pos.end($pos.depth));
                else
                    pm.setTextSelection(pos + 1, pos + 1 + node.content.size);
                pm.focus();
            }
        }
        handlers.mousedown = function(pm, e) {
            pm.signal("interaction");
            var now = Date.now(),
                doubleClick = now - lastClick < 500,
                tripleClick = now - oneButLastClick < 600;
            oneButLastClick = lastClick;
            lastClick = now;
            var target = realTarget(pm, e);
            if (tripleClick)
                handleTripleClick(pm, e, target);
            else if (doubleClick && (0, _dompos.handleNodeClick)(pm, "handleDoubleClick", e, target, true)) {} else
                pm.input.mouseDown = new MouseDown(pm, e, target, doubleClick);
        };
        var MouseDown = function() {
            function MouseDown(pm, event, target, doubleClick) {
                _classCallCheck(this, MouseDown);
                this.pm = pm;
                this.event = event;
                this.target = target;
                this.leaveToBrowser = pm.input.shiftKey || doubleClick;
                var pos = (0, _dompos.posBeforeFromDOM)(pm, this.target),
                    node = pm.doc.nodeAt(pos);
                this.mightDrag = node.type.draggable || node == pm.sel.range.node ? pos : null;
                if (this.mightDrag != null) {
                    this.target.draggable = true;
                    if (_dom.browser.gecko && (this.setContentEditable = !this.target.hasAttribute("contentEditable")))
                        this.target.setAttribute("contentEditable", "false");
                }
                this.x = event.clientX;
                this.y = event.clientY;
                window.addEventListener("mouseup", this.up = this.up.bind(this));
                window.addEventListener("mousemove", this.move = this.move.bind(this));
                pm.sel.fastPoll();
            }
            _createClass(MouseDown, [{
                key: "done",
                value: function done() {
                    window.removeEventListener("mouseup", this.up);
                    window.removeEventListener("mousemove", this.move);
                    if (this.mightDrag != null) {
                        this.target.draggable = false;
                        if (_dom.browser.gecko && this.setContentEditable)
                            this.target.removeAttribute("contentEditable");
                    }
                }
            }, {
                key: "up",
                value: function up(event) {
                    this.done();
                    var target = realTarget(this.pm, event);
                    if (this.leaveToBrowser || !(0, _dom.contains)(this.pm.content, target)) {
                        this.pm.sel.fastPoll();
                    } else if (this.event.ctrlKey) {
                        selectClickedNode(this.pm, event, target);
                    } else if (!(0, _dompos.handleNodeClick)(this.pm, "handleClick", event, target, true)) {
                        var pos = (0, _dompos.selectableNodeAbove)(this.pm, target, {
                            left: this.x,
                            top: this.y
                        });
                        if (pos) {
                            this.pm.setNodeSelection(pos);
                            this.pm.focus();
                        } else {
                            this.pm.sel.fastPoll();
                        }
                    }
                }
            }, {
                key: "move",
                value: function move(event) {
                    if (!this.leaveToBrowser && (Math.abs(this.x - event.clientX) > 4 || Math.abs(this.y - event.clientY) > 4))
                        this.leaveToBrowser = true;
                    this.pm.sel.fastPoll();
                }
            }]);
            return MouseDown;
        }();
        handlers.touchdown = function(pm) {
            pm.sel.fastPoll();
        };
        handlers.contextmenu = function(pm, e) {
            (0, _dompos.handleNodeClick)(pm, "handleContextMenu", e, realTarget(pm, e), false);
        };
        handlers.compositionstart = function(pm, e) {
            if (!pm.input.composing && (0, _selection.hasFocus)(pm))
                pm.input.startComposition(e.data ? e.data.length : 0, true);
        };
        handlers.compositionupdate = function(pm) {
            if (!pm.input.composing && (0, _selection.hasFocus)(pm))
                pm.input.startComposition(0, false);
        };
        handlers.compositionend = function(pm, e) {
            if (!(0, _selection.hasFocus)(pm))
                return;
            var composing = pm.input.composing;
            if (!composing) {
                if (e.data)
                    pm.input.startComposition(e.data.length, false);
                else
                    return;
            } else if (composing.applied) {
                return;
            }
            clearTimeout(pm.input.finishComposing);
            pm.operation.composing.ended = true;
            pm.input.finishComposing = window.setTimeout(function() {
                var composing = pm.input.composing;
                if (composing && composing.ended)
                    pm.input.applyComposition(true);
            }, 20);
        };
        handlers.input = function(pm) {
            if (!(0, _selection.hasFocus)(pm))
                return;
            var composing = pm.input.composing;
            if (composing) {
                if (composing.ended)
                    pm.input.applyComposition(true);
                return;
            }
            (0, _domchange.readInputChange)(pm);
            pm.flush();
        };
        function toClipboard(doc, from, to, dataTransfer) {
            var slice = doc.slice(from, to),
                $from = doc.resolve(from);
            var parent = $from.node($from.depth - slice.openLeft);
            var attr = parent.type.name + " " + slice.openLeft + " " + slice.openRight;
            var html = "<div pm-context=\"" + attr + "\">" + (0, _format.toHTML)(slice.content) + "</div>";
            dataTransfer.clearData();
            dataTransfer.setData("text/html", html);
            dataTransfer.setData("text/plain", (0, _format.toText)(slice.content));
            return slice;
        }
        var cachedCanUpdateClipboard = null;
        function canUpdateClipboard(dataTransfer) {
            if (cachedCanUpdateClipboard != null)
                return cachedCanUpdateClipboard;
            dataTransfer.setData("text/html", "<hr>");
            return cachedCanUpdateClipboard = dataTransfer.getData("text/html") == "<hr>";
        }
        function fromClipboard(pm, dataTransfer, plainText) {
            var txt = dataTransfer.getData("text/plain");
            var html = dataTransfer.getData("text/html");
            if (!html && !txt)
                return null;
            var doc = undefined,
                slice = undefined;
            if ((plainText || !html) && txt) {
                doc = (0, _format.parseFrom)(pm.schema, pm.signalPipelined("transformPastedText", txt), "text");
            } else {
                var dom = document.createElement("div");
                dom.innerHTML = pm.signalPipelined("transformPastedHTML", html);
                var wrap = dom.querySelector("[pm-context]"),
                    context = undefined,
                    contextNodeType = undefined,
                    found = undefined;
                if (wrap && (context = /^(\w+) (\d+) (\d+)$/.exec(wrap.getAttribute("pm-context"))) && (contextNodeType = pm.schema.nodes[context[1]]) && contextNodeType.defaultAttrs && (found = parseFromContext(wrap, contextNodeType, +context[2], +context[3])))
                    slice = found;
                else
                    doc = (0, _format.fromDOM)(pm.schema, dom);
            }
            if (!slice)
                slice = doc.slice((0, _selection.findSelectionAtStart)(doc).from, (0, _selection.findSelectionAtEnd)(doc).to);
            return pm.signalPipelined("transformPasted", slice);
        }
        function parseFromContext(dom, contextNodeType, openLeft, openRight) {
            var schema = contextNodeType.schema,
                contextNode = contextNodeType.create();
            var parsed = (0, _format.fromDOM)(schema, dom, {
                topNode: contextNode,
                preserveWhitespace: true
            });
            return new _model.Slice(parsed.content, clipOpen(parsed.content, openLeft, true), clipOpen(parsed.content, openRight, false), contextNode);
        }
        function clipOpen(fragment, max, start) {
            for (var i = 0; i < max; i++) {
                var node = start ? fragment.firstChild : fragment.lastChild;
                if (!node || node.type.contains == null)
                    return i;
                fragment = node.content;
            }
            return max;
        }
        handlers.copy = handlers.cut = function(pm, e) {
            var _pm$selection2 = pm.selection;
            var from = _pm$selection2.from;
            var to = _pm$selection2.to;
            var empty = _pm$selection2.empty;
            if (empty || !e.clipboardData || !canUpdateClipboard(e.clipboardData))
                return;
            toClipboard(pm.doc, from, to, e.clipboardData);
            e.preventDefault();
            if (e.type == "cut" && !empty)
                pm.tr.delete(from, to).apply();
        };
        handlers.paste = function(pm, e) {
            if (!(0, _selection.hasFocus)(pm))
                return;
            if (!e.clipboardData)
                return;
            var sel = pm.selection;
            var slice = fromClipboard(pm, e.clipboardData, pm.input.shiftKey);
            if (slice) {
                e.preventDefault();
                pm.tr.replace(sel.from, sel.to, slice).apply(pm.apply.scroll);
            }
        };
        var Dragging = function Dragging(slice, from, to) {
            _classCallCheck(this, Dragging);
            this.slice = slice;
            this.from = from;
            this.to = to;
        };
        function dropPos(pm, e, slice) {
            var pos = pm.posAtCoords({
                left: e.clientX,
                top: e.clientY
            });
            if (pos == null || !slice || !slice.content.size)
                return pos;
            var $pos = pm.doc.resolve(pos),
                kind = slice.content.leastSuperKind();
            for (var d = $pos.depth; d >= 0; d--) {
                if (kind.isSubKind($pos.node(d).type.contains)) {
                    if (d == $pos.depth)
                        return pos;
                    if (pos <= ($pos.start(d + 1) + $pos.end(d + 1)) / 2)
                        return $pos.before(d + 1);
                    return $pos.after(d + 1);
                }
            }
            return pos;
        }
        function removeDropTarget(pm) {
            if (pm.input.dropTarget) {
                pm.wrapper.removeChild(pm.input.dropTarget);
                pm.input.dropTarget = null;
            }
        }
        handlers.dragstart = function(pm, e) {
            var mouseDown = pm.input.mouseDown;
            if (mouseDown)
                mouseDown.done();
            if (!e.dataTransfer)
                return;
            var _pm$selection3 = pm.selection;
            var from = _pm$selection3.from;
            var to = _pm$selection3.to;
            var empty = _pm$selection3.empty;
            var dragging = undefined;
            var pos = !empty && pm.posAtCoords({
                    left: e.clientX,
                    top: e.clientY
                });
            if (pos != null && pos >= from && pos <= to) {
                dragging = {
                    from: from,
                    to: to
                };
            } else if (mouseDown && mouseDown.mightDrag != null) {
                var _pos = mouseDown.mightDrag;
                dragging = {
                    from: _pos,
                    to: _pos + pm.doc.nodeAt(_pos).nodeSize
                };
            }
            if (dragging) {
                var slice = toClipboard(pm.doc, dragging.from, dragging.to, e.dataTransfer);
                pm.input.dragging = new Dragging(slice, dragging.from, dragging.to);
            }
        };
        handlers.dragend = function(pm) {
            return window.setTimeout(function() {
                return pm.input.dragging = null;
            }, 50);
        };
        handlers.dragover = handlers.dragenter = function(pm, e) {
            e.preventDefault();
            var target = pm.input.dropTarget;
            if (!target)
                target = pm.input.dropTarget = pm.wrapper.appendChild((0, _dom.elt)("div", {class: "ProseMirror-drop-target"}));
            var pos = dropPos(pm, e, pm.input.dragging && pm.input.dragging.slice);
            if (pos == null)
                return;
            var coords = pm.coordsAtPos(pos);
            var rect = pm.wrapper.getBoundingClientRect();
            coords.top -= rect.top;
            coords.right -= rect.left;
            coords.bottom -= rect.top;
            coords.left -= rect.left;
            target.style.left = coords.left - 1 + "px";
            target.style.top = coords.top + "px";
            target.style.height = coords.bottom - coords.top + "px";
        };
        handlers.dragleave = function(pm, e) {
            if (e.target == pm.content)
                removeDropTarget(pm);
        };
        handlers.drop = function(pm, e) {
            var dragging = pm.input.dragging;
            pm.input.dragging = null;
            removeDropTarget(pm);
            if (!e.dataTransfer || pm.signalDOM(e))
                return;
            var slice = dragging && dragging.slice || fromClipboard(pm, e.dataTransfer);
            if (slice) {
                e.preventDefault();
                var insertPos = dropPos(pm, e, slice),
                    start = insertPos;
                if (insertPos == null)
                    return;
                var tr = pm.tr;
                if (dragging && !e.ctrlKey && dragging.from != null) {
                    tr.delete(dragging.from, dragging.to);
                    insertPos = tr.map(insertPos);
                }
                tr.replace(insertPos, insertPos, slice).apply();
                var found = undefined;
                if (slice.content.childCount == 1 && slice.openLeft == 0 && slice.openRight == 0 && slice.content.child(0).type.selectable && (found = pm.doc.nodeAt(insertPos)) && found.sameMarkup(slice.content.child(0))) {
                    pm.setNodeSelection(insertPos);
                } else {
                    var left = (0, _selection.findSelectionNear)(pm.doc, insertPos, 1, true).from;
                    var right = (0, _selection.findSelectionNear)(pm.doc, tr.map(start), -1, true).to;
                    pm.setTextSelection(left, right);
                }
                pm.focus();
            }
        };
        handlers.focus = function(pm) {
            pm.wrapper.classList.add("ProseMirror-focused");
            pm.signal("focus");
        };
        handlers.blur = function(pm) {
            pm.wrapper.classList.remove("ProseMirror-focused");
            pm.signal("blur");
        };
        return module.exports;
    });

    $__System.registerDynamic("18", ["19"], true, function($__require, exports, module) {
        "use strict";
        ;
        var define,
            global = this,
            GLOBAL = this;
        Object.defineProperty(exports, "__esModule", {value: true});
        exports.History = undefined;
        var _createClass = function() {
            function defineProperties(target, props) {
                for (var i = 0; i < props.length; i++) {
                    var descriptor = props[i];
                    descriptor.enumerable = descriptor.enumerable || false;
                    descriptor.configurable = true;
                    if ("value" in descriptor)
                        descriptor.writable = true;
                    Object.defineProperty(target, descriptor.key, descriptor);
                }
            }
            return function(Constructor, protoProps, staticProps) {
                if (protoProps)
                    defineProperties(Constructor.prototype, protoProps);
                if (staticProps)
                    defineProperties(Constructor, staticProps);
                return Constructor;
            };
        }();
        var _transform = $__require('19');
        function _possibleConstructorReturn(self, call) {
            if (!self) {
                throw new ReferenceError("this hasn't been initialised - super() hasn't been called");
            }
            return call && (typeof call === "object" || typeof call === "function") ? call : self;
        }
        function _inherits(subClass, superClass) {
            if (typeof superClass !== "function" && superClass !== null) {
                throw new TypeError("Super expression must either be null or a function, not " + typeof superClass);
            }
            subClass.prototype = Object.create(superClass && superClass.prototype, {constructor: {
                value: subClass,
                enumerable: false,
                writable: true,
                configurable: true
            }});
            if (superClass)
                Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass;
        }
        function _classCallCheck(instance, Constructor) {
            if (!(instance instanceof Constructor)) {
                throw new TypeError("Cannot call a class as a function");
            }
        }
        var max_empty_items = 500;
        var Branch = function() {
            function Branch(maxEvents) {
                _classCallCheck(this, Branch);
                this.events = 0;
                this.maxEvents = maxEvents;
                this.items = [new Item()];
            }
            _createClass(Branch, [{
                key: "popEvent",
                value: function popEvent(doc, preserveItems, upto) {
                    var preserve = preserveItems,
                        transform = new _transform.Transform(doc);
                    var remap = new BranchRemapping();
                    var selection = undefined,
                        ids = [],
                        i = this.items.length;
                    for (; ; ) {
                        var cur = this.items[--i];
                        if (upto && cur == upto)
                            break;
                        if (!cur.map)
                            return null;
                        if (!cur.step) {
                            remap.add(cur);
                            preserve = true;
                            continue;
                        }
                        if (preserve) {
                            var step = cur.step.map(remap.remap),
                                map = undefined;
                            this.items[i] = new MapItem(cur.map);
                            if (step && transform.maybeStep(step).doc) {
                                map = transform.maps[transform.maps.length - 1];
                                this.items.push(new MapItem(map, this.items[i].id));
                            }
                            remap.movePastStep(cur, map);
                        } else {
                            this.items.pop();
                            transform.maybeStep(cur.step);
                        }
                        ids.push(cur.id);
                        if (cur.selection) {
                            this.events--;
                            if (!upto) {
                                selection = cur.selection.type.mapToken(cur.selection, remap.remap);
                                break;
                            }
                        }
                    }
                    return {
                        transform: transform,
                        selection: selection,
                        ids: ids
                    };
                }
            }, {
                key: "clear",
                value: function clear() {
                    this.items.length = 1;
                    this.events = 0;
                }
            }, {
                key: "addTransform",
                value: function addTransform(transform, selection, ids) {
                    for (var i = 0; i < transform.steps.length; i++) {
                        var step = transform.steps[i].invert(transform.docs[i]);
                        this.items.push(new StepItem(transform.maps[i], ids && ids[i], step, selection));
                        if (selection) {
                            this.events++;
                            selection = null;
                        }
                    }
                    if (this.events > this.maxEvents)
                        this.clip();
                }
            }, {
                key: "clip",
                value: function clip() {
                    var seen = 0,
                        toClip = this.events - this.maxEvents;
                    for (var i = 0; ; i++) {
                        var cur = this.items[i];
                        if (cur.selection) {
                            if (seen < toClip) {
                                ++seen;
                            } else {
                                this.items.splice(0, i, new Item(null, this.events[toClip - 1]));
                                this.events = this.maxEvents;
                                return;
                            }
                        }
                    }
                }
            }, {
                key: "addMaps",
                value: function addMaps(array) {
                    if (this.events == 0)
                        return;
                    for (var i = 0; i < array.length; i++) {
                        this.items.push(new MapItem(array[i]));
                    }
                }
            }, {
                key: "findChangeID",
                value: function findChangeID(id) {
                    if (id == this.items[0].id)
                        return this.items[0];
                    for (var i = this.items.length - 1; i >= 0; i--) {
                        var cur = this.items[i];
                        if (cur.step) {
                            if (cur.id == id)
                                return cur;
                            if (cur.id < id)
                                return null;
                        }
                    }
                }
            }, {
                key: "rebased",
                value: function rebased(newMaps, rebasedTransform, positions) {
                    if (this.events == 0)
                        return;
                    var rebasedItems = [],
                        start = this.items.length - positions.length,
                        startPos = 0;
                    if (start < 1) {
                        startPos = 1 - start;
                        start = 1;
                        this.items[0] = new Item();
                    }
                    if (positions.length) {
                        var remap = new _transform.Remapping([], newMaps.slice());
                        for (var iItem = start,
                                 iPosition = startPos; iItem < this.items.length; iItem++) {
                            var item = this.items[iItem],
                                pos = positions[iPosition++],
                                id = undefined;
                            if (pos != -1) {
                                var map = rebasedTransform.maps[pos];
                                if (item.step) {
                                    var step = rebasedTransform.steps[pos].invert(rebasedTransform.docs[pos]);
                                    var selection = item.selection && item.selection.type.mapToken(item.selection, remap);
                                    rebasedItems.push(new StepItem(map, item.id, step, selection));
                                } else {
                                    rebasedItems.push(new MapItem(map));
                                }
                                id = remap.addToBack(map);
                            }
                            remap.addToFront(item.map.invert(), id);
                        }
                        this.items.length = start;
                    }
                    for (var i = 0; i < newMaps.length; i++) {
                        this.items.push(new MapItem(newMaps[i]));
                    }
                    for (var i = 0; i < rebasedItems.length; i++) {
                        this.items.push(rebasedItems[i]);
                    }
                    if (!this.compressing && this.emptyItems(start) + newMaps.length > max_empty_items)
                        this.compress(start + newMaps.length);
                }
            }, {
                key: "emptyItems",
                value: function emptyItems(upto) {
                    var count = 0;
                    for (var i = 1; i < upto; i++) {
                        if (!this.items[i].step)
                            count++;
                    }
                    return count;
                }
            }, {
                key: "compress",
                value: function compress(upto) {
                    var remap = new BranchRemapping();
                    var items = [],
                        events = 0;
                    for (var i = this.items.length - 1; i >= 0; i--) {
                        var item = this.items[i];
                        if (i >= upto) {
                            items.push(item);
                        } else if (item.step) {
                            var step = item.step.map(remap.remap),
                                map = step && step.posMap();
                            remap.movePastStep(item, map);
                            if (step) {
                                var selection = item.selection && item.selection.type.mapToken(item.selection, remap.remap);
                                items.push(new StepItem(map.invert(), item.id, step, selection));
                                if (selection)
                                    events++;
                            }
                        } else if (item.map) {
                            remap.add(item);
                        } else {
                            items.push(item);
                        }
                    }
                    this.items = items.reverse();
                    this.events = events;
                }
            }, {
                key: "toString",
                value: function toString() {
                    return this.items.join("\n");
                }
            }, {
                key: "changeID",
                get: function get() {
                    for (var i = this.items.length - 1; i > 0; i--) {
                        if (this.items[i].step)
                            return this.items[i].id;
                    }
                    return this.items[0].id;
                }
            }]);
            return Branch;
        }();
        var nextID = 1;
        var Item = function() {
            function Item(map, id) {
                _classCallCheck(this, Item);
                this.map = map;
                this.id = id || nextID++;
            }
            _createClass(Item, [{
                key: "toString",
                value: function toString() {
                    return this.id + ":" + (this.map || "") + (this.step ? ":" + this.step : "") + (this.mirror != null ? "->" + this.mirror : "");
                }
            }]);
            return Item;
        }();
        var StepItem = function(_Item) {
            _inherits(StepItem, _Item);
            function StepItem(map, id, step, selection) {
                _classCallCheck(this, StepItem);
                var _this = _possibleConstructorReturn(this, Object.getPrototypeOf(StepItem).call(this, map, id));
                _this.step = step;
                _this.selection = selection;
                return _this;
            }
            return StepItem;
        }(Item);
        var MapItem = function(_Item2) {
            _inherits(MapItem, _Item2);
            function MapItem(map, mirror) {
                _classCallCheck(this, MapItem);
                var _this2 = _possibleConstructorReturn(this, Object.getPrototypeOf(MapItem).call(this, map));
                _this2.mirror = mirror;
                return _this2;
            }
            return MapItem;
        }(Item);
        var BranchRemapping = function() {
            function BranchRemapping() {
                _classCallCheck(this, BranchRemapping);
                this.remap = new _transform.Remapping();
                this.mirrorBuffer = Object.create(null);
            }
            _createClass(BranchRemapping, [{
                key: "add",
                value: function add(item) {
                    var id = this.remap.addToFront(item.map, this.mirrorBuffer[item.id]);
                    if (item.mirror != null)
                        this.mirrorBuffer[item.mirror] = id;
                    return id;
                }
            }, {
                key: "movePastStep",
                value: function movePastStep(item, map) {
                    var id = this.add(item);
                    if (map)
                        this.remap.addToBack(map, id);
                }
            }]);
            return BranchRemapping;
        }();
        var History = exports.History = function() {
            function History(pm) {
                _classCallCheck(this, History);
                this.pm = pm;
                this.done = new Branch(pm.options.historyDepth);
                this.undone = new Branch(pm.options.historyDepth);
                this.lastAddedAt = 0;
                this.ignoreTransform = false;
                this.preserveItems = 0;
                pm.on("transform", this.recordTransform.bind(this));
            }
            _createClass(History, [{
                key: "recordTransform",
                value: function recordTransform(transform, selection, options) {
                    if (this.ignoreTransform)
                        return;
                    if (options.addToHistory == false) {
                        this.done.addMaps(transform.maps);
                        this.undone.addMaps(transform.maps);
                    } else {
                        var now = Date.now();
                        var newGroup = now > this.lastAddedAt + this.pm.options.historyEventDelay;
                        this.done.addTransform(transform, newGroup ? selection.token : null);
                        this.undone.clear();
                        this.lastAddedAt = now;
                    }
                }
            }, {
                key: "undo",
                value: function undo() {
                    return this.shift(this.done, this.undone);
                }
            }, {
                key: "redo",
                value: function redo() {
                    return this.shift(this.undone, this.done);
                }
            }, {
                key: "shift",
                value: function shift(from, to) {
                    var pop = from.popEvent(this.pm.doc, this.preserveItems > 0);
                    if (!pop)
                        return false;
                    var selectionBeforeTransform = this.pm.selection;
                    if (!pop.transform.steps.length)
                        return this.shift(from, to);
                    var selection = pop.selection.type.fromToken(pop.selection, pop.transform.doc);
                    this.applyIgnoring(pop.transform, selection);
                    to.addTransform(pop.transform, selectionBeforeTransform.token, pop.ids);
                    this.lastAddedAt = 0;
                    return true;
                }
            }, {
                key: "applyIgnoring",
                value: function applyIgnoring(transform, selection) {
                    this.ignoreTransform = true;
                    this.pm.apply(transform, {
                        selection: selection,
                        filter: false
                    });
                    this.ignoreTransform = false;
                }
            }, {
                key: "getVersion",
                value: function getVersion() {
                    return this.done.changeID;
                }
            }, {
                key: "isAtVersion",
                value: function isAtVersion(version) {
                    return this.done.changeID == version;
                }
            }, {
                key: "backToVersion",
                value: function backToVersion(version) {
                    var found = this.done.findChangeID(version);
                    if (!found)
                        return false;
                    var _done$popEvent = this.done.popEvent(this.pm.doc, this.preserveItems > 0, found);
                    var transform = _done$popEvent.transform;
                    this.applyIgnoring(transform);
                    this.undone.clear();
                    return true;
                }
            }, {
                key: "rebased",
                value: function rebased(newMaps, rebasedTransform, positions) {
                    this.done.rebased(newMaps, rebasedTransform, positions);
                    this.undone.rebased(newMaps, rebasedTransform, positions);
                }
            }, {
                key: "undoDepth",
                get: function get() {
                    return this.done.events;
                }
            }, {
                key: "redoDepth",
                get: function get() {
                    return this.undone.events;
                }
            }]);
            return History;
        }();
        return module.exports;
    });

    $__System.registerDynamic("1a", ["19"], true, function($__require, exports, module) {
        "use strict";
        ;
        var define,
            global = this,
            GLOBAL = this;
        Object.defineProperty(exports, "__esModule", {value: true});
        exports.EditorTransform = undefined;
        var _createClass = function() {
            function defineProperties(target, props) {
                for (var i = 0; i < props.length; i++) {
                    var descriptor = props[i];
                    descriptor.enumerable = descriptor.enumerable || false;
                    descriptor.configurable = true;
                    if ("value" in descriptor)
                        descriptor.writable = true;
                    Object.defineProperty(target, descriptor.key, descriptor);
                }
            }
            return function(Constructor, protoProps, staticProps) {
                if (protoProps)
                    defineProperties(Constructor.prototype, protoProps);
                if (staticProps)
                    defineProperties(Constructor, staticProps);
                return Constructor;
            };
        }();
        var _transform = $__require('19');
        function _classCallCheck(instance, Constructor) {
            if (!(instance instanceof Constructor)) {
                throw new TypeError("Cannot call a class as a function");
            }
        }
        function _possibleConstructorReturn(self, call) {
            if (!self) {
                throw new ReferenceError("this hasn't been initialised - super() hasn't been called");
            }
            return call && (typeof call === "object" || typeof call === "function") ? call : self;
        }
        function _inherits(subClass, superClass) {
            if (typeof superClass !== "function" && superClass !== null) {
                throw new TypeError("Super expression must either be null or a function, not " + typeof superClass);
            }
            subClass.prototype = Object.create(superClass && superClass.prototype, {constructor: {
                value: subClass,
                enumerable: false,
                writable: true,
                configurable: true
            }});
            if (superClass)
                Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass;
        }
        var EditorTransform = exports.EditorTransform = function(_Transform) {
            _inherits(EditorTransform, _Transform);
            function EditorTransform(pm) {
                _classCallCheck(this, EditorTransform);
                var _this = _possibleConstructorReturn(this, Object.getPrototypeOf(EditorTransform).call(this, pm.doc));
                _this.pm = pm;
                return _this;
            }
            _createClass(EditorTransform, [{
                key: "apply",
                value: function apply(options) {
                    return this.pm.apply(this, options);
                }
            }, {
                key: "replaceSelection",
                value: function replaceSelection(node, inheritMarks) {
                    var _selection = this.selection;
                    var empty = _selection.empty;
                    var from = _selection.from;
                    var to = _selection.to;
                    var selNode = _selection.node;
                    if (node && node.isInline && inheritMarks !== false)
                        node = node.mark(empty ? this.pm.input.storedMarks : this.doc.marksAt(from));
                    if (selNode && selNode.isTextblock && node && node.isInline) {
                        from++;
                        to--;
                    } else if (selNode) {
                        var $from = this.doc.resolve(from),
                            depth = $from.depth;
                        while (depth && $from.node(depth).childCount == 1 && !(node ? $from.node(depth).type.canContain(node) : $from.node(depth).type.canBeEmpty)) {
                            depth--;
                        }
                        if (depth < $from.depth) {
                            from = $from.before(depth + 1);
                            to = $from.after(depth + 1);
                        }
                    } else if (node && node.isBlock) {
                        var $from = this.doc.resolve(from);
                        if ($from.depth && $from.node($from.depth - 1).type.canContain(node)) {
                            this.delete(from, to);
                            if ($from.parentOffset && $from.parentOffset < $from.parent.content.size)
                                this.split(from);
                            return this.insert(from + ($from.parentOffset ? 1 : -1), node);
                        }
                    }
                    return this.replaceWith(from, to, node);
                }
            }, {
                key: "deleteSelection",
                value: function deleteSelection() {
                    return this.replaceSelection();
                }
            }, {
                key: "typeText",
                value: function typeText(text) {
                    return this.replaceSelection(this.pm.schema.text(text), true);
                }
            }, {
                key: "selection",
                get: function get() {
                    return this.steps.length ? this.pm.selection.map(this) : this.pm.selection;
                }
            }]);
            return EditorTransform;
        }(_transform.Transform);
        return module.exports;
    });

    $__System.registerDynamic("10", ["c", "14", "1b", "d", "1c", "8", "f", "1d", "13", "11", "e", "17", "18", "1e", "1a"], true, function($__require, exports, module) {
        "use strict";
        ;
        var define,
            global = this,
            GLOBAL = this;
        Object.defineProperty(exports, "__esModule", {value: true});
        exports.DIRTY_REDRAW = exports.DIRTY_RESCAN = exports.ProseMirror = undefined;
        var _createClass = function() {
            function defineProperties(target, props) {
                for (var i = 0; i < props.length; i++) {
                    var descriptor = props[i];
                    descriptor.enumerable = descriptor.enumerable || false;
                    descriptor.configurable = true;
                    if ("value" in descriptor)
                        descriptor.writable = true;
                    Object.defineProperty(target, descriptor.key, descriptor);
                }
            }
            return function(Constructor, protoProps, staticProps) {
                if (protoProps)
                    defineProperties(Constructor.prototype, protoProps);
                if (staticProps)
                    defineProperties(Constructor, staticProps);
                return Constructor;
            };
        }();
        $__require('c');
        var _browserkeymap = $__require('14');
        var _browserkeymap2 = _interopRequireDefault(_browserkeymap);
        var _sortedinsert = $__require('1b');
        var _sortedinsert2 = _interopRequireDefault(_sortedinsert);
        var _map = $__require('d');
        var _event = $__require('1c');
        var _dom = $__require('8');
        var _format = $__require('f');
        var _options = $__require('1d');
        var _selection = $__require('13');
        var _dompos = $__require('11');
        var _draw = $__require('e');
        var _input = $__require('17');
        var _history = $__require('18');
        var _range = $__require('1e');
        var _transform = $__require('1a');
        function _interopRequireDefault(obj) {
            return obj && obj.__esModule ? obj : {default: obj};
        }
        function _classCallCheck(instance, Constructor) {
            if (!(instance instanceof Constructor)) {
                throw new TypeError("Cannot call a class as a function");
            }
        }
        var ProseMirror = exports.ProseMirror = function() {
            function ProseMirror(opts) {
                _classCallCheck(this, ProseMirror);
                (0, _dom.ensureCSSAdded)();
                opts = this.options = (0, _options.parseOptions)(opts);
                this.schema = opts.schema;
                if (opts.doc == null)
                    opts.doc = this.schema.node("doc", null, [this.schema.node("paragraph")]);
                this.content = (0, _dom.elt)("div", {
                    class: "ProseMirror-content",
                    "pm-container": true
                });
                this.wrapper = (0, _dom.elt)("div", {class: "ProseMirror"}, this.content);
                this.wrapper.ProseMirror = this;
                if (opts.place && opts.place.appendChild)
                    opts.place.appendChild(this.wrapper);
                else if (opts.place)
                    opts.place(this.wrapper);
                this.setDocInner(opts.docFormat ? (0, _format.parseFrom)(this.schema, opts.doc, opts.docFormat) : opts.doc);
                (0, _draw.draw)(this, this.doc);
                this.content.contentEditable = true;
                if (opts.label)
                    this.content.setAttribute("aria-label", opts.label);
                this.mod = Object.create(null);
                this.cached = Object.create(null);
                this.operation = null;
                this.dirtyNodes = new _map.Map();
                this.flushScheduled = null;
                this.sel = new _selection.SelectionState(this, (0, _selection.findSelectionAtStart)(this.doc));
                this.accurateSelection = false;
                this.input = new _input.Input(this);
                this.commands = null;
                this.commandKeys = null;
                (0, _options.initOptions)(this);
            }
            _createClass(ProseMirror, [{
                key: "setOption",
                value: function setOption(name, value) {
                    (0, _options.setOption)(this, name, value);
                    this.signal("optionChanged", name, value);
                }
            }, {
                key: "getOption",
                value: function getOption(name) {
                    return this.options[name];
                }
            }, {
                key: "setTextSelection",
                value: function setTextSelection(anchor) {
                    var head = arguments.length <= 1 || arguments[1] === undefined ? anchor : arguments[1];
                    this.checkPos(head, true);
                    if (anchor != head)
                        this.checkPos(anchor, true);
                    this.setSelection(new _selection.TextSelection(anchor, head));
                }
            }, {
                key: "setNodeSelection",
                value: function setNodeSelection(pos) {
                    this.checkPos(pos, false);
                    var node = this.doc.nodeAt(pos);
                    if (!node)
                        throw new RangeError("Trying to set a node selection that doesn't point at a node");
                    if (!node.type.selectable)
                        throw new RangeError("Trying to select a non-selectable node");
                    this.setSelection(new _selection.NodeSelection(pos, pos + node.nodeSize, node));
                }
            }, {
                key: "setSelection",
                value: function setSelection(selection) {
                    this.ensureOperation();
                    if (!selection.eq(this.sel.range))
                        this.sel.setAndSignal(selection);
                }
            }, {
                key: "setContent",
                value: function setContent(value, format) {
                    if (format)
                        value = (0, _format.parseFrom)(this.schema, value, format);
                    this.setDoc(value);
                }
            }, {
                key: "getContent",
                value: function getContent(format) {
                    return format ? (0, _format.serializeTo)(this.doc, format) : this.doc;
                }
            }, {
                key: "setDocInner",
                value: function setDocInner(doc) {
                    if (doc.type != this.schema.nodes.doc)
                        throw new RangeError("Trying to set a document with a different schema");
                    this.doc = doc;
                    this.ranges = new _range.RangeStore(this);
                    this.history = new _history.History(this);
                }
            }, {
                key: "setDoc",
                value: function setDoc(doc, sel) {
                    if (!sel)
                        sel = (0, _selection.findSelectionAtStart)(doc);
                    this.signal("beforeSetDoc", doc, sel);
                    this.ensureOperation();
                    this.setDocInner(doc);
                    this.operation.docSet = true;
                    this.sel.set(sel, true);
                    this.signal("setDoc", doc, sel);
                }
            }, {
                key: "updateDoc",
                value: function updateDoc(doc, mapping, selection) {
                    this.ensureOperation();
                    this.ranges.transform(mapping);
                    this.operation.mappings.push(mapping);
                    this.doc = doc;
                    this.sel.setAndSignal(selection || this.sel.range.map(doc, mapping));
                    this.signal("change");
                }
            }, {
                key: "apply",
                value: function apply(transform) {
                    var options = arguments.length <= 1 || arguments[1] === undefined ? nullOptions : arguments[1];
                    if (!transform.steps.length)
                        return false;
                    if (!transform.docs[0].eq(this.doc))
                        throw new RangeError("Applying a transform that does not start with the current document");
                    if (options.filter !== false && this.signalHandleable("filterTransform", transform))
                        return false;
                    var selectionBeforeTransform = this.selection;
                    this.signal("beforeTransform", transform, options);
                    this.updateDoc(transform.doc, transform, options.selection);
                    this.signal("transform", transform, selectionBeforeTransform, options);
                    if (options.scrollIntoView)
                        this.scrollIntoView();
                    return transform;
                }
            }, {
                key: "checkPos",
                value: function checkPos(pos, textblock) {
                    var valid = pos >= 0 && pos <= this.doc.content.size;
                    if (valid && textblock)
                        valid = this.doc.resolve(pos).parent.isTextblock;
                    if (!valid)
                        throw new RangeError("Position " + pos + " is not valid in current document");
                }
            }, {
                key: "ensureOperation",
                value: function ensureOperation(options) {
                    return this.operation || this.startOperation(options);
                }
            }, {
                key: "startOperation",
                value: function startOperation(options) {
                    var _this = this;
                    this.operation = new Operation(this);
                    if (!(options && options.readSelection === false) && this.sel.readFromDOM())
                        this.operation.sel = this.sel.range;
                    if (this.flushScheduled == null)
                        this.flushScheduled = (0, _dom.requestAnimationFrame)(function() {
                            return _this.flush();
                        });
                    return this.operation;
                }
            }, {
                key: "unscheduleFlush",
                value: function unscheduleFlush() {
                    if (this.flushScheduled != null) {
                        (0, _dom.cancelAnimationFrame)(this.flushScheduled);
                        this.flushScheduled = null;
                    }
                }
            }, {
                key: "flush",
                value: function flush() {
                    this.unscheduleFlush();
                    if (!document.body.contains(this.wrapper) || !this.operation)
                        return false;
                    this.signal("flushing");
                    var op = this.operation,
                        redrawn = false;
                    if (!op)
                        return false;
                    if (op.composing)
                        this.input.applyComposition();
                    this.operation = null;
                    this.accurateSelection = true;
                    if (op.doc != this.doc || this.dirtyNodes.size) {
                        (0, _draw.redraw)(this, this.dirtyNodes, this.doc, op.doc);
                        this.dirtyNodes.clear();
                        redrawn = true;
                    }
                    if (redrawn || !op.sel.eq(this.sel.range) || op.focus)
                        this.sel.toDOM(op.focus);
                    if (op.scrollIntoView !== false)
                        (0, _dompos.scrollIntoView)(this, op.scrollIntoView);
                    if (redrawn)
                        this.signal("draw");
                    this.signal("flush");
                    this.accurateSelection = false;
                    return redrawn;
                }
            }, {
                key: "addKeymap",
                value: function addKeymap(map) {
                    var rank = arguments.length <= 1 || arguments[1] === undefined ? 50 : arguments[1];
                    (0, _sortedinsert2.default)(this.input.keymaps, {
                        map: map,
                        rank: rank
                    }, function(a, b) {
                        return a.rank - b.rank;
                    });
                }
            }, {
                key: "removeKeymap",
                value: function removeKeymap(map) {
                    var maps = this.input.keymaps;
                    for (var i = 0; i < maps.length; ++i) {
                        if (maps[i].map == map || maps[i].map.options.name == map) {
                            maps.splice(i, 1);
                            return true;
                        }
                    }
                }
            }, {
                key: "markRange",
                value: function markRange(from, to, options) {
                    this.checkPos(from);
                    this.checkPos(to);
                    var range = new _range.MarkedRange(from, to, options);
                    this.ranges.addRange(range);
                    return range;
                }
            }, {
                key: "removeRange",
                value: function removeRange(range) {
                    this.ranges.removeRange(range);
                }
            }, {
                key: "setMark",
                value: function setMark(type, to, attrs) {
                    var sel = this.selection;
                    if (sel.empty) {
                        var marks = this.activeMarks();
                        if (to == null)
                            to = !type.isInSet(marks);
                        if (to && !this.doc.resolve(sel.head).parent.type.canContainMark(type))
                            return;
                        this.input.storedMarks = to ? type.create(attrs).addToSet(marks) : type.removeFromSet(marks);
                        this.signal("activeMarkChange");
                    } else {
                        if (to != null ? to : !this.doc.rangeHasMark(sel.from, sel.to, type))
                            this.apply(this.tr.addMark(sel.from, sel.to, type.create(attrs)));
                        else
                            this.apply(this.tr.removeMark(sel.from, sel.to, type));
                    }
                }
            }, {
                key: "activeMarks",
                value: function activeMarks() {
                    var head;
                    return this.input.storedMarks || ((head = this.selection.head) != null ? this.doc.marksAt(head) : []);
                }
            }, {
                key: "focus",
                value: function focus() {
                    if (this.operation)
                        this.operation.focus = true;
                    else
                        this.sel.toDOM(true);
                }
            }, {
                key: "hasFocus",
                value: function hasFocus() {
                    if (this.sel.range instanceof _selection.NodeSelection)
                        return document.activeElement == this.content;
                    else
                        return (0, _selection.hasFocus)(this);
                }
            }, {
                key: "posAtCoords",
                value: function posAtCoords(coords) {
                    this.flush();
                    return (0, _dompos.posAtCoords)(this, coords);
                }
            }, {
                key: "coordsAtPos",
                value: function coordsAtPos(pos) {
                    this.checkPos(pos);
                    this.flush();
                    return (0, _dompos.coordsAtPos)(this, pos);
                }
            }, {
                key: "scrollIntoView",
                value: function scrollIntoView() {
                    var pos = arguments.length <= 0 || arguments[0] === undefined ? null : arguments[0];
                    if (pos)
                        this.checkPos(pos);
                    this.ensureOperation();
                    this.operation.scrollIntoView = pos;
                }
            }, {
                key: "execCommand",
                value: function execCommand(name, params) {
                    var cmd = this.commands[name];
                    return !!(cmd && cmd.exec(this, params) !== false);
                }
            }, {
                key: "keyForCommand",
                value: function keyForCommand(name) {
                    var cached = this.commandKeys[name];
                    if (cached !== undefined)
                        return cached;
                    var cmd = this.commands[name],
                        keymap = this.input.baseKeymap;
                    if (!cmd)
                        return this.commandKeys[name] = null;
                    var key = cmd.spec.key || (_dom.browser.mac ? cmd.spec.macKey : cmd.spec.pcKey);
                    if (key) {
                        key = _browserkeymap2.default.normalizeKeyName(Array.isArray(key) ? key[0] : key);
                        var deflt = keymap.bindings[key];
                        if (Array.isArray(deflt) ? deflt.indexOf(name) > -1 : deflt == name)
                            return this.commandKeys[name] = key;
                    }
                    for (var _key in keymap.bindings) {
                        var bound = keymap.bindings[_key];
                        if (Array.isArray(bound) ? bound.indexOf(name) > -1 : bound == name)
                            return this.commandKeys[name] = _key;
                    }
                    return this.commandKeys[name] = null;
                }
            }, {
                key: "markRangeDirty",
                value: function markRangeDirty(from, to) {
                    var doc = arguments.length <= 2 || arguments[2] === undefined ? this.doc : arguments[2];
                    this.ensureOperation();
                    var dirty = this.dirtyNodes;
                    var $from = doc.resolve(from),
                        $to = doc.resolve(to);
                    var same = $from.sameDepth($to);
                    for (var depth = 0; depth <= same; depth++) {
                        var child = $from.node(depth);
                        if (!dirty.has(child))
                            dirty.set(child, DIRTY_RESCAN);
                    }
                    var start = $from.index(same),
                        end = Math.max(start + 1, $to.index(same) + (same == $to.depth ? 0 : 1));
                    var parent = $from.node(same);
                    for (var i = start; i < end; i++) {
                        dirty.set(parent.child(i), DIRTY_REDRAW);
                    }
                }
            }, {
                key: "markAllDirty",
                value: function markAllDirty() {
                    this.dirtyNodes.set(this.doc, DIRTY_REDRAW);
                }
            }, {
                key: "translate",
                value: function translate(string) {
                    var trans = this.options.translate;
                    return trans ? trans(string) : string;
                }
            }, {
                key: "selection",
                get: function get() {
                    if (!this.accurateSelection)
                        this.ensureOperation();
                    return this.sel.range;
                }
            }, {
                key: "tr",
                get: function get() {
                    return new _transform.EditorTransform(this);
                }
            }]);
            return ProseMirror;
        }();
        ProseMirror.prototype.apply.scroll = {scrollIntoView: true};
        var DIRTY_RESCAN = exports.DIRTY_RESCAN = 1,
            DIRTY_REDRAW = exports.DIRTY_REDRAW = 2;
        var nullOptions = {};
        (0, _event.eventMixin)(ProseMirror);
        var Operation = function Operation(pm) {
            _classCallCheck(this, Operation);
            this.doc = pm.doc;
            this.docSet = false;
            this.sel = pm.sel.range;
            this.scrollIntoView = false;
            this.focus = false;
            this.mappings = [];
            this.composing = null;
        };
        return module.exports;
    });

    $__System.registerDynamic("1f", ["8"], true, function($__require, exports, module) {
        "use strict";
        ;
        var define,
            global = this,
            GLOBAL = this;
        Object.defineProperty(exports, "__esModule", {value: true});
        exports.ParamPrompt = undefined;
        var _createClass = function() {
            function defineProperties(target, props) {
                for (var i = 0; i < props.length; i++) {
                    var descriptor = props[i];
                    descriptor.enumerable = descriptor.enumerable || false;
                    descriptor.configurable = true;
                    if ("value" in descriptor)
                        descriptor.writable = true;
                    Object.defineProperty(target, descriptor.key, descriptor);
                }
            }
            return function(Constructor, protoProps, staticProps) {
                if (protoProps)
                    defineProperties(Constructor.prototype, protoProps);
                if (staticProps)
                    defineProperties(Constructor, staticProps);
                return Constructor;
            };
        }();
        exports.openPrompt = openPrompt;
        var _dom = $__require('8');
        function _classCallCheck(instance, Constructor) {
            if (!(instance instanceof Constructor)) {
                throw new TypeError("Cannot call a class as a function");
            }
        }
        var ParamPrompt = exports.ParamPrompt = function() {
            function ParamPrompt(pm, command) {
                var _this = this;
                _classCallCheck(this, ParamPrompt);
                this.pm = pm;
                this.command = command;
                this.doClose = null;
                this.fields = command.params.map(function(param) {
                    if (!(param.type in _this.paramTypes))
                        throw new RangeError("Unsupported parameter type: " + param.type);
                    return _this.paramTypes[param.type].render.call(_this.pm, param, _this.defaultValue(param));
                });
                var promptTitle = (0, _dom.elt)("h5", {}, command.spec && command.spec.label ? pm.translate(command.spec.label) : "");
                var submitButton = (0, _dom.elt)("button", {
                    type: "submit",
                    class: "ProseMirror-prompt-submit"
                }, "Ok");
                var cancelButton = (0, _dom.elt)("button", {
                    type: "button",
                    class: "ProseMirror-prompt-cancel"
                }, "Cancel");
                cancelButton.addEventListener("click", function() {
                    return _this.close();
                });
                this.form = (0, _dom.elt)("form", null, promptTitle, this.fields.map(function(f) {
                    return (0, _dom.elt)("div", null, f);
                }), (0, _dom.elt)("div", {class: "ProseMirror-prompt-buttons"}, submitButton, " ", cancelButton));
            }
            _createClass(ParamPrompt, [{
                key: "close",
                value: function close() {
                    if (this.doClose) {
                        this.doClose();
                        this.doClose = null;
                    }
                }
            }, {
                key: "open",
                value: function open() {
                    var _this2 = this;
                    this.close();
                    var prompt = this.prompt();
                    var hadFocus = this.pm.hasFocus();
                    this.doClose = function() {
                        prompt.close();
                        if (hadFocus)
                            setTimeout(function() {
                                return _this2.pm.focus();
                            }, 50);
                    };
                    var submit = function submit() {
                        var params = _this2.values();
                        if (params) {
                            _this2.close();
                            _this2.command.exec(_this2.pm, params);
                        }
                    };
                    this.form.addEventListener("submit", function(e) {
                        e.preventDefault();
                        submit();
                    });
                    this.form.addEventListener("keydown", function(e) {
                        if (e.keyCode == 27) {
                            e.preventDefault();
                            prompt.close();
                        } else if (e.keyCode == 13 && !(e.ctrlKey || e.metaKey || e.shiftKey)) {
                            e.preventDefault();
                            submit();
                        }
                    });
                    var input = this.form.querySelector("input, textarea");
                    if (input)
                        input.focus();
                }
            }, {
                key: "values",
                value: function values() {
                    var result = [];
                    for (var i = 0; i < this.command.params.length; i++) {
                        var param = this.command.params[i],
                            dom = this.fields[i];
                        var type = this.paramTypes[param.type],
                            value = undefined,
                            bad = undefined;
                        if (type.validate)
                            bad = type.validate(dom);
                        if (!bad) {
                            value = type.read.call(this.pm, dom);
                            if (param.validate)
                                bad = param.validate(value);
                            else if (!value && param.default == null)
                                bad = "No default value available";
                        }
                        if (bad) {
                            if (type.reportInvalid)
                                type.reportInvalid.call(this.pm, dom, bad);
                            else
                                this.reportInvalid(dom, bad);
                            return null;
                        }
                        result.push(value);
                    }
                    return result;
                }
            }, {
                key: "defaultValue",
                value: function defaultValue(param) {
                    if (param.prefill) {
                        var prefill = param.prefill.call(this.command.self, this.pm);
                        if (prefill != null)
                            return prefill;
                    }
                    return param.default;
                }
            }, {
                key: "prompt",
                value: function prompt() {
                    var _this3 = this;
                    return openPrompt(this.pm, this.form, {onClose: function onClose() {
                        return _this3.close();
                    }});
                }
            }, {
                key: "reportInvalid",
                value: function reportInvalid(dom, message) {
                    var parent = dom.parentNode;
                    var style = "left: " + (dom.offsetLeft + dom.offsetWidth + 2) + "px; top: " + (dom.offsetTop - 5) + "px";
                    var msg = parent.appendChild((0, _dom.elt)("div", {
                        class: "ProseMirror-invalid",
                        style: style
                    }, message));
                    setTimeout(function() {
                        return parent.removeChild(msg);
                    }, 1500);
                }
            }]);
            return ParamPrompt;
        }();
        ParamPrompt.prototype.paramTypes = Object.create(null);
        ParamPrompt.prototype.paramTypes.text = {
            render: function render(param, value) {
                return (0, _dom.elt)("input", {
                    type: "text",
                    placeholder: this.translate(param.label),
                    value: value,
                    autocomplete: "off"
                });
            },
            read: function read(dom) {
                return dom.value;
            }
        };
        ParamPrompt.prototype.paramTypes.select = {
            render: function render(param, value) {
                var _this4 = this;
                var options = param.options.call ? param.options(this) : param.options;
                return (0, _dom.elt)("select", null, options.map(function(o) {
                    return (0, _dom.elt)("option", {
                        value: o.value,
                        selected: o.value == value ? "true" : null
                    }, _this4.translate(o.label));
                }));
            },
            read: function read(dom) {
                return dom.value;
            }
        };
        function openPrompt(pm, content, options) {
            var button = (0, _dom.elt)("button", {class: "ProseMirror-prompt-close"});
            var wrapper = (0, _dom.elt)("div", {class: "ProseMirror-prompt"}, content, button);
            var outerBox = pm.wrapper.getBoundingClientRect();
            pm.wrapper.appendChild(wrapper);
            if (options && options.pos) {
                wrapper.style.left = options.pos.left - outerBox.left + "px";
                wrapper.style.top = options.pos.top - outerBox.top + "px";
            } else {
                var blockBox = wrapper.getBoundingClientRect();
                var cX = Math.max(0, outerBox.left) + Math.min(window.innerWidth, outerBox.right) - blockBox.width;
                var cY = Math.max(0, outerBox.top) + Math.min(window.innerHeight, outerBox.bottom) - blockBox.height;
                wrapper.style.left = cX / 2 - outerBox.left + "px";
                wrapper.style.top = cY / 2 - outerBox.top + "px";
            }
            var close = function close() {
                pm.off("interaction", close);
                if (wrapper.parentNode) {
                    wrapper.parentNode.removeChild(wrapper);
                    if (options && options.onClose)
                        options.onClose();
                }
            };
            button.addEventListener("click", close);
            pm.on("interaction", close);
            return {close: close};
        }
        (0, _dom.insertCSS)("\n.ProseMirror-prompt {\n  background: white;\n  padding: 2px 6px 2px 15px;\n  border: 1px solid silver;\n  position: absolute;\n  border-radius: 3px;\n  z-index: 11;\n}\n\n.ProseMirror-prompt h5 {\n  margin: 0;\n  font-weight: normal;\n  font-size: 100%;\n  color: #444;\n}\n\n.ProseMirror-prompt input[type=\"text\"],\n.ProseMirror-prompt textarea {\n  background: #eee;\n  border: none;\n  outline: none;\n}\n\n.ProseMirror-prompt input[type=\"text\"] {\n  padding: 0 4px;\n}\n\n.ProseMirror-prompt-close {\n  position: absolute;\n  left: 2px; top: 1px;\n  color: #666;\n  border: none; background: transparent; padding: 0;\n}\n\n.ProseMirror-prompt-close:after {\n  content: \"✕\";\n  font-size: 12px;\n}\n\n.ProseMirror-invalid {\n  background: #ffc;\n  border: 1px solid #cc7;\n  border-radius: 4px;\n  padding: 5px 10px;\n  position: absolute;\n  min-width: 10em;\n}\n\n.ProseMirror-prompt-buttons {\n  margin-top: 5px;\n  display: none;\n}\n\n");
        return module.exports;
    });

    $__System.registerDynamic("1d", ["6", "1f", "20"], true, function($__require, exports, module) {
        "use strict";
        ;
        var define,
            global = this,
            GLOBAL = this;
        Object.defineProperty(exports, "__esModule", {value: true});
        exports.defineOption = defineOption;
        exports.parseOptions = parseOptions;
        exports.initOptions = initOptions;
        exports.setOption = setOption;
        var _model = $__require('6');
        var _prompt = $__require('1f');
        var _command = $__require('20');
        function _classCallCheck(instance, Constructor) {
            if (!(instance instanceof Constructor)) {
                throw new TypeError("Cannot call a class as a function");
            }
        }
        var Option = function Option(defaultValue, update, updateOnInit) {
            _classCallCheck(this, Option);
            this.defaultValue = defaultValue;
            this.update = update;
            this.updateOnInit = updateOnInit !== false;
        };
        var options = Object.create(null);
        function defineOption(name, defaultValue, update, updateOnInit) {
            options[name] = new Option(defaultValue, update, updateOnInit);
        }
        defineOption("schema", _model.defaultSchema, false);
        defineOption("doc", null, function(pm, value) {
            return pm.setDoc(value);
        }, false);
        defineOption("docFormat", null);
        defineOption("place", null);
        defineOption("historyDepth", 100);
        defineOption("historyEventDelay", 500);
        defineOption("commands", _command.CommandSet.default, _command.updateCommands);
        defineOption("commandParamPrompt", _prompt.ParamPrompt);
        defineOption("label", null);
        defineOption("translate", null);
        function parseOptions(obj) {
            var result = Object.create(null);
            var given = obj ? [obj].concat(obj.use || []) : [];
            outer: for (var opt in options) {
                for (var i = 0; i < given.length; i++) {
                    if (opt in given[i]) {
                        result[opt] = given[i][opt];
                        continue outer;
                    }
                }
                result[opt] = options[opt].defaultValue;
            }
            return result;
        }
        function initOptions(pm) {
            for (var opt in options) {
                var desc = options[opt];
                if (desc.update && desc.updateOnInit)
                    desc.update(pm, pm.options[opt], null, true);
            }
        }
        function setOption(pm, name, value) {
            var desc = options[name];
            if (desc === undefined)
                throw new RangeError("Option '" + name + "' is not defined");
            if (desc.update === false)
                throw new RangeError("Option '" + name + "' can not be changed");
            var old = pm.options[name];
            pm.options[name] = value;
            if (desc.update)
                desc.update(pm, value, old, false);
        }
        return module.exports;
    });

    $__System.registerDynamic("1c", [], true, function($__require, exports, module) {
        "use strict";
        ;
        var define,
            global = this,
            GLOBAL = this;
        Object.defineProperty(exports, "__esModule", {value: true});
        exports.eventMixin = eventMixin;
        var noHandlers = [];
        function getHandlers(obj, type) {
            return obj._handlers && obj._handlers[type] || noHandlers;
        }
        var methods = {
            on: function on(type, handler) {
                var map = this._handlers || (this._handlers = Object.create(null));
                map[type] = type in map ? map[type].concat(handler) : [handler];
            },
            off: function off(type, handler) {
                var map = this._handlers,
                    arr = map && map[type];
                if (arr)
                    for (var i = 0; i < arr.length; ++i) {
                        if (arr[i] == handler) {
                            map[type] = arr.slice(0, i).concat(arr.slice(i + 1));
                            break;
                        }
                    }
            },
            signal: function signal(type) {
                var arr = getHandlers(this, type);
                for (var _len = arguments.length,
                         args = Array(_len > 1 ? _len - 1 : 0),
                         _key = 1; _key < _len; _key++) {
                    args[_key - 1] = arguments[_key];
                }
                for (var i = 0; i < arr.length; ++i) {
                    arr[i].apply(arr, args);
                }
            },
            signalHandleable: function signalHandleable(type) {
                var arr = getHandlers(this, type);
                for (var _len2 = arguments.length,
                         args = Array(_len2 > 1 ? _len2 - 1 : 0),
                         _key2 = 1; _key2 < _len2; _key2++) {
                    args[_key2 - 1] = arguments[_key2];
                }
                for (var i = 0; i < arr.length; ++i) {
                    var result = arr[i].apply(arr, args);
                    if (result != null)
                        return result;
                }
            },
            signalPipelined: function signalPipelined(type, value) {
                var arr = getHandlers(this, type);
                for (var i = 0; i < arr.length; ++i) {
                    value = arr[i](value);
                }
                return value;
            },
            signalDOM: function signalDOM(event, type) {
                var arr = getHandlers(this, type || event.type);
                for (var i = 0; i < arr.length; ++i) {
                    if (arr[i](event) || event.defaultPrevented)
                        return true;
                }
                return false;
            },
            hasHandler: function hasHandler(type) {
                return getHandlers(this, type).length > 0;
            }
        };
        function eventMixin(ctor) {
            var proto = ctor.prototype;
            for (var prop in methods) {
                if (methods.hasOwnProperty(prop))
                    proto[prop] = methods[prop];
            }
        }
        return module.exports;
    });

    $__System.registerDynamic("1e", ["1c"], true, function($__require, exports, module) {
        "use strict";
        ;
        var define,
            global = this,
            GLOBAL = this;
        Object.defineProperty(exports, "__esModule", {value: true});
        exports.RangeStore = exports.MarkedRange = undefined;
        var _createClass = function() {
            function defineProperties(target, props) {
                for (var i = 0; i < props.length; i++) {
                    var descriptor = props[i];
                    descriptor.enumerable = descriptor.enumerable || false;
                    descriptor.configurable = true;
                    if ("value" in descriptor)
                        descriptor.writable = true;
                    Object.defineProperty(target, descriptor.key, descriptor);
                }
            }
            return function(Constructor, protoProps, staticProps) {
                if (protoProps)
                    defineProperties(Constructor.prototype, protoProps);
                if (staticProps)
                    defineProperties(Constructor, staticProps);
                return Constructor;
            };
        }();
        var _event = $__require('1c');
        function _classCallCheck(instance, Constructor) {
            if (!(instance instanceof Constructor)) {
                throw new TypeError("Cannot call a class as a function");
            }
        }
        var MarkedRange = exports.MarkedRange = function() {
            function MarkedRange(from, to, options) {
                _classCallCheck(this, MarkedRange);
                this.options = options || {};
                this.from = from;
                this.to = to;
            }
            _createClass(MarkedRange, [{
                key: "remove",
                value: function remove() {
                    this.signal("removed", this.from, Math.max(this.to, this.from));
                    this.from = this.to = null;
                }
            }]);
            return MarkedRange;
        }();
        (0, _event.eventMixin)(MarkedRange);
        var RangeSorter = function() {
            function RangeSorter() {
                _classCallCheck(this, RangeSorter);
                this.sorted = [];
            }
            _createClass(RangeSorter, [{
                key: "find",
                value: function find(at) {
                    var min = 0,
                        max = this.sorted.length;
                    for (; ; ) {
                        if (max < min + 10) {
                            for (var i = min; i < max; i++) {
                                if (this.sorted[i].at >= at)
                                    return i;
                            }
                            return max;
                        }
                        var mid = min + max >> 1;
                        if (this.sorted[mid].at > at)
                            max = mid;
                        else
                            min = mid;
                    }
                }
            }, {
                key: "insert",
                value: function insert(obj) {
                    this.sorted.splice(this.find(obj.at), 0, obj);
                }
            }, {
                key: "remove",
                value: function remove(at, range) {
                    var pos = this.find(at);
                    for (var dist = 0; ; dist++) {
                        var leftPos = pos - dist - 1,
                            rightPos = pos + dist;
                        if (leftPos >= 0 && this.sorted[leftPos].range == range) {
                            this.sorted.splice(leftPos, 1);
                            return;
                        } else if (rightPos < this.sorted.length && this.sorted[rightPos].range == range) {
                            this.sorted.splice(rightPos, 1);
                            return;
                        }
                    }
                }
            }, {
                key: "resort",
                value: function resort() {
                    for (var i = 0; i < this.sorted.length; i++) {
                        var cur = this.sorted[i];
                        var at = cur.at = cur.type == "open" ? cur.range.from : cur.range.to;
                        var pos = i;
                        while (pos > 0 && this.sorted[pos - 1].at > at) {
                            this.sorted[pos] = this.sorted[pos - 1];
                            this.sorted[--pos] = cur;
                        }
                    }
                }
            }]);
            return RangeSorter;
        }();
        var RangeStore = exports.RangeStore = function() {
            function RangeStore(pm) {
                _classCallCheck(this, RangeStore);
                this.pm = pm;
                this.ranges = [];
                this.sorted = new RangeSorter();
            }
            _createClass(RangeStore, [{
                key: "addRange",
                value: function addRange(range) {
                    this.ranges.push(range);
                    this.sorted.insert({
                        type: "open",
                        at: range.from,
                        range: range
                    });
                    this.sorted.insert({
                        type: "close",
                        at: range.to,
                        range: range
                    });
                    if (range.options.className)
                        this.pm.markRangeDirty(range.from, range.to);
                }
            }, {
                key: "removeRange",
                value: function removeRange(range) {
                    var found = this.ranges.indexOf(range);
                    if (found > -1) {
                        this.ranges.splice(found, 1);
                        this.sorted.remove(range.from, range);
                        this.sorted.remove(range.to, range);
                        if (range.options.className)
                            this.pm.markRangeDirty(range.from, range.to);
                        range.remove();
                    }
                }
            }, {
                key: "transform",
                value: function transform(mapping) {
                    for (var i = 0; i < this.ranges.length; i++) {
                        var range = this.ranges[i];
                        range.from = mapping.map(range.from, range.options.inclusiveLeft ? -1 : 1);
                        range.to = mapping.map(range.to, range.options.inclusiveRight ? 1 : -1);
                        if (range.options.removeWhenEmpty !== false && range.from >= range.to) {
                            this.removeRange(range);
                            i--;
                        } else if (range.from > range.to) {
                            range.to = range.from;
                        }
                    }
                    this.sorted.resort();
                }
            }, {
                key: "activeRangeTracker",
                value: function activeRangeTracker() {
                    return new RangeTracker(this.sorted.sorted);
                }
            }]);
            return RangeStore;
        }();
        var RangeTracker = function() {
            function RangeTracker(sorted) {
                _classCallCheck(this, RangeTracker);
                this.sorted = sorted;
                this.pos = 0;
                this.current = [];
            }
            _createClass(RangeTracker, [{
                key: "advanceTo",
                value: function advanceTo(pos) {
                    var next = undefined;
                    while (this.pos < this.sorted.length && (next = this.sorted[this.pos]).at <= pos) {
                        var className = next.range.options.className;
                        if (className) {
                            if (next.type == "open")
                                this.current.push(className);
                            else
                                this.current.splice(this.current.indexOf(className), 1);
                        }
                        this.pos++;
                    }
                }
            }, {
                key: "nextChangeBefore",
                value: function nextChangeBefore(pos) {
                    for (; ; ) {
                        if (this.pos == this.sorted.length)
                            return -1;
                        var next = this.sorted[this.pos];
                        if (!next.range.options.className)
                            this.pos++;
                        else if (next.at >= pos)
                            return -1;
                        else
                            return next.at;
                    }
                }
            }]);
            return RangeTracker;
        }();
        return module.exports;
    });

    $__System.registerDynamic("21", ["6", "22", "23", "16"], true, function($__require, exports, module) {
        "use strict";
        ;
        var define,
            global = this,
            GLOBAL = this;
        Object.defineProperty(exports, "__esModule", {value: true});
        exports.canLift = canLift;
        exports.canWrap = canWrap;
        var _model = $__require('6');
        var _transform = $__require('22');
        var _step = $__require('23');
        var _map = $__require('16');
        function isFlatRange($from, $to) {
            if ($from.depth != $to.depth)
                return false;
            for (var i = 0; i < $from.depth; i++) {
                if ($from.index(i) != $to.index(i))
                    return false;
            }
            return $from.parentOffset <= $to.parentOffset;
        }
        _step.Step.define("ancestor", {
            apply: function apply(doc, step) {
                var $from = doc.resolve(step.from),
                    $to = doc.resolve(step.to);
                if (!isFlatRange($from, $to))
                    return _step.StepResult.fail("Not a flat range");
                var _step$param = step.param;
                var _step$param$depth = _step$param.depth;
                var depth = _step$param$depth === undefined ? 0 : _step$param$depth;
                var _step$param$types = _step$param.types;
                var types = _step$param$types === undefined ? [] : _step$param$types;
                var _step$param$attrs = _step$param.attrs;
                var attrs = _step$param$attrs === undefined ? [] : _step$param$attrs;
                if (depth == 0 && types.length == 0)
                    return _step.StepResult.ok(doc);
                for (var i = 0,
                         d = $from.depth; i < depth; i++, d--) {
                    if ($from.start(d) != $from.pos - i || $to.end(d) != $to.pos + i)
                        return _step.StepResult.fail("Parent at depth " + d + " not fully covered");
                }
                var inner = $from.parent,
                    slice = undefined;
                if (types.length) {
                    var lastWrapper = types[types.length - 1];
                    if (!lastWrapper.contains)
                        throw new RangeError("Can not wrap content in node type " + lastWrapper.name);
                    var content = inner.content.cut($from.parentOffset, $to.parentOffset);
                    if (!lastWrapper.checkContent(content, attrs[types.length - 1]))
                        return _step.StepResult.fail("Content can not be wrapped in ancestor " + lastWrapper.name);
                    for (var i = types.length - 1; i >= 0; i--) {
                        content = _model.Fragment.from(types[i].create(attrs[i], content));
                    }
                    slice = new _model.Slice(content, 0, 0);
                } else {
                    slice = new _model.Slice(inner.content, 0, 0);
                }
                return _step.StepResult.fromReplace(doc, $from.pos - depth, $to.pos + depth, slice);
            },
            posMap: function posMap(step) {
                var depth = step.param.depth || 0,
                    newDepth = step.param.types ? step.param.types.length : 0;
                if (depth == newDepth && depth < 2)
                    return _map.PosMap.empty;
                return new _map.PosMap([step.from - depth, depth, newDepth, step.to, depth, newDepth]);
            },
            invert: function invert(step, oldDoc) {
                var types = [],
                    attrs = [];
                var $from = oldDoc.resolve(step.from);
                var oldDepth = step.param.depth || 0,
                    newDepth = step.param.types ? step.param.types.length : 0;
                for (var i = 0; i < oldDepth; i++) {
                    var parent = $from.node($from.depth - i);
                    types.unshift(parent.type);
                    attrs.unshift(parent.attrs);
                }
                var dDepth = newDepth - oldDepth;
                return new _step.Step("ancestor", step.from + dDepth, step.to + dDepth, {
                    depth: newDepth,
                    types: types,
                    attrs: attrs
                });
            },
            paramToJSON: function paramToJSON(param) {
                return {
                    depth: param.depth,
                    types: param.types && param.types.map(function(t) {
                        return t.name;
                    }),
                    attrs: param.attrs
                };
            },
            paramFromJSON: function paramFromJSON(schema, json) {
                return {
                    depth: json.depth,
                    types: json.types && json.types.map(function(n) {
                        return schema.nodeType(n);
                    }),
                    attrs: json.attrs
                };
            }
        });
        function canLift(doc, from, to) {
            return !!findLiftable(doc.resolve(from), doc.resolve(to == null ? from : to));
        }
        function rangeDepth(from, to) {
            var shared = from.sameDepth(to);
            if (from.node(shared).isTextblock)
                --shared;
            if (shared && from.before(shared) >= to.after(shared))
                return null;
            return shared;
        }
        function findLiftable(from, to) {
            var shared = rangeDepth(from, to);
            if (shared == null)
                return null;
            var parent = from.node(shared);
            for (var depth = shared - 1; depth >= 0; --depth) {
                if (from.node(depth).type.canContainContent(parent.type))
                    return {
                        depth: depth,
                        shared: shared,
                        unwrap: false
                    };
            }
            if (parent.isBlock)
                for (var depth = shared - 1; depth >= 0; --depth) {
                    var target = from.node(depth);
                    for (var i = from.index(shared),
                             e = Math.min(to.index(shared) + 1, parent.childCount); i < e; i++) {
                        if (!target.type.canContainContent(parent.child(i).type))
                            continue;
                    }
                    return {
                        depth: depth,
                        shared: shared,
                        unwrap: true
                    };
                }
        }
        _transform.Transform.prototype.lift = function(from) {
            var to = arguments.length <= 1 || arguments[1] === undefined ? from : arguments[1];
            var silent = arguments.length <= 2 || arguments[2] === undefined ? false : arguments[2];
            var $from = this.doc.resolve(from),
                $to = this.doc.resolve(to);
            var liftable = findLiftable($from, $to);
            if (!liftable) {
                if (!silent)
                    throw new RangeError("No valid lift target");
                return this;
            }
            var depth = liftable.depth;
            var shared = liftable.shared;
            var unwrap = liftable.unwrap;
            var start = $from.before(shared + 1),
                end = $to.after(shared + 1);
            for (var d = shared; d > depth; d--) {
                if ($to.index(d) + 1 < $to.node(d).childCount) {
                    this.split($to.after(d + 1), d - depth);
                    break;
                }
            }
            for (var d = shared; d > depth; d--) {
                if ($from.index(d) > 0) {
                    var cut = d - depth;
                    this.split($from.before(d + 1), cut);
                    start += 2 * cut;
                    end += 2 * cut;
                    break;
                }
            }
            if (unwrap) {
                var joinPos = start,
                    parent = $from.node(shared);
                for (var i = $from.index(shared),
                         e = $to.index(shared) + 1,
                         first = true; i < e; i++, first = false) {
                    if (!first) {
                        this.join(joinPos);
                        end -= 2;
                    }
                    joinPos += parent.child(i).nodeSize - (first ? 0 : 2);
                }
                shared++;
                start++;
                end--;
            }
            return this.step("ancestor", start, end, {depth: shared - depth});
        };
        function canWrap(doc, from, to, type) {
            return !!checkWrap(doc.resolve(from), doc.resolve(to == null ? from : to), type);
        }
        function checkWrap($from, $to, type) {
            var shared = rangeDepth($from, $to);
            if (shared == null)
                return null;
            var parent = $from.node(shared);
            var around = parent.type.findConnection(type);
            var inside = type.findConnection(parent.child($from.index(shared)).type);
            if (around && inside)
                return {
                    shared: shared,
                    around: around,
                    inside: inside
                };
        }
        _transform.Transform.prototype.wrap = function(from) {
            var to = arguments.length <= 1 || arguments[1] === undefined ? from : arguments[1];
            var type = arguments[2];
            var wrapAttrs = arguments[3];
            var $from = this.doc.resolve(from),
                $to = this.doc.resolve(to);
            var check = checkWrap($from, $to, type);
            if (!check)
                throw new RangeError("Wrap not possible");
            var shared = check.shared;
            var around = check.around;
            var inside = check.inside;
            var types = around.concat(type).concat(inside);
            var attrs = around.map(function() {
                return null;
            }).concat(wrapAttrs).concat(inside.map(function() {
                return null;
            }));
            var start = $from.before(shared + 1);
            this.step("ancestor", start, $to.after(shared + 1), {
                types: types,
                attrs: attrs
            });
            if (inside.length) {
                var splitPos = start + types.length,
                    parent = $from.node(shared);
                for (var i = $from.index(shared),
                         e = $to.index(shared) + 1,
                         first = true; i < e; i++, first = false) {
                    if (!first)
                        this.split(splitPos, inside.length);
                    splitPos += parent.child(i).nodeSize + (first ? 0 : 2 * inside.length);
                }
            }
            return this;
        };
        _transform.Transform.prototype.setBlockType = function(from) {
            var to = arguments.length <= 1 || arguments[1] === undefined ? from : arguments[1];
            var _this = this;
            var type = arguments[2];
            var attrs = arguments[3];
            if (!type.isTextblock)
                throw new RangeError("Type given to setBlockType should be a textblock");
            this.doc.nodesBetween(from, to, function(node, pos) {
                if (node.isTextblock && !node.hasMarkup(type, attrs)) {
                    var start = pos + 1,
                        end = start + node.content.size;
                    _this.clearMarkup(start, end, type);
                    _this.step("ancestor", start, end, {
                        depth: 1,
                        types: [type],
                        attrs: [attrs]
                    });
                    return false;
                }
            });
            return this;
        };
        _transform.Transform.prototype.setNodeType = function(pos, type, attrs) {
            var node = this.doc.nodeAt(pos);
            if (!node)
                throw new RangeError("No node at given position");
            if (!type)
                type = node.type;
            if (node.type.contains)
                return this.step("ancestor", pos + 1, pos + 1 + node.content.size, {
                    depth: 1,
                    types: [type],
                    attrs: [attrs]
                });
            else
                return this.replaceWith(pos, pos + node.nodeSize, type.create(attrs, null, node.marks));
        };
        return module.exports;
    });

    $__System.registerDynamic("24", ["6", "22", "23", "16"], true, function($__require, exports, module) {
        "use strict";
        ;
        var define,
            global = this,
            GLOBAL = this;
        Object.defineProperty(exports, "__esModule", {value: true});
        exports.joinable = joinable;
        exports.joinPoint = joinPoint;
        var _model = $__require('6');
        var _transform = $__require('22');
        var _step = $__require('23');
        var _map = $__require('16');
        _step.Step.define("join", {
            apply: function apply(doc, step) {
                var $from = doc.resolve(step.from),
                    $to = doc.resolve(step.to);
                if ($from.parentOffset < $from.parent.content.size || $to.parentOffset > 0 || $to.pos - $from.pos != 2)
                    return _step.StepResult.fail("Join positions not around a split");
                return _step.StepResult.fromReplace(doc, $from.pos, $to.pos, _model.Slice.empty);
            },
            posMap: function posMap(step) {
                return new _map.PosMap([step.from, 2, 0]);
            },
            invert: function invert(step, doc) {
                var $before = doc.resolve(step.from),
                    d1 = $before.depth - 1;
                var parentAfter = $before.node(d1).child($before.index(d1) + 1);
                var param = null;
                if (!$before.parent.sameMarkup(parentAfter))
                    param = {
                        type: parentAfter.type,
                        attrs: parentAfter.attrs
                    };
                return new _step.Step("split", step.from, step.from, param);
            }
        });
        function joinable(doc, pos) {
            var $pos = doc.resolve(pos);
            return canJoin($pos.nodeBefore, $pos.nodeAfter);
        }
        function canJoin(a, b) {
            return a && b && !a.isText && a.type.contains && a.type.canContainContent(b.type);
        }
        function joinPoint(doc, pos) {
            var dir = arguments.length <= 2 || arguments[2] === undefined ? -1 : arguments[2];
            var $pos = doc.resolve(pos);
            for (var d = $pos.depth; ; d--) {
                var before = undefined,
                    after = undefined;
                if (d == $pos.depth) {
                    before = $pos.nodeBefore;
                    after = $pos.nodeAfter;
                } else if (dir > 0) {
                    before = $pos.node(d + 1);
                    after = $pos.node(d).maybeChild($pos.index(d) + 1);
                } else {
                    before = $pos.node(d).maybeChild($pos.index(d) - 1);
                    after = $pos.node(d + 1);
                }
                if (before && !before.isTextblock && canJoin(before, after))
                    return pos;
                if (d == 0)
                    break;
                pos = dir < 0 ? $pos.before(d) : $pos.after(d);
            }
        }
        _transform.Transform.prototype.join = function(pos) {
            var depth = arguments.length <= 1 || arguments[1] === undefined ? 1 : arguments[1];
            var silent = arguments.length <= 2 || arguments[2] === undefined ? false : arguments[2];
            for (var i = 0; i < depth; i++) {
                var $pos = this.doc.resolve(pos);
                if ($pos.parentOffset == 0 || $pos.parentOffset == $pos.parent.content.size || !$pos.nodeBefore.type.canContainContent($pos.nodeAfter.type)) {
                    if (!silent)
                        throw new RangeError("Nothing to join at " + pos);
                    break;
                }
                this.step("join", pos - 1, pos + 1);
                pos--;
            }
            return this;
        };
        return module.exports;
    });

    $__System.registerDynamic("25", ["6", "22", "23"], true, function($__require, exports, module) {
        "use strict";
        ;
        var define,
            global = this,
            GLOBAL = this;
        var _model = $__require('6');
        var _transform = $__require('22');
        var _step = $__require('23');
        function mapNode(node, f, parent) {
            if (node.content.size)
                node = node.copy(mapFragment(node.content, f, node));
            if (node.isInline)
                node = f(node, parent);
            return node;
        }
        function mapFragment(fragment, f, parent) {
            var mapped = [];
            for (var i = 0; i < fragment.childCount; i++) {
                mapped.push(mapNode(fragment.child(i), f, parent));
            }
            return _model.Fragment.fromArray(mapped);
        }
        _step.Step.define("addMark", {
            apply: function apply(doc, step) {
                var slice = doc.slice(step.from, step.to),
                    $pos = doc.resolve(step.from);
                slice.content = mapFragment(slice.content, function(node, parent) {
                    if (!parent.type.canContainMark(step.param.type))
                        return node;
                    return node.mark(step.param.addToSet(node.marks));
                }, $pos.node($pos.depth - slice.openLeft));
                return _step.StepResult.fromReplace(doc, step.from, step.to, slice);
            },
            invert: function invert(step) {
                return new _step.Step("removeMark", step.from, step.to, step.param);
            },
            paramToJSON: function paramToJSON(param) {
                return param.toJSON();
            },
            paramFromJSON: function paramFromJSON(schema, json) {
                return schema.markFromJSON(json);
            }
        });
        _transform.Transform.prototype.addMark = function(from, to, mark) {
            var _this = this;
            var removed = [],
                added = [],
                removing = null,
                adding = null;
            this.doc.nodesBetween(from, to, function(node, pos, parent) {
                if (!node.isInline)
                    return;
                var marks = node.marks;
                if (mark.isInSet(marks) || !parent.type.canContainMark(mark.type)) {
                    adding = removing = null;
                } else {
                    var start = Math.max(pos, from),
                        end = Math.min(pos + node.nodeSize, to);
                    var rm = mark.type.isInSet(marks);
                    if (!rm)
                        removing = null;
                    else if (removing && removing.param.eq(rm))
                        removing.to = end;
                    else
                        removed.push(removing = new _step.Step("removeMark", start, end, rm));
                    if (adding)
                        adding.to = end;
                    else
                        added.push(adding = new _step.Step("addMark", start, end, mark));
                }
            });
            removed.forEach(function(s) {
                return _this.step(s);
            });
            added.forEach(function(s) {
                return _this.step(s);
            });
            return this;
        };
        _step.Step.define("removeMark", {
            apply: function apply(doc, step) {
                var slice = doc.slice(step.from, step.to);
                slice.content = mapFragment(slice.content, function(node) {
                    return node.mark(step.param.removeFromSet(node.marks));
                });
                return _step.StepResult.fromReplace(doc, step.from, step.to, slice);
            },
            invert: function invert(step) {
                return new _step.Step("addMark", step.from, step.to, step.param);
            },
            paramToJSON: function paramToJSON(param) {
                return param.toJSON();
            },
            paramFromJSON: function paramFromJSON(schema, json) {
                return schema.markFromJSON(json);
            }
        });
        _transform.Transform.prototype.removeMark = function(from, to) {
            var _this2 = this;
            var mark = arguments.length <= 2 || arguments[2] === undefined ? null : arguments[2];
            var matched = [],
                step = 0;
            this.doc.nodesBetween(from, to, function(node, pos) {
                if (!node.isInline)
                    return;
                step++;
                var toRemove = null;
                if (mark instanceof _model.MarkType) {
                    var found = mark.isInSet(node.marks);
                    if (found)
                        toRemove = [found];
                } else if (mark) {
                    if (mark.isInSet(node.marks))
                        toRemove = [mark];
                } else {
                    toRemove = node.marks;
                }
                if (toRemove && toRemove.length) {
                    var end = Math.min(pos + node.nodeSize, to);
                    for (var i = 0; i < toRemove.length; i++) {
                        var style = toRemove[i],
                            found = undefined;
                        for (var j = 0; j < matched.length; j++) {
                            var m = matched[j];
                            if (m.step == step - 1 && style.eq(matched[j].style))
                                found = m;
                        }
                        if (found) {
                            found.to = end;
                            found.step = step;
                        } else {
                            matched.push({
                                style: style,
                                from: Math.max(pos, from),
                                to: end,
                                step: step
                            });
                        }
                    }
                }
            });
            matched.forEach(function(m) {
                return _this2.step("removeMark", m.from, m.to, m.style);
            });
            return this;
        };
        _transform.Transform.prototype.clearMarkup = function(from, to, newParent) {
            var _this3 = this;
            var delSteps = [];
            this.doc.nodesBetween(from, to, function(node, pos) {
                if (!node.isInline)
                    return;
                if (newParent ? !newParent.canContainType(node.type) : !node.type.isText) {
                    delSteps.push(new _step.Step("replace", pos, pos + node.nodeSize));
                    return;
                }
                for (var i = 0; i < node.marks.length; i++) {
                    var mark = node.marks[i];
                    if (!newParent || !newParent.canContainMark(mark.type))
                        _this3.step("removeMark", Math.max(pos, from), Math.min(pos + node.nodeSize, to), mark);
                }
            });
            for (var i = delSteps.length - 1; i >= 0; i--) {
                this.step(delSteps[i]);
            }
            return this;
        };
        return module.exports;
    });

    $__System.registerDynamic("26", ["6", "22", "23", "16"], true, function($__require, exports, module) {
        "use strict";
        ;
        var define,
            global = this,
            GLOBAL = this;
        var _model = $__require('6');
        var _transform = $__require('22');
        var _step = $__require('23');
        var _map = $__require('16');
        _step.Step.define("split", {
            apply: function apply(doc, step) {
                var $pos = doc.resolve(step.from),
                    parent = $pos.parent;
                var cut = [parent.copy(), step.param ? step.param.type.create(step.attrs) : parent.copy()];
                return _step.StepResult.fromReplace(doc, $pos.pos, $pos.pos, new _model.Slice(_model.Fragment.fromArray(cut), 1, 1));
            },
            posMap: function posMap(step) {
                return new _map.PosMap([step.from, 0, 2]);
            },
            invert: function invert(step) {
                return new _step.Step("join", step.from, step.from + 2);
            },
            paramToJSON: function paramToJSON(param) {
                return param && {
                        type: param.type.name,
                        attrs: param.attrs
                    };
            },
            paramFromJSON: function paramFromJSON(schema, json) {
                return json && {
                        type: schema.nodeType(json.type),
                        attrs: json.attrs
                    };
            }
        });
        _transform.Transform.prototype.split = function(pos) {
            var depth = arguments.length <= 1 || arguments[1] === undefined ? 1 : arguments[1];
            var typeAfter = arguments[2];
            var attrsAfter = arguments[3];
            for (var i = 0; i < depth; i++) {
                this.step("split", pos + i, pos + i, i == 0 && typeAfter ? {
                    type: typeAfter,
                    attrs: attrsAfter
                } : null);
            }
            return this;
        };
        _transform.Transform.prototype.splitIfNeeded = function(pos) {
            var depth = arguments.length <= 1 || arguments[1] === undefined ? 1 : arguments[1];
            var $pos = this.doc.resolve(pos),
                before = true;
            for (var i = 0; i < depth; i++) {
                var d = $pos.depth - i,
                    point = i == 0 ? $pos.pos : before ? $pos.before(d + 1) : $pos.after(d + 1);
                if (point == $pos.start(d))
                    before = true;
                else if (point == $pos.end(d))
                    before = false;
                else
                    return this.split(point, depth - i);
            }
            return this;
        };
        return module.exports;
    });

    $__System.registerDynamic("22", ["27", "23", "16"], true, function($__require, exports, module) {
        "use strict";
        ;
        var define,
            global = this,
            GLOBAL = this;
        Object.defineProperty(exports, "__esModule", {value: true});
        exports.Transform = exports.TransformError = undefined;
        var _createClass = function() {
            function defineProperties(target, props) {
                for (var i = 0; i < props.length; i++) {
                    var descriptor = props[i];
                    descriptor.enumerable = descriptor.enumerable || false;
                    descriptor.configurable = true;
                    if ("value" in descriptor)
                        descriptor.writable = true;
                    Object.defineProperty(target, descriptor.key, descriptor);
                }
            }
            return function(Constructor, protoProps, staticProps) {
                if (protoProps)
                    defineProperties(Constructor.prototype, protoProps);
                if (staticProps)
                    defineProperties(Constructor, staticProps);
                return Constructor;
            };
        }();
        var _error = $__require('27');
        var _step2 = $__require('23');
        var _map = $__require('16');
        function _classCallCheck(instance, Constructor) {
            if (!(instance instanceof Constructor)) {
                throw new TypeError("Cannot call a class as a function");
            }
        }
        function _possibleConstructorReturn(self, call) {
            if (!self) {
                throw new ReferenceError("this hasn't been initialised - super() hasn't been called");
            }
            return call && (typeof call === "object" || typeof call === "function") ? call : self;
        }
        function _inherits(subClass, superClass) {
            if (typeof superClass !== "function" && superClass !== null) {
                throw new TypeError("Super expression must either be null or a function, not " + typeof superClass);
            }
            subClass.prototype = Object.create(superClass && superClass.prototype, {constructor: {
                value: subClass,
                enumerable: false,
                writable: true,
                configurable: true
            }});
            if (superClass)
                Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass;
        }
        var TransformError = exports.TransformError = function(_ProseMirrorError) {
            _inherits(TransformError, _ProseMirrorError);
            function TransformError() {
                _classCallCheck(this, TransformError);
                return _possibleConstructorReturn(this, Object.getPrototypeOf(TransformError).apply(this, arguments));
            }
            return TransformError;
        }(_error.ProseMirrorError);
        var Transform = function() {
            function Transform(doc) {
                _classCallCheck(this, Transform);
                this.doc = doc;
                this.docs = [];
                this.steps = [];
                this.maps = [];
            }
            _createClass(Transform, [{
                key: "step",
                value: function step(_step, from, to, param) {
                    if (typeof _step == "string")
                        _step = new _step2.Step(_step, from, to, param);
                    var result = this.maybeStep(_step);
                    if (result.failed)
                        throw new TransformError(result.failed);
                    return this;
                }
            }, {
                key: "maybeStep",
                value: function maybeStep(step) {
                    var result = step.apply(this.doc);
                    if (!result.failed) {
                        this.docs.push(this.doc);
                        this.steps.push(step);
                        this.maps.push(step.posMap());
                        this.doc = result.doc;
                    }
                    return result;
                }
            }, {
                key: "mapResult",
                value: function mapResult(pos, bias) {
                    return (0, _map.mapThroughResult)(this.maps, pos, bias);
                }
            }, {
                key: "map",
                value: function map(pos, bias) {
                    return (0, _map.mapThrough)(this.maps, pos, bias);
                }
            }, {
                key: "before",
                get: function get() {
                    return this.docs.length ? this.docs[0] : this.doc;
                }
            }]);
            return Transform;
        }();
        exports.Transform = Transform;
        return module.exports;
    });

    $__System.registerDynamic("23", ["6", "16"], true, function($__require, exports, module) {
        "use strict";
        ;
        var define,
            global = this,
            GLOBAL = this;
        Object.defineProperty(exports, "__esModule", {value: true});
        exports.StepResult = exports.Step = undefined;
        var _createClass = function() {
            function defineProperties(target, props) {
                for (var i = 0; i < props.length; i++) {
                    var descriptor = props[i];
                    descriptor.enumerable = descriptor.enumerable || false;
                    descriptor.configurable = true;
                    if ("value" in descriptor)
                        descriptor.writable = true;
                    Object.defineProperty(target, descriptor.key, descriptor);
                }
            }
            return function(Constructor, protoProps, staticProps) {
                if (protoProps)
                    defineProperties(Constructor.prototype, protoProps);
                if (staticProps)
                    defineProperties(Constructor, staticProps);
                return Constructor;
            };
        }();
        var _model = $__require('6');
        var _map = $__require('16');
        function _classCallCheck(instance, Constructor) {
            if (!(instance instanceof Constructor)) {
                throw new TypeError("Cannot call a class as a function");
            }
        }
        var Step = exports.Step = function() {
            function Step(type, from, to) {
                var param = arguments.length <= 3 || arguments[3] === undefined ? null : arguments[3];
                _classCallCheck(this, Step);
                if (!(type in steps))
                    throw new RangeError("Unknown step type: " + type);
                this.type = type;
                this.from = from;
                this.to = to;
                this.param = param;
            }
            _createClass(Step, [{
                key: "apply",
                value: function apply(doc) {
                    return steps[this.type].apply(doc, this);
                }
            }, {
                key: "posMap",
                value: function posMap() {
                    var type = steps[this.type];
                    return type.posMap ? type.posMap(this) : _map.PosMap.empty;
                }
            }, {
                key: "invert",
                value: function invert(oldDoc) {
                    return steps[this.type].invert(this, oldDoc);
                }
            }, {
                key: "map",
                value: function map(remapping) {
                    var from = remapping.mapResult(this.from, 1);
                    var to = this.to == this.from ? from : remapping.mapResult(this.to, -1);
                    if (from.deleted && to.deleted)
                        return null;
                    return new Step(this.type, from.pos, Math.max(from.pos, to.pos), this.param);
                }
            }, {
                key: "toJSON",
                value: function toJSON() {
                    var impl = steps[this.type];
                    return {
                        type: this.type,
                        from: this.from,
                        to: this.to,
                        param: impl.paramToJSON ? impl.paramToJSON(this.param) : this.param
                    };
                }
            }, {
                key: "toString",
                value: function toString() {
                    return this.type + "@" + this.from + "-" + this.to;
                }
            }], [{
                key: "fromJSON",
                value: function fromJSON(schema, json) {
                    var impl = steps[json.type];
                    return new Step(json.type, json.from, json.to, impl.paramFromJSON ? impl.paramFromJSON(schema, json.param) : json.param);
                }
            }, {
                key: "define",
                value: function define(type, implementation) {
                    steps[type] = implementation;
                }
            }]);
            return Step;
        }();
        var steps = Object.create(null);
        var StepResult = exports.StepResult = function() {
            function StepResult(doc, failed) {
                _classCallCheck(this, StepResult);
                this.doc = doc;
                this.failed = failed;
            }
            _createClass(StepResult, null, [{
                key: "ok",
                value: function ok(doc) {
                    return new StepResult(doc, null);
                }
            }, {
                key: "fail",
                value: function fail(val) {
                    return new StepResult(null, val);
                }
            }, {
                key: "fromReplace",
                value: function fromReplace(doc, from, to, slice) {
                    try {
                        return StepResult.ok(doc.replace(from, to, slice));
                    } catch (e) {
                        if (e instanceof _model.ReplaceError)
                            return StepResult.fail(e.message);
                        throw e;
                    }
                }
            }]);
            return StepResult;
        }();
        return module.exports;
    });

    $__System.registerDynamic("16", [], true, function($__require, exports, module) {
        "use strict";
        ;
        var define,
            global = this,
            GLOBAL = this;
        Object.defineProperty(exports, "__esModule", {value: true});
        var _createClass = function() {
            function defineProperties(target, props) {
                for (var i = 0; i < props.length; i++) {
                    var descriptor = props[i];
                    descriptor.enumerable = descriptor.enumerable || false;
                    descriptor.configurable = true;
                    if ("value" in descriptor)
                        descriptor.writable = true;
                    Object.defineProperty(target, descriptor.key, descriptor);
                }
            }
            return function(Constructor, protoProps, staticProps) {
                if (protoProps)
                    defineProperties(Constructor.prototype, protoProps);
                if (staticProps)
                    defineProperties(Constructor, staticProps);
                return Constructor;
            };
        }();
        exports.mapThrough = mapThrough;
        exports.mapThroughResult = mapThroughResult;
        function _classCallCheck(instance, Constructor) {
            if (!(instance instanceof Constructor)) {
                throw new TypeError("Cannot call a class as a function");
            }
        }
        var lower16 = 0xffff;
        var factor16 = Math.pow(2, 16);
        function makeRecover(index, offset) {
            return index + offset * factor16;
        }
        function recoverIndex(value) {
            return value & lower16;
        }
        function recoverOffset(value) {
            return (value - (value & lower16)) / factor16;
        }
        var MapResult = exports.MapResult = function MapResult(pos) {
            var deleted = arguments.length <= 1 || arguments[1] === undefined ? false : arguments[1];
            var recover = arguments.length <= 2 || arguments[2] === undefined ? null : arguments[2];
            _classCallCheck(this, MapResult);
            this.pos = pos;
            this.deleted = deleted;
            this.recover = recover;
        };
        var PosMap = exports.PosMap = function() {
            function PosMap(ranges, inverted) {
                _classCallCheck(this, PosMap);
                this.ranges = ranges;
                this.inverted = inverted || false;
            }
            _createClass(PosMap, [{
                key: "recover",
                value: function recover(value) {
                    var diff = 0,
                        index = recoverIndex(value);
                    if (!this.inverted)
                        for (var i = 0; i < index; i++) {
                            diff += this.ranges[i * 3 + 2] - this.ranges[i * 3 + 1];
                        }
                    return this.ranges[index * 3] + diff + recoverOffset(value);
                }
            }, {
                key: "mapResult",
                value: function mapResult(pos, bias) {
                    return this._map(pos, bias, false);
                }
            }, {
                key: "map",
                value: function map(pos, bias) {
                    return this._map(pos, bias, true);
                }
            }, {
                key: "_map",
                value: function _map(pos, bias, simple) {
                    var diff = 0,
                        oldIndex = this.inverted ? 2 : 1,
                        newIndex = this.inverted ? 1 : 2;
                    for (var i = 0; i < this.ranges.length; i += 3) {
                        var start = this.ranges[i] - (this.inverted ? diff : 0);
                        if (start > pos)
                            break;
                        var oldSize = this.ranges[i + oldIndex],
                            newSize = this.ranges[i + newIndex],
                            end = start + oldSize;
                        if (pos <= end) {
                            var side = !oldSize ? bias : pos == start ? -1 : pos == end ? 1 : bias;
                            var result = start + diff + (side < 0 ? 0 : newSize);
                            if (simple)
                                return result;
                            var recover = makeRecover(i / 3, pos - start);
                            return new MapResult(result, pos != start && pos != end, recover);
                        }
                        diff += newSize - oldSize;
                    }
                    return simple ? pos + diff : new MapResult(pos + diff);
                }
            }, {
                key: "touches",
                value: function touches(pos, recover) {
                    var diff = 0,
                        index = recoverIndex(recover);
                    var oldIndex = this.inverted ? 2 : 1,
                        newIndex = this.inverted ? 1 : 2;
                    for (var i = 0; i < this.ranges.length; i += 3) {
                        var start = this.ranges[i] - (this.inverted ? diff : 0);
                        if (start > pos)
                            break;
                        var oldSize = this.ranges[i + oldIndex],
                            end = start + oldSize;
                        if (pos <= end && i == index * 3)
                            return true;
                        diff += this.ranges[i + newIndex] - oldSize;
                    }
                    return false;
                }
            }, {
                key: "invert",
                value: function invert() {
                    return new PosMap(this.ranges, !this.inverted);
                }
            }, {
                key: "toString",
                value: function toString() {
                    return (this.inverted ? "-" : "") + JSON.stringify(this.ranges);
                }
            }]);
            return PosMap;
        }();
        PosMap.empty = new PosMap([]);
        var Remapping = exports.Remapping = function() {
            function Remapping() {
                var head = arguments.length <= 0 || arguments[0] === undefined ? [] : arguments[0];
                var tail = arguments.length <= 1 || arguments[1] === undefined ? [] : arguments[1];
                _classCallCheck(this, Remapping);
                this.head = head;
                this.tail = tail;
                this.mirror = Object.create(null);
            }
            _createClass(Remapping, [{
                key: "addToFront",
                value: function addToFront(map, corr) {
                    this.head.push(map);
                    var id = -this.head.length;
                    if (corr != null)
                        this.mirror[id] = corr;
                    return id;
                }
            }, {
                key: "addToBack",
                value: function addToBack(map, corr) {
                    this.tail.push(map);
                    var id = this.tail.length - 1;
                    if (corr != null)
                        this.mirror[corr] = id;
                    return id;
                }
            }, {
                key: "get",
                value: function get(id) {
                    return id < 0 ? this.head[-id - 1] : this.tail[id];
                }
            }, {
                key: "mapResult",
                value: function mapResult(pos, bias) {
                    return this._map(pos, bias, false);
                }
            }, {
                key: "map",
                value: function map(pos, bias) {
                    return this._map(pos, bias, true);
                }
            }, {
                key: "_map",
                value: function _map(pos, bias, simple) {
                    var deleted = false,
                        recoverables = null;
                    for (var i = -this.head.length; i < this.tail.length; i++) {
                        var map = this.get(i),
                            rec = undefined;
                        if ((rec = recoverables && recoverables[i]) != null && map.touches(pos, rec)) {
                            pos = map.recover(rec);
                            continue;
                        }
                        var result = map.mapResult(pos, bias);
                        if (result.recover != null) {
                            var corr = this.mirror[i];
                            if (corr != null) {
                                if (result.deleted) {
                                    i = corr;
                                    pos = this.get(corr).recover(result.recover);
                                    continue;
                                } else {
                                    ;
                                    (recoverables || (recoverables = Object.create(null)))[corr] = result.recover;
                                }
                            }
                        }
                        if (result.deleted)
                            deleted = true;
                        pos = result.pos;
                    }
                    return simple ? pos : new MapResult(pos, deleted);
                }
            }, {
                key: "toString",
                value: function toString() {
                    var maps = [];
                    for (var i = -this.head.length; i < this.tail.length; i++) {
                        maps.push(i + ":" + this.get(i) + (this.mirror[i] != null ? "->" + this.mirror[i] : ""));
                    }
                    return maps.join("\n");
                }
            }]);
            return Remapping;
        }();
        function mapThrough(mappables, pos, bias) {
            for (var i = 0; i < mappables.length; i++) {
                pos = mappables[i].map(pos, bias);
            }
            return pos;
        }
        function mapThroughResult(mappables, pos, bias) {
            var deleted = false;
            for (var i = 0; i < mappables.length; i++) {
                var result = mappables[i].mapResult(pos, bias);
                pos = result.pos;
                if (result.deleted)
                    deleted = true;
            }
            return new MapResult(pos, deleted);
        }
        return module.exports;
    });

    $__System.registerDynamic("28", [], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        var process = module.exports = {};
        var queue = [];
        var draining = false;
        var currentQueue;
        var queueIndex = -1;
        function cleanUpNextTick() {
            if (!draining || !currentQueue) {
                return;
            }
            draining = false;
            if (currentQueue.length) {
                queue = currentQueue.concat(queue);
            } else {
                queueIndex = -1;
            }
            if (queue.length) {
                drainQueue();
            }
        }
        function drainQueue() {
            if (draining) {
                return;
            }
            var timeout = setTimeout(cleanUpNextTick);
            draining = true;
            var len = queue.length;
            while (len) {
                currentQueue = queue;
                queue = [];
                while (++queueIndex < len) {
                    if (currentQueue) {
                        currentQueue[queueIndex].run();
                    }
                }
                queueIndex = -1;
                len = queue.length;
            }
            currentQueue = null;
            draining = false;
            clearTimeout(timeout);
        }
        process.nextTick = function(fun) {
            var args = new Array(arguments.length - 1);
            if (arguments.length > 1) {
                for (var i = 1; i < arguments.length; i++) {
                    args[i - 1] = arguments[i];
                }
            }
            queue.push(new Item(fun, args));
            if (queue.length === 1 && !draining) {
                setTimeout(drainQueue, 0);
            }
        };
        function Item(fun, array) {
            this.fun = fun;
            this.array = array;
        }
        Item.prototype.run = function() {
            this.fun.apply(null, this.array);
        };
        process.title = 'browser';
        process.browser = true;
        process.env = {};
        process.argv = [];
        process.version = '';
        process.versions = {};
        function noop() {}
        process.on = noop;
        process.addListener = noop;
        process.once = noop;
        process.off = noop;
        process.removeListener = noop;
        process.removeAllListeners = noop;
        process.emit = noop;
        process.binding = function(name) {
            throw new Error('process.binding is not supported');
        };
        process.cwd = function() {
            return '/';
        };
        process.chdir = function(dir) {
            throw new Error('process.chdir is not supported');
        };
        process.umask = function() {
            return 0;
        };
        return module.exports;
    });

    $__System.registerDynamic("29", ["28"], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        module.exports = $__require('28');
        return module.exports;
    });

    $__System.registerDynamic("2a", ["29"], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        module.exports = $__System._nodeRequire ? process : $__require('29');
        return module.exports;
    });

    $__System.registerDynamic("2b", ["2a"], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        module.exports = $__require('2a');
        return module.exports;
    });

    $__System.registerDynamic("2c", ["6", "22", "23", "16", "2b"], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        (function(process) {
            "use strict";
            var _model = $__require('6');
            var _transform = $__require('22');
            var _step = $__require('23');
            var _map = $__require('16');
            _step.Step.define("replace", {
                apply: function apply(doc, step) {
                    return _step.StepResult.fromReplace(doc, step.from, step.to, step.param);
                },
                posMap: function posMap(step) {
                    return new _map.PosMap([step.from, step.to - step.from, step.param.size]);
                },
                invert: function invert(step, oldDoc) {
                    return new _step.Step("replace", step.from, step.from + step.param.size, oldDoc.slice(step.from, step.to));
                },
                paramToJSON: function paramToJSON(param) {
                    return param.toJSON();
                },
                paramFromJSON: function paramFromJSON(schema, json) {
                    return _model.Slice.fromJSON(schema, json);
                }
            });
            _transform.Transform.prototype.delete = function(from, to) {
                if (from != to)
                    this.replace(from, to, _model.Slice.empty);
                return this;
            };
            _transform.Transform.prototype.replace = function(from) {
                var to = arguments.length <= 1 || arguments[1] === undefined ? from : arguments[1];
                var slice = arguments.length <= 2 || arguments[2] === undefined ? _model.Slice.empty : arguments[2];
                var $from = this.doc.resolve(from),
                    $to = this.doc.resolve(to);
                var _fitSliceInto = fitSliceInto($from, $to, slice);
                var fitted = _fitSliceInto.fitted;
                var distAfter = _fitSliceInto.distAfter;
                var fSize = fitted.size;
                if (from == to && !fSize)
                    return this;
                this.step("replace", from, to, fitted);
                if (!fSize || !$to.parent.isTextblock)
                    return this;
                var after = from + fSize;
                var inner = !slice.size ? from : distAfter < 0 ? -1 : after - distAfter,
                    $inner = undefined;
                if (inner == -1 || inner == after || !($inner = this.doc.resolve(inner)).parent.isTextblock || !$inner.parent.type.canContainFragment($to.parent.content))
                    return this;
                mergeTextblockAfter(this, $inner, this.doc.resolve(after));
                return this;
            };
            _transform.Transform.prototype.replaceWith = function(from, to, content) {
                return this.replace(from, to, new _model.Slice(_model.Fragment.from(content), 0, 0));
            };
            _transform.Transform.prototype.insert = function(pos, content) {
                return this.replaceWith(pos, pos, content);
            };
            _transform.Transform.prototype.insertText = function(pos, text) {
                return this.insert(pos, this.doc.type.schema.text(text, this.doc.marksAt(pos)));
            };
            _transform.Transform.prototype.insertInline = function(pos, node) {
                return this.insert(pos, node.mark(this.doc.marksAt(pos)));
            };
            var distAfter = 0;
            function fitSliceInto($from, $to, slice) {
                var base = $from.sameDepth($to);
                var placed = placeSlice($from, slice),
                    outer = outerPlaced(placed);
                if (outer)
                    base = Math.min(outer.depth, base);
                distAfter = -1e10;
                var fragment = closeFragment($from.node(base).type, fillBetween($from, $to, base, placed), $from, $to, base);
                return {
                    fitted: new _model.Slice(fragment, $from.depth - base, $to.depth - base),
                    distAfter: distAfter - ($to.depth - base)
                };
            }
            function outerPlaced(placed) {
                for (var i = 0; i < placed.length; i++) {
                    if (placed[i])
                        return placed[i];
                }
            }
            function fillBetween($from, $to, depth, placed) {
                var fromNext = $from.depth > depth && $from.node(depth + 1);
                var toNext = $to.depth > depth && $to.node(depth + 1);
                var placedHere = placed[depth];
                if (fromNext && toNext && fromNext.type.canContainContent(toNext.type) && !placedHere)
                    return _model.Fragment.from(closeNode(fromNext, fillBetween($from, $to, depth + 1, placed), $from, $to, depth + 1));
                var content = _model.Fragment.empty;
                if (placedHere) {
                    content = closeLeft(placedHere.content, placedHere.openLeft);
                    if (placedHere.isEnd)
                        distAfter = placedHere.openRight;
                }
                distAfter--;
                if (fromNext)
                    content = content.addToStart(closeNode(fromNext, fillFrom($from, depth + 1, placed), $from, null, depth + 1));
                if (toNext)
                    content = closeTo(content, $to, depth + 1, placedHere ? placedHere.openRight : 0);
                else if (placedHere)
                    content = closeRight(content, placedHere.openRight);
                distAfter++;
                return content;
            }
            function fillFrom($from, depth, placed) {
                var placedHere = placed[depth],
                    content = _model.Fragment.empty;
                if (placedHere) {
                    content = closeRight(placedHere.content, placedHere.openRight);
                    if (placedHere.isEnd)
                        distAfter = placedHere.openRight;
                }
                distAfter--;
                if ($from.depth > depth)
                    content = content.addToStart(closeNode($from.node(depth + 1), fillFrom($from, depth + 1, placed), $from, null, depth + 1));
                distAfter++;
                return content;
            }
            function closeTo(content, $to, depth, openDepth) {
                var after = $to.node(depth);
                if (openDepth == 0 || !after.type.canContainContent(content.lastChild.type)) {
                    var finish = closeNode(after, fillTo($to, depth), null, $to, depth);
                    distAfter += finish.nodeSize;
                    return closeRight(content, openDepth).addToEnd(finish);
                }
                var inner = content.lastChild.content;
                if (depth < $to.depth)
                    inner = closeTo(inner, $to, depth + 1, openDepth - 1);
                return content.replaceChild(content.childCount - 1, after.copy(inner));
            }
            function fillTo(to, depth) {
                if (to.depth == depth)
                    return _model.Fragment.empty;
                return _model.Fragment.from(closeNode(to.node(depth + 1), fillTo(to, depth + 1), null, to, depth + 1));
            }
            function closeRight(content, openDepth) {
                if (openDepth == 0)
                    return content;
                var last = content.lastChild,
                    closed = closeNode(last, closeRight(last.content, openDepth - 1));
                return closed == last ? content : content.replaceChild(content.childCount - 1, closed);
            }
            function closeLeft(content, openDepth) {
                if (openDepth == 0)
                    return content;
                var first = content.firstChild,
                    closed = closeNode(first, first.content);
                return closed == first ? content : content.replaceChild(0, closed);
            }
            function closeFragment(type, content, $to, $from, depth) {
                if (type.canBeEmpty)
                    return content;
                var hasContent = content.size || $to && ($to.depth > depth || $to.index(depth)) || $from && ($from.depth > depth || $from.index(depth) < $from.node(depth).childCount);
                return hasContent ? content : type.defaultContent();
            }
            function closeNode(node, content, $to, $from, depth) {
                return node.copy(closeFragment(node.type, content, $to, $from, depth));
            }
            function nodeLeft(slice, depth) {
                var content = slice.content;
                for (var i = 1; i < depth; i++) {
                    content = content.firstChild.content;
                }
                return content.firstChild;
            }
            function placeSlice($from, slice) {
                var dFrom = $from.depth,
                    unplaced = null,
                    openLeftUnplaced = 0;
                var placed = [],
                    parents = null;
                for (var dSlice = slice.openLeft; ; --dSlice) {
                    var curType = undefined,
                        curAttrs = undefined,
                        curFragment = undefined;
                    if (dSlice >= 0) {
                        if (dSlice > 0) {
                            ;
                            var _nodeLeft = nodeLeft(slice, dSlice);
                            curType = _nodeLeft.type;
                            curAttrs = _nodeLeft.attrs;
                            curFragment = _nodeLeft.content;
                        } else if (dSlice == 0) {
                            curFragment = slice.content;
                        }
                        if (dSlice < slice.openLeft)
                            curFragment = curFragment.cut(curFragment.firstChild.nodeSize);
                    } else {
                        curFragment = _model.Fragment.empty;
                        curType = parents[parents.length + dSlice - 1];
                    }
                    if (unplaced)
                        curFragment = curFragment.addToStart(unplaced);
                    if (curFragment.size == 0 && dSlice <= 0)
                        break;
                    var found = findPlacement(curType, curFragment, $from, dFrom);
                    if (found > -1) {
                        if (curFragment.size > 0)
                            placed[found] = {
                                content: curFragment,
                                openLeft: openLeftUnplaced,
                                openRight: dSlice > 0 ? 0 : slice.openRight - dSlice,
                                isEnd: dSlice <= 0,
                                depth: found
                            };
                        if (dSlice <= 0)
                            break;
                        unplaced = null;
                        openLeftUnplaced = 0;
                        dFrom = Math.max(0, found - 1);
                    } else {
                        if (dSlice == 0) {
                            parents = $from.node(0).type.findConnectionToKind(curFragment.leastSuperKind());
                            if (!parents)
                                break;
                            parents.unshift($from.node(0).type);
                            curType = parents[parents.length - 1];
                        }
                        unplaced = curType.create(curAttrs, curFragment);
                        openLeftUnplaced++;
                    }
                }
                return placed;
            }
            function findPlacement(type, fragment, $from, start) {
                for (var d = start; d >= 0; d--) {
                    var fromType = $from.node(d).type;
                    if (type ? fromType.canContainContent(type) : fromType.canContainFragment(fragment))
                        return d;
                }
                return -1;
            }
            function mergeTextblockAfter(tr, $inside, $after) {
                var base = $inside.sameDepth($after);
                var end = $after.end($after.depth),
                    cutAt = end + 1,
                    cutDepth = $after.depth - 1;
                while (cutDepth > base && $after.index(cutDepth) + 1 == $after.node(cutDepth).childCount) {
                    --cutDepth;
                    ++cutAt;
                }
                if (cutDepth > base)
                    tr.split(cutAt, cutDepth - base);
                var types = [],
                    attrs = [];
                for (var i = base + 1; i <= $inside.depth; i++) {
                    var node = $inside.node(i);
                    types.push(node.type);
                    attrs.push(node.attrs);
                }
                tr.step("ancestor", $after.pos, end, {
                    depth: $after.depth - base,
                    types: types,
                    attrs: attrs
                });
                tr.join($after.pos - ($after.depth - base), $inside.depth - base);
            }
        })($__require('2b'));
        return module.exports;
    });

    $__System.registerDynamic("19", ["22", "23", "21", "24", "16", "25", "26", "2c"], true, function($__require, exports, module) {
        "use strict";
        ;
        var define,
            global = this,
            GLOBAL = this;
        Object.defineProperty(exports, "__esModule", {value: true});
        exports.Remapping = exports.MapResult = exports.PosMap = exports.joinable = exports.joinPoint = exports.canWrap = exports.canLift = exports.StepResult = exports.Step = exports.TransformError = exports.Transform = undefined;
        var _transform = $__require('22');
        Object.defineProperty(exports, "Transform", {
            enumerable: true,
            get: function get() {
                return _transform.Transform;
            }
        });
        Object.defineProperty(exports, "TransformError", {
            enumerable: true,
            get: function get() {
                return _transform.TransformError;
            }
        });
        var _step = $__require('23');
        Object.defineProperty(exports, "Step", {
            enumerable: true,
            get: function get() {
                return _step.Step;
            }
        });
        Object.defineProperty(exports, "StepResult", {
            enumerable: true,
            get: function get() {
                return _step.StepResult;
            }
        });
        var _ancestor = $__require('21');
        Object.defineProperty(exports, "canLift", {
            enumerable: true,
            get: function get() {
                return _ancestor.canLift;
            }
        });
        Object.defineProperty(exports, "canWrap", {
            enumerable: true,
            get: function get() {
                return _ancestor.canWrap;
            }
        });
        var _join = $__require('24');
        Object.defineProperty(exports, "joinPoint", {
            enumerable: true,
            get: function get() {
                return _join.joinPoint;
            }
        });
        Object.defineProperty(exports, "joinable", {
            enumerable: true,
            get: function get() {
                return _join.joinable;
            }
        });
        var _map = $__require('16');
        Object.defineProperty(exports, "PosMap", {
            enumerable: true,
            get: function get() {
                return _map.PosMap;
            }
        });
        Object.defineProperty(exports, "MapResult", {
            enumerable: true,
            get: function get() {
                return _map.MapResult;
            }
        });
        Object.defineProperty(exports, "Remapping", {
            enumerable: true,
            get: function get() {
                return _map.Remapping;
            }
        });
        $__require('25');
        $__require('26');
        $__require('2c');
        return module.exports;
    });

    $__System.registerDynamic("2d", [], true, function($__require, exports, module) {
        "use strict";
        ;
        var define,
            global = this,
            GLOBAL = this;
        Object.defineProperty(exports, "__esModule", {value: true});
        exports.isWordChar = isWordChar;
        exports.charCategory = charCategory;
        exports.isExtendingChar = isExtendingChar;
        var nonASCIISingleCaseWordChar = /[\u00df\u0587\u0590-\u05f4\u0600-\u06ff\u3040-\u309f\u30a0-\u30ff\u3400-\u4db5\u4e00-\u9fcc\uac00-\ud7af]/;
        var extendingChar = /[\u0300-\u036f\u0483-\u0489\u0591-\u05bd\u05bf\u05c1\u05c2\u05c4\u05c5\u05c7\u0610-\u061a\u064b-\u065e\u0670\u06d6-\u06dc\u06de-\u06e4\u06e7\u06e8\u06ea-\u06ed\u0711\u0730-\u074a\u07a6-\u07b0\u07eb-\u07f3\u0816-\u0819\u081b-\u0823\u0825-\u0827\u0829-\u082d\u0900-\u0902\u093c\u0941-\u0948\u094d\u0951-\u0955\u0962\u0963\u0981\u09bc\u09be\u09c1-\u09c4\u09cd\u09d7\u09e2\u09e3\u0a01\u0a02\u0a3c\u0a41\u0a42\u0a47\u0a48\u0a4b-\u0a4d\u0a51\u0a70\u0a71\u0a75\u0a81\u0a82\u0abc\u0ac1-\u0ac5\u0ac7\u0ac8\u0acd\u0ae2\u0ae3\u0b01\u0b3c\u0b3e\u0b3f\u0b41-\u0b44\u0b4d\u0b56\u0b57\u0b62\u0b63\u0b82\u0bbe\u0bc0\u0bcd\u0bd7\u0c3e-\u0c40\u0c46-\u0c48\u0c4a-\u0c4d\u0c55\u0c56\u0c62\u0c63\u0cbc\u0cbf\u0cc2\u0cc6\u0ccc\u0ccd\u0cd5\u0cd6\u0ce2\u0ce3\u0d3e\u0d41-\u0d44\u0d4d\u0d57\u0d62\u0d63\u0dca\u0dcf\u0dd2-\u0dd4\u0dd6\u0ddf\u0e31\u0e34-\u0e3a\u0e47-\u0e4e\u0eb1\u0eb4-\u0eb9\u0ebb\u0ebc\u0ec8-\u0ecd\u0f18\u0f19\u0f35\u0f37\u0f39\u0f71-\u0f7e\u0f80-\u0f84\u0f86\u0f87\u0f90-\u0f97\u0f99-\u0fbc\u0fc6\u102d-\u1030\u1032-\u1037\u1039\u103a\u103d\u103e\u1058\u1059\u105e-\u1060\u1071-\u1074\u1082\u1085\u1086\u108d\u109d\u135f\u1712-\u1714\u1732-\u1734\u1752\u1753\u1772\u1773\u17b7-\u17bd\u17c6\u17c9-\u17d3\u17dd\u180b-\u180d\u18a9\u1920-\u1922\u1927\u1928\u1932\u1939-\u193b\u1a17\u1a18\u1a56\u1a58-\u1a5e\u1a60\u1a62\u1a65-\u1a6c\u1a73-\u1a7c\u1a7f\u1b00-\u1b03\u1b34\u1b36-\u1b3a\u1b3c\u1b42\u1b6b-\u1b73\u1b80\u1b81\u1ba2-\u1ba5\u1ba8\u1ba9\u1c2c-\u1c33\u1c36\u1c37\u1cd0-\u1cd2\u1cd4-\u1ce0\u1ce2-\u1ce8\u1ced\u1dc0-\u1de6\u1dfd-\u1dff\u200c\u200d\u20d0-\u20f0\u2cef-\u2cf1\u2de0-\u2dff\u302a-\u302f\u3099\u309a\ua66f-\ua672\ua67c\ua67d\ua6f0\ua6f1\ua802\ua806\ua80b\ua825\ua826\ua8c4\ua8e0-\ua8f1\ua926-\ua92d\ua947-\ua951\ua980-\ua982\ua9b3\ua9b6-\ua9b9\ua9bc\uaa29-\uaa2e\uaa31\uaa32\uaa35\uaa36\uaa43\uaa4c\uaab0\uaab2-\uaab4\uaab7\uaab8\uaabe\uaabf\uaac1\uabe5\uabe8\uabed\udc00-\udfff\ufb1e\ufe00-\ufe0f\ufe20-\ufe26\uff9e\uff9f]/;
        function isWordChar(ch) {
            return (/\w/.test(ch) || isExtendingChar(ch) || ch > "\x80" && (ch.toUpperCase() != ch.toLowerCase() || nonASCIISingleCaseWordChar.test(ch)));
        }
        function charCategory(ch) {
            return (/\s/.test(ch) ? "space" : isWordChar(ch) ? "word" : "other");
        }
        function isExtendingChar(ch) {
            return ch.charCodeAt(0) >= 768 && extendingChar.test(ch);
        }
        return module.exports;
    });

    $__System.registerDynamic("11", ["8"], true, function($__require, exports, module) {
        "use strict";
        ;
        var define,
            global = this,
            GLOBAL = this;
        Object.defineProperty(exports, "__esModule", {value: true});
        exports.posBeforeFromDOM = posBeforeFromDOM;
        exports.posFromDOM = posFromDOM;
        exports.childContainer = childContainer;
        exports.DOMFromPos = DOMFromPos;
        exports.DOMAfterPos = DOMAfterPos;
        exports.scrollIntoView = scrollIntoView;
        exports.posAtCoords = posAtCoords;
        exports.coordsAtPos = coordsAtPos;
        exports.selectableNodeAbove = selectableNodeAbove;
        exports.handleNodeClick = handleNodeClick;
        var _dom = $__require('8');
        function posBeforeFromDOM(pm, node) {
            var pos = 0,
                add = 0;
            for (var cur = node; cur != pm.content; cur = cur.parentNode) {
                var attr = cur.getAttribute("pm-offset");
                if (attr) {
                    pos += +attr + add;
                    add = 1;
                }
            }
            return pos;
        }
        function posFromDOM(pm, dom, domOffset) {
            if (pm.operation && pm.doc != pm.operation.doc)
                throw new RangeError("Fetching a position from an outdated DOM structure");
            if (domOffset == null) {
                domOffset = Array.prototype.indexOf.call(dom.parentNode.childNodes, dom);
                dom = dom.parentNode;
            }
            var innerOffset = 0,
                tag = undefined;
            for (; ; ) {
                var adjust = 0;
                if (dom.nodeType == 3) {
                    innerOffset += domOffset;
                } else if (tag = dom.getAttribute("pm-offset") && !childContainer(dom)) {
                    var size = +dom.getAttribute("pm-size");
                    return posBeforeFromDOM(pm, dom) + (domOffset == dom.childNodes.length ? size : Math.min(innerOffset, size));
                } else if (dom.hasAttribute("pm-container")) {
                    break;
                } else if (tag = dom.getAttribute("pm-inner-offset")) {
                    innerOffset += +tag;
                    adjust = -1;
                } else if (domOffset && domOffset == dom.childNodes.length) {
                    adjust = 1;
                }
                var parent = dom.parentNode;
                domOffset = adjust < 0 ? 0 : Array.prototype.indexOf.call(parent.childNodes, dom) + adjust;
                dom = parent;
            }
            var start = dom == pm.content ? 0 : posBeforeFromDOM(pm, dom) + 1,
                before = 0;
            for (var child = dom.childNodes[domOffset - 1]; child; child = child.previousSibling) {
                if (child.nodeType == 1 && (tag = child.getAttribute("pm-offset"))) {
                    before += +tag + +child.getAttribute("pm-size");
                    break;
                }
            }
            return start + before + innerOffset;
        }
        function childContainer(dom) {
            return dom.hasAttribute("pm-container") ? dom : dom.querySelector("[pm-container]");
        }
        function DOMFromPos(pm, pos, liberal) {
            if (!liberal && pm.operation && pm.doc != pm.operation.doc)
                throw new RangeError("Resolving a position in an outdated DOM structure");
            var container = pm.content,
                offset = pos;
            outer: for (; ; ) {
                for (var child = container.firstChild,
                         i = 0; ; child = child.nextSibling, i++) {
                    if (!child) {
                        if (offset && !liberal)
                            throw new RangeError("Failed to find node at " + pos + " rem = " + offset);
                        return {
                            node: container,
                            offset: i
                        };
                    }
                    var size = child.nodeType == 1 && child.getAttribute("pm-size");
                    if (size) {
                        if (!offset)
                            return {
                                node: container,
                                offset: i
                            };
                        size = +size;
                        if (offset < size) {
                            container = childContainer(child);
                            if (!container) {
                                return leafAt(child, offset);
                            } else {
                                offset--;
                                break;
                            }
                        } else {
                            offset -= size;
                        }
                    }
                }
            }
        }
        function DOMAfterPos(pm, pos) {
            var _DOMFromPos = DOMFromPos(pm, pos);
            var node = _DOMFromPos.node;
            var offset = _DOMFromPos.offset;
            if (node.nodeType != 1 || offset == node.childNodes.length)
                throw new RangeError("No node after pos " + pos);
            return node.childNodes[offset];
        }
        function leafAt(node, offset) {
            for (; ; ) {
                var child = node.firstChild;
                if (!child)
                    return {
                        node: node,
                        offset: offset
                    };
                if (child.nodeType != 1)
                    return {
                        node: child,
                        offset: offset
                    };
                if (child.hasAttribute("pm-inner-offset")) {
                    var nodeOffset = 0;
                    for (; ; ) {
                        var nextSib = child.nextSibling,
                            nextOffset = undefined;
                        if (!nextSib || (nextOffset = +nextSib.getAttribute("pm-inner-offset")) >= offset)
                            break;
                        child = nextSib;
                        nodeOffset = nextOffset;
                    }
                    offset -= nodeOffset;
                }
                node = child;
            }
        }
        function windowRect() {
            return {
                left: 0,
                right: window.innerWidth,
                top: 0,
                bottom: window.innerHeight
            };
        }
        var scrollMargin = 5;
        function scrollIntoView(pm, pos) {
            if (!pos)
                pos = pm.sel.range.head || pm.sel.range.from;
            var coords = coordsAtPos(pm, pos);
            for (var parent = pm.content; ; parent = parent.parentNode) {
                var atBody = parent == document.body;
                var rect = atBody ? windowRect() : parent.getBoundingClientRect();
                var moveX = 0,
                    moveY = 0;
                if (coords.top < rect.top)
                    moveY = -(rect.top - coords.top + scrollMargin);
                else if (coords.bottom > rect.bottom)
                    moveY = coords.bottom - rect.bottom + scrollMargin;
                if (coords.left < rect.left)
                    moveX = -(rect.left - coords.left + scrollMargin);
                else if (coords.right > rect.right)
                    moveX = coords.right - rect.right + scrollMargin;
                if (moveX || moveY) {
                    if (atBody) {
                        window.scrollBy(moveX, moveY);
                    } else {
                        if (moveY)
                            parent.scrollTop += moveY;
                        if (moveX)
                            parent.scrollLeft += moveX;
                    }
                }
                if (atBody)
                    break;
            }
        }
        function findOffsetInNode(node, coords) {
            var closest = undefined,
                dyClosest = 1e8,
                coordsClosest = undefined,
                offset = 0;
            for (var child = node.firstChild; child; child = child.nextSibling) {
                var rects = undefined;
                if (child.nodeType == 1)
                    rects = child.getClientRects();
                else if (child.nodeType == 3)
                    rects = textRects(child);
                else
                    continue;
                for (var i = 0; i < rects.length; i++) {
                    var rect = rects[i];
                    if (rect.left <= coords.left && rect.right >= coords.left) {
                        var dy = rect.top > coords.top ? rect.top - coords.top : rect.bottom < coords.top ? coords.top - rect.bottom : 0;
                        if (dy < dyClosest) {
                            closest = child;
                            dyClosest = dy;
                            coordsClosest = dy ? {
                                left: coords.left,
                                top: rect.top
                            } : coords;
                            if (child.nodeType == 1 && !child.firstChild)
                                offset = i + (coords.left >= (rect.left + rect.right) / 2 ? 1 : 0);
                            continue;
                        }
                    }
                    if (!closest && (coords.top >= rect.bottom || coords.top >= rect.top && coords.left >= rect.right))
                        offset = i + 1;
                }
            }
            if (!closest)
                return {
                    node: node,
                    offset: offset
                };
            if (closest.nodeType == 3)
                return findOffsetInText(closest, coordsClosest);
            if (closest.firstChild)
                return findOffsetInNode(closest, coordsClosest);
            return {
                node: node,
                offset: offset
            };
        }
        function findOffsetInText(node, coords) {
            var len = node.nodeValue.length;
            var range = document.createRange();
            for (var i = 0; i < len; i++) {
                range.setEnd(node, i + 1);
                range.setStart(node, i);
                var rect = range.getBoundingClientRect();
                if (rect.top == rect.bottom)
                    continue;
                if (rect.left - 1 <= coords.left && rect.right + 1 >= coords.left && rect.top - 1 <= coords.top && rect.bottom + 1 >= coords.top)
                    return {
                        node: node,
                        offset: i + (coords.left >= (rect.left + rect.right) / 2 ? 1 : 0)
                    };
            }
            return {
                node: node,
                offset: 0
            };
        }
        function posAtCoords(pm, coords) {
            var elt = document.elementFromPoint(coords.left, coords.top + 1);
            if (!(0, _dom.contains)(pm.content, elt))
                return null;
            if (!elt.firstChild)
                elt = elt.parentNode;
            var _findOffsetInNode = findOffsetInNode(elt, coords);
            var node = _findOffsetInNode.node;
            var offset = _findOffsetInNode.offset;
            return posFromDOM(pm, node, offset);
        }
        function textRect(node, from, to) {
            var range = document.createRange();
            range.setEnd(node, to);
            range.setStart(node, from);
            return range.getBoundingClientRect();
        }
        function textRects(node) {
            var range = document.createRange();
            range.setEnd(node, node.nodeValue.length);
            range.setStart(node, 0);
            return range.getClientRects();
        }
        function coordsAtPos(pm, pos) {
            var _DOMFromPos2 = DOMFromPos(pm, pos);
            var node = _DOMFromPos2.node;
            var offset = _DOMFromPos2.offset;
            var side = undefined,
                rect = undefined;
            if (node.nodeType == 3) {
                if (offset < node.nodeValue.length) {
                    rect = textRect(node, offset, offset + 1);
                    side = "left";
                }
                if ((!rect || rect.left == rect.right) && offset) {
                    rect = textRect(node, offset - 1, offset);
                    side = "right";
                }
            } else if (node.firstChild) {
                if (offset < node.childNodes.length) {
                    var child = node.childNodes[offset];
                    rect = child.nodeType == 3 ? textRect(child, 0, child.nodeValue.length) : child.getBoundingClientRect();
                    side = "left";
                }
                if ((!rect || rect.left == rect.right) && offset) {
                    var child = node.childNodes[offset - 1];
                    rect = child.nodeType == 3 ? textRect(child, 0, child.nodeValue.length) : child.getBoundingClientRect();
                    side = "right";
                }
            } else {
                rect = node.getBoundingClientRect();
                side = "left";
            }
            var x = rect[side];
            return {
                top: rect.top,
                bottom: rect.bottom,
                left: x,
                right: x
            };
        }
        function selectableNodeAbove(pm, dom, coords, liberal) {
            for (; dom && dom != pm.content; dom = dom.parentNode) {
                if (dom.hasAttribute("pm-offset")) {
                    var pos = posBeforeFromDOM(pm, dom),
                        node = pm.doc.nodeAt(pos);
                    if (node.type.countCoordsAsChild) {
                        var result = node.type.countCoordsAsChild(node, pos, dom, coords);
                        if (result != null)
                            return result;
                    }
                    if ((liberal || node.type.contains == null) && node.type.selectable)
                        return pos;
                    if (!liberal)
                        return null;
                }
            }
        }
        function handleNodeClick(pm, type, event, target, direct) {
            for (var dom = target; dom && dom != pm.content; dom = dom.parentNode) {
                if (dom.hasAttribute("pm-offset")) {
                    var pos = posBeforeFromDOM(pm, dom),
                        node = pm.doc.nodeAt(pos);
                    var handled = node.type[type] && node.type[type](pm, event, pos, node) !== false;
                    if (direct || handled)
                        return handled;
                }
            }
        }
        return module.exports;
    });

    $__System.registerDynamic("13", ["8", "11"], true, function($__require, exports, module) {
        "use strict";
        ;
        var define,
            global = this,
            GLOBAL = this;
        Object.defineProperty(exports, "__esModule", {value: true});
        exports.NodeSelection = exports.TextSelection = exports.Selection = exports.SelectionState = undefined;
        var _createClass = function() {
            function defineProperties(target, props) {
                for (var i = 0; i < props.length; i++) {
                    var descriptor = props[i];
                    descriptor.enumerable = descriptor.enumerable || false;
                    descriptor.configurable = true;
                    if ("value" in descriptor)
                        descriptor.writable = true;
                    Object.defineProperty(target, descriptor.key, descriptor);
                }
            }
            return function(Constructor, protoProps, staticProps) {
                if (protoProps)
                    defineProperties(Constructor.prototype, protoProps);
                if (staticProps)
                    defineProperties(Constructor, staticProps);
                return Constructor;
            };
        }();
        exports.hasFocus = hasFocus;
        exports.findSelectionFrom = findSelectionFrom;
        exports.findSelectionNear = findSelectionNear;
        exports.findSelectionAtStart = findSelectionAtStart;
        exports.findSelectionAtEnd = findSelectionAtEnd;
        exports.verticalMotionLeavesTextblock = verticalMotionLeavesTextblock;
        var _dom = $__require('8');
        var _dompos = $__require('11');
        function _possibleConstructorReturn(self, call) {
            if (!self) {
                throw new ReferenceError("this hasn't been initialised - super() hasn't been called");
            }
            return call && (typeof call === "object" || typeof call === "function") ? call : self;
        }
        function _inherits(subClass, superClass) {
            if (typeof superClass !== "function" && superClass !== null) {
                throw new TypeError("Super expression must either be null or a function, not " + typeof superClass);
            }
            subClass.prototype = Object.create(superClass && superClass.prototype, {constructor: {
                value: subClass,
                enumerable: false,
                writable: true,
                configurable: true
            }});
            if (superClass)
                Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass;
        }
        function _classCallCheck(instance, Constructor) {
            if (!(instance instanceof Constructor)) {
                throw new TypeError("Cannot call a class as a function");
            }
        }
        var SelectionState = exports.SelectionState = function() {
            function SelectionState(pm, range) {
                var _this = this;
                _classCallCheck(this, SelectionState);
                this.pm = pm;
                this.range = range;
                this.polling = null;
                this.lastAnchorNode = this.lastHeadNode = this.lastAnchorOffset = this.lastHeadOffset = null;
                this.lastNode = null;
                pm.content.addEventListener("focus", function() {
                    return _this.receivedFocus();
                });
                this.poller = this.poller.bind(this);
            }
            _createClass(SelectionState, [{
                key: "setAndSignal",
                value: function setAndSignal(range, clearLast) {
                    this.set(range, clearLast);
                    this.pm.signal("selectionChange");
                }
            }, {
                key: "set",
                value: function set(range, clearLast) {
                    this.pm.ensureOperation({readSelection: false});
                    this.range = range;
                    if (clearLast !== false)
                        this.lastAnchorNode = null;
                }
            }, {
                key: "poller",
                value: function poller() {
                    if (hasFocus(this.pm)) {
                        if (!this.pm.operation)
                            this.readFromDOM();
                        this.polling = setTimeout(this.poller, 100);
                    } else {
                        this.polling = null;
                    }
                }
            }, {
                key: "startPolling",
                value: function startPolling() {
                    clearTimeout(this.polling);
                    this.polling = setTimeout(this.poller, 50);
                }
            }, {
                key: "fastPoll",
                value: function fastPoll() {
                    this.startPolling();
                }
            }, {
                key: "stopPolling",
                value: function stopPolling() {
                    clearTimeout(this.polling);
                    this.polling = null;
                }
            }, {
                key: "domChanged",
                value: function domChanged() {
                    var sel = window.getSelection();
                    return sel.anchorNode != this.lastAnchorNode || sel.anchorOffset != this.lastAnchorOffset || sel.focusNode != this.lastHeadNode || sel.focusOffset != this.lastHeadOffset;
                }
            }, {
                key: "storeDOMState",
                value: function storeDOMState() {
                    var sel = window.getSelection();
                    this.lastAnchorNode = sel.anchorNode;
                    this.lastAnchorOffset = sel.anchorOffset;
                    this.lastHeadNode = sel.focusNode;
                    this.lastHeadOffset = sel.focusOffset;
                }
            }, {
                key: "readFromDOM",
                value: function readFromDOM() {
                    if (!hasFocus(this.pm) || !this.domChanged())
                        return false;
                    var sel = window.getSelection(),
                        doc = this.pm.doc;
                    var anchor = (0, _dompos.posFromDOM)(this.pm, sel.anchorNode, sel.anchorOffset);
                    var head = sel.isCollapsed ? anchor : (0, _dompos.posFromDOM)(this.pm, sel.focusNode, sel.focusOffset);
                    var newRange = findSelectionNear(doc, head, this.range.head != null && this.range.head < head ? 1 : -1);
                    if (newRange instanceof TextSelection) {
                        var selNearAnchor = findSelectionNear(doc, anchor, anchor > newRange.to ? -1 : 1, true);
                        newRange = new TextSelection(selNearAnchor.anchor, newRange.head);
                    } else if (anchor < newRange.from || anchor > newRange.to) {
                        var inv = anchor > newRange.to;
                        newRange = new TextSelection(findSelectionNear(doc, anchor, inv ? -1 : 1, true).anchor, findSelectionNear(doc, inv ? newRange.from : newRange.to, inv ? 1 : -1, true).head);
                    }
                    this.setAndSignal(newRange);
                    if (newRange instanceof NodeSelection || newRange.head != head || newRange.anchor != anchor) {
                        this.toDOM();
                    } else {
                        this.clearNode();
                        this.storeDOMState();
                    }
                    return true;
                }
            }, {
                key: "toDOM",
                value: function toDOM(takeFocus) {
                    if (!hasFocus(this.pm)) {
                        if (!takeFocus)
                            return;
                        else if (_dom.browser.gecko)
                            this.pm.content.focus();
                    }
                    if (this.range instanceof NodeSelection)
                        this.nodeToDOM();
                    else
                        this.rangeToDOM();
                }
            }, {
                key: "nodeToDOM",
                value: function nodeToDOM() {
                    var dom = (0, _dompos.DOMAfterPos)(this.pm, this.range.from);
                    if (dom != this.lastNode) {
                        this.clearNode();
                        dom.classList.add("ProseMirror-selectednode");
                        this.pm.content.classList.add("ProseMirror-nodeselection");
                        this.lastNode = dom;
                    }
                    var range = document.createRange(),
                        sel = window.getSelection();
                    range.selectNode(dom);
                    sel.removeAllRanges();
                    sel.addRange(range);
                    this.storeDOMState();
                }
            }, {
                key: "rangeToDOM",
                value: function rangeToDOM() {
                    this.clearNode();
                    var anchor = (0, _dompos.DOMFromPos)(this.pm, this.range.anchor);
                    var head = (0, _dompos.DOMFromPos)(this.pm, this.range.head);
                    var sel = window.getSelection(),
                        range = document.createRange();
                    if (sel.extend) {
                        range.setEnd(anchor.node, anchor.offset);
                        range.collapse(false);
                    } else {
                        if (this.range.anchor > this.range.head) {
                            var tmp = anchor;
                            anchor = head;
                            head = tmp;
                        }
                        range.setEnd(head.node, head.offset);
                        range.setStart(anchor.node, anchor.offset);
                    }
                    sel.removeAllRanges();
                    sel.addRange(range);
                    if (sel.extend)
                        sel.extend(head.node, head.offset);
                    this.storeDOMState();
                }
            }, {
                key: "clearNode",
                value: function clearNode() {
                    if (this.lastNode) {
                        this.lastNode.classList.remove("ProseMirror-selectednode");
                        this.pm.content.classList.remove("ProseMirror-nodeselection");
                        this.lastNode = null;
                        return true;
                    }
                }
            }, {
                key: "receivedFocus",
                value: function receivedFocus() {
                    if (this.polling == null)
                        this.startPolling();
                }
            }]);
            return SelectionState;
        }();
        var Selection = exports.Selection = function Selection() {
            _classCallCheck(this, Selection);
        };
        var TextSelection = exports.TextSelection = function(_Selection) {
            _inherits(TextSelection, _Selection);
            function TextSelection(anchor, head) {
                _classCallCheck(this, TextSelection);
                var _this2 = _possibleConstructorReturn(this, Object.getPrototypeOf(TextSelection).call(this));
                _this2.anchor = anchor;
                _this2.head = head == null ? anchor : head;
                return _this2;
            }
            _createClass(TextSelection, [{
                key: "eq",
                value: function eq(other) {
                    return other instanceof TextSelection && other.head == this.head && other.anchor == this.anchor;
                }
            }, {
                key: "map",
                value: function map(doc, mapping) {
                    var head = mapping.map(this.head);
                    if (!doc.resolve(head).parent.isTextblock)
                        return findSelectionNear(doc, head);
                    var anchor = mapping.map(this.anchor);
                    return new TextSelection(doc.resolve(anchor).parent.isTextblock ? anchor : head, head);
                }
            }, {
                key: "inverted",
                get: function get() {
                    return this.anchor > this.head;
                }
            }, {
                key: "from",
                get: function get() {
                    return Math.min(this.head, this.anchor);
                }
            }, {
                key: "to",
                get: function get() {
                    return Math.max(this.head, this.anchor);
                }
            }, {
                key: "empty",
                get: function get() {
                    return this.anchor == this.head;
                }
            }, {
                key: "token",
                get: function get() {
                    return new SelectionToken(TextSelection, this.anchor, this.head);
                }
            }], [{
                key: "mapToken",
                value: function mapToken(token, mapping) {
                    return new SelectionToken(TextSelection, mapping.map(token.a), mapping.map(token.b));
                }
            }, {
                key: "fromToken",
                value: function fromToken(token, doc) {
                    if (!doc.resolve(token.b).parent.isTextblock)
                        return findSelectionNear(doc, token.b);
                    return new TextSelection(doc.resolve(token.a).parent.isTextblock ? token.a : token.b, token.b);
                }
            }]);
            return TextSelection;
        }(Selection);
        var NodeSelection = exports.NodeSelection = function(_Selection2) {
            _inherits(NodeSelection, _Selection2);
            function NodeSelection(from, to, node) {
                _classCallCheck(this, NodeSelection);
                var _this3 = _possibleConstructorReturn(this, Object.getPrototypeOf(NodeSelection).call(this));
                _this3.from = from;
                _this3.to = to;
                _this3.node = node;
                return _this3;
            }
            _createClass(NodeSelection, [{
                key: "eq",
                value: function eq(other) {
                    return other instanceof NodeSelection && this.from == other.from;
                }
            }, {
                key: "map",
                value: function map(doc, mapping) {
                    var from = mapping.map(this.from, 1);
                    var to = mapping.map(this.to, -1);
                    var node = doc.nodeAt(from);
                    if (node && to == from + node.nodeSize && node.type.selectable)
                        return new NodeSelection(from, to, node);
                    return findSelectionNear(doc, from);
                }
            }, {
                key: "empty",
                get: function get() {
                    return false;
                }
            }, {
                key: "token",
                get: function get() {
                    return new SelectionToken(NodeSelection, this.from, this.to);
                }
            }], [{
                key: "mapToken",
                value: function mapToken(token, mapping) {
                    return new SelectionToken(TextSelection, mapping.map(token.a, 1), mapping.map(token.b, -1));
                }
            }, {
                key: "fromToken",
                value: function fromToken(token, doc) {
                    var node = doc.nodeAt(token.a);
                    if (node && token.b == token.a + node.nodeSize && node.type.selectable)
                        return new NodeSelection(token.a, token.b, node);
                    return findSelectionNear(doc, token.a);
                }
            }]);
            return NodeSelection;
        }(Selection);
        var SelectionToken = function SelectionToken(type, a, b) {
            _classCallCheck(this, SelectionToken);
            this.type = type;
            this.a = a;
            this.b = b;
        };
        function hasFocus(pm) {
            if (document.activeElement != pm.content)
                return false;
            var sel = window.getSelection();
            return sel.rangeCount && (0, _dom.contains)(pm.content, sel.anchorNode);
        }
        function findSelectionIn(node, pos, index, dir, text) {
            for (var i = index - (dir > 0 ? 0 : 1); dir > 0 ? i < node.childCount : i >= 0; i += dir) {
                var child = node.child(i);
                if (child.isTextblock)
                    return new TextSelection(pos + dir);
                if (child.type.contains) {
                    var inner = findSelectionIn(child, pos + dir, dir < 0 ? child.childCount : 0, dir, text);
                    if (inner)
                        return inner;
                } else if (!text && child.type.selectable) {
                    return new NodeSelection(pos - (dir < 0 ? child.nodeSize : 0), pos + (dir > 0 ? child.nodeSize : 0), child);
                }
                pos += child.nodeSize * dir;
            }
        }
        function findSelectionFrom(doc, pos, dir, text) {
            var $pos = doc.resolve(pos);
            var inner = $pos.parent.isTextblock ? new TextSelection(pos) : findSelectionIn($pos.parent, pos, $pos.index($pos.depth), dir, text);
            if (inner)
                return inner;
            for (var depth = $pos.depth - 1; depth >= 0; depth--) {
                var found = dir < 0 ? findSelectionIn($pos.node(depth), $pos.before(depth + 1), $pos.index(depth), dir, text) : findSelectionIn($pos.node(depth), $pos.after(depth + 1), $pos.index(depth) + 1, dir, text);
                if (found)
                    return found;
            }
        }
        function findSelectionNear(doc, pos) {
            var bias = arguments.length <= 2 || arguments[2] === undefined ? 1 : arguments[2];
            var text = arguments[3];
            var result = findSelectionFrom(doc, pos, bias, text) || findSelectionFrom(doc, pos, -bias, text);
            if (!result)
                throw new RangeError("Searching for selection in invalid document " + doc);
            return result;
        }
        function findSelectionAtStart(node, text) {
            return findSelectionIn(node, 0, 0, 1, text);
        }
        function findSelectionAtEnd(node, text) {
            return findSelectionIn(node, node.content.size, node.childCount, -1, text);
        }
        function verticalMotionLeavesTextblock(pm, pos, dir) {
            var $pos = pm.doc.resolve(pos);
            var dom = (0, _dompos.DOMAfterPos)(pm, $pos.before($pos.depth));
            var coords = (0, _dompos.coordsAtPos)(pm, pos);
            for (var child = dom.firstChild; child; child = child.nextSibling) {
                if (child.nodeType != 1)
                    continue;
                var boxes = child.getClientRects();
                for (var i = 0; i < boxes.length; i++) {
                    var box = boxes[i];
                    if (dir < 0 ? box.bottom < coords.top : box.top > coords.bottom)
                        return false;
                }
            }
            return true;
        }
        return module.exports;
    });

    $__System.registerDynamic("2e", ["19", "2d", "13"], true, function($__require, exports, module) {
        "use strict";
        ;
        var define,
            global = this,
            GLOBAL = this;
        Object.defineProperty(exports, "__esModule", {value: true});
        exports.baseCommands = undefined;
        var _transform = $__require('19');
        var _char = $__require('2d');
        var _selection = $__require('13');
        function _toConsumableArray(arr) {
            if (Array.isArray(arr)) {
                for (var i = 0,
                         arr2 = Array(arr.length); i < arr.length; i++) {
                    arr2[i] = arr[i];
                }
                return arr2;
            } else {
                return Array.from(arr);
            }
        }
        var baseCommands = exports.baseCommands = Object.create(null);
        baseCommands.deleteSelection = {
            label: "Delete the selection",
            run: function run(pm) {
                return pm.tr.replaceSelection().apply(pm.apply.scroll);
            },
            keys: {
                all: ["Backspace(10)", "Delete(10)", "Mod-Backspace(10)", "Mod-Delete(10)"],
                mac: ["Ctrl-H(10)", "Alt-Backspace(10)", "Ctrl-D(10)", "Ctrl-Alt-Backspace(10)", "Alt-Delete(10)", "Alt-D(10)"]
            }
        };
        function deleteBarrier(pm, cut) {
            var $cut = pm.doc.resolve(cut),
                before = $cut.nodeBefore,
                after = $cut.nodeAfter;
            if (before.type.canContainContent(after.type)) {
                var tr = pm.tr.join(cut);
                if (tr.steps.length && before.content.size == 0 && !before.sameMarkup(after))
                    tr.setNodeType(cut - before.nodeSize, after.type, after.attrs);
                if (tr.apply(pm.apply.scroll) !== false)
                    return;
            }
            var conn = undefined;
            if (after.isTextblock && (conn = before.type.findConnection(after.type))) {
                var tr = pm.tr,
                    end = cut + after.nodeSize;
                tr.step("ancestor", cut, end, {
                    types: [before.type].concat(_toConsumableArray(conn)),
                    attrs: [before.attrs].concat(_toConsumableArray(conn.map(function() {
                        return null;
                    })))
                });
                tr.join(end + 2 * conn.length + 2, 1, true);
                tr.join(cut);
                if (tr.apply(pm.apply.scroll) !== false)
                    return;
            }
            var selAfter = (0, _selection.findSelectionFrom)(pm.doc, cut, 1);
            return pm.tr.lift(selAfter.from, selAfter.to, true).apply(pm.apply.scroll);
        }
        baseCommands.joinBackward = {
            label: "Join with the block above",
            run: function run(pm) {
                var _pm$selection = pm.selection;
                var head = _pm$selection.head;
                var empty = _pm$selection.empty;
                if (!empty)
                    return false;
                var $head = pm.doc.resolve(head);
                if ($head.parentOffset > 0)
                    return false;
                var before = undefined,
                    cut = undefined;
                for (var i = $head.depth - 1; !before && i >= 0; i--) {
                    if ($head.index(i) > 0) {
                        cut = $head.before(i + 1);
                        before = $head.node(i).child($head.index(i) - 1);
                    }
                }
                if (!before)
                    return pm.tr.lift(head, head, true).apply(pm.apply.scroll);
                if (before.type.contains == null && before.type.selectable && $head.parent.content.size == 0) {
                    var tr = pm.tr.delete(cut, cut + $head.parent.nodeSize).apply(pm.apply.scroll);
                    pm.setNodeSelection(cut - before.nodeSize);
                    return tr;
                }
                if (before.type.contains == null)
                    return pm.tr.delete(cut - before.nodeSize, cut).apply(pm.apply.scroll);
                return deleteBarrier(pm, cut);
            },
            keys: ["Backspace(30)", "Mod-Backspace(30)"]
        };
        function moveBackward(doc, pos, by) {
            if (by != "char" && by != "word")
                throw new RangeError("Unknown motion unit: " + by);
            var $pos = doc.resolve(pos);
            var parent = $pos.parent,
                offset = $pos.parentOffset;
            var cat = null,
                counted = 0;
            for (; ; ) {
                if (offset == 0)
                    return pos;
                var _parent$childBefore = parent.childBefore(offset);
                var start = _parent$childBefore.offset;
                var node = _parent$childBefore.node;
                if (!node)
                    return pos;
                if (!node.isText)
                    return cat ? pos : pos - 1;
                if (by == "char") {
                    for (var i = offset - start; i > 0; i--) {
                        if (!(0, _char.isExtendingChar)(node.text.charAt(i - 1)))
                            return pos - 1;
                        offset--;
                        pos--;
                    }
                } else if (by == "word") {
                    for (var i = offset - start; i > 0; i--) {
                        var nextCharCat = (0, _char.charCategory)(node.text.charAt(i - 1));
                        if (cat == null || counted == 1 && cat == "space")
                            cat = nextCharCat;
                        else if (cat != nextCharCat)
                            return pos;
                        offset--;
                        pos--;
                        counted++;
                    }
                }
            }
        }
        baseCommands.deleteCharBefore = {
            label: "Delete a character before the cursor",
            run: function run(pm) {
                var _pm$selection2 = pm.selection;
                var head = _pm$selection2.head;
                var empty = _pm$selection2.empty;
                if (!empty || pm.doc.resolve(head).parentOffset == 0)
                    return false;
                var dest = moveBackward(pm.doc, head, "char");
                return pm.tr.delete(dest, head).apply(pm.apply.scroll);
            },
            keys: {
                all: ["Backspace(60)"],
                mac: ["Ctrl-H(40)"]
            }
        };
        baseCommands.deleteWordBefore = {
            label: "Delete the word before the cursor",
            run: function run(pm) {
                var _pm$selection3 = pm.selection;
                var head = _pm$selection3.head;
                var empty = _pm$selection3.empty;
                if (!empty || pm.doc.resolve(head).parentOffset == 0)
                    return false;
                var dest = moveBackward(pm.doc, head, "word");
                return pm.tr.delete(dest, head).apply(pm.apply.scroll);
            },
            keys: {
                all: ["Mod-Backspace(40)"],
                mac: ["Alt-Backspace(40)"]
            }
        };
        baseCommands.joinForward = {
            label: "Join with the block below",
            run: function run(pm) {
                var _pm$selection4 = pm.selection;
                var head = _pm$selection4.head;
                var empty = _pm$selection4.empty;
                var $head = undefined;
                if (!empty || ($head = pm.doc.resolve(head)).parentOffset < $head.parent.content.size)
                    return false;
                var after = undefined,
                    cut = undefined;
                for (var i = $head.depth - 1; !after && i >= 0; i--) {
                    var parent = $head.node(i);
                    if ($head.index(i) + 1 < parent.childCount) {
                        after = parent.child($head.index(i) + 1);
                        cut = $head.after(i + 1);
                    }
                }
                if (!after)
                    return false;
                if (after.type.contains == null)
                    return pm.tr.delete(cut, cut + after.nodeSize).apply(pm.apply.scroll);
                return deleteBarrier(pm, cut);
            },
            keys: ["Delete(30)", "Mod-Delete(30)"]
        };
        function moveForward(doc, pos, by) {
            if (by != "char" && by != "word")
                throw new RangeError("Unknown motion unit: " + by);
            var $pos = doc.resolve(pos);
            var parent = $pos.parent,
                offset = $pos.parentOffset;
            var cat = null,
                counted = 0;
            for (; ; ) {
                if (offset == parent.content.size)
                    return pos;
                var _parent$childAfter = parent.childAfter(offset);
                var start = _parent$childAfter.offset;
                var node = _parent$childAfter.node;
                if (!node)
                    return pos;
                if (!node.isText)
                    return cat ? pos : pos + 1;
                if (by == "char") {
                    for (var i = offset - start; i < node.text.length; i++) {
                        if (!(0, _char.isExtendingChar)(node.text.charAt(i + 1)))
                            return pos + 1;
                        offset++;
                        pos++;
                    }
                } else if (by == "word") {
                    for (var i = offset - start; i < node.text.length; i++) {
                        var nextCharCat = (0, _char.charCategory)(node.text.charAt(i));
                        if (cat == null || counted == 1 && cat == "space")
                            cat = nextCharCat;
                        else if (cat != nextCharCat)
                            return pos;
                        offset++;
                        pos++;
                        counted++;
                    }
                }
            }
        }
        baseCommands.deleteCharAfter = {
            label: "Delete a character after the cursor",
            run: function run(pm) {
                var _pm$selection5 = pm.selection;
                var head = _pm$selection5.head;
                var empty = _pm$selection5.empty;
                var $head = undefined;
                if (!empty || ($head = pm.doc.resolve(head)).parentOffset == $head.parent.content.size)
                    return false;
                var dest = moveForward(pm.doc, head, "char");
                return pm.tr.delete(head, dest).apply(pm.apply.scroll);
            },
            keys: {
                all: ["Delete(60)"],
                mac: ["Ctrl-D(60)"]
            }
        };
        baseCommands.deleteWordAfter = {
            label: "Delete a word after the cursor",
            run: function run(pm) {
                var _pm$selection6 = pm.selection;
                var head = _pm$selection6.head;
                var empty = _pm$selection6.empty;
                var $head = undefined;
                if (!empty || ($head = pm.doc.resolve(head)).parentOffset == $head.parent.content.size)
                    return false;
                var dest = moveForward(pm.doc, head, "word");
                return pm.tr.delete(head, dest).apply(pm.apply.scroll);
            },
            keys: {
                all: ["Mod-Delete(40)"],
                mac: ["Ctrl-Alt-Backspace(40)", "Alt-Delete(40)", "Alt-D(40)"]
            }
        };
        function joinPointAbove(pm) {
            var _pm$selection7 = pm.selection;
            var node = _pm$selection7.node;
            var from = _pm$selection7.from;
            if (node)
                return (0, _transform.joinable)(pm.doc, from) ? from : null;
            else
                return (0, _transform.joinPoint)(pm.doc, from, -1);
        }
        baseCommands.joinUp = {
            label: "Join with above block",
            run: function run(pm) {
                var point = joinPointAbove(pm),
                    selectNode = undefined;
                if (!point)
                    return false;
                if (pm.selection.node)
                    selectNode = point - pm.doc.resolve(point).nodeBefore.nodeSize;
                pm.tr.join(point).apply();
                if (selectNode != null)
                    pm.setNodeSelection(selectNode);
            },
            select: function select(pm) {
                return joinPointAbove(pm);
            },
            menu: {
                group: "block",
                rank: 80,
                display: {
                    type: "icon",
                    width: 800,
                    height: 900,
                    path: "M0 75h800v125h-800z M0 825h800v-125h-800z M250 400h100v-100h100v100h100v100h-100v100h-100v-100h-100z"
                }
            },
            keys: ["Alt-Up"]
        };
        function joinPointBelow(pm) {
            var _pm$selection8 = pm.selection;
            var node = _pm$selection8.node;
            var to = _pm$selection8.to;
            if (node)
                return (0, _transform.joinable)(pm.doc, to) ? to : null;
            else
                return (0, _transform.joinPoint)(pm.doc, to, 1);
        }
        baseCommands.joinDown = {
            label: "Join with below block",
            run: function run(pm) {
                var node = pm.selection.node,
                    nodeAt = pm.selection.from;
                var point = joinPointBelow(pm);
                if (!point)
                    return false;
                pm.tr.join(point).apply();
                if (node)
                    pm.setNodeSelection(nodeAt);
            },
            select: function select(pm) {
                return joinPointBelow(pm);
            },
            keys: ["Alt-Down"]
        };
        baseCommands.lift = {
            label: "Lift out of enclosing block",
            run: function run(pm) {
                var _pm$selection9 = pm.selection;
                var from = _pm$selection9.from;
                var to = _pm$selection9.to;
                return pm.tr.lift(from, to, true).apply(pm.apply.scroll);
            },
            select: function select(pm) {
                var _pm$selection10 = pm.selection;
                var from = _pm$selection10.from;
                var to = _pm$selection10.to;
                return (0, _transform.canLift)(pm.doc, from, to);
            },
            menu: {
                group: "block",
                rank: 75,
                display: {
                    type: "icon",
                    width: 1024,
                    height: 1024,
                    path: "M219 310v329q0 7-5 12t-12 5q-8 0-13-5l-164-164q-5-5-5-13t5-13l164-164q5-5 13-5 7 0 12 5t5 12zM1024 749v109q0 7-5 12t-12 5h-987q-7 0-12-5t-5-12v-109q0-7 5-12t12-5h987q7 0 12 5t5 12zM1024 530v109q0 7-5 12t-12 5h-621q-7 0-12-5t-5-12v-109q0-7 5-12t12-5h621q7 0 12 5t5 12zM1024 310v109q0 7-5 12t-12 5h-621q-7 0-12-5t-5-12v-109q0-7 5-12t12-5h621q7 0 12 5t5 12zM1024 91v109q0 7-5 12t-12 5h-987q-7 0-12-5t-5-12v-109q0-7 5-12t12-5h987q7 0 12 5t5 12z"
                }
            },
            keys: ["Mod-["]
        };
        baseCommands.newlineInCode = {
            label: "Insert newline",
            run: function run(pm) {
                var _pm$selection11 = pm.selection;
                var from = _pm$selection11.from;
                var to = _pm$selection11.to;
                var node = _pm$selection11.node;
                if (node)
                    return false;
                var $from = pm.doc.resolve(from);
                if (!$from.parent.type.isCode || to >= $from.end($from.depth))
                    return false;
                return pm.tr.typeText("\n").apply(pm.apply.scroll);
            },
            keys: ["Enter(10)"]
        };
        baseCommands.createParagraphNear = {
            label: "Create a paragraph near the selected block",
            run: function run(pm) {
                var _pm$selection12 = pm.selection;
                var from = _pm$selection12.from;
                var to = _pm$selection12.to;
                var node = _pm$selection12.node;
                if (!node || !node.isBlock)
                    return false;
                var side = pm.doc.resolve(from).parentOffset ? to : from;
                pm.tr.insert(side, pm.schema.defaultTextblockType().create()).apply(pm.apply.scroll);
                pm.setTextSelection(side + 1);
            },
            keys: ["Enter(20)"]
        };
        baseCommands.liftEmptyBlock = {
            label: "Move current block up",
            run: function run(pm) {
                var _pm$selection13 = pm.selection;
                var head = _pm$selection13.head;
                var empty = _pm$selection13.empty;
                var $head = undefined;
                if (!empty || ($head = pm.doc.resolve(head)).parentOffset > 0 || $head.parent.content.size)
                    return false;
                if ($head.depth > 1) {
                    if ($head.index($head.depth - 1) > 0 && $head.index($head.depth - 1) < $head.node($head.depth - 1).childCount - 1 && pm.tr.split($head.before($head.depth)).apply() !== false)
                        return;
                }
                return pm.tr.lift(head, head, true).apply(pm.apply.scroll);
            },
            keys: ["Enter(30)"]
        };
        baseCommands.splitBlock = {
            label: "Split the current block",
            run: function run(pm) {
                var _pm$selection14 = pm.selection;
                var from = _pm$selection14.from;
                var to = _pm$selection14.to;
                var node = _pm$selection14.node;
                var $from = pm.doc.resolve(from);
                if (node && node.isBlock) {
                    if (!$from.parentOffset)
                        return false;
                    return pm.tr.split(from).apply(pm.apply.scroll);
                } else {
                    var $to = pm.doc.resolve(to),
                        atEnd = $to.parentOffset == $to.parent.content.size;
                    var deflt = pm.schema.defaultTextblockType();
                    var type = atEnd ? deflt : null;
                    var tr = pm.tr.delete(from, to).split(from, 1, type);
                    if (!atEnd && !$from.parentOffset && $from.parent.type != deflt)
                        tr.setNodeType($from.before($from.depth), deflt);
                    return tr.apply(pm.apply.scroll);
                }
            },
            keys: ["Enter(60)"]
        };
        function nodeAboveSelection(pm) {
            var sel = pm.selection;
            if (sel.node) {
                var $from = pm.doc.resolve(sel.from);
                return !!$from.depth && $from.before($from.depth);
            }
            var $head = pm.doc.resolve(sel.head);
            var same = $head.sameDepth(pm.doc.resolve(sel.anchor));
            return same == 0 ? false : $head.before(same);
        }
        baseCommands.selectParentNode = {
            label: "Select parent node",
            run: function run(pm) {
                var node = nodeAboveSelection(pm);
                if (node === false)
                    return false;
                pm.setNodeSelection(node);
            },
            select: function select(pm) {
                return nodeAboveSelection(pm);
            },
            menu: {
                group: "block",
                rank: 90,
                display: {
                    type: "icon",
                    text: "⬚",
                    style: "font-weight: bold"
                }
            },
            keys: ["Esc"]
        };
        baseCommands.undo = {
            label: "Undo last change",
            run: function run(pm) {
                pm.scrollIntoView();
                return pm.history.undo();
            },
            select: function select(pm) {
                return pm.history.undoDepth > 0;
            },
            menu: {
                group: "history",
                rank: 10,
                display: {
                    type: "icon",
                    width: 1024,
                    height: 1024,
                    path: "M761 1024c113-206 132-520-313-509v253l-384-384 384-384v248c534-13 594 472 313 775z"
                }
            },
            keys: ["Mod-Z"]
        };
        baseCommands.redo = {
            label: "Redo last undone change",
            run: function run(pm) {
                pm.scrollIntoView();
                return pm.history.redo();
            },
            select: function select(pm) {
                return pm.history.redoDepth > 0;
            },
            menu: {
                group: "history",
                rank: 20,
                display: {
                    type: "icon",
                    width: 1024,
                    height: 1024,
                    path: "M576 248v-248l384 384-384 384v-253c-446-10-427 303-313 509-280-303-221-789 313-775z"
                }
            },
            keys: ["Mod-Y", "Shift-Mod-Z"]
        };
        return module.exports;
    });

    $__System.registerDynamic("20", ["14", "6", "19", "8", "1b", "2f", "2e"], true, function($__require, exports, module) {
        "use strict";
        ;
        var define,
            global = this,
            GLOBAL = this;
        Object.defineProperty(exports, "__esModule", {value: true});
        exports.CommandSet = exports.Command = undefined;
        var _slicedToArray = function() {
            function sliceIterator(arr, i) {
                var _arr = [];
                var _n = true;
                var _d = false;
                var _e = undefined;
                try {
                    for (var _i = arr[Symbol.iterator](),
                             _s; !(_n = (_s = _i.next()).done); _n = true) {
                        _arr.push(_s.value);
                        if (i && _arr.length === i)
                            break;
                    }
                } catch (err) {
                    _d = true;
                    _e = err;
                } finally {
                    try {
                        if (!_n && _i["return"])
                            _i["return"]();
                    } finally {
                        if (_d)
                            throw _e;
                    }
                }
                return _arr;
            }
            return function(arr, i) {
                if (Array.isArray(arr)) {
                    return arr;
                } else if (Symbol.iterator in Object(arr)) {
                    return sliceIterator(arr, i);
                } else {
                    throw new TypeError("Invalid attempt to destructure non-iterable instance");
                }
            };
        }();
        var _typeof = typeof Symbol === "function" && typeof Symbol.iterator === "symbol" ? function(obj) {
            return typeof obj;
        } : function(obj) {
            return obj && typeof Symbol === "function" && obj.constructor === Symbol ? "symbol" : typeof obj;
        };
        var _createClass = function() {
            function defineProperties(target, props) {
                for (var i = 0; i < props.length; i++) {
                    var descriptor = props[i];
                    descriptor.enumerable = descriptor.enumerable || false;
                    descriptor.configurable = true;
                    if ("value" in descriptor)
                        descriptor.writable = true;
                    Object.defineProperty(target, descriptor.key, descriptor);
                }
            }
            return function(Constructor, protoProps, staticProps) {
                if (protoProps)
                    defineProperties(Constructor.prototype, protoProps);
                if (staticProps)
                    defineProperties(Constructor, staticProps);
                return Constructor;
            };
        }();
        exports.updateCommands = updateCommands;
        exports.selectedNodeAttr = selectedNodeAttr;
        var _browserkeymap = $__require('14');
        var _browserkeymap2 = _interopRequireDefault(_browserkeymap);
        var _model = $__require('6');
        var _transform = $__require('19');
        var _dom = $__require('8');
        var _sortedinsert = $__require('1b');
        var _sortedinsert2 = _interopRequireDefault(_sortedinsert);
        var _obj = $__require('2f');
        var _base_commands = $__require('2e');
        function _interopRequireDefault(obj) {
            return obj && obj.__esModule ? obj : {default: obj};
        }
        function _toConsumableArray(arr) {
            if (Array.isArray(arr)) {
                for (var i = 0,
                         arr2 = Array(arr.length); i < arr.length; i++) {
                    arr2[i] = arr[i];
                }
                return arr2;
            } else {
                return Array.from(arr);
            }
        }
        function _classCallCheck(instance, Constructor) {
            if (!(instance instanceof Constructor)) {
                throw new TypeError("Cannot call a class as a function");
            }
        }
        var Command = exports.Command = function() {
            function Command(spec, self, name) {
                _classCallCheck(this, Command);
                this.name = name;
                if (!this.name)
                    throw new RangeError("Trying to define a command without a name");
                this.spec = spec;
                this.self = self;
            }
            _createClass(Command, [{
                key: "exec",
                value: function exec(pm, params) {
                    var run = this.spec.run;
                    if (!params) {
                        if (!this.params.length)
                            return run.call(this.self, pm);
                        return new pm.options.commandParamPrompt(pm, this).open();
                    } else {
                        if (this.params.length != (params ? params.length : 0))
                            throw new RangeError("Invalid amount of parameters for command " + this.name);
                        return run.call.apply(run, [this.self, pm].concat(_toConsumableArray(params)));
                    }
                }
            }, {
                key: "select",
                value: function select(pm) {
                    var f = this.spec.select;
                    return f ? f.call(this.self, pm) : true;
                }
            }, {
                key: "active",
                value: function active(pm) {
                    var f = this.spec.active;
                    return f ? f.call(this.self, pm) : false;
                }
            }, {
                key: "params",
                get: function get() {
                    return this.spec.params || empty;
                }
            }, {
                key: "label",
                get: function get() {
                    return this.spec.label || this.name;
                }
            }]);
            return Command;
        }();
        var empty = [];
        function deriveCommandSpec(type, spec, name) {
            if (!spec.derive)
                return spec;
            var conf = _typeof(spec.derive) == "object" ? spec.derive : {};
            var dname = conf.name || name;
            var derive = type.constructor.derivableCommands[dname];
            if (!derive)
                throw new RangeError("Don't know how to derive command " + dname);
            var derived = derive.call(type, conf);
            for (var prop in spec) {
                if (prop != "derive")
                    derived[prop] = spec[prop];
            }
            return derived;
        }
        var CommandSet = function() {
            function CommandSet(base, op) {
                _classCallCheck(this, CommandSet);
                this.base = base;
                this.op = op;
            }
            _createClass(CommandSet, [{
                key: "add",
                value: function add(set, filter) {
                    return new CommandSet(this, function(commands, schema) {
                        function add(name, spec, self) {
                            if (!filter || filter(name, spec)) {
                                if (commands[name])
                                    throw new RangeError("Duplicate definition of command " + name);
                                commands[name] = new Command(spec, self, name);
                            }
                        }
                        if (set === "schema") {
                            schema.registry("command", function(name, spec, type, typeName) {
                                add(typeName + ":" + name, deriveCommandSpec(type, spec, name), type);
                            });
                        } else {
                            for (var name in set) {
                                add(name, set[name]);
                            }
                        }
                    });
                }
            }, {
                key: "update",
                value: function update(_update) {
                    return new CommandSet(this, function(commands) {
                        for (var name in _update) {
                            var spec = _update[name];
                            if (!spec) {
                                delete commands[name];
                            } else if (spec.run) {
                                commands[name] = new Command(spec, null, name);
                            } else {
                                var known = commands[name];
                                if (known)
                                    commands[name] = new Command((0, _obj.copyObj)(spec, (0, _obj.copyObj)(known.spec)), known.self, name);
                            }
                        }
                    });
                }
            }, {
                key: "derive",
                value: function derive(schema) {
                    var commands = this.base ? this.base.derive(schema) : Object.create(null);
                    this.op(commands, schema);
                    return commands;
                }
            }]);
            return CommandSet;
        }();
        exports.CommandSet = CommandSet;
        CommandSet.empty = new CommandSet(null, function() {
            return null;
        });
        CommandSet.default = CommandSet.empty.add("schema").add(_base_commands.baseCommands);
        function deriveKeymap(pm) {
            var bindings = {},
                platform = _dom.browser.mac ? "mac" : "pc";
            function add(command, keys) {
                for (var i = 0; i < keys.length; i++) {
                    var _$exec = /^(.+?)(?:\((\d+)\))?$/.exec(keys[i]);
                    var _$exec2 = _slicedToArray(_$exec, 3);
                    var _ = _$exec2[0];
                    var name = _$exec2[1];
                    var _$exec2$ = _$exec2[2];
                    var rank = _$exec2$ === undefined ? 50 : _$exec2$;
                    (0, _sortedinsert2.default)(bindings[name] || (bindings[name] = []), {
                        command: command,
                        rank: rank
                    }, function(a, b) {
                        return a.rank - b.rank;
                    });
                }
            }
            for (var name in pm.commands) {
                var cmd = pm.commands[name],
                    keys = cmd.spec.keys;
                if (!keys)
                    continue;
                if (Array.isArray(keys)) {
                    add(cmd, keys);
                } else {
                    if (keys.all)
                        add(cmd, keys.all);
                    if (keys[platform])
                        add(cmd, keys[platform]);
                }
            }
            for (var key in bindings) {
                bindings[key] = bindings[key].map(function(b) {
                    return b.command.name;
                });
            }
            return new _browserkeymap2.default(bindings);
        }
        function updateCommands(pm, set) {
            pm.signal("commandsChanging");
            pm.commands = set.derive(pm.schema);
            pm.input.baseKeymap = deriveKeymap(pm);
            pm.commandKeys = Object.create(null);
            pm.signal("commandsChanged");
        }
        function markActive(pm, type) {
            var sel = pm.selection;
            if (sel.empty)
                return type.isInSet(pm.activeMarks());
            else
                return pm.doc.rangeHasMark(sel.from, sel.to, type);
        }
        function canAddInline(pm, type) {
            var _pm$selection = pm.selection;
            var from = _pm$selection.from;
            var to = _pm$selection.to;
            var empty = _pm$selection.empty;
            if (empty)
                return !type.isInSet(pm.activeMarks()) && pm.doc.resolve(from).parent.type.canContainMark(type);
            var can = false;
            pm.doc.nodesBetween(from, to, function(node) {
                if (can || node.isTextblock && !node.type.canContainMark(type))
                    return false;
                if (node.isInline && !type.isInSet(node.marks))
                    can = true;
            });
            return can;
        }
        function markApplies(pm, type) {
            var _pm$selection2 = pm.selection;
            var from = _pm$selection2.from;
            var to = _pm$selection2.to;
            var relevant = false;
            pm.doc.nodesBetween(from, to, function(node) {
                if (node.isTextblock) {
                    if (node.type.canContainMark(type))
                        relevant = true;
                    return false;
                }
            });
            return relevant;
        }
        function selectedMarkAttr(pm, type, attr) {
            var _pm$selection3 = pm.selection;
            var from = _pm$selection3.from;
            var to = _pm$selection3.to;
            var empty = _pm$selection3.empty;
            var start = undefined,
                end = undefined;
            if (empty) {
                start = end = type.isInSet(pm.activeMarks());
            } else {
                var startChunk = pm.doc.resolve(from).nodeAfter;
                start = startChunk ? type.isInSet(startChunk.marks) : null;
                end = type.isInSet(pm.doc.marksAt(to));
            }
            if (start && end && start.attrs[attr] == end.attrs[attr])
                return start.attrs[attr];
        }
        function selectedNodeAttr(pm, type, name) {
            var node = pm.selection.node;
            if (node && node.type == type)
                return node.attrs[name];
        }
        function deriveParams(type, params) {
            return params && params.map(function(param) {
                    var attr = type.attrs[param.attr];
                    var obj = {
                        type: "text",
                        default: attr.default,
                        prefill: type instanceof _model.NodeType ? function(pm) {
                            return selectedNodeAttr(pm, this, param.attr);
                        } : function(pm) {
                            return selectedMarkAttr(pm, this, param.attr);
                        }
                    };
                    for (var prop in param) {
                        obj[prop] = param[prop];
                    }
                    return obj;
                });
        }
        function fillAttrs(conf, givenParams) {
            var attrs = conf.attrs;
            if (conf.params) {
                (function() {
                    var filled = Object.create(null);
                    if (attrs)
                        for (var name in attrs) {
                            filled[name] = attrs[name];
                        }
                    conf.params.forEach(function(param, i) {
                        return filled[param.attr] = givenParams[i];
                    });
                    attrs = filled;
                })();
            }
            return attrs;
        }
        _model.NodeType.derivableCommands = Object.create(null);
        _model.MarkType.derivableCommands = Object.create(null);
        _model.MarkType.derivableCommands.set = function(conf) {
            return {
                run: function run(pm) {
                    for (var _len = arguments.length,
                             params = Array(_len > 1 ? _len - 1 : 0),
                             _key = 1; _key < _len; _key++) {
                        params[_key - 1] = arguments[_key];
                    }
                    pm.setMark(this, true, fillAttrs(conf, params));
                },
                select: function select(pm) {
                    return conf.inverseSelect ? markApplies(pm, this) && !markActive(pm, this) : canAddInline(pm, this);
                },
                params: deriveParams(this, conf.params)
            };
        };
        _model.MarkType.derivableCommands.unset = function() {
            return {
                run: function run(pm) {
                    pm.setMark(this, false);
                },
                select: function select(pm) {
                    return markActive(pm, this);
                }
            };
        };
        _model.MarkType.derivableCommands.toggle = function() {
            return {
                run: function run(pm) {
                    pm.setMark(this, null);
                },
                active: function active(pm) {
                    return markActive(pm, this);
                },
                select: function select(pm) {
                    return markApplies(pm, this);
                }
            };
        };
        function isAtTopOfListItem(doc, from, to, listType) {
            var $from = doc.resolve(from);
            return $from.sameParent(doc.resolve(to)) && $from.depth >= 2 && $from.index($from.depth - 1) == 0 && listType.canContain($from.node($from.depth - 1));
        }
        _model.NodeType.derivableCommands.wrap = function(conf) {
            return {
                run: function run(pm) {
                    var _pm$selection4 = pm.selection;
                    var from = _pm$selection4.from;
                    var to = _pm$selection4.to;
                    var head = _pm$selection4.head;
                    var doJoin = false;
                    var $from = pm.doc.resolve(from);
                    if (conf.list && head && isAtTopOfListItem(pm.doc, from, to, this)) {
                        if ($from.index($from.depth - 2) == 0)
                            return false;
                        doJoin = true;
                    }
                    for (var _len2 = arguments.length,
                             params = Array(_len2 > 1 ? _len2 - 1 : 0),
                             _key2 = 1; _key2 < _len2; _key2++) {
                        params[_key2 - 1] = arguments[_key2];
                    }
                    var tr = pm.tr.wrap(from, to, this, fillAttrs(conf, params));
                    if (doJoin)
                        tr.join($from.before($from.depth - 1));
                    return tr.apply(pm.apply.scroll);
                },
                select: function select(pm) {
                    var _pm$selection5 = pm.selection;
                    var from = _pm$selection5.from;
                    var to = _pm$selection5.to;
                    var head = _pm$selection5.head;
                    var $from = undefined;
                    if (conf.list && head && isAtTopOfListItem(pm.doc, from, to, this) && ($from = pm.doc.resolve(from)).index($from.depth - 2) == 0)
                        return false;
                    return (0, _transform.canWrap)(pm.doc, from, to, this, conf.attrs);
                },
                params: deriveParams(this, conf.params)
            };
        };
        function alreadyHasBlockType(doc, from, to, type, attrs) {
            var found = false;
            if (!attrs)
                attrs = {};
            doc.nodesBetween(from, to || from, function(node) {
                if (node.isTextblock) {
                    if (node.hasMarkup(type, attrs))
                        found = true;
                    return false;
                }
            });
            return found;
        }
        function activeTextblockIs(pm, type, attrs) {
            var _pm$selection6 = pm.selection;
            var from = _pm$selection6.from;
            var to = _pm$selection6.to;
            var node = _pm$selection6.node;
            if (!node || node.isInline) {
                var $from = pm.doc.resolve(from);
                if (!$from.sameParent(pm.doc.resolve(to)))
                    return false;
                node = $from.parent;
            } else if (!node.isTextblock) {
                return false;
            }
            return node.hasMarkup(type, attrs);
        }
        _model.NodeType.derivableCommands.make = function(conf) {
            return {
                run: function run(pm) {
                    var _pm$selection7 = pm.selection;
                    var from = _pm$selection7.from;
                    var to = _pm$selection7.to;
                    return pm.tr.setBlockType(from, to, this, conf.attrs).apply(pm.apply.scroll);
                },
                select: function select(pm) {
                    var _pm$selection8 = pm.selection;
                    var from = _pm$selection8.from;
                    var to = _pm$selection8.to;
                    var node = _pm$selection8.node;
                    if (node)
                        return node.isTextblock && !node.hasMarkup(this, conf.attrs);
                    else
                        return !alreadyHasBlockType(pm.doc, from, to, this, conf.attrs);
                },
                active: function active(pm) {
                    return activeTextblockIs(pm, this, conf.attrs);
                }
            };
        };
        _model.NodeType.derivableCommands.insert = function(conf) {
            return {
                run: function run(pm) {
                    for (var _len3 = arguments.length,
                             params = Array(_len3 > 1 ? _len3 - 1 : 0),
                             _key3 = 1; _key3 < _len3; _key3++) {
                        params[_key3 - 1] = arguments[_key3];
                    }
                    return pm.tr.replaceSelection(this.create(fillAttrs(conf, params))).apply(pm.apply.scroll);
                },
                select: this.isInline ? function(pm) {
                    return pm.doc.resolve(pm.selection.from).parent.type.canContainType(this);
                } : null,
                params: deriveParams(this, conf.params)
            };
        };
        return module.exports;
    });

    $__System.registerDynamic("30", ["6", "1b", "31"], true, function($__require, exports, module) {
        "use strict";
        ;
        var define,
            global = this,
            GLOBAL = this;
        Object.defineProperty(exports, "__esModule", {value: true});
        var _createClass = function() {
            function defineProperties(target, props) {
                for (var i = 0; i < props.length; i++) {
                    var descriptor = props[i];
                    descriptor.enumerable = descriptor.enumerable || false;
                    descriptor.configurable = true;
                    if ("value" in descriptor)
                        descriptor.writable = true;
                    Object.defineProperty(target, descriptor.key, descriptor);
                }
            }
            return function(Constructor, protoProps, staticProps) {
                if (protoProps)
                    defineProperties(Constructor.prototype, protoProps);
                if (staticProps)
                    defineProperties(Constructor, staticProps);
                return Constructor;
            };
        }();
        exports.fromDOM = fromDOM;
        exports.fromHTML = fromHTML;
        var _model = $__require('6');
        var _sortedinsert = $__require('1b');
        var _sortedinsert2 = _interopRequireDefault(_sortedinsert);
        var _register = $__require('31');
        function _interopRequireDefault(obj) {
            return obj && obj.__esModule ? obj : {default: obj};
        }
        function _classCallCheck(instance, Constructor) {
            if (!(instance instanceof Constructor)) {
                throw new TypeError("Cannot call a class as a function");
            }
        }
        function fromDOM(schema, dom, options) {
            if (!options)
                options = {};
            var context = new DOMParseState(schema, options.topNode || schema.node("doc"), options);
            var start = options.from ? dom.childNodes[options.from] : dom.firstChild;
            var end = options.to != null && dom.childNodes[options.to] || null;
            context.addAll(start, end, true);
            var doc = undefined;
            do {
                doc = context.leave();
            } while (context.stack.length);
            return doc;
        }
        (0, _register.defineSource)("dom", fromDOM);
        function fromHTML(schema, html, options) {
            var wrap = (options && options.document || window.document).createElement("div");
            wrap.innerHTML = html;
            return fromDOM(schema, wrap, options);
        }
        (0, _register.defineSource)("html", fromHTML);
        var blockElements = {
            address: true,
            article: true,
            aside: true,
            blockquote: true,
            canvas: true,
            dd: true,
            div: true,
            dl: true,
            fieldset: true,
            figcaption: true,
            figure: true,
            footer: true,
            form: true,
            h1: true,
            h2: true,
            h3: true,
            h4: true,
            h5: true,
            h6: true,
            header: true,
            hgroup: true,
            hr: true,
            li: true,
            noscript: true,
            ol: true,
            output: true,
            p: true,
            pre: true,
            section: true,
            table: true,
            tfoot: true,
            ul: true
        };
        var ignoreElements = {
            head: true,
            noscript: true,
            object: true,
            script: true,
            style: true,
            title: true
        };
        var listElements = {
            ol: true,
            ul: true
        };
        var noMarks = [];
        var DOMParseState = function() {
            function DOMParseState(schema, topNode, options) {
                _classCallCheck(this, DOMParseState);
                this.options = options || {};
                this.schema = schema;
                this.stack = [];
                this.marks = noMarks;
                this.closing = false;
                this.enter(topNode.type, topNode.attrs);
                var info = schemaInfo(schema);
                this.tagInfo = info.tags;
                this.styleInfo = info.styles;
            }
            _createClass(DOMParseState, [{
                key: "addDOM",
                value: function addDOM(dom) {
                    if (dom.nodeType == 3) {
                        var value = dom.nodeValue;
                        var top = this.top,
                            last = undefined;
                        if (/\S/.test(value) || top.type.isTextblock) {
                            if (!this.options.preserveWhitespace) {
                                value = value.replace(/\s+/g, " ");
                                if (/^\s/.test(value) && (!(last = top.content[top.content.length - 1]) || last.type.name == "text" && /\s$/.test(last.text)))
                                    value = value.slice(1);
                            }
                            if (value)
                                this.insertNode(this.schema.text(value, this.marks));
                        }
                    } else if (dom.nodeType == 1 && !dom.hasAttribute("pm-ignore")) {
                        var style = dom.getAttribute("style");
                        if (style)
                            this.addElementWithStyles(parseStyles(style), dom);
                        else
                            this.addElement(dom);
                    }
                }
            }, {
                key: "addElement",
                value: function addElement(dom) {
                    var name = dom.nodeName.toLowerCase();
                    if (listElements.hasOwnProperty(name))
                        this.normalizeList(dom);
                    if (this.options.editableContent && name == "br" && !dom.nextSibling)
                        return;
                    if (!this.parseNodeType(name, dom) && !ignoreElements.hasOwnProperty(name)) {
                        this.addAll(dom.firstChild, null);
                        if (blockElements.hasOwnProperty(name) && this.top.type == this.schema.defaultTextblockType())
                            this.closing = true;
                    }
                }
            }, {
                key: "addElementWithStyles",
                value: function addElementWithStyles(styles, dom) {
                    var _this = this;
                    var wrappers = [];
                    for (var i = 0; i < styles.length; i += 2) {
                        var parsers = this.styleInfo[styles[i]],
                            value = styles[i + 1];
                        if (parsers)
                            for (var j = 0; j < parsers.length; j++) {
                                wrappers.push(parsers[j], value);
                            }
                    }
                    var next = function next(i) {
                        if (i == wrappers.length) {
                            _this.addElement(dom);
                        } else {
                            var parser = wrappers[i];
                            parser.parse.call(parser.type, wrappers[i + 1], _this, next.bind(null, i + 2));
                        }
                    };
                    next(0);
                }
            }, {
                key: "tryParsers",
                value: function tryParsers(parsers, dom) {
                    if (parsers)
                        for (var i = 0; i < parsers.length; i++) {
                            var parser = parsers[i];
                            if ((!parser.selector || matches(dom, parser.selector)) && parser.parse.call(parser.type, dom, this) !== false)
                                return true;
                        }
                }
            }, {
                key: "parseNodeType",
                value: function parseNodeType(name, dom) {
                    return this.tryParsers(this.tagInfo[name], dom) || this.tryParsers(this.tagInfo._, dom);
                }
            }, {
                key: "addAll",
                value: function addAll(from, to, sync) {
                    var stack = sync && this.stack.slice();
                    for (var dom = from; dom != to; dom = dom.nextSibling) {
                        this.addDOM(dom);
                        if (sync && blockElements.hasOwnProperty(dom.nodeName.toLowerCase()))
                            this.sync(stack);
                    }
                }
            }, {
                key: "doClose",
                value: function doClose() {
                    if (!this.closing || this.stack.length < 2)
                        return;
                    var left = this.leave();
                    this.enter(left.type, left.attrs);
                    this.closing = false;
                }
            }, {
                key: "insertNode",
                value: function insertNode(node) {
                    if (this.top.type.canContain(node)) {
                        this.doClose();
                    } else {
                        var found = undefined;
                        for (var i = this.stack.length - 1; i >= 0; i--) {
                            var route = this.stack[i].type.findConnection(node.type);
                            if (!route)
                                continue;
                            if (i == this.stack.length - 1) {
                                this.doClose();
                            } else {
                                while (this.stack.length > i + 1) {
                                    this.leave();
                                }
                            }
                            found = route;
                            break;
                        }
                        if (!found)
                            return;
                        for (var j = 0; j < found.length; j++) {
                            this.enter(found[j]);
                        }
                        if (this.marks.length)
                            this.marks = noMarks;
                    }
                    this.top.content.push(node);
                    return node;
                }
            }, {
                key: "close",
                value: function close(type, attrs, content) {
                    content = _model.Fragment.from(content);
                    if (!type.checkContent(content, attrs)) {
                        content = type.fixContent(content, attrs);
                        if (!content)
                            return null;
                    }
                    return type.create(attrs, content, this.marks);
                }
            }, {
                key: "insert",
                value: function insert(type, attrs, content) {
                    var closed = this.close(type, attrs, content);
                    if (closed)
                        return this.insertNode(closed);
                }
            }, {
                key: "enter",
                value: function enter(type, attrs) {
                    this.stack.push({
                        type: type,
                        attrs: attrs,
                        content: []
                    });
                }
            }, {
                key: "leave",
                value: function leave() {
                    if (this.marks.length)
                        this.marks = noMarks;
                    var top = this.stack.pop();
                    var last = top.content[top.content.length - 1];
                    if (!this.options.preserveWhitespace && last && last.isText && /\s$/.test(last.text)) {
                        if (last.text.length == 1)
                            top.content.pop();
                        else
                            top.content[top.content.length - 1] = last.copy(last.text.slice(0, last.text.length - 1));
                    }
                    var node = this.close(top.type, top.attrs, top.content);
                    if (node && this.stack.length)
                        this.insertNode(node);
                    return node;
                }
            }, {
                key: "sync",
                value: function sync(stack) {
                    while (this.stack.length > stack.length) {
                        this.leave();
                    }
                    for (; ; ) {
                        var n = this.stack.length - 1,
                            one = this.stack[n],
                            two = stack[n];
                        if (one.type == two.type && _model.Node.sameAttrs(one.attrs, two.attrs))
                            break;
                        this.leave();
                    }
                    while (stack.length > this.stack.length) {
                        var add = stack[this.stack.length];
                        this.enter(add.type, add.attrs);
                    }
                    if (this.marks.length)
                        this.marks = noMarks;
                    this.closing = false;
                }
            }, {
                key: "wrapIn",
                value: function wrapIn(dom, type, attrs) {
                    this.enter(type, attrs);
                    this.addAll(dom.firstChild, null, true);
                    this.leave();
                }
            }, {
                key: "wrapMark",
                value: function wrapMark(inner, mark) {
                    var old = this.marks;
                    this.marks = (mark.instance || mark).addToSet(old);
                    if (inner.call)
                        inner();
                    else
                        this.addAll(inner.firstChild, null);
                    this.marks = old;
                }
            }, {
                key: "normalizeList",
                value: function normalizeList(dom) {
                    for (var child = dom.firstChild,
                             prev; child; child = child.nextSibling) {
                        if (child.nodeType == 1 && listElements.hasOwnProperty(child.nodeName.toLowerCase()) && (prev = child.previousSibling)) {
                            prev.appendChild(child);
                            child = prev;
                        }
                    }
                }
            }, {
                key: "top",
                get: function get() {
                    return this.stack[this.stack.length - 1];
                }
            }]);
            return DOMParseState;
        }();
        function matches(dom, selector) {
            return (dom.matches || dom.msMatchesSelector || dom.webkitMatchesSelector || dom.mozMatchesSelector).call(dom, selector);
        }
        function parseStyles(style) {
            var re = /\s*([\w-]+)\s*:\s*([^;]+)/g,
                m = undefined,
                result = [];
            while (m = re.exec(style)) {
                result.push(m[1], m[2].trim());
            }
            return result;
        }
        function schemaInfo(schema) {
            return schema.cached.parseDOMInfo || (schema.cached.parseDOMInfo = summarizeSchemaInfo(schema));
        }
        function summarizeSchemaInfo(schema) {
            var tags = Object.create(null),
                styles = Object.create(null);
            tags._ = [];
            schema.registry("parseDOM", function(tag, info, type) {
                var parse = info.parse;
                if (parse == "block")
                    parse = function parse(dom, state) {
                        state.wrapIn(dom, this);
                    };
                else if (parse == "mark")
                    parse = function parse(dom, state) {
                        state.wrapMark(dom, this);
                    };
                (0, _sortedinsert2.default)(tags[tag] || (tags[tag] = []), {
                    type: type,
                    parse: parse,
                    selector: info.selector,
                    rank: info.rank == null ? 50 : info.rank
                }, function(a, b) {
                    return a.rank - b.rank;
                });
            });
            schema.registry("parseDOMStyle", function(style, info, type) {
                (0, _sortedinsert2.default)(styles[style] || (styles[style] = []), {
                    type: type,
                    parse: info.parse,
                    rank: info.rank == null ? 50 : info.rank
                }, function(a, b) {
                    return a.rank - b.rank;
                });
            });
            return {
                tags: tags,
                styles: styles
            };
        }
        _model.Paragraph.register("parseDOM", "p", {parse: "block"});
        _model.BlockQuote.register("parseDOM", "blockquote", {parse: "block"});
        var _loop = function _loop(i) {
            _model.Heading.registerComputed("parseDOM", "h" + i, function(type) {
                if (i <= type.maxLevel)
                    return {parse: function parse(dom, state) {
                        state.wrapIn(dom, this, {level: String(i)});
                    }};
            });
        };
        for (var i = 1; i <= 6; i++) {
            _loop(i);
        }
        _model.HorizontalRule.register("parseDOM", "hr", {parse: "block"});
        _model.CodeBlock.register("parseDOM", "pre", {parse: function parse(dom, state) {
            var params = dom.firstChild && /^code$/i.test(dom.firstChild.nodeName) && dom.firstChild.getAttribute("class");
            if (params && /fence/.test(params)) {
                var found = [],
                    re = /(?:^|\s)lang-(\S+)/g,
                    m = undefined;
                while (m = re.exec(params)) {
                    found.push(m[1]);
                }
                params = found.join(" ");
            } else {
                params = null;
            }
            var text = dom.textContent;
            state.insert(this, {params: params}, text ? [state.schema.text(text)] : []);
        }});
        _model.BulletList.register("parseDOM", "ul", {parse: "block"});
        _model.OrderedList.register("parseDOM", "ol", {parse: function parse(dom, state) {
            var attrs = {order: dom.getAttribute("start") || "1"};
            state.wrapIn(dom, this, attrs);
        }});
        _model.ListItem.register("parseDOM", "li", {parse: "block"});
        _model.HardBreak.register("parseDOM", "br", {parse: function parse(_, state) {
            state.insert(this);
        }});
        _model.Image.register("parseDOM", "img", {parse: function parse(dom, state) {
            state.insert(this, {
                src: dom.getAttribute("src"),
                title: dom.getAttribute("title") || null,
                alt: dom.getAttribute("alt") || null
            });
        }});
        _model.LinkMark.register("parseDOM", "a", {
            parse: function parse(dom, state) {
                state.wrapMark(dom, this.create({
                    href: dom.getAttribute("href"),
                    title: dom.getAttribute("title")
                }));
            },
            selector: "[href]"
        });
        _model.EmMark.register("parseDOM", "i", {parse: "mark"});
        _model.EmMark.register("parseDOM", "em", {parse: "mark"});
        _model.EmMark.register("parseDOMStyle", "font-style", {parse: function parse(value, state, inner) {
            if (value == "italic")
                state.wrapMark(inner, this);
            else
                inner();
        }});
        _model.StrongMark.register("parseDOM", "b", {parse: "mark"});
        _model.StrongMark.register("parseDOM", "strong", {parse: "mark"});
        _model.StrongMark.register("parseDOMStyle", "font-weight", {parse: function parse(value, state, inner) {
            if (value == "bold" || value == "bolder" || !/\D/.test(value) && +value >= 500)
                state.wrapMark(inner, this);
            else
                inner();
        }});
        _model.CodeMark.register("parseDOM", "code", {parse: "mark"});
        return module.exports;
    });

    $__System.registerDynamic("32", ["6", "31"], true, function($__require, exports, module) {
        "use strict";
        ;
        var define,
            global = this,
            GLOBAL = this;
        Object.defineProperty(exports, "__esModule", {value: true});
        var _createClass = function() {
            function defineProperties(target, props) {
                for (var i = 0; i < props.length; i++) {
                    var descriptor = props[i];
                    descriptor.enumerable = descriptor.enumerable || false;
                    descriptor.configurable = true;
                    if ("value" in descriptor)
                        descriptor.writable = true;
                    Object.defineProperty(target, descriptor.key, descriptor);
                }
            }
            return function(Constructor, protoProps, staticProps) {
                if (protoProps)
                    defineProperties(Constructor.prototype, protoProps);
                if (staticProps)
                    defineProperties(Constructor, staticProps);
                return Constructor;
            };
        }();
        exports.toDOM = toDOM;
        exports.nodeToDOM = nodeToDOM;
        exports.toHTML = toHTML;
        var _model = $__require('6');
        var _register = $__require('31');
        function _classCallCheck(instance, Constructor) {
            if (!(instance instanceof Constructor)) {
                throw new TypeError("Cannot call a class as a function");
            }
        }
        var DOMSerializer = function() {
            function DOMSerializer(options) {
                _classCallCheck(this, DOMSerializer);
                this.options = options || {};
                this.doc = this.options.document || window.document;
            }
            _createClass(DOMSerializer, [{
                key: "elt",
                value: function elt(type, attrs) {
                    var result = this.doc.createElement(type);
                    if (attrs)
                        for (var name in attrs) {
                            if (name == "style")
                                result.style.cssText = attrs[name];
                            else if (attrs[name])
                                result.setAttribute(name, attrs[name]);
                        }
                    for (var _len = arguments.length,
                             content = Array(_len > 2 ? _len - 2 : 0),
                             _key = 2; _key < _len; _key++) {
                        content[_key - 2] = arguments[_key];
                    }
                    for (var i = 0; i < content.length; i++) {
                        result.appendChild(typeof content[i] == "string" ? this.doc.createTextNode(content[i]) : content[i]);
                    }
                    return result;
                }
            }, {
                key: "renderNode",
                value: function renderNode(node, offset) {
                    var dom = node.type.serializeDOM(node, this);
                    if (this.options.onRender)
                        dom = this.options.onRender(node, dom, offset) || dom;
                    return dom;
                }
            }, {
                key: "renderFragment",
                value: function renderFragment(fragment, where) {
                    if (!where)
                        where = this.doc.createDocumentFragment();
                    if (fragment.size == 0)
                        return where;
                    if (!fragment.firstChild.isInline)
                        this.renderBlocksInto(fragment, where);
                    else if (this.options.renderInlineFlat)
                        this.renderInlineFlatInto(fragment, where);
                    else
                        this.renderInlineInto(fragment, where);
                    return where;
                }
            }, {
                key: "renderBlocksInto",
                value: function renderBlocksInto(fragment, where) {
                    var _this = this;
                    fragment.forEach(function(node, offset) {
                        return where.appendChild(_this.renderNode(node, offset));
                    });
                }
            }, {
                key: "renderInlineInto",
                value: function renderInlineInto(fragment, where) {
                    var _this2 = this;
                    var top = where;
                    var active = [];
                    fragment.forEach(function(node, offset) {
                        var keep = 0;
                        for (; keep < Math.min(active.length, node.marks.length); ++keep) {
                            if (!node.marks[keep].eq(active[keep]))
                                break;
                        }
                        while (keep < active.length) {
                            active.pop();
                            top = top.parentNode;
                        }
                        while (active.length < node.marks.length) {
                            var add = node.marks[active.length];
                            active.push(add);
                            top = top.appendChild(_this2.renderMark(add));
                        }
                        top.appendChild(_this2.renderNode(node, offset));
                    });
                }
            }, {
                key: "renderInlineFlatInto",
                value: function renderInlineFlatInto(fragment, where) {
                    var _this3 = this;
                    fragment.forEach(function(node, offset) {
                        var dom = _this3.renderNode(node, offset);
                        dom = _this3.wrapInlineFlat(dom, node.marks);
                        dom = _this3.options.renderInlineFlat(node, dom, offset) || dom;
                        where.appendChild(dom);
                    });
                }
            }, {
                key: "renderMark",
                value: function renderMark(mark) {
                    return mark.type.serializeDOM(mark, this);
                }
            }, {
                key: "wrapInlineFlat",
                value: function wrapInlineFlat(dom, marks) {
                    for (var i = marks.length - 1; i >= 0; i--) {
                        var wrap = this.renderMark(marks[i]);
                        wrap.appendChild(dom);
                        dom = wrap;
                    }
                    return dom;
                }
            }, {
                key: "renderAs",
                value: function renderAs(node, tagName, tagAttrs) {
                    if (this.options.preRenderContent)
                        this.options.preRenderContent(node);
                    var dom = this.renderFragment(node.content, this.elt(tagName, tagAttrs));
                    if (this.options.onContainer)
                        this.options.onContainer(dom);
                    if (this.options.postRenderContent)
                        this.options.postRenderContent(node);
                    return dom;
                }
            }]);
            return DOMSerializer;
        }();
        function toDOM(content, options) {
            return new DOMSerializer(options).renderFragment(content instanceof _model.Node ? content.content : content);
        }
        (0, _register.defineTarget)("dom", toDOM);
        function nodeToDOM(node, options, offset) {
            var serializer = new DOMSerializer(options);
            var dom = serializer.renderNode(node, offset);
            if (node.isInline) {
                dom = serializer.wrapInlineFlat(dom, node.marks);
                if (serializer.options.renderInlineFlat)
                    dom = options.renderInlineFlat(node, dom, offset) || dom;
            }
            return dom;
        }
        function toHTML(content, options) {
            var serializer = new DOMSerializer(options);
            var wrap = serializer.elt("div");
            wrap.appendChild(serializer.renderFragment(content instanceof _model.Node ? content.content : content));
            return wrap.innerHTML;
        }
        (0, _register.defineTarget)("html", toHTML);
        function def(cls, method) {
            cls.prototype.serializeDOM = method;
        }
        def(_model.BlockQuote, function(node, s) {
            return s.renderAs(node, "blockquote");
        });
        _model.BlockQuote.prototype.countCoordsAsChild = function(_, pos, dom, coords) {
            var childBox = dom.firstChild.getBoundingClientRect();
            if (coords.left < childBox.left - 2)
                return pos;
        };
        def(_model.BulletList, function(node, s) {
            return s.renderAs(node, "ul");
        });
        def(_model.OrderedList, function(node, s) {
            return s.renderAs(node, "ol", {start: node.attrs.order != "1" && node.attrs.order});
        });
        _model.OrderedList.prototype.countCoordsAsChild = _model.BulletList.prototype.countCoordsAsChild = function(_, pos, dom, coords) {
            for (var child = dom.firstChild; child; child = child.nextSibling) {
                var off = child.getAttribute("pm-offset");
                if (!off)
                    continue;
                var childBox = child.getBoundingClientRect();
                if (coords.left > childBox.left - 2)
                    return null;
                if (childBox.top <= coords.top && childBox.bottom >= coords.top)
                    return pos + 1 + +off;
            }
        };
        def(_model.ListItem, function(node, s) {
            return s.renderAs(node, "li");
        });
        def(_model.HorizontalRule, function(_, s) {
            return s.elt("div", null, s.elt("hr"));
        });
        def(_model.Paragraph, function(node, s) {
            return s.renderAs(node, "p");
        });
        def(_model.Heading, function(node, s) {
            return s.renderAs(node, "h" + node.attrs.level);
        });
        def(_model.CodeBlock, function(node, s) {
            var code = s.renderAs(node, "code");
            if (node.attrs.params != null)
                code.className = "fence " + node.attrs.params.replace(/(^|\s+)/g, "$&lang-");
            return s.elt("pre", null, code);
        });
        def(_model.Text, function(node, s) {
            return s.doc.createTextNode(node.text);
        });
        def(_model.Image, function(node, s) {
            return s.elt("img", {
                src: node.attrs.src,
                alt: node.attrs.alt,
                title: node.attrs.title
            });
        });
        def(_model.HardBreak, function(_, s) {
            return s.elt("br");
        });
        def(_model.EmMark, function(_, s) {
            return s.elt("em");
        });
        def(_model.StrongMark, function(_, s) {
            return s.elt("strong");
        });
        def(_model.CodeMark, function(_, s) {
            return s.elt("code");
        });
        def(_model.LinkMark, function(mark, s) {
            return s.elt("a", {
                href: mark.attrs.href,
                title: mark.attrs.title
            });
        });
        return module.exports;
    });

    $__System.registerDynamic("33", ["31"], true, function($__require, exports, module) {
        "use strict";
        ;
        var define,
            global = this,
            GLOBAL = this;
        Object.defineProperty(exports, "__esModule", {value: true});
        exports.fromText = fromText;
        var _register = $__require('31');
        function fromText(schema, text) {
            var blocks = text.trim().split(/\n{2,}/);
            var nodes = [];
            for (var i = 0; i < blocks.length; i++) {
                var spans = [];
                var parts = blocks[i].split("\n");
                for (var j = 0; j < parts.length; j++) {
                    if (j)
                        spans.push(schema.node("hard_break"));
                    if (parts[j])
                        spans.push(schema.text(parts[j]));
                }
                nodes.push(schema.node("paragraph", null, spans));
            }
            if (!nodes.length)
                nodes.push(schema.node("paragraph"));
            return schema.node("doc", null, nodes);
        }
        (0, _register.defineSource)("text", fromText);
        return module.exports;
    });

    $__System.registerDynamic("27", [], true, function($__require, exports, module) {
        "use strict";
        ;
        var define,
            global = this,
            GLOBAL = this;
        Object.defineProperty(exports, "__esModule", {value: true});
        exports.ProseMirrorError = ProseMirrorError;
        function ProseMirrorError(message) {
            Error.call(this, message);
            if (this.message != message) {
                this.message = message;
                if (Error.captureStackTrace)
                    Error.captureStackTrace(this, this.name);
                else
                    this.stack = new Error(message).stack;
            }
        }
        ProseMirrorError.prototype = Object.create(Error.prototype);
        ProseMirrorError.prototype.constructor = ProseMirrorError;
        Object.defineProperty(ProseMirrorError.prototype, "name", {get: function get() {
            return this.constructor.name || functionName(this.constructor) || "ProseMirrorError";
        }});
        function functionName(f) {
            var match = /^function (\w+)/.exec(f.toString());
            return match && match[1];
        }
        return module.exports;
    });

    $__System.registerDynamic("34", ["27", "35"], true, function($__require, exports, module) {
        "use strict";
        ;
        var define,
            global = this,
            GLOBAL = this;
        Object.defineProperty(exports, "__esModule", {value: true});
        exports.Slice = exports.ReplaceError = undefined;
        var _createClass = function() {
            function defineProperties(target, props) {
                for (var i = 0; i < props.length; i++) {
                    var descriptor = props[i];
                    descriptor.enumerable = descriptor.enumerable || false;
                    descriptor.configurable = true;
                    if ("value" in descriptor)
                        descriptor.writable = true;
                    Object.defineProperty(target, descriptor.key, descriptor);
                }
            }
            return function(Constructor, protoProps, staticProps) {
                if (protoProps)
                    defineProperties(Constructor.prototype, protoProps);
                if (staticProps)
                    defineProperties(Constructor, staticProps);
                return Constructor;
            };
        }();
        exports.replace = replace;
        var _error = $__require('27');
        var _fragment = $__require('35');
        function _classCallCheck(instance, Constructor) {
            if (!(instance instanceof Constructor)) {
                throw new TypeError("Cannot call a class as a function");
            }
        }
        function _possibleConstructorReturn(self, call) {
            if (!self) {
                throw new ReferenceError("this hasn't been initialised - super() hasn't been called");
            }
            return call && (typeof call === "object" || typeof call === "function") ? call : self;
        }
        function _inherits(subClass, superClass) {
            if (typeof superClass !== "function" && superClass !== null) {
                throw new TypeError("Super expression must either be null or a function, not " + typeof superClass);
            }
            subClass.prototype = Object.create(superClass && superClass.prototype, {constructor: {
                value: subClass,
                enumerable: false,
                writable: true,
                configurable: true
            }});
            if (superClass)
                Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass;
        }
        var ReplaceError = exports.ReplaceError = function(_ProseMirrorError) {
            _inherits(ReplaceError, _ProseMirrorError);
            function ReplaceError() {
                _classCallCheck(this, ReplaceError);
                return _possibleConstructorReturn(this, Object.getPrototypeOf(ReplaceError).apply(this, arguments));
            }
            return ReplaceError;
        }(_error.ProseMirrorError);
        var Slice = exports.Slice = function() {
            function Slice(content, openLeft, openRight, possibleParent) {
                _classCallCheck(this, Slice);
                this.content = content;
                this.openLeft = openLeft;
                this.openRight = openRight;
                this.possibleParent = possibleParent;
            }
            _createClass(Slice, [{
                key: "toJSON",
                value: function toJSON() {
                    if (!this.content.size)
                        return null;
                    return {
                        content: this.content.toJSON(),
                        openLeft: this.openLeft,
                        openRight: this.openRight
                    };
                }
            }, {
                key: "size",
                get: function get() {
                    return this.content.size - this.openLeft - this.openRight;
                }
            }], [{
                key: "fromJSON",
                value: function fromJSON(schema, json) {
                    if (!json)
                        return Slice.empty;
                    return new Slice(_fragment.Fragment.fromJSON(schema, json.content), json.openLeft, json.openRight);
                }
            }]);
            return Slice;
        }();
        Slice.empty = new Slice(_fragment.Fragment.empty, 0, 0);
        function replace($from, $to, slice) {
            if (slice.openLeft > $from.depth)
                throw new ReplaceError("Inserted content deeper than insertion position");
            if ($from.depth - slice.openLeft != $to.depth - slice.openRight)
                throw new ReplaceError("Inconsistent open depths");
            return replaceOuter($from, $to, slice, 0);
        }
        function replaceOuter($from, $to, slice, depth) {
            var index = $from.index(depth),
                node = $from.node(depth);
            if (index == $to.index(depth) && depth < $from.depth - slice.openLeft) {
                var inner = replaceOuter($from, $to, slice, depth + 1);
                return node.copy(node.content.replaceChild(index, inner));
            } else if (slice.content.size) {
                var _prepareSliceForRepla = prepareSliceForReplace(slice, $from);
                var start = _prepareSliceForRepla.start;
                var end = _prepareSliceForRepla.end;
                return close(node, replaceThreeWay($from, start, end, $to, depth));
            } else {
                return close(node, replaceTwoWay($from, $to, depth));
            }
        }
        function checkJoin(main, sub) {
            if (!main.type.canContainContent(sub.type))
                throw new ReplaceError("Cannot join " + sub.type.name + " onto " + main.type.name);
        }
        function joinable($before, $after, depth) {
            var node = $before.node(depth);
            checkJoin(node, $after.node(depth));
            return node;
        }
        function addNode(child, target) {
            var last = target.length - 1;
            if (last >= 0 && child.isText && child.sameMarkup(target[last]))
                target[last] = child.copy(target[last].text + child.text);
            else
                target.push(child);
        }
        function addRange($start, $end, depth, target) {
            var node = ($end || $start).node(depth);
            var startIndex = 0,
                endIndex = $end ? $end.index(depth) : node.childCount;
            if ($start) {
                startIndex = $start.index(depth);
                if ($start.depth > depth) {
                    startIndex++;
                } else if (!$start.atNodeBoundary) {
                    addNode($start.nodeAfter, target);
                    startIndex++;
                }
            }
            for (var i = startIndex; i < endIndex; i++) {
                addNode(node.child(i), target);
            }
            if ($end && $end.depth == depth && !$end.atNodeBoundary)
                addNode($end.nodeBefore, target);
        }
        function close(node, content) {
            if (!node.type.checkContent(content, node.attrs))
                throw new ReplaceError("Invalid content for node " + node.type.name);
            return node.copy(content);
        }
        function replaceThreeWay($from, $start, $end, $to, depth) {
            var openLeft = $from.depth > depth && joinable($from, $start, depth + 1);
            var openRight = $to.depth > depth && joinable($end, $to, depth + 1);
            var content = [];
            addRange(null, $from, depth, content);
            if (openLeft && openRight && $start.index(depth) == $end.index(depth)) {
                checkJoin(openLeft, openRight);
                addNode(close(openLeft, replaceThreeWay($from, $start, $end, $to, depth + 1)), content);
            } else {
                if (openLeft)
                    addNode(close(openLeft, replaceTwoWay($from, $start, depth + 1)), content);
                addRange($start, $end, depth, content);
                if (openRight)
                    addNode(close(openRight, replaceTwoWay($end, $to, depth + 1)), content);
            }
            addRange($to, null, depth, content);
            return new _fragment.Fragment(content);
        }
        function replaceTwoWay($from, $to, depth) {
            var content = [];
            addRange(null, $from, depth, content);
            if ($from.depth > depth) {
                var type = joinable($from, $to, depth + 1);
                addNode(close(type, replaceTwoWay($from, $to, depth + 1)), content);
            }
            addRange($to, null, depth, content);
            return new _fragment.Fragment(content);
        }
        function prepareSliceForReplace(slice, $along) {
            var extra = $along.depth - slice.openLeft,
                parent = $along.node(extra);
            if (!parent.type.canContainFragment(slice.content))
                throw new ReplaceError("Content " + slice.content + " cannot be placed in " + parent.type.name);
            var node = parent.copy(slice.content);
            for (var i = extra - 1; i >= 0; i--) {
                node = $along.node(i).copy(_fragment.Fragment.from(node));
            }
            return {
                start: node.resolveNoCache(slice.openLeft + extra),
                end: node.resolveNoCache(node.content.size - slice.openRight - extra)
            };
        }
        return module.exports;
    });

    $__System.registerDynamic("36", [], true, function($__require, exports, module) {
        "use strict";
        ;
        var define,
            global = this,
            GLOBAL = this;
        Object.defineProperty(exports, "__esModule", {value: true});
        var _createClass = function() {
            function defineProperties(target, props) {
                for (var i = 0; i < props.length; i++) {
                    var descriptor = props[i];
                    descriptor.enumerable = descriptor.enumerable || false;
                    descriptor.configurable = true;
                    if ("value" in descriptor)
                        descriptor.writable = true;
                    Object.defineProperty(target, descriptor.key, descriptor);
                }
            }
            return function(Constructor, protoProps, staticProps) {
                if (protoProps)
                    defineProperties(Constructor.prototype, protoProps);
                if (staticProps)
                    defineProperties(Constructor, staticProps);
                return Constructor;
            };
        }();
        function _classCallCheck(instance, Constructor) {
            if (!(instance instanceof Constructor)) {
                throw new TypeError("Cannot call a class as a function");
            }
        }
        var ResolvedPos = exports.ResolvedPos = function() {
            function ResolvedPos(pos, path, parentOffset) {
                _classCallCheck(this, ResolvedPos);
                this.pos = pos;
                this.path = path;
                this.depth = path.length / 3 - 1;
                this.parentOffset = parentOffset;
            }
            _createClass(ResolvedPos, [{
                key: "node",
                value: function node(depth) {
                    return this.path[depth * 3];
                }
            }, {
                key: "index",
                value: function index(depth) {
                    return this.path[depth * 3 + 1];
                }
            }, {
                key: "start",
                value: function start(depth) {
                    return depth == 0 ? 0 : this.path[depth * 3 - 1] + 1;
                }
            }, {
                key: "end",
                value: function end(depth) {
                    return this.start(depth) + this.node(depth).content.size;
                }
            }, {
                key: "before",
                value: function before(depth) {
                    if (!depth)
                        throw new RangeError("There is no position before the top-level node");
                    return depth == this.depth + 1 ? this.pos : this.path[depth * 3 - 1];
                }
            }, {
                key: "after",
                value: function after(depth) {
                    if (!depth)
                        throw new RangeError("There is no position after the top-level node");
                    return depth == this.depth + 1 ? this.pos : this.path[depth * 3 - 1] + this.path[depth * 3].nodeSize;
                }
            }, {
                key: "sameDepth",
                value: function sameDepth(other) {
                    var depth = 0,
                        max = Math.min(this.depth, other.depth);
                    while (depth < max && this.index(depth) == other.index(depth)) {
                        ++depth;
                    }
                    return depth;
                }
            }, {
                key: "sameParent",
                value: function sameParent(other) {
                    return this.pos - this.parentOffset == other.pos - other.parentOffset;
                }
            }, {
                key: "toString",
                value: function toString() {
                    var str = "";
                    for (var i = 1; i <= this.depth; i++) {
                        str += (str ? "/" : "") + this.node(i).type.name + "_" + this.index(i - 1);
                    }
                    return str + ":" + this.parentOffset;
                }
            }, {
                key: "parent",
                get: function get() {
                    return this.node(this.depth);
                }
            }, {
                key: "atNodeBoundary",
                get: function get() {
                    return this.path[this.path.length - 1] == this.pos;
                }
            }, {
                key: "nodeAfter",
                get: function get() {
                    var parent = this.parent,
                        index = this.index(this.depth);
                    if (index == parent.childCount)
                        return null;
                    var dOff = this.pos - this.path[this.path.length - 1],
                        child = parent.child(index);
                    return dOff ? parent.child(index).cut(dOff) : child;
                }
            }, {
                key: "nodeBefore",
                get: function get() {
                    var index = this.index(this.depth);
                    var dOff = this.pos - this.path[this.path.length - 1];
                    if (dOff)
                        return this.parent.child(index).cut(0, dOff);
                    return index == 0 ? null : this.parent.child(index - 1);
                }
            }], [{
                key: "resolve",
                value: function resolve(doc, pos) {
                    if (!(pos >= 0 && pos <= doc.content.size))
                        throw new RangeError("Position " + pos + " out of range");
                    var path = [];
                    var start = 0,
                        parentOffset = pos;
                    for (var node = doc; ; ) {
                        var _node$content$findInd = node.content.findIndex(parentOffset);
                        var index = _node$content$findInd.index;
                        var offset = _node$content$findInd.offset;
                        var rem = parentOffset - offset;
                        path.push(node, index, start + offset);
                        if (!rem)
                            break;
                        node = node.child(index);
                        if (node.isText)
                            break;
                        parentOffset = rem - 1;
                        start += offset + 1;
                    }
                    return new ResolvedPos(pos, path, parentOffset);
                }
            }, {
                key: "resolveCached",
                value: function resolveCached(doc, pos) {
                    for (var i = 0; i < resolveCache.length; i++) {
                        var cached = resolveCache[i];
                        if (cached.pos == pos && cached.node(0) == doc)
                            return cached;
                    }
                    var result = resolveCache[resolveCachePos] = ResolvedPos.resolve(doc, pos);
                    resolveCachePos = (resolveCachePos + 1) % resolveCacheSize;
                    return result;
                }
            }]);
            return ResolvedPos;
        }();
        var resolveCache = [],
            resolveCachePos = 0,
            resolveCacheSize = 6;
        return module.exports;
    });

    $__System.registerDynamic("37", ["35", "38", "34", "36"], true, function($__require, exports, module) {
        "use strict";
        ;
        var define,
            global = this,
            GLOBAL = this;
        Object.defineProperty(exports, "__esModule", {value: true});
        exports.TextNode = exports.Node = undefined;
        var _get = function get(object, property, receiver) {
            if (object === null)
                object = Function.prototype;
            var desc = Object.getOwnPropertyDescriptor(object, property);
            if (desc === undefined) {
                var parent = Object.getPrototypeOf(object);
                if (parent === null) {
                    return undefined;
                } else {
                    return get(parent, property, receiver);
                }
            } else if ("value" in desc) {
                return desc.value;
            } else {
                var getter = desc.get;
                if (getter === undefined) {
                    return undefined;
                }
                return getter.call(receiver);
            }
        };
        var _createClass = function() {
            function defineProperties(target, props) {
                for (var i = 0; i < props.length; i++) {
                    var descriptor = props[i];
                    descriptor.enumerable = descriptor.enumerable || false;
                    descriptor.configurable = true;
                    if ("value" in descriptor)
                        descriptor.writable = true;
                    Object.defineProperty(target, descriptor.key, descriptor);
                }
            }
            return function(Constructor, protoProps, staticProps) {
                if (protoProps)
                    defineProperties(Constructor.prototype, protoProps);
                if (staticProps)
                    defineProperties(Constructor, staticProps);
                return Constructor;
            };
        }();
        var _fragment = $__require('35');
        var _mark = $__require('38');
        var _replace2 = $__require('34');
        var _resolvedpos = $__require('36');
        function _possibleConstructorReturn(self, call) {
            if (!self) {
                throw new ReferenceError("this hasn't been initialised - super() hasn't been called");
            }
            return call && (typeof call === "object" || typeof call === "function") ? call : self;
        }
        function _inherits(subClass, superClass) {
            if (typeof superClass !== "function" && superClass !== null) {
                throw new TypeError("Super expression must either be null or a function, not " + typeof superClass);
            }
            subClass.prototype = Object.create(superClass && superClass.prototype, {constructor: {
                value: subClass,
                enumerable: false,
                writable: true,
                configurable: true
            }});
            if (superClass)
                Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass;
        }
        function _classCallCheck(instance, Constructor) {
            if (!(instance instanceof Constructor)) {
                throw new TypeError("Cannot call a class as a function");
            }
        }
        var emptyArray = [],
            emptyAttrs = Object.create(null);
        var Node = exports.Node = function() {
            function Node(type, attrs, content, marks) {
                _classCallCheck(this, Node);
                this.type = type;
                this.attrs = attrs;
                this.content = content || _fragment.Fragment.empty;
                this.marks = marks || emptyArray;
            }
            _createClass(Node, [{
                key: "child",
                value: function child(index) {
                    return this.content.child(index);
                }
            }, {
                key: "maybeChild",
                value: function maybeChild(index) {
                    return this.content.maybeChild(index);
                }
            }, {
                key: "forEach",
                value: function forEach(f) {
                    this.content.forEach(f);
                }
            }, {
                key: "eq",
                value: function eq(other) {
                    return this == other || this.sameMarkup(other) && this.content.eq(other.content);
                }
            }, {
                key: "sameMarkup",
                value: function sameMarkup(other) {
                    return this.hasMarkup(other.type, other.attrs, other.marks);
                }
            }, {
                key: "hasMarkup",
                value: function hasMarkup(type, attrs, marks) {
                    return this.type == type && Node.sameAttrs(this.attrs, attrs || emptyAttrs) && _mark.Mark.sameSet(this.marks, marks || emptyArray);
                }
            }, {
                key: "copy",
                value: function copy() {
                    var content = arguments.length <= 0 || arguments[0] === undefined ? null : arguments[0];
                    if (content == this.content)
                        return this;
                    return new this.constructor(this.type, this.attrs, content, this.marks);
                }
            }, {
                key: "mark",
                value: function mark(marks) {
                    return new this.constructor(this.type, this.attrs, this.content, marks);
                }
            }, {
                key: "cut",
                value: function cut(from, to) {
                    if (from == 0 && to == this.content.size)
                        return this;
                    return this.copy(this.content.cut(from, to));
                }
            }, {
                key: "slice",
                value: function slice(from) {
                    var to = arguments.length <= 1 || arguments[1] === undefined ? this.content.size : arguments[1];
                    if (from == to)
                        return _replace2.Slice.empty;
                    var $from = this.resolve(from),
                        $to = this.resolve(to);
                    var depth = $from.sameDepth($to),
                        start = $from.start(depth),
                        node = $from.node(depth);
                    var content = node.content.cut($from.pos - start, $to.pos - start);
                    return new _replace2.Slice(content, $from.depth - depth, $to.depth - depth, node);
                }
            }, {
                key: "replace",
                value: function replace(from, to, slice) {
                    return (0, _replace2.replace)(this.resolve(from), this.resolve(to), slice);
                }
            }, {
                key: "nodeAt",
                value: function nodeAt(pos) {
                    for (var node = this; ; ) {
                        var _node$content$findInd = node.content.findIndex(pos);
                        var index = _node$content$findInd.index;
                        var offset = _node$content$findInd.offset;
                        node = node.maybeChild(index);
                        if (!node)
                            return null;
                        if (offset == pos || node.isText)
                            return node;
                        pos -= offset + 1;
                    }
                }
            }, {
                key: "childAfter",
                value: function childAfter(pos) {
                    var _content$findIndex = this.content.findIndex(pos);
                    var index = _content$findIndex.index;
                    var offset = _content$findIndex.offset;
                    return {
                        node: this.content.maybeChild(index),
                        index: index,
                        offset: offset
                    };
                }
            }, {
                key: "childBefore",
                value: function childBefore(pos) {
                    if (pos == 0)
                        return {
                            node: null,
                            index: 0,
                            offset: 0
                        };
                    var _content$findIndex2 = this.content.findIndex(pos);
                    var index = _content$findIndex2.index;
                    var offset = _content$findIndex2.offset;
                    if (offset < pos)
                        return {
                            node: this.content.child(index),
                            index: index,
                            offset: offset
                        };
                    var node = this.content.child(index - 1);
                    return {
                        node: node,
                        index: index - 1,
                        offset: offset - node.nodeSize
                    };
                }
            }, {
                key: "nodesBetween",
                value: function nodesBetween(from, to, f) {
                    var pos = arguments.length <= 3 || arguments[3] === undefined ? 0 : arguments[3];
                    this.content.nodesBetween(from, to, f, pos, this);
                }
            }, {
                key: "descendants",
                value: function descendants(f) {
                    this.nodesBetween(0, this.content.size, f);
                }
            }, {
                key: "resolve",
                value: function resolve(pos) {
                    return _resolvedpos.ResolvedPos.resolveCached(this, pos);
                }
            }, {
                key: "resolveNoCache",
                value: function resolveNoCache(pos) {
                    return _resolvedpos.ResolvedPos.resolve(this, pos);
                }
            }, {
                key: "marksAt",
                value: function marksAt(pos) {
                    var $pos = this.resolve(pos),
                        parent = $pos.parent,
                        index = $pos.index($pos.depth);
                    if (parent.content.size == 0)
                        return emptyArray;
                    if (index == 0 || !$pos.atNodeBoundary)
                        return parent.child(index).marks;
                    var marks = parent.child(index - 1).marks;
                    for (var i = 0; i < marks.length; i++) {
                        if (!marks[i].type.inclusiveRight)
                            marks = marks[i--].removeFromSet(marks);
                    }
                    return marks;
                }
            }, {
                key: "rangeHasMark",
                value: function rangeHasMark(from, to, type) {
                    var found = false;
                    this.nodesBetween(from, to, function(node) {
                        if (type.isInSet(node.marks))
                            found = true;
                        return !found;
                    });
                    return found;
                }
            }, {
                key: "toString",
                value: function toString() {
                    var name = this.type.name;
                    if (this.content.size)
                        name += "(" + this.content.toStringInner() + ")";
                    return wrapMarks(this.marks, name);
                }
            }, {
                key: "toJSON",
                value: function toJSON() {
                    var obj = {type: this.type.name};
                    for (var _ in this.attrs) {
                        obj.attrs = this.attrs;
                        break;
                    }
                    if (this.content.size)
                        obj.content = this.content.toJSON();
                    if (this.marks.length)
                        obj.marks = this.marks.map(function(n) {
                            return n.toJSON();
                        });
                    return obj;
                }
            }, {
                key: "nodeSize",
                get: function get() {
                    return this.type.contains ? 2 + this.content.size : 1;
                }
            }, {
                key: "childCount",
                get: function get() {
                    return this.content.childCount;
                }
            }, {
                key: "textContent",
                get: function get() {
                    return this.content.textContent;
                }
            }, {
                key: "firstChild",
                get: function get() {
                    return this.content.firstChild;
                }
            }, {
                key: "lastChild",
                get: function get() {
                    return this.content.lastChild;
                }
            }, {
                key: "isBlock",
                get: function get() {
                    return this.type.isBlock;
                }
            }, {
                key: "isTextblock",
                get: function get() {
                    return this.type.isTextblock;
                }
            }, {
                key: "isInline",
                get: function get() {
                    return this.type.isInline;
                }
            }, {
                key: "isText",
                get: function get() {
                    return this.type.isText;
                }
            }, {
                key: "value",
                get: function get() {
                    return this;
                }
            }], [{
                key: "sameAttrs",
                value: function sameAttrs(a, b) {
                    if (a == b)
                        return true;
                    for (var prop in a) {
                        if (a[prop] !== b[prop])
                            return false;
                    }
                    return true;
                }
            }, {
                key: "fromJSON",
                value: function fromJSON(schema, json) {
                    var type = schema.nodeType(json.type);
                    var content = json.text != null ? json.text : _fragment.Fragment.fromJSON(schema, json.content);
                    return type.create(json.attrs, content, json.marks && json.marks.map(schema.markFromJSON));
                }
            }]);
            return Node;
        }();
        var TextNode = exports.TextNode = function(_Node) {
            _inherits(TextNode, _Node);
            function TextNode(type, attrs, content, marks) {
                _classCallCheck(this, TextNode);
                var _this = _possibleConstructorReturn(this, Object.getPrototypeOf(TextNode).call(this, type, attrs, null, marks));
                if (!content)
                    throw new RangeError("Empty text nodes are not allowed");
                _this.text = content;
                return _this;
            }
            _createClass(TextNode, [{
                key: "toString",
                value: function toString() {
                    return wrapMarks(this.marks, JSON.stringify(this.text));
                }
            }, {
                key: "mark",
                value: function mark(marks) {
                    return new TextNode(this.type, this.attrs, this.text, marks);
                }
            }, {
                key: "cut",
                value: function cut() {
                    var from = arguments.length <= 0 || arguments[0] === undefined ? 0 : arguments[0];
                    var to = arguments.length <= 1 || arguments[1] === undefined ? this.text.length : arguments[1];
                    if (from == 0 && to == this.text.length)
                        return this;
                    return this.copy(this.text.slice(from, to));
                }
            }, {
                key: "eq",
                value: function eq(other) {
                    return this.sameMarkup(other) && this.text == other.text;
                }
            }, {
                key: "toJSON",
                value: function toJSON() {
                    var base = _get(Object.getPrototypeOf(TextNode.prototype), "toJSON", this).call(this);
                    base.text = this.text;
                    return base;
                }
            }, {
                key: "textContent",
                get: function get() {
                    return this.text;
                }
            }, {
                key: "nodeSize",
                get: function get() {
                    return this.text.length;
                }
            }]);
            return TextNode;
        }(Node);
        function wrapMarks(marks, str) {
            for (var i = marks.length - 1; i >= 0; i--) {
                str = marks[i].type.name + "(" + str + ")";
            }
            return str;
        }
        return module.exports;
    });

    $__System.registerDynamic("35", [], true, function($__require, exports, module) {
        "use strict";
        ;
        var define,
            global = this,
            GLOBAL = this;
        Object.defineProperty(exports, "__esModule", {value: true});
        var _createClass = function() {
            function defineProperties(target, props) {
                for (var i = 0; i < props.length; i++) {
                    var descriptor = props[i];
                    descriptor.enumerable = descriptor.enumerable || false;
                    descriptor.configurable = true;
                    if ("value" in descriptor)
                        descriptor.writable = true;
                    Object.defineProperty(target, descriptor.key, descriptor);
                }
            }
            return function(Constructor, protoProps, staticProps) {
                if (protoProps)
                    defineProperties(Constructor.prototype, protoProps);
                if (staticProps)
                    defineProperties(Constructor, staticProps);
                return Constructor;
            };
        }();
        function _classCallCheck(instance, Constructor) {
            if (!(instance instanceof Constructor)) {
                throw new TypeError("Cannot call a class as a function");
            }
        }
        var Fragment = exports.Fragment = function() {
            function Fragment(content, size) {
                _classCallCheck(this, Fragment);
                this.content = content;
                this.size = size || 0;
                if (size == null)
                    for (var i = 0; i < content.length; i++) {
                        this.size += content[i].nodeSize;
                    }
            }
            _createClass(Fragment, [{
                key: "toString",
                value: function toString() {
                    return "<" + this.toStringInner() + ">";
                }
            }, {
                key: "toStringInner",
                value: function toStringInner() {
                    return this.content.join(", ");
                }
            }, {
                key: "nodesBetween",
                value: function nodesBetween(from, to, f, nodeStart, parent) {
                    for (var i = 0,
                             pos = 0; pos < to; i++) {
                        var child = this.content[i],
                            end = pos + child.nodeSize;
                        if (end > from && f(child, nodeStart + pos, parent) !== false && child.content.size) {
                            var start = pos + 1;
                            child.nodesBetween(Math.max(0, from - start), Math.min(child.content.size, to - start), f, nodeStart + start);
                        }
                        pos = end;
                    }
                }
            }, {
                key: "cut",
                value: function cut(from, to) {
                    if (to == null)
                        to = this.size;
                    if (from == 0 && to == this.size)
                        return this;
                    var result = [],
                        size = 0;
                    if (to > from)
                        for (var i = 0,
                                 pos = 0; pos < to; i++) {
                            var child = this.content[i],
                                end = pos + child.nodeSize;
                            if (end > from) {
                                if (pos < from || end > to) {
                                    if (child.isText)
                                        child = child.cut(Math.max(0, from - pos), Math.min(child.text.length, to - pos));
                                    else
                                        child = child.cut(Math.max(0, from - pos - 1), Math.min(child.content.size, to - pos - 1));
                                }
                                result.push(child);
                                size += child.nodeSize;
                            }
                            pos = end;
                        }
                    return new Fragment(result, size);
                }
            }, {
                key: "append",
                value: function append(other) {
                    if (!other.size)
                        return this;
                    if (!this.size)
                        return other;
                    var last = this.lastChild,
                        first = other.firstChild,
                        content = this.content.slice(),
                        i = 0;
                    if (last.isText && last.sameMarkup(first)) {
                        content[content.length - 1] = last.copy(last.text + first.text);
                        i = 1;
                    }
                    for (; i < other.content.length; i++) {
                        content.push(other.content[i]);
                    }
                    return new Fragment(content, this.size + other.size);
                }
            }, {
                key: "replaceChild",
                value: function replaceChild(index, node) {
                    var copy = this.content.slice();
                    var size = this.size + node.nodeSize - copy[index].nodeSize;
                    copy[index] = node;
                    return new Fragment(copy, size);
                }
            }, {
                key: "addToStart",
                value: function addToStart(node) {
                    return new Fragment([node].concat(this.content), this.size + node.nodeSize);
                }
            }, {
                key: "addToEnd",
                value: function addToEnd(node) {
                    return new Fragment(this.content.concat(node), this.size + node.nodeSize);
                }
            }, {
                key: "toJSON",
                value: function toJSON() {
                    return this.content.length ? this.content.map(function(n) {
                        return n.toJSON();
                    }) : null;
                }
            }, {
                key: "eq",
                value: function eq(other) {
                    if (this.content.length != other.content.length)
                        return false;
                    for (var i = 0; i < this.content.length; i++) {
                        if (!this.content[i].eq(other.content[i]))
                            return false;
                    }
                    return true;
                }
            }, {
                key: "child",
                value: function child(index) {
                    var found = this.content[index];
                    if (!found)
                        throw new RangeError("Index " + index + " out of range for " + this);
                    return found;
                }
            }, {
                key: "maybeChild",
                value: function maybeChild(index) {
                    return this.content[index];
                }
            }, {
                key: "forEach",
                value: function forEach(f) {
                    for (var i = 0,
                             p = 0; i < this.content.length; i++) {
                        var child = this.content[i];
                        f(child, p);
                        p += child.nodeSize;
                    }
                }
            }, {
                key: "leastSuperKind",
                value: function leastSuperKind() {
                    var kind = undefined;
                    for (var i = this.childCount - 1; i >= 0; i--) {
                        var cur = this.child(i).type.kind;
                        kind = kind ? kind.sharedSuperKind(cur) : cur;
                    }
                    return kind;
                }
            }, {
                key: "findIndex",
                value: function findIndex(pos) {
                    var round = arguments.length <= 1 || arguments[1] === undefined ? -1 : arguments[1];
                    if (pos == 0)
                        return retIndex(0, pos);
                    if (pos == this.size)
                        return retIndex(this.content.length, pos);
                    if (pos > this.size || pos < 0)
                        throw new RangeError("Position " + pos + " outside of fragment (" + this + ")");
                    for (var i = 0,
                             curPos = 0; ; i++) {
                        var cur = this.child(i),
                            end = curPos + cur.nodeSize;
                        if (end >= pos) {
                            if (end == pos || round > 0)
                                return retIndex(i + 1, end);
                            return retIndex(i, curPos);
                        }
                        curPos = end;
                    }
                }
            }, {
                key: "textContent",
                get: function get() {
                    var text = "";
                    this.content.forEach(function(n) {
                        return text += n.textContent;
                    });
                    return text;
                }
            }, {
                key: "firstChild",
                get: function get() {
                    return this.content.length ? this.content[0] : null;
                }
            }, {
                key: "lastChild",
                get: function get() {
                    return this.content.length ? this.content[this.content.length - 1] : null;
                }
            }, {
                key: "childCount",
                get: function get() {
                    return this.content.length;
                }
            }], [{
                key: "fromJSON",
                value: function fromJSON(schema, value) {
                    return value ? new Fragment(value.map(schema.nodeFromJSON)) : Fragment.empty;
                }
            }, {
                key: "fromArray",
                value: function fromArray(array) {
                    if (!array.length)
                        return Fragment.empty;
                    var joined = undefined,
                        size = 0;
                    for (var i = 0; i < array.length; i++) {
                        var node = array[i];
                        size += node.nodeSize;
                        if (i && node.isText && array[i - 1].sameMarkup(node)) {
                            if (!joined)
                                joined = array.slice(0, i);
                            joined[joined.length - 1] = node.copy(joined[joined.length - 1].text + node.text);
                        } else if (joined) {
                            joined.push(node);
                        }
                    }
                    return new Fragment(joined || array, size);
                }
            }, {
                key: "from",
                value: function from(nodes) {
                    if (!nodes)
                        return Fragment.empty;
                    if (nodes instanceof Fragment)
                        return nodes;
                    if (Array.isArray(nodes))
                        return this.fromArray(nodes);
                    return new Fragment([nodes], nodes.nodeSize);
                }
            }]);
            return Fragment;
        }();
        var found = {
            index: 0,
            offset: 0
        };
        function retIndex(index, offset) {
            found.index = index;
            found.offset = offset;
            return found;
        }
        Fragment.empty = new Fragment([], 0);
        return module.exports;
    });

    $__System.registerDynamic("38", [], true, function($__require, exports, module) {
        "use strict";
        ;
        var define,
            global = this,
            GLOBAL = this;
        Object.defineProperty(exports, "__esModule", {value: true});
        var _createClass = function() {
            function defineProperties(target, props) {
                for (var i = 0; i < props.length; i++) {
                    var descriptor = props[i];
                    descriptor.enumerable = descriptor.enumerable || false;
                    descriptor.configurable = true;
                    if ("value" in descriptor)
                        descriptor.writable = true;
                    Object.defineProperty(target, descriptor.key, descriptor);
                }
            }
            return function(Constructor, protoProps, staticProps) {
                if (protoProps)
                    defineProperties(Constructor.prototype, protoProps);
                if (staticProps)
                    defineProperties(Constructor, staticProps);
                return Constructor;
            };
        }();
        function _classCallCheck(instance, Constructor) {
            if (!(instance instanceof Constructor)) {
                throw new TypeError("Cannot call a class as a function");
            }
        }
        var Mark = exports.Mark = function() {
            function Mark(type, attrs) {
                _classCallCheck(this, Mark);
                this.type = type;
                this.attrs = attrs;
            }
            _createClass(Mark, [{
                key: "toJSON",
                value: function toJSON() {
                    var obj = {_: this.type.name};
                    for (var attr in this.attrs) {
                        obj[attr] = this.attrs[attr];
                    }
                    return obj;
                }
            }, {
                key: "addToSet",
                value: function addToSet(set) {
                    for (var i = 0; i < set.length; i++) {
                        var other = set[i];
                        if (other.type == this.type) {
                            if (this.eq(other))
                                return set;
                            var copy = set.slice();
                            copy[i] = this;
                            return copy;
                        }
                        if (other.type.rank > this.type.rank)
                            return set.slice(0, i).concat(this).concat(set.slice(i));
                    }
                    return set.concat(this);
                }
            }, {
                key: "removeFromSet",
                value: function removeFromSet(set) {
                    for (var i = 0; i < set.length; i++) {
                        if (this.eq(set[i]))
                            return set.slice(0, i).concat(set.slice(i + 1));
                    }
                    return set;
                }
            }, {
                key: "isInSet",
                value: function isInSet(set) {
                    for (var i = 0; i < set.length; i++) {
                        if (this.eq(set[i]))
                            return true;
                    }
                    return false;
                }
            }, {
                key: "eq",
                value: function eq(other) {
                    if (this == other)
                        return true;
                    if (this.type != other.type)
                        return false;
                    for (var attr in this.attrs) {
                        if (other.attrs[attr] != this.attrs[attr])
                            return false;
                    }
                    return true;
                }
            }], [{
                key: "sameSet",
                value: function sameSet(a, b) {
                    if (a == b)
                        return true;
                    if (a.length != b.length)
                        return false;
                    for (var i = 0; i < a.length; i++) {
                        if (!a[i].eq(b[i]))
                            return false;
                    }
                    return true;
                }
            }, {
                key: "setFrom",
                value: function setFrom(marks) {
                    if (!marks || marks.length == 0)
                        return empty;
                    if (marks instanceof Mark)
                        return [marks];
                    var copy = marks.slice();
                    copy.sort(function(a, b) {
                        return a.type.rank - b.type.rank;
                    });
                    return copy;
                }
            }]);
            return Mark;
        }();
        var empty = [];
        return module.exports;
    });

    $__System.registerDynamic("39", ["37", "35", "38", "2f"], true, function($__require, exports, module) {
        "use strict";
        ;
        var define,
            global = this,
            GLOBAL = this;
        Object.defineProperty(exports, "__esModule", {value: true});
        exports.Schema = exports.SchemaSpec = exports.MarkType = exports.Attribute = exports.Text = exports.Inline = exports.Textblock = exports.Block = exports.NodeKind = exports.NodeType = undefined;
        var _get = function get(object, property, receiver) {
            if (object === null)
                object = Function.prototype;
            var desc = Object.getOwnPropertyDescriptor(object, property);
            if (desc === undefined) {
                var parent = Object.getPrototypeOf(object);
                if (parent === null) {
                    return undefined;
                } else {
                    return get(parent, property, receiver);
                }
            } else if ("value" in desc) {
                return desc.value;
            } else {
                var getter = desc.get;
                if (getter === undefined) {
                    return undefined;
                }
                return getter.call(receiver);
            }
        };
        var _createClass = function() {
            function defineProperties(target, props) {
                for (var i = 0; i < props.length; i++) {
                    var descriptor = props[i];
                    descriptor.enumerable = descriptor.enumerable || false;
                    descriptor.configurable = true;
                    if ("value" in descriptor)
                        descriptor.writable = true;
                    Object.defineProperty(target, descriptor.key, descriptor);
                }
            }
            return function(Constructor, protoProps, staticProps) {
                if (protoProps)
                    defineProperties(Constructor.prototype, protoProps);
                if (staticProps)
                    defineProperties(Constructor, staticProps);
                return Constructor;
            };
        }();
        var _node = $__require('37');
        var _fragment = $__require('35');
        var _mark = $__require('38');
        var _obj = $__require('2f');
        function _possibleConstructorReturn(self, call) {
            if (!self) {
                throw new ReferenceError("this hasn't been initialised - super() hasn't been called");
            }
            return call && (typeof call === "object" || typeof call === "function") ? call : self;
        }
        function _inherits(subClass, superClass) {
            if (typeof superClass !== "function" && superClass !== null) {
                throw new TypeError("Super expression must either be null or a function, not " + typeof superClass);
            }
            subClass.prototype = Object.create(superClass && superClass.prototype, {constructor: {
                value: subClass,
                enumerable: false,
                writable: true,
                configurable: true
            }});
            if (superClass)
                Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass;
        }
        function _classCallCheck(instance, Constructor) {
            if (!(instance instanceof Constructor)) {
                throw new TypeError("Cannot call a class as a function");
            }
        }
        var SchemaItem = function() {
            function SchemaItem() {
                _classCallCheck(this, SchemaItem);
            }
            _createClass(SchemaItem, [{
                key: "getDefaultAttrs",
                value: function getDefaultAttrs() {
                    var defaults = Object.create(null);
                    for (var attrName in this.attrs) {
                        var attr = this.attrs[attrName];
                        if (attr.default == null)
                            return null;
                        defaults[attrName] = attr.default;
                    }
                    return defaults;
                }
            }, {
                key: "computeAttrs",
                value: function computeAttrs(attrs, arg) {
                    var built = Object.create(null);
                    for (var name in this.attrs) {
                        var value = attrs && attrs[name];
                        if (value == null) {
                            var attr = this.attrs[name];
                            if (attr.default != null)
                                value = attr.default;
                            else if (attr.compute)
                                value = attr.compute(this, arg);
                            else
                                throw new RangeError("No value supplied for attribute " + name);
                        }
                        built[name] = value;
                    }
                    return built;
                }
            }, {
                key: "freezeAttrs",
                value: function freezeAttrs() {
                    var frozen = Object.create(null);
                    for (var name in this.attrs) {
                        frozen[name] = this.attrs[name];
                    }
                    Object.defineProperty(this, "attrs", {value: frozen});
                }
            }, {
                key: "attrs",
                get: function get() {
                    return {};
                }
            }], [{
                key: "updateAttrs",
                value: function updateAttrs(attrs) {
                    Object.defineProperty(this.prototype, "attrs", {value: overlayObj(this.prototype.attrs, attrs)});
                }
            }, {
                key: "getRegistry",
                value: function getRegistry() {
                    if (this == SchemaItem)
                        return null;
                    if (!this.prototype.hasOwnProperty("registry"))
                        this.prototype.registry = Object.create(Object.getPrototypeOf(this).getRegistry());
                    return this.prototype.registry;
                }
            }, {
                key: "getNamespace",
                value: function getNamespace(name) {
                    if (this == SchemaItem)
                        return null;
                    var reg = this.getRegistry();
                    if (!Object.prototype.hasOwnProperty.call(reg, name))
                        reg[name] = Object.create(Object.getPrototypeOf(this).getNamespace(name));
                    return reg[name];
                }
            }, {
                key: "register",
                value: function register(namespace, name, value) {
                    this.getNamespace(namespace)[name] = function() {
                        return value;
                    };
                }
            }, {
                key: "registerComputed",
                value: function registerComputed(namespace, name, f) {
                    this.getNamespace(namespace)[name] = f;
                }
            }, {
                key: "cleanNamespace",
                value: function cleanNamespace(namespace) {
                    this.getNamespace(namespace).__proto__ = null;
                }
            }]);
            return SchemaItem;
        }();
        var NodeType = exports.NodeType = function(_SchemaItem) {
            _inherits(NodeType, _SchemaItem);
            function NodeType(name, schema) {
                _classCallCheck(this, NodeType);
                var _this = _possibleConstructorReturn(this, Object.getPrototypeOf(NodeType).call(this));
                _this.name = name;
                _this.freezeAttrs();
                _this.defaultAttrs = _this.getDefaultAttrs();
                _this.schema = schema;
                return _this;
            }
            _createClass(NodeType, [{
                key: "canContainFragment",
                value: function canContainFragment(fragment) {
                    for (var i = 0; i < fragment.childCount; i++) {
                        if (!this.canContain(fragment.child(i)))
                            return false;
                    }
                    return true;
                }
            }, {
                key: "canContain",
                value: function canContain(node) {
                    if (!this.canContainType(node.type))
                        return false;
                    for (var i = 0; i < node.marks.length; i++) {
                        if (!this.canContainMark(node.marks[i]))
                            return false;
                    }
                    return true;
                }
            }, {
                key: "canContainMark",
                value: function canContainMark(mark) {
                    var contains = this.containsMarks;
                    if (contains === true)
                        return true;
                    if (contains)
                        for (var i = 0; i < contains.length; i++) {
                            if (contains[i] == mark.name)
                                return true;
                        }
                    return false;
                }
            }, {
                key: "canContainType",
                value: function canContainType(type) {
                    return type.kind && type.kind.isSubKind(this.contains);
                }
            }, {
                key: "canContainContent",
                value: function canContainContent(type) {
                    return type.contains && type.contains.isSubKind(this.contains);
                }
            }, {
                key: "findConnection",
                value: function findConnection(other) {
                    return other.kind && this.findConnectionToKind(other.kind);
                }
            }, {
                key: "findConnectionToKind",
                value: function findConnectionToKind(kind) {
                    var cache = this.schema.cached.connections,
                        key = this.name + "-" + kind.id;
                    if (key in cache)
                        return cache[key];
                    return cache[key] = this.findConnectionToKindInner(kind);
                }
            }, {
                key: "findConnectionToKindInner",
                value: function findConnectionToKindInner(kind) {
                    if (kind.isSubKind(this.contains))
                        return [];
                    var seen = Object.create(null);
                    var active = [{
                        from: this,
                        via: []
                    }];
                    while (active.length) {
                        var current = active.shift();
                        for (var name in this.schema.nodes) {
                            var type = this.schema.nodes[name];
                            if (type.contains && type.defaultAttrs && !(type.contains.id in seen) && current.from.canContainType(type)) {
                                var via = current.via.concat(type);
                                if (kind.isSubKind(type.contains))
                                    return via;
                                active.push({
                                    from: type,
                                    via: via
                                });
                                seen[type.contains.id] = true;
                            }
                        }
                    }
                }
            }, {
                key: "computeAttrs",
                value: function computeAttrs(attrs, content) {
                    if (!attrs && this.defaultAttrs)
                        return this.defaultAttrs;
                    else
                        return _get(Object.getPrototypeOf(NodeType.prototype), "computeAttrs", this).call(this, attrs, content);
                }
            }, {
                key: "create",
                value: function create(attrs, content, marks) {
                    return new _node.Node(this, this.computeAttrs(attrs, content), _fragment.Fragment.from(content), _mark.Mark.setFrom(marks));
                }
            }, {
                key: "checkContent",
                value: function checkContent(content, _attrs) {
                    if (content.size == 0)
                        return this.canBeEmpty;
                    for (var i = 0; i < content.childCount; i++) {
                        if (!this.canContain(content.child(i)))
                            return false;
                    }
                    return true;
                }
            }, {
                key: "fixContent",
                value: function fixContent(_content, _attrs) {
                    return this.defaultContent();
                }
            }, {
                key: "isBlock",
                get: function get() {
                    return false;
                }
            }, {
                key: "isTextblock",
                get: function get() {
                    return false;
                }
            }, {
                key: "isInline",
                get: function get() {
                    return false;
                }
            }, {
                key: "isText",
                get: function get() {
                    return false;
                }
            }, {
                key: "selectable",
                get: function get() {
                    return true;
                }
            }, {
                key: "draggable",
                get: function get() {
                    return false;
                }
            }, {
                key: "locked",
                get: function get() {
                    return false;
                }
            }, {
                key: "contains",
                get: function get() {
                    return null;
                }
            }, {
                key: "kind",
                get: function get() {
                    return null;
                }
            }, {
                key: "canBeEmpty",
                get: function get() {
                    return true;
                }
            }, {
                key: "containsMarks",
                get: function get() {
                    return false;
                }
            }], [{
                key: "compile",
                value: function compile(types, schema) {
                    var result = Object.create(null);
                    for (var name in types) {
                        result[name] = new types[name](name, schema);
                    }
                    if (!result.doc)
                        throw new RangeError("Every schema needs a 'doc' type");
                    if (!result.text)
                        throw new RangeError("Every schema needs a 'text' type");
                    return result;
                }
            }]);
            return NodeType;
        }(SchemaItem);
        var NodeKind = exports.NodeKind = function() {
            function NodeKind(name, supers, subs) {
                var _this2 = this;
                _classCallCheck(this, NodeKind);
                this.name = name;
                this.id = ++NodeKind.nextID;
                this.supers = Object.create(null);
                this.supers[this.id] = this;
                this.subs = subs || [];
                if (supers)
                    supers.forEach(function(sup) {
                        return _this2.addSuper(sup);
                    });
                if (subs)
                    subs.forEach(function(sub) {
                        return _this2.addSub(sub);
                    });
            }
            _createClass(NodeKind, [{
                key: "sharedSuperKind",
                value: function sharedSuperKind(other) {
                    if (this.isSubKind(other))
                        return other;
                    if (other.isSubKind(this))
                        return this;
                    var found = undefined;
                    for (var id in this.supers) {
                        var shared = other.supers[id];
                        if (shared && (!found || shared.isSupKind(found)))
                            found = shared;
                    }
                    return found;
                }
            }, {
                key: "addSuper",
                value: function addSuper(sup) {
                    for (var id in sup.supers) {
                        this.supers[id] = sup.supers[id];
                        sup.subs.push(this);
                    }
                }
            }, {
                key: "addSub",
                value: function addSub(sub) {
                    var _this3 = this;
                    if (this.supers[sub.id])
                        throw new RangeError("Circular subkind relation");
                    sub.supers[this.id] = true;
                    sub.subs.forEach(function(next) {
                        return _this3.addSub(next);
                    });
                }
            }, {
                key: "isSubKind",
                value: function isSubKind(other) {
                    return other && other.id in this.supers || false;
                }
            }]);
            return NodeKind;
        }();
        NodeKind.nextID = 0;
        NodeKind.block = new NodeKind("block");
        NodeKind.inline = new NodeKind("inline");
        NodeKind.text = new NodeKind("text", [NodeKind.inline]);
        var Block = exports.Block = function(_NodeType) {
            _inherits(Block, _NodeType);
            function Block() {
                _classCallCheck(this, Block);
                return _possibleConstructorReturn(this, Object.getPrototypeOf(Block).apply(this, arguments));
            }
            _createClass(Block, [{
                key: "defaultContent",
                value: function defaultContent() {
                    var inner = this.schema.defaultTextblockType().create();
                    var conn = this.findConnection(inner.type);
                    if (!conn)
                        throw new RangeError("Can't create default content for " + this.name);
                    for (var i = conn.length - 1; i >= 0; i--) {
                        inner = conn[i].create(null, inner);
                    }
                    return _fragment.Fragment.from(inner);
                }
            }, {
                key: "contains",
                get: function get() {
                    return NodeKind.block;
                }
            }, {
                key: "kind",
                get: function get() {
                    return NodeKind.block;
                }
            }, {
                key: "isBlock",
                get: function get() {
                    return true;
                }
            }, {
                key: "canBeEmpty",
                get: function get() {
                    return this.contains == null;
                }
            }]);
            return Block;
        }(NodeType);
        var Textblock = exports.Textblock = function(_Block) {
            _inherits(Textblock, _Block);
            function Textblock() {
                _classCallCheck(this, Textblock);
                return _possibleConstructorReturn(this, Object.getPrototypeOf(Textblock).apply(this, arguments));
            }
            _createClass(Textblock, [{
                key: "contains",
                get: function get() {
                    return NodeKind.inline;
                }
            }, {
                key: "containsMarks",
                get: function get() {
                    return true;
                }
            }, {
                key: "isTextblock",
                get: function get() {
                    return true;
                }
            }, {
                key: "canBeEmpty",
                get: function get() {
                    return true;
                }
            }]);
            return Textblock;
        }(Block);
        var Inline = exports.Inline = function(_NodeType2) {
            _inherits(Inline, _NodeType2);
            function Inline() {
                _classCallCheck(this, Inline);
                return _possibleConstructorReturn(this, Object.getPrototypeOf(Inline).apply(this, arguments));
            }
            _createClass(Inline, [{
                key: "kind",
                get: function get() {
                    return NodeKind.inline;
                }
            }, {
                key: "isInline",
                get: function get() {
                    return true;
                }
            }]);
            return Inline;
        }(NodeType);
        var Text = exports.Text = function(_Inline) {
            _inherits(Text, _Inline);
            function Text() {
                _classCallCheck(this, Text);
                return _possibleConstructorReturn(this, Object.getPrototypeOf(Text).apply(this, arguments));
            }
            _createClass(Text, [{
                key: "create",
                value: function create(attrs, content, marks) {
                    return new _node.TextNode(this, this.computeAttrs(attrs, content), content, marks);
                }
            }, {
                key: "selectable",
                get: function get() {
                    return false;
                }
            }, {
                key: "isText",
                get: function get() {
                    return true;
                }
            }, {
                key: "kind",
                get: function get() {
                    return NodeKind.text;
                }
            }]);
            return Text;
        }(Inline);
        var Attribute = exports.Attribute = function Attribute() {
            var options = arguments.length <= 0 || arguments[0] === undefined ? {} : arguments[0];
            _classCallCheck(this, Attribute);
            this.default = options.default;
            this.compute = options.compute;
            this.label = options.label;
        };
        var MarkType = exports.MarkType = function(_SchemaItem2) {
            _inherits(MarkType, _SchemaItem2);
            function MarkType(name, rank, schema) {
                _classCallCheck(this, MarkType);
                var _this8 = _possibleConstructorReturn(this, Object.getPrototypeOf(MarkType).call(this));
                _this8.name = name;
                _this8.freezeAttrs();
                _this8.rank = rank;
                _this8.schema = schema;
                var defaults = _this8.getDefaultAttrs();
                _this8.instance = defaults && new _mark.Mark(_this8, defaults);
                return _this8;
            }
            _createClass(MarkType, [{
                key: "create",
                value: function create(attrs) {
                    if (!attrs && this.instance)
                        return this.instance;
                    return new _mark.Mark(this, this.computeAttrs(attrs));
                }
            }, {
                key: "removeFromSet",
                value: function removeFromSet(set) {
                    for (var i = 0; i < set.length; i++) {
                        if (set[i].type == this)
                            return set.slice(0, i).concat(set.slice(i + 1));
                    }
                    return set;
                }
            }, {
                key: "isInSet",
                value: function isInSet(set) {
                    for (var i = 0; i < set.length; i++) {
                        if (set[i].type == this)
                            return set[i];
                    }
                }
            }, {
                key: "inclusiveRight",
                get: function get() {
                    return true;
                }
            }], [{
                key: "getOrder",
                value: function getOrder(marks) {
                    var sorted = [];
                    for (var name in marks) {
                        sorted.push({
                            name: name,
                            rank: marks[name].rank
                        });
                    }
                    sorted.sort(function(a, b) {
                        return a.rank - b.rank;
                    });
                    var ranks = Object.create(null);
                    for (var i = 0; i < sorted.length; i++) {
                        ranks[sorted[i].name] = i;
                    }
                    return ranks;
                }
            }, {
                key: "compile",
                value: function compile(marks, schema) {
                    var order = this.getOrder(marks);
                    var result = Object.create(null);
                    for (var name in marks) {
                        result[name] = new marks[name](name, order[name], schema);
                    }
                    return result;
                }
            }, {
                key: "rank",
                get: function get() {
                    return 50;
                }
            }]);
            return MarkType;
        }(SchemaItem);
        var SchemaSpec = exports.SchemaSpec = function() {
            function SchemaSpec(nodes, marks) {
                _classCallCheck(this, SchemaSpec);
                this.nodes = nodes || {};
                this.marks = marks || {};
            }
            _createClass(SchemaSpec, [{
                key: "update",
                value: function update(nodes, marks) {
                    return new SchemaSpec(nodes ? overlayObj(this.nodes, nodes) : this.nodes, marks ? overlayObj(this.marks, marks) : this.marks);
                }
            }]);
            return SchemaSpec;
        }();
        function overlayObj(base, update) {
            var copy = (0, _obj.copyObj)(base);
            for (var name in update) {
                var value = update[name];
                if (value == null)
                    delete copy[name];
                else
                    copy[name] = value;
            }
            return copy;
        }
        var Schema = function() {
            function Schema(spec) {
                _classCallCheck(this, Schema);
                this.spec = spec;
                this.nodes = NodeType.compile(spec.nodes, this);
                this.marks = MarkType.compile(spec.marks, this);
                for (var prop in this.nodes) {
                    if (prop in this.marks)
                        throw new RangeError(prop + " can not be both a node and a mark");
                }
                this.cached = Object.create(null);
                this.cached.connections = Object.create(null);
                this.node = this.node.bind(this);
                this.text = this.text.bind(this);
                this.nodeFromJSON = this.nodeFromJSON.bind(this);
                this.markFromJSON = this.markFromJSON.bind(this);
            }
            _createClass(Schema, [{
                key: "node",
                value: function node(type, attrs, content, marks) {
                    if (typeof type == "string")
                        type = this.nodeType(type);
                    else if (!(type instanceof NodeType))
                        throw new RangeError("Invalid node type: " + type);
                    else if (type.schema != this)
                        throw new RangeError("Node type from different schema used (" + type.name + ")");
                    return type.create(attrs, content, marks);
                }
            }, {
                key: "text",
                value: function text(_text, marks) {
                    return this.nodes.text.create(null, _text, _mark.Mark.setFrom(marks));
                }
            }, {
                key: "defaultTextblockType",
                value: function defaultTextblockType() {
                    var cached = this.cached.defaultTextblockType;
                    if (cached !== undefined)
                        return cached;
                    for (var name in this.nodes) {
                        if (this.nodes[name].defaultTextblock)
                            return this.cached.defaultTextblockType = this.nodes[name];
                    }
                    return this.cached.defaultTextblockType = null;
                }
            }, {
                key: "mark",
                value: function mark(name, attrs) {
                    var spec = this.marks[name];
                    if (!spec)
                        throw new RangeError("No mark named " + name);
                    return spec.create(attrs);
                }
            }, {
                key: "nodeFromJSON",
                value: function nodeFromJSON(json) {
                    return _node.Node.fromJSON(this, json);
                }
            }, {
                key: "markFromJSON",
                value: function markFromJSON(json) {
                    var type = this.marks[json._];
                    var attrs = null;
                    for (var prop in json) {
                        if (prop != "_") {
                            if (!attrs)
                                attrs = Object.create(null);
                            attrs[prop] = json[prop];
                        }
                    }
                    return attrs ? type.create(attrs) : type.instance;
                }
            }, {
                key: "nodeType",
                value: function nodeType(name) {
                    var found = this.nodes[name];
                    if (!found)
                        throw new RangeError("Unknown node type: " + name);
                    return found;
                }
            }, {
                key: "registry",
                value: function registry(namespace, f) {
                    for (var i = 0; i < 2; i++) {
                        var obj = i ? this.marks : this.nodes;
                        for (var tname in obj) {
                            var type = obj[tname],
                                registry = type.registry,
                                ns = registry && registry[namespace];
                            if (ns)
                                for (var prop in ns) {
                                    var value = ns[prop](type);
                                    if (value != null)
                                        f(prop, value, type, tname);
                                }
                        }
                    }
                }
            }]);
            return Schema;
        }();
        exports.Schema = Schema;
        return module.exports;
    });

    $__System.registerDynamic("3a", ["39"], true, function($__require, exports, module) {
        "use strict";
        ;
        var define,
            global = this,
            GLOBAL = this;
        Object.defineProperty(exports, "__esModule", {value: true});
        exports.defaultSchema = exports.CodeMark = exports.LinkMark = exports.StrongMark = exports.EmMark = exports.HardBreak = exports.Image = exports.Paragraph = exports.CodeBlock = exports.Heading = exports.HorizontalRule = exports.ListItem = exports.BulletList = exports.OrderedList = exports.BlockQuote = exports.Doc = undefined;
        var _createClass = function() {
            function defineProperties(target, props) {
                for (var i = 0; i < props.length; i++) {
                    var descriptor = props[i];
                    descriptor.enumerable = descriptor.enumerable || false;
                    descriptor.configurable = true;
                    if ("value" in descriptor)
                        descriptor.writable = true;
                    Object.defineProperty(target, descriptor.key, descriptor);
                }
            }
            return function(Constructor, protoProps, staticProps) {
                if (protoProps)
                    defineProperties(Constructor.prototype, protoProps);
                if (staticProps)
                    defineProperties(Constructor, staticProps);
                return Constructor;
            };
        }();
        var _schema = $__require('39');
        function _classCallCheck(instance, Constructor) {
            if (!(instance instanceof Constructor)) {
                throw new TypeError("Cannot call a class as a function");
            }
        }
        function _possibleConstructorReturn(self, call) {
            if (!self) {
                throw new ReferenceError("this hasn't been initialised - super() hasn't been called");
            }
            return call && (typeof call === "object" || typeof call === "function") ? call : self;
        }
        function _inherits(subClass, superClass) {
            if (typeof superClass !== "function" && superClass !== null) {
                throw new TypeError("Super expression must either be null or a function, not " + typeof superClass);
            }
            subClass.prototype = Object.create(superClass && superClass.prototype, {constructor: {
                value: subClass,
                enumerable: false,
                writable: true,
                configurable: true
            }});
            if (superClass)
                Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass;
        }
        var Doc = exports.Doc = function(_Block) {
            _inherits(Doc, _Block);
            function Doc() {
                _classCallCheck(this, Doc);
                return _possibleConstructorReturn(this, Object.getPrototypeOf(Doc).apply(this, arguments));
            }
            _createClass(Doc, [{
                key: "kind",
                get: function get() {
                    return null;
                }
            }]);
            return Doc;
        }(_schema.Block);
        var BlockQuote = exports.BlockQuote = function(_Block2) {
            _inherits(BlockQuote, _Block2);
            function BlockQuote() {
                _classCallCheck(this, BlockQuote);
                return _possibleConstructorReturn(this, Object.getPrototypeOf(BlockQuote).apply(this, arguments));
            }
            return BlockQuote;
        }(_schema.Block);
        _schema.NodeKind.list_item = new _schema.NodeKind("list_item");
        var OrderedList = exports.OrderedList = function(_Block3) {
            _inherits(OrderedList, _Block3);
            function OrderedList() {
                _classCallCheck(this, OrderedList);
                return _possibleConstructorReturn(this, Object.getPrototypeOf(OrderedList).apply(this, arguments));
            }
            _createClass(OrderedList, [{
                key: "contains",
                get: function get() {
                    return _schema.NodeKind.list_item;
                }
            }, {
                key: "attrs",
                get: function get() {
                    return {order: new _schema.Attribute({default: "1"})};
                }
            }]);
            return OrderedList;
        }(_schema.Block);
        var BulletList = exports.BulletList = function(_Block4) {
            _inherits(BulletList, _Block4);
            function BulletList() {
                _classCallCheck(this, BulletList);
                return _possibleConstructorReturn(this, Object.getPrototypeOf(BulletList).apply(this, arguments));
            }
            _createClass(BulletList, [{
                key: "contains",
                get: function get() {
                    return _schema.NodeKind.list_item;
                }
            }]);
            return BulletList;
        }(_schema.Block);
        var ListItem = exports.ListItem = function(_Block5) {
            _inherits(ListItem, _Block5);
            function ListItem() {
                _classCallCheck(this, ListItem);
                return _possibleConstructorReturn(this, Object.getPrototypeOf(ListItem).apply(this, arguments));
            }
            _createClass(ListItem, [{
                key: "kind",
                get: function get() {
                    return _schema.NodeKind.list_item;
                }
            }]);
            return ListItem;
        }(_schema.Block);
        var HorizontalRule = exports.HorizontalRule = function(_Block6) {
            _inherits(HorizontalRule, _Block6);
            function HorizontalRule() {
                _classCallCheck(this, HorizontalRule);
                return _possibleConstructorReturn(this, Object.getPrototypeOf(HorizontalRule).apply(this, arguments));
            }
            _createClass(HorizontalRule, [{
                key: "contains",
                get: function get() {
                    return null;
                }
            }]);
            return HorizontalRule;
        }(_schema.Block);
        var Heading = exports.Heading = function(_Textblock) {
            _inherits(Heading, _Textblock);
            function Heading() {
                _classCallCheck(this, Heading);
                return _possibleConstructorReturn(this, Object.getPrototypeOf(Heading).apply(this, arguments));
            }
            _createClass(Heading, [{
                key: "attrs",
                get: function get() {
                    return {level: new _schema.Attribute({default: "1"})};
                }
            }, {
                key: "maxLevel",
                get: function get() {
                    return 6;
                }
            }]);
            return Heading;
        }(_schema.Textblock);
        var CodeBlock = exports.CodeBlock = function(_Textblock2) {
            _inherits(CodeBlock, _Textblock2);
            function CodeBlock() {
                _classCallCheck(this, CodeBlock);
                return _possibleConstructorReturn(this, Object.getPrototypeOf(CodeBlock).apply(this, arguments));
            }
            _createClass(CodeBlock, [{
                key: "contains",
                get: function get() {
                    return _schema.NodeKind.text;
                }
            }, {
                key: "containsMarks",
                get: function get() {
                    return false;
                }
            }, {
                key: "isCode",
                get: function get() {
                    return true;
                }
            }]);
            return CodeBlock;
        }(_schema.Textblock);
        var Paragraph = exports.Paragraph = function(_Textblock3) {
            _inherits(Paragraph, _Textblock3);
            function Paragraph() {
                _classCallCheck(this, Paragraph);
                return _possibleConstructorReturn(this, Object.getPrototypeOf(Paragraph).apply(this, arguments));
            }
            _createClass(Paragraph, [{
                key: "defaultTextblock",
                get: function get() {
                    return true;
                }
            }]);
            return Paragraph;
        }(_schema.Textblock);
        var Image = exports.Image = function(_Inline) {
            _inherits(Image, _Inline);
            function Image() {
                _classCallCheck(this, Image);
                return _possibleConstructorReturn(this, Object.getPrototypeOf(Image).apply(this, arguments));
            }
            _createClass(Image, [{
                key: "attrs",
                get: function get() {
                    return {
                        src: new _schema.Attribute(),
                        alt: new _schema.Attribute({default: ""}),
                        title: new _schema.Attribute({default: ""})
                    };
                }
            }, {
                key: "draggable",
                get: function get() {
                    return true;
                }
            }]);
            return Image;
        }(_schema.Inline);
        var HardBreak = exports.HardBreak = function(_Inline2) {
            _inherits(HardBreak, _Inline2);
            function HardBreak() {
                _classCallCheck(this, HardBreak);
                return _possibleConstructorReturn(this, Object.getPrototypeOf(HardBreak).apply(this, arguments));
            }
            _createClass(HardBreak, [{
                key: "selectable",
                get: function get() {
                    return false;
                }
            }, {
                key: "isBR",
                get: function get() {
                    return true;
                }
            }]);
            return HardBreak;
        }(_schema.Inline);
        var EmMark = exports.EmMark = function(_MarkType) {
            _inherits(EmMark, _MarkType);
            function EmMark() {
                _classCallCheck(this, EmMark);
                return _possibleConstructorReturn(this, Object.getPrototypeOf(EmMark).apply(this, arguments));
            }
            _createClass(EmMark, null, [{
                key: "rank",
                get: function get() {
                    return 31;
                }
            }]);
            return EmMark;
        }(_schema.MarkType);
        var StrongMark = exports.StrongMark = function(_MarkType2) {
            _inherits(StrongMark, _MarkType2);
            function StrongMark() {
                _classCallCheck(this, StrongMark);
                return _possibleConstructorReturn(this, Object.getPrototypeOf(StrongMark).apply(this, arguments));
            }
            _createClass(StrongMark, null, [{
                key: "rank",
                get: function get() {
                    return 32;
                }
            }]);
            return StrongMark;
        }(_schema.MarkType);
        var LinkMark = exports.LinkMark = function(_MarkType3) {
            _inherits(LinkMark, _MarkType3);
            function LinkMark() {
                _classCallCheck(this, LinkMark);
                return _possibleConstructorReturn(this, Object.getPrototypeOf(LinkMark).apply(this, arguments));
            }
            _createClass(LinkMark, [{
                key: "attrs",
                get: function get() {
                    return {
                        href: new _schema.Attribute(),
                        title: new _schema.Attribute({default: ""})
                    };
                }
            }], [{
                key: "rank",
                get: function get() {
                    return 60;
                }
            }]);
            return LinkMark;
        }(_schema.MarkType);
        var CodeMark = exports.CodeMark = function(_MarkType4) {
            _inherits(CodeMark, _MarkType4);
            function CodeMark() {
                _classCallCheck(this, CodeMark);
                return _possibleConstructorReturn(this, Object.getPrototypeOf(CodeMark).apply(this, arguments));
            }
            _createClass(CodeMark, [{
                key: "isCode",
                get: function get() {
                    return true;
                }
            }], [{
                key: "rank",
                get: function get() {
                    return 101;
                }
            }]);
            return CodeMark;
        }(_schema.MarkType);
        var defaultSpec = new _schema.SchemaSpec({
            doc: Doc,
            blockquote: BlockQuote,
            ordered_list: OrderedList,
            bullet_list: BulletList,
            list_item: ListItem,
            horizontal_rule: HorizontalRule,
            paragraph: Paragraph,
            heading: Heading,
            code_block: CodeBlock,
            text: _schema.Text,
            image: Image,
            hard_break: HardBreak
        }, {
            em: EmMark,
            strong: StrongMark,
            link: LinkMark,
            code: CodeMark
        });
        var defaultSchema = exports.defaultSchema = new _schema.Schema(defaultSpec);
        return module.exports;
    });

    $__System.registerDynamic("3b", [], true, function($__require, exports, module) {
        "use strict";
        ;
        var define,
            global = this,
            GLOBAL = this;
        Object.defineProperty(exports, "__esModule", {value: true});
        exports.findDiffStart = findDiffStart;
        exports.findDiffEnd = findDiffEnd;
        function findDiffStart(a, b) {
            var pos = arguments.length <= 2 || arguments[2] === undefined ? 0 : arguments[2];
            for (var i = 0; ; i++) {
                if (i == a.childCount || i == b.childCount)
                    return a.childCount == b.childCount ? null : pos;
                var childA = a.child(i),
                    childB = b.child(i);
                if (childA == childB) {
                    pos += childA.nodeSize;
                    continue;
                }
                if (!childA.sameMarkup(childB))
                    return pos;
                if (childA.isText && childA.text != childB.text) {
                    for (var j = 0; childA.text[j] == childB.text[j]; j++) {
                        pos++;
                    }
                    return pos;
                }
                if (childA.content.size || childB.content.size) {
                    var inner = findDiffStart(childA.content, childB.content, pos + 1);
                    if (inner != null)
                        return inner;
                }
                pos += childA.nodeSize;
            }
        }
        function findDiffEnd(a, b) {
            var posA = arguments.length <= 2 || arguments[2] === undefined ? a.size : arguments[2];
            var posB = arguments.length <= 3 || arguments[3] === undefined ? b.size : arguments[3];
            for (var iA = a.childCount,
                     iB = b.childCount; ; ) {
                if (iA == 0 || iB == 0)
                    return iA == iB ? null : {
                        a: posA,
                        b: posB
                    };
                var childA = a.child(--iA),
                    childB = b.child(--iB),
                    size = childA.nodeSize;
                if (childA == childB) {
                    posA -= size;
                    posB -= size;
                    continue;
                }
                if (!childA.sameMarkup(childB))
                    return {
                        a: posA,
                        b: posB
                    };
                if (childA.isText && childA.text != childB.text) {
                    var same = 0,
                        minSize = Math.min(childA.text.length, childB.text.length);
                    while (same < minSize && childA.text[childA.text.length - same - 1] == childB.text[childB.text.length - same - 1]) {
                        same++;
                        posA--;
                        posB--;
                    }
                    return {
                        a: posA,
                        b: posB
                    };
                }
                if (childA.content.size || childB.content.size) {
                    var inner = findDiffEnd(childA.content, childB.content, posA - 1, posB - 1);
                    if (inner)
                        return inner;
                }
                posA -= size;
                posB -= size;
            }
        }
        return module.exports;
    });

    $__System.registerDynamic("6", ["37", "36", "35", "34", "38", "39", "3a", "3b"], true, function($__require, exports, module) {
        "use strict";
        ;
        var define,
            global = this,
            GLOBAL = this;
        Object.defineProperty(exports, "__esModule", {value: true});
        var _node = $__require('37');
        Object.defineProperty(exports, "Node", {
            enumerable: true,
            get: function get() {
                return _node.Node;
            }
        });
        var _resolvedpos = $__require('36');
        Object.defineProperty(exports, "ResolvedPos", {
            enumerable: true,
            get: function get() {
                return _resolvedpos.ResolvedPos;
            }
        });
        var _fragment = $__require('35');
        Object.defineProperty(exports, "Fragment", {
            enumerable: true,
            get: function get() {
                return _fragment.Fragment;
            }
        });
        var _replace = $__require('34');
        Object.defineProperty(exports, "Slice", {
            enumerable: true,
            get: function get() {
                return _replace.Slice;
            }
        });
        Object.defineProperty(exports, "ReplaceError", {
            enumerable: true,
            get: function get() {
                return _replace.ReplaceError;
            }
        });
        var _mark = $__require('38');
        Object.defineProperty(exports, "Mark", {
            enumerable: true,
            get: function get() {
                return _mark.Mark;
            }
        });
        var _schema = $__require('39');
        Object.defineProperty(exports, "SchemaSpec", {
            enumerable: true,
            get: function get() {
                return _schema.SchemaSpec;
            }
        });
        Object.defineProperty(exports, "Schema", {
            enumerable: true,
            get: function get() {
                return _schema.Schema;
            }
        });
        Object.defineProperty(exports, "NodeType", {
            enumerable: true,
            get: function get() {
                return _schema.NodeType;
            }
        });
        Object.defineProperty(exports, "Block", {
            enumerable: true,
            get: function get() {
                return _schema.Block;
            }
        });
        Object.defineProperty(exports, "Textblock", {
            enumerable: true,
            get: function get() {
                return _schema.Textblock;
            }
        });
        Object.defineProperty(exports, "Inline", {
            enumerable: true,
            get: function get() {
                return _schema.Inline;
            }
        });
        Object.defineProperty(exports, "Text", {
            enumerable: true,
            get: function get() {
                return _schema.Text;
            }
        });
        Object.defineProperty(exports, "MarkType", {
            enumerable: true,
            get: function get() {
                return _schema.MarkType;
            }
        });
        Object.defineProperty(exports, "Attribute", {
            enumerable: true,
            get: function get() {
                return _schema.Attribute;
            }
        });
        Object.defineProperty(exports, "NodeKind", {
            enumerable: true,
            get: function get() {
                return _schema.NodeKind;
            }
        });
        var _defaultschema = $__require('3a');
        Object.defineProperty(exports, "defaultSchema", {
            enumerable: true,
            get: function get() {
                return _defaultschema.defaultSchema;
            }
        });
        Object.defineProperty(exports, "Doc", {
            enumerable: true,
            get: function get() {
                return _defaultschema.Doc;
            }
        });
        Object.defineProperty(exports, "BlockQuote", {
            enumerable: true,
            get: function get() {
                return _defaultschema.BlockQuote;
            }
        });
        Object.defineProperty(exports, "OrderedList", {
            enumerable: true,
            get: function get() {
                return _defaultschema.OrderedList;
            }
        });
        Object.defineProperty(exports, "BulletList", {
            enumerable: true,
            get: function get() {
                return _defaultschema.BulletList;
            }
        });
        Object.defineProperty(exports, "ListItem", {
            enumerable: true,
            get: function get() {
                return _defaultschema.ListItem;
            }
        });
        Object.defineProperty(exports, "HorizontalRule", {
            enumerable: true,
            get: function get() {
                return _defaultschema.HorizontalRule;
            }
        });
        Object.defineProperty(exports, "Paragraph", {
            enumerable: true,
            get: function get() {
                return _defaultschema.Paragraph;
            }
        });
        Object.defineProperty(exports, "Heading", {
            enumerable: true,
            get: function get() {
                return _defaultschema.Heading;
            }
        });
        Object.defineProperty(exports, "CodeBlock", {
            enumerable: true,
            get: function get() {
                return _defaultschema.CodeBlock;
            }
        });
        Object.defineProperty(exports, "Image", {
            enumerable: true,
            get: function get() {
                return _defaultschema.Image;
            }
        });
        Object.defineProperty(exports, "HardBreak", {
            enumerable: true,
            get: function get() {
                return _defaultschema.HardBreak;
            }
        });
        Object.defineProperty(exports, "CodeMark", {
            enumerable: true,
            get: function get() {
                return _defaultschema.CodeMark;
            }
        });
        Object.defineProperty(exports, "EmMark", {
            enumerable: true,
            get: function get() {
                return _defaultschema.EmMark;
            }
        });
        Object.defineProperty(exports, "StrongMark", {
            enumerable: true,
            get: function get() {
                return _defaultschema.StrongMark;
            }
        });
        Object.defineProperty(exports, "LinkMark", {
            enumerable: true,
            get: function get() {
                return _defaultschema.LinkMark;
            }
        });
        var _diff = $__require('3b');
        Object.defineProperty(exports, "findDiffStart", {
            enumerable: true,
            get: function get() {
                return _diff.findDiffStart;
            }
        });
        Object.defineProperty(exports, "findDiffEnd", {
            enumerable: true,
            get: function get() {
                return _diff.findDiffEnd;
            }
        });
        return module.exports;
    });

    $__System.registerDynamic("31", [], true, function($__require, exports, module) {
        "use strict";
        ;
        var define,
            global = this,
            GLOBAL = this;
        Object.defineProperty(exports, "__esModule", {value: true});
        exports.serializeTo = serializeTo;
        exports.knownTarget = knownTarget;
        exports.defineTarget = defineTarget;
        exports.parseFrom = parseFrom;
        exports.knownSource = knownSource;
        exports.defineSource = defineSource;
        var serializers = Object.create(null);
        function serializeTo(doc, format, options) {
            var converter = serializers[format];
            if (!converter)
                throw new RangeError("Target format " + format + " not defined");
            return converter(doc, options);
        }
        function knownTarget(format) {
            return !!serializers[format];
        }
        function defineTarget(format, func) {
            serializers[format] = func;
        }
        defineTarget("json", function(doc) {
            return doc.toJSON();
        });
        var parsers = Object.create(null);
        function parseFrom(schema, value, format, options) {
            var converter = parsers[format];
            if (!converter)
                throw new RangeError("Source format " + format + " not defined");
            return converter(schema, value, options);
        }
        function knownSource(format) {
            return !!parsers[format];
        }
        function defineSource(format, func) {
            parsers[format] = func;
        }
        defineSource("json", function(schema, json) {
            return schema.nodeFromJSON(json);
        });
        return module.exports;
    });

    $__System.registerDynamic("3c", ["6", "31"], true, function($__require, exports, module) {
        "use strict";
        ;
        var define,
            global = this,
            GLOBAL = this;
        Object.defineProperty(exports, "__esModule", {value: true});
        exports.toText = toText;
        var _model = $__require('6');
        var _register = $__require('31');
        function serializeFragment(fragment) {
            var accum = "";
            fragment.forEach(function(child) {
                return accum += child.type.serializeText(child);
            });
            return accum;
        }
        _model.Block.prototype.serializeText = function(node) {
            return serializeFragment(node.content);
        };
        _model.Textblock.prototype.serializeText = function(node) {
            var text = _model.Block.prototype.serializeText(node);
            return text && text + "\n\n";
        };
        _model.Inline.prototype.serializeText = function() {
            return "";
        };
        _model.HardBreak.prototype.serializeText = function() {
            return "\n";
        };
        _model.Text.prototype.serializeText = function(node) {
            return node.text;
        };
        function toText(content) {
            return serializeFragment(content).trim();
        }
        (0, _register.defineTarget)("text", toText);
        return module.exports;
    });

    $__System.registerDynamic("f", ["31", "30", "32", "33", "3c"], true, function($__require, exports, module) {
        "use strict";
        ;
        var define,
            global = this,
            GLOBAL = this;
        Object.defineProperty(exports, "__esModule", {value: true});
        var _register = $__require('31');
        Object.defineProperty(exports, "serializeTo", {
            enumerable: true,
            get: function get() {
                return _register.serializeTo;
            }
        });
        Object.defineProperty(exports, "knownTarget", {
            enumerable: true,
            get: function get() {
                return _register.knownTarget;
            }
        });
        Object.defineProperty(exports, "defineTarget", {
            enumerable: true,
            get: function get() {
                return _register.defineTarget;
            }
        });
        Object.defineProperty(exports, "parseFrom", {
            enumerable: true,
            get: function get() {
                return _register.parseFrom;
            }
        });
        Object.defineProperty(exports, "knownSource", {
            enumerable: true,
            get: function get() {
                return _register.knownSource;
            }
        });
        Object.defineProperty(exports, "defineSource", {
            enumerable: true,
            get: function get() {
                return _register.defineSource;
            }
        });
        var _from_dom = $__require('30');
        Object.defineProperty(exports, "fromDOM", {
            enumerable: true,
            get: function get() {
                return _from_dom.fromDOM;
            }
        });
        Object.defineProperty(exports, "fromHTML", {
            enumerable: true,
            get: function get() {
                return _from_dom.fromHTML;
            }
        });
        var _to_dom = $__require('32');
        Object.defineProperty(exports, "toDOM", {
            enumerable: true,
            get: function get() {
                return _to_dom.toDOM;
            }
        });
        Object.defineProperty(exports, "toHTML", {
            enumerable: true,
            get: function get() {
                return _to_dom.toHTML;
            }
        });
        Object.defineProperty(exports, "nodeToDOM", {
            enumerable: true,
            get: function get() {
                return _to_dom.nodeToDOM;
            }
        });
        var _from_text = $__require('33');
        Object.defineProperty(exports, "fromText", {
            enumerable: true,
            get: function get() {
                return _from_text.fromText;
            }
        });
        var _to_text = $__require('3c');
        Object.defineProperty(exports, "toText", {
            enumerable: true,
            get: function get() {
                return _to_text.toText;
            }
        });
        return module.exports;
    });

    $__System.registerDynamic("3d", ["6", "20", "f"], true, function($__require, exports, module) {
        "use strict";
        ;
        var define,
            global = this,
            GLOBAL = this;
        var _model = $__require('6');
        var _command = $__require('20');
        var _format = $__require('f');
        _model.StrongMark.register("command", "set", {
            derive: true,
            label: "Set strong"
        });
        _model.StrongMark.register("command", "unset", {
            derive: true,
            label: "Unset strong"
        });
        _model.StrongMark.register("command", "toggle", {
            derive: true,
            label: "Toggle strong",
            menu: {
                group: "inline",
                rank: 20,
                display: {
                    type: "icon",
                    width: 805,
                    height: 1024,
                    path: "M317 869q42 18 80 18 214 0 214-191 0-65-23-102-15-25-35-42t-38-26-46-14-48-6-54-1q-41 0-57 5 0 30-0 90t-0 90q0 4-0 38t-0 55 2 47 6 38zM309 442q24 4 62 4 46 0 81-7t62-25 42-51 14-81q0-40-16-70t-45-46-61-24-70-8q-28 0-74 7 0 28 2 86t2 86q0 15-0 45t-0 45q0 26 0 39zM0 950l1-53q8-2 48-9t60-15q4-6 7-15t4-19 3-18 1-21 0-19v-37q0-561-12-585-2-4-12-8t-25-6-28-4-27-2-17-1l-2-47q56-1 194-6t213-5q13 0 39 0t38 0q40 0 78 7t73 24 61 40 42 59 16 78q0 29-9 54t-22 41-36 32-41 25-48 22q88 20 146 76t58 141q0 57-20 102t-53 74-78 48-93 27-100 8q-25 0-75-1t-75-1q-60 0-175 6t-132 6z"
                }
            },
            keys: ["Mod-B"]
        });
        _model.EmMark.register("command", "set", {
            derive: true,
            label: "Add emphasis"
        });
        _model.EmMark.register("command", "unset", {
            derive: true,
            label: "Remove emphasis"
        });
        _model.EmMark.register("command", "toggle", {
            derive: true,
            label: "Toggle emphasis",
            menu: {
                group: "inline",
                rank: 21,
                display: {
                    type: "icon",
                    width: 585,
                    height: 1024,
                    path: "M0 949l9-48q3-1 46-12t63-21q16-20 23-57 0-4 35-165t65-310 29-169v-14q-13-7-31-10t-39-4-33-3l10-58q18 1 68 3t85 4 68 1q27 0 56-1t69-4 56-3q-2 22-10 50-17 5-58 16t-62 19q-4 10-8 24t-5 22-4 26-3 24q-15 84-50 239t-44 203q-1 5-7 33t-11 51-9 47-3 32l0 10q9 2 105 17-1 25-9 56-6 0-18 0t-18 0q-16 0-49-5t-49-5q-78-1-117-1-29 0-81 5t-69 6z"
                }
            },
            keys: ["Mod-I"]
        });
        _model.CodeMark.register("command", "set", {
            derive: true,
            label: "Set code style"
        });
        _model.CodeMark.register("command", "unset", {
            derive: true,
            label: "Remove code style"
        });
        _model.CodeMark.register("command", "toggle", {
            derive: true,
            label: "Toggle code style",
            menu: {
                group: "inline",
                rank: 22,
                display: {
                    type: "icon",
                    width: 896,
                    height: 1024,
                    path: "M608 192l-96 96 224 224-224 224 96 96 288-320-288-320zM288 192l-288 320 288 320 96-96-224-224 224-224-96-96z"
                }
            },
            keys: ["Mod-`"]
        });
        var linkIcon = {
            type: "icon",
            width: 951,
            height: 1024,
            path: "M832 694q0-22-16-38l-118-118q-16-16-38-16-24 0-41 18 1 1 10 10t12 12 8 10 7 14 2 15q0 22-16 38t-38 16q-8 0-15-2t-14-7-10-8-12-12-10-10q-18 17-18 41 0 22 16 38l117 118q15 15 38 15 22 0 38-14l84-83q16-16 16-38zM430 292q0-22-16-38l-117-118q-16-16-38-16-22 0-38 15l-84 83q-16 16-16 38 0 22 16 38l118 118q15 15 38 15 24 0 41-17-1-1-10-10t-12-12-8-10-7-14-2-15q0-22 16-38t38-16q8 0 15 2t14 7 10 8 12 12 10 10q18-17 18-41zM941 694q0 68-48 116l-84 83q-47 47-116 47-69 0-116-48l-117-118q-47-47-47-116 0-70 50-119l-50-50q-49 50-118 50-68 0-116-48l-118-118q-48-48-48-116t48-116l84-83q47-47 116-47 69 0 116 48l117 118q47 47 47 116 0 70-50 119l50 50q49-50 118-50 68 0 116 48l118 118q48 48 48 116z"
        };
        _model.LinkMark.register("command", "unset", {
            derive: true,
            label: "Unlink",
            menu: {
                group: "inline",
                rank: 30,
                display: linkIcon
            },
            active: function active() {
                return true;
            }
        });
        _model.LinkMark.register("command", "set", {
            derive: {
                inverseSelect: true,
                params: [{
                    label: "Target",
                    attr: "href"
                }, {
                    label: "Title",
                    attr: "title"
                }]
            },
            label: "Add link",
            menu: {
                group: "inline",
                rank: 30,
                display: linkIcon
            }
        });
        _model.Image.register("command", "insert", {
            derive: {params: [{
                label: "Image URL",
                attr: "src"
            }, {
                label: "Description / alternative text",
                attr: "alt",
                prefill: function prefill(pm) {
                    return (0, _command.selectedNodeAttr)(pm, this, "alt") || (0, _format.toText)(pm.doc.cut(pm.selection.from, pm.selection.to));
                }
            }, {
                label: "Title",
                attr: "title"
            }]},
            label: "Insert image",
            menu: {
                group: "insert",
                rank: 20,
                display: {
                    type: "label",
                    label: "Image"
                }
            }
        });
        _model.BulletList.register("command", "wrap", {
            derive: {list: true},
            label: "Wrap the selection in a bullet list",
            menu: {
                group: "block",
                rank: 40,
                display: {
                    type: "icon",
                    width: 768,
                    height: 896,
                    path: "M0 512h128v-128h-128v128zM0 256h128v-128h-128v128zM0 768h128v-128h-128v128zM256 512h512v-128h-512v128zM256 256h512v-128h-512v128zM256 768h512v-128h-512v128z"
                }
            },
            keys: ["Shift-Ctrl-8"]
        });
        _model.OrderedList.register("command", "wrap", {
            derive: {list: true},
            label: "Wrap the selection in an ordered list",
            menu: {
                group: "block",
                rank: 41,
                display: {
                    type: "icon",
                    width: 768,
                    height: 896,
                    path: "M320 512h448v-128h-448v128zM320 768h448v-128h-448v128zM320 128v128h448v-128h-448zM79 384h78v-256h-36l-85 23v50l43-2v185zM189 590c0-36-12-78-96-78-33 0-64 6-83 16l1 66c21-10 42-15 67-15s32 11 32 28c0 26-30 58-110 112v50h192v-67l-91 2c49-30 87-66 87-113l1-1z"
                }
            },
            keys: ["Shift-Ctrl-9"]
        });
        _model.BlockQuote.register("command", "wrap", {
            derive: true,
            label: "Wrap the selection in a block quote",
            menu: {
                group: "block",
                rank: 45,
                display: {
                    type: "icon",
                    width: 640,
                    height: 896,
                    path: "M0 448v256h256v-256h-128c0 0 0-128 128-128v-128c0 0-256 0-256 256zM640 320v-128c0 0-256 0-256 256v256h256v-256h-128c0 0 0-128 128-128z"
                }
            },
            keys: ["Shift-Ctrl-."]
        });
        _model.HardBreak.register("command", "insert", {
            label: "Insert hard break",
            run: function run(pm) {
                var _pm$selection = pm.selection;
                var node = _pm$selection.node;
                var from = _pm$selection.from;
                if (node && node.isBlock)
                    return false;
                else if (pm.doc.resolve(from).parent.type.isCode)
                    return pm.tr.typeText("\n").apply(pm.apply.scroll);
                else
                    return pm.tr.replaceSelection(this.create()).apply(pm.apply.scroll);
            },
            keys: {
                all: ["Mod-Enter", "Shift-Enter"],
                mac: ["Ctrl-Enter"]
            }
        });
        _model.ListItem.register("command", "split", {
            label: "Split the current list item",
            run: function run(pm) {
                var _pm$selection2 = pm.selection;
                var from = _pm$selection2.from;
                var to = _pm$selection2.to;
                var node = _pm$selection2.node;
                var $from = pm.doc.resolve(from);
                if (node && node.isBlock || $from.depth < 2 || !$from.sameParent(pm.doc.resolve(to)))
                    return false;
                var grandParent = $from.node($from.depth - 1);
                if (grandParent.type != this)
                    return false;
                var nextType = to == $from.end($from.depth) ? pm.schema.defaultTextblockType() : null;
                return pm.tr.delete(from, to).split(from, 2, nextType).apply(pm.apply.scroll);
            },
            keys: ["Enter(50)"]
        });
        function selectedListItems(pm, type) {
            var _pm$selection3 = pm.selection;
            var node = _pm$selection3.node;
            var from = _pm$selection3.from;
            var to = _pm$selection3.to;
            var $from = pm.doc.resolve(from);
            if (node && node.type == type)
                return {
                    from: from,
                    to: to,
                    depth: $from.depth + 1
                };
            var itemDepth = $from.parent.type == type ? $from.depth : $from.depth > 0 && $from.node($from.depth - 1).type == type ? $from.depth - 1 : null;
            if (itemDepth == null)
                return;
            var $to = pm.doc.resolve(to);
            if ($from.sameDepth($to) < itemDepth - 1)
                return null;
            return {
                from: $from.before(itemDepth),
                to: $to.after(itemDepth),
                depth: itemDepth
            };
        }
        _model.ListItem.register("command", "lift", {
            label: "Lift the selected list items to an outer list",
            run: function run(pm) {
                var selected = selectedListItems(pm, this);
                if (!selected || selected.depth < 3)
                    return false;
                var $to = pm.doc.resolve(pm.selection.to);
                if ($to.node(selected.depth - 2).type != this)
                    return false;
                var itemsAfter = selected.to < $to.end(selected.depth - 1);
                var tr = pm.tr.splitIfNeeded(selected.to, 2).splitIfNeeded(selected.from, 2);
                var end = tr.map(selected.to, -1);
                tr.step("ancestor", tr.map(selected.from), end, {depth: 2});
                if (itemsAfter)
                    tr.join(end - 2);
                return tr.apply(pm.apply.scroll);
            },
            keys: ["Mod-[(20)"]
        });
        _model.ListItem.register("command", "sink", {
            label: "Sink the selected list items into an inner list",
            run: function run(pm) {
                var selected = selectedListItems(pm, this);
                if (!selected)
                    return false;
                var $from = pm.doc.resolve(pm.selection.from),
                    startIndex = $from.index(selected.depth - 1);
                if (startIndex == 0)
                    return false;
                var parent = $from.node(selected.depth - 1),
                    before = parent.child(startIndex - 1);
                var tr = pm.tr.wrap(selected.from, selected.to, parent.type, parent.attrs);
                if (before.type == this)
                    tr.join(selected.from, before.lastChild && before.lastChild.type == parent.type ? 2 : 1);
                return tr.apply(pm.apply.scroll);
            },
            keys: ["Mod-](20)"]
        });
        var _loop = function _loop(i) {
            _model.Heading.registerComputed("command", "make" + i, function(type) {
                var attrs = {level: String(i)};
                if (i <= type.maxLevel)
                    return {
                        derive: {
                            name: "make",
                            attrs: attrs
                        },
                        label: "Change to heading " + i,
                        keys: i <= 6 && ["Shift-Ctrl-" + i],
                        menu: {
                            group: "textblockHeading",
                            rank: 30 + i,
                            display: {
                                type: "label",
                                label: "Level " + i
                            },
                            activeDisplay: "Head " + i
                        }
                    };
            });
        };
        for (var i = 1; i <= 10; i++) {
            _loop(i);
        }
        _model.Paragraph.register("command", "make", {
            derive: true,
            label: "Change to paragraph",
            keys: ["Shift-Ctrl-0"],
            menu: {
                group: "textblock",
                rank: 10,
                display: {
                    type: "label",
                    label: "Plain"
                },
                activeDisplay: "Plain"
            }
        });
        _model.CodeBlock.register("command", "make", {
            derive: true,
            label: "Change to code block",
            keys: ["Shift-Ctrl-\\"],
            menu: {
                group: "textblock",
                rank: 20,
                display: {
                    type: "label",
                    label: "Code"
                },
                activeDisplay: "Code"
            }
        });
        _model.HorizontalRule.register("command", "insert", {
            derive: true,
            label: "Insert horizontal rule",
            keys: ["Mod-Shift--"],
            menu: {
                group: "insert",
                rank: 70,
                display: {
                    type: "label",
                    label: "Horizontal rule"
                }
            }
        });
        return module.exports;
    });

    $__System.registerDynamic("3e", [], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        "format cjs";
        (function(mod) {
            if (typeof exports == "object" && typeof module == "object")
                module.exports = mod();
            else if (typeof define == "function" && define.amd)
                return define([], mod);
            else
                (this || window).browserKeymap = mod();
        })(function() {
            "use strict";
            var mac = typeof navigator != "undefined" ? /Mac/.test(navigator.platform) : typeof os != "undefined" ? os.platform() == "darwin" : false;
            var keyNames = {
                3: "Enter",
                8: "Backspace",
                9: "Tab",
                13: "Enter",
                16: "Shift",
                17: "Ctrl",
                18: "Alt",
                19: "Pause",
                20: "CapsLock",
                27: "Esc",
                32: "Space",
                33: "PageUp",
                34: "PageDown",
                35: "End",
                36: "Home",
                37: "Left",
                38: "Up",
                39: "Right",
                40: "Down",
                44: "PrintScrn",
                45: "Insert",
                46: "Delete",
                59: ";",
                61: "=",
                91: "Mod",
                92: "Mod",
                93: "Mod",
                106: "*",
                107: "=",
                109: "-",
                110: ".",
                111: "/",
                127: "Delete",
                173: "-",
                186: ";",
                187: "=",
                188: ",",
                189: "-",
                190: ".",
                191: "/",
                192: "`",
                219: "[",
                220: "\\",
                221: "]",
                222: "'",
                63232: "Up",
                63233: "Down",
                63234: "Left",
                63235: "Right",
                63272: "Delete",
                63273: "Home",
                63275: "End",
                63276: "PageUp",
                63277: "PageDown",
                63302: "Insert"
            };
            for (var i = 0; i < 10; i++)
                keyNames[i + 48] = keyNames[i + 96] = String(i);
            for (var i = 65; i <= 90; i++)
                keyNames[i] = String.fromCharCode(i);
            for (var i = 1; i <= 12; i++)
                keyNames[i + 111] = keyNames[i + 63235] = "F" + i;
            function keyName(event) {
                if (event.type == "keypress")
                    return "'" + String.fromCharCode(event.charCode) + "'";
                var base = keyNames[event.keyCode],
                    name = base;
                if (name == null || event.altGraphKey)
                    return null;
                if (event.altKey && base != "Alt")
                    name = "Alt-" + name;
                if (event.ctrlKey && base != "Ctrl")
                    name = "Ctrl-" + name;
                if (event.metaKey && base != "Cmd")
                    name = "Cmd-" + name;
                if (event.shiftKey && base != "Shift")
                    name = "Shift-" + name;
                return name;
            }
            function isModifierKey(name) {
                name = /[^-]*$/.exec(name)[0];
                return name == "Ctrl" || name == "Alt" || name == "Shift" || name == "Mod";
            }
            function normalizeKeyName(name) {
                var parts = name.split(/-(?!'?$)/),
                    result = parts[parts.length - 1];
                var alt,
                    ctrl,
                    shift,
                    cmd;
                for (var i = 0; i < parts.length - 1; i++) {
                    var mod = parts[i];
                    if (/^(cmd|meta|m)$/i.test(mod))
                        cmd = true;
                    else if (/^a(lt)?$/i.test(mod))
                        alt = true;
                    else if (/^(c|ctrl|control)$/i.test(mod))
                        ctrl = true;
                    else if (/^s(hift)$/i.test(mod))
                        shift = true;
                    else if (/^mod$/i.test(mod)) {
                        if (mac)
                            cmd = true;
                        else
                            ctrl = true;
                    } else
                        throw new Error("Unrecognized modifier name: " + mod);
                }
                if (alt)
                    result = "Alt-" + result;
                if (ctrl)
                    result = "Ctrl-" + result;
                if (cmd)
                    result = "Cmd-" + result;
                if (shift)
                    result = "Shift-" + result;
                return result;
            }
            function Keymap(keys, options) {
                this.options = options || {};
                this.bindings = Object.create(null);
                if (keys)
                    for (var keyname in keys)
                        if (Object.prototype.hasOwnProperty.call(keys, keyname))
                            this.addBinding(keyname, keys[keyname]);
            }
            Keymap.prototype = {
                normalize: function(name) {
                    return this.options.multi !== false ? name.split(/ +(?!\'$)/).map(normalizeKeyName) : [normalizeKeyName(name)];
                },
                addBinding: function(keyname, value) {
                    var keys = this.normalize(keyname);
                    for (var i = 0; i < keys.length; i++) {
                        var name = keys.slice(0, i + 1).join(" ");
                        var val = i == keys.length - 1 ? value : "...";
                        var prev = this.bindings[name];
                        if (!prev)
                            this.bindings[name] = val;
                        else if (prev != val)
                            throw new Error("Inconsistent bindings for " + name);
                    }
                },
                removeBinding: function(keyname) {
                    var keys = this.normalize(keyname);
                    for (var i = keys.length - 1; i >= 0; i--) {
                        var name = keys.slice(0, i).join(" ");
                        var val = this.bindings[name];
                        if (val == "..." && !this.unusedMulti(name))
                            break;
                        else if (val)
                            delete this.bindings[name];
                    }
                },
                unusedMulti: function(name) {
                    for (var binding in this.bindings)
                        if (binding.length > name && binding.indexOf(name) == 0 && binding.charAt(name.length) == " ")
                            return false;
                    return true;
                },
                lookup: function(key, context) {
                    return this.options.call ? this.options.call(key, context) : this.bindings[key];
                },
                constructor: Keymap
            };
            Keymap.keyName = keyName;
            Keymap.isModifierKey = isModifierKey;
            Keymap.normalizeKeyName = normalizeKeyName;
            return Keymap;
        });
        return module.exports;
    });

    $__System.registerDynamic("14", ["3e"], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        module.exports = $__require('3e');
        return module.exports;
    });

    $__System.registerDynamic("3", ["10", "1d", "13", "1e", "20", "2e", "3d", "14"], true, function($__require, exports, module) {
        "use strict";
        ;
        var define,
            global = this,
            GLOBAL = this;
        Object.defineProperty(exports, "__esModule", {value: true});
        exports.Keymap = exports.baseCommands = exports.Command = exports.CommandSet = exports.MarkedRange = exports.NodeSelection = exports.TextSelection = exports.Selection = exports.defineOption = exports.ProseMirror = undefined;
        var _main = $__require('10');
        Object.defineProperty(exports, "ProseMirror", {
            enumerable: true,
            get: function get() {
                return _main.ProseMirror;
            }
        });
        var _options = $__require('1d');
        Object.defineProperty(exports, "defineOption", {
            enumerable: true,
            get: function get() {
                return _options.defineOption;
            }
        });
        var _selection = $__require('13');
        Object.defineProperty(exports, "Selection", {
            enumerable: true,
            get: function get() {
                return _selection.Selection;
            }
        });
        Object.defineProperty(exports, "TextSelection", {
            enumerable: true,
            get: function get() {
                return _selection.TextSelection;
            }
        });
        Object.defineProperty(exports, "NodeSelection", {
            enumerable: true,
            get: function get() {
                return _selection.NodeSelection;
            }
        });
        var _range = $__require('1e');
        Object.defineProperty(exports, "MarkedRange", {
            enumerable: true,
            get: function get() {
                return _range.MarkedRange;
            }
        });
        var _command = $__require('20');
        Object.defineProperty(exports, "CommandSet", {
            enumerable: true,
            get: function get() {
                return _command.CommandSet;
            }
        });
        Object.defineProperty(exports, "Command", {
            enumerable: true,
            get: function get() {
                return _command.Command;
            }
        });
        var _base_commands = $__require('2e');
        Object.defineProperty(exports, "baseCommands", {
            enumerable: true,
            get: function get() {
                return _base_commands.baseCommands;
            }
        });
        $__require('3d');
        var _browserkeymap = $__require('14');
        var _browserkeymap2 = _interopRequireDefault(_browserkeymap);
        function _interopRequireDefault(obj) {
            return obj && obj.__esModule ? obj : {default: obj};
        }
        exports.Keymap = _browserkeymap2.default;
        return module.exports;
    });

    $__System.registerDynamic("a", [], true, function($__require, exports, module) {
        "use strict";
        ;
        var define,
            global = this,
            GLOBAL = this;
        Object.defineProperty(exports, "__esModule", {value: true});
        var _createClass = function() {
            function defineProperties(target, props) {
                for (var i = 0; i < props.length; i++) {
                    var descriptor = props[i];
                    descriptor.enumerable = descriptor.enumerable || false;
                    descriptor.configurable = true;
                    if ("value" in descriptor)
                        descriptor.writable = true;
                    Object.defineProperty(target, descriptor.key, descriptor);
                }
            }
            return function(Constructor, protoProps, staticProps) {
                if (protoProps)
                    defineProperties(Constructor.prototype, protoProps);
                if (staticProps)
                    defineProperties(Constructor, staticProps);
                return Constructor;
            };
        }();
        exports.scheduleDOMUpdate = scheduleDOMUpdate;
        exports.unscheduleDOMUpdate = unscheduleDOMUpdate;
        function _classCallCheck(instance, Constructor) {
            if (!(instance instanceof Constructor)) {
                throw new TypeError("Cannot call a class as a function");
            }
        }
        var UPDATE_TIMEOUT = 50;
        var MIN_FLUSH_DELAY = 100;
        var CentralScheduler = function() {
            function CentralScheduler(pm) {
                var _this = this;
                _classCallCheck(this, CentralScheduler);
                this.waiting = [];
                this.timeout = null;
                this.lastForce = 0;
                this.pm = pm;
                this.timedOut = function() {
                    if (_this.pm.operation)
                        _this.timeout = setTimeout(_this.timedOut, UPDATE_TIMEOUT);
                    else
                        _this.force();
                };
                pm.on("flush", this.onFlush.bind(this));
            }
            _createClass(CentralScheduler, [{
                key: "set",
                value: function set(f) {
                    if (this.waiting.length == 0)
                        this.timeout = setTimeout(this.timedOut, UPDATE_TIMEOUT);
                    if (this.waiting.indexOf(f) == -1)
                        this.waiting.push(f);
                }
            }, {
                key: "unset",
                value: function unset(f) {
                    var index = this.waiting.indexOf(f);
                    if (index > -1)
                        this.waiting.splice(index, 1);
                }
            }, {
                key: "force",
                value: function force() {
                    clearTimeout(this.timeout);
                    this.lastForce = Date.now();
                    while (this.waiting.length) {
                        for (var i = 0; i < this.waiting.length; i++) {
                            var result = this.waiting[i]();
                            if (result)
                                this.waiting[i] = result;
                            else
                                this.waiting.splice(i--, 1);
                        }
                    }
                }
            }, {
                key: "onFlush",
                value: function onFlush() {
                    if (this.waiting.length && Date.now() - this.lastForce > MIN_FLUSH_DELAY)
                        this.force();
                }
            }], [{
                key: "get",
                value: function get(pm) {
                    return pm.mod.centralScheduler || (pm.mod.centralScheduler = new this(pm));
                }
            }]);
            return CentralScheduler;
        }();
        function scheduleDOMUpdate(pm, f) {
            CentralScheduler.get(pm).set(f);
        }
        function unscheduleDOMUpdate(pm, f) {
            CentralScheduler.get(pm).unset(f);
        }
        var UpdateScheduler = exports.UpdateScheduler = function() {
            function UpdateScheduler(pm, events, start) {
                var _this2 = this;
                _classCallCheck(this, UpdateScheduler);
                this.pm = pm;
                this.start = start;
                this.events = events.split(" ");
                this.onEvent = this.onEvent.bind(this);
                this.events.forEach(function(event) {
                    return pm.on(event, _this2.onEvent);
                });
            }
            _createClass(UpdateScheduler, [{
                key: "detach",
                value: function detach() {
                    var _this3 = this;
                    unscheduleDOMUpdate(this.pm, this.start);
                    this.events.forEach(function(event) {
                        return _this3.pm.off(event, _this3.onEvent);
                    });
                }
            }, {
                key: "onEvent",
                value: function onEvent() {
                    scheduleDOMUpdate(this.pm, this.start);
                }
            }, {
                key: "force",
                value: function force() {
                    if (this.pm.operation) {
                        this.onEvent();
                    } else {
                        unscheduleDOMUpdate(this.pm, this.start);
                        for (var run = this.start; run; run = run()) {}
                    }
                }
            }]);
            return UpdateScheduler;
        }();
        return module.exports;
    });

    $__System.registerDynamic("1b", [], true, function($__require, exports, module) {
        "use strict";
        ;
        var define,
            global = this,
            GLOBAL = this;
        Object.defineProperty(exports, "__esModule", {value: true});
        exports.default = sortedInsert;
        function sortedInsert(array, elt, compare) {
            var i = 0;
            for (; i < array.length; i++) {
                if (compare(array[i], elt) > 0)
                    break;
            }
            array.splice(i, 0, elt);
        }
        return module.exports;
    });

    $__System.registerDynamic("2f", [], true, function($__require, exports, module) {
        "use strict";
        ;
        var define,
            global = this,
            GLOBAL = this;
        Object.defineProperty(exports, "__esModule", {value: true});
        exports.copyObj = copyObj;
        function copyObj(obj, base) {
            var copy = base || Object.create(null);
            for (var prop in obj) {
                copy[prop] = obj[prop];
            }
            return copy;
        }
        return module.exports;
    });

    $__System.registerDynamic("8", [], true, function($__require, exports, module) {
        "use strict";
        ;
        var define,
            global = this,
            GLOBAL = this;
        Object.defineProperty(exports, "__esModule", {value: true});
        exports.elt = elt;
        exports.requestAnimationFrame = requestAnimationFrame;
        exports.cancelAnimationFrame = cancelAnimationFrame;
        exports.contains = contains;
        exports.insertCSS = insertCSS;
        exports.ensureCSSAdded = ensureCSSAdded;
        function elt(tag, attrs) {
            var result = document.createElement(tag);
            if (attrs)
                for (var name in attrs) {
                    if (name == "style")
                        result.style.cssText = attrs[name];
                    else if (attrs[name] != null)
                        result.setAttribute(name, attrs[name]);
                }
            for (var _len = arguments.length,
                     args = Array(_len > 2 ? _len - 2 : 0),
                     _key = 2; _key < _len; _key++) {
                args[_key - 2] = arguments[_key];
            }
            for (var i = 0; i < args.length; i++) {
                add(args[i], result);
            }
            return result;
        }
        function add(value, target) {
            if (typeof value == "string")
                value = document.createTextNode(value);
            if (Array.isArray(value)) {
                for (var i = 0; i < value.length; i++) {
                    add(value[i], target);
                }
            } else {
                target.appendChild(value);
            }
        }
        var reqFrame = window.requestAnimationFrame || window.mozRequestAnimationFrame || window.webkitRequestAnimationFrame || window.msRequestAnimationFrame;
        var cancelFrame = window.cancelAnimationFrame || window.mozCancelAnimationFrame || window.webkitCancelAnimationFrame || window.msCancelAnimationFrame;
        function requestAnimationFrame(f) {
            if (reqFrame)
                return reqFrame(f);
            else
                return setTimeout(f, 10);
        }
        function cancelAnimationFrame(handle) {
            if (reqFrame)
                return cancelFrame(handle);
            else
                clearTimeout(handle);
        }
        var ie_upto10 = /MSIE \d/.test(navigator.userAgent);
        var ie_11up = /Trident\/(?:[7-9]|\d{2,})\..*rv:(\d+)/.exec(navigator.userAgent);
        var browser = exports.browser = {
            mac: /Mac/.test(navigator.platform),
            ie_upto10: ie_upto10,
            ie_11up: ie_11up,
            ie: ie_upto10 || ie_11up,
            gecko: /gecko\/\d/i.test(navigator.userAgent),
            ios: /AppleWebKit/.test(navigator.userAgent) && /Mobile\/\w+/.test(navigator.userAgent)
        };
        function contains(parent, child) {
            if (child.nodeType != 1)
                child = child.parentNode;
            return child && parent.contains(child);
        }
        var accumulatedCSS = "",
            cssNode = null;
        function insertCSS(css) {
            if (cssNode)
                cssNode.textContent += css;
            else
                accumulatedCSS += css;
        }
        function ensureCSSAdded() {
            if (!cssNode) {
                cssNode = document.createElement("style");
                cssNode.textContent = "/* ProseMirror CSS */\n" + accumulatedCSS;
                document.head.insertBefore(cssNode, document.head.firstChild);
            }
        }
        return module.exports;
    });

    $__System.registerDynamic("3f", ["8"], true, function($__require, exports, module) {
        "use strict";
        ;
        var define,
            global = this,
            GLOBAL = this;
        Object.defineProperty(exports, "__esModule", {value: true});
        exports.getIcon = getIcon;
        var _dom = $__require('8');
        var svgCollection = null;
        var svgBuilt = Object.create(null);
        var SVG = "http://www.w3.org/2000/svg";
        var XLINK = "http://www.w3.org/1999/xlink";
        var prefix = "ProseMirror-icon";
        function getIcon(name, data) {
            var node = document.createElement("div");
            node.className = prefix;
            if (data.path) {
                if (!svgBuilt[name])
                    buildSVG(name, data);
                var svg = node.appendChild(document.createElementNS(SVG, "svg"));
                svg.style.width = data.width / data.height + "em";
                var use = svg.appendChild(document.createElementNS(SVG, "use"));
                use.setAttributeNS(XLINK, "href", /([^#]*)/.exec(document.location)[1] + "#pm-icon-" + name);
            } else if (data.dom) {
                node.appendChild(data.dom.cloneNode(true));
            } else {
                node.appendChild(document.createElement("span")).textContent = data.text || '';
                if (data.style)
                    node.firstChild.style.cssText = data.style;
            }
            return node;
        }
        function buildSVG(name, data) {
            if (!svgCollection) {
                svgCollection = document.createElementNS(SVG, "svg");
                svgCollection.style.display = "none";
                document.body.insertBefore(svgCollection, document.body.firstChild);
            }
            var sym = document.createElementNS(SVG, "symbol");
            sym.id = "pm-icon-" + name;
            sym.setAttribute("viewBox", "0 0 " + data.width + " " + data.height);
            var path = sym.appendChild(document.createElementNS(SVG, "path"));
            path.setAttribute("d", data.path);
            svgCollection.appendChild(sym);
            svgBuilt[name] = true;
        }
        (0, _dom.insertCSS)("\n." + prefix + " {\n  display: inline-block;\n  line-height: .8;\n  vertical-align: -2px; /* Compensate for padding */\n  padding: 2px 8px;\n  cursor: pointer;\n}\n\n." + prefix + " svg {\n  fill: currentColor;\n  height: 1em;\n}\n\n." + prefix + " span {\n  vertical-align: text-top;\n}");
        return module.exports;
    });

    $__System.registerDynamic("b", ["8", "1b", "2f", "3f"], true, function($__require, exports, module) {
        "use strict";
        ;
        var define,
            global = this,
            GLOBAL = this;
        Object.defineProperty(exports, "__esModule", {value: true});
        exports.historyGroup = exports.blockGroup = exports.textblockMenu = exports.insertMenu = exports.inlineGroup = exports.DropdownSubmenu = exports.Dropdown = exports.MenuCommandGroup = exports.MenuCommand = undefined;
        var _createClass = function() {
            function defineProperties(target, props) {
                for (var i = 0; i < props.length; i++) {
                    var descriptor = props[i];
                    descriptor.enumerable = descriptor.enumerable || false;
                    descriptor.configurable = true;
                    if ("value" in descriptor)
                        descriptor.writable = true;
                    Object.defineProperty(target, descriptor.key, descriptor);
                }
            }
            return function(Constructor, protoProps, staticProps) {
                if (protoProps)
                    defineProperties(Constructor.prototype, protoProps);
                if (staticProps)
                    defineProperties(Constructor, staticProps);
                return Constructor;
            };
        }();
        exports.resolveGroup = resolveGroup;
        exports.renderGrouped = renderGrouped;
        var _dom = $__require('8');
        var _sortedinsert = $__require('1b');
        var _sortedinsert2 = _interopRequireDefault(_sortedinsert);
        var _obj = $__require('2f');
        var _icons = $__require('3f');
        function _interopRequireDefault(obj) {
            return obj && obj.__esModule ? obj : {default: obj};
        }
        function _classCallCheck(instance, Constructor) {
            if (!(instance instanceof Constructor)) {
                throw new TypeError("Cannot call a class as a function");
            }
        }
        var prefix = "ProseMirror-menu";
        function title(pm, command) {
            if (!command.label)
                return null;
            var label = pm.translate(command.label);
            var key = command.name && pm.keyForCommand(command.name);
            return key ? label + " (" + key + ")" : label;
        }
        var MenuCommand = exports.MenuCommand = function() {
            function MenuCommand(command, options) {
                _classCallCheck(this, MenuCommand);
                this.command_ = command;
                this.options = options;
            }
            _createClass(MenuCommand, [{
                key: "command",
                value: function command(pm) {
                    return typeof this.command_ == "string" ? pm.commands[this.command_] : this.command_;
                }
            }, {
                key: "render",
                value: function render(pm) {
                    var cmd = this.command(pm),
                        disabled = false;
                    if (!cmd)
                        return;
                    if (this.options.select != "ignore" && !cmd.select(pm)) {
                        if (this.options.select == null || this.options.select == "hide")
                            return null;
                        else if (this.options.select == "disable")
                            disabled = true;
                    }
                    var disp = this.options.display;
                    if (!disp)
                        throw new RangeError("No display style defined for menu command " + cmd.name);
                    var dom = undefined;
                    if (disp.render) {
                        dom = disp.render(cmd, pm);
                    } else if (disp.type == "icon") {
                        dom = (0, _icons.getIcon)(cmd.name, disp);
                        if (!disabled && cmd.active(pm))
                            dom.classList.add(prefix + "-active");
                    } else if (disp.type == "label") {
                        var label = pm.translate(disp.label || cmd.spec.label);
                        dom = (0, _dom.elt)("div", null, label);
                    } else {
                        throw new RangeError("Unsupported command display style: " + disp.type);
                    }
                    dom.setAttribute("title", title(pm, cmd));
                    if (this.options.class)
                        dom.classList.add(this.options.class);
                    if (disabled)
                        dom.classList.add(prefix + "-disabled");
                    if (this.options.css)
                        dom.style.cssText += this.options.css;
                    dom.addEventListener("mousedown", function(e) {
                        e.preventDefault();
                        e.stopPropagation();
                        pm.signal("interaction");
                        cmd.exec(pm, null, dom);
                    });
                    dom.setAttribute("data-command", this.commandName);
                    return dom;
                }
            }, {
                key: "commandName",
                get: function get() {
                    return typeof this.command_ === "string" ? this.command_.command : this.command_.name;
                }
            }]);
            return MenuCommand;
        }();
        var MenuCommandGroup = exports.MenuCommandGroup = function() {
            function MenuCommandGroup(name, options) {
                _classCallCheck(this, MenuCommandGroup);
                this.name = name;
                this.options = options;
            }
            _createClass(MenuCommandGroup, [{
                key: "collect",
                value: function collect(pm) {
                    var _this = this;
                    var result = [];
                    for (var name in pm.commands) {
                        var cmd = pm.commands[name],
                            spec = cmd.spec.menu;
                        if (spec && spec.group == this.name)
                            (0, _sortedinsert2.default)(result, {
                                cmd: cmd,
                                rank: spec.rank == null ? 50 : spec.rank
                            }, function(a, b) {
                                return a.rank - b.rank;
                            });
                    }
                    return result.map(function(o) {
                        var spec = o.cmd.spec.menu;
                        if (_this.options)
                            spec = (0, _obj.copyObj)(_this.options, (0, _obj.copyObj)(spec));
                        return new MenuCommand(o.cmd, spec);
                    });
                }
            }, {
                key: "get",
                value: function get(pm) {
                    var groups = pm.mod.menuGroups || this.startGroups(pm);
                    return groups[this.name] || (groups[this.name] = this.collect(pm));
                }
            }, {
                key: "startGroups",
                value: function startGroups(pm) {
                    var clear = function clear() {
                        pm.mod.menuGroups = null;
                        pm.off("commandsChanging", clear);
                    };
                    pm.on("commandsChanging", clear);
                    return pm.mod.menuGroups = Object.create(null);
                }
            }]);
            return MenuCommandGroup;
        }();
        var Dropdown = exports.Dropdown = function() {
            function Dropdown(options, content) {
                _classCallCheck(this, Dropdown);
                this.options = options || {};
                this.content = content;
            }
            _createClass(Dropdown, [{
                key: "render",
                value: function render(pm) {
                    var _this2 = this;
                    var items = renderDropdownItems(resolveGroup(pm, this.content), pm);
                    if (!items.length)
                        return;
                    var label = this.options.activeLabel && this.findActiveIn(this, pm) || this.options.label;
                    label = pm.translate(label);
                    var dom = (0, _dom.elt)("div", {
                        class: prefix + "-dropdown " + (this.options.class || ""),
                        style: this.options.css,
                        title: this.options.title
                    }, label);
                    var open = null;
                    dom.addEventListener("mousedown", function(e) {
                        e.preventDefault();
                        e.stopPropagation();
                        if (open && open())
                            open = null;
                        else
                            open = _this2.expand(pm, dom, items);
                    });
                    return dom;
                }
            }, {
                key: "select",
                value: function select(pm) {
                    return resolveGroup(pm, this.content).some(function(e) {
                        return e.select(pm);
                    });
                }
            }, {
                key: "expand",
                value: function expand(pm, dom, items) {
                    var box = dom.getBoundingClientRect(),
                        outer = pm.wrapper.getBoundingClientRect();
                    var menuDOM = (0, _dom.elt)("div", {
                        class: prefix + "-dropdown-menu " + (this.options.class || ""),
                        style: "left: " + (box.left - outer.left) + "px; top: " + (box.bottom - outer.top) + "px"
                    }, items);
                    var done = false;
                    function finish() {
                        if (done)
                            return;
                        done = true;
                        pm.off("interaction", finish);
                        pm.wrapper.removeChild(menuDOM);
                        return true;
                    }
                    pm.signal("interaction");
                    pm.wrapper.appendChild(menuDOM);
                    pm.on("interaction", finish);
                    return finish;
                }
            }, {
                key: "findActiveIn",
                value: function findActiveIn(element, pm) {
                    var items = resolveGroup(pm, element.content);
                    for (var i = 0; i < items.length; i++) {
                        var cur = items[i];
                        if (cur instanceof MenuCommand) {
                            var active = cur.command(pm).active(pm);
                            if (active)
                                return cur.options.activeLabel;
                        } else if (cur instanceof DropdownSubmenu) {
                            var found = this.findActiveIn(cur, pm);
                            if (found)
                                return found;
                        }
                    }
                }
            }]);
            return Dropdown;
        }();
        function renderDropdownItems(items, pm) {
            var rendered = [];
            for (var i = 0; i < items.length; i++) {
                var inner = items[i].render(pm);
                if (inner)
                    rendered.push((0, _dom.elt)("div", {class: prefix + "-dropdown-item"}, inner));
            }
            return rendered;
        }
        var DropdownSubmenu = exports.DropdownSubmenu = function() {
            function DropdownSubmenu(options, content) {
                _classCallCheck(this, DropdownSubmenu);
                this.options = options || {};
                this.content = content;
            }
            _createClass(DropdownSubmenu, [{
                key: "render",
                value: function render(pm) {
                    var items = renderDropdownItems(resolveGroup(pm, this.content), pm);
                    if (!items.length)
                        return;
                    var label = (0, _dom.elt)("div", {class: prefix + "-submenu-label"}, pm.translate(this.options.label));
                    var wrap = (0, _dom.elt)("div", {class: prefix + "-submenu-wrap"}, label, (0, _dom.elt)("div", {class: prefix + "-submenu"}, items));
                    label.addEventListener("mousedown", function(e) {
                        e.preventDefault();
                        e.stopPropagation();
                        wrap.classList.toggle(prefix + "-submenu-wrap-active");
                    });
                    return wrap;
                }
            }]);
            return DropdownSubmenu;
        }();
        function resolveGroup(pm, content) {
            var result = undefined,
                isArray = Array.isArray(content);
            for (var i = 0; i < (isArray ? content.length : 1); i++) {
                var cur = isArray ? content[i] : content;
                if (cur instanceof MenuCommandGroup) {
                    var elts = cur.get(pm);
                    if (!isArray || content.length == 1)
                        return elts;
                    else
                        result = (result || content.slice(0, i)).concat(elts);
                } else if (result) {
                    result.push(cur);
                }
            }
            return result || (isArray ? content : [content]);
        }
        function renderGrouped(pm, content) {
            var result = document.createDocumentFragment(),
                needSep = false;
            for (var i = 0; i < content.length; i++) {
                var items = resolveGroup(pm, content[i]),
                    added = false;
                for (var j = 0; j < items.length; j++) {
                    var rendered = items[j].render(pm);
                    if (rendered) {
                        if (!added && needSep)
                            result.appendChild(separator());
                        result.appendChild((0, _dom.elt)("span", {class: prefix + "item"}, rendered));
                        added = true;
                    }
                }
                if (added)
                    needSep = true;
            }
            return result;
        }
        function separator() {
            return (0, _dom.elt)("span", {class: prefix + "separator"});
        }
        var inlineGroup = exports.inlineGroup = new MenuCommandGroup("inline");
        var insertMenu = exports.insertMenu = new Dropdown({label: "Insert"}, new MenuCommandGroup("insert"));
        var textblockMenu = exports.textblockMenu = new Dropdown({
            label: "Type..",
            displayActive: true,
            class: "ProseMirror-textblock-dropdown"
        }, [new MenuCommandGroup("textblock"), new DropdownSubmenu({label: "Heading"}, new MenuCommandGroup("textblockHeading"))]);
        var blockGroup = exports.blockGroup = new MenuCommandGroup("block");
        var historyGroup = exports.historyGroup = new MenuCommandGroup("history");
        (0, _dom.insertCSS)("\n\n.ProseMirror-textblock-dropdown {\n  min-width: 3em;\n}\n\n." + prefix + " {\n  margin: 0 -4px;\n  line-height: 1;\n}\n\n.ProseMirror-tooltip ." + prefix + " {\n  width: -webkit-fit-content;\n  width: fit-content;\n  white-space: pre;\n}\n\n." + prefix + "item {\n  margin-right: 3px;\n  display: inline-block;\n}\n\n." + prefix + "separator {\n  border-right: 1px solid #ddd;\n  margin-right: 3px;\n}\n\n." + prefix + "-dropdown, ." + prefix + "-dropdown-menu {\n  font-size: 90%;\n  white-space: nowrap;\n}\n\n." + prefix + "-dropdown {\n  padding: 1px 14px 1px 4px;\n  display: inline-block;\n  vertical-align: 1px;\n  position: relative;\n  cursor: pointer;\n}\n\n." + prefix + "-dropdown:after {\n  content: \"\";\n  border-left: 4px solid transparent;\n  border-right: 4px solid transparent;\n  border-top: 4px solid currentColor;\n  opacity: .6;\n  position: absolute;\n  right: 2px;\n  top: calc(50% - 2px);\n}\n\n." + prefix + "-dropdown-menu, ." + prefix + "-submenu {\n  position: absolute;\n  background: white;\n  color: #666;\n  border: 1px solid #aaa;\n  padding: 2px;\n}\n\n." + prefix + "-dropdown-menu {\n  z-index: 15;\n  min-width: 6em;\n}\n\n." + prefix + "-dropdown-item {\n  cursor: pointer;\n  padding: 2px 8px 2px 4px;\n}\n\n." + prefix + "-dropdown-item:hover {\n  background: #f2f2f2;\n}\n\n." + prefix + "-submenu-wrap {\n  position: relative;\n  margin-right: -4px;\n}\n\n." + prefix + "-submenu-label:after {\n  content: \"\";\n  border-top: 4px solid transparent;\n  border-bottom: 4px solid transparent;\n  border-left: 4px solid currentColor;\n  opacity: .6;\n  position: absolute;\n  right: 4px;\n  top: calc(50% - 4px);\n}\n\n." + prefix + "-submenu {\n  display: none;\n  min-width: 4em;\n  left: 100%;\n  top: -3px;\n}\n\n." + prefix + "-active {\n  background: #eee;\n  border-radius: 4px;\n}\n\n." + prefix + "-active {\n  background: #eee;\n  border-radius: 4px;\n}\n\n." + prefix + "-disabled {\n  opacity: .3;\n}\n\n." + prefix + "-submenu-wrap:hover ." + prefix + "-submenu, ." + prefix + "-submenu-wrap-active ." + prefix + "-submenu {\n  display: block;\n}\n");
        return module.exports;
    });

    $__System.registerDynamic("40", ["3", "8", "a", "b"], true, function($__require, exports, module) {
        "use strict";
        ;
        var define,
            global = this,
            GLOBAL = this;
        var _typeof = typeof Symbol === "function" && typeof Symbol.iterator === "symbol" ? function(obj) {
            return typeof obj;
        } : function(obj) {
            return obj && typeof Symbol === "function" && obj.constructor === Symbol ? "symbol" : typeof obj;
        };
        var _createClass = function() {
            function defineProperties(target, props) {
                for (var i = 0; i < props.length; i++) {
                    var descriptor = props[i];
                    descriptor.enumerable = descriptor.enumerable || false;
                    descriptor.configurable = true;
                    if ("value" in descriptor)
                        descriptor.writable = true;
                    Object.defineProperty(target, descriptor.key, descriptor);
                }
            }
            return function(Constructor, protoProps, staticProps) {
                if (protoProps)
                    defineProperties(Constructor.prototype, protoProps);
                if (staticProps)
                    defineProperties(Constructor, staticProps);
                return Constructor;
            };
        }();
        var _edit = $__require('3');
        var _dom = $__require('8');
        var _update = $__require('a');
        var _menu = $__require('b');
        function _classCallCheck(instance, Constructor) {
            if (!(instance instanceof Constructor)) {
                throw new TypeError("Cannot call a class as a function");
            }
        }
        var prefix = "ProseMirror-menubar";
        (0, _edit.defineOption)("menuBar", false, function(pm, value) {
            if (pm.mod.menuBar)
                pm.mod.menuBar.detach();
            pm.mod.menuBar = value ? new MenuBar(pm, value) : null;
        });
        var defaultMenu = [_menu.inlineGroup, _menu.insertMenu, [_menu.textblockMenu, _menu.blockGroup], _menu.historyGroup];
        var MenuBar = function() {
            function MenuBar(pm, config) {
                var _this = this;
                _classCallCheck(this, MenuBar);
                this.pm = pm;
                this.config = config || {};
                this.wrapper = pm.wrapper.insertBefore((0, _dom.elt)("div", {class: prefix}), pm.wrapper.firstChild);
                this.spacer = null;
                this.maxHeight = 0;
                this.widthForMaxHeight = 0;
                this.updater = new _update.UpdateScheduler(pm, "selectionChange change activeMarkChange commandsChanged", function() {
                    return _this.update();
                });
                this.content = config.content || defaultMenu;
                this.updater.force();
                this.floating = false;
                if (this.config.float) {
                    this.updateFloat();
                    this.scrollFunc = function() {
                        if (!document.body.contains(_this.pm.wrapper))
                            window.removeEventListener("scroll", _this.scrollFunc);
                        else
                            _this.updateFloat();
                    };
                    window.addEventListener("scroll", this.scrollFunc);
                }
            }
            _createClass(MenuBar, [{
                key: "detach",
                value: function detach() {
                    this.updater.detach();
                    this.wrapper.parentNode.removeChild(this.wrapper);
                    if (this.scrollFunc)
                        window.removeEventListener("scroll", this.scrollFunc);
                }
            }, {
                key: "update",
                value: function update() {
                    var _this2 = this;
                    this.wrapper.textContent = "";
                    this.wrapper.appendChild((0, _menu.renderGrouped)(this.pm, this.content));
                    return this.floating ? this.updateScrollCursor() : function() {
                        if (_this2.wrapper.offsetWidth != _this2.widthForMaxHeight) {
                            _this2.widthForMaxHeight = _this2.wrapper.offsetWidth;
                            _this2.maxHeight = 0;
                        }
                        if (_this2.wrapper.offsetHeight > _this2.maxHeight) {
                            _this2.maxHeight = _this2.wrapper.offsetHeight;
                            return function() {
                                _this2.wrapper.style.minHeight = _this2.maxHeight + "px";
                            };
                        }
                    };
                }
            }, {
                key: "updateFloat",
                value: function updateFloat() {
                    var editorRect = this.pm.wrapper.getBoundingClientRect();
                    if (this.floating) {
                        if (editorRect.top >= 0 || editorRect.bottom < this.wrapper.offsetHeight + 10) {
                            this.floating = false;
                            this.wrapper.style.position = this.wrapper.style.left = this.wrapper.style.width = "";
                            this.wrapper.style.display = "";
                            this.spacer.parentNode.removeChild(this.spacer);
                            this.spacer = null;
                        } else {
                            var border = (this.pm.wrapper.offsetWidth - this.pm.wrapper.clientWidth) / 2;
                            this.wrapper.style.left = editorRect.left + border + "px";
                            this.wrapper.style.display = editorRect.top > window.innerHeight ? "none" : "";
                        }
                    } else {
                        if (editorRect.top < 0 && editorRect.bottom >= this.wrapper.offsetHeight + 10) {
                            this.floating = true;
                            var menuRect = this.wrapper.getBoundingClientRect();
                            this.wrapper.style.left = menuRect.left + "px";
                            this.wrapper.style.width = menuRect.width + "px";
                            this.wrapper.style.position = "fixed";
                            this.spacer = (0, _dom.elt)("div", {
                                class: prefix + "-spacer",
                                style: "height: " + menuRect.height + "px"
                            });
                            this.pm.wrapper.insertBefore(this.spacer, this.wrapper);
                        }
                    }
                }
            }, {
                key: "updateScrollCursor",
                value: function updateScrollCursor() {
                    var _this3 = this;
                    if (!this.floating)
                        return null;
                    var head = this.pm.selection.head;
                    if (!head)
                        return null;
                    return function() {
                        var cursorPos = _this3.pm.coordsAtPos(head);
                        var menuRect = _this3.wrapper.getBoundingClientRect();
                        if (cursorPos.top < menuRect.bottom && cursorPos.bottom > menuRect.top) {
                            var _ret = function() {
                                var scrollable = findWrappingScrollable(_this3.pm.wrapper);
                                if (scrollable)
                                    return {v: function v() {
                                        scrollable.scrollTop -= menuRect.bottom - cursorPos.top;
                                    }};
                            }();
                            if ((typeof _ret === "undefined" ? "undefined" : _typeof(_ret)) === "object")
                                return _ret.v;
                        }
                    };
                }
            }]);
            return MenuBar;
        }();
        function findWrappingScrollable(node) {
            for (var cur = node.parentNode; cur; cur = cur.parentNode) {
                if (cur.scrollHeight > cur.clientHeight)
                    return cur;
            }
        }
        (0, _dom.insertCSS)("\n." + prefix + " {\n  border-top-left-radius: inherit;\n  border-top-right-radius: inherit;\n  position: relative;\n  min-height: 1em;\n  color: #666;\n  padding: 1px 6px;\n  top: 0; left: 0; right: 0;\n  border-bottom: 1px solid silver;\n  background: white;\n  z-index: 10;\n  -moz-box-sizing: border-box;\n  box-sizing: border-box;\n  overflow: visible;\n}\n");
        return module.exports;
    });

    $__System.registerDynamic("1", ["2", "5", "9", "40"], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        var pm = $__require('2');
        $__require('5');
        $__require('9');
        $__require('40');
        var proseMirrorMap = {};
        getProseMirror = function(id) {
            return proseMirrorMap[id];
        };
        createProseMirror = function(id, opts) {
            var place = document.getElementById(id);
            $.extend(opts, {
                place: place,
                doc: $(place).children('.card-content').val(),
                docFormat: "html"
            });
            proseMirrorMap[id] = new pm.ProseMirror(opts);
        };
        return module.exports;
    });

})
(function(factory) {
    factory();
});
