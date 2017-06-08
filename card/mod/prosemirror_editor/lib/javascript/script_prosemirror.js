!function(e){function r(e,r,o){return 4===arguments.length?t.apply(this,arguments):void n(e,{declarative:!0,deps:r,declare:o})}function t(e,r,t,o){n(e,{declarative:!1,deps:r,executingRequire:t,execute:o})}function n(e,r){r.name=e,e in g||(g[e]=r),r.normalizedDeps=r.deps}function o(e,r){if(r[e.groupIndex]=r[e.groupIndex]||[],-1==m.call(r[e.groupIndex],e)){r[e.groupIndex].push(e);for(var t=0,n=e.normalizedDeps.length;n>t;t++){var a=e.normalizedDeps[t],u=g[a];if(u&&!u.evaluated){var d=e.groupIndex+(u.declarative!=e.declarative);if(void 0===u.groupIndex||u.groupIndex<d){if(void 0!==u.groupIndex&&(r[u.groupIndex].splice(m.call(r[u.groupIndex],u),1),0==r[u.groupIndex].length))throw new TypeError("Mixed dependency cycle detected");u.groupIndex=d}o(u,r)}}}}function a(e){var r=g[e];r.groupIndex=0;var t=[];o(r,t);for(var n=!!r.declarative==t.length%2,a=t.length-1;a>=0;a--){for(var u=t[a],i=0;i<u.length;i++){var s=u[i];n?d(s):l(s)}n=!n}}function u(e){return D[e]||(D[e]={name:e,dependencies:[],exports:{},importers:[]})}function d(r){if(!r.module){var t=r.module=u(r.name),n=r.module.exports,o=r.declare.call(e,function(e,r){if(t.locked=!0,"object"==typeof e)for(var o in e)n[o]=e[o];else n[e]=r;for(var a=0,u=t.importers.length;u>a;a++){var d=t.importers[a];if(!d.locked)for(var i=0;i<d.dependencies.length;++i)d.dependencies[i]===t&&d.setters[i](n)}return t.locked=!1,r},r.name);t.setters=o.setters,t.execute=o.execute;for(var a=0,i=r.normalizedDeps.length;i>a;a++){var l,s=r.normalizedDeps[a],c=g[s],f=D[s];f?l=f.exports:c&&!c.declarative?l=c.esModule:c?(d(c),f=c.module,l=f.exports):l=v(s),f&&f.importers?(f.importers.push(t),t.dependencies.push(f)):t.dependencies.push(null),t.setters[a]&&t.setters[a](l)}}}function i(e){var r,t=g[e];if(t)t.declarative?p(e,[]):t.evaluated||l(t),r=t.module.exports;else if(r=v(e),!r)throw new Error("Unable to load dependency "+e+".");return(!t||t.declarative)&&r&&r.__useDefault?r["default"]:r}function l(r){if(!r.module){var t={},n=r.module={exports:t,id:r.name};if(!r.executingRequire)for(var o=0,a=r.normalizedDeps.length;a>o;o++){var u=r.normalizedDeps[o],d=g[u];d&&l(d)}r.evaluated=!0;var c=r.execute.call(e,function(e){for(var t=0,n=r.deps.length;n>t;t++)if(r.deps[t]==e)return i(r.normalizedDeps[t]);throw new TypeError("Module "+e+" not declared as a dependency.")},t,n);c&&(n.exports=c),t=n.exports,t&&t.__esModule?r.esModule=t:r.esModule=s(t)}}function s(e){var r={};if("object"==typeof e||"function"==typeof e){var t=e&&e.hasOwnProperty;if(h)for(var n in e)f(r,e,n)||c(r,e,n,t);else for(var n in e)c(r,e,n,t)}return r["default"]=e,y(r,"__useDefault",{value:!0}),r}function c(e,r,t,n){(!n||r.hasOwnProperty(t))&&(e[t]=r[t])}function f(e,r,t){try{var n;return(n=Object.getOwnPropertyDescriptor(r,t))&&y(e,t,n),!0}catch(o){return!1}}function p(r,t){var n=g[r];if(n&&!n.evaluated&&n.declarative){t.push(r);for(var o=0,a=n.normalizedDeps.length;a>o;o++){var u=n.normalizedDeps[o];-1==m.call(t,u)&&(g[u]?p(u,t):v(u))}n.evaluated||(n.evaluated=!0,n.module.execute.call(e))}}function v(e){if(I[e])return I[e];if("@node/"==e.substr(0,6))return _(e.substr(6));var r=g[e];if(!r)throw"Module "+e+" not present.";return a(e),p(e,[]),g[e]=void 0,r.declarative&&y(r.module.exports,"__esModule",{value:!0}),I[e]=r.declarative?r.module.exports:r.esModule}var g={},m=Array.prototype.indexOf||function(e){for(var r=0,t=this.length;t>r;r++)if(this[r]===e)return r;return-1},h=!0;try{Object.getOwnPropertyDescriptor({a:0},"a")}catch(x){h=!1}var y;!function(){try{Object.defineProperty({},"a",{})&&(y=Object.defineProperty)}catch(e){y=function(e,r,t){try{e[r]=t.value||t.get.call(e)}catch(n){}}}}();var D={},_="undefined"!=typeof System&&System._nodeRequire||"undefined"!=typeof require&&require.resolve&&"undefined"!=typeof process&&require,I={"@empty":{}};return function(e,n,o){return function(a){a(function(a){for(var u={_nodeRequire:_,register:r,registerDynamic:t,get:v,set:function(e,r){I[e]=r},newModule:function(e){return e}},d=0;d<n.length;d++)(function(e,r){r&&r.__esModule?I[e]=r:I[e]=s(r)})(n[d],arguments[d]);o(u);var i=v(e[0]);if(e.length>1)for(var d=1;d<e.length;d++)v(e[d]);return i.__useDefault?i["default"]:i})}}}("undefined"!=typeof self?self:global)

(["1"], [], function($__System) {
    var require = this.require, exports = this.exports, module = this.module;
    $__System.registerDynamic("2", ["3"], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        var ref = $__require('3');
        var Schema = ref.Schema;
        var nodes = {
            doc: {content: "block+"},
            paragraph: {
                content: "inline<_>*",
                group: "block",
                parseDOM: [{tag: "p"}],
                toDOM: function toDOM() {
                    return ["p", 0];
                }
            },
            blockquote: {
                content: "block+",
                group: "block",
                defining: true,
                parseDOM: [{tag: "blockquote"}],
                toDOM: function toDOM() {
                    return ["blockquote", 0];
                }
            },
            horizontal_rule: {
                group: "block",
                parseDOM: [{tag: "hr"}],
                toDOM: function toDOM() {
                    return ["hr"];
                }
            },
            heading: {
                attrs: {level: {default: 1}},
                content: "inline<_>*",
                group: "block",
                defining: true,
                parseDOM: [{
                    tag: "h1",
                    attrs: {level: 1}
                }, {
                    tag: "h2",
                    attrs: {level: 2}
                }, {
                    tag: "h3",
                    attrs: {level: 3}
                }, {
                    tag: "h4",
                    attrs: {level: 4}
                }, {
                    tag: "h5",
                    attrs: {level: 5}
                }, {
                    tag: "h6",
                    attrs: {level: 6}
                }],
                toDOM: function toDOM(node) {
                    return ["h" + node.attrs.level, 0];
                }
            },
            code_block: {
                content: "text*",
                group: "block",
                code: true,
                defining: true,
                parseDOM: [{
                    tag: "pre",
                    preserveWhitespace: true
                }],
                toDOM: function toDOM() {
                    return ["pre", ["code", 0]];
                }
            },
            text: {
                group: "inline",
                toDOM: function toDOM(node) {
                    return node.text;
                }
            },
            image: {
                inline: true,
                attrs: {
                    src: {},
                    alt: {default: null},
                    title: {default: null}
                },
                group: "inline",
                draggable: true,
                parseDOM: [{
                    tag: "img[src]",
                    getAttrs: function getAttrs(dom) {
                        return {
                            src: dom.getAttribute("src"),
                            title: dom.getAttribute("title"),
                            alt: dom.getAttribute("alt")
                        };
                    }
                }],
                toDOM: function toDOM(node) {
                    return ["img", node.attrs];
                }
            },
            hard_break: {
                inline: true,
                group: "inline",
                selectable: false,
                parseDOM: [{tag: "br"}],
                toDOM: function toDOM() {
                    return ["br"];
                }
            }
        };
        exports.nodes = nodes;
        var marks = {
            em: {
                parseDOM: [{tag: "i"}, {tag: "em"}, {
                    style: "font-style",
                    getAttrs: function(value) {
                        return value == "italic" && null;
                    }
                }],
                toDOM: function toDOM() {
                    return ["em"];
                }
            },
            strong: {
                parseDOM: [{tag: "strong"}, {
                    tag: "b",
                    getAttrs: function(node) {
                        return node.style.fontWeight != "normal" && null;
                    }
                }, {
                    style: "font-weight",
                    getAttrs: function(value) {
                        return /^(bold(er)?|[5-9]\d{2,})$/.test(value) && null;
                    }
                }],
                toDOM: function toDOM() {
                    return ["strong"];
                }
            },
            link: {
                attrs: {
                    href: {},
                    title: {default: null}
                },
                parseDOM: [{
                    tag: "a[href]",
                    getAttrs: function getAttrs(dom) {
                        return {
                            href: dom.getAttribute("href"),
                            title: dom.getAttribute("title")
                        };
                    }
                }],
                toDOM: function toDOM(node) {
                    return ["a", node.attrs];
                }
            },
            code: {
                parseDOM: [{tag: "code"}],
                toDOM: function toDOM() {
                    return ["code"];
                }
            }
        };
        exports.marks = marks;
        var schema = new Schema({
            nodes: nodes,
            marks: marks
        });
        exports.schema = schema;
        return module.exports;
    });

    $__System.registerDynamic("4", ["2"], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        module.exports = $__require('2');
        return module.exports;
    });

    $__System.registerDynamic("5", ["6"], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        var ref = $__require('6');
        var InputRule = ref.InputRule;
        var emDash = new InputRule(/--$/, "—");
        exports.emDash = emDash;
        var ellipsis = new InputRule(/\.\.\.$/, "…");
        exports.ellipsis = ellipsis;
        var openDoubleQuote = new InputRule(/(?:^|[\s\{\[\(\<'"\u2018\u201C])(")$/, "“");
        exports.openDoubleQuote = openDoubleQuote;
        var closeDoubleQuote = new InputRule(/"$/, "”");
        exports.closeDoubleQuote = closeDoubleQuote;
        var openSingleQuote = new InputRule(/(?:^|[\s\{\[\(\<'"\u2018\u201C])(')$/, "‘");
        exports.openSingleQuote = openSingleQuote;
        var closeSingleQuote = new InputRule(/'$/, "’");
        exports.closeSingleQuote = closeSingleQuote;
        var smartQuotes = [openDoubleQuote, closeDoubleQuote, openSingleQuote, closeSingleQuote];
        exports.smartQuotes = smartQuotes;
        var allInputRules = [emDash, ellipsis].concat(smartQuotes);
        exports.allInputRules = allInputRules;
        return module.exports;
    });

    $__System.registerDynamic("6", ["7"], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        var ref = $__require('7');
        var Plugin = ref.Plugin;
        var PluginKey = ref.PluginKey;
        var InputRule = function InputRule(match, handler) {
            this.match = match;
            this.handler = typeof handler == "string" ? stringHandler(handler) : handler;
        };
        exports.InputRule = InputRule;
        function stringHandler(string) {
            return function(state, match, start, end) {
                var insert = string;
                if (match[1]) {
                    var offset = match[0].lastIndexOf(match[1]);
                    insert += match[0].slice(offset + match[1].length);
                    start += offset;
                    var cutOff = start - end;
                    if (cutOff > 0) {
                        insert = match[0].slice(offset - cutOff, offset) + insert;
                        start = end;
                    }
                }
                var marks = state.doc.resolve(start).marks();
                return state.tr.replaceWith(start, end, state.schema.text(insert, marks));
            };
        }
        var MAX_MATCH = 100;
        var stateKey = new PluginKey("fromInputRule");
        function inputRules(ref) {
            var rules = ref.rules;
            return new Plugin({
                state: {
                    init: function init() {
                        return null;
                    },
                    apply: function apply(tr, prev) {
                        var stored = tr.getMeta(stateKey);
                        if (stored) {
                            return stored;
                        }
                        return tr.selectionSet || tr.docChanged ? null : prev;
                    }
                },
                props: {
                    handleTextInput: function handleTextInput(view, from, to, text) {
                        var state = view.state,
                            $from = state.doc.resolve(from);
                        var textBefore = $from.parent.textBetween(Math.max(0, $from.parentOffset - MAX_MATCH), $from.parentOffset, null, "\ufffc") + text;
                        for (var i = 0; i < rules.length; i++) {
                            var match = rules[i].match.exec(textBefore);
                            var tr = match && rules[i].handler(state, match, from - (match[0].length - text.length), to);
                            if (!tr) {
                                continue;
                            }
                            view.dispatch(tr.setMeta(stateKey, {
                                transform: tr,
                                from: from,
                                to: to,
                                text: text
                            }));
                            return true;
                        }
                        return false;
                    },
                    handleKeyDown: function handleKeyDown(view, event) {
                        if (event.keyCode == 8) {
                            return maybeUndoInputRule(view.state, view.dispatch, this.getState(view.state));
                        }
                        return false;
                    }
                }
            });
        }
        exports.inputRules = inputRules;
        function maybeUndoInputRule(state, dispatch, undoable) {
            if (!undoable) {
                return false;
            }
            var tr = state.tr,
                toUndo = undoable.transform;
            for (var i = toUndo.steps.length - 1; i >= 0; i--) {
                tr.step(toUndo.steps[i].invert(toUndo.docs[i]));
            }
            var marks = tr.doc.resolve(undoable.from).marks();
            dispatch(tr.replaceWith(undoable.from, undoable.to, state.schema.text(undoable.text, marks)));
            return true;
        }
        return module.exports;
    });

    $__System.registerDynamic("8", ["6", "9"], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        var ref = $__require('6');
        var InputRule = ref.InputRule;
        var ref$1 = $__require('9');
        var findWrapping = ref$1.findWrapping;
        var canJoin = ref$1.canJoin;
        function wrappingInputRule(regexp, nodeType, getAttrs, joinPredicate) {
            return new InputRule(regexp, function(state, match, start, end) {
                var attrs = getAttrs instanceof Function ? getAttrs(match) : getAttrs;
                var tr = state.tr.delete(start, end);
                var $start = tr.doc.resolve(start),
                    range = $start.blockRange(),
                    wrapping = range && findWrapping(range, nodeType, attrs);
                if (!wrapping) {
                    return null;
                }
                tr.wrap(range, wrapping);
                var before = tr.doc.resolve(start - 1).nodeBefore;
                if (before && before.type == nodeType && canJoin(tr.doc, start - 1) && (!joinPredicate || joinPredicate(match, before))) {
                    tr.join(start - 1);
                }
                return tr;
            });
        }
        exports.wrappingInputRule = wrappingInputRule;
        function textblockTypeInputRule(regexp, nodeType, getAttrs) {
            return new InputRule(regexp, function(state, match, start, end) {
                var $start = state.doc.resolve(start);
                var attrs = getAttrs instanceof Function ? getAttrs(match) : getAttrs;
                if (!$start.node(-1).canReplaceWith($start.index(-1), $start.indexAfter(-1), nodeType, attrs)) {
                    return null;
                }
                return state.tr.delete(start, end).setBlockType(start, start, nodeType, attrs);
            });
        }
        exports.textblockTypeInputRule = textblockTypeInputRule;
        function blockQuoteRule(nodeType) {
            return wrappingInputRule(/^\s*> $/, nodeType);
        }
        exports.blockQuoteRule = blockQuoteRule;
        function orderedListRule(nodeType) {
            return wrappingInputRule(/^(\d+)\. $/, nodeType, function(match) {
                return ({order: +match[1]});
            }, function(match, node) {
                return node.childCount + node.attrs.order == +match[1];
            });
        }
        exports.orderedListRule = orderedListRule;
        function bulletListRule(nodeType) {
            return wrappingInputRule(/^\s*([-+*]) $/, nodeType);
        }
        exports.bulletListRule = bulletListRule;
        function codeBlockRule(nodeType) {
            return textblockTypeInputRule(/^```$/, nodeType);
        }
        exports.codeBlockRule = codeBlockRule;
        function headingRule(nodeType, maxLevel) {
            return textblockTypeInputRule(new RegExp("^(#{1," + maxLevel + "}) $"), nodeType, function(match) {
                return ({level: match[1].length});
            });
        }
        exports.headingRule = headingRule;
        return module.exports;
    });

    $__System.registerDynamic("a", ["6", "5", "8"], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        ;
        var assign;
        ((assign = $__require('6'), exports.InputRule = assign.InputRule, exports.inputRules = assign.inputRules));
        ;
        var assign$1;
        ((assign$1 = $__require('5'), exports.emDash = assign$1.emDash, exports.ellipsis = assign$1.ellipsis, exports.openDoubleQuote = assign$1.openDoubleQuote, exports.closeDoubleQuote = assign$1.closeDoubleQuote, exports.openSingleQuote = assign$1.openSingleQuote, exports.closeSingleQuote = assign$1.closeSingleQuote, exports.smartQuotes = assign$1.smartQuotes, exports.allInputRules = assign$1.allInputRules));
        ;
        var assign$2;
        ((assign$2 = $__require('8'), exports.wrappingInputRule = assign$2.wrappingInputRule, exports.textblockTypeInputRule = assign$2.textblockTypeInputRule, exports.blockQuoteRule = assign$2.blockQuoteRule, exports.orderedListRule = assign$2.orderedListRule, exports.bulletListRule = assign$2.bulletListRule, exports.codeBlockRule = assign$2.codeBlockRule, exports.headingRule = assign$2.headingRule));
        return module.exports;
    });

    $__System.registerDynamic("b", ["a"], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        module.exports = $__require('a');
        return module.exports;
    });

    $__System.registerDynamic("c", [], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        var base = {
            8: "Backspace",
            9: "Tab",
            10: "Enter",
            12: "NumLock",
            13: "Enter",
            16: "Shift",
            17: "Control",
            18: "Alt",
            20: "CapsLock",
            27: "Escape",
            32: " ",
            33: "PageUp",
            34: "PageDown",
            35: "End",
            36: "Home",
            37: "ArrowLeft",
            38: "ArrowUp",
            39: "ArrowRight",
            40: "ArrowDown",
            44: "PrintScreen",
            45: "Insert",
            46: "Delete",
            59: ";",
            61: "=",
            91: "Meta",
            92: "Meta",
            106: "*",
            107: "+",
            108: ",",
            109: "-",
            110: ".",
            111: "/",
            144: "NumLock",
            145: "ScrollLock",
            160: "Shift",
            161: "Shift",
            162: "Control",
            163: "Control",
            164: "Alt",
            165: "Alt",
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
            229: "q"
        };
        var shift = {
            48: ")",
            49: "!",
            50: "@",
            51: "#",
            52: "$",
            53: "%",
            54: "^",
            55: "&",
            56: "*",
            57: "(",
            59: ";",
            61: "+",
            173: "_",
            186: ":",
            187: "+",
            188: "<",
            189: "_",
            190: ">",
            191: "?",
            192: "~",
            219: "{",
            220: "|",
            221: "}",
            222: "\"",
            229: "Q"
        };
        var chrome = typeof navigator != "undefined" && /Chrome\/(\d+)/.exec(navigator.userAgent);
        var brokenModifierNames = chrome && +chrome[1] < 57;
        for (var i = 0; i < 10; i++)
            base[48 + i] = base[96 + i] = String(i);
        for (var i = 1; i <= 24; i++)
            base[i + 111] = "F" + i;
        for (var i = 65; i <= 90; i++) {
            base[i] = String.fromCharCode(i + 32);
            shift[i] = String.fromCharCode(i);
        }
        for (var code in base)
            if (!shift.hasOwnProperty(code))
                shift[code] = base[code];
        function keyName(event) {
            var name = ((!brokenModifierNames || !event.ctrlKey && !event.altKey && !event.metaKey) && event.key) || (event.shiftKey ? shift : base)[event.keyCode] || event.key || "Unidentified";
            if (name == "Esc")
                name = "Escape";
            if (name == "Del")
                name = "Delete";
            return name;
        }
        module.exports = keyName;
        keyName.base = base;
        keyName.shift = shift;
        return module.exports;
    });

    $__System.registerDynamic("d", ["c"], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        module.exports = $__require('c');
        return module.exports;
    });

    $__System.registerDynamic("e", ["d", "7"], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        var keyName = $__require('d');
        var ref = $__require('7');
        var Plugin = ref.Plugin;
        var mac = typeof navigator != "undefined" ? /Mac/.test(navigator.platform) : false;
        function normalizeKeyName(name) {
            var parts = name.split(/-(?!$)/),
                result = parts[parts.length - 1];
            if (result == "Space") {
                result = " ";
            }
            var alt,
                ctrl,
                shift,
                meta;
            for (var i = 0; i < parts.length - 1; i++) {
                var mod = parts[i];
                if (/^(cmd|meta|m)$/i.test(mod)) {
                    meta = true;
                } else if (/^a(lt)?$/i.test(mod)) {
                    alt = true;
                } else if (/^(c|ctrl|control)$/i.test(mod)) {
                    ctrl = true;
                } else if (/^s(hift)?$/i.test(mod)) {
                    shift = true;
                } else if (/^mod$/i.test(mod)) {
                    if (mac) {
                        meta = true;
                    } else {
                        ctrl = true;
                    }
                } else {
                    throw new Error("Unrecognized modifier name: " + mod);
                }
            }
            if (alt) {
                result = "Alt-" + result;
            }
            if (ctrl) {
                result = "Ctrl-" + result;
            }
            if (meta) {
                result = "Meta-" + result;
            }
            if (shift) {
                result = "Shift-" + result;
            }
            return result;
        }
        function normalize(map) {
            var copy = Object.create(null);
            for (var prop in map) {
                copy[normalizeKeyName(prop)] = map[prop];
            }
            return copy;
        }
        function modifiers(name, event, shift) {
            if (event.altKey) {
                name = "Alt-" + name;
            }
            if (event.ctrlKey) {
                name = "Ctrl-" + name;
            }
            if (event.metaKey) {
                name = "Meta-" + name;
            }
            if (shift !== false && event.shiftKey) {
                name = "Shift-" + name;
            }
            return name;
        }
        function keymap(bindings) {
            var map = normalize(bindings);
            return new Plugin({props: {handleKeyDown: function handleKeyDown(view, event) {
                var name = keyName(event),
                    isChar = name.length == 1 && name != " ",
                    baseName;
                var direct = map[modifiers(name, event, !isChar)];
                if (direct && direct(view.state, view.dispatch, view)) {
                    return true;
                }
                if (event.shiftKey && isChar && (baseName = keyName.base[event.keyCode])) {
                    var withShift = map[modifiers(baseName, event, true)];
                    if (withShift && withShift(view.state, view.dispatch, view)) {
                        return true;
                    }
                }
                return false;
            }}});
        }
        exports.keymap = keymap;
        return module.exports;
    });

    $__System.registerDynamic("f", ["e"], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        module.exports = $__require('e');
        return module.exports;
    });

    $__System.registerDynamic("10", ["7", "11"], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        var ref = $__require('7');
        var Plugin = ref.Plugin;
        var ref$1 = $__require('11');
        var Decoration = ref$1.Decoration;
        var DecorationSet = ref$1.DecorationSet;
        var gecko = typeof navigator != "undefined" && /gecko\/\d/i.test(navigator.userAgent);
        var linux = typeof navigator != "undefined" && /linux/i.test(navigator.platform);
        function dropCursor(options) {
            function dispatch(view, data) {
                view.dispatch(view.state.tr.setMeta(plugin, data));
            }
            var timeout = null;
            function scheduleRemoval(view) {
                clearTimeout(timeout);
                timeout = setTimeout(function() {
                    if (plugin.getState(view.state)) {
                        dispatch(view, {type: "remove"});
                    }
                }, 1000);
            }
            var plugin = new Plugin({
                state: {
                    init: function init() {
                        return null;
                    },
                    apply: function apply(tr, prev, state) {
                        if (gecko && linux) {
                            return null;
                        }
                        var command = tr.getMeta(plugin);
                        if (!command) {
                            return prev;
                        }
                        if (command.type == "set") {
                            return pluginStateFor(state, command.pos, options);
                        }
                        return null;
                    }
                },
                props: {
                    handleDOMEvents: {
                        dragover: function dragover(view, event) {
                            var active = plugin.getState(view.state);
                            var pos = view.posAtCoords({
                                left: event.clientX,
                                top: event.clientY
                            });
                            if (pos && !active || active.pos != pos.pos) {
                                dispatch(view, {
                                    type: "setDropCursor",
                                    pos: pos.pos
                                });
                            }
                            scheduleRemoval(view);
                            return false;
                        },
                        dragend: function dragend(view) {
                            if (plugin.getState(view.state)) {
                                dispatch(view, {type: "remove"});
                            }
                            return false;
                        },
                        drop: function drop(view) {
                            if (plugin.getState(view.state)) {
                                dispatch(view, {type: "remove"});
                            }
                            return false;
                        },
                        dragleave: function dragleave(view, event) {
                            if (event.target == view.content) {
                                dispatch(view, {type: "remove"});
                            }
                            return false;
                        }
                    },
                    decorations: function decorations(state) {
                        var active = plugin.getState(state);
                        return active && active.deco;
                    }
                }
            });
            return plugin;
        }
        exports.dropCursor = dropCursor;
        function style(options, side) {
            var width = (options && options.width) || 1;
            var color = (options && options.color) || "black";
            return ("border-" + side + ": " + width + "px solid " + color + "; margin-" + side + ": -" + width + "px");
        }
        function pluginStateFor(state, pos, options) {
            var $pos = state.doc.resolve(pos),
                deco;
            if (!$pos.parent.isTextblock) {
                var before,
                    after;
                if (before = $pos.nodeBefore) {
                    deco = Decoration.node(pos - before.nodeSize, pos, {
                        nodeName: "div",
                        style: style(options, "right")
                    });
                } else if (after = $pos.nodeAfter) {
                    deco = Decoration.node(pos, pos + after.nodeSize, {
                        nodeName: "div",
                        style: style(options, "left")
                    });
                }
            }
            if (!deco) {
                var node = document.createElement("span");
                node.textContent = "\u200b";
                node.style.cssText = style(options, "left") + "; display: inline-block; pointer-events: none";
                deco = Decoration.widget(pos, node);
            }
            return {
                pos: pos,
                deco: DecorationSet.create(state.doc, [deco])
            };
        }
        return module.exports;
    });

    $__System.registerDynamic("12", ["10"], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        module.exports = $__require('10');
        return module.exports;
    });

    $__System.registerDynamic("13", [], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        function windowRect() {
            return {
                left: 0,
                right: window.innerWidth,
                top: 0,
                bottom: window.innerHeight
            };
        }
        function parentNode(node) {
            var parent = node.parentNode;
            return parent.nodeType == 11 ? parent.host : parent;
        }
        function scrollRectIntoView(view, rect) {
            var scrollThreshold = view.someProp("scrollThreshold") || 0,
                scrollMargin = view.someProp("scrollMargin");
            if (scrollMargin == null) {
                scrollMargin = 5;
            }
            for (var parent = view.content; ; parent = parentNode(parent)) {
                var atBody = parent == document.body;
                var bounding = atBody ? windowRect() : parent.getBoundingClientRect();
                var moveX = 0,
                    moveY = 0;
                if (rect.top < bounding.top + scrollThreshold) {
                    moveY = -(bounding.top - rect.top + scrollMargin);
                } else if (rect.bottom > bounding.bottom - scrollThreshold) {
                    moveY = rect.bottom - bounding.bottom + scrollMargin;
                }
                if (rect.left < bounding.left + scrollThreshold) {
                    moveX = -(bounding.left - rect.left + scrollMargin);
                } else if (rect.right > bounding.right - scrollThreshold) {
                    moveX = rect.right - bounding.right + scrollMargin;
                }
                if (moveX || moveY) {
                    if (atBody) {
                        window.scrollBy(moveX, moveY);
                    } else {
                        if (moveY) {
                            parent.scrollTop += moveY;
                        }
                        if (moveX) {
                            parent.scrollLeft += moveX;
                        }
                    }
                }
                if (atBody) {
                    break;
                }
            }
        }
        exports.scrollRectIntoView = scrollRectIntoView;
        function findOffsetInNode(node, coords) {
            var closest,
                dxClosest = 2e8,
                coordsClosest,
                offset = 0;
            var rowBot = coords.top,
                rowTop = coords.top;
            for (var child = node.firstChild,
                     childIndex = 0; child; child = child.nextSibling, childIndex++) {
                var rects = (void 0);
                if (child.nodeType == 1) {
                    rects = child.getClientRects();
                } else if (child.nodeType == 3) {
                    rects = textRange(child).getClientRects();
                } else {
                    continue;
                }
                for (var i = 0; i < rects.length; i++) {
                    var rect = rects[i];
                    if (rect.top <= rowBot && rect.bottom >= rowTop) {
                        rowBot = Math.max(rect.bottom, rowBot);
                        rowTop = Math.min(rect.top, rowTop);
                        var dx = rect.left > coords.left ? rect.left - coords.left : rect.right < coords.left ? coords.left - rect.right : 0;
                        if (dx < dxClosest) {
                            closest = child;
                            dxClosest = dx;
                            coordsClosest = dx && closest.nodeType == 3 ? {
                                left: rect.right < coords.left ? rect.right : rect.left,
                                top: coords.top
                            } : coords;
                            if (child.nodeType == 1 && dx) {
                                offset = childIndex + (coords.left >= (rect.left + rect.right) / 2 ? 1 : 0);
                            }
                            continue;
                        }
                    }
                    if (!closest && (coords.left >= rect.right && coords.top >= rect.top || coords.left >= rect.left && coords.top >= rect.bottom)) {
                        offset = childIndex + 1;
                    }
                }
            }
            if (closest && closest.nodeType == 3) {
                return findOffsetInText(closest, coordsClosest);
            }
            if (!closest || (dxClosest && closest.nodeType == 1)) {
                return {
                    node: node,
                    offset: offset
                };
            }
            return findOffsetInNode(closest, coordsClosest);
        }
        function findOffsetInText(node, coords) {
            var len = node.nodeValue.length;
            var range = document.createRange();
            for (var i = 0; i < len; i++) {
                range.setEnd(node, i + 1);
                range.setStart(node, i);
                var rect = singleRect(range, 1);
                if (rect.top == rect.bottom) {
                    continue;
                }
                if (rect.left - 1 <= coords.left && rect.right + 1 >= coords.left && rect.top - 1 <= coords.top && rect.bottom + 1 >= coords.top) {
                    return {
                        node: node,
                        offset: i + (coords.left >= (rect.left + rect.right) / 2 ? 1 : 0)
                    };
                }
            }
            return {
                node: node,
                offset: 0
            };
        }
        function targetKludge(dom, coords) {
            if (/^[uo]l$/i.test(dom.nodeName)) {
                for (var child = dom.firstChild; child; child = child.nextSibling) {
                    if (!child.pmViewDesc || !/^li$/i.test(child.nodeName)) {
                        continue;
                    }
                    var childBox = child.getBoundingClientRect();
                    if (coords.left > childBox.left - 2) {
                        break;
                    }
                    if (childBox.top <= coords.top && childBox.bottom >= coords.top) {
                        return child;
                    }
                }
            }
            return dom;
        }
        function posAtCoords(view, coords) {
            var elt = targetKludge(view.root.elementFromPoint(coords.left, coords.top + 1), coords);
            if (!view.content.contains(elt.nodeType == 3 ? elt.parentNode : elt)) {
                return null;
            }
            var ref = findOffsetInNode(elt, coords);
            var node = ref.node;
            var offset = ref.offset;
            var bias = -1;
            if (node.nodeType == 1 && !node.firstChild) {
                var rect = node.getBoundingClientRect();
                bias = rect.left != rect.right && coords.left > (rect.left + rect.right) / 2 ? 1 : -1;
            }
            var desc = view.docView.nearestDesc(elt, true);
            return {
                pos: view.docView.posFromDOM(node, offset, bias),
                inside: desc && (desc.posAtStart - desc.border)
            };
        }
        exports.posAtCoords = posAtCoords;
        function textRange(node, from, to) {
            var range = document.createRange();
            range.setEnd(node, to == null ? node.nodeValue.length : to);
            range.setStart(node, from || 0);
            return range;
        }
        function singleRect(object, bias) {
            var rects = object.getClientRects();
            return !rects.length ? object.getBoundingClientRect() : rects[bias < 0 ? 0 : rects.length - 1];
        }
        function coordsAtPos(view, pos) {
            var ref = view.docView.domFromPos(pos);
            var node = ref.node;
            var offset = ref.offset;
            var side,
                rect;
            if (node.nodeType == 3) {
                if (offset < node.nodeValue.length) {
                    rect = singleRect(textRange(node, offset, offset + 1), -1);
                    side = "left";
                }
                if ((!rect || rect.left == rect.right) && offset) {
                    rect = singleRect(textRange(node, offset - 1, offset), 1);
                    side = "right";
                }
            } else if (node.firstChild) {
                if (offset < node.childNodes.length) {
                    var child = node.childNodes[offset];
                    rect = singleRect(child.nodeType == 3 ? textRange(child) : child, -1);
                    side = "left";
                }
                if ((!rect || rect.top == rect.bottom) && offset) {
                    var child$1 = node.childNodes[offset - 1];
                    rect = singleRect(child$1.nodeType == 3 ? textRange(child$1) : child$1, 1);
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
        exports.coordsAtPos = coordsAtPos;
        function withFlushedState(view, state, f) {
            var viewState = view.state,
                active = view.root.activeElement;
            if (viewState != state || !view.inDOMChange) {
                view.updateState(state);
            }
            if (active != view.content) {
                view.focus();
            }
            try {
                return f();
            } finally {
                if (viewState != state) {
                    view.updateState(viewState);
                }
                if (active != view.content) {
                    active.focus();
                }
            }
        }
        function endOfTextblockVertical(view, state, dir) {
            var $pos = dir == "up" ? state.selection.$from : state.selection.$to;
            if (!$pos.depth) {
                return false;
            }
            return withFlushedState(view, state, function() {
                var dom = view.docView.domAfterPos($pos.before());
                var coords = coordsAtPos(view, $pos.pos);
                for (var child = dom.firstChild; child; child = child.nextSibling) {
                    var boxes = (void 0);
                    if (child.nodeType == 1) {
                        boxes = child.getClientRects();
                    } else if (child.nodeType == 3) {
                        boxes = textRange(child, 0, child.nodeValue.length).getClientRects();
                    } else {
                        continue;
                    }
                    for (var i = 0; i < boxes.length; i++) {
                        var box = boxes[i];
                        if (dir == "up" ? box.bottom < coords.top + 1 : box.top > coords.bottom - 1) {
                            return false;
                        }
                    }
                }
                return true;
            });
        }
        var maybeRTL = /[\u0590-\u08ac]/;
        function endOfTextblockHorizontal(view, state, dir) {
            var ref = state.selection;
            var $head = ref.$head;
            var empty = ref.empty;
            if (!empty || !$head.parent.isTextblock || !$head.depth) {
                return false;
            }
            var offset = $head.parentOffset,
                atStart = !offset,
                atEnd = offset == $head.parent.content.size;
            if (!atStart && !atEnd && !maybeRTL.test($head.parent.textContent)) {
                return false;
            }
            var sel = getSelection();
            if (!sel.modify) {
                return dir == "left" || dir == "backward" ? atStart : atEnd;
            }
            return withFlushedState(view, state, function() {
                var oldRange = sel.getRangeAt(0);
                sel.modify("move", dir, "character");
                var parentDOM = view.docView.domAfterPos($head.before());
                var result = !parentDOM.contains(sel.focusNode.nodeType == 1 ? sel.focusNode : sel.focusNode.parentNode) || view.docView.posFromDOM(sel.focusNode, sel.focusOffset) == $head.pos;
                sel.removeAllRanges();
                sel.addRange(oldRange);
                return result;
            });
        }
        var cachedState = null,
            cachedDir = null,
            cachedResult = false;
        function endOfTextblock(view, state, dir) {
            if (cachedState == state && cachedDir == dir) {
                return cachedResult;
            }
            cachedState = state;
            cachedDir = dir;
            return cachedResult = dir == "up" || dir == "down" ? endOfTextblockVertical(view, state, dir) : endOfTextblockHorizontal(view, state, dir);
        }
        exports.endOfTextblock = endOfTextblock;
        return module.exports;
    });

    $__System.registerDynamic("14", ["3", "15"], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        var ref = $__require('3');
        var DOMSerializer = ref.DOMSerializer;
        var browser = $__require('15');
        var NOT_DIRTY = 0,
            CHILD_DIRTY = 1,
            CONTENT_DIRTY = 2,
            NODE_DIRTY = 3;
        var ViewDesc = function(parent, children, dom, contentDOM) {
            this.parent = parent;
            this.children = children;
            this.dom = dom;
            dom.pmViewDesc = this;
            this.contentDOM = contentDOM;
            this.dirty = NOT_DIRTY;
        };
        var prototypeAccessors = {
            size: {},
            border: {},
            posAtStart: {},
            posAtEnd: {}
        };
        ViewDesc.prototype.matchesWidget = function() {
            return false;
        };
        ViewDesc.prototype.matchesMark = function() {
            return false;
        };
        ViewDesc.prototype.matchesNode = function() {
            return false;
        };
        ViewDesc.prototype.matchesHack = function() {
            return false;
        };
        ViewDesc.prototype.parseRule = function() {
            return null;
        };
        ViewDesc.prototype.stopEvent = function() {
            return false;
        };
        prototypeAccessors.size.get = function() {
            var this$1 = this;
            var size = 0;
            for (var i = 0; i < this.children.length; i++) {
                size += this$1.children[i].size;
            }
            return size;
        };
        prototypeAccessors.border.get = function() {
            return 0;
        };
        ViewDesc.prototype.destroy = function() {
            var this$1 = this;
            this.parent = this.dom.pmViewDesc = null;
            for (var i = 0; i < this.children.length; i++) {
                this$1.children[i].destroy();
            }
        };
        ViewDesc.prototype.posBeforeChild = function(child) {
            var this$1 = this;
            for (var i = 0,
                     pos = this.posAtStart; i < this.children.length; i++) {
                var cur = this$1.children[i];
                if (cur == child) {
                    return pos;
                }
                pos += cur.size;
            }
        };
        prototypeAccessors.posAtStart.get = function() {
            return this.parent ? this.parent.posBeforeChild(this) + this.border : 0;
        };
        prototypeAccessors.posAtEnd.get = function() {
            return this.posAtStart + this.size - 2 * this.border;
        };
        ViewDesc.prototype.localPosFromDOM = function(dom, offset, bias) {
            var this$1 = this;
            if (this.contentDOM && this.contentDOM.contains(dom.nodeType == 1 ? dom : dom.parentNode)) {
                if (bias < 0) {
                    var domBefore,
                        desc;
                    if (dom == this.contentDOM) {
                        domBefore = dom.childNodes[offset - 1];
                    } else {
                        while (dom.parentNode != this.contentDOM) {
                            dom = dom.parentNode;
                        }
                        domBefore = dom.previousSibling;
                    }
                    while (domBefore && !((desc = domBefore.pmViewDesc) && desc.parent == this)) {
                        domBefore = domBefore.previousSibling;
                    }
                    return domBefore ? this.posBeforeChild(desc) + desc.size : this.posAtStart;
                } else {
                    var domAfter,
                        desc$1;
                    if (dom == this.contentDOM) {
                        domAfter = dom.childNodes[offset];
                    } else {
                        while (dom.parentNode != this.contentDOM) {
                            dom = dom.parentNode;
                        }
                        domAfter = dom.nextSibling;
                    }
                    while (domAfter && !((desc$1 = domAfter.pmViewDesc) && desc$1.parent == this)) {
                        domAfter = domAfter.nextSibling;
                    }
                    return domAfter ? this.posBeforeChild(desc$1) : this.posAtEnd;
                }
            }
            var atEnd;
            if (this.contentDOM) {
                atEnd = dom.compareDocumentPosition(this.contentDOM) & 2;
            } else if (this.dom.firstChild) {
                if (offset == 0) {
                    for (var search = dom; ; search = search.parentNode) {
                        if (search == this$1.dom) {
                            atEnd = false;
                            break;
                        }
                        if (search.parentNode.firstChild != search) {
                            break;
                        }
                    }
                }
                if (atEnd == null && offset == dom.childNodes.length) {
                    for (var search$1 = dom; ; search$1 = search$1.parentNode) {
                        if (search$1 == this$1.dom) {
                            atEnd = true;
                            break;
                        }
                        if (search$1.parentNode.lastChild != search$1) {
                            break;
                        }
                    }
                }
            }
            return (atEnd == null ? bias > 0 : atEnd) ? this.posAtEnd : this.posAtStart;
        };
        ViewDesc.prototype.nearestDesc = function(dom, onlyNodes) {
            var this$1 = this;
            for (var first = true,
                     cur = dom; cur; cur = cur.parentNode) {
                var desc = this$1.getDesc(cur);
                if (desc && (!onlyNodes || desc.node)) {
                    if (first && desc.nodeDOM && !desc.nodeDOM.contains(dom)) {
                        first = false;
                    } else {
                        return desc;
                    }
                }
            }
        };
        ViewDesc.prototype.getDesc = function(dom) {
            var this$1 = this;
            var desc = dom.pmViewDesc;
            for (var cur = desc; cur; cur = cur.parent) {
                if (cur == this$1) {
                    return desc;
                }
            }
        };
        ViewDesc.prototype.posFromDOM = function(dom, offset, bias) {
            var this$1 = this;
            for (var scan = dom; ; scan = scan.parentNode) {
                var desc = this$1.getDesc(scan);
                if (desc) {
                    return desc.localPosFromDOM(dom, offset, bias);
                }
            }
        };
        ViewDesc.prototype.descAt = function(pos) {
            var this$1 = this;
            for (var i = 0,
                     offset = 0; i < this.children.length; i++) {
                var child = this$1.children[i],
                    end = offset + child.size;
                if (offset == pos && end != offset) {
                    while (!child.border && child.children.length) {
                        child = child.children[0];
                    }
                    return child;
                }
                if (pos < end) {
                    return child.descAt(pos - offset - child.border);
                }
                offset = end;
            }
        };
        ViewDesc.prototype.domFromPos = function(pos, searchDOM) {
            var this$1 = this;
            if (!this.contentDOM) {
                return {
                    node: this.dom,
                    offset: 0
                };
            }
            for (var offset = 0,
                     i = 0; ; i++) {
                if (offset == pos) {
                    return {
                        node: this$1.contentDOM,
                        offset: searchDOM ? this$1.findDOMOffset(i, searchDOM) : i
                    };
                }
                if (i == this$1.children.length) {
                    throw new Error("Invalid position " + pos);
                }
                var child = this$1.children[i],
                    end = offset + child.size;
                if (pos < end) {
                    return child.domFromPos(pos - offset - child.border, searchDOM);
                }
                offset = end;
            }
        };
        ViewDesc.prototype.findDOMOffset = function(i, searchDOM) {
            var this$1 = this;
            var content = this.contentDOM;
            if (searchDOM < 0) {
                for (var j = i - 1; j >= 0; j--) {
                    var child = this$1.children[j];
                    if (!child.size) {
                        continue;
                    }
                    var found = Array.prototype.indexOf.call(content.childNodes, child.dom);
                    if (found > -1) {
                        return found + 1;
                    }
                }
                return 0;
            } else {
                for (var j$1 = i; j$1 < this.children.length; j$1++) {
                    var child$1 = this$1.children[j$1];
                    if (!child$1.size) {
                        continue;
                    }
                    var found$1 = Array.prototype.indexOf.call(content.childNodes, child$1.dom);
                    if (found$1 > -1) {
                        return found$1;
                    }
                }
                return content.childNodes.length;
            }
        };
        ViewDesc.prototype.domAfterPos = function(pos) {
            var ref = this.domFromPos(pos);
            var node = ref.node;
            var offset = ref.offset;
            if (node.nodeType != 1 || offset == node.childNodes.length) {
                throw new RangeError("No node after pos " + pos);
            }
            return node.childNodes[offset];
        };
        ViewDesc.prototype.setSelection = function(anchor, head, root) {
            var this$1 = this;
            var from = Math.min(anchor, head),
                to = Math.max(anchor, head);
            for (var i = 0,
                     offset = 0; i < this.children.length; i++) {
                var child = this$1.children[i],
                    end = offset + child.size;
                if (from > offset && to < end) {
                    return child.setSelection(anchor - offset - child.border, head - offset - child.border, root);
                }
                offset = end;
            }
            var anchorDOM = this.domFromPos(anchor),
                headDOM = this.domFromPos(head);
            var domSel = root.getSelection(),
                range = document.createRange();
            if (domSel.extend) {
                range.setEnd(anchorDOM.node, anchorDOM.offset);
                range.collapse(false);
            } else {
                if (anchor > head) {
                    var tmp = anchorDOM;
                    anchorDOM = headDOM;
                    headDOM = tmp;
                }
                range.setEnd(headDOM.node, headDOM.offset);
                range.setStart(anchorDOM.node, anchorDOM.offset);
            }
            domSel.removeAllRanges();
            domSel.addRange(range);
            if (domSel.extend) {
                domSel.extend(headDOM.node, headDOM.offset);
            }
        };
        ViewDesc.prototype.ignoreMutation = function(_mutation) {
            return !this.contentDOM;
        };
        ViewDesc.prototype.markDirty = function(from, to) {
            var this$1 = this;
            for (var offset = 0,
                     i = 0; i < this.children.length; i++) {
                var child = this$1.children[i],
                    end = offset + child.size;
                if (offset == end ? from <= end && to >= offset : from < end && to > offset) {
                    var startInside = offset + child.border,
                        endInside = end - child.border;
                    if (from >= startInside && to <= endInside) {
                        this$1.dirty = from == offset || to == end ? CONTENT_DIRTY : CHILD_DIRTY;
                        child.markDirty(from - startInside, to - startInside);
                        return;
                    } else {
                        child.dirty = NODE_DIRTY;
                    }
                }
                offset = end;
            }
            this.dirty = CONTENT_DIRTY;
        };
        Object.defineProperties(ViewDesc.prototype, prototypeAccessors);
        var nothing = [];
        var WidgetViewDesc = (function(ViewDesc) {
            function WidgetViewDesc(parent, widget) {
                ViewDesc.call(this, parent, nothing, widget.type.widget, null);
                this.widget = widget;
            }
            if (ViewDesc)
                WidgetViewDesc.__proto__ = ViewDesc;
            WidgetViewDesc.prototype = Object.create(ViewDesc && ViewDesc.prototype);
            WidgetViewDesc.prototype.constructor = WidgetViewDesc;
            WidgetViewDesc.prototype.matchesWidget = function(widget) {
                return this.dirty == NOT_DIRTY && widget.type == this.widget.type;
            };
            WidgetViewDesc.prototype.parseRule = function() {
                return {ignore: true};
            };
            WidgetViewDesc.prototype.stopEvent = function(event) {
                var stop = this.widget.type.options.stopEvent;
                return stop ? stop(event) : false;
            };
            return WidgetViewDesc;
        }(ViewDesc));
        var MarkViewDesc = (function(ViewDesc) {
            function MarkViewDesc(parent, mark, dom) {
                ViewDesc.call(this, parent, [], dom, dom);
                this.mark = mark;
            }
            if (ViewDesc)
                MarkViewDesc.__proto__ = ViewDesc;
            MarkViewDesc.prototype = Object.create(ViewDesc && ViewDesc.prototype);
            MarkViewDesc.prototype.constructor = MarkViewDesc;
            MarkViewDesc.create = function(parent, mark, view) {
                var custom = customNodeViews(view)[mark.type.name];
                var spec = custom && custom(mark, view);
                var dom = spec && spec.dom || DOMSerializer.renderSpec(document, mark.type.spec.toDOM(mark)).dom;
                return new MarkViewDesc(parent, mark, dom);
            };
            MarkViewDesc.prototype.parseRule = function() {
                return {
                    mark: this.mark.type.name,
                    attrs: this.mark.attrs,
                    contentElement: this.contentDOM
                };
            };
            MarkViewDesc.prototype.matchesMark = function(mark) {
                return this.dirty != NODE_DIRTY && this.mark.eq(mark);
            };
            return MarkViewDesc;
        }(ViewDesc));
        var NodeViewDesc = (function(ViewDesc) {
            function NodeViewDesc(parent, node, outerDeco, innerDeco, dom, contentDOM, nodeDOM, view) {
                ViewDesc.call(this, parent, node.isLeaf ? nothing : [], dom, contentDOM);
                this.nodeDOM = nodeDOM;
                this.node = node;
                this.outerDeco = outerDeco;
                this.innerDeco = innerDeco;
                if (contentDOM) {
                    this.updateChildren(view);
                }
            }
            if (ViewDesc)
                NodeViewDesc.__proto__ = ViewDesc;
            NodeViewDesc.prototype = Object.create(ViewDesc && ViewDesc.prototype);
            NodeViewDesc.prototype.constructor = NodeViewDesc;
            var prototypeAccessors$1 = {
                size: {},
                border: {}
            };
            NodeViewDesc.create = function(parent, node, outerDeco, innerDeco, view) {
                var custom = customNodeViews(view)[node.type.name],
                    descObj;
                var spec = custom && custom(node, view, function() {
                        if (descObj && descObj.parent) {
                            return descObj.parent.posBeforeChild(descObj);
                        }
                    }, outerDeco);
                var dom = spec && spec.dom,
                    contentDOM = spec && spec.contentDOM;
                if (!dom) {
                    var assign;
                    ((assign = DOMSerializer.renderSpec(document, node.type.spec.toDOM(node)), dom = assign.dom, contentDOM = assign.contentDOM));
                }
                if (!contentDOM && !node.isText) {
                    dom.contentEditable = false;
                }
                var nodeDOM = dom;
                dom = applyOuterDeco(dom, outerDeco, node);
                if (spec) {
                    return descObj = new CustomNodeViewDesc(parent, node, outerDeco, innerDeco, dom, contentDOM, nodeDOM, spec, view);
                } else if (node.isText) {
                    return new TextViewDesc(parent, node, outerDeco, innerDeco, dom, nodeDOM, view);
                } else {
                    return new NodeViewDesc(parent, node, outerDeco, innerDeco, dom, contentDOM, nodeDOM, view);
                }
            };
            NodeViewDesc.prototype.parseRule = function() {
                return {
                    node: this.node.type.name,
                    attrs: this.node.attrs,
                    contentElement: this.contentDOM
                };
            };
            NodeViewDesc.prototype.matchesNode = function(node, outerDeco, innerDeco) {
                return this.dirty == NOT_DIRTY && node.eq(this.node) && sameOuterDeco(outerDeco, this.outerDeco) && innerDeco.eq(this.innerDeco);
            };
            prototypeAccessors$1.size.get = function() {
                return this.node.nodeSize;
            };
            prototypeAccessors$1.border.get = function() {
                return this.node.isLeaf ? 0 : 1;
            };
            NodeViewDesc.prototype.updateChildren = function(view) {
                var this$1 = this;
                var updater = new ViewTreeUpdater(this);
                iterDeco(this.node, this.innerDeco, function(widget) {
                    updater.placeWidget(widget);
                }, function(child, outerDeco, innerDeco, i) {
                    updater.syncToMarks(child.marks, view);
                    updater.findNodeMatch(child, outerDeco, innerDeco) || updater.updateNextNode(child, outerDeco, innerDeco, view, this$1.node.content, i) || updater.addNode(child, outerDeco, innerDeco, view);
                });
                updater.syncToMarks(nothing, view);
                if (this.node.isTextblock) {
                    updater.addTextblockHacks();
                }
                updater.destroyRest();
                if (updater.changed || this.dirty == CONTENT_DIRTY) {
                    this.renderChildren();
                }
            };
            NodeViewDesc.prototype.renderChildren = function() {
                renderDescs(this.contentDOM, this.children, NodeViewDesc.is);
                if (browser.ios) {
                    iosHacks(this.dom);
                }
            };
            NodeViewDesc.prototype.update = function(node, outerDeco, innerDeco, view) {
                if (this.dirty == NODE_DIRTY || !node.sameMarkup(this.node)) {
                    return false;
                }
                this.updateOuterDeco(outerDeco);
                this.node = node;
                this.innerDeco = innerDeco;
                if (!node.isLeaf) {
                    this.updateChildren(view);
                }
                this.dirty = NOT_DIRTY;
                return true;
            };
            NodeViewDesc.prototype.updateOuterDeco = function(outerDeco) {
                if (sameOuterDeco(outerDeco, this.outerDeco)) {
                    return;
                }
                var needsWrap = this.nodeDOM.nodeType != 1;
                this.dom = patchOuterDeco(this.dom, this.nodeDOM, computeOuterDeco(this.outerDeco, this.node, needsWrap), computeOuterDeco(outerDeco, this.node, needsWrap));
                this.outerDeco = outerDeco;
            };
            NodeViewDesc.prototype.selectNode = function() {
                this.nodeDOM.classList.add("ProseMirror-selectednode");
            };
            NodeViewDesc.prototype.deselectNode = function() {
                this.nodeDOM.classList.remove("ProseMirror-selectednode");
            };
            Object.defineProperties(NodeViewDesc.prototype, prototypeAccessors$1);
            return NodeViewDesc;
        }(ViewDesc));
        function docViewDesc(doc, outerDeco, innerDeco, dom, view) {
            applyOuterDeco(dom, outerDeco, doc, true);
            return new NodeViewDesc(null, doc, outerDeco, innerDeco, dom, dom, dom, view);
        }
        exports.docViewDesc = docViewDesc;
        var TextViewDesc = (function(NodeViewDesc) {
            function TextViewDesc(parent, node, outerDeco, innerDeco, dom, nodeDOM, view) {
                NodeViewDesc.call(this, parent, node, outerDeco, innerDeco, dom, null, nodeDOM, view);
            }
            if (NodeViewDesc)
                TextViewDesc.__proto__ = NodeViewDesc;
            TextViewDesc.prototype = Object.create(NodeViewDesc && NodeViewDesc.prototype);
            TextViewDesc.prototype.constructor = TextViewDesc;
            TextViewDesc.prototype.parseRule = function() {
                return {skip: this.nodeDOM.parentNode};
            };
            TextViewDesc.prototype.update = function(node, outerDeco) {
                if (this.dirty == NODE_DIRTY || (this.dirty != NOT_DIRTY && !this.inParent) || !node.sameMarkup(this.node)) {
                    return false;
                }
                this.updateOuterDeco(outerDeco);
                if ((this.dirty != NOT_DIRTY || node.text != this.node.text) && node.text != this.nodeDOM.nodeValue) {
                    this.nodeDOM.nodeValue = node.text;
                }
                this.node = node;
                this.dirty = NOT_DIRTY;
                return true;
            };
            TextViewDesc.prototype.inParent = function() {
                var parentDOM = this.parent.contentDOM;
                for (var n = this.nodeDOM; n; n = n.parentNode) {
                    if (n == parentDOM) {
                        return true;
                    }
                }
                return false;
            };
            TextViewDesc.prototype.domFromPos = function(pos, searchDOM) {
                return {
                    node: this.nodeDOM,
                    offset: searchDOM ? Math.max(pos, this.nodeDOM.nodeValue.length) : pos
                };
            };
            TextViewDesc.prototype.localPosFromDOM = function(dom, offset, bias) {
                if (dom == this.nodeDOM) {
                    return this.posAtStart + Math.min(offset, this.node.text.length);
                }
                return NodeViewDesc.prototype.localPosFromDOM.call(this, dom, offset, bias);
            };
            TextViewDesc.prototype.ignoreMutation = function(mutation) {
                return mutation.type != "characterData";
            };
            return TextViewDesc;
        }(NodeViewDesc));
        var BRHackViewDesc = (function(ViewDesc) {
            function BRHackViewDesc() {
                ViewDesc.apply(this, arguments);
            }
            if (ViewDesc)
                BRHackViewDesc.__proto__ = ViewDesc;
            BRHackViewDesc.prototype = Object.create(ViewDesc && ViewDesc.prototype);
            BRHackViewDesc.prototype.constructor = BRHackViewDesc;
            BRHackViewDesc.prototype.parseRule = function() {
                return {ignore: true};
            };
            BRHackViewDesc.prototype.matchesHack = function() {
                return this.dirty == NOT_DIRTY;
            };
            return BRHackViewDesc;
        }(ViewDesc));
        var CustomNodeViewDesc = (function(NodeViewDesc) {
            function CustomNodeViewDesc(parent, node, outerDeco, innerDeco, dom, contentDOM, nodeDOM, spec, view) {
                NodeViewDesc.call(this, parent, node, outerDeco, innerDeco, dom, contentDOM, nodeDOM, view);
                this.spec = spec;
            }
            if (NodeViewDesc)
                CustomNodeViewDesc.__proto__ = NodeViewDesc;
            CustomNodeViewDesc.prototype = Object.create(NodeViewDesc && NodeViewDesc.prototype);
            CustomNodeViewDesc.prototype.constructor = CustomNodeViewDesc;
            CustomNodeViewDesc.prototype.update = function(node, outerDeco, innerDeco, view) {
                if (this.spec.update) {
                    var result = this.spec.update(node, outerDeco);
                    if (result) {
                        this.node = node;
                        if (this.contentDOM) {
                            this.updateChildren(view);
                        }
                    }
                    return result;
                } else if (!this.contentDOM && !node.isLeaf) {
                    return false;
                } else {
                    return NodeViewDesc.prototype.update.call(this, node, outerDeco, this.contentDOM ? this.innerDeco : innerDeco, view);
                }
            };
            CustomNodeViewDesc.prototype.selectNode = function() {
                this.spec.selectNode ? this.spec.selectNode() : NodeViewDesc.prototype.selectNode.call(this);
            };
            CustomNodeViewDesc.prototype.deselectNode = function() {
                this.spec.deselectNode ? this.spec.deselectNode() : NodeViewDesc.prototype.deselectNode.call(this);
            };
            CustomNodeViewDesc.prototype.setSelection = function(anchor, head, root) {
                this.spec.setSelection ? this.spec.setSelection(anchor, head, root) : NodeViewDesc.prototype.setSelection.call(this, anchor, head, root);
            };
            CustomNodeViewDesc.prototype.destroy = function() {
                if (this.spec.destroy) {
                    this.spec.destroy();
                }
                NodeViewDesc.prototype.destroy.call(this);
            };
            CustomNodeViewDesc.prototype.stopEvent = function(event) {
                return this.spec.stopEvent ? this.spec.stopEvent(event) : false;
            };
            CustomNodeViewDesc.prototype.ignoreMutation = function(mutation) {
                return this.spec.ignoreMutation ? this.spec.ignoreMutation(mutation) : NodeViewDesc.prototype.ignoreMutation.call(this, mutation);
            };
            return CustomNodeViewDesc;
        }(NodeViewDesc));
        function renderDescs(parentDOM, descs) {
            var dom = parentDOM.firstChild;
            for (var i = 0; i < descs.length; i++) {
                var desc = descs[i],
                    childDOM = desc.dom;
                if (childDOM.parentNode == parentDOM) {
                    while (childDOM != dom) {
                        dom = rm(dom);
                    }
                    dom = dom.nextSibling;
                } else {
                    parentDOM.insertBefore(childDOM, dom);
                }
                if (desc instanceof MarkViewDesc) {
                    renderDescs(desc.contentDOM, desc.children);
                }
            }
            while (dom) {
                dom = rm(dom);
            }
        }
        var OuterDecoLevel = function(nodeName) {
            if (nodeName) {
                this.nodeName = nodeName;
            }
        };
        OuterDecoLevel.prototype = Object.create(null);
        var noDeco = [new OuterDecoLevel];
        function computeOuterDeco(outerDeco, node, needsWrap) {
            if (outerDeco.length == 0) {
                return noDeco;
            }
            var top = needsWrap ? noDeco[0] : new OuterDecoLevel,
                result = [top];
            for (var i = 0; i < outerDeco.length; i++) {
                var attrs = outerDeco[i].type.attrs,
                    cur = top;
                if (!attrs) {
                    continue;
                }
                if (attrs.nodeName) {
                    result.push(cur = new OuterDecoLevel(attrs.nodeName));
                }
                for (var name in attrs) {
                    var val = attrs[name];
                    if (val == null) {
                        continue;
                    }
                    if (needsWrap && result.length == 1) {
                        result.push(cur = top = new OuterDecoLevel(node.isInline ? "span" : "div"));
                    }
                    if (name == "class") {
                        cur.class = (cur.class ? cur.class + " " : "") + val;
                    } else if (name == "style") {
                        cur.style = (cur.style ? cur.style + ";" : "") + val;
                    } else if (name != "nodeName") {
                        cur[name] = val;
                    }
                }
            }
            return result;
        }
        function patchOuterDeco(outerDOM, nodeDOM, prevComputed, curComputed) {
            if (prevComputed == noDeco && curComputed == noDeco) {
                return nodeDOM;
            }
            var curDOM = nodeDOM;
            for (var i = 0; i < curComputed.length; i++) {
                var deco = curComputed[i],
                    prev = prevComputed[i];
                if (i) {
                    var parent = (void 0);
                    if (prev && prev.nodeName == deco.nodeName && curDOM != outerDOM && (parent = nodeDOM.parentNode) && parent.tagName.toLowerCase() == deco.nodeName) {
                        curDOM = parent;
                    } else {
                        parent = document.createElement(deco.nodeName);
                        parent.appendChild(curDOM);
                        curDOM = parent;
                    }
                }
                patchAttributes(curDOM, prev || noDeco[0], deco);
            }
            return curDOM;
        }
        function patchAttributes(dom, prev, cur) {
            for (var name in prev) {
                if (name != "class" && name != "style" && name != "nodeName" && !(name in cur)) {
                    dom.removeAttribute(name);
                }
            }
            for (var name$1 in cur) {
                if (name$1 != "class" && name$1 != "style" && name$1 != "nodeName" && cur[name$1] != prev[name$1]) {
                    dom.setAttribute(name$1, cur[name$1]);
                }
            }
            if (prev.class != cur.class) {
                var prevList = prev.class ? prev.class.split(" ") : nothing;
                var curList = cur.class ? cur.class.split(" ") : nothing;
                for (var i = 0; i < prevList.length; i++) {
                    if (curList.indexOf(prevList[i]) == -1) {
                        dom.classList.remove(prevList[i]);
                    }
                }
                for (var i$1 = 0; i$1 < curList.length; i$1++) {
                    if (prevList.indexOf(curList[i$1]) == -1) {
                        dom.classList.add(curList[i$1]);
                    }
                }
            }
            if (prev.style != cur.style) {
                var text = dom.style.cssText,
                    found;
                if (prev.style && (found = text.indexOf(prev.style)) > -1) {
                    text = text.slice(0, found) + text.slice(found + prev.style.length);
                }
                dom.style.cssText = text + (cur.style || "");
            }
        }
        function applyOuterDeco(dom, deco, node) {
            return patchOuterDeco(dom, dom, noDeco, computeOuterDeco(deco, node, dom.nodeType != 1));
        }
        function sameOuterDeco(a, b) {
            if (a.length != b.length) {
                return false;
            }
            for (var i = 0; i < a.length; i++) {
                if (!a[i].type.eq(b[i].type)) {
                    return false;
                }
            }
            return true;
        }
        function rm(dom) {
            var next = dom.nextSibling;
            dom.parentNode.removeChild(dom);
            return next;
        }
        var ViewTreeUpdater = function(top) {
            this.top = top;
            this.index = 0;
            this.stack = [];
            this.changed = false;
        };
        ViewTreeUpdater.prototype.destroyBetween = function(start, end) {
            var this$1 = this;
            if (start == end) {
                return;
            }
            for (var i = start; i < end; i++) {
                this$1.top.children[i].destroy();
            }
            this.top.children.splice(start, end - start);
            this.changed = true;
        };
        ViewTreeUpdater.prototype.destroyRest = function() {
            this.destroyBetween(this.index, this.top.children.length);
        };
        ViewTreeUpdater.prototype.syncToMarks = function(marks, view) {
            var this$1 = this;
            var keep = 0,
                depth = this.stack.length >> 1;
            var maxKeep = Math.min(depth, marks.length),
                next;
            while (keep < maxKeep && (keep == depth - 1 ? this.top : this.stack[(keep + 1) << 1]).matchesMark(marks[keep])) {
                keep++;
            }
            while (keep < depth) {
                this$1.destroyRest();
                this$1.top.dirty = NOT_DIRTY;
                this$1.index = this$1.stack.pop();
                this$1.top = this$1.stack.pop();
                depth--;
            }
            while (depth < marks.length) {
                this$1.stack.push(this$1.top, this$1.index + 1);
                if (this$1.index < this$1.top.children.length && (next = this$1.top.children[this$1.index]).matchesMark(marks[depth])) {
                    this$1.top = next;
                } else {
                    var markDesc = MarkViewDesc.create(this$1.top, marks[depth], view);
                    this$1.top.children.splice(this$1.index, 0, markDesc);
                    this$1.top = markDesc;
                    this$1.changed = true;
                }
                this$1.index = 0;
                depth++;
            }
        };
        ViewTreeUpdater.prototype.findNodeMatch = function(node, outerDeco, innerDeco) {
            var this$1 = this;
            for (var i = this.index,
                     children = this.top.children,
                     e = Math.min(children.length, i + 5); i < e; i++) {
                if (children[i].matchesNode(node, outerDeco, innerDeco)) {
                    this$1.destroyBetween(this$1.index, i);
                    this$1.index++;
                    return true;
                }
            }
            return false;
        };
        ViewTreeUpdater.prototype.updateNextNode = function(node, outerDeco, innerDeco, view, siblings, index) {
            if (this.index == this.top.children.length) {
                return false;
            }
            var next = this.top.children[this.index];
            if (next instanceof NodeViewDesc) {
                for (var i = index + 1,
                         e = Math.min(siblings.childCount, i + 5); i < e; i++) {
                    if (next.node == siblings.child(i)) {
                        return false;
                    }
                }
                var nextDOM = next.dom;
                if (next.update(node, outerDeco, innerDeco, view)) {
                    if (next.dom != nextDOM) {
                        this.changed = true;
                    }
                    this.index++;
                    return true;
                }
            }
            return false;
        };
        ViewTreeUpdater.prototype.addNode = function(node, outerDeco, innerDeco, view) {
            this.top.children.splice(this.index++, 0, NodeViewDesc.create(this.top, node, outerDeco, innerDeco, view));
            this.changed = true;
        };
        ViewTreeUpdater.prototype.placeWidget = function(widget) {
            if (this.index < this.top.children.length && this.top.children[this.index].matchesWidget(widget)) {
                this.index++;
            } else {
                this.top.children.splice(this.index++, 0, new WidgetViewDesc(this.top, widget));
                this.changed = true;
            }
        };
        ViewTreeUpdater.prototype.addTextblockHacks = function() {
            var lastChild = this.top.children[this.index - 1];
            while (lastChild instanceof MarkViewDesc) {
                lastChild = lastChild.children[lastChild.children.length - 1];
            }
            if (!lastChild || !(lastChild instanceof TextViewDesc) || /\n$/.test(lastChild.node.text)) {
                if (this.index < this.top.children.length && this.top.children[this.index].matchesHack()) {
                    this.index++;
                } else {
                    var dom = document.createElement("br");
                    this.top.children.splice(this.index++, 0, new BRHackViewDesc(this.top, nothing, dom, null));
                    this.changed = true;
                }
            }
        };
        function iterDeco(parent, deco, onWidget, onNode) {
            var locals = deco.locals(parent),
                offset = 0;
            if (locals.length == 0) {
                for (var i = 0; i < parent.childCount; i++) {
                    var child = parent.child(i);
                    onNode(child, locals, deco.forChild(offset, child), i);
                    offset += child.nodeSize;
                }
                return;
            }
            var decoIndex = 0,
                active = [],
                restNode = null;
            for (var parentIndex = 0; ; ) {
                while (decoIndex < locals.length && locals[decoIndex].to == offset) {
                    onWidget(locals[decoIndex++]);
                }
                var child$1 = (void 0);
                if (restNode) {
                    child$1 = restNode;
                    restNode = null;
                } else if (parentIndex < parent.childCount) {
                    child$1 = parent.child(parentIndex++);
                } else {
                    break;
                }
                for (var i$1 = 0; i$1 < active.length; i$1++) {
                    if (active[i$1].to <= offset) {
                        active.splice(i$1--, 1);
                    }
                }
                while (decoIndex < locals.length && locals[decoIndex].from == offset) {
                    active.push(locals[decoIndex++]);
                }
                var end = offset + child$1.nodeSize;
                if (child$1.isText) {
                    var cutAt = end;
                    if (decoIndex < locals.length && locals[decoIndex].from < cutAt) {
                        cutAt = locals[decoIndex].from;
                    }
                    for (var i$2 = 0; i$2 < active.length; i$2++) {
                        if (active[i$2].to < cutAt) {
                            cutAt = active[i$2].to;
                        }
                    }
                    if (cutAt < end) {
                        restNode = child$1.cut(cutAt - offset);
                        child$1 = child$1.cut(0, cutAt - offset);
                        end = cutAt;
                    }
                }
                onNode(child$1, active.length ? active.slice() : nothing, deco.forChild(offset, child$1), parentIndex - 1);
                offset = end;
            }
        }
        var cachedCustomViews,
            cachedCustomFor;
        function customNodeViews(view) {
            if (cachedCustomFor == view.props) {
                return cachedCustomViews;
            }
            cachedCustomFor = view.props;
            return cachedCustomViews = buildCustomViews(view);
        }
        function buildCustomViews(view) {
            var result = {};
            view.someProp("nodeViews", function(obj) {
                for (var prop in obj) {
                    if (!Object.prototype.hasOwnProperty.call(result, prop)) {
                        result[prop] = obj[prop];
                    }
                }
            });
            return result;
        }
        function iosHacks(dom) {
            if (dom.nodeName == "UL" || dom.nodeName == "OL") {
                var oldCSS = dom.style.cssText;
                dom.style.cssText = oldCSS + "; list-style: square !important";
                window.getComputedStyle(dom).listStyle;
                dom.style.cssText = oldCSS;
            }
        }
        return module.exports;
    });

    $__System.registerDynamic("16", ["7", "15"], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        var ref = $__require('7');
        var Selection = ref.Selection;
        var NodeSelection = ref.NodeSelection;
        var TextSelection = ref.TextSelection;
        var browser = $__require('15');
        function moveSelectionBlock(state, dir) {
            var ref = state.selection;
            var $from = ref.$from;
            var $to = ref.$to;
            var node = ref.node;
            var $side = dir > 0 ? $to : $from;
            var $start = node && node.isBlock ? $side : $side.depth ? state.doc.resolve(dir > 0 ? $side.after() : $side.before()) : null;
            return $start && Selection.findFrom($start, dir);
        }
        function apply(view, sel) {
            view.dispatch(view.state.tr.setSelection(sel).scrollIntoView());
            return true;
        }
        function selectHorizontally(view, dir) {
            var ref = view.state.selection;
            var empty = ref.empty;
            var node = ref.node;
            var $from = ref.$from;
            var $to = ref.$to;
            if (!empty && !node) {
                return false;
            }
            if (node && node.isInline) {
                return apply(view, new TextSelection(dir > 0 ? $to : $from));
            }
            if (!node && !view.endOfTextblock(dir > 0 ? "right" : "left")) {
                var ref$1 = dir > 0 ? $from.parent.childAfter($from.parentOffset) : $from.parent.childBefore($from.parentOffset);
                var nextNode = ref$1.node;
                var offset = ref$1.offset;
                if (nextNode && NodeSelection.isSelectable(nextNode) && offset == $from.parentOffset - (dir > 0 ? 0 : nextNode.nodeSize)) {
                    return apply(view, new NodeSelection(dir < 0 ? view.state.doc.resolve($from.pos - nextNode.nodeSize) : $from));
                }
                return false;
            }
            var next = moveSelectionBlock(view.state, dir);
            if (next && (next instanceof NodeSelection || node)) {
                return apply(view, next);
            }
            return false;
        }
        function nodeLen(node) {
            return node.nodeType == 3 ? node.nodeValue.length : node.childNodes.length;
        }
        function isIgnorable(dom) {
            var desc = dom.pmViewDesc;
            return desc && desc.size == 0;
        }
        function skipIgnoredNodesLeft(view) {
            var sel = view.root.getSelection();
            var node = sel.anchorNode,
                offset = sel.anchorOffset;
            var moveNode,
                moveOffset;
            for (; ; ) {
                if (offset > 0) {
                    if (node.nodeType != 1) {
                        break;
                    }
                    var before = node.childNodes[offset - 1];
                    if (isIgnorable(before)) {
                        moveNode = node;
                        moveOffset = --offset;
                    } else {
                        break;
                    }
                } else if (isBlockNode(node)) {
                    break;
                } else {
                    var prev = node.previousSibling;
                    while (prev && isIgnorable(prev)) {
                        moveNode = node.parentNode;
                        moveOffset = Array.prototype.indexOf.call(moveNode.childNodes, prev);
                        prev = prev.previousSibling;
                    }
                    if (!prev) {
                        node = node.parentNode;
                        if (node == view.content) {
                            break;
                        }
                        offset = 0;
                    } else {
                        node = prev;
                        offset = nodeLen(node);
                    }
                }
            }
            if (moveNode) {
                setSel(sel, moveNode, moveOffset);
            }
        }
        function skipIgnoredNodesRight(view) {
            var sel = view.root.getSelection();
            var node = sel.anchorNode,
                offset = sel.anchorOffset,
                len = nodeLen(node);
            var moveNode,
                moveOffset;
            for (; ; ) {
                if (offset < len) {
                    if (node.nodeType != 1) {
                        break;
                    }
                    var after = node.childNodes[offset];
                    if (isIgnorable(after)) {
                        moveNode = node;
                        moveOffset = ++offset;
                    } else {
                        break;
                    }
                } else if (isBlockNode(node)) {
                    break;
                } else {
                    var next = node.nextSibling;
                    while (next && isIgnorable(next)) {
                        moveNode = next.parentNode;
                        moveOffset = Array.prototype.indexOf.call(moveNode.childNodes, next) + 1;
                        next = next.nextSibling;
                    }
                    if (!next) {
                        node = node.parentNode;
                        if (node == view.content) {
                            break;
                        }
                        offset = len = 0;
                    } else {
                        node = next;
                        offset = 0;
                        len = nodeLen(node);
                    }
                }
            }
            if (moveNode) {
                setSel(sel, moveNode, moveOffset);
            }
        }
        function isBlockNode(dom) {
            var desc = dom.pmViewDesc;
            return desc && desc.node && desc.node.isBlock;
        }
        function setSel(sel, node, offset) {
            var range = document.createRange();
            range.setEnd(node, offset);
            range.setStart(node, offset);
            sel.removeAllRanges();
            sel.addRange(range);
        }
        function selectVertically(view, dir) {
            var ref = view.state.selection;
            var empty = ref.empty;
            var node = ref.node;
            var $from = ref.$from;
            var $to = ref.$to;
            if (!empty && !node) {
                return false;
            }
            var leavingTextblock = true,
                $start = dir < 0 ? $from : $to;
            if (!node || node.isInline) {
                leavingTextblock = view.endOfTextblock(dir < 0 ? "up" : "down");
            }
            if (leavingTextblock) {
                var next = moveSelectionBlock(view.state, dir);
                if (next && (next instanceof NodeSelection)) {
                    return apply(view, next);
                }
            }
            if (!node || node.isInline) {
                return false;
            }
            var beyond = Selection.findFrom($start, dir);
            return beyond ? apply(view, beyond) : true;
        }
        function stopNativeHorizontalDelete(view, dir) {
            var ref = view.state.selection;
            var $head = ref.$head;
            var $anchor = ref.$anchor;
            var empty = ref.empty;
            if (!$head || !$head.sameParent($anchor) || !$head.parent.isTextblock) {
                return true;
            }
            if (!empty) {
                return false;
            }
            if (view.endOfTextblock(dir > 0 ? "forward" : "backward")) {
                return true;
            }
            var nextNode = !$head.textOffset && (dir < 0 ? $head.nodeBefore : $head.nodeAfter);
            if (nextNode && !nextNode.isText) {
                var tr = view.state.tr;
                if (dir < 0) {
                    tr.delete($head.pos - nextNode.nodeSize, $head.pos);
                } else {
                    tr.delete($head.pos, $head.pos + nextNode.nodeSize);
                }
                view.dispatch(tr);
                return true;
            }
            return false;
        }
        function captureKeyDown(view, event) {
            var code = event.keyCode,
                mod = browser.mac ? event.metaKey : event.ctrlKey;
            if (code == 8) {
                return stopNativeHorizontalDelete(view, -1) || skipIgnoredNodesLeft(view);
            } else if (code == 46) {
                return stopNativeHorizontalDelete(view, 1) || skipIgnoredNodesRight(view);
            } else if (code == 13 || code == 27) {
                return true;
            } else if (code == 37) {
                return selectHorizontally(view, -1) || skipIgnoredNodesLeft(view);
            } else if (code == 39) {
                return selectHorizontally(view, 1) || skipIgnoredNodesRight(view);
            } else if (code == 38) {
                return selectVertically(view, -1);
            } else if (code == 40) {
                return selectVertically(view, 1);
            } else if (mod && !event.altKey && !event.shiftKey) {
                if (code == 66 || code == 73 || code == 89 || code == 90) {
                    return true;
                }
                if (browser.mac && code == 68) {
                    return stopNativeHorizontalDelete(view, 1) || skipIgnoredNodesRight(view);
                }
                if (browser.mac && code == 72) {
                    return stopNativeHorizontalDelete(view, -1) || skipIgnoredNodesLeft(view);
                }
            } else if (browser.mac && code == 68 && event.altKey && !mod && !event.shiftKey) {
                return stopNativeHorizontalDelete(view, 1) || skipIgnoredNodesRight(view);
            }
            return false;
        }
        exports.captureKeyDown = captureKeyDown;
        return module.exports;
    });

    $__System.registerDynamic("17", ["3", "7", "18"], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        var ref = $__require('3');
        var Fragment = ref.Fragment;
        var DOMParser = ref.DOMParser;
        var ref$1 = $__require('7');
        var Selection = ref$1.Selection;
        var ref$2 = $__require('18');
        var TrackMappings = ref$2.TrackMappings;
        var DOMChange = function(view, id, composing) {
            var this$1 = this;
            this.view = view;
            this.id = id;
            this.state = view.state;
            this.composing = composing;
            this.from = this.to = null;
            this.timeout = composing ? null : setTimeout(function() {
                return this$1.finish();
            }, 20);
            this.mappings = new TrackMappings(view.state);
        };
        DOMChange.prototype.addRange = function(from, to) {
            if (this.from == null) {
                this.from = from;
                this.to = to;
            } else {
                this.from = Math.min(from, this.from);
                this.to = Math.max(to, this.to);
            }
        };
        DOMChange.prototype.changedRange = function() {
            if (this.from == null) {
                return rangeAroundSelection(this.state.selection);
            }
            var $from = this.state.doc.resolve(this.from),
                $to = this.state.doc.resolve(this.to);
            var shared = $from.sharedDepth(this.to);
            return {
                from: $from.before(shared + 1),
                to: $to.after(shared + 1)
            };
        };
        DOMChange.prototype.finish = function(force) {
            clearTimeout(this.timeout);
            if (this.composing && !force) {
                return;
            }
            var range = this.changedRange();
            if (this.from == null) {
                this.view.docView.markDirty(range.from, range.to);
            } else {
                this.view.docView.markDirty(this.from, this.to);
            }
            var mapping = this.mappings.getMapping(this.view.state);
            this.destroy();
            if (mapping) {
                readDOMChange(this.view, mapping, this.state, range);
            }
            if (this.view.docView.dirty) {
                this.view.updateState(this.view.state);
            }
        };
        DOMChange.prototype.destroy = function() {
            this.mappings.destroy();
            this.view.inDOMChange = null;
        };
        DOMChange.prototype.compositionEnd = function() {
            var this$1 = this;
            if (this.composing) {
                this.composing = false;
                this.timeout = setTimeout(function() {
                    return this$1.finish();
                }, 50);
            }
        };
        DOMChange.start = function(view, composing) {
            if (view.inDOMChange) {
                if (composing) {
                    clearTimeout(view.inDOMChange.timeout);
                    view.inDOMChange.composing = true;
                }
            } else {
                var id = Math.floor(Math.random() * 0xffffffff);
                view.inDOMChange = new DOMChange(view, id, composing);
            }
        };
        exports.DOMChange = DOMChange;
        function parseBetween(view, oldState, from, to) {
            var ref = view.docView.domFromPos(from, -1);
            var parent = ref.node;
            var startOff = ref.offset;
            var ref$1 = view.docView.domFromPos(to, 1);
            var parentRight = ref$1.node;
            var endOff = ref$1.offset;
            if (parent != parentRight) {
                return null;
            }
            if (endOff == parent.childNodes.length) {
                for (var scan = parent; scan != view.content; ) {
                    if (scan.nextSibling) {
                        if (!scan.nextSibling.pmViewDesc) {
                            return null;
                        }
                        break;
                    }
                    scan = scan.parentNode;
                }
            }
            var domSel = view.root.getSelection(),
                find = null;
            if (domSel.anchorNode && view.content.contains(domSel.anchorNode)) {
                find = [{
                    node: domSel.anchorNode,
                    offset: domSel.anchorOffset
                }];
                if (!domSel.isCollapsed) {
                    find.push({
                        node: domSel.focusNode,
                        offset: domSel.focusOffset
                    });
                }
            }
            var startDoc = oldState.doc;
            var parser = view.someProp("domParser") || DOMParser.fromSchema(view.state.schema);
            var $from = startDoc.resolve(from);
            var sel = null,
                doc = parser.parse(parent, {
                    topNode: $from.parent.copy(),
                    topStart: $from.index(),
                    topOpen: true,
                    from: startOff,
                    to: endOff,
                    preserveWhitespace: true,
                    editableContent: true,
                    findPositions: find,
                    ruleFromNode: ruleFromNode
                });
            if (find && find[0].pos != null) {
                var anchor = find[0].pos,
                    head = find[1] && find[1].pos;
                if (head == null) {
                    head = anchor;
                }
                sel = {
                    anchor: anchor + from,
                    head: head + from
                };
            }
            return {
                doc: doc,
                sel: sel
            };
        }
        function ruleFromNode(dom) {
            var desc = dom.pmViewDesc;
            if (desc) {
                return desc.parseRule();
            } else if (dom.nodeName == "BR" && dom.parentNode && dom.parentNode.lastChild == dom) {
                return {ignore: true};
            }
        }
        function isAtEnd($pos, depth) {
            for (var i = depth || 0; i < $pos.depth; i++) {
                if ($pos.index(i) + 1 < $pos.node(i).childCount) {
                    return false;
                }
            }
            return $pos.parentOffset == $pos.parent.content.size;
        }
        function isAtStart($pos, depth) {
            for (var i = depth || 0; i < $pos.depth; i++) {
                if ($pos.index(0) > 0) {
                    return false;
                }
            }
            return $pos.parentOffset == 0;
        }
        function rangeAroundSelection(selection) {
            var $from = selection.$from;
            var $to = selection.$to;
            if ($from.sameParent($to) && $from.parent.isTextblock && $from.parentOffset && $to.parentOffset < $to.parent.content.size) {
                var startOff = Math.max(0, $from.parentOffset);
                var size = $from.parent.content.size;
                var endOff = Math.min(size, $to.parentOffset);
                if (startOff > 0) {
                    startOff = $from.parent.childBefore(startOff).offset;
                }
                if (endOff < size) {
                    var after = $from.parent.childAfter(endOff);
                    endOff = after.offset + after.node.nodeSize;
                }
                var nodeStart = $from.start();
                return {
                    from: nodeStart + startOff,
                    to: nodeStart + endOff
                };
            } else {
                for (var depth = 0; ; depth++) {
                    var fromStart = isAtStart($from, depth + 1),
                        toEnd = isAtEnd($to, depth + 1);
                    if (fromStart || toEnd || $from.index(depth) != $to.index(depth) || $to.node(depth).isTextblock) {
                        var from = $from.before(depth + 1),
                            to = $to.after(depth + 1);
                        if (fromStart && $from.index(depth) > 0) {
                            from -= $from.node(depth).child($from.index(depth) - 1).nodeSize;
                        }
                        if (toEnd && $to.index(depth) + 1 < $to.node(depth).childCount) {
                            to += $to.node(depth).child($to.index(depth) + 1).nodeSize;
                        }
                        return {
                            from: from,
                            to: to
                        };
                    }
                }
            }
        }
        function keyEvent(keyCode, key) {
            var event = document.createEvent("Event");
            event.initEvent("keydown", true, true);
            event.keyCode = keyCode;
            event.key = event.code = key;
            return event;
        }
        function readDOMChange(view, mapping, oldState, range) {
            var parseResult,
                doc = oldState.doc;
            for (; ; ) {
                parseResult = parseBetween(view, oldState, range.from, range.to);
                if (parseResult) {
                    break;
                }
                var $from$1 = doc.resolve(range.from),
                    $to$1 = doc.resolve(range.to);
                range = {
                    from: $from$1.depth ? $from$1.before() : 0,
                    to: $to$1.depth ? $to$1.after() : doc.content.size
                };
            }
            var parsed = parseResult.doc;
            var parsedSel = parseResult.sel;
            var compare = doc.slice(range.from, range.to);
            var change = findDiff(compare.content, parsed.content, range.from, oldState.selection.from);
            if (!change) {
                if (parsedSel) {
                    var sel = resolveSelection(view.state.doc, mapping, parsedSel);
                    if (!sel.eq(view.state.selection)) {
                        view.dispatch(view.state.tr.setSelection(sel));
                    }
                }
                return;
            }
            var $from = parsed.resolveNoCache(change.start - range.from);
            var $to = parsed.resolveNoCache(change.endB - range.from);
            var nextSel;
            if (!$from.sameParent($to) && $from.pos < parsed.content.size && (nextSel = Selection.findFrom(parsed.resolve($from.pos + 1), 1, true)) && nextSel.head == $to.pos && view.someProp("handleKeyDown", function(f) {
                    return f(view, keyEvent(13, "Enter"));
                })) {
                return;
            }
            if (oldState.selection.anchor > change.start && looksLikeJoin(doc, change.start, change.endA, $from, $to) && view.someProp("handleKeyDown", function(f) {
                    return f(view, keyEvent(8, "Backspace"));
                })) {
                return;
            }
            var from = mapping.map(change.start),
                to = mapping.map(change.endA, -1);
            var tr,
                storedMarks,
                markChange,
                $from1;
            if ($from.sameParent($to) && $from.parent.isTextblock) {
                if ($from.pos == $to.pos) {
                    tr = view.state.tr.delete(from, to);
                    var $start = doc.resolve(change.start);
                    if ($start.parentOffset < $start.parent.content.size) {
                        storedMarks = $start.marks(true);
                    }
                } else if (change.endA == change.endB && ($from1 = doc.resolve(change.start)) && (markChange = isMarkChange($from.parent.content.cut($from.parentOffset, $to.parentOffset), $from1.parent.content.cut($from1.parentOffset, change.endA - $from1.start())))) {
                    tr = view.state.tr;
                    if (markChange.type == "add") {
                        tr.addMark(from, to, markChange.mark);
                    } else {
                        tr.removeMark(from, to, markChange.mark);
                    }
                } else if ($from.parent.child($from.index()).isText && $from.index() == $to.index() - ($to.textOffset ? 0 : 1)) {
                    var text = $from.parent.textBetween($from.parentOffset, $to.parentOffset);
                    if (view.someProp("handleTextInput", function(f) {
                            return f(view, from, to, text);
                        })) {
                        return;
                    }
                    tr = view.state.tr.insertText(text, from, to);
                }
            }
            if (!tr) {
                tr = view.state.tr.replace(from, to, parsed.slice(change.start - range.from, change.endB - range.from));
            }
            if (parsedSel) {
                tr.setSelection(resolveSelection(tr.doc, mapping, parsedSel));
            }
            if (storedMarks) {
                tr.setStoredMarks(storedMarks);
            }
            view.dispatch(tr.scrollIntoView());
        }
        function resolveSelection(doc, mapping, parsedSel) {
            return Selection.between(doc.resolve(mapping.map(parsedSel.anchor)), doc.resolve(mapping.map(parsedSel.head)));
        }
        function isMarkChange(cur, prev) {
            var curMarks = cur.firstChild.marks,
                prevMarks = prev.firstChild.marks;
            var added = curMarks,
                removed = prevMarks,
                type,
                mark,
                update;
            for (var i = 0; i < prevMarks.length; i++) {
                added = prevMarks[i].removeFromSet(added);
            }
            for (var i$1 = 0; i$1 < curMarks.length; i$1++) {
                removed = curMarks[i$1].removeFromSet(removed);
            }
            if (added.length == 1 && removed.length == 0) {
                mark = added[0];
                type = "add";
                update = function(node) {
                    return node.mark(mark.addToSet(node.marks));
                };
            } else if (added.length == 0 && removed.length == 1) {
                mark = removed[0];
                type = "remove";
                update = function(node) {
                    return node.mark(mark.removeFromSet(node.marks));
                };
            } else {
                return null;
            }
            var updated = [];
            for (var i$2 = 0; i$2 < prev.childCount; i$2++) {
                updated.push(update(prev.child(i$2)));
            }
            if (Fragment.from(updated).eq(cur)) {
                return {
                    mark: mark,
                    type: type
                };
            }
        }
        function looksLikeJoin(old, start, end, $newStart, $newEnd) {
            if (!$newStart.parent.isTextblock || end - start <= $newEnd.pos - $newStart.pos || skipClosingAndOpening($newStart, true, false) < $newEnd.pos) {
                return false;
            }
            var $start = old.resolve(start);
            if ($start.parentOffset < $start.parent.content.size || !$start.parent.isTextblock) {
                return false;
            }
            var $next = old.resolve(skipClosingAndOpening($start, true, true));
            if (!$next.parent.isTextblock || $next.pos > end || skipClosingAndOpening($next, true, false) < end) {
                return false;
            }
            return $newStart.parent.content.cut($newStart.parentOffset).eq($next.parent.content);
        }
        function skipClosingAndOpening($pos, fromEnd, mayOpen) {
            var depth = $pos.depth,
                end = fromEnd ? $pos.end() : $pos.pos;
            while (depth > 0 && (fromEnd || $pos.indexAfter(depth) == $pos.node(depth).childCount)) {
                depth--;
                end++;
                fromEnd = false;
            }
            if (mayOpen) {
                var next = $pos.node(depth).maybeChild($pos.indexAfter(depth));
                while (next && !next.isLeaf) {
                    next = next.firstChild;
                    end++;
                }
            }
            return end;
        }
        function findDiff(a, b, pos, preferedStart) {
            var start = a.findDiffStart(b, pos);
            if (!start) {
                return null;
            }
            var ref = a.findDiffEnd(b, pos + a.size, pos + b.size);
            var endA = ref.a;
            var endB = ref.b;
            if (endA < start && a.size < b.size) {
                var move = preferedStart <= start && preferedStart >= endA ? start - preferedStart : 0;
                start -= move;
                endB = start + (endB - endA);
                endA = start;
            } else if (endB < start) {
                var move$1 = preferedStart <= start && preferedStart >= endB ? start - preferedStart : 0;
                start -= move$1;
                endA = start + (endA - endB);
                endB = start;
            }
            return {
                start: start,
                endA: endA,
                endB: endB
            };
        }
        return module.exports;
    });

    $__System.registerDynamic("19", ["3"], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        var ref = $__require('3');
        var Slice = ref.Slice;
        var Fragment = ref.Fragment;
        var DOMParser = ref.DOMParser;
        var DOMSerializer = ref.DOMSerializer;
        function toClipboard(view, range, dataTransfer) {
            var doc = view.state.doc,
                fullSlice = doc.slice(range.from, range.to, !range.node);
            var slice = fullSlice,
                context;
            if (!range.node) {
                var cut = Math.max(0, range.$from.sharedDepth(range.to) - 1);
                context = sliceContext(slice, cut);
                var content = slice.content;
                for (var i = 0; i < cut; i++) {
                    content = content.firstChild.content;
                }
                slice = new Slice(content, slice.openLeft - cut, slice.openRight - cut);
            }
            var serializer = view.someProp("clipboardSerializer") || DOMSerializer.fromSchema(view.state.schema);
            var dom = serializer.serializeFragment(slice.content),
                wrap = document.createElement("div");
            wrap.appendChild(dom);
            var child = wrap.firstChild.nodeType == 1 && wrap.firstChild;
            if (child) {
                if (range.node) {
                    child.setAttribute("data-pm-node-selection", true);
                } else {
                    child.setAttribute("data-pm-context", context);
                }
            }
            dataTransfer.clearData();
            dataTransfer.setData("text/html", wrap.innerHTML);
            dataTransfer.setData("text/plain", slice.content.textBetween(0, slice.content.size, "\n\n"));
            return fullSlice;
        }
        exports.toClipboard = toClipboard;
        var cachedCanUpdateClipboard = null;
        function canUpdateClipboard(dataTransfer) {
            if (cachedCanUpdateClipboard != null) {
                return cachedCanUpdateClipboard;
            }
            dataTransfer.setData("text/html", "<hr>");
            return cachedCanUpdateClipboard = dataTransfer.getData("text/html") == "<hr>";
        }
        exports.canUpdateClipboard = canUpdateClipboard;
        function fromClipboard(view, dataTransfer, plainText, $context) {
            var txt = dataTransfer.getData("text/plain");
            var html = dataTransfer.getData("text/html");
            if (!html && !txt) {
                return null;
            }
            var dom,
                inCode = $context.parent.type.spec.code;
            if ((plainText || inCode || !html) && txt) {
                view.someProp("transformPastedText", function(f) {
                    return txt = f(txt);
                });
                if (inCode) {
                    return new Slice(Fragment.from(view.state.schema.text(txt)), 0, 0);
                }
                dom = document.createElement("div");
                txt.split(/(?:\r\n?|\n)+/).forEach(function(block) {
                    dom.appendChild(document.createElement("p")).textContent = block;
                });
            } else {
                view.someProp("transformPastedHTML", function(f) {
                    return html = f(html);
                });
                dom = readHTML(html);
            }
            var parser = view.someProp("clipboardParser") || view.someProp("domParser") || DOMParser.fromSchema(view.state.schema);
            var slice = parser.parseSlice(dom, {preserveWhitespace: true}),
                context;
            if (dom.querySelector("[data-pm-node-selection]")) {
                slice = new Slice(slice.content, 0, 0);
            } else if (context = dom.querySelector("[data-pm-context]")) {
                slice = addContext(slice, context.getAttribute("data-pm-context"));
            } else {
                slice = normalizeSiblings(slice, $context);
            }
            return slice;
        }
        exports.fromClipboard = fromClipboard;
        function normalizeSiblings(slice, $context) {
            if (slice.content.childCount < 2) {
                return slice;
            }
            var loop = function(d) {
                var parent = $context.node(d);
                var match = parent.contentMatchAt($context.index(d));
                var lastWrap = (void 0),
                    result = [];
                slice.content.forEach(function(node) {
                    if (!result) {
                        return;
                    }
                    var wrap = match.findWrappingFor(node),
                        inLast;
                    if (!wrap) {
                        return result = null;
                    }
                    if (inLast = result.length && lastWrap.length && addToSibling(wrap, lastWrap, node, result[result.length - 1], 0)) {
                        result[result.length - 1] = inLast;
                    } else {
                        if (result.length) {
                            result[result.length - 1] = closeRight(result[result.length - 1], lastWrap.length);
                        }
                        var wrapped = withWrappers(node, wrap);
                        result.push(wrapped);
                        match = match.matchType(wrapped.type, wrapped.attrs);
                        lastWrap = wrap;
                    }
                });
                if (result) {
                    return {v: Slice.maxOpen(Fragment.from(result))};
                }
            };
            for (var d = $context.depth; d >= 0; d--) {
                var returned = loop(d);
                if (returned)
                    return returned.v;
            }
            return slice;
        }
        function withWrappers(node, wrap, from) {
            if (from === void 0)
                from = 0;
            for (var i = wrap.length - 1; i >= from; i--) {
                node = wrap[i].type.create(wrap[i].attrs, Fragment.from(node));
            }
            return node;
        }
        function addToSibling(wrap, lastWrap, node, sibling, depth) {
            if (depth < wrap.length && depth < lastWrap.length && wrap[depth].type == lastWrap[depth].type) {
                var inner = addToSibling(wrap, lastWrap, node, sibling.lastChild, depth + 1);
                if (inner) {
                    return sibling.copy(sibling.content.replaceChild(sibling.childCount - 1, inner));
                }
                var match = sibling.contentMatchAt(sibling.childCount);
                if (depth == wrap.length - 1 ? match.matchNode(node) : match.matchType(wrap[depth + 1].type, wrap[depth + 1].attrs)) {
                    return sibling.copy(sibling.content.append(Fragment.from(withWrappers(node, wrap, depth + 1))));
                }
            }
        }
        function closeRight(node, depth) {
            if (depth == 0) {
                return node;
            }
            var fragment = node.content.replaceChild(node.childCount - 1, closeRight(node.lastChild, depth - 1));
            var fill = node.contentMatchAt(node.childCount).fillBefore(Fragment.empty, true);
            return node.copy(fragment.append(fill));
        }
        var wrapMap = {
            thead: "table",
            colgroup: "table",
            col: "table colgroup",
            tr: "table tbody",
            td: "table tbody tr",
            th: "table tbody tr"
        };
        var detachedDoc = null;
        function readHTML(html) {
            var metas = /(\s*<meta [^>]*>)*/.exec(html);
            if (metas) {
                html = html.slice(metas[0].length);
            }
            var doc = detachedDoc || (detachedDoc = document.implementation.createHTMLDocument("title"));
            var elt = doc.createElement("div");
            var firstTag = /(?:<meta [^>]*>)*<([a-z][^>\s]+)/i.exec(html),
                wrap,
                depth = 0;
            if (wrap = firstTag && wrapMap[firstTag[1].toLowerCase()]) {
                var nodes = wrap.split(" ");
                html = nodes.map(function(n) {
                        return "<" + n + ">";
                    }).join("") + html + nodes.map(function(n) {
                        return "</" + n + ">";
                    }).reverse().join("");
                depth = nodes.length;
            }
            elt.innerHTML = html;
            for (var i = 0; i < depth; i++) {
                elt = elt.firstChild;
            }
            return elt;
        }
        function sliceContext(slice, depth) {
            var result = [],
                content = slice.content;
            for (var i = 0; i < depth; i++) {
                var node = content.firstChild;
                result.push(node.type.name, node.type.hasRequiredAttrs() ? node.attrs : null);
                content = node.content;
            }
            return JSON.stringify(result);
        }
        function addContext(slice, context) {
            if (!slice.size) {
                return slice;
            }
            var schema = slice.content.firstChild.type.schema,
                array;
            try {
                array = JSON.parse(context);
            } catch (e) {
                return slice;
            }
            var content = slice.content;
            var openLeft = slice.openLeft;
            var openRight = slice.openRight;
            for (var i = array.length - 2; i >= 0; i -= 2) {
                var type = schema.nodes[array[i]];
                if (!type || type.hasRequiredAttrs()) {
                    break;
                }
                content = Fragment.from(type.create(array[i + 1], content));
                openLeft++;
                openRight++;
            }
            return new Slice(content, openLeft, openRight);
        }
        return module.exports;
    });

    $__System.registerDynamic("18", ["7", "9"], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        var ref = $__require('7');
        var EditorState = ref.EditorState;
        var ref$1 = $__require('9');
        var Mapping = ref$1.Mapping;
        var TrackedRecord = function(prev, mapping, state) {
            this.prev = prev;
            this.mapping = mapping;
            this.state = state;
        };
        var TrackMappings = function(state) {
            this.seen = [new TrackedRecord(null, null, state)];
            EditorState.addApplyListener(this.track = this.track.bind(this));
        };
        TrackMappings.prototype.destroy = function() {
            EditorState.removeApplyListener(this.track);
        };
        TrackMappings.prototype.find = function(state) {
            var this$1 = this;
            for (var i = this.seen.length - 1; i >= 0; i--) {
                var record = this$1.seen[i];
                if (record.state == state) {
                    return record;
                }
            }
        };
        TrackMappings.prototype.track = function(old, tr, state) {
            var found = this.seen.length < 200 ? this.find(old) : null;
            if (found) {
                this.seen.push(new TrackedRecord(found, tr.docChanged ? tr.mapping : null, state));
            }
        };
        TrackMappings.prototype.getMapping = function(state) {
            var found = this.find(state);
            if (!found) {
                return null;
            }
            var mappings = [];
            for (var rec = found; rec; rec = rec.prev) {
                if (rec.mapping) {
                    mappings.push(rec.mapping);
                }
            }
            var result = new Mapping;
            for (var i = mappings.length - 1; i >= 0; i--) {
                result.appendMapping(mappings[i]);
            }
            return result;
        };
        exports.TrackMappings = TrackMappings;
        return module.exports;
    });

    $__System.registerDynamic("1a", ["7", "15", "16", "17", "19", "18"], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        var ref = $__require('7');
        var Selection = ref.Selection;
        var NodeSelection = ref.NodeSelection;
        var TextSelection = ref.TextSelection;
        var browser = $__require('15');
        var ref$1 = $__require('16');
        var captureKeyDown = ref$1.captureKeyDown;
        var ref$2 = $__require('17');
        var DOMChange = ref$2.DOMChange;
        var ref$3 = $__require('19');
        var fromClipboard = ref$3.fromClipboard;
        var toClipboard = ref$3.toClipboard;
        var canUpdateClipboard = ref$3.canUpdateClipboard;
        var ref$4 = $__require('18');
        var TrackMappings = ref$4.TrackMappings;
        var handlers = {},
            editHandlers = {};
        function initInput(view) {
            view.shiftKey = false;
            view.mouseDown = null;
            view.dragging = null;
            view.inDOMChange = null;
            view.mutationObserver = window.MutationObserver && new window.MutationObserver(function(mutations) {
                    return registerMutations(view, mutations);
                });
            startObserving(view);
            var loop = function(event) {
                var handler = handlers[event];
                view.content.addEventListener(event, function(event) {
                    if (eventBelongsToView(view, event) && !runCustomHandler(view, event) && (view.editable || !(event.type in editHandlers))) {
                        handler(view, event);
                    }
                });
            };
            for (var event in handlers)
                loop(event);
            view.extraHandlers = Object.create(null);
            ensureListeners(view);
        }
        exports.initInput = initInput;
        function destroyInput(view) {
            stopObserving(view);
            if (view.inDOMChange) {
                view.inDOMChange.destroy();
            }
            if (view.dragging) {
                view.dragging.destroy();
            }
        }
        exports.destroyInput = destroyInput;
        function ensureListeners(view) {
            view.someProp("handleDOMEvents", function(handlers) {
                for (var type in handlers) {
                    if (!view.extraHandlers[type] && !handlers.hasOwnProperty(type)) {
                        view.extraHandlers[type] = true;
                        view.content.addEventListener(type, function(event) {
                            return runCustomHandler(view, event);
                        });
                    }
                }
            });
        }
        exports.ensureListeners = ensureListeners;
        function runCustomHandler(view, event) {
            return view.someProp("handleDOMEvents", function(handlers) {
                var handler = handlers[event.type];
                return handler ? handler(view, event) : false;
            });
        }
        function eventBelongsToView(view, event) {
            if (!event.bubbles) {
                return true;
            }
            if (event.defaultPrevented) {
                return false;
            }
            for (var node = event.target; node != view.content; node = node.parentNode) {
                if (!node || node.nodeType == 11 || (node.pmViewDesc && node.pmViewDesc.stopEvent(event))) {
                    return false;
                }
            }
            return true;
        }
        function dispatchEvent(view, event) {
            if (!runCustomHandler(view, event) && handlers[event.type] && (view.editable || !(event.type in editHandlers))) {
                handlers[event.type](view, event);
            }
        }
        exports.dispatchEvent = dispatchEvent;
        editHandlers.keydown = function(view, event) {
            if (event.keyCode == 16) {
                view.shiftKey = true;
            }
            if (view.inDOMChange) {
                return;
            }
            if (view.someProp("handleKeyDown", function(f) {
                    return f(view, event);
                }) || captureKeyDown(view, event)) {
                event.preventDefault();
            } else {
                view.selectionReader.poll();
            }
        };
        editHandlers.keyup = function(view, e) {
            if (e.keyCode == 16) {
                view.shiftKey = false;
            }
        };
        editHandlers.keypress = function(view, event) {
            if (view.inDOMChange || !event.charCode || event.ctrlKey && !event.altKey || browser.mac && event.metaKey) {
                return;
            }
            if (view.someProp("handleKeyPress", function(f) {
                    return f(view, event);
                })) {
                event.preventDefault();
                return;
            }
            var ref = view.state.selection;
            var node = ref.node;
            var $from = ref.$from;
            var $to = ref.$to;
            if (node || !$from.sameParent($to)) {
                var text = String.fromCharCode(event.charCode);
                if (!view.someProp("handleTextInput", function(f) {
                        return f(view, $from.pos, $to.pos, text);
                    })) {
                    view.dispatch(view.state.tr.insertText(text).scrollIntoView());
                }
                event.preventDefault();
            }
        };
        function eventCoords(event) {
            return {
                left: event.clientX,
                top: event.clientY
            };
        }
        var lastClick = {
                time: 0,
                x: 0,
                y: 0
            },
            oneButLastClick = lastClick;
        function isNear(event, click) {
            var dx = click.x - event.clientX,
                dy = click.y - event.clientY;
            return dx * dx + dy * dy < 100;
        }
        function runHandlerOnContext(view, propName, pos, inside, event) {
            if (inside == -1) {
                return false;
            }
            var $pos = view.state.doc.resolve(inside);
            var loop = function(i) {
                if (view.someProp(propName, function(f) {
                        return i > $pos.depth ? f(view, pos, $pos.nodeAfter, $pos.before(i), event, true) : f(view, pos, $pos.node(i), $pos.before(i), event, false);
                    })) {
                    return {v: true};
                }
            };
            for (var i = $pos.depth + 1; i > 0; i--) {
                var returned = loop(i);
                if (returned)
                    return returned.v;
            }
            return false;
        }
        function updateSelection(view, selection, origin) {
            view.focus();
            var tr = view.state.tr.setSelection(selection);
            if (origin == "pointer") {
                tr.setMeta("pointer", true);
            }
            view.dispatch(tr);
        }
        function selectClickedLeaf(view, inside) {
            if (inside == -1) {
                return false;
            }
            var $pos = view.state.doc.resolve(inside),
                node = $pos.nodeAfter;
            if (node && node.isLeaf && NodeSelection.isSelectable(node)) {
                updateSelection(view, new NodeSelection($pos), "pointer");
                return true;
            }
            return false;
        }
        function selectClickedNode(view, inside) {
            if (inside == -1) {
                return false;
            }
            var ref = view.state.selection;
            var selectedNode = ref.node;
            var $from = ref.$from;
            var selectAt;
            var $pos = view.state.doc.resolve(inside);
            for (var i = $pos.depth + 1; i > 0; i--) {
                var node = i > $pos.depth ? $pos.nodeAfter : $pos.node(i);
                if (NodeSelection.isSelectable(node)) {
                    if (selectedNode && $from.depth > 0 && i >= $from.depth && $pos.before($from.depth + 1) == $from.pos) {
                        selectAt = $pos.before($from.depth);
                    } else {
                        selectAt = $pos.before(i);
                    }
                    break;
                }
            }
            if (selectAt != null) {
                updateSelection(view, NodeSelection.create(view.state.doc, selectAt), "pointer");
                return true;
            } else {
                return false;
            }
        }
        function handleSingleClick(view, pos, inside, event) {
            return runHandlerOnContext(view, "handleClickOn", pos, inside, event) || view.someProp("handleClick", function(f) {
                    return f(view, pos, event);
                }) || selectClickedLeaf(view, inside);
        }
        function handleDoubleClick(view, pos, inside, event) {
            return runHandlerOnContext(view, "handleDoubleClickOn", pos, inside, event) || view.someProp("handleDoubleClick", function(f) {
                    return f(view, pos, event);
                });
        }
        function handleTripleClick(view, pos, inside, event) {
            return runHandlerOnContext(view, "handleTripleClickOn", pos, inside, event) || view.someProp("handleTripleClick", function(f) {
                    return f(view, pos, event);
                }) || defaultTripleClick(view, inside);
        }
        function defaultTripleClick(view, inside) {
            var doc = view.state.doc;
            if (inside == -1) {
                if (doc.isTextblock) {
                    updateSelection(view, TextSelection.create(doc, 0, doc.content.size), "pointer");
                    return true;
                }
                return false;
            }
            var $pos = doc.resolve(inside);
            for (var i = $pos.depth + 1; i > 0; i--) {
                var node = i > $pos.depth ? $pos.nodeAfter : $pos.node(i);
                var nodePos = $pos.before(i);
                if (node.isTextblock) {
                    updateSelection(view, TextSelection.create(doc, nodePos + 1, nodePos + 1 + node.content.size), "pointer");
                } else if (NodeSelection.isSelectable(node)) {
                    updateSelection(view, NodeSelection.create(doc, nodePos), "pointer");
                } else {
                    continue;
                }
                return true;
            }
        }
        function forceDOMFlush(view) {
            if (!view.inDOMChange) {
                return false;
            }
            view.inDOMChange.finish(true);
            return true;
        }
        var selectNodeModifier = browser.mac ? "metaKey" : "ctrlKey";
        handlers.mousedown = function(view, event) {
            var flushed = forceDOMFlush(view);
            var now = Date.now(),
                type;
            if (now - lastClick.time >= 500 || !isNear(event, lastClick) || event[selectNodeModifier]) {
                type = "singleClick";
            } else if (now - oneButLastClick.time >= 600 || !isNear(event, oneButLastClick)) {
                type = "doubleClick";
            } else {
                type = "tripleClick";
            }
            oneButLastClick = lastClick;
            lastClick = {
                time: now,
                x: event.clientX,
                y: event.clientY
            };
            var pos = view.posAtCoords(eventCoords(event));
            if (!pos) {
                return;
            }
            if (type == "singleClick") {
                view.mouseDown = new MouseDown(view, pos, event, flushed);
            } else if ((type == "doubleClick" ? handleDoubleClick : handleTripleClick)(view, pos.pos, pos.inside, event)) {
                event.preventDefault();
            } else {
                view.selectionReader.poll("pointer");
            }
        };
        var MouseDown = function(view, pos, event, flushed) {
            var this$1 = this;
            this.view = view;
            this.pos = pos;
            this.flushed = flushed;
            this.selectNode = event[selectNodeModifier];
            this.allowDefault = event.shiftKey;
            var targetNode,
                targetPos;
            if (pos.inside > -1) {
                targetNode = view.state.doc.nodeAt(pos.inside);
                targetPos = pos.inside;
            } else {
                var $pos = view.state.doc.resolve(pos.pos);
                targetNode = $pos.parent;
                targetPos = $pos.depth ? $pos.before() : 0;
            }
            this.mightDrag = (targetNode.type.spec.draggable || targetNode == view.state.selection.node) ? {
                node: targetNode,
                pos: targetPos
            } : null;
            this.target = flushed ? null : event.target;
            if (this.target && this.mightDrag) {
                stopObserving(this.view);
                this.target.draggable = true;
                if (browser.gecko && (this.setContentEditable = !this.target.hasAttribute("contentEditable"))) {
                    setTimeout(function() {
                        return this$1.target.setAttribute("contentEditable", "false");
                    }, 20);
                }
                startObserving(this.view);
            }
            view.root.addEventListener("mouseup", this.up = this.up.bind(this));
            view.root.addEventListener("mousemove", this.move = this.move.bind(this));
            view.selectionReader.poll("pointer");
        };
        MouseDown.prototype.done = function() {
            this.view.root.removeEventListener("mouseup", this.up);
            this.view.root.removeEventListener("mousemove", this.move);
            if (this.mightDrag && this.target) {
                stopObserving(this.view);
                this.target.draggable = false;
                if (browser.gecko && this.setContentEditable) {
                    this.target.removeAttribute("contentEditable");
                }
                startObserving(this.view);
            }
        };
        MouseDown.prototype.up = function(event) {
            this.done();
            if (!this.view.content.contains(event.target.nodeType == 3 ? event.target.parentNode : event.target)) {
                return;
            }
            if (this.allowDefault) {
                this.view.selectionReader.poll("pointer");
            } else if (this.selectNode ? selectClickedNode(this.view, this.pos.inside) : handleSingleClick(this.view, this.pos.pos, this.pos.inside, event)) {
                event.preventDefault();
            } else if (this.flushed) {
                updateSelection(this.view, Selection.near(this.view.state.doc.resolve(this.pos.pos)), "pointer");
                event.preventDefault();
            } else {
                this.view.selectionReader.poll("pointer");
            }
        };
        MouseDown.prototype.move = function(event) {
            if (!this.allowDefault && (Math.abs(this.x - event.clientX) > 4 || Math.abs(this.y - event.clientY) > 4)) {
                this.allowDefault = true;
            }
            this.view.selectionReader.poll("pointer");
        };
        handlers.touchdown = function(view) {
            forceDOMFlush(view);
            view.selectionReader.poll("pointer");
        };
        handlers.contextmenu = function(view, e) {
            forceDOMFlush(view);
            var pos = view.posAtCoords(eventCoords(e));
            if (pos && view.someProp("handleContextMenu", function(f) {
                    return f(view, pos.pos, e);
                })) {
                e.preventDefault();
            }
        };
        editHandlers.compositionstart = editHandlers.compositionupdate = function(view) {
            DOMChange.start(view, true);
            if (view.state.storedMarks) {
                view.inDOMChange.finish(true);
            }
        };
        editHandlers.compositionend = function(view, e) {
            if (!view.inDOMChange) {
                if (e.data) {
                    DOMChange.start(view, true);
                } else {
                    return;
                }
            }
            view.inDOMChange.compositionEnd();
        };
        var observeOptions = {
            childList: true,
            characterData: true,
            attributes: true,
            subtree: true
        };
        function startObserving(view) {
            if (view.mutationObserver) {
                view.mutationObserver.observe(view.content, observeOptions);
            }
        }
        exports.startObserving = startObserving;
        function stopObserving(view) {
            if (view.mutationObserver) {
                view.mutationObserver.disconnect();
            }
        }
        exports.stopObserving = stopObserving;
        function registerMutations(view, mutations) {
            if (view.editable) {
                for (var i = 0; i < mutations.length; i++) {
                    var mut = mutations[i],
                        desc = view.docView.nearestDesc(mut.target);
                    if (mut.type == "attributes" && (desc == view.docView || mut.attributeName == "contenteditable")) {
                        continue;
                    }
                    if (!desc || desc.ignoreMutation(mut)) {
                        continue;
                    }
                    var from = (void 0),
                        to = (void 0);
                    if (mut.type == "childList") {
                        var fromOffset = mut.previousSibling && mut.previousSibling.parentNode == mut.target ? Array.prototype.indexOf.call(mut.target.childNodes, desc.previousSibling) + 1 : 0;
                        from = desc.localPosFromDOM(mut.target, fromOffset, -1);
                        var toOffset = mut.nextSibling && mut.nextSibling.parentNode == mut.target ? Array.prototype.indexOf.call(mut.target.childNodes, desc.nextSibling) : mut.target.childNodes.length;
                        to = desc.localPosFromDOM(mut.target, toOffset, 1);
                    } else if (mut.type == "attributes") {
                        from = desc.posAtStart - desc.border;
                        to = desc.posAtEnd + desc.border;
                    } else {
                        from = desc.posAtStart;
                        to = desc.posAtEnd;
                    }
                    DOMChange.start(view);
                    view.inDOMChange.addRange(from, to);
                }
            }
        }
        editHandlers.input = function(view) {
            return DOMChange.start(view);
        };
        handlers.copy = editHandlers.cut = function(view, e) {
            var sel = view.state.selection,
                cut = e.type == "cut";
            if (sel.empty) {
                return;
            }
            if (!e.clipboardData || !canUpdateClipboard(e.clipboardData)) {
                if (cut && browser.ie && browser.ie_version <= 11) {
                    DOMChange.start(view);
                }
                return;
            }
            toClipboard(view, sel, e.clipboardData);
            e.preventDefault();
            if (cut) {
                view.dispatch(view.state.tr.deleteRange(sel.from, sel.to).scrollIntoView());
            }
        };
        function sliceSingleNode(slice) {
            return slice.openLeft == 0 && slice.openRight == 0 && slice.content.childCount == 1 ? slice.content.firstChild : null;
        }
        editHandlers.paste = function(view, e) {
            if (!e.clipboardData) {
                if (browser.ie && browser.ie_version <= 11) {
                    DOMChange.start(view);
                }
                return;
            }
            var slice = fromClipboard(view, e.clipboardData, view.shiftKey, view.state.selection.$from);
            if (slice) {
                e.preventDefault();
                view.someProp("transformPasted", function(f) {
                    slice = f(slice);
                });
                var singleNode = sliceSingleNode(slice);
                var tr = singleNode ? view.state.tr.replaceSelectionWith(singleNode) : view.state.tr.replaceSelection(slice);
                view.dispatch(tr.scrollIntoView());
            }
        };
        var Dragging = function(state, slice, range, move) {
            this.slice = slice;
            this.range = range;
            this.move = move && new TrackMappings(state);
        };
        Dragging.prototype.destroy = function() {
            if (this.move) {
                this.move.destroy();
            }
        };
        function clearDragging(view) {
            if (view.dragging) {
                view.dragging.destroy();
                view.dragging = null;
            }
        }
        function dropPos(slice, $pos) {
            if (!slice || !slice.content.size) {
                return $pos.pos;
            }
            var content = slice.content;
            for (var i = 0; i < slice.openLeft; i++) {
                content = content.firstChild.content;
            }
            for (var d = $pos.depth; d >= 0; d--) {
                var bias = d == $pos.depth ? 0 : $pos.pos <= ($pos.start(d + 1) + $pos.end(d + 1)) / 2 ? -1 : 1;
                var insertPos = $pos.index(d) + (bias > 0 ? 1 : 0);
                if ($pos.node(d).canReplace(insertPos, insertPos, content)) {
                    return bias == 0 ? $pos.pos : bias < 0 ? $pos.before(d + 1) : $pos.after(d + 1);
                }
            }
            return $pos.pos;
        }
        handlers.dragstart = function(view, e) {
            var mouseDown = view.mouseDown;
            if (mouseDown) {
                mouseDown.done();
            }
            if (!e.dataTransfer) {
                return;
            }
            var sel = view.state.selection,
                draggedRange;
            var pos = sel.empty ? null : view.posAtCoords(eventCoords(e));
            if (pos != null && pos.pos >= sel.from && pos.pos <= sel.to) {
                draggedRange = sel;
            } else if (mouseDown && mouseDown.mightDrag) {
                draggedRange = NodeSelection.create(view.state.doc, mouseDown.mightDrag.pos);
            }
            if (draggedRange) {
                var slice = toClipboard(view, draggedRange, e.dataTransfer);
                view.dragging = new Dragging(view.state, slice, draggedRange, !e.ctrlKey);
            }
        };
        handlers.dragend = function(view) {
            window.setTimeout(function() {
                return clearDragging(view);
            }, 50);
        };
        editHandlers.dragover = editHandlers.dragenter = function(_, e) {
            return e.preventDefault();
        };
        editHandlers.drop = function(view, e) {
            var dragging = view.dragging;
            clearDragging(view);
            if (!e.dataTransfer) {
                return;
            }
            var $mouse = view.state.doc.resolve(view.posAtCoords(eventCoords(e)).pos);
            if (!$mouse) {
                return;
            }
            var slice = dragging && dragging.slice || fromClipboard(view, e.dataTransfer, false, $mouse);
            if (!slice) {
                return;
            }
            var insertPos = dropPos(slice, view.state.doc.resolve($mouse.pos));
            e.preventDefault();
            var tr = view.state.tr;
            if (dragging && dragging.move) {
                var ref = dragging.range;
                var from = ref.from;
                var to = ref.to;
                var mapping = dragging.move.getMapping(view.state);
                if (mapping) {
                    tr.deleteRange(mapping.map(from, 1), mapping.map(to, -1));
                }
            }
            view.someProp("transformPasted", function(f) {
                slice = f(slice);
            });
            var pos = tr.mapping.map(insertPos);
            var isNode = slice.openLeft == 0 && slice.openRight == 0 && slice.content.childCount == 1;
            if (isNode) {
                tr.replaceRangeWith(pos, pos, slice.content.firstChild);
            } else {
                tr.replaceRange(pos, pos, slice);
            }
            var $pos = tr.doc.resolve(pos);
            if (isNode && NodeSelection.isSelectable(slice.content.firstChild) && $pos.nodeAfter && $pos.nodeAfter.sameMarkup(slice.content.firstChild)) {
                tr.setSelection(new NodeSelection($pos));
            } else {
                tr.setSelection(Selection.between($pos, tr.doc.resolve(tr.mapping.map(insertPos))));
            }
            view.focus();
            view.dispatch(tr);
        };
        handlers.focus = function(view, event) {
            if (!view.focused) {
                view.content.classList.add("ProseMirror-focused");
                view.focused = true;
            }
            view.someProp("onFocus", function(f) {
                f(view, event);
            });
        };
        handlers.blur = function(view, event) {
            if (view.focused) {
                view.content.classList.remove("ProseMirror-focused");
                view.focused = false;
            }
            view.someProp("onBlur", function(f) {
                f(view, event);
            });
        };
        for (var prop in editHandlers) {
            handlers[prop] = editHandlers[prop];
        }
        return module.exports;
    });

    $__System.registerDynamic("15", [], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        var result = module.exports = {};
        if (typeof navigator != "undefined") {
            var ie_upto10 = /MSIE \d/.test(navigator.userAgent);
            var ie_11up = /Trident\/(?:[7-9]|\d{2,})\..*rv:(\d+)/.exec(navigator.userAgent);
            result.mac = /Mac/.test(navigator.platform);
            result.ie = ie_upto10 || !!ie_11up;
            result.ie_version = ie_upto10 ? document.documentMode || 6 : ie_11up && +ie_11up[1];
            result.gecko = /gecko\/\d/i.test(navigator.userAgent);
            result.ios = /AppleWebKit/.test(navigator.userAgent) && /Mobile\/\w+/.test(navigator.userAgent);
            result.webkit = 'WebkitAppearance' in document.documentElement.style;
        }
        return module.exports;
    });

    $__System.registerDynamic("1b", ["7", "15"], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        var ref = $__require('7');
        var Selection = ref.Selection;
        var NodeSelection = ref.NodeSelection;
        var browser = $__require('15');
        var SelectionReader = function(view) {
            var this$1 = this;
            this.view = view;
            this.lastAnchorNode = this.lastHeadNode = this.lastAnchorOffset = this.lastHeadOffset = null;
            this.lastSelection = view.state.selection;
            this.poller = poller(this);
            view.content.addEventListener("focus", function() {
                return this$1.poller.start();
            });
            view.content.addEventListener("blur", function() {
                return this$1.poller.stop();
            });
            if (!view.editable) {
                this.poller.start();
            }
        };
        SelectionReader.prototype.destroy = function() {
            this.poller.stop();
        };
        SelectionReader.prototype.poll = function(origin) {
            this.poller.poll(origin);
        };
        SelectionReader.prototype.editableChanged = function() {
            if (!this.view.editable) {
                this.poller.start();
            } else if (!this.view.hasFocus()) {
                this.poller.stop();
            }
        };
        SelectionReader.prototype.domChanged = function() {
            var sel = this.view.root.getSelection();
            return sel.anchorNode != this.lastAnchorNode || sel.anchorOffset != this.lastAnchorOffset || sel.focusNode != this.lastHeadNode || sel.focusOffset != this.lastHeadOffset;
        };
        SelectionReader.prototype.storeDOMState = function(selection) {
            var sel = this.view.root.getSelection();
            this.lastAnchorNode = sel.anchorNode;
            this.lastAnchorOffset = sel.anchorOffset;
            this.lastHeadNode = sel.focusNode;
            this.lastHeadOffset = sel.focusOffset;
            this.lastSelection = selection;
        };
        SelectionReader.prototype.readFromDOM = function(origin) {
            if (!this.view.hasFocus() || this.view.inDOMChange || !this.domChanged()) {
                return;
            }
            var domSel = this.view.root.getSelection(),
                doc = this.view.state.doc;
            var nearestDesc = this.view.docView.nearestDesc(domSel.focusNode);
            if (!nearestDesc.size) {
                this.storeDOMState();
                return;
            }
            var head = this.view.docView.posFromDOM(domSel.focusNode, domSel.focusOffset);
            var $head = doc.resolve(head),
                $anchor,
                selection;
            if (domSel.isCollapsed) {
                $anchor = $head;
                while (nearestDesc && !nearestDesc.node) {
                    nearestDesc = nearestDesc.parent;
                }
                if (nearestDesc && nearestDesc.node.isLeaf && NodeSelection.isSelectable(nearestDesc.node)) {
                    var pos = nearestDesc.posAtStart;
                    selection = new NodeSelection(head == pos ? $head : doc.resolve(pos));
                }
            } else {
                $anchor = doc.resolve(this.view.docView.posFromDOM(domSel.anchorNode, domSel.anchorOffset));
            }
            if (!selection) {
                var bias = this.view.state.selection.head != null && this.view.state.selection.head < $head.pos ? 1 : -1;
                selection = Selection.between($anchor, $head, bias);
                if (bias == -1 && selection.node) {
                    selection = Selection.between($anchor, $head, 1);
                }
            }
            if ($head.pos == selection.head && $anchor.pos == selection.anchor) {
                this.storeDOMState(selection);
            }
            var tr = this.view.state.tr.setSelection(selection);
            if (origin == "pointer") {
                tr.setMeta("pointer", true);
            }
            this.view.dispatch(tr);
        };
        exports.SelectionReader = SelectionReader;
        var SelectionChangePoller = function(reader) {
            var this$1 = this;
            this.listening = false;
            this.curOrigin = null;
            this.originTime = 0;
            this.readFunc = function() {
                return reader.readFromDOM(this$1.originTime > Date.now() - 50 ? this$1.curOrigin : null);
            };
        };
        SelectionChangePoller.prototype.poll = function(origin) {
            this.curOrigin = origin;
            this.originTime = Date.now();
        };
        SelectionChangePoller.prototype.start = function() {
            if (!this.listening) {
                document.addEventListener("selectionchange", this.readFunc);
                this.listening = true;
            }
        };
        SelectionChangePoller.prototype.stop = function() {
            if (this.listening) {
                document.removeEventListener("selectionchange", this.readFunc);
                this.listening = false;
            }
        };
        var TimeoutPoller = function(reader) {
            this.polling = null;
            this.reader = reader;
            this.pollFunc = this.doPoll.bind(this, null);
        };
        TimeoutPoller.prototype.doPoll = function(origin) {
            var view = this.reader.view;
            if (view.focused || !view.editable) {
                this.reader.readFromDOM(origin);
                this.polling = setTimeout(this.pollFunc, 100);
            } else {
                this.polling = null;
            }
        };
        TimeoutPoller.prototype.poll = function(origin) {
            clearTimeout(this.polling);
            this.polling = setTimeout(origin ? this.doPoll.bind(this, origin) : this.pollFunc, 0);
        };
        TimeoutPoller.prototype.start = function() {
            if (this.polling == null) {
                this.poll();
            }
        };
        TimeoutPoller.prototype.stop = function() {
            clearTimeout(this.polling);
            this.polling = null;
        };
        function poller(reader) {
            return new ("onselectionchange" in document ? SelectionChangePoller : TimeoutPoller)(reader);
        }
        function selectionToDOM(view, sel, takeFocus) {
            syncNodeSelection(view, sel);
            if (!view.hasFocus()) {
                if (!takeFocus) {
                    return;
                } else if (browser.gecko && view.editable) {
                    view.content.focus();
                }
            }
            var reader = view.selectionReader;
            if (sel.eq(reader.lastSelection) && !reader.domChanged()) {
                return;
            }
            var anchor = sel.anchor;
            var head = sel.head;
            var resetEditable;
            if (anchor == null) {
                anchor = sel.from;
                head = sel.to;
                if (browser.webkit && sel.node.isBlock) {
                    var desc = view.docView.descAt(sel.from);
                    if (!desc.contentDOM && desc.dom.contentEditable == "false") {
                        resetEditable = desc.dom;
                        desc.dom.contentEditable = "true";
                    }
                }
            }
            view.docView.setSelection(anchor, head, view.root);
            if (resetEditable) {
                resetEditable.contentEditable = "false";
            }
            reader.storeDOMState(sel);
        }
        exports.selectionToDOM = selectionToDOM;
        function syncNodeSelection(view, sel) {
            if (sel instanceof NodeSelection) {
                var desc = view.docView.descAt(sel.from);
                if (desc != view.lastSelectedViewDesc) {
                    clearNodeSelection(view);
                    if (desc) {
                        desc.selectNode();
                    }
                    view.lastSelectedViewDesc = desc;
                }
            } else {
                clearNodeSelection(view);
            }
        }
        function clearNodeSelection(view) {
            if (view.lastSelectedViewDesc) {
                view.lastSelectedViewDesc.deselectNode();
                view.lastSelectedViewDesc = null;
            }
        }
        return module.exports;
    });

    $__System.registerDynamic("1c", [], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        function compareObjs(a, b) {
            if (a == b) {
                return true;
            }
            for (var p in a) {
                if (a[p] !== b[p]) {
                    return false;
                }
            }
            for (var p$1 in b) {
                if (!(p$1 in a)) {
                    return false;
                }
            }
            return true;
        }
        var WidgetType = function(widget, options) {
            if (widget.nodeType != 1) {
                var wrap = document.createElement("span");
                wrap.appendChild(widget);
                widget = wrap;
            }
            widget.contentEditable = false;
            widget.classList.add("ProseMirror-widget");
            this.widget = widget;
            this.options = options || noOptions;
        };
        WidgetType.prototype.map = function(mapping, span, offset, oldOffset) {
            var ref = mapping.mapResult(span.from + oldOffset, this.options.associative == "left" ? -1 : 1);
            var pos = ref.pos;
            var deleted = ref.deleted;
            return deleted ? null : new Decoration(pos - offset, pos - offset, this);
        };
        WidgetType.prototype.valid = function() {
            return true;
        };
        WidgetType.prototype.eq = function(other) {
            return this == other || (other instanceof WidgetType && (this.widget == other.widget || this.options.key) && compareObjs(this.options, other.options));
        };
        var InlineType = function(attrs, options) {
            this.options = options || noOptions;
            this.attrs = attrs;
        };
        InlineType.prototype.map = function(mapping, span, offset, oldOffset) {
            var from = mapping.map(span.from + oldOffset, this.options.inclusiveLeft ? -1 : 1) - offset;
            var to = mapping.map(span.to + oldOffset, this.options.inclusiveRight ? 1 : -1) - offset;
            return from >= to ? null : new Decoration(from, to, this);
        };
        InlineType.prototype.valid = function(_, span) {
            return span.from < span.to;
        };
        InlineType.prototype.eq = function(other) {
            return this == other || (other instanceof InlineType && compareObjs(this.attrs, other.attrs) && compareObjs(this.options, other.options));
        };
        InlineType.is = function(span) {
            return span.type instanceof InlineType;
        };
        var NodeType = function(attrs, options) {
            this.attrs = attrs;
            this.options = options || noOptions;
        };
        NodeType.prototype.map = function(mapping, span, offset, oldOffset) {
            var from = mapping.mapResult(span.from + oldOffset, 1);
            if (from.deleted) {
                return null;
            }
            var to = mapping.mapResult(span.to + oldOffset, -1);
            if (to.deleted || to.pos <= from.pos) {
                return null;
            }
            return new Decoration(from.pos - offset, to.pos - offset, this);
        };
        NodeType.prototype.valid = function(node, span) {
            var ref = node.content.findIndex(span.from);
            var index = ref.index;
            var offset = ref.offset;
            return offset == span.from && offset + node.child(index).nodeSize == span.to;
        };
        NodeType.prototype.eq = function(other) {
            return this == other || (other instanceof NodeType && compareObjs(this.attrs, other.attrs) && compareObjs(this.options, other.options));
        };
        var Decoration = function(from, to, type) {
            this.from = from;
            this.to = to;
            this.type = type;
        };
        var prototypeAccessors = {options: {}};
        Decoration.prototype.copy = function(from, to) {
            return new Decoration(from, to, this.type);
        };
        Decoration.prototype.eq = function(other) {
            return this.type.eq(other.type) && this.from == other.from && this.to == other.to;
        };
        Decoration.prototype.map = function(mapping, offset, oldOffset) {
            return this.type.map(mapping, this, offset, oldOffset);
        };
        Decoration.widget = function(pos, dom, options) {
            return new Decoration(pos, pos, new WidgetType(dom, options));
        };
        Decoration.inline = function(from, to, attrs, options) {
            return new Decoration(from, to, new InlineType(attrs, options));
        };
        Decoration.node = function(from, to, attrs, options) {
            return new Decoration(from, to, new NodeType(attrs, options));
        };
        prototypeAccessors.options.get = function() {
            return this.type.options;
        };
        Object.defineProperties(Decoration.prototype, prototypeAccessors);
        exports.Decoration = Decoration;
        var none = [],
            noOptions = {};
        var DecorationSet = function(local, children) {
            this.local = local && local.length ? local : none;
            this.children = children && children.length ? children : none;
        };
        DecorationSet.create = function(doc, decorations) {
            return decorations.length ? buildTree(decorations, doc, 0, noOptions) : empty;
        };
        DecorationSet.prototype.find = function(start, end) {
            var result = [];
            this.findInner(start == null ? 0 : start, end == null ? 1e9 : end, result, 0);
            return result;
        };
        DecorationSet.prototype.findInner = function(start, end, result, offset) {
            var this$1 = this;
            for (var i = 0; i < this.local.length; i++) {
                var span = this$1.local[i];
                if (span.from <= end && span.to >= start) {
                    result.push(span.copy(span.from + offset, span.to + offset));
                }
            }
            for (var i$1 = 0; i$1 < this.children.length; i$1 += 3) {
                if (this$1.children[i$1] < end && this$1.children[i$1 + 1] > start) {
                    var childOff = this$1.children[i$1] + 1;
                    this$1.children[i$1 + 2].findInner(start - childOff, end - childOff, result, offset + childOff);
                }
            }
        };
        DecorationSet.prototype.map = function(mapping, doc, options) {
            if (this == empty || mapping.maps.length == 0) {
                return this;
            }
            return this.mapInner(mapping, doc, 0, 0, options || noOptions);
        };
        DecorationSet.prototype.mapInner = function(mapping, node, offset, oldOffset, options) {
            var this$1 = this;
            var newLocal;
            for (var i = 0; i < this.local.length; i++) {
                var mapped = this$1.local[i].map(mapping, offset, oldOffset);
                if (mapped && mapped.type.valid(node, mapped)) {
                    (newLocal || (newLocal = [])).push(mapped);
                } else if (options.onRemove) {
                    options.onRemove(this$1.local[i].options);
                }
            }
            if (this.children.length) {
                return mapChildren(this.children, newLocal, mapping, node, offset, oldOffset, options);
            } else {
                return newLocal ? new DecorationSet(newLocal.sort(byPos)) : empty;
            }
        };
        DecorationSet.prototype.add = function(doc, decorations) {
            if (!decorations.length) {
                return this;
            }
            if (this == empty) {
                return DecorationSet.create(doc, decorations);
            }
            return this.addInner(doc, decorations, 0);
        };
        DecorationSet.prototype.addInner = function(doc, decorations, offset) {
            var this$1 = this;
            var children,
                childIndex = 0;
            doc.forEach(function(childNode, childOffset) {
                var baseOffset = childOffset + offset,
                    found;
                if (!(found = takeSpansForNode(decorations, childNode, baseOffset))) {
                    return;
                }
                if (!children) {
                    children = this$1.children.slice();
                }
                while (childIndex < children.length && children[childIndex] < childOffset) {
                    childIndex += 3;
                }
                if (children[childIndex] == childOffset) {
                    children[childIndex + 2] = children[childIndex + 2].addInner(childNode, found, baseOffset + 1);
                } else {
                    children.splice(childIndex, 0, childOffset, childOffset + childNode.nodeSize, buildTree(found, childNode, baseOffset + 1, noOptions));
                }
                childIndex += 3;
            });
            var local = moveSpans(childIndex ? withoutNulls(decorations) : decorations, -offset);
            return new DecorationSet(local.length ? this.local.concat(local).sort(byPos) : this.local, children || this.children);
        };
        DecorationSet.prototype.remove = function(decorations) {
            if (decorations.length == 0 || this == empty) {
                return this;
            }
            return this.removeInner(decorations, 0);
        };
        DecorationSet.prototype.removeInner = function(decorations, offset) {
            var this$1 = this;
            var children = this.children,
                local = this.local;
            for (var i = 0; i < children.length; i += 3) {
                var found = (void 0),
                    from = children[i] + offset,
                    to = children[i + 1] + offset;
                for (var j = 0,
                         span = (void 0); j < decorations.length; j++) {
                    if (span = decorations[j]) {
                        if (span.from > from && span.to < to) {
                            decorations[j] = null;
                            ;
                            (found || (found = [])).push(span);
                        }
                    }
                }
                if (!found) {
                    continue;
                }
                if (children == this$1.children) {
                    children = this$1.children.slice();
                }
                var removed = children[i + 2].removeInner(found, from + 1);
                if (removed != empty) {
                    children[i + 2] = removed;
                } else {
                    children.splice(i, 3);
                    i -= 3;
                }
            }
            if (local.length) {
                for (var i$1 = 0,
                         span$1 = (void 0); i$1 < decorations.length; i$1++) {
                    if (span$1 = decorations[i$1]) {
                        for (var j$1 = 0; j$1 < local.length; j$1++) {
                            if (local[j$1].type == span$1.type) {
                                if (local == this$1.local) {
                                    local = this$1.local.slice();
                                }
                                local.splice(j$1--, 1);
                            }
                        }
                    }
                }
            }
            if (children == this.children && local == this.local) {
                return this;
            }
            return local.length || children.length ? new DecorationSet(local, children) : empty;
        };
        DecorationSet.prototype.forChild = function(offset, node) {
            var this$1 = this;
            if (this == empty) {
                return this;
            }
            if (node.isLeaf) {
                return DecorationSet.empty;
            }
            var child,
                local;
            for (var i = 0; i < this.children.length; i += 3) {
                if (this$1.children[i] >= offset) {
                    if (this$1.children[i] == offset) {
                        child = this$1.children[i + 2];
                    }
                    break;
                }
            }
            var start = offset + 1,
                end = start + node.content.size;
            for (var i$1 = 0; i$1 < this.local.length; i$1++) {
                var dec = this$1.local[i$1];
                if (dec.from < end && dec.to > start && (dec.type instanceof InlineType)) {
                    var from = Math.max(start, dec.from) - start,
                        to = Math.min(end, dec.to) - start;
                    if (from < to) {
                        (local || (local = [])).push(dec.copy(from, to));
                    }
                }
            }
            if (local) {
                var localSet = new DecorationSet(local);
                return child ? new DecorationGroup([localSet, child]) : localSet;
            }
            return child || empty;
        };
        DecorationSet.prototype.eq = function(other) {
            var this$1 = this;
            if (this == other) {
                return true;
            }
            if (!(other instanceof DecorationSet) || this.local.length != other.local.length || this.children.length != other.children.length) {
                return false;
            }
            for (var i = 0; i < this.local.length; i++) {
                if (!this$1.local[i].eq(other.local[i])) {
                    return false;
                }
            }
            for (var i$1 = 0; i$1 < this.children.length; i$1 += 3) {
                if (this$1.children[i$1] != other.children[i$1] || this$1.children[i$1 + 1] != other.children[i$1 + 1] || !this$1.children[i$1 + 2].eq(other.children[i$1 + 2])) {
                    return false;
                }
            }
            return false;
        };
        DecorationSet.prototype.locals = function(node) {
            return removeOverlap(this.localsInner(node));
        };
        DecorationSet.prototype.localsInner = function(node) {
            var this$1 = this;
            if (this == empty) {
                return none;
            }
            if (node.isTextblock || !this.local.some(InlineType.is)) {
                return this.local;
            }
            var result = [];
            for (var i = 0; i < this.local.length; i++) {
                if (!(this$1.local[i].type instanceof InlineType)) {
                    result.push(this$1.local[i]);
                }
            }
            return result;
        };
        exports.DecorationSet = DecorationSet;
        var empty = new DecorationSet();
        DecorationSet.empty = empty;
        var DecorationGroup = function(members) {
            this.members = members;
        };
        DecorationGroup.prototype.forChild = function(offset, child) {
            var this$1 = this;
            if (child.isLeaf) {
                return DecorationSet.empty;
            }
            var found = [];
            for (var i = 0; i < this.members.length; i++) {
                var result = this$1.members[i].forChild(offset, child);
                if (result == empty) {
                    continue;
                }
                if (result instanceof DecorationGroup) {
                    found = found.concat(result.members);
                } else {
                    found.push(result);
                }
            }
            return DecorationGroup.from(found);
        };
        DecorationGroup.prototype.eq = function(other) {
            var this$1 = this;
            if (!(other instanceof DecorationGroup) || other.members.length != this.members.length) {
                return false;
            }
            for (var i = 0; i < this.members.length; i++) {
                if (!this$1.members[i].eq(other.members[i])) {
                    return false;
                }
            }
            return true;
        };
        DecorationGroup.prototype.locals = function(node) {
            var this$1 = this;
            var result,
                sorted = true;
            for (var i = 0; i < this.members.length; i++) {
                var locals = this$1.members[i].localsInner(node);
                if (!locals.length) {
                    continue;
                }
                if (!result) {
                    result = locals;
                } else {
                    if (sorted) {
                        result = result.slice();
                        sorted = false;
                    }
                    for (var j = 0; j < locals.length; j++) {
                        result.push(locals[j]);
                    }
                }
            }
            return result ? removeOverlap(sorted ? result : result.sort(byPos)) : none;
        };
        DecorationGroup.from = function(members) {
            switch (members.length) {
                case 0:
                    return empty;
                case 1:
                    return members[0];
                default:
                    return new DecorationGroup(members);
            }
        };
        exports.DecorationGroup = DecorationGroup;
        function mapChildren(oldChildren, newLocal, mapping, node, offset, oldOffset, options) {
            var children = oldChildren.slice();
            var shift = function(oldStart, oldEnd, newStart, newEnd) {
                for (var i = 0; i < children.length; i += 3) {
                    var end = children[i + 1],
                        dSize = (void 0);
                    if (end == -1 || oldStart > end + oldOffset) {
                        continue;
                    }
                    if (oldEnd >= children[i] + oldOffset) {
                        children[i + 1] = -1;
                    } else if (dSize = (newEnd - newStart) - (oldEnd - oldStart)) {
                        children[i] += dSize;
                        children[i + 1] += dSize;
                    }
                }
            };
            for (var i = 0; i < mapping.maps.length; i++) {
                mapping.maps[i].forEach(shift);
            }
            var mustRebuild = false;
            for (var i$1 = 0; i$1 < children.length; i$1 += 3) {
                if (children[i$1 + 1] == -1) {
                    var from = mapping.map(children[i$1] + oldOffset),
                        fromLocal = from - offset;
                    if (fromLocal < 0 || fromLocal >= node.content.size) {
                        mustRebuild = true;
                        continue;
                    }
                    var to = mapping.map(oldChildren[i$1 + 1] + oldOffset, -1),
                        toLocal = to - offset;
                    var ref = node.content.findIndex(fromLocal);
                    var index = ref.index;
                    var childOffset = ref.offset;
                    var childNode = node.maybeChild(index);
                    if (childNode && childOffset == fromLocal && childOffset + childNode.nodeSize == toLocal) {
                        var mapped = children[i$1 + 2].mapInner(mapping, childNode, from + 1, children[i$1] + oldOffset + 1, options);
                        if (mapped != empty) {
                            children[i$1] = fromLocal;
                            children[i$1 + 1] = toLocal;
                            children[i$1 + 2] = mapped;
                        } else {
                            children.splice(i$1, 3);
                            i$1 -= 3;
                        }
                    } else {
                        mustRebuild = true;
                    }
                }
            }
            if (mustRebuild) {
                var decorations = mapAndGatherRemainingDecorations(children, newLocal ? moveSpans(newLocal, offset) : [], mapping, oldOffset, options);
                var built = buildTree(decorations, node, 0, options);
                newLocal = built.local;
                for (var i$2 = 0; i$2 < children.length; i$2 += 3) {
                    if (children[i$2 + 1] == -1) {
                        children.splice(i$2, 3);
                        i$2 -= 3;
                    }
                }
                for (var i$3 = 0,
                         j = 0; i$3 < built.children.length; i$3 += 3) {
                    var from$1 = built.children[i$3];
                    while (j < children.length && children[j] < from$1) {
                        j += 3;
                    }
                    children.splice(j, 0, built.children[i$3], built.children[i$3 + 1], built.children[i$3 + 2]);
                }
            }
            return new DecorationSet(newLocal && newLocal.sort(byPos), children);
        }
        function moveSpans(spans, offset) {
            if (!offset || !spans.length) {
                return spans;
            }
            var result = [];
            for (var i = 0; i < spans.length; i++) {
                var span = spans[i];
                result.push(new Decoration(span.from + offset, span.to + offset, span.type));
            }
            return result;
        }
        function mapAndGatherRemainingDecorations(children, decorations, mapping, oldOffset, options) {
            function gather(set, oldOffset) {
                for (var i = 0; i < set.local.length; i++) {
                    var mapped = set.local[i].map(mapping, 0, oldOffset);
                    if (mapped) {
                        decorations.push(mapped);
                    } else if (options.onRemove) {
                        options.onRemove(set.local[i].options);
                    }
                }
                for (var i$1 = 0; i$1 < set.children.length; i$1 += 3) {
                    gather(set.children[i$1 + 2], set.children[i$1] + oldOffset + 1);
                }
            }
            for (var i = 0; i < children.length; i += 3) {
                if (children[i + 1] == -1) {
                    gather(children[i + 2], children[i] + oldOffset + 1);
                }
            }
            return decorations;
        }
        function takeSpansForNode(spans, node, offset) {
            if (node.isLeaf) {
                return null;
            }
            var end = offset + node.nodeSize,
                found = null;
            for (var i = 0,
                     span = (void 0); i < spans.length; i++) {
                if ((span = spans[i]) && span.from > offset && span.to < end) {
                    ;
                    (found || (found = [])).push(span);
                    spans[i] = null;
                }
            }
            return found;
        }
        function withoutNulls(array) {
            var result = [];
            for (var i = 0; i < array.length; i++) {
                if (array[i] != null) {
                    result.push(array[i]);
                }
            }
            return result;
        }
        function buildTree(spans, node, offset, options) {
            var children = [],
                hasNulls = false;
            node.forEach(function(childNode, localStart) {
                var found = takeSpansForNode(spans, childNode, localStart + offset);
                if (found) {
                    hasNulls = true;
                    var subtree = buildTree(found, childNode, offset + localStart + 1, options);
                    if (subtree != empty) {
                        children.push(localStart, localStart + childNode.nodeSize, subtree);
                    }
                }
            });
            var locals = moveSpans(hasNulls ? withoutNulls(spans) : spans, -offset).sort(byPos);
            for (var i = 0; i < locals.length; i++) {
                if (!locals[i].type.valid(node, locals[i])) {
                    if (options.onRemove) {
                        options.onRemove(locals[i].options);
                    }
                    locals.splice(i--, 1);
                }
            }
            return locals.length || children.length ? new DecorationSet(locals, children) : empty;
        }
        function byPos(a, b) {
            return a.from - b.from || a.to - b.to;
        }
        function removeOverlap(spans) {
            var working = spans;
            for (var i = 0; i < working.length - 1; i++) {
                var span = working[i];
                if (span.from != span.to) {
                    for (var j = i + 1; j < working.length; j++) {
                        var next = working[j];
                        if (next.from == span.from) {
                            if (next.to != span.to) {
                                if (working == spans) {
                                    working = spans.slice();
                                }
                                working[j] = next.copy(next.from, span.to);
                                insertAhead(working, j + 1, next.copy(span.to, next.to));
                            }
                            continue;
                        } else {
                            if (next.from < span.to) {
                                if (working == spans) {
                                    working = spans.slice();
                                }
                                working[i] = span.copy(span.from, next.from);
                                insertAhead(working, j, span.copy(next.from, span.to));
                            }
                            break;
                        }
                    }
                }
            }
            return working;
        }
        exports.removeOverlap = removeOverlap;
        function insertAhead(array, i, deco) {
            while (i < array.length && byPos(deco, array[i]) > 0) {
                i++;
            }
            array.splice(i, 0, deco);
        }
        function viewDecorations(view) {
            var found = [];
            view.someProp("decorations", function(f) {
                var result = f(view.state);
                if (result && result != empty) {
                    found.push(result);
                }
            });
            return DecorationGroup.from(found);
        }
        exports.viewDecorations = viewDecorations;
        return module.exports;
    });

    $__System.registerDynamic("1d", ["13", "14", "1a", "1b", "1c"], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        var ref = $__require('13');
        var scrollRectIntoView = ref.scrollRectIntoView;
        var posAtCoords = ref.posAtCoords;
        var coordsAtPos = ref.coordsAtPos;
        var endOfTextblock = ref.endOfTextblock;
        var ref$1 = $__require('14');
        var docViewDesc = ref$1.docViewDesc;
        var ref$2 = $__require('1a');
        var initInput = ref$2.initInput;
        var destroyInput = ref$2.destroyInput;
        var dispatchEvent = ref$2.dispatchEvent;
        var startObserving = ref$2.startObserving;
        var stopObserving = ref$2.stopObserving;
        var ensureListeners = ref$2.ensureListeners;
        var ref$3 = $__require('1b');
        var SelectionReader = ref$3.SelectionReader;
        var selectionToDOM = ref$3.selectionToDOM;
        var ref$4 = $__require('1c');
        var viewDecorations = ref$4.viewDecorations;
        var Decoration = ref$4.Decoration;
        var assign;
        ((assign = $__require('1c'), exports.Decoration = assign.Decoration, exports.DecorationSet = assign.DecorationSet));
        var EditorView = function(place, props) {
            this.props = props;
            this.state = props.state;
            this.dispatch = this.dispatch.bind(this);
            this._root = null;
            this.focused = false;
            this.content = document.createElement("div");
            if (place && place.appendChild) {
                place.appendChild(this.content);
            } else if (place) {
                place(this.content);
            }
            this.editable = getEditable(this);
            this.docView = docViewDesc(this.state.doc, computeDocDeco(this), viewDecorations(this), this.content, this);
            this.lastSelectedViewDesc = null;
            this.selectionReader = new SelectionReader(this);
            initInput(this);
            this.pluginViews = [];
            this.updatePluginViews();
        };
        var prototypeAccessors = {root: {}};
        EditorView.prototype.update = function(props) {
            if (props.handleDOMEvents != this.props.handleDOMEvents) {
                ensureListeners(this);
            }
            this.props = props;
            this.updateState(props.state);
        };
        EditorView.prototype.updateState = function(state) {
            var prev = this.state;
            this.state = state;
            if (prev.plugins != state.plugins) {
                ensureListeners(this);
            }
            if (this.inDOMChange) {
                return;
            }
            var prevEditable = this.editable;
            this.editable = getEditable(this);
            var innerDeco = viewDecorations(this),
                outerDeco = computeDocDeco(this);
            if (!this.docView.matchesNode(state.doc, outerDeco, innerDeco)) {
                stopObserving(this);
                this.docView.update(state.doc, outerDeco, innerDeco, this);
                selectionToDOM(this, state.selection);
                startObserving(this);
            } else if (!state.selection.eq(prev.selection) || this.selectionReader.domChanged()) {
                stopObserving(this);
                selectionToDOM(this, state.selection);
                startObserving(this);
            }
            if (prevEditable != this.editable) {
                this.selectionReader.editableChanged();
            }
            this.updatePluginViews(prev);
            if (state.scrollToSelection > prev.scrollToSelection || prev.config != state.config) {
                if (state.selection.node) {
                    scrollRectIntoView(this, this.docView.domAfterPos(state.selection.from).getBoundingClientRect());
                } else {
                    scrollRectIntoView(this, this.coordsAtPos(state.selection.head));
                }
            }
        };
        EditorView.prototype.destroyPluginViews = function() {
            var view;
            while (view = this.pluginViews.pop()) {
                if (view.destroy) {
                    view.destroy();
                }
            }
        };
        EditorView.prototype.updatePluginViews = function(prevState) {
            var this$1 = this;
            var plugins = this.state.plugins;
            if (!prevState || prevState.plugins != plugins) {
                this.destroyPluginViews();
                for (var i = 0; i < plugins.length; i++) {
                    var plugin = plugins[i];
                    if (plugin.options.view) {
                        this$1.pluginViews.push(plugin.options.view(this$1));
                    }
                }
            } else {
                for (var i$1 = 0; i$1 < this.pluginViews.length; i$1++) {
                    var pluginView = this$1.pluginViews[i$1];
                    if (pluginView.update) {
                        pluginView.update(this$1);
                    }
                }
            }
        };
        EditorView.prototype.hasFocus = function() {
            if (this.editable && this.content.ownerDocument.activeElement != this.content) {
                return false;
            }
            var sel = this.root.getSelection();
            return sel.rangeCount && this.content.contains(sel.anchorNode.nodeType == 3 ? sel.anchorNode.parentNode : sel.anchorNode);
        };
        EditorView.prototype.someProp = function(propName, f) {
            var prop = this.props && this.props[propName],
                value;
            if (prop != null && (value = f ? f(prop) : prop)) {
                return value;
            }
            var plugins = this.state.plugins;
            if (plugins) {
                for (var i = 0; i < plugins.length; i++) {
                    var prop$1 = plugins[i].props[propName];
                    if (prop$1 != null && (value = f ? f(prop$1) : prop$1)) {
                        return value;
                    }
                }
            }
        };
        EditorView.prototype.focus = function() {
            if (this.editable) {
                this.content.focus();
            }
            stopObserving(this);
            selectionToDOM(this, this.state.selection, true);
            startObserving(this);
        };
        prototypeAccessors.root.get = function() {
            var this$1 = this;
            var cached = this._root;
            if (cached == null) {
                for (var search = this.content.parentNode; search; search = search.parentNode) {
                    if (search.nodeType == 9 || (search.nodeType == 11 && search.host)) {
                        return this$1._root = search;
                    }
                }
            }
            return cached || document;
        };
        EditorView.prototype.posAtCoords = function(coords) {
            return posAtCoords(this, coords);
        };
        EditorView.prototype.coordsAtPos = function(pos) {
            return coordsAtPos(this, pos);
        };
        EditorView.prototype.endOfTextblock = function(dir, state) {
            return endOfTextblock(this, state || this.state, dir);
        };
        EditorView.prototype.destroy = function() {
            destroyInput(this);
            this.destroyPluginViews();
            this.docView.destroy();
            this.selectionReader.destroy();
            if (this.content.parentNode) {
                this.content.parentNode.removeChild(this.content);
            }
        };
        EditorView.prototype.dispatchEvent = function(event) {
            return dispatchEvent(this, event);
        };
        EditorView.prototype.dispatch = function(tr) {
            var dispatchTransaction = this.props.dispatchTransaction;
            if (dispatchTransaction) {
                dispatchTransaction(tr);
            } else {
                this.updateState(this.state.apply(tr));
            }
        };
        Object.defineProperties(EditorView.prototype, prototypeAccessors);
        exports.EditorView = EditorView;
        function computeDocDeco(view) {
            var attrs = Object.create(null);
            attrs.class = "ProseMirror" + (view.focused ? " ProseMirror-focused" : "") + (view.state.selection.node ? " ProseMirror-nodeselection" : "");
            attrs.contenteditable = String(view.editable);
            view.someProp("attributes", function(value) {
                if (typeof value == "function") {
                    value = value(view.state);
                }
                if (value) {
                    for (var attr in value) {
                        if (attr == "class") {
                            attrs.class += " " + value[attr];
                        } else if (!attrs[attr] && attr != "contenteditable" && attr != "nodeName") {
                            attrs[attr] = String(value[attr]);
                        }
                    }
                }
            });
            return [Decoration.node(0, view.state.doc.content.size, attrs)];
        }
        function getEditable(view) {
            return !view.someProp("editable", function(value) {
                return value(view.state) === false;
            });
        }
        return module.exports;
    });

    $__System.registerDynamic("11", ["1d"], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        module.exports = $__require('1d');
        return module.exports;
    });

    $__System.registerDynamic("1e", [], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        "format cjs";
        (function(root, factory) {
            if (typeof exports === 'object') {
                module.exports = factory();
            } else if (typeof define === 'function' && define.amd) {
                define(factory);
            } else {
                root.crel = factory();
            }
        }(this, function() {
            var fn = 'function',
                obj = 'object',
                nodeType = 'nodeType',
                textContent = 'textContent',
                setAttribute = 'setAttribute',
                attrMapString = 'attrMap',
                isNodeString = 'isNode',
                isElementString = 'isElement',
                d = typeof document === obj ? document : {},
                isType = function(a, type) {
                    return typeof a === type;
                },
                isNode = typeof Node === fn ? function(object) {
                    return object instanceof Node;
                } : function(object) {
                    return object && isType(object, obj) && (nodeType in object) && isType(object.ownerDocument, obj);
                },
                isElement = function(object) {
                    return crel[isNodeString](object) && object[nodeType] === 1;
                },
                isArray = function(a) {
                    return a instanceof Array;
                },
                appendChild = function(element, child) {
                    if (!crel[isNodeString](child)) {
                        child = d.createTextNode(child);
                    }
                    element.appendChild(child);
                };
            function crel() {
                var args = arguments,
                    element = args[0],
                    child,
                    settings = args[1],
                    childIndex = 2,
                    argumentsLength = args.length,
                    attributeMap = crel[attrMapString];
                element = crel[isElementString](element) ? element : d.createElement(element);
                if (argumentsLength === 1) {
                    return element;
                }
                if (!isType(settings, obj) || crel[isNodeString](settings) || isArray(settings)) {
                    --childIndex;
                    settings = null;
                }
                if ((argumentsLength - childIndex) === 1 && isType(args[childIndex], 'string') && element[textContent] !== undefined) {
                    element[textContent] = args[childIndex];
                } else {
                    for (; childIndex < argumentsLength; ++childIndex) {
                        child = args[childIndex];
                        if (child == null) {
                            continue;
                        }
                        if (isArray(child)) {
                            for (var i = 0; i < child.length; ++i) {
                                appendChild(element, child[i]);
                            }
                        } else {
                            appendChild(element, child);
                        }
                    }
                }
                for (var key in settings) {
                    if (!attributeMap[key]) {
                        element[setAttribute](key, settings[key]);
                    } else {
                        var attr = attributeMap[key];
                        if (typeof attr === fn) {
                            attr(element, settings[key]);
                        } else {
                            element[setAttribute](attr, settings[key]);
                        }
                    }
                }
                return element;
            }
            crel[attrMapString] = {};
            crel[isElementString] = isElement;
            crel[isNodeString] = isNode;
            if (typeof Proxy !== 'undefined') {
                crel.proxy = new Proxy(crel, {get: function(target, key) {
                    !(key in crel) && (crel[key] = crel.bind(null, key));
                    return crel[key];
                }});
            }
            return crel;
        }));
        return module.exports;
    });

    $__System.registerDynamic("1f", ["1e"], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        module.exports = $__require('1e');
        return module.exports;
    });

    $__System.registerDynamic("20", [], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        var SVG = "http://www.w3.org/2000/svg";
        var XLINK = "http://www.w3.org/1999/xlink";
        var prefix = "ProseMirror-icon";
        function hashPath(path) {
            var hash = 0;
            for (var i = 0; i < path.length; i++) {
                hash = (((hash << 5) - hash) + path.charCodeAt(i)) | 0;
            }
            return hash;
        }
        function getIcon(icon) {
            var node = document.createElement("div");
            node.className = prefix;
            if (icon.path) {
                var name = "pm-icon-" + hashPath(icon.path).toString(16);
                if (!document.getElementById(name)) {
                    buildSVG(name, icon);
                }
                var svg = node.appendChild(document.createElementNS(SVG, "svg"));
                svg.style.width = (icon.width / icon.height) + "em";
                var use = svg.appendChild(document.createElementNS(SVG, "use"));
                use.setAttributeNS(XLINK, "href", /([^#]*)/.exec(document.location)[1] + "#" + name);
            } else if (icon.dom) {
                node.appendChild(icon.dom.cloneNode(true));
            } else {
                node.appendChild(document.createElement("span")).textContent = icon.text || '';
                if (icon.css) {
                    node.firstChild.style.cssText = icon.css;
                }
            }
            return node;
        }
        exports.getIcon = getIcon;
        function buildSVG(name, data) {
            var collection = document.getElementById(prefix + "-collection");
            if (!collection) {
                collection = document.createElementNS(SVG, "svg");
                collection.id = prefix + "-collection";
                collection.style.display = "none";
                document.body.insertBefore(collection, document.body.firstChild);
            }
            var sym = document.createElementNS(SVG, "symbol");
            sym.id = name;
            sym.setAttribute("viewBox", "0 0 " + data.width + " " + data.height);
            var path = sym.appendChild(document.createElementNS(SVG, "path"));
            path.setAttribute("d", data.path);
            collection.appendChild(sym);
        }
        return module.exports;
    });

    $__System.registerDynamic("21", ["1f", "22", "23", "20"], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        var crel = $__require('1f');
        var ref = $__require('22');
        var lift = ref.lift;
        var joinUp = ref.joinUp;
        var selectParentNode = ref.selectParentNode;
        var wrapIn = ref.wrapIn;
        var setBlockType = ref.setBlockType;
        var ref$1 = $__require('23');
        var undo = ref$1.undo;
        var redo = ref$1.redo;
        var ref$2 = $__require('20');
        var getIcon = ref$2.getIcon;
        var prefix = "ProseMirror-menu";
        var MenuItem = function MenuItem(spec) {
            this.spec = spec;
        };
        MenuItem.prototype.render = function render(view) {
            var disabled = false,
                spec = this.spec;
            if (spec.select && !spec.select(view.state)) {
                if (spec.onDeselected == "disable") {
                    disabled = true;
                } else {
                    return null;
                }
            }
            var active = spec.active && !disabled && spec.active(view.state);
            var dom;
            if (spec.render) {
                dom = spec.render(view);
            } else if (spec.icon) {
                dom = getIcon(spec.icon);
                if (active) {
                    dom.classList.add(prefix + "-active");
                }
            } else if (spec.label) {
                dom = crel("div", null, translate(view, spec.label));
            } else {
                throw new RangeError("MenuItem without render, icon, or label property");
            }
            if (spec.title) {
                dom.setAttribute("title", translate(view, spec.title));
            }
            if (spec.class) {
                dom.classList.add(spec.class);
            }
            if (disabled) {
                dom.classList.add(prefix + "-disabled");
            }
            if (spec.css) {
                dom.style.cssText += spec.css;
            }
            if (!disabled) {
                dom.addEventListener(spec.execEvent || "mousedown", function(e) {
                    e.preventDefault();
                    spec.run(view.state, view.dispatch, view);
                });
            }
            return dom;
        };
        exports.MenuItem = MenuItem;
        function translate(view, text) {
            return view.props.translate ? view.props.translate(text) : text;
        }
        var lastMenuEvent = {
            time: 0,
            node: null
        };
        function markMenuEvent(e) {
            lastMenuEvent.time = Date.now();
            lastMenuEvent.node = e.target;
        }
        function isMenuEvent(wrapper) {
            return Date.now() - 100 < lastMenuEvent.time && lastMenuEvent.node && wrapper.contains(lastMenuEvent.node);
        }
        var Dropdown = function Dropdown(content, options) {
            this.options = options || {};
            this.content = Array.isArray(content) ? content : [content];
        };
        Dropdown.prototype.render = function render(view) {
            var this$1 = this;
            var items = renderDropdownItems(this.content, view);
            if (!items.length) {
                return null;
            }
            var label = crel("div", {
                class: prefix + "-dropdown " + (this.options.class || ""),
                style: this.options.css,
                title: this.options.title && translate(view, this.options.title)
            }, translate(view, this.options.label));
            var wrap = crel("div", {class: prefix + "-dropdown-wrap"}, label);
            var open = null,
                listeningOnClose = null;
            var close = function() {
                if (open && open.close()) {
                    open = null;
                    window.removeEventListener("mousedown", listeningOnClose);
                }
            };
            label.addEventListener("mousedown", function(e) {
                e.preventDefault();
                markMenuEvent(e);
                if (open) {
                    close();
                } else {
                    open = this$1.expand(wrap, items);
                    window.addEventListener("mousedown", listeningOnClose = function() {
                        if (!isMenuEvent(wrap)) {
                            close();
                        }
                    });
                }
            });
            return wrap;
        };
        Dropdown.prototype.expand = function expand(dom, items) {
            var menuDOM = crel("div", {class: prefix + "-dropdown-menu " + (this.options.class || "")}, items);
            var done = false;
            function close() {
                if (done) {
                    return;
                }
                done = true;
                dom.removeChild(menuDOM);
                return true;
            }
            dom.appendChild(menuDOM);
            return {
                close: close,
                node: menuDOM
            };
        };
        exports.Dropdown = Dropdown;
        function renderDropdownItems(items, view) {
            var rendered = [];
            for (var i = 0; i < items.length; i++) {
                var inner = items[i].render(view);
                if (inner) {
                    rendered.push(crel("div", {class: prefix + "-dropdown-item"}, inner));
                }
            }
            return rendered;
        }
        var DropdownSubmenu = function DropdownSubmenu(content, options) {
            this.options = options || {};
            this.content = Array.isArray(content) ? content : [content];
        };
        DropdownSubmenu.prototype.render = function render(view) {
            var items = renderDropdownItems(this.content, view);
            if (!items.length) {
                return null;
            }
            var label = crel("div", {class: prefix + "-submenu-label"}, translate(view, this.options.label));
            var wrap = crel("div", {class: prefix + "-submenu-wrap"}, label, crel("div", {class: prefix + "-submenu"}, items));
            var listeningOnClose = null;
            label.addEventListener("mousedown", function(e) {
                e.preventDefault();
                markMenuEvent(e);
                wrap.classList.toggle(prefix + "-submenu-wrap-active");
                if (!listeningOnClose) {
                    window.addEventListener("mousedown", listeningOnClose = function() {
                        if (!isMenuEvent(wrap)) {
                            wrap.classList.remove(prefix + "-submenu-wrap-active");
                            window.removeEventListener("mousedown", listeningOnClose);
                            listeningOnClose = null;
                        }
                    });
                }
            });
            return wrap;
        };
        exports.DropdownSubmenu = DropdownSubmenu;
        function renderGrouped(view, content) {
            var result = document.createDocumentFragment(),
                needSep = false;
            for (var i = 0; i < content.length; i++) {
                var items = content[i],
                    added = false;
                for (var j = 0; j < items.length; j++) {
                    var rendered = items[j].render(view);
                    if (rendered) {
                        if (!added && needSep) {
                            result.appendChild(separator());
                        }
                        result.appendChild(crel("span", {class: prefix + "item"}, rendered));
                        added = true;
                    }
                }
                if (added) {
                    needSep = true;
                }
            }
            return result;
        }
        exports.renderGrouped = renderGrouped;
        function separator() {
            return crel("span", {class: prefix + "separator"});
        }
        var icons = {
            join: {
                width: 800,
                height: 900,
                path: "M0 75h800v125h-800z M0 825h800v-125h-800z M250 400h100v-100h100v100h100v100h-100v100h-100v-100h-100z"
            },
            lift: {
                width: 1024,
                height: 1024,
                path: "M219 310v329q0 7-5 12t-12 5q-8 0-13-5l-164-164q-5-5-5-13t5-13l164-164q5-5 13-5 7 0 12 5t5 12zM1024 749v109q0 7-5 12t-12 5h-987q-7 0-12-5t-5-12v-109q0-7 5-12t12-5h987q7 0 12 5t5 12zM1024 530v109q0 7-5 12t-12 5h-621q-7 0-12-5t-5-12v-109q0-7 5-12t12-5h621q7 0 12 5t5 12zM1024 310v109q0 7-5 12t-12 5h-621q-7 0-12-5t-5-12v-109q0-7 5-12t12-5h621q7 0 12 5t5 12zM1024 91v109q0 7-5 12t-12 5h-987q-7 0-12-5t-5-12v-109q0-7 5-12t12-5h987q7 0 12 5t5 12z"
            },
            selectParentNode: {
                text: "\u2b1a",
                css: "font-weight: bold"
            },
            undo: {
                width: 1024,
                height: 1024,
                path: "M761 1024c113-206 132-520-313-509v253l-384-384 384-384v248c534-13 594 472 313 775z"
            },
            redo: {
                width: 1024,
                height: 1024,
                path: "M576 248v-248l384 384-384 384v-253c-446-10-427 303-313 509-280-303-221-789 313-775z"
            },
            strong: {
                width: 805,
                height: 1024,
                path: "M317 869q42 18 80 18 214 0 214-191 0-65-23-102-15-25-35-42t-38-26-46-14-48-6-54-1q-41 0-57 5 0 30-0 90t-0 90q0 4-0 38t-0 55 2 47 6 38zM309 442q24 4 62 4 46 0 81-7t62-25 42-51 14-81q0-40-16-70t-45-46-61-24-70-8q-28 0-74 7 0 28 2 86t2 86q0 15-0 45t-0 45q0 26 0 39zM0 950l1-53q8-2 48-9t60-15q4-6 7-15t4-19 3-18 1-21 0-19v-37q0-561-12-585-2-4-12-8t-25-6-28-4-27-2-17-1l-2-47q56-1 194-6t213-5q13 0 39 0t38 0q40 0 78 7t73 24 61 40 42 59 16 78q0 29-9 54t-22 41-36 32-41 25-48 22q88 20 146 76t58 141q0 57-20 102t-53 74-78 48-93 27-100 8q-25 0-75-1t-75-1q-60 0-175 6t-132 6z"
            },
            em: {
                width: 585,
                height: 1024,
                path: "M0 949l9-48q3-1 46-12t63-21q16-20 23-57 0-4 35-165t65-310 29-169v-14q-13-7-31-10t-39-4-33-3l10-58q18 1 68 3t85 4 68 1q27 0 56-1t69-4 56-3q-2 22-10 50-17 5-58 16t-62 19q-4 10-8 24t-5 22-4 26-3 24q-15 84-50 239t-44 203q-1 5-7 33t-11 51-9 47-3 32l0 10q9 2 105 17-1 25-9 56-6 0-18 0t-18 0q-16 0-49-5t-49-5q-78-1-117-1-29 0-81 5t-69 6z"
            },
            code: {
                width: 896,
                height: 1024,
                path: "M608 192l-96 96 224 224-224 224 96 96 288-320-288-320zM288 192l-288 320 288 320 96-96-224-224 224-224-96-96z"
            },
            link: {
                width: 951,
                height: 1024,
                path: "M832 694q0-22-16-38l-118-118q-16-16-38-16-24 0-41 18 1 1 10 10t12 12 8 10 7 14 2 15q0 22-16 38t-38 16q-8 0-15-2t-14-7-10-8-12-12-10-10q-18 17-18 41 0 22 16 38l117 118q15 15 38 15 22 0 38-14l84-83q16-16 16-38zM430 292q0-22-16-38l-117-118q-16-16-38-16-22 0-38 15l-84 83q-16 16-16 38 0 22 16 38l118 118q15 15 38 15 24 0 41-17-1-1-10-10t-12-12-8-10-7-14-2-15q0-22 16-38t38-16q8 0 15 2t14 7 10 8 12 12 10 10q18-17 18-41zM941 694q0 68-48 116l-84 83q-47 47-116 47-69 0-116-48l-117-118q-47-47-47-116 0-70 50-119l-50-50q-49 50-118 50-68 0-116-48l-118-118q-48-48-48-116t48-116l84-83q47-47 116-47 69 0 116 48l117 118q47 47 47 116 0 70-50 119l50 50q49-50 118-50 68 0 116 48l118 118q48 48 48 116z"
            },
            bulletList: {
                width: 768,
                height: 896,
                path: "M0 512h128v-128h-128v128zM0 256h128v-128h-128v128zM0 768h128v-128h-128v128zM256 512h512v-128h-512v128zM256 256h512v-128h-512v128zM256 768h512v-128h-512v128z"
            },
            orderedList: {
                width: 768,
                height: 896,
                path: "M320 512h448v-128h-448v128zM320 768h448v-128h-448v128zM320 128v128h448v-128h-448zM79 384h78v-256h-36l-85 23v50l43-2v185zM189 590c0-36-12-78-96-78-33 0-64 6-83 16l1 66c21-10 42-15 67-15s32 11 32 28c0 26-30 58-110 112v50h192v-67l-91 2c49-30 87-66 87-113l1-1z"
            },
            blockquote: {
                width: 640,
                height: 896,
                path: "M0 448v256h256v-256h-128c0 0 0-128 128-128v-128c0 0-256 0-256 256zM640 320v-128c0 0-256 0-256 256v256h256v-256h-128c0 0 0-128 128-128z"
            }
        };
        exports.icons = icons;
        var joinUpItem = new MenuItem({
            title: "Join with above block",
            run: joinUp,
            select: function(state) {
                return joinUp(state);
            },
            icon: icons.join
        });
        exports.joinUpItem = joinUpItem;
        var liftItem = new MenuItem({
            title: "Lift out of enclosing block",
            run: lift,
            select: function(state) {
                return lift(state);
            },
            icon: icons.lift
        });
        exports.liftItem = liftItem;
        var selectParentNodeItem = new MenuItem({
            title: "Select parent node",
            run: selectParentNode,
            select: function(state) {
                return selectParentNode(state);
            },
            icon: icons.selectParentNode
        });
        exports.selectParentNodeItem = selectParentNodeItem;
        var undoItem = new MenuItem({
            title: "Undo last change",
            run: undo,
            select: function(state) {
                return undo(state);
            },
            icon: icons.undo
        });
        exports.undoItem = undoItem;
        var redoItem = new MenuItem({
            title: "Redo last undone change",
            run: redo,
            select: function(state) {
                return redo(state);
            },
            icon: icons.redo
        });
        exports.redoItem = redoItem;
        function wrapItem(nodeType, options) {
            var passedOptions = {
                run: function run(state, dispatch) {
                    return wrapIn(nodeType, options.attrs)(state, dispatch);
                },
                select: function select(state) {
                    return wrapIn(nodeType, options.attrs instanceof Function ? null : options.attrs)(state);
                }
            };
            for (var prop in options) {
                passedOptions[prop] = options[prop];
            }
            return new MenuItem(passedOptions);
        }
        exports.wrapItem = wrapItem;
        function blockTypeItem(nodeType, options) {
            var command = setBlockType(nodeType, options.attrs);
            var passedOptions = {
                run: command,
                select: function select(state) {
                    return command(state);
                },
                active: function active(state) {
                    var ref = state.selection;
                    var $from = ref.$from;
                    var to = ref.to;
                    var node = ref.node;
                    if (node) {
                        return node.hasMarkup(nodeType, options.attrs);
                    }
                    return to <= $from.end() && $from.parent.hasMarkup(nodeType, options.attrs);
                }
            };
            for (var prop in options) {
                passedOptions[prop] = options[prop];
            }
            return new MenuItem(passedOptions);
        }
        exports.blockTypeItem = blockTypeItem;
        return module.exports;
    });

    $__System.registerDynamic("24", ["1f", "11", "21"], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        var crel = $__require('1f');
        var ref = $__require('11');
        var EditorView = ref.EditorView;
        var ref$1 = $__require('21');
        var renderGrouped = ref$1.renderGrouped;
        var prefix = "ProseMirror-menubar";
        var MenuBarEditorView = function MenuBarEditorView(place, props) {
            var this$1 = this;
            this.wrapper = crel("div", {class: prefix + "-wrapper"});
            if (place && place.appendChild) {
                place.appendChild(this.wrapper);
            } else if (place) {
                place(this.wrapper);
            }
            if (!props.dispatchTransaction) {
                props.dispatchTransaction = function(tr) {
                    return this$1.updateState(this$1.editor.state.apply(tr));
                };
            }
            this.editor = new EditorView(this.wrapper, props);
            this.menu = crel("div", {class: prefix});
            this.menu.className = prefix;
            this.spacer = null;
            this.wrapper.insertBefore(this.menu, this.wrapper.firstChild);
            this.maxHeight = 0;
            this.widthForMaxHeight = 0;
            this.floating = false;
            this.props = props;
            this.updateMenu();
            if (this.editor.someProp("floatingMenu")) {
                this.updateFloat();
                this.scrollFunc = function() {
                    if (!this$1.editor.root.contains(this$1.wrapper)) {
                        window.removeEventListener("scroll", this$1.scrollFunc);
                    } else {
                        this$1.updateFloat();
                    }
                };
                window.addEventListener("scroll", this.scrollFunc);
            }
        };
        MenuBarEditorView.prototype.update = function update(props) {
            this.props = props;
            this.editor.update(props);
            this.updateMenu();
        };
        MenuBarEditorView.prototype.updateState = function updateState(state) {
            this.editor.updateState(state);
            this.updateMenu();
        };
        MenuBarEditorView.prototype.updateMenu = function updateMenu() {
            this.menu.textContent = "";
            this.menu.appendChild(renderGrouped(this.editor, this.editor.someProp("menuContent")));
            if (this.floating) {
                this.updateScrollCursor();
            } else {
                if (this.menu.offsetWidth != this.widthForMaxHeight) {
                    this.widthForMaxHeight = this.menu.offsetWidth;
                    this.maxHeight = 0;
                }
                if (this.menu.offsetHeight > this.maxHeight) {
                    this.maxHeight = this.menu.offsetHeight;
                    this.menu.style.minHeight = this.maxHeight + "px";
                }
            }
        };
        MenuBarEditorView.prototype.updateScrollCursor = function updateScrollCursor() {
            var selection = this.editor.root.getSelection();
            if (!selection.focusNode) {
                return;
            }
            var rects = selection.getRangeAt(0).getClientRects();
            var selRect = rects[selectionIsInverted(selection) ? 0 : rects.length - 1];
            if (!selRect) {
                return;
            }
            var menuRect = this.menu.getBoundingClientRect();
            if (selRect.top < menuRect.bottom && selRect.bottom > menuRect.top) {
                var scrollable = findWrappingScrollable(this.wrapper);
                if (scrollable) {
                    scrollable.scrollTop -= (menuRect.bottom - selRect.top);
                }
            }
        };
        MenuBarEditorView.prototype.updateFloat = function updateFloat() {
            var parent = this.wrapper,
                editorRect = parent.getBoundingClientRect();
            if (this.floating) {
                if (editorRect.top >= 0 || editorRect.bottom < this.menu.offsetHeight + 10) {
                    this.floating = false;
                    this.menu.style.position = this.menu.style.left = this.menu.style.width = "";
                    this.menu.style.display = "";
                    this.spacer.parentNode.removeChild(this.spacer);
                    this.spacer = null;
                } else {
                    var border = (parent.offsetWidth - parent.clientWidth) / 2;
                    this.menu.style.left = (editorRect.left + border) + "px";
                    this.menu.style.display = (editorRect.top > window.innerHeight ? "none" : "");
                }
            } else {
                if (editorRect.top < 0 && editorRect.bottom >= this.menu.offsetHeight + 10) {
                    this.floating = true;
                    var menuRect = this.menu.getBoundingClientRect();
                    this.menu.style.left = menuRect.left + "px";
                    this.menu.style.width = menuRect.width + "px";
                    this.menu.style.position = "fixed";
                    this.spacer = crel("div", {
                        class: prefix + "-spacer",
                        style: ("height: " + (menuRect.height) + "px")
                    });
                    parent.insertBefore(this.spacer, this.menu);
                }
            }
        };
        MenuBarEditorView.prototype.destroy = function destroy() {
            this.editor.destroy();
        };
        exports.MenuBarEditorView = MenuBarEditorView;
        function selectionIsInverted(selection) {
            if (selection.anchorNode == selection.focusNode) {
                return selection.anchorOffset > selection.focusOffset;
            }
            return selection.anchorNode.compareDocumentPosition(selection.focusNode) == Node.DOCUMENT_POSITION_FOLLOWING;
        }
        function findWrappingScrollable(node) {
            for (var cur = node.parentNode; cur; cur = cur.parentNode) {
                if (cur.scrollHeight > cur.clientHeight) {
                    return cur;
                }
            }
        }
        return module.exports;
    });

    $__System.registerDynamic("25", ["21", "24"], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        ;
        var assign;
        ((assign = $__require('21'), exports.MenuItem = assign.MenuItem, exports.Dropdown = assign.Dropdown, exports.DropdownSubmenu = assign.DropdownSubmenu, exports.renderGrouped = assign.renderGrouped, exports.icons = assign.icons, exports.joinUpItem = assign.joinUpItem, exports.liftItem = assign.liftItem, exports.selectParentNodeItem = assign.selectParentNodeItem, exports.undoItem = assign.undoItem, exports.redoItem = assign.redoItem, exports.wrapItem = assign.wrapItem, exports.blockTypeItem = assign.blockTypeItem));
        exports.MenuBarEditorView = $__require('24').MenuBarEditorView;
        return module.exports;
    });

    $__System.registerDynamic("26", ["25"], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        module.exports = $__require('25');
        return module.exports;
    });

    $__System.registerDynamic("27", [], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        var prefix = "ProseMirror-prompt";
        function openPrompt(options) {
            var wrapper = document.body.appendChild(document.createElement("div"));
            wrapper.className = prefix;
            var mouseOutside = function(e) {
                if (!wrapper.contains(e.target)) {
                    close();
                }
            };
            setTimeout(function() {
                return window.addEventListener("mousedown", mouseOutside);
            }, 50);
            var close = function() {
                window.removeEventListener("mousedown", mouseOutside);
                if (wrapper.parentNode) {
                    wrapper.parentNode.removeChild(wrapper);
                }
            };
            var domFields = [];
            for (var name in options.fields) {
                domFields.push(options.fields[name].render());
            }
            var submitButton = document.createElement("button");
            submitButton.type = "submit";
            submitButton.className = prefix + "-submit";
            submitButton.textContent = "OK";
            var cancelButton = document.createElement("button");
            cancelButton.type = "button";
            cancelButton.className = prefix + "-cancel";
            cancelButton.textContent = "Cancel";
            cancelButton.addEventListener("click", close);
            var form = wrapper.appendChild(document.createElement("form"));
            if (options.title) {
                form.appendChild(document.createElement("h5")).textContent = options.title;
            }
            domFields.forEach(function(field) {
                form.appendChild(document.createElement("div")).appendChild(field);
            });
            var buttons = form.appendChild(document.createElement("div"));
            buttons.className = prefix + "-buttons";
            buttons.appendChild(submitButton);
            buttons.appendChild(document.createTextNode(" "));
            buttons.appendChild(cancelButton);
            var box = wrapper.getBoundingClientRect();
            wrapper.style.top = ((window.innerHeight - box.height) / 2) + "px";
            wrapper.style.left = ((window.innerWidth - box.width) / 2) + "px";
            var submit = function() {
                var params = getValues(options.fields, domFields);
                if (params) {
                    close();
                    options.callback(params);
                }
            };
            form.addEventListener("submit", function(e) {
                e.preventDefault();
                submit();
            });
            form.addEventListener("keydown", function(e) {
                if (e.keyCode == 27) {
                    e.preventDefault();
                    close();
                } else if (e.keyCode == 13 && !(e.ctrlKey || e.metaKey || e.shiftKey)) {
                    e.preventDefault();
                    submit();
                } else if (e.keyCode == 9) {
                    window.setTimeout(function() {
                        if (!wrapper.contains(document.activeElement)) {
                            close();
                        }
                    }, 500);
                }
            });
            var input = form.elements[0];
            if (input) {
                input.focus();
            }
        }
        exports.openPrompt = openPrompt;
        function getValues(fields, domFields) {
            var result = Object.create(null),
                i = 0;
            for (var name in fields) {
                var field = fields[name],
                    dom = domFields[i++];
                var value = field.read(dom),
                    bad = field.validate(value);
                if (bad) {
                    reportInvalid(dom, bad);
                    return null;
                }
                result[name] = field.clean(value);
            }
            return result;
        }
        function reportInvalid(dom, message) {
            var parent = dom.parentNode;
            var msg = parent.appendChild(document.createElement("div"));
            msg.style.left = (dom.offsetLeft + dom.offsetWidth + 2) + "px";
            msg.style.top = (dom.offsetTop - 5) + "px";
            msg.className = "ProseMirror-invalid";
            msg.textContent = message;
            setTimeout(function() {
                return parent.removeChild(msg);
            }, 1500);
        }
        var Field = function Field(options) {
            this.options = options;
        };
        Field.prototype.read = function read(dom) {
            return dom.value;
        };
        Field.prototype.validateType = function validateType(_value) {};
        Field.prototype.validate = function validate(value) {
            if (!value && this.options.required) {
                return "Required field";
            }
            return this.validateType(value) || (this.options.validate && this.options.validate(value));
        };
        Field.prototype.clean = function clean(value) {
            return this.options.clean ? this.options.clean(value) : value;
        };
        exports.Field = Field;
        var TextField = (function(Field) {
            function TextField() {
                Field.apply(this, arguments);
            }
            if (Field)
                TextField.__proto__ = Field;
            TextField.prototype = Object.create(Field && Field.prototype);
            TextField.prototype.constructor = TextField;
            TextField.prototype.render = function render() {
                var input = document.createElement("input");
                input.type = "text";
                input.placeholder = this.options.label;
                input.value = this.options.value || "";
                input.autocomplete = "off";
                return input;
            };
            return TextField;
        }(Field));
        exports.TextField = TextField;
        var SelectField = (function(Field) {
            function SelectField() {
                Field.apply(this, arguments);
            }
            if (Field)
                SelectField.__proto__ = Field;
            SelectField.prototype = Object.create(Field && Field.prototype);
            SelectField.prototype.constructor = SelectField;
            SelectField.prototype.render = function render() {
                var this$1 = this;
                var select = document.createElement("select");
                this.options.options.forEach(function(o) {
                    var opt = select.appendChild(document.createElement("option"));
                    opt.value = o.value;
                    opt.selected = o.value == this$1.options.value;
                    opt.label = o.label;
                });
                return select;
            };
            return SelectField;
        }(Field));
        exports.SelectField = SelectField;
        return module.exports;
    });

    $__System.registerDynamic("28", ["26", "29", "7", "22", "2a", "27"], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        var ref = $__require('26');
        var wrapItem = ref.wrapItem;
        var blockTypeItem = ref.blockTypeItem;
        var Dropdown = ref.Dropdown;
        var DropdownSubmenu = ref.DropdownSubmenu;
        var joinUpItem = ref.joinUpItem;
        var liftItem = ref.liftItem;
        var selectParentNodeItem = ref.selectParentNodeItem;
        var undoItem = ref.undoItem;
        var redoItem = ref.redoItem;
        var icons = ref.icons;
        var MenuItem = ref.MenuItem;
        var ref$1 = $__require('29');
        var createTable = ref$1.createTable;
        var addColumnBefore = ref$1.addColumnBefore;
        var addColumnAfter = ref$1.addColumnAfter;
        var removeColumn = ref$1.removeColumn;
        var addRowBefore = ref$1.addRowBefore;
        var addRowAfter = ref$1.addRowAfter;
        var removeRow = ref$1.removeRow;
        var ref$2 = $__require('7');
        var Selection = ref$2.Selection;
        var ref$3 = $__require('22');
        var toggleMark = ref$3.toggleMark;
        var ref$4 = $__require('2a');
        var wrapInList = ref$4.wrapInList;
        var ref$5 = $__require('27');
        var TextField = ref$5.TextField;
        var openPrompt = ref$5.openPrompt;
        function canInsert(state, nodeType, attrs) {
            var $from = state.selection.$from;
            for (var d = $from.depth; d >= 0; d--) {
                var index = $from.index(d);
                if ($from.node(d).canReplaceWith(index, index, nodeType, attrs)) {
                    return true;
                }
            }
            return false;
        }
        function insertImageItem(nodeType) {
            return new MenuItem({
                title: "Insert image",
                label: "Image",
                select: function select(state) {
                    return canInsert(state, nodeType);
                },
                run: function run(state, _, view) {
                    var ref = state.selection;
                    var node = ref.node;
                    var from = ref.from;
                    var to = ref.to;
                    var attrs = nodeType && node && node.type == nodeType && node.attrs;
                    openPrompt({
                        title: "Insert image",
                        fields: {
                            src: new TextField({
                                label: "Location",
                                required: true,
                                value: attrs && attrs.src
                            }),
                            title: new TextField({
                                label: "Title",
                                value: attrs && attrs.title
                            }),
                            alt: new TextField({
                                label: "Description",
                                value: attrs ? attrs.title : state.doc.textBetween(from, to, " ")
                            })
                        },
                        callback: function callback(attrs) {
                            view.dispatch(view.state.tr.replaceSelectionWith(nodeType.createAndFill(attrs)));
                            view.focus();
                        }
                    });
                }
            });
        }
        function positiveInteger(value) {
            if (!/^[1-9]\d*$/.test(value)) {
                return "Should be a positive integer";
            }
        }
        function insertTableItem(tableType) {
            return new MenuItem({
                title: "Insert a table",
                run: function run(_, _a, view) {
                    openPrompt({
                        title: "Insert table",
                        fields: {
                            rows: new TextField({
                                label: "Rows",
                                validate: positiveInteger
                            }),
                            cols: new TextField({
                                label: "Columns",
                                validate: positiveInteger
                            })
                        },
                        callback: function callback(ref) {
                            var rows = ref.rows;
                            var cols = ref.cols;
                            var tr = view.state.tr.replaceSelectionWith(createTable(tableType, +rows, +cols));
                            tr.setSelection(Selection.near(tr.doc.resolve(view.state.selection.from)));
                            view.dispatch(tr.scrollIntoView());
                            view.focus();
                        }
                    });
                },
                select: function select(state) {
                    var $from = state.selection.$from;
                    for (var d = $from.depth; d >= 0; d--) {
                        var index = $from.index(d);
                        if ($from.node(d).canReplaceWith(index, index, tableType)) {
                            return true;
                        }
                    }
                    return false;
                },
                label: "Table"
            });
        }
        function cmdItem(cmd, options) {
            var passedOptions = {
                label: options.title,
                run: cmd,
                select: function select(state) {
                    return cmd(state);
                }
            };
            for (var prop in options) {
                passedOptions[prop] = options[prop];
            }
            return new MenuItem(passedOptions);
        }
        function markActive(state, type) {
            var ref = state.selection;
            var from = ref.from;
            var $from = ref.$from;
            var to = ref.to;
            var empty = ref.empty;
            if (empty) {
                return type.isInSet(state.storedMarks || $from.marks());
            } else {
                return state.doc.rangeHasMark(from, to, type);
            }
        }
        function markItem(markType, options) {
            var passedOptions = {active: function active(state) {
                return markActive(state, markType);
            }};
            for (var prop in options) {
                passedOptions[prop] = options[prop];
            }
            return cmdItem(toggleMark(markType), passedOptions);
        }
        function linkItem(markType) {
            return markItem(markType, {
                title: "Add or remove link",
                icon: icons.link,
                run: function run(state, dispatch, view) {
                    if (markActive(state, markType)) {
                        toggleMark(markType)(state, dispatch);
                        return true;
                    }
                    openPrompt({
                        title: "Create a link",
                        fields: {
                            href: new TextField({
                                label: "Link target",
                                required: true,
                                clean: function(val) {
                                    if (!/^https?:\/\//i.test(val)) {
                                        val = 'http://' + val;
                                    }
                                    return val;
                                }
                            }),
                            title: new TextField({label: "Title"})
                        },
                        callback: function callback(attrs) {
                            toggleMark(markType, attrs)(view.state, view.dispatch);
                            view.focus();
                        }
                    });
                }
            });
        }
        function wrapListItem(nodeType, options) {
            return cmdItem(wrapInList(nodeType, options.attrs), options);
        }
        function buildMenuItems(schema) {
            var r = {},
                type;
            if (type = schema.marks.strong) {
                r.toggleStrong = markItem(type, {
                    title: "Toggle strong style",
                    icon: icons.strong
                });
            }
            if (type = schema.marks.em) {
                r.toggleEm = markItem(type, {
                    title: "Toggle emphasis",
                    icon: icons.em
                });
            }
            if (type = schema.marks.code) {
                r.toggleCode = markItem(type, {
                    title: "Toggle code font",
                    icon: icons.code
                });
            }
            if (type = schema.marks.link) {
                r.toggleLink = linkItem(type);
            }
            if (type = schema.nodes.image) {
                r.insertImage = insertImageItem(type);
            }
            if (type = schema.nodes.bullet_list) {
                r.wrapBulletList = wrapListItem(type, {
                    title: "Wrap in bullet list",
                    icon: icons.bulletList
                });
            }
            if (type = schema.nodes.ordered_list) {
                r.wrapOrderedList = wrapListItem(type, {
                    title: "Wrap in ordered list",
                    icon: icons.orderedList
                });
            }
            if (type = schema.nodes.blockquote) {
                r.wrapBlockQuote = wrapItem(type, {
                    title: "Wrap in block quote",
                    icon: icons.blockquote
                });
            }
            if (type = schema.nodes.paragraph) {
                r.makeParagraph = blockTypeItem(type, {
                    title: "Change to paragraph",
                    label: "Plain"
                });
            }
            if (type = schema.nodes.code_block) {
                r.makeCodeBlock = blockTypeItem(type, {
                    title: "Change to code block",
                    label: "Code"
                });
            }
            if (type = schema.nodes.heading) {
                for (var i = 1; i <= 10; i++) {
                    r["makeHead" + i] = blockTypeItem(type, {
                        title: "Change to heading " + i,
                        label: "Level " + i,
                        attrs: {level: i}
                    });
                }
            }
            if (type = schema.nodes.horizontal_rule) {
                var hr = type;
                r.insertHorizontalRule = new MenuItem({
                    title: "Insert horizontal rule",
                    label: "Horizontal rule",
                    select: function select(state) {
                        return canInsert(state, hr);
                    },
                    run: function run(state, dispatch) {
                        dispatch(state.tr.replaceSelectionWith(hr.create()));
                    }
                });
            }
            if (type = schema.nodes.table) {
                r.insertTable = insertTableItem(type);
            }
            if (type = schema.nodes.table_row) {
                r.addRowBefore = cmdItem(addRowBefore, {title: "Add row before"});
                r.addRowAfter = cmdItem(addRowAfter, {title: "Add row after"});
                r.removeRow = cmdItem(removeRow, {title: "Remove row"});
                r.addColumnBefore = cmdItem(addColumnBefore, {title: "Add column before"});
                r.addColumnAfter = cmdItem(addColumnAfter, {title: "Add column after"});
                r.removeColumn = cmdItem(removeColumn, {title: "Remove column"});
            }
            var cut = function(arr) {
                return arr.filter(function(x) {
                    return x;
                });
            };
            r.insertMenu = new Dropdown(cut([r.insertImage, r.insertHorizontalRule, r.insertTable]), {label: "Insert"});
            r.typeMenu = new Dropdown(cut([r.makeParagraph, r.makeCodeBlock, r.makeHead1 && new DropdownSubmenu(cut([r.makeHead1, r.makeHead2, r.makeHead3, r.makeHead4, r.makeHead5, r.makeHead6]), {label: "Heading"})]), {label: "Type..."});
            var tableItems = cut([r.addRowBefore, r.addRowAfter, r.removeRow, r.addColumnBefore, r.addColumnAfter, r.removeColumn]);
            if (tableItems.length) {
                r.tableMenu = new Dropdown(tableItems, {label: "Table"});
            }
            r.inlineMenu = [cut([r.toggleStrong, r.toggleEm, r.toggleCode, r.toggleLink]), [r.insertMenu]];
            r.blockMenu = [cut([r.typeMenu, r.tableMenu, r.wrapBulletList, r.wrapOrderedList, r.wrapBlockQuote, joinUpItem, liftItem, selectParentNodeItem])];
            r.fullMenu = r.inlineMenu.concat(r.blockMenu).concat([[undoItem, redoItem]]);
            return r;
        }
        exports.buildMenuItems = buildMenuItems;
        return module.exports;
    });

    $__System.registerDynamic("2b", ["9", "3", "7"], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        var ref = $__require('9');
        var joinPoint = ref.joinPoint;
        var canJoin = ref.canJoin;
        var findWrapping = ref.findWrapping;
        var liftTarget = ref.liftTarget;
        var canSplit = ref.canSplit;
        var ReplaceAroundStep = ref.ReplaceAroundStep;
        var ref$1 = $__require('3');
        var Slice = ref$1.Slice;
        var Fragment = ref$1.Fragment;
        var ref$2 = $__require('7');
        var Selection = ref$2.Selection;
        var TextSelection = ref$2.TextSelection;
        var NodeSelection = ref$2.NodeSelection;
        function deleteSelection(state, dispatch) {
            if (state.selection.empty) {
                return false;
            }
            if (dispatch) {
                var ref = state.selection;
                var $from = ref.$from;
                var $to = ref.$to;
                var tr = state.tr.deleteSelection().scrollIntoView();
                if ($from.sameParent($to) && $from.parent.isTextblock) {
                    tr.setStoredMarks($from.marks(true));
                }
                dispatch(tr);
            }
            return true;
        }
        exports.deleteSelection = deleteSelection;
        function joinBackward(state, dispatch, view) {
            var ref = state.selection;
            var $head = ref.$head;
            var empty = ref.empty;
            if (!empty || (view ? !view.endOfTextblock("backward", state) : $head.parentOffset > 0)) {
                return false;
            }
            var before,
                cut;
            for (var i = $head.depth - 1; !before && i >= 0; i--) {
                if ($head.index(i) > 0) {
                    cut = $head.before(i + 1);
                    before = $head.node(i).child($head.index(i) - 1);
                }
            }
            if (!before) {
                var range = $head.blockRange(),
                    target = range && liftTarget(range);
                if (target == null) {
                    return false;
                }
                if (dispatch) {
                    dispatch(state.tr.lift(range, target).scrollIntoView());
                }
                return true;
            }
            if (before.isLeaf && NodeSelection.isSelectable(before) && $head.parent.content.size == 0) {
                if (dispatch) {
                    var tr = state.tr.delete(cut, cut + $head.parent.nodeSize);
                    tr.setSelection(NodeSelection.create(tr.doc, cut - before.nodeSize));
                    dispatch(tr.scrollIntoView());
                }
                return true;
            }
            if (before.isLeaf) {
                if (dispatch) {
                    dispatch(state.tr.delete(cut - before.nodeSize, cut).scrollIntoView());
                }
                return true;
            }
            return deleteBarrier(state, cut, dispatch) || selectNextNode(state, cut, -1, dispatch);
        }
        exports.joinBackward = joinBackward;
        function joinForward(state, dispatch, view) {
            var ref = state.selection;
            var $head = ref.$head;
            var empty = ref.empty;
            if (!empty || (view ? !view.endOfTextblock("forward", state) : $head.parentOffset < $head.parent.content.size)) {
                return false;
            }
            var after,
                cut;
            for (var i = $head.depth - 1; !after && i >= 0; i--) {
                var parent = $head.node(i);
                if ($head.index(i) + 1 < parent.childCount) {
                    after = parent.child($head.index(i) + 1);
                    cut = $head.after(i + 1);
                }
            }
            if (!after) {
                return false;
            }
            if (after.isLeaf) {
                if (dispatch) {
                    dispatch(state.tr.delete(cut, cut + after.nodeSize).scrollIntoView());
                }
                return true;
            }
            return deleteBarrier(state, cut, dispatch) || selectNextNode(state, cut, 1, dispatch);
        }
        exports.joinForward = joinForward;
        function joinUp(state, dispatch) {
            var ref = state.selection;
            var node = ref.node;
            var from = ref.from;
            var point;
            if (node) {
                if (node.isTextblock || !canJoin(state.doc, from)) {
                    return false;
                }
                point = from;
            } else {
                point = joinPoint(state.doc, from, -1);
                if (point == null) {
                    return false;
                }
            }
            if (dispatch) {
                var tr = state.tr.join(point);
                if (state.selection.node) {
                    tr.setSelection(NodeSelection.create(tr.doc, point - state.doc.resolve(point).nodeBefore.nodeSize));
                }
                dispatch(tr.scrollIntoView());
            }
            return true;
        }
        exports.joinUp = joinUp;
        function joinDown(state, dispatch) {
            var node = state.selection.node,
                nodeAt = state.selection.from;
            var point = joinPointBelow(state);
            if (!point) {
                return false;
            }
            if (dispatch) {
                var tr = state.tr.join(point);
                if (node) {
                    tr.setSelection(NodeSelection.create(tr.doc, nodeAt));
                }
                dispatch(tr.scrollIntoView());
            }
            return true;
        }
        exports.joinDown = joinDown;
        function lift(state, dispatch) {
            var ref = state.selection;
            var $from = ref.$from;
            var $to = ref.$to;
            var range = $from.blockRange($to),
                target = range && liftTarget(range);
            if (target == null) {
                return false;
            }
            if (dispatch) {
                dispatch(state.tr.lift(range, target).scrollIntoView());
            }
            return true;
        }
        exports.lift = lift;
        function newlineInCode(state, dispatch) {
            var ref = state.selection;
            var $head = ref.$head;
            var anchor = ref.anchor;
            if (!$head || !$head.parent.type.spec.code || $head.sharedDepth(anchor) != $head.depth) {
                return false;
            }
            if (dispatch) {
                dispatch(state.tr.insertText("\n").scrollIntoView());
            }
            return true;
        }
        exports.newlineInCode = newlineInCode;
        function exitCode(state, dispatch) {
            var ref = state.selection;
            var $head = ref.$head;
            var anchor = ref.anchor;
            if (!$head || !$head.parent.type.spec.code || $head.sharedDepth(anchor) != $head.depth) {
                return false;
            }
            var above = $head.node(-1),
                after = $head.indexAfter(-1),
                type = above.defaultContentType(after);
            if (!above.canReplaceWith(after, after, type)) {
                return false;
            }
            if (dispatch) {
                var pos = $head.after(),
                    tr = state.tr.replaceWith(pos, pos, type.createAndFill());
                tr.setSelection(Selection.near(tr.doc.resolve(pos), 1));
                dispatch(tr.scrollIntoView());
            }
            return true;
        }
        exports.exitCode = exitCode;
        function createParagraphNear(state, dispatch) {
            var ref = state.selection;
            var $from = ref.$from;
            var $to = ref.$to;
            var node = ref.node;
            if (!node || !node.isBlock) {
                return false;
            }
            var type = $from.parent.defaultContentType($to.indexAfter());
            if (!type || !type.isTextblock) {
                return false;
            }
            if (dispatch) {
                var side = ($from.parentOffset ? $to : $from).pos;
                var tr = state.tr.insert(side, type.createAndFill());
                tr.setSelection(TextSelection.create(tr.doc, side + 1));
                dispatch(tr.scrollIntoView());
            }
            return true;
        }
        exports.createParagraphNear = createParagraphNear;
        function liftEmptyBlock(state, dispatch) {
            var ref = state.selection;
            var $head = ref.$head;
            var empty = ref.empty;
            if (!empty || $head.parent.content.size) {
                return false;
            }
            if ($head.depth > 1 && $head.after() != $head.end(-1)) {
                var before = $head.before();
                if (canSplit(state.doc, before)) {
                    if (dispatch) {
                        dispatch(state.tr.split(before).scrollIntoView());
                    }
                    return true;
                }
            }
            var range = $head.blockRange(),
                target = range && liftTarget(range);
            if (target == null) {
                return false;
            }
            if (dispatch) {
                dispatch(state.tr.lift(range, target).scrollIntoView());
            }
            return true;
        }
        exports.liftEmptyBlock = liftEmptyBlock;
        function splitBlock(state, dispatch) {
            var ref = state.selection;
            var $from = ref.$from;
            var $to = ref.$to;
            var node = ref.node;
            if (node && node.isBlock) {
                if (!$from.parentOffset || !canSplit(state.doc, $from.pos)) {
                    return false;
                }
                if (dispatch) {
                    dispatch(state.tr.split($from.pos).scrollIntoView());
                }
                return true;
            }
            if (dispatch) {
                var atEnd = $to.parentOffset == $to.parent.content.size;
                var tr = state.tr.delete($from.pos, $to.pos);
                var deflt = $from.depth == 0 ? null : $from.node(-1).defaultContentType($from.indexAfter(-1));
                var types = atEnd ? [{type: deflt}] : null;
                var can = canSplit(tr.doc, $from.pos, 1, types);
                if (!types && !can && canSplit(tr.doc, $from.pos, 1, [{type: deflt}])) {
                    types = [{type: deflt}];
                    can = true;
                }
                if (can) {
                    tr.split($from.pos, 1, types);
                    if (!atEnd && !$from.parentOffset && $from.parent.type != deflt && $from.node(-1).canReplace($from.index(-1), $from.indexAfter(-1), Fragment.from(deflt.create(), $from.parent))) {
                        tr.setNodeType($from.before(), deflt);
                    }
                }
                dispatch(tr.scrollIntoView());
            }
            return true;
        }
        exports.splitBlock = splitBlock;
        function selectParentNode(state, dispatch) {
            var sel = state.selection,
                pos;
            if (sel.node) {
                if (!sel.$from.depth) {
                    return false;
                }
                pos = sel.$from.before();
            } else {
                var same = sel.$head.sharedDepth(sel.anchor);
                if (same == 0) {
                    return false;
                }
                pos = sel.$head.before(same);
            }
            if (dispatch) {
                dispatch(state.tr.setSelection(NodeSelection.create(state.doc, pos)));
            }
            return true;
        }
        exports.selectParentNode = selectParentNode;
        function joinMaybeClear(state, $pos, dispatch) {
            var before = $pos.nodeBefore,
                after = $pos.nodeAfter,
                index = $pos.index();
            if (!before || !after || !before.type.compatibleContent(after.type)) {
                return false;
            }
            if (!before.content.size && $pos.parent.canReplace(index - 1, index)) {
                if (dispatch) {
                    dispatch(state.tr.delete($pos.pos - before.nodeSize, $pos.pos).scrollIntoView());
                }
                return true;
            }
            if (!$pos.parent.canReplace(index, index + 1)) {
                return false;
            }
            if (dispatch) {
                dispatch(state.tr.clearNonMatching($pos.pos, before.contentMatchAt(before.childCount)).join($pos.pos).scrollIntoView());
            }
            return true;
        }
        function deleteBarrier(state, cut, dispatch) {
            var $cut = state.doc.resolve(cut),
                before = $cut.nodeBefore,
                after = $cut.nodeAfter,
                conn,
                match;
            if (joinMaybeClear(state, $cut, dispatch)) {
                return true;
            } else if (after.isTextblock && $cut.parent.canReplace($cut.index(), $cut.index() + 1) && (conn = (match = before.contentMatchAt(before.childCount)).findWrappingFor(after)) && match.matchType((conn[0] || after).type, (conn[0] || after).attrs).validEnd()) {
                if (dispatch) {
                    var end = cut + after.nodeSize,
                        wrap = Fragment.empty;
                    for (var i = conn.length - 1; i >= 0; i--) {
                        wrap = Fragment.from(conn[i].type.create(conn[i].attrs, wrap));
                    }
                    wrap = Fragment.from(before.copy(wrap));
                    var tr = state.tr.step(new ReplaceAroundStep(cut - 1, end, cut, end, new Slice(wrap, 1, 0), conn.length, true));
                    var joinAt = end + 2 * conn.length;
                    if (canJoin(tr.doc, joinAt)) {
                        tr.join(joinAt);
                    }
                    dispatch(tr.scrollIntoView());
                }
                return true;
            } else {
                var selAfter = Selection.findFrom($cut, 1);
                var range = selAfter.$from.blockRange(selAfter.$to),
                    target = range && liftTarget(range);
                if (target == null) {
                    return false;
                }
                if (dispatch) {
                    dispatch(state.tr.lift(range, target).scrollIntoView());
                }
                return true;
            }
        }
        function selectNextNode(state, cut, dir, dispatch) {
            var $cut = state.doc.resolve(cut);
            var node = dir > 0 ? $cut.nodeAfter : $cut.nodeBefore;
            if (!node || !NodeSelection.isSelectable(node)) {
                return false;
            }
            if (dispatch) {
                dispatch(state.tr.setSelection(NodeSelection.create(state.doc, cut - (dir > 0 ? 0 : node.nodeSize))).scrollIntoView());
            }
            return true;
        }
        function joinPointBelow(state) {
            var ref = state.selection;
            var node = ref.node;
            var to = ref.to;
            if (node) {
                return canJoin(state.doc, to) ? to : null;
            } else {
                return joinPoint(state.doc, to, 1);
            }
        }
        function wrapIn(nodeType, attrs) {
            return function(state, dispatch) {
                var ref = state.selection;
                var $from = ref.$from;
                var $to = ref.$to;
                var range = $from.blockRange($to),
                    wrapping = range && findWrapping(range, nodeType, attrs);
                if (!wrapping) {
                    return false;
                }
                if (dispatch) {
                    dispatch(state.tr.wrap(range, wrapping).scrollIntoView());
                }
                return true;
            };
        }
        exports.wrapIn = wrapIn;
        function setBlockType(nodeType, attrs) {
            return function(state, dispatch) {
                var ref = state.selection;
                var $from = ref.$from;
                var $to = ref.$to;
                var node = ref.node;
                var depth;
                if (node) {
                    depth = $from.depth;
                } else {
                    if (!$from.depth || $to.pos > $from.end()) {
                        return false;
                    }
                    depth = $from.depth - 1;
                }
                var target = node || $from.parent;
                if (!target.isTextblock || target.hasMarkup(nodeType, attrs)) {
                    return false;
                }
                var index = $from.index(depth);
                if (!$from.node(depth).canReplaceWith(index, index + 1, nodeType)) {
                    return false;
                }
                if (dispatch) {
                    var where = $from.before(depth + 1);
                    dispatch(state.tr.clearNonMatching(where, nodeType.contentExpr.start(attrs)).setNodeType(where, nodeType, attrs).scrollIntoView());
                }
                return true;
            };
        }
        exports.setBlockType = setBlockType;
        function markApplies(doc, from, to, type) {
            var can = false;
            doc.nodesBetween(from, to, function(node) {
                if (can) {
                    return false;
                }
                can = node.isTextblock && node.contentMatchAt(0).allowsMark(type);
            });
            return can;
        }
        function toggleMark(markType, attrs) {
            return function(state, dispatch) {
                var ref = state.selection;
                var empty = ref.empty;
                var from = ref.from;
                var to = ref.to;
                var $from = ref.$from;
                if (!markApplies(state.doc, from, to, markType)) {
                    return false;
                }
                if (dispatch) {
                    if (empty) {
                        if (markType.isInSet(state.storedMarks || $from.marks())) {
                            dispatch(state.tr.removeStoredMark(markType));
                        } else {
                            dispatch(state.tr.addStoredMark(markType.create(attrs)));
                        }
                    } else {
                        if (state.doc.rangeHasMark(from, to, markType)) {
                            dispatch(state.tr.removeMark(from, to, markType).scrollIntoView());
                        } else {
                            dispatch(state.tr.addMark(from, to, markType.create(attrs)).scrollIntoView());
                        }
                    }
                }
                return true;
            };
        }
        exports.toggleMark = toggleMark;
        function wrapDispatchForJoin(dispatch, isJoinable) {
            return function(tr) {
                if (!tr.isGeneric) {
                    return dispatch(tr);
                }
                var ranges = [];
                for (var i = 0; i < tr.mapping.maps.length; i++) {
                    var map = tr.mapping.maps[i];
                    for (var j = 0; j < ranges.length; j++) {
                        ranges[j] = map.map(ranges[j]);
                    }
                    map.forEach(function(_s, _e, from, to) {
                        return ranges.push(from, to);
                    });
                }
                var joinable = [];
                for (var i$1 = 0; i$1 < ranges.length; i$1 += 2) {
                    var from = ranges[i$1],
                        to = ranges[i$1 + 1];
                    var $from = tr.doc.resolve(from),
                        depth = $from.sharedDepth(to),
                        parent = $from.node(depth);
                    for (var index = $from.indexAfter(depth),
                             pos = $from.after(depth + 1); pos <= to; ++index) {
                        var after = parent.maybeChild(index);
                        if (!after) {
                            break;
                        }
                        if (index && joinable.indexOf(pos) == -1) {
                            var before = parent.child(index - 1);
                            if (before.type == after.type && isJoinable(before, after)) {
                                joinable.push(pos);
                            }
                        }
                        pos += after.nodeSize;
                    }
                }
                joinable.sort(function(a, b) {
                    return a - b;
                });
                for (var i$2 = joinable.length - 1; i$2 >= 0; i$2--) {
                    if (canJoin(tr.doc, joinable[i$2])) {
                        tr.join(joinable[i$2]);
                    }
                }
                dispatch(tr);
            };
        }
        function autoJoin(command, isJoinable) {
            if (Array.isArray(isJoinable)) {
                var types = isJoinable;
                isJoinable = function(node) {
                    return types.indexOf(node.type.name) > -1;
                };
            }
            return function(state, dispatch) {
                return command(state, dispatch && wrapDispatchForJoin(dispatch, isJoinable));
            };
        }
        exports.autoJoin = autoJoin;
        function chainCommands() {
            var commands = [],
                len = arguments.length;
            while (len--)
                commands[len] = arguments[len];
            return function(state, dispatch, view) {
                for (var i = 0; i < commands.length; i++) {
                    if (commands[i](state, dispatch, view)) {
                        return true;
                    }
                }
                return false;
            };
        }
        exports.chainCommands = chainCommands;
        var baseKeymap = {
            "Enter": chainCommands(newlineInCode, createParagraphNear, liftEmptyBlock, splitBlock),
            "Mod-Enter": exitCode,
            "Backspace": chainCommands(deleteSelection, joinBackward),
            "Mod-Backspace": chainCommands(deleteSelection, joinBackward),
            "Delete": chainCommands(deleteSelection, joinForward),
            "Mod-Delete": chainCommands(deleteSelection, joinForward),
            "Alt-ArrowUp": joinUp,
            "Alt-ArrowDown": joinDown,
            "Mod-BracketLeft": lift,
            "Escape": selectParentNode
        };
        var mac = typeof navigator != "undefined" ? /Mac/.test(navigator.platform) : typeof os != "undefined" ? os.platform() == "darwin" : false;
        if (mac) {
            var extra = {
                "Ctrl-h": baseKeymap["Backspace"],
                "Alt-Backspace": baseKeymap["Mod-Backspace"],
                "Ctrl-d": baseKeymap["Delete"],
                "Ctrl-Alt-Backspace": baseKeymap["Mod-Delete"],
                "Alt-Delete": baseKeymap["Mod-Delete"],
                "Alt-d": baseKeymap["Mod-Delete"]
            };
            for (var prop in extra) {
                baseKeymap[prop] = extra[prop];
            }
        }
        exports.baseKeymap = baseKeymap;
        return module.exports;
    });

    $__System.registerDynamic("22", ["2b"], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        module.exports = $__require('2b');
        return module.exports;
    });

    $__System.registerDynamic("2c", ["3", "9", "7"], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        var ref = $__require('3');
        var Fragment = ref.Fragment;
        var Slice = ref.Slice;
        var ref$1 = $__require('9');
        var Step = ref$1.Step;
        var StepResult = ref$1.StepResult;
        var StepMap = ref$1.StepMap;
        var ReplaceStep = ref$1.ReplaceStep;
        var ref$2 = $__require('7');
        var Selection = ref$2.Selection;
        var table = {
            attrs: {columns: {default: 1}},
            parseDOM: [{
                tag: "table",
                getAttrs: function getAttrs(dom) {
                    var row = dom.querySelector("tr");
                    if (!row || !row.children.length) {
                        return false;
                    }
                    return {columns: row.children.length};
                }
            }],
            toDOM: function toDOM() {
                return ["table", ["tbody", 0]];
            }
        };
        exports.table = table;
        var tableRow = {
            attrs: {columns: {default: 1}},
            parseDOM: [{
                tag: "tr",
                getAttrs: function(dom) {
                    return dom.children.length ? {columns: dom.children.length} : false;
                }
            }],
            toDOM: function toDOM() {
                return ["tr", 0];
            },
            tableRow: true
        };
        exports.tableRow = tableRow;
        var tableCell = {
            parseDOM: [{tag: "td"}],
            toDOM: function toDOM() {
                return ["td", 0];
            }
        };
        exports.tableCell = tableCell;
        function add(obj, props) {
            var copy = {};
            for (var prop in obj) {
                copy[prop] = obj[prop];
            }
            for (var prop$1 in props) {
                copy[prop$1] = props[prop$1];
            }
            return copy;
        }
        function addTableNodes(nodes, cellContent, tableGroup) {
            return nodes.append({
                table: add(table, {
                    content: "table_row[columns=.columns]+",
                    group: tableGroup
                }),
                table_row: add(tableRow, {content: "table_cell{.columns}"}),
                table_cell: add(tableCell, {content: cellContent})
            });
        }
        exports.addTableNodes = addTableNodes;
        function createTable(nodeType, rows, columns, attrs) {
            attrs = setColumns(attrs, columns);
            var rowType = nodeType.contentExpr.elements[0].nodeTypes[0];
            var cellType = rowType.contentExpr.elements[0].nodeTypes[0];
            var cell = cellType.createAndFill(),
                cells = [];
            for (var i = 0; i < columns; i++) {
                cells.push(cell);
            }
            var row = rowType.create({columns: columns}, Fragment.from(cells)),
                rowNodes = [];
            for (var i$1 = 0; i$1 < rows; i$1++) {
                rowNodes.push(row);
            }
            return nodeType.create(attrs, Fragment.from(rowNodes));
        }
        exports.createTable = createTable;
        function setColumns(attrs, columns) {
            var result = Object.create(null);
            if (attrs) {
                for (var prop in attrs) {
                    result[prop] = attrs[prop];
                }
            }
            result.columns = columns;
            return result;
        }
        function adjustColumns(attrs, diff) {
            return setColumns(attrs, attrs.columns + diff);
        }
        var AddColumnStep = (function(Step) {
            function AddColumnStep(positions, cells) {
                Step.call(this);
                this.positions = positions;
                this.cells = cells;
            }
            if (Step)
                AddColumnStep.__proto__ = Step;
            AddColumnStep.prototype = Object.create(Step && Step.prototype);
            AddColumnStep.prototype.constructor = AddColumnStep;
            AddColumnStep.create = function create(doc, tablePos, columnIndex, cellType, cellAttrs) {
                var cell = cellType.createAndFill(cellAttrs);
                var positions = [],
                    cells = [];
                var table = doc.nodeAt(tablePos);
                table.forEach(function(row, rowOff) {
                    var cellPos = tablePos + 2 + rowOff;
                    for (var i = 0; i < columnIndex; i++) {
                        cellPos += row.child(i).nodeSize;
                    }
                    positions.push(cellPos);
                    cells.push(cell);
                });
                return new AddColumnStep(positions, cells);
            };
            AddColumnStep.prototype.apply = function apply(doc) {
                var this$1 = this;
                var index = null,
                    table = null,
                    tablePos = null;
                for (var i = 0; i < this.positions.length; i++) {
                    var $pos = doc.resolve(this$1.positions[i]);
                    if ($pos.depth < 2 || $pos.index(-1) != i) {
                        return StepResult.fail("Invalid cell insert position");
                    }
                    if (table == null) {
                        table = $pos.node(-1);
                        if (table.childCount != this$1.positions.length) {
                            return StepResult.fail("Mismatch in number of rows");
                        }
                        tablePos = $pos.before(-1);
                        index = $pos.index();
                    } else if ($pos.before(-1) != tablePos || $pos.index() != index) {
                        return StepResult.fail("Column insert positions not consistent");
                    }
                }
                var updatedRows = [];
                for (var i$1 = 0; i$1 < table.childCount; i$1++) {
                    var row = table.child(i$1),
                        rowCells = index ? [] : [this$1.cells[i$1]];
                    for (var j = 0; j < row.childCount; j++) {
                        rowCells.push(row.child(j));
                        if (j + 1 == index) {
                            rowCells.push(this$1.cells[i$1]);
                        }
                    }
                    updatedRows.push(row.type.create(adjustColumns(row.attrs, 1), Fragment.from(rowCells)));
                }
                var updatedTable = table.type.create(adjustColumns(table.attrs, 1), Fragment.from(updatedRows));
                return StepResult.fromReplace(doc, tablePos, tablePos + table.nodeSize, new Slice(Fragment.from(updatedTable), 0, 0));
            };
            AddColumnStep.prototype.getMap = function getMap() {
                var this$1 = this;
                var ranges = [];
                for (var i = 0; i < this.positions.length; i++) {
                    ranges.push(this$1.positions[i], 0, this$1.cells[i].nodeSize);
                }
                return new StepMap(ranges);
            };
            AddColumnStep.prototype.invert = function invert(doc) {
                var this$1 = this;
                var $first = doc.resolve(this.positions[0]);
                var table = $first.node(-1);
                var from = [],
                    to = [],
                    dPos = 0;
                for (var i = 0; i < table.childCount; i++) {
                    var pos = this$1.positions[i] + dPos,
                        size = this$1.cells[i].nodeSize;
                    from.push(pos);
                    to.push(pos + size);
                    dPos += size;
                }
                return new RemoveColumnStep(from, to);
            };
            AddColumnStep.prototype.map = function map(mapping) {
                return new AddColumnStep(this.positions.map(function(p) {
                    return mapping.map(p);
                }), this.cells);
            };
            AddColumnStep.prototype.toJSON = function toJSON() {
                return {
                    stepType: this.jsonID,
                    positions: this.positions,
                    cells: this.cells.map(function(c) {
                        return c.toJSON();
                    })
                };
            };
            AddColumnStep.fromJSON = function fromJSON(schema, json) {
                return new AddColumnStep(json.positions, json.cells.map(schema.nodeFromJSON));
            };
            return AddColumnStep;
        }(Step));
        exports.AddColumnStep = AddColumnStep;
        Step.jsonID("addTableColumn", AddColumnStep);
        var RemoveColumnStep = (function(Step) {
            function RemoveColumnStep(from, to) {
                Step.call(this);
                this.from = from;
                this.to = to;
            }
            if (Step)
                RemoveColumnStep.__proto__ = Step;
            RemoveColumnStep.prototype = Object.create(Step && Step.prototype);
            RemoveColumnStep.prototype.constructor = RemoveColumnStep;
            RemoveColumnStep.create = function create(doc, tablePos, columnIndex) {
                var from = [],
                    to = [];
                var table = doc.nodeAt(tablePos);
                table.forEach(function(row, rowOff) {
                    var cellPos = tablePos + 2 + rowOff;
                    for (var i = 0; i < columnIndex; i++) {
                        cellPos += row.child(i).nodeSize;
                    }
                    from.push(cellPos);
                    to.push(cellPos + row.child(columnIndex).nodeSize);
                });
                return new RemoveColumnStep(from, to);
            };
            RemoveColumnStep.prototype.apply = function apply(doc) {
                var this$1 = this;
                var index = null,
                    table = null,
                    tablePos = null;
                for (var i = 0; i < this.from.length; i++) {
                    var $from = doc.resolve(this$1.from[i]),
                        after = $from.nodeAfter;
                    if ($from.depth < 2 || $from.index(-1) != i || !after || this$1.from[i] + after.nodeSize != this$1.to[i]) {
                        return StepResult.fail("Invalid cell delete positions");
                    }
                    if (table == null) {
                        table = $from.node(-1);
                        if (table.childCount != this$1.from.length) {
                            return StepResult.fail("Mismatch in number of rows");
                        }
                        tablePos = $from.before(-1);
                        index = $from.index();
                    } else if ($from.before(-1) != tablePos || $from.index() != index) {
                        return StepResult.fail("Column delete positions not consistent");
                    }
                }
                var updatedRows = [];
                for (var i$1 = 0; i$1 < table.childCount; i$1++) {
                    var row = table.child(i$1),
                        rowCells = [];
                    for (var j = 0; j < row.childCount; j++) {
                        if (j != index) {
                            rowCells.push(row.child(j));
                        }
                    }
                    updatedRows.push(row.type.create(adjustColumns(row.attrs, -1), Fragment.from(rowCells)));
                }
                var updatedTable = table.type.create(adjustColumns(table.attrs, -1), Fragment.from(updatedRows));
                return StepResult.fromReplace(doc, tablePos, tablePos + table.nodeSize, new Slice(Fragment.from(updatedTable), 0, 0));
            };
            RemoveColumnStep.prototype.getMap = function getMap() {
                var this$1 = this;
                var ranges = [];
                for (var i = 0; i < this.from.length; i++) {
                    ranges.push(this$1.from[i], this$1.to[i] - this$1.from[i], 0);
                }
                return new StepMap(ranges);
            };
            RemoveColumnStep.prototype.invert = function invert(doc) {
                var this$1 = this;
                var $first = doc.resolve(this.from[0]);
                var table = $first.node(-1),
                    index = $first.index();
                var positions = [],
                    cells = [],
                    dPos = 0;
                for (var i = 0; i < table.childCount; i++) {
                    positions.push(this$1.from[i] - dPos);
                    var cell = table.child(i).child(index);
                    dPos += cell.nodeSize;
                    cells.push(cell);
                }
                return new AddColumnStep(positions, cells);
            };
            RemoveColumnStep.prototype.map = function map(mapping) {
                var this$1 = this;
                var from = [],
                    to = [];
                for (var i = 0; i < this.from.length; i++) {
                    var start = mapping.map(this$1.from[i], 1),
                        end = mapping.map(this$1.to[i], -1);
                    if (end <= start) {
                        return null;
                    }
                    from.push(start);
                    to.push(end);
                }
                return new RemoveColumnStep(from, to);
            };
            RemoveColumnStep.fromJSON = function fromJSON(_schema, json) {
                return new RemoveColumnStep(json.from, json.to);
            };
            return RemoveColumnStep;
        }(Step));
        exports.RemoveColumnStep = RemoveColumnStep;
        Step.jsonID("removeTableColumn", RemoveColumnStep);
        function findRow($pos, pred) {
            for (var d = $pos.depth; d > 0; d--) {
                if ($pos.node(d).type.spec.tableRow && (!pred || pred(d))) {
                    return d;
                }
            }
            return -1;
        }
        function addColumnBefore(state, dispatch) {
            var $from = state.selection.$from,
                cellFrom;
            var rowDepth = findRow($from, function(d) {
                return cellFrom = d == $from.depth ? $from.nodeBefore : $from.node(d + 1);
            });
            if (rowDepth == -1) {
                return false;
            }
            if (dispatch) {
                dispatch(state.tr.step(AddColumnStep.create(state.doc, $from.before(rowDepth - 1), $from.index(rowDepth), cellFrom.type, cellFrom.attrs)));
            }
            return true;
        }
        exports.addColumnBefore = addColumnBefore;
        function addColumnAfter(state, dispatch) {
            var $from = state.selection.$from,
                cellFrom;
            var rowDepth = findRow($from, function(d) {
                return cellFrom = d == $from.depth ? $from.nodeAfter : $from.node(d + 1);
            });
            if (rowDepth == -1) {
                return false;
            }
            if (dispatch) {
                dispatch(state.tr.step(AddColumnStep.create(state.doc, $from.before(rowDepth - 1), $from.indexAfter(rowDepth) + (rowDepth == $from.depth ? 1 : 0), cellFrom.type, cellFrom.attrs)));
            }
            return true;
        }
        exports.addColumnAfter = addColumnAfter;
        function removeColumn(state, dispatch) {
            var $from = state.selection.$from;
            var rowDepth = findRow($from, function(d) {
                return $from.node(d).childCount > 1;
            });
            if (rowDepth == -1) {
                return false;
            }
            if (dispatch) {
                dispatch(state.tr.step(RemoveColumnStep.create(state.doc, $from.before(rowDepth - 1), $from.index(rowDepth))));
            }
            return true;
        }
        exports.removeColumn = removeColumn;
        function addRow(state, dispatch, side) {
            var $from = state.selection.$from;
            var rowDepth = findRow($from);
            if (rowDepth == -1) {
                return false;
            }
            if (dispatch) {
                var exampleRow = $from.node(rowDepth);
                var cells = [],
                    pos = side < 0 ? $from.before(rowDepth) : $from.after(rowDepth);
                exampleRow.forEach(function(cell) {
                    return cells.push(cell.type.createAndFill(cell.attrs));
                });
                var row = exampleRow.copy(Fragment.from(cells));
                dispatch(state.tr.step(new ReplaceStep(pos, pos, new Slice(Fragment.from(row), 0, 0))));
            }
            return true;
        }
        function addRowBefore(state, dispatch) {
            return addRow(state, dispatch, -1);
        }
        exports.addRowBefore = addRowBefore;
        function addRowAfter(state, dispatch) {
            return addRow(state, dispatch, 1);
        }
        exports.addRowAfter = addRowAfter;
        function removeRow(state, dispatch) {
            var $from = state.selection.$from;
            var rowDepth = findRow($from, function(d) {
                return $from.node(d - 1).childCount > 1;
            });
            if (rowDepth == -1) {
                return false;
            }
            if (dispatch) {
                dispatch(state.tr.step(new ReplaceStep($from.before(rowDepth), $from.after(rowDepth), Slice.empty)));
            }
            return true;
        }
        exports.removeRow = removeRow;
        function moveCell(state, dir, dispatch) {
            var ref = state.selection;
            var $from = ref.$from;
            var rowDepth = findRow($from);
            if (rowDepth == -1) {
                return false;
            }
            var row = $from.node(rowDepth),
                newIndex = $from.index(rowDepth) + dir;
            if (newIndex >= 0 && newIndex < row.childCount) {
                var $cellStart = state.doc.resolve(row.content.offsetAt(newIndex) + $from.start(rowDepth));
                var sel = Selection.findFrom($cellStart, 1);
                if (!sel || sel.from >= $cellStart.end()) {
                    return false;
                }
                if (dispatch) {
                    dispatch(state.tr.setSelection(sel).scrollIntoView());
                }
                return true;
            } else {
                var rowIndex = $from.index(rowDepth - 1) + dir,
                    table = $from.node(rowDepth - 1);
                if (rowIndex < 0 || rowIndex >= table.childCount) {
                    return false;
                }
                var cellStart = dir > 0 ? $from.after(rowDepth) + 2 : $from.before(rowDepth) - 2 - table.child(rowIndex).lastChild.content.size;
                var $cellStart$1 = state.doc.resolve(cellStart),
                    sel$1 = Selection.findFrom($cellStart$1, 1);
                if (!sel$1 || sel$1.from >= $cellStart$1.end()) {
                    return false;
                }
                if (dispatch) {
                    dispatch(state.tr.setSelection(sel$1).scrollIntoView());
                }
                return true;
            }
        }
        function selectNextCell(state, dispatch) {
            return moveCell(state, 1, dispatch);
        }
        exports.selectNextCell = selectNextCell;
        function selectPreviousCell(state, dispatch) {
            return moveCell(state, -1, dispatch);
        }
        exports.selectPreviousCell = selectPreviousCell;
        return module.exports;
    });

    $__System.registerDynamic("29", ["2c"], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        module.exports = $__require('2c');
        return module.exports;
    });

    $__System.registerDynamic("2d", [], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        var GOOD_LEAF_SIZE = 200;
        var RopeSequence = function RopeSequence() {};
        RopeSequence.prototype.append = function append(other) {
            if (!other.length) {
                return this;
            }
            other = RopeSequence.from(other);
            return (!this.length && other) || (other.length < GOOD_LEAF_SIZE && this.leafAppend(other)) || (this.length < GOOD_LEAF_SIZE && other.leafPrepend(this)) || this.appendInner(other);
        };
        RopeSequence.prototype.prepend = function prepend(other) {
            if (!other.length) {
                return this;
            }
            return RopeSequence.from(other).append(this);
        };
        RopeSequence.prototype.appendInner = function appendInner(other) {
            return new Append(this, other);
        };
        RopeSequence.prototype.slice = function slice(from, to) {
            if (from === void 0)
                from = 0;
            if (to === void 0)
                to = this.length;
            if (from >= to) {
                return RopeSequence.empty;
            }
            return this.sliceInner(Math.max(0, from), Math.min(this.length, to));
        };
        RopeSequence.prototype.get = function get(i) {
            if (i < 0 || i >= this.length) {
                return undefined;
            }
            return this.getInner(i);
        };
        RopeSequence.prototype.forEach = function forEach(f, from, to) {
            if (from === void 0)
                from = 0;
            if (to === void 0)
                to = this.length;
            if (from <= to) {
                this.forEachInner(f, from, to, 0);
            } else {
                this.forEachInvertedInner(f, from, to, 0);
            }
        };
        RopeSequence.prototype.map = function map(f, from, to) {
            if (from === void 0)
                from = 0;
            if (to === void 0)
                to = this.length;
            var result = [];
            this.forEach(function(elt, i) {
                return result.push(f(elt, i));
            }, from, to);
            return result;
        };
        RopeSequence.from = function from(values) {
            if (values instanceof RopeSequence) {
                return values;
            }
            return values && values.length ? new Leaf(values) : RopeSequence.empty;
        };
        var Leaf = (function(RopeSequence) {
            function Leaf(values) {
                RopeSequence.call(this);
                this.values = values;
            }
            if (RopeSequence)
                Leaf.__proto__ = RopeSequence;
            Leaf.prototype = Object.create(RopeSequence && RopeSequence.prototype);
            Leaf.prototype.constructor = Leaf;
            var prototypeAccessors = {
                length: {},
                depth: {}
            };
            Leaf.prototype.flatten = function flatten() {
                return this.values;
            };
            Leaf.prototype.sliceInner = function sliceInner(from, to) {
                if (from == 0 && to == this.length) {
                    return this;
                }
                return new Leaf(this.values.slice(from, to));
            };
            Leaf.prototype.getInner = function getInner(i) {
                return this.values[i];
            };
            Leaf.prototype.forEachInner = function forEachInner(f, from, to, start) {
                var this$1 = this;
                for (var i = from; i < to; i++) {
                    if (f(this$1.values[i], start + i) === false) {
                        return false;
                    }
                }
            };
            Leaf.prototype.forEachInvertedInner = function forEachInvertedInner(f, from, to, start) {
                var this$1 = this;
                for (var i = from - 1; i >= to; i--) {
                    if (f(this$1.values[i], start + i) === false) {
                        return false;
                    }
                }
            };
            Leaf.prototype.leafAppend = function leafAppend(other) {
                if (this.length + other.length <= GOOD_LEAF_SIZE) {
                    return new Leaf(this.values.concat(other.flatten()));
                }
            };
            Leaf.prototype.leafPrepend = function leafPrepend(other) {
                if (this.length + other.length <= GOOD_LEAF_SIZE) {
                    return new Leaf(other.flatten().concat(this.values));
                }
            };
            prototypeAccessors.length.get = function() {
                return this.values.length;
            };
            prototypeAccessors.depth.get = function() {
                return 0;
            };
            Object.defineProperties(Leaf.prototype, prototypeAccessors);
            return Leaf;
        }(RopeSequence));
        RopeSequence.empty = new Leaf([]);
        var Append = (function(RopeSequence) {
            function Append(left, right) {
                RopeSequence.call(this);
                this.left = left;
                this.right = right;
                this.length = left.length + right.length;
                this.depth = Math.max(left.depth, right.depth) + 1;
            }
            if (RopeSequence)
                Append.__proto__ = RopeSequence;
            Append.prototype = Object.create(RopeSequence && RopeSequence.prototype);
            Append.prototype.constructor = Append;
            Append.prototype.flatten = function flatten() {
                return this.left.flatten().concat(this.right.flatten());
            };
            Append.prototype.getInner = function getInner(i) {
                return i < this.left.length ? this.left.get(i) : this.right.get(i - this.left.length);
            };
            Append.prototype.forEachInner = function forEachInner(f, from, to, start) {
                var leftLen = this.left.length;
                if (from < leftLen && this.left.forEachInner(f, from, Math.min(to, leftLen), start) === false) {
                    return false;
                }
                if (to > leftLen && this.right.forEachInner(f, Math.max(from - leftLen, 0), Math.min(this.length, to) - leftLen, start + leftLen) === false) {
                    return false;
                }
            };
            Append.prototype.forEachInvertedInner = function forEachInvertedInner(f, from, to, start) {
                var leftLen = this.left.length;
                if (from > leftLen && this.right.forEachInvertedInner(f, from - leftLen, Math.max(to, leftLen) - leftLen, start + leftLen) === false) {
                    return false;
                }
                if (to < leftLen && this.left.forEachInvertedInner(f, Math.min(from, leftLen), to, start) === false) {
                    return false;
                }
            };
            Append.prototype.sliceInner = function sliceInner(from, to) {
                if (from == 0 && to == this.length) {
                    return this;
                }
                var leftLen = this.left.length;
                if (to <= leftLen) {
                    return this.left.slice(from, to);
                }
                if (from >= leftLen) {
                    return this.right.slice(from - leftLen, to - leftLen);
                }
                return this.left.slice(from, leftLen).append(this.right.slice(0, to - leftLen));
            };
            Append.prototype.leafAppend = function leafAppend(other) {
                var inner = this.right.leafAppend(other);
                if (inner) {
                    return new Append(this.left, inner);
                }
            };
            Append.prototype.leafPrepend = function leafPrepend(other) {
                var inner = this.left.leafPrepend(other);
                if (inner) {
                    return new Append(inner, this.right);
                }
            };
            Append.prototype.appendInner = function appendInner(other) {
                if (this.left.depth >= Math.max(this.right.depth, other.depth) + 1) {
                    return new Append(this.left, new Append(this.right, other));
                }
                return new Append(this, other);
            };
            return Append;
        }(RopeSequence));
        module.exports = RopeSequence;
        return module.exports;
    });

    $__System.registerDynamic("2e", ["2d"], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        module.exports = $__require('2d');
        return module.exports;
    });

    $__System.registerDynamic("2f", [], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        var Selection = function Selection($from, $to) {
            this.$from = $from;
            this.$to = $to;
        };
        var prototypeAccessors = {
            from: {},
            to: {},
            empty: {}
        };
        prototypeAccessors.from.get = function() {
            return this.$from.pos;
        };
        prototypeAccessors.to.get = function() {
            return this.$to.pos;
        };
        prototypeAccessors.empty.get = function() {
            return this.from == this.to;
        };
        Selection.findFrom = function findFrom($pos, dir, textOnly) {
            var inner = $pos.parent.isTextblock ? new TextSelection($pos) : findSelectionIn($pos.node(0), $pos.parent, $pos.pos, $pos.index(), dir, textOnly);
            if (inner) {
                return inner;
            }
            for (var depth = $pos.depth - 1; depth >= 0; depth--) {
                var found = dir < 0 ? findSelectionIn($pos.node(0), $pos.node(depth), $pos.before(depth + 1), $pos.index(depth), dir, textOnly) : findSelectionIn($pos.node(0), $pos.node(depth), $pos.after(depth + 1), $pos.index(depth) + 1, dir, textOnly);
                if (found) {
                    return found;
                }
            }
        };
        Selection.near = function near($pos, bias) {
            if (bias === void 0)
                bias = 1;
            var result = this.findFrom($pos, bias) || this.findFrom($pos, -bias);
            if (!result) {
                throw new RangeError("Searching for selection in invalid document " + $pos.node(0));
            }
            return result;
        };
        Selection.atStart = function atStart(doc, textOnly) {
            return findSelectionIn(doc, doc, 0, 0, 1, textOnly);
        };
        Selection.atEnd = function atEnd(doc, textOnly) {
            return findSelectionIn(doc, doc, doc.content.size, doc.childCount, -1, textOnly);
        };
        Selection.between = function between($anchor, $head, bias) {
            var found = Selection.near($head, bias);
            if (found instanceof TextSelection) {
                var nearAnchor = Selection.findFrom($anchor, $anchor.pos > found.to ? -1 : 1, true);
                found = new TextSelection(nearAnchor.$anchor, found.$head);
            } else if ($anchor.pos < found.from || $anchor.pos > found.to) {
                var inv = $anchor.pos > found.to;
                var foundAnchor = Selection.findFrom($anchor, inv ? -1 : 1, true);
                var foundHead = Selection.findFrom(inv ? found.$from : found.$to, inv ? 1 : -1, true);
                if (foundAnchor && foundHead) {
                    found = new TextSelection(foundAnchor.$anchor, foundHead.$head);
                }
            }
            return found;
        };
        Selection.mapJSON = function mapJSON(json, mapping) {
            if (json.anchor != null) {
                return {
                    head: mapping.map(json.head),
                    anchor: mapping.map(json.anchor)
                };
            } else {
                return {
                    node: mapping.map(json.node),
                    after: mapping.map(json.after, -1)
                };
            }
        };
        Selection.fromJSON = function fromJSON(doc, json) {
            if (json.head != null) {
                var $anchor = doc.resolve(json.anchor),
                    $head = doc.resolve(json.head);
                if ($anchor.parent.isTextblock && $head.parent.isTextblock) {
                    return new TextSelection($anchor, $head);
                } else {
                    return Selection.between($anchor, $head);
                }
            } else {
                var $pos = doc.resolve(json.node),
                    after = $pos.nodeAfter;
                if (after && json.after == json.pos + after.nodeSize && NodeSelection.isSelectable(after)) {
                    return new NodeSelection($pos);
                } else {
                    return Selection.near($pos);
                }
            }
        };
        Object.defineProperties(Selection.prototype, prototypeAccessors);
        exports.Selection = Selection;
        var TextSelection = (function(Selection) {
            function TextSelection($anchor, $head) {
                if ($head === void 0)
                    $head = $anchor;
                var inv = $anchor.pos > $head.pos;
                Selection.call(this, inv ? $head : $anchor, inv ? $anchor : $head);
                this.$anchor = $anchor;
                this.$head = $head;
            }
            if (Selection)
                TextSelection.__proto__ = Selection;
            TextSelection.prototype = Object.create(Selection && Selection.prototype);
            TextSelection.prototype.constructor = TextSelection;
            var prototypeAccessors$1 = {
                anchor: {},
                head: {},
                inverted: {}
            };
            prototypeAccessors$1.anchor.get = function() {
                return this.$anchor.pos;
            };
            prototypeAccessors$1.head.get = function() {
                return this.$head.pos;
            };
            prototypeAccessors$1.inverted.get = function() {
                return this.anchor > this.head;
            };
            TextSelection.prototype.eq = function eq(other) {
                return other instanceof TextSelection && other.head == this.head && other.anchor == this.anchor;
            };
            TextSelection.prototype.map = function map(doc, mapping) {
                var $head = doc.resolve(mapping.map(this.head));
                if (!$head.parent.isTextblock) {
                    return Selection.near($head);
                }
                var $anchor = doc.resolve(mapping.map(this.anchor));
                return new TextSelection($anchor.parent.isTextblock ? $anchor : $head, $head);
            };
            TextSelection.prototype.toJSON = function toJSON() {
                return {
                    head: this.head,
                    anchor: this.anchor
                };
            };
            TextSelection.create = function create(doc, anchor, head) {
                if (head === void 0)
                    head = anchor;
                var $anchor = doc.resolve(anchor);
                return new this($anchor, head == anchor ? $anchor : doc.resolve(head));
            };
            Object.defineProperties(TextSelection.prototype, prototypeAccessors$1);
            return TextSelection;
        }(Selection));
        exports.TextSelection = TextSelection;
        var NodeSelection = (function(Selection) {
            function NodeSelection($from) {
                var $to = $from.node(0).resolve($from.pos + $from.nodeAfter.nodeSize);
                Selection.call(this, $from, $to);
                this.node = $from.nodeAfter;
            }
            if (Selection)
                NodeSelection.__proto__ = Selection;
            NodeSelection.prototype = Object.create(Selection && Selection.prototype);
            NodeSelection.prototype.constructor = NodeSelection;
            NodeSelection.prototype.eq = function eq(other) {
                return other instanceof NodeSelection && this.from == other.from;
            };
            NodeSelection.prototype.map = function map(doc, mapping) {
                var from = mapping.mapResult(this.from, 1),
                    to = mapping.mapResult(this.to, -1);
                var $from = doc.resolve(from.pos),
                    node = $from.nodeAfter;
                if (!from.deleted && !to.deleted && node && to.pos == from.pos + node.nodeSize && NodeSelection.isSelectable(node)) {
                    return new NodeSelection($from);
                }
                return Selection.near($from);
            };
            NodeSelection.prototype.toJSON = function toJSON() {
                return {
                    node: this.from,
                    after: this.to
                };
            };
            NodeSelection.create = function create(doc, from) {
                return new this(doc.resolve(from));
            };
            NodeSelection.isSelectable = function isSelectable(node) {
                return !node.isText && node.type.spec.selectable !== false;
            };
            return NodeSelection;
        }(Selection));
        exports.NodeSelection = NodeSelection;
        function findSelectionIn(doc, node, pos, index, dir, text) {
            if (node.isTextblock) {
                return TextSelection.create(doc, pos);
            }
            for (var i = index - (dir > 0 ? 0 : 1); dir > 0 ? i < node.childCount : i >= 0; i += dir) {
                var child = node.child(i);
                if (!child.isLeaf) {
                    var inner = findSelectionIn(doc, child, pos + dir, dir < 0 ? child.childCount : 0, dir, text);
                    if (inner) {
                        return inner;
                    }
                } else if (!text && NodeSelection.isSelectable(child)) {
                    return NodeSelection.create(doc, pos - (dir < 0 ? child.nodeSize : 0));
                }
                pos += child.nodeSize * dir;
            }
        }
        return module.exports;
    });

    $__System.registerDynamic("30", ["9", "3", "2f"], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        var ref = $__require('9');
        var Transform = ref.Transform;
        var ref$1 = $__require('3');
        var Mark = ref$1.Mark;
        var ref$2 = $__require('2f');
        var Selection = ref$2.Selection;
        var UPDATED_SEL = 1,
            UPDATED_MARKS = 2,
            UPDATED_SCROLL = 4;
        var Transaction = (function(Transform) {
            function Transaction(state) {
                Transform.call(this, state.doc);
                this.time = Date.now();
                this.curSelection = state.selection;
                this.curSelectionFor = 0;
                this.storedMarks = state.storedMarks;
                this.updated = 0;
                this.meta = Object.create(null);
            }
            if (Transform)
                Transaction.__proto__ = Transform;
            Transaction.prototype = Object.create(Transform && Transform.prototype);
            Transaction.prototype.constructor = Transaction;
            var prototypeAccessors = {
                docChanged: {},
                selection: {},
                selectionSet: {},
                storedMarksSet: {},
                isGeneric: {},
                scrolledIntoView: {}
            };
            prototypeAccessors.docChanged.get = function() {
                return this.steps.length > 0;
            };
            prototypeAccessors.selection.get = function() {
                if (this.curSelectionFor < this.steps.length) {
                    this.curSelection = this.curSelection.map(this.doc, this.mapping.slice(this.curSelectionFor));
                    this.curSelectionFor = this.steps.length;
                }
                return this.curSelection;
            };
            Transaction.prototype.setSelection = function setSelection(selection) {
                this.curSelection = selection;
                this.curSelectionFor = this.steps.length;
                this.updated = (this.updated | UPDATED_SEL) & ~UPDATED_MARKS;
                this.storedMarks = null;
                return this;
            };
            prototypeAccessors.selectionSet.get = function() {
                return this.updated & UPDATED_SEL > 0;
            };
            Transaction.prototype.setStoredMarks = function setStoredMarks(marks) {
                this.storedMarks = marks;
                this.updated |= UPDATED_MARKS;
                return this;
            };
            prototypeAccessors.storedMarksSet.get = function() {
                return this.updated & UPDATED_MARKS > 0;
            };
            Transaction.prototype.addStep = function addStep(step, doc) {
                Transform.prototype.addStep.call(this, step, doc);
                this.updated = this.updated & ~UPDATED_MARKS;
                this.storedMarks = null;
            };
            Transaction.prototype.setTime = function setTime(time) {
                this.time = time;
                return this;
            };
            Transaction.prototype.replaceSelection = function replaceSelection(slice) {
                var ref = this.selection;
                var from = ref.from;
                var to = ref.to;
                var startLen = this.steps.length;
                this.replaceRange(from, to, slice);
                var lastNode = slice.content.lastChild,
                    lastParent = null;
                for (var i = 0; i < slice.openRight; i++) {
                    lastParent = lastNode;
                    lastNode = lastNode.lastChild;
                }
                selectionToInsertionEnd(this, startLen, (lastNode ? lastNode.isInline : lastParent && lastParent.isTextblock) ? -1 : 1);
                return this;
            };
            Transaction.prototype.replaceSelectionWith = function replaceSelectionWith(node, inheritMarks) {
                var ref = this.selection;
                var $from = ref.$from;
                var from = ref.from;
                var to = ref.to;
                var startLen = this.steps.length;
                if (inheritMarks !== false) {
                    node = node.mark(this.storedMarks || $from.marks(to > from));
                }
                this.replaceRangeWith(from, to, node);
                selectionToInsertionEnd(this, startLen, node.isInline ? -1 : 1);
                return this;
            };
            Transaction.prototype.deleteSelection = function deleteSelection() {
                var ref = this.selection;
                var from = ref.from;
                var to = ref.to;
                return this.deleteRange(from, to);
            };
            Transaction.prototype.insertText = function insertText(text, from, to) {
                if (to === void 0)
                    to = from;
                var schema = this.doc.type.schema;
                if (from == null) {
                    if (!text) {
                        return this.deleteSelection();
                    }
                    return this.replaceSelectionWith(schema.text(text), true);
                } else {
                    if (!text) {
                        return this.deleteRange(from, to);
                    }
                    var node = schema.text(text, this.storedMarks || this.doc.resolve(from).marks(to > from));
                    return this.replaceRangeWith(from, to, node);
                }
            };
            Transaction.prototype.setMeta = function setMeta(key, value) {
                this.meta[typeof key == "string" ? key : key.key] = value;
                return this;
            };
            Transaction.prototype.getMeta = function getMeta(key) {
                return this.meta[typeof key == "string" ? key : key.key];
            };
            prototypeAccessors.isGeneric.get = function() {
                var this$1 = this;
                for (var _ in this$1.meta) {
                    return false;
                }
                return true;
            };
            Transaction.prototype.scrollIntoView = function scrollIntoView() {
                this.updated |= UPDATED_SCROLL;
                return this;
            };
            prototypeAccessors.scrolledIntoView.get = function() {
                return this.updated | UPDATED_SCROLL > 0;
            };
            Transaction.prototype.addStoredMark = function addStoredMark(mark) {
                this.storedMarks = mark.addToSet(this.storedMarks || currentMarks(this.selection));
                return this;
            };
            Transaction.prototype.removeStoredMark = function removeStoredMark(mark) {
                this.storedMarks = mark.removeFromSet(this.storedMarks || currentMarks(this.selection));
                return this;
            };
            Object.defineProperties(Transaction.prototype, prototypeAccessors);
            return Transaction;
        }(Transform));
        exports.Transaction = Transaction;
        function selectionToInsertionEnd(tr, startLen, bias) {
            if (tr.steps.length == startLen) {
                return;
            }
            var map = tr.mapping.maps[tr.mapping.maps.length - 1],
                end;
            map.forEach(function(_from, _to, _newFrom, newTo) {
                return end = newTo;
            });
            if (end != null) {
                tr.setSelection(Selection.near(tr.doc.resolve(end), bias));
            }
        }
        function currentMarks(selection) {
            return selection.head == null ? Mark.none : selection.$head.marks();
        }
        return module.exports;
    });

    $__System.registerDynamic("31", ["3", "2f", "30"], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        var ref = $__require('3');
        var Node = ref.Node;
        var ref$1 = $__require('2f');
        var Selection = ref$1.Selection;
        var ref$2 = $__require('30');
        var Transaction = ref$2.Transaction;
        function bind(f, self) {
            return !self || !f ? f : f.bind(self);
        }
        var FieldDesc = function FieldDesc(name, desc, self) {
            this.name = name;
            this.init = bind(desc.init, self);
            this.apply = bind(desc.apply, self);
        };
        var baseFields = [new FieldDesc("doc", {
            init: function init(config) {
                return config.doc || config.schema.nodes.doc.createAndFill();
            },
            apply: function apply(tr) {
                return tr.doc;
            }
        }), new FieldDesc("selection", {
            init: function init(config, instance) {
                return config.selection || Selection.atStart(instance.doc);
            },
            apply: function apply(tr) {
                return tr.selection;
            }
        }), new FieldDesc("storedMarks", {
            init: function init() {
                return null;
            },
            apply: function apply(tr, _marks, _old, state) {
                return state.selection.empty ? tr.storedMarks : null;
            }
        }), new FieldDesc("scrollToSelection", {
            init: function init() {
                return 0;
            },
            apply: function apply(tr, prev) {
                return tr.scrolledIntoView ? prev + 1 : prev;
            }
        })];
        var Configuration = function Configuration(schema, plugins) {
            var this$1 = this;
            this.schema = schema;
            this.fields = baseFields.concat();
            this.plugins = [];
            this.pluginsByKey = Object.create(null);
            if (plugins) {
                plugins.forEach(function(plugin) {
                    if (this$1.pluginsByKey[plugin.key]) {
                        throw new RangeError("Adding different instances of a keyed plugin (" + plugin.key + ")");
                    }
                    this$1.plugins.push(plugin);
                    this$1.pluginsByKey[plugin.key] = plugin;
                    if (plugin.options.state) {
                        this$1.fields.push(new FieldDesc(plugin.key, plugin.options.state, plugin));
                    }
                });
            }
        };
        var EditorState = function EditorState(config) {
            this.config = config;
        };
        var prototypeAccessors = {
            schema: {},
            plugins: {},
            tr: {}
        };
        prototypeAccessors.schema.get = function() {
            return this.config.schema;
        };
        prototypeAccessors.plugins.get = function() {
            return this.config.plugins;
        };
        EditorState.prototype.apply = function apply(tr) {
            return this.applyTransaction(tr).state;
        };
        EditorState.prototype.filterTransaction = function filterTransaction(tr, ignore) {
            var this$1 = this;
            if (ignore === void 0)
                ignore = -1;
            for (var i = 0; i < this.config.plugins.length; i++) {
                if (i != ignore) {
                    var plugin = this$1.config.plugins[i];
                    if (plugin.options.filterTransaction && !plugin.options.filterTransaction.call(plugin, tr, this$1)) {
                        return false;
                    }
                }
            }
            return true;
        };
        EditorState.prototype.applyTransaction = function applyTransaction(tr) {
            var this$1 = this;
            if (!this.filterTransaction(tr)) {
                return {
                    state: this,
                    transactions: []
                };
            }
            var trs = [tr],
                newState = this.applyInner(tr),
                seen = null;
            outer: for (; ; ) {
                var haveNew = false;
                for (var i = 0; i < this.config.plugins.length; i++) {
                    var plugin = this$1.config.plugins[i];
                    if (plugin.options.appendTransaction) {
                        var n = seen ? seen[i].n : 0,
                            oldState = seen ? seen[i].state : this$1;
                        var tr$1 = n < trs.length && plugin.options.appendTransaction.call(plugin, n ? trs.slice(n) : trs, oldState, newState);
                        if (tr$1 && newState.filterTransaction(tr$1, i)) {
                            if (!seen) {
                                seen = [];
                                for (var j = 0; j < this.config.plugins.length; j++) {
                                    seen.push(j < i ? {
                                        state: newState,
                                        n: trs.length
                                    } : {
                                        state: this$1,
                                        n: 0
                                    });
                                }
                            }
                            trs.push(tr$1);
                            newState = newState.applyInner(tr$1);
                            haveNew = true;
                        }
                        if (seen) {
                            seen[i] = {
                                state: newState,
                                n: trs.length
                            };
                        }
                    }
                }
                if (!haveNew) {
                    return {
                        state: newState,
                        transactions: trs
                    };
                }
            }
        };
        EditorState.prototype.applyInner = function applyInner(tr) {
            var this$1 = this;
            if (!tr.before.eq(this.doc)) {
                throw new RangeError("Applying a mismatched transaction");
            }
            var newInstance = new EditorState(this.config),
                fields = this.config.fields;
            for (var i = 0; i < fields.length; i++) {
                var field = fields[i];
                newInstance[field.name] = field.apply(tr, this$1[field.name], this$1, newInstance);
            }
            for (var i$1 = 0; i$1 < applyListeners.length; i$1++) {
                applyListeners[i$1](this$1, tr, newInstance);
            }
            return newInstance;
        };
        prototypeAccessors.tr.get = function() {
            return new Transaction(this);
        };
        EditorState.create = function create(config) {
            var $config = new Configuration(config.schema || config.doc.type.schema, config.plugins);
            var instance = new EditorState($config);
            for (var i = 0; i < $config.fields.length; i++) {
                instance[$config.fields[i].name] = $config.fields[i].init(config, instance);
            }
            return instance;
        };
        EditorState.prototype.reconfigure = function reconfigure(config) {
            var this$1 = this;
            var $config = new Configuration(config.schema || this.schema, config.plugins);
            var fields = $config.fields,
                instance = new EditorState($config);
            for (var i = 0; i < fields.length; i++) {
                var name = fields[i].name;
                instance[name] = this$1.hasOwnProperty(name) ? this$1[name] : fields[i].init(config, instance);
            }
            return instance;
        };
        EditorState.prototype.toJSON = function toJSON(pluginFields) {
            var this$1 = this;
            var result = {
                doc: this.doc.toJSON(),
                selection: this.selection.toJSON()
            };
            if (pluginFields) {
                for (var prop in pluginFields) {
                    if (prop == "doc" || prop == "selection") {
                        throw new RangeError("The JSON fields `doc` and `selection` are reserved");
                    }
                    var plugin = pluginFields[prop],
                        state = plugin.options.state;
                    if (state && state.toJSON) {
                        result[prop] = state.toJSON.call(plugin, this$1[plugin.key]);
                    }
                }
            }
            return result;
        };
        EditorState.fromJSON = function fromJSON(config, json, pluginFields) {
            if (!config.schema) {
                throw new RangeError("Required config field 'schema' missing");
            }
            var $config = new Configuration(config.schema, config.plugins);
            var instance = new EditorState($config);
            $config.fields.forEach(function(field) {
                if (field.name == "doc") {
                    instance.doc = Node.fromJSON(config.schema, json.doc);
                } else if (field.name == "selection") {
                    instance.selection = Selection.fromJSON(instance.doc, json.selection);
                } else {
                    if (pluginFields) {
                        for (var prop in pluginFields) {
                            var plugin = pluginFields[prop],
                                state = plugin.options.state;
                            if (plugin.key == field.name && state && state.fromJSON && Object.prototype.hasOwnProperty.call(json, prop)) {
                                instance[field.name] = state.fromJSON.call(plugin, config, json[prop], instance);
                                return;
                            }
                        }
                    }
                    instance[field.name] = field.init(config, instance);
                }
            });
            return instance;
        };
        EditorState.addApplyListener = function addApplyListener(f) {
            applyListeners.push(f);
        };
        EditorState.removeApplyListener = function removeApplyListener(f) {
            var found = applyListeners.indexOf(f);
            if (found > -1) {
                applyListeners.splice(found, 1);
            }
        };
        Object.defineProperties(EditorState.prototype, prototypeAccessors);
        exports.EditorState = EditorState;
        var applyListeners = [];
        return module.exports;
    });

    $__System.registerDynamic("32", [], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        var Plugin = function Plugin(options) {
            var this$1 = this;
            this.props = {};
            if (options.props) {
                for (var prop in options.props) {
                    var val = options.props[prop];
                    if (val instanceof Function) {
                        val = val.bind(this$1);
                    }
                    this$1.props[prop] = val;
                }
            }
            this.options = options;
            this.key = options.key ? options.key.key : createKey("plugin");
        };
        Plugin.prototype.getState = function getState(state) {
            return state[this.key];
        };
        exports.Plugin = Plugin;
        var keys = Object.create(null);
        function createKey(name) {
            if (name in keys) {
                return name + "$" + ++keys[name];
            }
            keys[name] = 0;
            return name + "$";
        }
        var PluginKey = function PluginKey(name) {
            if (name === void 0)
                name = "key";
            this.key = createKey(name);
        };
        PluginKey.prototype.get = function get(state) {
            return state.config.pluginsByKey[this.key];
        };
        PluginKey.prototype.getState = function getState(state) {
            return state[this.key];
        };
        exports.PluginKey = PluginKey;
        return module.exports;
    });

    $__System.registerDynamic("33", ["2f", "30", "31", "32"], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        ;
        var assign;
        ((assign = $__require('2f'), exports.Selection = assign.Selection, exports.TextSelection = assign.TextSelection, exports.NodeSelection = assign.NodeSelection));
        exports.Transaction = $__require('30').Transaction;
        exports.EditorState = $__require('31').EditorState;
        ;
        var assign$1;
        ((assign$1 = $__require('32'), exports.Plugin = assign$1.Plugin, exports.PluginKey = assign$1.PluginKey));
        return module.exports;
    });

    $__System.registerDynamic("7", ["33"], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        module.exports = $__require('33');
        return module.exports;
    });

    $__System.registerDynamic("34", ["2e", "9", "7"], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        var RopeSequence = $__require('2e');
        var ref = $__require('9');
        var Mapping = ref.Mapping;
        var ref$1 = $__require('7');
        var Selection = ref$1.Selection;
        var Plugin = ref$1.Plugin;
        var PluginKey = ref$1.PluginKey;
        var max_empty_items = 500;
        var Branch = function Branch(items, eventCount) {
            this.items = items;
            this.eventCount = eventCount;
        };
        Branch.prototype.popEvent = function popEvent(state, preserveItems) {
            var this$1 = this;
            if (this.eventCount == 0) {
                return null;
            }
            var end = this.items.length;
            for (; ; end--) {
                var next = this$1.items.get(end - 1);
                if (next.selection) {
                    --end;
                    break;
                }
            }
            var remap,
                mapFrom;
            if (preserveItems) {
                remap = this.remapping(end, this.items.length);
                mapFrom = remap.maps.length;
            }
            var transform = state.tr;
            var selection,
                remaining;
            var addAfter = [],
                addBefore = [];
            this.items.forEach(function(item, i) {
                if (!item.step) {
                    if (!remap) {
                        remap = this$1.remapping(end, i + 1);
                        mapFrom = remap.maps.length;
                    }
                    mapFrom--;
                    addBefore.push(item);
                    return;
                }
                if (remap) {
                    addBefore.push(new Item(item.map));
                    var step = item.step.map(remap.slice(mapFrom)),
                        map;
                    if (step && transform.maybeStep(step).doc) {
                        map = transform.mapping.maps[transform.mapping.maps.length - 1];
                        addAfter.push(new Item(map, null, null, addAfter.length + addBefore.length));
                    }
                    mapFrom--;
                    if (map) {
                        remap.appendMap(map, mapFrom);
                    }
                } else {
                    transform.maybeStep(item.step);
                }
                if (item.selection) {
                    selection = remap ? Selection.mapJSON(item.selection, remap.slice(mapFrom)) : item.selection;
                    remaining = new Branch(this$1.items.slice(0, end).append(addBefore.reverse().concat(addAfter)), this$1.eventCount - 1);
                    return false;
                }
            }, this.items.length, 0);
            return {
                remaining: remaining,
                transform: transform,
                selection: selection
            };
        };
        Branch.prototype.addTransform = function addTransform(transform, selection, histOptions) {
            var newItems = [],
                eventCount = this.eventCount + (selection ? 1 : 0);
            var oldItems = this.items,
                lastItem = !histOptions.preserveItems && oldItems.length ? oldItems.get(oldItems.length - 1) : null;
            for (var i = 0; i < transform.steps.length; i++) {
                var step = transform.steps[i].invert(transform.docs[i]);
                var item = new Item(transform.mapping.maps[i], step, selection),
                    merged = (void 0);
                if (merged = lastItem && lastItem.merge(item)) {
                    item = merged;
                    if (i) {
                        newItems.pop();
                    } else {
                        oldItems = oldItems.slice(0, oldItems.length - 1);
                    }
                }
                newItems.push(item);
                selection = null;
                if (!histOptions.preserveItems) {
                    lastItem = item;
                }
            }
            var overflow = this.eventCount - histOptions.depth;
            if (overflow > DEPTH_OVERFLOW) {
                oldItems = cutOffEvents(oldItems, overflow);
            }
            return new Branch(oldItems.append(newItems), eventCount);
        };
        Branch.prototype.remapping = function remapping(from, to) {
            var maps = [],
                mirrors = [];
            this.items.forEach(function(item, i) {
                if (item.mirrorOffset != null) {
                    var mirrorPos = i - item.mirrorOffset;
                    if (mirrorPos >= from) {
                        mirrors.push(maps.length - item.mirrorOffset, maps.length);
                    }
                }
                maps.push(item.map);
            }, from, to);
            return new Mapping(maps, mirrors);
        };
        Branch.prototype.addMaps = function addMaps(array) {
            if (this.eventCount == 0) {
                return this;
            }
            return new Branch(this.items.append(array.map(function(map) {
                return new Item(map);
            })), this.eventCount);
        };
        Branch.prototype.rebased = function rebased(rebasedTransform, rebasedCount) {
            if (!this.eventCount) {
                return this;
            }
            var rebasedItems = [],
                start = this.items.length - rebasedCount,
                startPos = 0;
            if (start < 0) {
                startPos = -start;
                start = 0;
            }
            var mapping = rebasedTransform.mapping;
            var newUntil = rebasedTransform.steps.length;
            var iRebased = startPos;
            this.items.forEach(function(item) {
                var pos = mapping.getMirror(iRebased++);
                if (pos == null) {
                    return;
                }
                newUntil = Math.min(newUntil, pos);
                var map = mapping.maps[pos];
                if (item.step) {
                    var step = rebasedTransform.steps[pos].invert(rebasedTransform.docs[pos]);
                    var selection = item.selection && Selection.mapJSON(item.selection, mapping.slice(iRebased - 1, pos));
                    rebasedItems.push(new Item(map, step, selection));
                } else {
                    rebasedItems.push(new Item(map));
                }
            }, start);
            var newMaps = [];
            for (var i = rebasedCount; i < newUntil; i++) {
                newMaps.push(new Item(mapping.maps[i]));
            }
            var items = this.items.slice(0, start).append(newMaps).append(rebasedItems);
            var branch = new Branch(items, this.eventCount);
            if (branch.emptyItemCount() > max_empty_items) {
                branch = branch.compress(this.items.length - rebasedItems.length);
            }
            return branch;
        };
        Branch.prototype.emptyItemCount = function emptyItemCount() {
            var count = 0;
            this.items.forEach(function(item) {
                if (!item.step) {
                    count++;
                }
            });
            return count;
        };
        Branch.prototype.compress = function compress(upto) {
            if (upto === void 0)
                upto = this.items.length;
            var remap = this.remapping(0, upto),
                mapFrom = remap.maps.length;
            var items = [],
                events = 0;
            this.items.forEach(function(item, i) {
                if (i >= upto) {
                    items.push(item);
                } else if (item.step) {
                    var step = item.step.map(remap.slice(mapFrom)),
                        map = step && step.getMap();
                    mapFrom--;
                    if (map) {
                        remap.appendMap(map, mapFrom);
                    }
                    if (step) {
                        var selection = item.selection && Selection.mapJSON(item.selection, remap.slice(mapFrom));
                        if (selection) {
                            events++;
                        }
                        var newItem = new Item(map.invert(), step, selection),
                            merged,
                            last = items.length - 1;
                        if (merged = items.length && items[last].merge(newItem)) {
                            items[last] = merged;
                        } else {
                            items.push(newItem);
                        }
                    }
                } else if (item.map) {
                    mapFrom--;
                }
            }, this.items.length, 0);
            return new Branch(RopeSequence.from(items.reverse()), events);
        };
        Branch.empty = new Branch(RopeSequence.empty, 0);
        function cutOffEvents(items, n) {
            var cutPoint;
            items.forEach(function(item, i) {
                if (item.selection && (--n == 0)) {
                    cutPoint = i;
                    return false;
                }
            });
            return items.slice(cutPoint);
        }
        var Item = function Item(map, step, selection, mirrorOffset) {
            this.map = map;
            this.step = step;
            this.selection = selection;
            this.mirrorOffset = mirrorOffset;
        };
        Item.prototype.merge = function merge(other) {
            if (this.step && other.step && !other.selection) {
                var step = other.step.merge(this.step);
                if (step) {
                    return new Item(step.getMap().invert(), step, this.selection);
                }
            }
        };
        var HistoryState = function HistoryState(done, undone, prevMap, prevTime) {
            this.done = done;
            this.undone = undone;
            this.prevMap = prevMap;
            this.prevTime = prevTime;
        };
        exports.HistoryState = HistoryState;
        var DEPTH_OVERFLOW = 20;
        function applyTransaction(history, selection, tr, options) {
            var newState = tr.getMeta(historyKey),
                rebased;
            if (newState) {
                return newState;
            } else if (tr.steps.length == 0) {
                if (tr.getMeta(closeHistoryKey)) {
                    return new HistoryState(history.done, history.undone, null, 0);
                } else {
                    return history;
                }
            } else if (tr.getMeta("addToHistory") !== false) {
                var newGroup = history.prevTime < (tr.time || 0) - options.newGroupDelay || !isAdjacentToLastStep(tr, history.prevMap, history.done);
                return new HistoryState(history.done.addTransform(tr, newGroup ? selection.toJSON() : null, options), Branch.empty, tr.mapping.maps[tr.steps.length - 1], tr.time);
            } else if (rebased = tr.getMeta("rebased")) {
                return new HistoryState(history.done.rebased(tr, rebased), history.undone.rebased(tr, rebased), history.prevMap && tr.mapping.maps[tr.steps.length - 1], history.prevTime);
            } else {
                return new HistoryState(history.done.addMaps(tr.mapping.maps), history.undone.addMaps(tr.mapping.maps), history.prevMap, history.prevTime);
            }
        }
        function isAdjacentToLastStep(transform, prevMap, done) {
            if (!prevMap) {
                return false;
            }
            var firstMap = transform.mapping.maps[0],
                adjacent = false;
            if (!firstMap) {
                return true;
            }
            firstMap.forEach(function(start, end) {
                done.items.forEach(function(item) {
                    if (item.step) {
                        prevMap.forEach(function(_start, _end, rStart, rEnd) {
                            if (start <= rEnd && end >= rStart) {
                                adjacent = true;
                            }
                        });
                        return false;
                    } else {
                        start = item.map.invert().map(start, -1);
                        end = item.map.invert().map(end, 1);
                    }
                }, done.items.length, 0);
            });
            return adjacent;
        }
        function histTransaction(history, state, dispatch, redo) {
            var histOptions = historyKey.get(state).options.config;
            var pop = (redo ? history.undone : history.done).popEvent(state, histOptions.preserveItems);
            if (!pop) {
                return;
            }
            var selectionBefore = state.selection;
            var selection = Selection.fromJSON(pop.transform.doc, pop.selection);
            var added = (redo ? history.done : history.undone).addTransform(pop.transform, selectionBefore.toJSON(), histOptions);
            var newHist = new HistoryState(redo ? added : pop.remaining, redo ? pop.remaining : added, null, 0);
            dispatch(pop.transform.setSelection(selection).setMeta(historyKey, newHist).scrollIntoView());
        }
        function closeHistory(state) {
            return state.tr.setMeta(closeHistoryKey, true);
        }
        exports.closeHistory = closeHistory;
        var historyKey = new PluginKey("history");
        var closeHistoryKey = new PluginKey("closeHistory");
        function history(config) {
            config = {
                depth: config && config.depth || 100,
                preserveItems: !!(config && config.preserveItems),
                newGroupDelay: config && config.newGroupDelay || 500
            };
            return new Plugin({
                key: historyKey,
                state: {
                    init: function init() {
                        return new HistoryState(Branch.empty, Branch.empty, null, 0);
                    },
                    apply: function apply(tr, hist, state) {
                        return applyTransaction(hist, state.selection, tr, config);
                    }
                },
                config: config
            });
        }
        exports.history = history;
        function undo(state, dispatch) {
            var hist = historyKey.getState(state);
            if (!hist || hist.done.eventCount == 0) {
                return false;
            }
            if (dispatch) {
                histTransaction(hist, state, dispatch, false);
            }
            return true;
        }
        exports.undo = undo;
        function redo(state, dispatch) {
            var hist = historyKey.getState(state);
            if (!hist || hist.undone.eventCount == 0) {
                return false;
            }
            if (dispatch) {
                histTransaction(hist, state, dispatch, true);
            }
            return true;
        }
        exports.redo = redo;
        function undoDepth(state) {
            var hist = historyKey.getState(state);
            return hist ? hist.done.eventCount : 0;
        }
        exports.undoDepth = undoDepth;
        function redoDepth(state) {
            var hist = historyKey.getState(state);
            return hist ? hist.undone.eventCount : 0;
        }
        exports.redoDepth = redoDepth;
        return module.exports;
    });

    $__System.registerDynamic("23", ["34"], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        module.exports = $__require('34');
        return module.exports;
    });

    $__System.registerDynamic("35", ["22", "29", "2a", "23"], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        var ref = $__require('22');
        var wrapIn = ref.wrapIn;
        var setBlockType = ref.setBlockType;
        var chainCommands = ref.chainCommands;
        var toggleMark = ref.toggleMark;
        var exitCode = ref.exitCode;
        var ref$1 = $__require('29');
        var selectNextCell = ref$1.selectNextCell;
        var selectPreviousCell = ref$1.selectPreviousCell;
        var ref$2 = $__require('2a');
        var wrapInList = ref$2.wrapInList;
        var splitListItem = ref$2.splitListItem;
        var liftListItem = ref$2.liftListItem;
        var sinkListItem = ref$2.sinkListItem;
        var ref$3 = $__require('23');
        var undo = ref$3.undo;
        var redo = ref$3.redo;
        var mac = typeof navigator != "undefined" ? /Mac/.test(navigator.platform) : false;
        function buildKeymap(schema, mapKeys) {
            var keys = {},
                type;
            function bind(key, cmd) {
                if (mapKeys) {
                    var mapped = mapKeys[key];
                    if (mapped === false) {
                        return;
                    }
                    if (mapped) {
                        key = mapped;
                    }
                }
                keys[key] = cmd;
            }
            bind("Mod-z", undo);
            bind("Shift-Mod-z", redo);
            if (!mac) {
                bind("Mod-y", redo);
            }
            if (type = schema.marks.strong) {
                bind("Mod-b", toggleMark(type));
            }
            if (type = schema.marks.em) {
                bind("Mod-i", toggleMark(type));
            }
            if (type = schema.marks.code) {
                bind("Mod-`", toggleMark(type));
            }
            if (type = schema.nodes.bullet_list) {
                bind("Shift-Ctrl-8", wrapInList(type));
            }
            if (type = schema.nodes.ordered_list) {
                bind("Shift-Ctrl-9", wrapInList(type));
            }
            if (type = schema.nodes.blockquote) {
                bind("Ctrl->", wrapIn(type));
            }
            if (type = schema.nodes.hard_break) {
                var br = type,
                    cmd = chainCommands(exitCode, function(state, dispatch) {
                        dispatch(state.tr.replaceSelectionWith(br.create()).scrollIntoView());
                        return true;
                    });
                bind("Mod-Enter", cmd);
                bind("Shift-Enter", cmd);
                if (mac) {
                    bind("Ctrl-Enter", cmd);
                }
            }
            if (type = schema.nodes.list_item) {
                bind("Enter", splitListItem(type));
                bind("Mod-[", liftListItem(type));
                bind("Mod-]", sinkListItem(type));
            }
            if (type = schema.nodes.paragraph) {
                bind("Shift-Ctrl-0", setBlockType(type));
            }
            if (type = schema.nodes.code_block) {
                bind("Shift-Ctrl-\\", setBlockType(type));
            }
            if (type = schema.nodes.heading) {
                for (var i = 1; i <= 6; i++) {
                    bind("Shift-Ctrl-" + i, setBlockType(type, {level: i}));
                }
            }
            if (type = schema.nodes.horizontal_rule) {
                var hr = type;
                bind("Mod-_", function(state, dispatch) {
                    dispatch(state.tr.replaceSelectionWith(hr.create()).scrollIntoView());
                    return true;
                });
            }
            if (schema.nodes.table_row) {
                bind("Tab", selectNextCell);
                bind("Shift-Tab", selectPreviousCell);
            }
            return keys;
        }
        exports.buildKeymap = buildKeymap;
        return module.exports;
    });

    $__System.registerDynamic("36", ["b", "f", "23", "22", "7", "12", "28", "35"], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        var ref = $__require('b');
        var blockQuoteRule = ref.blockQuoteRule;
        var orderedListRule = ref.orderedListRule;
        var bulletListRule = ref.bulletListRule;
        var codeBlockRule = ref.codeBlockRule;
        var headingRule = ref.headingRule;
        var inputRules = ref.inputRules;
        var allInputRules = ref.allInputRules;
        var ref$1 = $__require('f');
        var keymap = ref$1.keymap;
        var ref$2 = $__require('23');
        var history = ref$2.history;
        var ref$3 = $__require('22');
        var baseKeymap = ref$3.baseKeymap;
        var ref$4 = $__require('7');
        var Plugin = ref$4.Plugin;
        var ref$5 = $__require('12');
        var dropCursor = ref$5.dropCursor;
        var ref$6 = $__require('28');
        var buildMenuItems = ref$6.buildMenuItems;
        exports.buildMenuItems = buildMenuItems;
        var ref$7 = $__require('35');
        var buildKeymap = ref$7.buildKeymap;
        exports.buildKeymap = buildKeymap;
        function exampleSetup(options) {
            var plugins = [inputRules({rules: allInputRules.concat(buildInputRules(options.schema))}), keymap(buildKeymap(options.schema, options.mapKeys)), keymap(baseKeymap), dropCursor()];
            if (options.history !== false) {
                plugins.push(history());
            }
            return plugins.concat(new Plugin({props: {
                attributes: {class: "ProseMirror-example-setup-style"},
                menuContent: buildMenuItems(options.schema).fullMenu,
                floatingMenu: true
            }}));
        }
        exports.exampleSetup = exampleSetup;
        function buildInputRules(schema) {
            var result = [],
                type;
            if (type = schema.nodes.blockquote) {
                result.push(blockQuoteRule(type));
            }
            if (type = schema.nodes.ordered_list) {
                result.push(orderedListRule(type));
            }
            if (type = schema.nodes.bullet_list) {
                result.push(bulletListRule(type));
            }
            if (type = schema.nodes.code_block) {
                result.push(codeBlockRule(type));
            }
            if (type = schema.nodes.heading) {
                result.push(headingRule(type, 6));
            }
            return result;
        }
        exports.buildInputRules = buildInputRules;
        return module.exports;
    });

    $__System.registerDynamic("37", ["36"], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        module.exports = $__require('36');
        return module.exports;
    });

    $__System.registerDynamic("38", ["3", "39"], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        var ref = $__require('3');
        var Fragment = ref.Fragment;
        var Slice = ref.Slice;
        var ref$1 = $__require('39');
        var Step = ref$1.Step;
        var StepResult = ref$1.StepResult;
        function mapFragment(fragment, f, parent) {
            var mapped = [];
            for (var i = 0; i < fragment.childCount; i++) {
                var child = fragment.child(i);
                if (child.content.size) {
                    child = child.copy(mapFragment(child.content, f, child));
                }
                if (child.isInline) {
                    child = f(child, parent, i);
                }
                mapped.push(child);
            }
            return Fragment.fromArray(mapped);
        }
        var AddMarkStep = (function(Step) {
            function AddMarkStep(from, to, mark) {
                Step.call(this);
                this.from = from;
                this.to = to;
                this.mark = mark;
            }
            if (Step)
                AddMarkStep.__proto__ = Step;
            AddMarkStep.prototype = Object.create(Step && Step.prototype);
            AddMarkStep.prototype.constructor = AddMarkStep;
            AddMarkStep.prototype.apply = function apply(doc) {
                var this$1 = this;
                var oldSlice = doc.slice(this.from, this.to),
                    $from = doc.resolve(this.from);
                var parent = $from.node($from.sharedDepth(this.to));
                var slice = new Slice(mapFragment(oldSlice.content, function(node, parent, index) {
                    if (!parent.contentMatchAt(index + 1).allowsMark(this$1.mark.type)) {
                        return node;
                    }
                    return node.mark(this$1.mark.addToSet(node.marks));
                }, parent), oldSlice.openLeft, oldSlice.openRight);
                return StepResult.fromReplace(doc, this.from, this.to, slice);
            };
            AddMarkStep.prototype.invert = function invert() {
                return new RemoveMarkStep(this.from, this.to, this.mark);
            };
            AddMarkStep.prototype.map = function map(mapping) {
                var from = mapping.mapResult(this.from, 1),
                    to = mapping.mapResult(this.to, -1);
                if (from.deleted && to.deleted || from.pos >= to.pos) {
                    return null;
                }
                return new AddMarkStep(from.pos, to.pos, this.mark);
            };
            AddMarkStep.prototype.merge = function merge(other) {
                if (other instanceof AddMarkStep && other.mark.eq(this.mark) && this.from <= other.to && this.to >= other.from) {
                    return new AddMarkStep(Math.min(this.from, other.from), Math.max(this.to, other.to), this.mark);
                }
            };
            AddMarkStep.fromJSON = function fromJSON(schema, json) {
                return new AddMarkStep(json.from, json.to, schema.markFromJSON(json.mark));
            };
            return AddMarkStep;
        }(Step));
        exports.AddMarkStep = AddMarkStep;
        Step.jsonID("addMark", AddMarkStep);
        var RemoveMarkStep = (function(Step) {
            function RemoveMarkStep(from, to, mark) {
                Step.call(this);
                this.from = from;
                this.to = to;
                this.mark = mark;
            }
            if (Step)
                RemoveMarkStep.__proto__ = Step;
            RemoveMarkStep.prototype = Object.create(Step && Step.prototype);
            RemoveMarkStep.prototype.constructor = RemoveMarkStep;
            RemoveMarkStep.prototype.apply = function apply(doc) {
                var this$1 = this;
                var oldSlice = doc.slice(this.from, this.to);
                var slice = new Slice(mapFragment(oldSlice.content, function(node) {
                    return node.mark(this$1.mark.removeFromSet(node.marks));
                }), oldSlice.openLeft, oldSlice.openRight);
                return StepResult.fromReplace(doc, this.from, this.to, slice);
            };
            RemoveMarkStep.prototype.invert = function invert() {
                return new AddMarkStep(this.from, this.to, this.mark);
            };
            RemoveMarkStep.prototype.map = function map(mapping) {
                var from = mapping.mapResult(this.from, 1),
                    to = mapping.mapResult(this.to, -1);
                if (from.deleted && to.deleted || from.pos >= to.pos) {
                    return null;
                }
                return new RemoveMarkStep(from.pos, to.pos, this.mark);
            };
            RemoveMarkStep.prototype.merge = function merge(other) {
                if (other instanceof RemoveMarkStep && other.mark.eq(this.mark) && this.from <= other.to && this.to >= other.from) {
                    return new RemoveMarkStep(Math.min(this.from, other.from), Math.max(this.to, other.to), this.mark);
                }
            };
            RemoveMarkStep.fromJSON = function fromJSON(schema, json) {
                return new RemoveMarkStep(json.from, json.to, schema.markFromJSON(json.mark));
            };
            return RemoveMarkStep;
        }(Step));
        exports.RemoveMarkStep = RemoveMarkStep;
        Step.jsonID("removeMark", RemoveMarkStep);
        return module.exports;
    });

    $__System.registerDynamic("3a", ["3", "3b", "38", "3c"], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        var ref = $__require('3');
        var MarkType = ref.MarkType;
        var Slice = ref.Slice;
        var Fragment = ref.Fragment;
        var ref$1 = $__require('3b');
        var Transform = ref$1.Transform;
        var ref$2 = $__require('38');
        var AddMarkStep = ref$2.AddMarkStep;
        var RemoveMarkStep = ref$2.RemoveMarkStep;
        var ref$3 = $__require('3c');
        var ReplaceStep = ref$3.ReplaceStep;
        Transform.prototype.addMark = function(from, to, mark) {
            var this$1 = this;
            var removed = [],
                added = [],
                removing = null,
                adding = null;
            this.doc.nodesBetween(from, to, function(node, pos, parent, index) {
                if (!node.isInline) {
                    return;
                }
                var marks = node.marks;
                if (mark.isInSet(marks) || !parent.contentMatchAt(index + 1).allowsMark(mark.type)) {
                    adding = removing = null;
                } else {
                    var start = Math.max(pos, from),
                        end = Math.min(pos + node.nodeSize, to);
                    var rm = mark.type.isInSet(marks);
                    if (!rm) {
                        removing = null;
                    } else if (removing && removing.mark.eq(rm)) {
                        removing.to = end;
                    } else {
                        removed.push(removing = new RemoveMarkStep(start, end, rm));
                    }
                    if (adding) {
                        adding.to = end;
                    } else {
                        added.push(adding = new AddMarkStep(start, end, mark));
                    }
                }
            });
            removed.forEach(function(s) {
                return this$1.step(s);
            });
            added.forEach(function(s) {
                return this$1.step(s);
            });
            return this;
        };
        Transform.prototype.removeMark = function(from, to, mark) {
            var this$1 = this;
            if (mark === void 0)
                mark = null;
            var matched = [],
                step = 0;
            this.doc.nodesBetween(from, to, function(node, pos) {
                if (!node.isInline) {
                    return;
                }
                step++;
                var toRemove = null;
                if (mark instanceof MarkType) {
                    var found = mark.isInSet(node.marks);
                    if (found) {
                        toRemove = [found];
                    }
                } else if (mark) {
                    if (mark.isInSet(node.marks)) {
                        toRemove = [mark];
                    }
                } else {
                    toRemove = node.marks;
                }
                if (toRemove && toRemove.length) {
                    var end = Math.min(pos + node.nodeSize, to);
                    for (var i = 0; i < toRemove.length; i++) {
                        var style = toRemove[i],
                            found$1 = (void 0);
                        for (var j = 0; j < matched.length; j++) {
                            var m = matched[j];
                            if (m.step == step - 1 && style.eq(matched[j].style)) {
                                found$1 = m;
                            }
                        }
                        if (found$1) {
                            found$1.to = end;
                            found$1.step = step;
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
                return this$1.step(new RemoveMarkStep(m.from, m.to, m.style));
            });
            return this;
        };
        Transform.prototype.clearMarkup = function(from, to) {
            var this$1 = this;
            var delSteps = [];
            this.doc.nodesBetween(from, to, function(node, pos) {
                if (!node.isInline) {
                    return;
                }
                if (!node.type.isText) {
                    delSteps.push(new ReplaceStep(pos, pos + node.nodeSize, Slice.empty));
                    return;
                }
                for (var i = 0; i < node.marks.length; i++) {
                    this$1.step(new RemoveMarkStep(Math.max(pos, from), Math.min(pos + node.nodeSize, to), node.marks[i]));
                }
            });
            for (var i = delSteps.length - 1; i >= 0; i--) {
                this$1.step(delSteps[i]);
            }
            return this;
        };
        Transform.prototype.clearNonMatching = function(pos, match) {
            var this$1 = this;
            var node = this.doc.nodeAt(pos);
            var delSteps = [],
                cur = pos + 1;
            for (var i = 0; i < node.childCount; i++) {
                var child = node.child(i),
                    end = cur + child.nodeSize;
                var allowed = match.matchType(child.type, child.attrs);
                if (!allowed) {
                    delSteps.push(new ReplaceStep(cur, end, Slice.empty));
                } else {
                    match = allowed;
                    for (var j = 0; j < child.marks.length; j++) {
                        if (!match.allowsMark(child.marks[j])) {
                            this$1.step(new RemoveMarkStep(cur, end, child.marks[j]));
                        }
                    }
                }
                cur = end;
            }
            if (!match.validEnd()) {
                var fill = match.fillBefore(Fragment.empty, true);
                this.replace(cur, cur, new Slice(fill, 0, 0));
            }
            for (var i$1 = delSteps.length - 1; i$1 >= 0; i$1--) {
                this$1.step(delSteps[i$1]);
            }
            return this;
        };
        return module.exports;
    });

    $__System.registerDynamic("3b", ["3d"], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        var ref = $__require('3d');
        var Mapping = ref.Mapping;
        var TransformError = (function(Error) {
            function TransformError() {
                Error.apply(this, arguments);
            }
            if (Error)
                TransformError.__proto__ = Error;
            TransformError.prototype = Object.create(Error && Error.prototype);
            TransformError.prototype.constructor = TransformError;
            return TransformError;
        }(Error));
        exports.TransformError = TransformError;
        var Transform = function Transform(doc) {
            this.doc = doc;
            this.steps = [];
            this.docs = [];
            this.mapping = new Mapping;
        };
        var prototypeAccessors = {before: {}};
        prototypeAccessors.before.get = function() {
            return this.docs.length ? this.docs[0] : this.doc;
        };
        Transform.prototype.step = function step(object) {
            var result = this.maybeStep(object);
            if (result.failed) {
                throw new TransformError(result.failed);
            }
            return this;
        };
        Transform.prototype.maybeStep = function maybeStep(step) {
            var result = step.apply(this.doc);
            if (!result.failed) {
                this.addStep(step, result.doc);
            }
            return result;
        };
        Transform.prototype.addStep = function addStep(step, doc) {
            this.docs.push(this.doc);
            this.steps.push(step);
            this.mapping.appendMap(step.getMap());
            this.doc = doc;
        };
        Object.defineProperties(Transform.prototype, prototypeAccessors);
        exports.Transform = Transform;
        return module.exports;
    });

    $__System.registerDynamic("39", ["3", "3d"], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        var ref = $__require('3');
        var ReplaceError = ref.ReplaceError;
        var ref$1 = $__require('3d');
        var StepMap = ref$1.StepMap;
        function mustOverride() {
            throw new Error("Override me");
        }
        var stepsByID = Object.create(null);
        var Step = function Step() {};
        Step.prototype.apply = function apply(_doc) {
            return mustOverride();
        };
        Step.prototype.getMap = function getMap() {
            return StepMap.empty;
        };
        Step.prototype.invert = function invert(_doc) {
            return mustOverride();
        };
        Step.prototype.map = function map(_mapping) {
            return mustOverride();
        };
        Step.prototype.merge = function merge(_other) {
            return null;
        };
        Step.prototype.toJSON = function toJSON() {
            var this$1 = this;
            var obj = {stepType: this.jsonID};
            for (var prop in this$1) {
                if (this$1.hasOwnProperty(prop)) {
                    var val = this$1[prop];
                    obj[prop] = val && val.toJSON ? val.toJSON() : val;
                }
            }
            return obj;
        };
        Step.fromJSON = function fromJSON(schema, json) {
            return stepsByID[json.stepType].fromJSON(schema, json);
        };
        Step.jsonID = function jsonID(id, stepClass) {
            if (id in stepsByID) {
                throw new RangeError("Duplicate use of step JSON ID " + id);
            }
            stepsByID[id] = stepClass;
            stepClass.prototype.jsonID = id;
            return stepClass;
        };
        exports.Step = Step;
        var StepResult = function StepResult(doc, failed) {
            this.doc = doc;
            this.failed = failed;
        };
        StepResult.ok = function ok(doc) {
            return new StepResult(doc, null);
        };
        StepResult.fail = function fail(message) {
            return new StepResult(null, message);
        };
        StepResult.fromReplace = function fromReplace(doc, from, to, slice) {
            try {
                return StepResult.ok(doc.replace(from, to, slice));
            } catch (e) {
                if (e instanceof ReplaceError) {
                    return StepResult.fail(e.message);
                }
                throw e;
            }
        };
        exports.StepResult = StepResult;
        return module.exports;
    });

    $__System.registerDynamic("3d", [], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
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
        var MapResult = function MapResult(pos, deleted, recover) {
            if (deleted === void 0)
                deleted = false;
            if (recover === void 0)
                recover = null;
            this.pos = pos;
            this.deleted = deleted;
            this.recover = recover;
        };
        exports.MapResult = MapResult;
        var StepMap = function StepMap(ranges, inverted) {
            if (inverted === void 0)
                inverted = false;
            this.ranges = ranges;
            this.inverted = inverted;
        };
        StepMap.prototype.recover = function recover(value) {
            var this$1 = this;
            var diff = 0,
                index = recoverIndex(value);
            if (!this.inverted) {
                for (var i = 0; i < index; i++) {
                    diff += this$1.ranges[i * 3 + 2] - this$1.ranges[i * 3 + 1];
                }
            }
            return this.ranges[index * 3] + diff + recoverOffset(value);
        };
        StepMap.prototype.mapResult = function mapResult(pos, assoc) {
            return this._map(pos, assoc, false);
        };
        StepMap.prototype.map = function map(pos, assoc) {
            return this._map(pos, assoc, true);
        };
        StepMap.prototype._map = function _map(pos, assoc, simple) {
            var this$1 = this;
            var diff = 0,
                oldIndex = this.inverted ? 2 : 1,
                newIndex = this.inverted ? 1 : 2;
            for (var i = 0; i < this.ranges.length; i += 3) {
                var start = this$1.ranges[i] - (this$1.inverted ? diff : 0);
                if (start > pos) {
                    break;
                }
                var oldSize = this$1.ranges[i + oldIndex],
                    newSize = this$1.ranges[i + newIndex],
                    end = start + oldSize;
                if (pos <= end) {
                    var side = !oldSize ? assoc : pos == start ? -1 : pos == end ? 1 : assoc;
                    var result = start + diff + (side < 0 ? 0 : newSize);
                    if (simple) {
                        return result;
                    }
                    var recover = makeRecover(i / 3, pos - start);
                    return new MapResult(result, assoc < 0 ? pos != start : pos != end, recover);
                }
                diff += newSize - oldSize;
            }
            return simple ? pos + diff : new MapResult(pos + diff);
        };
        StepMap.prototype.touches = function touches(pos, recover) {
            var this$1 = this;
            var diff = 0,
                index = recoverIndex(recover);
            var oldIndex = this.inverted ? 2 : 1,
                newIndex = this.inverted ? 1 : 2;
            for (var i = 0; i < this.ranges.length; i += 3) {
                var start = this$1.ranges[i] - (this$1.inverted ? diff : 0);
                if (start > pos) {
                    break;
                }
                var oldSize = this$1.ranges[i + oldIndex],
                    end = start + oldSize;
                if (pos <= end && i == index * 3) {
                    return true;
                }
                diff += this$1.ranges[i + newIndex] - oldSize;
            }
            return false;
        };
        StepMap.prototype.forEach = function forEach(f) {
            var this$1 = this;
            var oldIndex = this.inverted ? 2 : 1,
                newIndex = this.inverted ? 1 : 2;
            for (var i = 0,
                     diff = 0; i < this.ranges.length; i += 3) {
                var start = this$1.ranges[i],
                    oldStart = start - (this$1.inverted ? diff : 0),
                    newStart = start + (this$1.inverted ? 0 : diff);
                var oldSize = this$1.ranges[i + oldIndex],
                    newSize = this$1.ranges[i + newIndex];
                f(oldStart, oldStart + oldSize, newStart, newStart + newSize);
                diff += newSize - oldSize;
            }
        };
        StepMap.prototype.invert = function invert() {
            return new StepMap(this.ranges, !this.inverted);
        };
        StepMap.prototype.toString = function toString() {
            return (this.inverted ? "-" : "") + JSON.stringify(this.ranges);
        };
        exports.StepMap = StepMap;
        StepMap.empty = new StepMap([]);
        var Mapping = function Mapping(maps, mirror, from, to) {
            this.maps = maps || [];
            this.from = from || 0;
            this.to = to == null ? this.maps.length : to;
            this.mirror = mirror;
        };
        Mapping.prototype.slice = function slice(from, to) {
            if (from === void 0)
                from = 0;
            if (to === void 0)
                to = this.maps.length;
            return new Mapping(this.maps, this.mirror, from, to);
        };
        Mapping.prototype.copy = function copy() {
            return new Mapping(this.maps.slice(), this.mirror && this.mirror.slice(), this.from, this.to);
        };
        Mapping.prototype.getMirror = function getMirror(n) {
            var this$1 = this;
            if (this.mirror) {
                for (var i = 0; i < this.mirror.length; i++) {
                    if (this$1.mirror[i] == n) {
                        return this$1.mirror[i + (i % 2 ? -1 : 1)];
                    }
                }
            }
        };
        Mapping.prototype.setMirror = function setMirror(n, m) {
            if (!this.mirror) {
                this.mirror = [];
            }
            this.mirror.push(n, m);
        };
        Mapping.prototype.appendMap = function appendMap(map, mirrors) {
            this.to = this.maps.push(map);
            if (mirrors != null) {
                this.setMirror(this.maps.length - 1, mirrors);
            }
        };
        Mapping.prototype.appendMapping = function appendMapping(mapping) {
            var this$1 = this;
            for (var i = 0,
                     startSize = this.maps.length; i < mapping.maps.length; i++) {
                var mirr = mapping.getMirror(i);
                this$1.appendMap(mapping.maps[i], mirr != null && mirr < i ? startSize + mirr : null);
            }
        };
        Mapping.prototype.map = function map(pos, assoc) {
            var this$1 = this;
            if (this.mirror) {
                return this._map(pos, assoc, true);
            }
            for (var i = this.from; i < this.to; i++) {
                pos = this$1.maps[i].map(pos, assoc);
            }
            return pos;
        };
        Mapping.prototype.mapResult = function mapResult(pos, assoc) {
            return this._map(pos, assoc, false);
        };
        Mapping.prototype._map = function _map(pos, assoc, simple) {
            var this$1 = this;
            var deleted = false,
                recoverables = null;
            for (var i = this.from; i < this.to; i++) {
                var map = this$1.maps[i],
                    rec = recoverables && recoverables[i];
                if (rec != null && map.touches(pos, rec)) {
                    pos = map.recover(rec);
                    continue;
                }
                var result = map.mapResult(pos, assoc);
                if (result.recover != null) {
                    var corr = this$1.getMirror(i);
                    if (corr != null && corr > i && corr < this$1.to) {
                        if (result.deleted) {
                            i = corr;
                            pos = this$1.maps[corr].recover(result.recover);
                            continue;
                        } else {
                            ;
                            (recoverables || (recoverables = Object.create(null)))[corr] = result.recover;
                        }
                    }
                }
                if (result.deleted) {
                    deleted = true;
                }
                pos = result.pos;
            }
            return simple ? pos : new MapResult(pos, deleted);
        };
        exports.Mapping = Mapping;
        return module.exports;
    });

    $__System.registerDynamic("3c", ["3", "39", "3d"], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        var ref = $__require('3');
        var Slice = ref.Slice;
        var ref$1 = $__require('39');
        var Step = ref$1.Step;
        var StepResult = ref$1.StepResult;
        var ref$2 = $__require('3d');
        var StepMap = ref$2.StepMap;
        var ReplaceStep = (function(Step) {
            function ReplaceStep(from, to, slice, structure) {
                Step.call(this);
                this.from = from;
                this.to = to;
                this.slice = slice;
                this.structure = !!structure;
            }
            if (Step)
                ReplaceStep.__proto__ = Step;
            ReplaceStep.prototype = Object.create(Step && Step.prototype);
            ReplaceStep.prototype.constructor = ReplaceStep;
            ReplaceStep.prototype.apply = function apply(doc) {
                if (this.structure && contentBetween(doc, this.from, this.to)) {
                    return StepResult.fail("Structure replace would overwrite content");
                }
                return StepResult.fromReplace(doc, this.from, this.to, this.slice);
            };
            ReplaceStep.prototype.getMap = function getMap() {
                return new StepMap([this.from, this.to - this.from, this.slice.size]);
            };
            ReplaceStep.prototype.invert = function invert(doc) {
                return new ReplaceStep(this.from, this.from + this.slice.size, doc.slice(this.from, this.to));
            };
            ReplaceStep.prototype.map = function map(mapping) {
                var from = mapping.mapResult(this.from, 1),
                    to = mapping.mapResult(this.to, -1);
                if (from.deleted && to.deleted) {
                    return null;
                }
                return new ReplaceStep(from.pos, Math.max(from.pos, to.pos), this.slice);
            };
            ReplaceStep.prototype.merge = function merge(other) {
                if (!(other instanceof ReplaceStep) || other.structure != this.structure) {
                    return null;
                }
                if (this.from + this.slice.size == other.from && !this.slice.openRight && !other.slice.openLeft) {
                    var slice = this.slice.size + other.slice.size == 0 ? Slice.empty : new Slice(this.slice.content.append(other.slice.content), this.slice.openLeft, other.slice.openRight);
                    return new ReplaceStep(this.from, this.to + (other.to - other.from), slice, this.structure);
                } else if (other.to == this.from && !this.slice.openLeft && !other.slice.openRight) {
                    var slice$1 = this.slice.size + other.slice.size == 0 ? Slice.empty : new Slice(other.slice.content.append(this.slice.content), other.slice.openLeft, this.slice.openRight);
                    return new ReplaceStep(other.from, this.to, slice$1, this.structure);
                } else {
                    return null;
                }
            };
            ReplaceStep.prototype.toJSON = function toJSON() {
                var json = {
                    stepType: "replace",
                    from: this.from,
                    to: this.to
                };
                if (this.slice.size) {
                    json.slice = this.slice.toJSON();
                }
                if (this.structure) {
                    json.structure = true;
                }
                return json;
            };
            ReplaceStep.fromJSON = function fromJSON(schema, json) {
                return new ReplaceStep(json.from, json.to, Slice.fromJSON(schema, json.slice), !!json.structure);
            };
            return ReplaceStep;
        }(Step));
        exports.ReplaceStep = ReplaceStep;
        Step.jsonID("replace", ReplaceStep);
        var ReplaceAroundStep = (function(Step) {
            function ReplaceAroundStep(from, to, gapFrom, gapTo, slice, insert, structure) {
                Step.call(this);
                this.from = from;
                this.to = to;
                this.gapFrom = gapFrom;
                this.gapTo = gapTo;
                this.slice = slice;
                this.insert = insert;
                this.structure = !!structure;
            }
            if (Step)
                ReplaceAroundStep.__proto__ = Step;
            ReplaceAroundStep.prototype = Object.create(Step && Step.prototype);
            ReplaceAroundStep.prototype.constructor = ReplaceAroundStep;
            ReplaceAroundStep.prototype.apply = function apply(doc) {
                if (this.structure && (contentBetween(doc, this.from, this.gapFrom) || contentBetween(doc, this.gapTo, this.to))) {
                    return StepResult.fail("Structure gap-replace would overwrite content");
                }
                var gap = doc.slice(this.gapFrom, this.gapTo);
                if (gap.openLeft || gap.openRight) {
                    return StepResult.fail("Gap is not a flat range");
                }
                var inserted = this.slice.insertAt(this.insert, gap.content);
                if (!inserted) {
                    return StepResult.fail("Content does not fit in gap");
                }
                return StepResult.fromReplace(doc, this.from, this.to, inserted);
            };
            ReplaceAroundStep.prototype.getMap = function getMap() {
                return new StepMap([this.from, this.gapFrom - this.from, this.insert, this.gapTo, this.to - this.gapTo, this.slice.size - this.insert]);
            };
            ReplaceAroundStep.prototype.invert = function invert(doc) {
                var gap = this.gapTo - this.gapFrom;
                return new ReplaceAroundStep(this.from, this.from + this.slice.size + gap, this.from + this.insert, this.from + this.insert + gap, doc.slice(this.from, this.to).removeBetween(this.gapFrom - this.from, this.gapTo - this.from), this.gapFrom - this.from, this.structure);
            };
            ReplaceAroundStep.prototype.map = function map(mapping) {
                var from = mapping.mapResult(this.from, 1),
                    to = mapping.mapResult(this.to, -1);
                var gapFrom = mapping.map(this.gapFrom, -1),
                    gapTo = mapping.map(this.gapTo, 1);
                if ((from.deleted && to.deleted) || gapFrom < from.pos || gapTo > to.pos) {
                    return null;
                }
                return new ReplaceAroundStep(from.pos, to.pos, gapFrom, gapTo, this.slice, this.insert, this.structure);
            };
            ReplaceAroundStep.toJSON = function toJSON() {
                var json = {
                    stepType: "replaceAround",
                    from: this.from,
                    to: this.to,
                    gapFrom: this.gapFrom,
                    gapTo: this.gapTo,
                    slice: this.slice.toJSON()
                };
                if (this.structure) {
                    json.structure = true;
                }
                return true;
            };
            ReplaceAroundStep.fromJSON = function fromJSON(schema, json) {
                return new ReplaceAroundStep(json.from, json.to, json.gapFrom, json.gapTo, Slice.fromJSON(schema, json.slice), json.insert, !!json.structure);
            };
            return ReplaceAroundStep;
        }(Step));
        exports.ReplaceAroundStep = ReplaceAroundStep;
        Step.jsonID("replaceAround", ReplaceAroundStep);
        function contentBetween(doc, from, to) {
            var $from = doc.resolve(from),
                dist = to - from,
                depth = $from.depth;
            while (dist > 0 && depth > 0 && $from.indexAfter(depth) == $from.node(depth).childCount) {
                depth--;
                dist--;
            }
            if (dist > 0) {
                var next = $from.node(depth).maybeChild($from.indexAfter(depth));
                while (dist > 0) {
                    if (!next || next.isLeaf) {
                        return true;
                    }
                    next = next.firstChild;
                    dist--;
                }
            }
            return false;
        }
        return module.exports;
    });

    $__System.registerDynamic("3e", ["3", "3b", "3c"], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        var ref = $__require('3');
        var Slice = ref.Slice;
        var Fragment = ref.Fragment;
        var ref$1 = $__require('3b');
        var Transform = ref$1.Transform;
        var ref$2 = $__require('3c');
        var ReplaceStep = ref$2.ReplaceStep;
        var ReplaceAroundStep = ref$2.ReplaceAroundStep;
        function canCut(node, start, end) {
            return (start == 0 || node.canReplace(start, node.childCount)) && (end == node.childCount || node.canReplace(0, end));
        }
        function liftTarget(range) {
            var parent = range.parent;
            var content = parent.content.cutByIndex(range.startIndex, range.endIndex);
            for (var depth = range.depth; ; --depth) {
                var node = range.$from.node(depth),
                    index = range.$from.index(depth),
                    endIndex = range.$to.indexAfter(depth);
                if (depth < range.depth && node.canReplace(index, endIndex, content)) {
                    return depth;
                }
                if (depth == 0 || !canCut(node, index, endIndex)) {
                    break;
                }
            }
        }
        exports.liftTarget = liftTarget;
        Transform.prototype.lift = function(range, target) {
            var $from = range.$from;
            var $to = range.$to;
            var depth = range.depth;
            var gapStart = $from.before(depth + 1),
                gapEnd = $to.after(depth + 1);
            var start = gapStart,
                end = gapEnd;
            var before = Fragment.empty,
                openLeft = 0;
            for (var d = depth,
                     splitting = false; d > target; d--) {
                if (splitting || $from.index(d) > 0) {
                    splitting = true;
                    before = Fragment.from($from.node(d).copy(before));
                    openLeft++;
                } else {
                    start--;
                }
            }
            var after = Fragment.empty,
                openRight = 0;
            for (var d$1 = depth,
                     splitting$1 = false; d$1 > target; d$1--) {
                if (splitting$1 || $to.after(d$1 + 1) < $to.end(d$1)) {
                    splitting$1 = true;
                    after = Fragment.from($to.node(d$1).copy(after));
                    openRight++;
                } else {
                    end++;
                }
            }
            return this.step(new ReplaceAroundStep(start, end, gapStart, gapEnd, new Slice(before.append(after), openLeft, openRight), before.size - openLeft, true));
        };
        function findWrapping(range, nodeType, attrs, innerRange) {
            if (innerRange === void 0)
                innerRange = range;
            var wrap = {
                type: nodeType,
                attrs: attrs
            };
            var around = findWrappingOutside(range, wrap);
            var inner = around && findWrappingInside(innerRange, wrap);
            if (!inner) {
                return null;
            }
            return around.concat(wrap).concat(inner);
        }
        exports.findWrapping = findWrapping;
        function findWrappingOutside(range, wrap) {
            var parent = range.parent;
            var startIndex = range.startIndex;
            var endIndex = range.endIndex;
            var around = parent.contentMatchAt(startIndex).findWrapping(wrap.type, wrap.attrs);
            if (!around) {
                return null;
            }
            var outer = around.length ? around[0] : wrap;
            if (!parent.canReplaceWith(startIndex, endIndex, outer.type, outer.attrs)) {
                return null;
            }
            return around;
        }
        function findWrappingInside(range, wrap) {
            var parent = range.parent;
            var startIndex = range.startIndex;
            var endIndex = range.endIndex;
            var inner = parent.child(startIndex);
            var inside = wrap.type.contentExpr.start(wrap.attrs).findWrappingFor(inner);
            if (!inside) {
                return null;
            }
            var last = inside.length ? inside[inside.length - 1] : wrap;
            var innerMatch = last.type.contentExpr.start(last.attrs);
            for (var i = startIndex; i < endIndex; i++) {
                innerMatch = innerMatch && innerMatch.matchNode(parent.child(i));
            }
            if (!innerMatch || !innerMatch.validEnd()) {
                return null;
            }
            return inside;
        }
        Transform.prototype.wrap = function(range, wrappers) {
            var content = Fragment.empty;
            for (var i = wrappers.length - 1; i >= 0; i--) {
                content = Fragment.from(wrappers[i].type.create(wrappers[i].attrs, content));
            }
            var start = range.start,
                end = range.end;
            return this.step(new ReplaceAroundStep(start, end, start, end, new Slice(content, 0, 0), wrappers.length, true));
        };
        Transform.prototype.setBlockType = function(from, to, type, attrs) {
            var this$1 = this;
            if (to === void 0)
                to = from;
            if (!type.isTextblock) {
                throw new RangeError("Type given to setBlockType should be a textblock");
            }
            var mapFrom = this.steps.length;
            this.doc.nodesBetween(from, to, function(node, pos) {
                if (node.isTextblock && !node.hasMarkup(type, attrs)) {
                    this$1.clearNonMatching(this$1.mapping.slice(mapFrom).map(pos, 1), type.contentExpr.start(attrs));
                    var mapping = this$1.mapping.slice(mapFrom);
                    var startM = mapping.map(pos, 1),
                        endM = mapping.map(pos + node.nodeSize, 1);
                    this$1.step(new ReplaceAroundStep(startM, endM, startM + 1, endM - 1, new Slice(Fragment.from(type.create(attrs)), 0, 0), 1, true));
                    return false;
                }
            });
            return this;
        };
        Transform.prototype.setNodeType = function(pos, type, attrs) {
            var node = this.doc.nodeAt(pos);
            if (!node) {
                throw new RangeError("No node at given position");
            }
            if (!type) {
                type = node.type;
            }
            if (node.isLeaf) {
                return this.replaceWith(pos, pos + node.nodeSize, type.create(attrs, null, node.marks));
            }
            if (!type.validContent(node.content, attrs)) {
                throw new RangeError("Invalid content for node type " + type.name);
            }
            return this.step(new ReplaceAroundStep(pos, pos + node.nodeSize, pos + 1, pos + node.nodeSize - 1, new Slice(Fragment.from(type.create(attrs)), 0, 0), 1, true));
        };
        function canSplit(doc, pos, depth, typesAfter) {
            if (depth === void 0)
                depth = 1;
            var $pos = doc.resolve(pos),
                base = $pos.depth - depth;
            if (base < 0 || !$pos.parent.canReplace($pos.index(), $pos.parent.childCount) || !$pos.parent.canReplace(0, $pos.indexAfter())) {
                return false;
            }
            for (var d = $pos.depth - 1,
                     i = depth - 1; d > base; d--, i--) {
                var node = $pos.node(d),
                    index$1 = $pos.index(d);
                var typeAfter = typesAfter && typesAfter[i];
                if (!node.canReplace(0, index$1) || !node.canReplaceWith(index$1, node.childCount, typeAfter ? typeAfter.type : $pos.node(d + 1).type, typeAfter ? typeAfter.attrs : $pos.node(d + 1).attrs)) {
                    return false;
                }
            }
            var index = $pos.indexAfter(base);
            var baseType = typesAfter && typesAfter[0];
            return $pos.node(base).canReplaceWith(index, index, baseType ? baseType.type : $pos.node(base + 1).type, baseType ? baseType.attrs : $pos.node(base + 1).attrs);
        }
        exports.canSplit = canSplit;
        Transform.prototype.split = function(pos, depth, typesAfter) {
            if (depth === void 0)
                depth = 1;
            var $pos = this.doc.resolve(pos),
                before = Fragment.empty,
                after = Fragment.empty;
            for (var d = $pos.depth,
                     e = $pos.depth - depth,
                     i = depth - 1; d > e; d--, i--) {
                before = Fragment.from($pos.node(d).copy(before));
                var typeAfter = typesAfter && typesAfter[i];
                after = Fragment.from(typeAfter ? typeAfter.type.create(typeAfter.attrs, after) : $pos.node(d).copy(after));
            }
            return this.step(new ReplaceStep(pos, pos, new Slice(before.append(after), depth, depth, true)));
        };
        function canJoin(doc, pos) {
            var $pos = doc.resolve(pos),
                index = $pos.index();
            return joinable($pos.nodeBefore, $pos.nodeAfter) && $pos.parent.canReplace(index, index + 1);
        }
        exports.canJoin = canJoin;
        function joinable(a, b) {
            return a && b && !a.isLeaf && a.canAppend(b);
        }
        function joinPoint(doc, pos, dir) {
            if (dir === void 0)
                dir = -1;
            var $pos = doc.resolve(pos);
            for (var d = $pos.depth; ; d--) {
                var before = (void 0),
                    after = (void 0);
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
                if (before && !before.isTextblock && joinable(before, after)) {
                    return pos;
                }
                if (d == 0) {
                    break;
                }
                pos = dir < 0 ? $pos.before(d) : $pos.after(d);
            }
        }
        exports.joinPoint = joinPoint;
        Transform.prototype.join = function(pos, depth) {
            if (depth === void 0)
                depth = 1;
            var step = new ReplaceStep(pos - depth, pos + depth, Slice.empty, true);
            return this.step(step);
        };
        function insertPoint(doc, pos, nodeType, attrs) {
            var $pos = doc.resolve(pos);
            if ($pos.parent.canReplaceWith($pos.index(), $pos.index(), nodeType, attrs)) {
                return pos;
            }
            if ($pos.parentOffset == 0) {
                for (var d = $pos.depth - 1; d >= 0; d--) {
                    var index = $pos.index(d);
                    if ($pos.node(d).canReplaceWith(index, index, nodeType, attrs)) {
                        return $pos.before(d + 1);
                    }
                    if (index > 0) {
                        return null;
                    }
                }
            }
            if ($pos.parentOffset == $pos.parent.content.size) {
                for (var d$1 = $pos.depth - 1; d$1 >= 0; d$1--) {
                    var index$1 = $pos.indexAfter(d$1);
                    if ($pos.node(d$1).canReplaceWith(index$1, index$1, nodeType, attrs)) {
                        return $pos.after(d$1 + 1);
                    }
                    if (index$1 < $pos.node(d$1).childCount) {
                        return null;
                    }
                }
            }
        }
        exports.insertPoint = insertPoint;
        return module.exports;
    });

    $__System.registerDynamic("3f", ["3", "3c", "3b", "3e"], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        var ref = $__require('3');
        var Fragment = ref.Fragment;
        var Slice = ref.Slice;
        var ref$1 = $__require('3c');
        var ReplaceStep = ref$1.ReplaceStep;
        var ReplaceAroundStep = ref$1.ReplaceAroundStep;
        var ref$2 = $__require('3b');
        var Transform = ref$2.Transform;
        var ref$3 = $__require('3e');
        var insertPoint = ref$3.insertPoint;
        Transform.prototype.replaceRange = function(from, to, slice) {
            var this$1 = this;
            if (!slice.size) {
                return this.deleteRange(from, to);
            }
            var $from = this.doc.resolve(from);
            if (fitsTrivially($from, this.doc.resolve(to), slice)) {
                return this.step(new ReplaceStep(from, to, slice));
            }
            var canExpand = coveredDepths($from, this.doc.resolve(to)),
                preferredExpand = 0;
            canExpand.unshift($from.depth + 1);
            for (var d = $from.depth; d > 0; d--) {
                if ($from.node(d).type.spec.defining) {
                    break;
                }
                var found = canExpand.indexOf(d, 1);
                if (found > -1) {
                    preferredExpand = found;
                }
            }
            var leftNodes = [],
                preferredDepth = slice.openLeft;
            for (var content = slice.content,
                     i = 0; ; i++) {
                var node = content.firstChild;
                leftNodes.push(node);
                if (i == slice.openLeft) {
                    break;
                }
                content = node.content;
            }
            if (preferredDepth > 0 && leftNodes[preferredDepth - 1].type.spec.defining) {
                preferredDepth -= 1;
            } else if (preferredDepth >= 2 && leftNodes[preferredDepth - 1].isTextblock && leftNodes[preferredDepth - 2].type.spec.defining) {
                preferredDepth -= 2;
            }
            for (var j = slice.openLeft; j >= 0; j--) {
                var openDepth = (j + preferredDepth + 1) % (slice.openLeft + 1);
                var insert = leftNodes[openDepth];
                if (!insert) {
                    continue;
                }
                for (var i$1 = 0; i$1 < canExpand.length; i$1++) {
                    var expandDepth = canExpand[(i$1 + preferredExpand) % canExpand.length];
                    var parent = $from.node(expandDepth - 1),
                        index = $from.index(expandDepth - 1);
                    if (parent.canReplaceWith(index, index, insert.type, insert.attrs, insert.marks)) {
                        return this$1.replace($from.before(expandDepth), expandDepth > $from.depth ? to : $from.after(expandDepth), new Slice(closeFragment(slice.content, 0, slice.openLeft, openDepth), openDepth, slice.openRight));
                    }
                }
            }
            return this.replace(from, to, slice);
        };
        function closeFragment(fragment, depth, oldOpen, newOpen, parent) {
            if (depth < oldOpen) {
                var first = fragment.firstChild;
                fragment = fragment.replaceChild(0, first.copy(closeFragment(first.content, depth + 1, oldOpen, newOpen, first)));
            }
            if (depth > newOpen) {
                fragment = parent.contentMatchAt(0).fillBefore(fragment).append(fragment);
            }
            return fragment;
        }
        Transform.prototype.replaceRangeWith = function(from, to, node) {
            if (!node.isInline && from == to && this.doc.resolve(from).parent.content.size) {
                var point = insertPoint(this.doc, from, node.type, node.attrs);
                if (point != null) {
                    from = to = point;
                }
            }
            return this.replaceRange(from, to, new Slice(Fragment.from(node), 0, 0));
        };
        Transform.prototype.deleteRange = function(from, to) {
            var $from = this.doc.resolve(from);
            var covered = coveredDepths($from, this.doc.resolve(to)),
                grown = false;
            for (var i = 0; i < covered.length; i++) {
                if ($from.node(covered[i]).contentMatchAt(0).validEnd()) {
                    from = $from.start(covered[i]);
                    to = $from.end(covered[i]);
                    grown = true;
                    break;
                }
            }
            if (!grown && covered.length) {
                var depth = covered[covered.length - 1];
                if ($from.node(depth - 1).canReplace($from.index(depth - 1), $from.indexAfter(depth - 1))) {
                    from = $from.before(depth);
                    to = $from.after(depth);
                }
            }
            return this.delete(from, to);
        };
        function coveredDepths($from, $to) {
            var result = [];
            for (var i = 0; i < $from.depth; i++) {
                var depth = $from.depth - i;
                if ($from.pos - i > $from.start(depth)) {
                    break;
                }
                if ($to.depth >= depth && $to.pos + ($to.depth - depth) == $from.end(depth)) {
                    result.push(depth);
                }
            }
            return result;
        }
        Transform.prototype.delete = function(from, to) {
            return this.replace(from, to, Slice.empty);
        };
        function replaceStep(doc, from, to, slice) {
            if (to === void 0)
                to = from;
            if (slice === void 0)
                slice = Slice.empty;
            if (from == to && !slice.size) {
                return null;
            }
            var $from = doc.resolve(from),
                $to = doc.resolve(to);
            if (fitsTrivially($from, $to, slice)) {
                return new ReplaceStep(from, to, slice);
            }
            var placed = placeSlice($from, slice);
            var fittedLeft = fitLeft($from, placed);
            var fitted = fitRight($from, $to, fittedLeft);
            if (!fitted) {
                return null;
            }
            if (fittedLeft.size != fitted.size && canMoveText($from, $to, fittedLeft)) {
                var d = $to.depth,
                    after = $to.after(d);
                while (d > 1 && after == $to.end(--d)) {
                    ++after;
                }
                var fittedAfter = fitRight($from, doc.resolve(after), fittedLeft);
                if (fittedAfter) {
                    return new ReplaceAroundStep(from, after, to, $to.end(), fittedAfter, fittedLeft.size);
                }
            }
            return new ReplaceStep(from, to, fitted);
        }
        exports.replaceStep = replaceStep;
        Transform.prototype.replace = function(from, to, slice) {
            if (to === void 0)
                to = from;
            if (slice === void 0)
                slice = Slice.empty;
            var step = replaceStep(this.doc, from, to, slice);
            if (step) {
                this.step(step);
            }
            return this;
        };
        Transform.prototype.replaceWith = function(from, to, content) {
            return this.replace(from, to, new Slice(Fragment.from(content), 0, 0));
        };
        Transform.prototype.insert = function(pos, content) {
            return this.replaceWith(pos, pos, content);
        };
        function fitLeftInner($from, depth, placed, placedBelow) {
            var content = Fragment.empty,
                openRight = 0,
                placedHere = placed[depth];
            if ($from.depth > depth) {
                var inner = fitLeftInner($from, depth + 1, placed, placedBelow || placedHere);
                openRight = inner.openRight + 1;
                content = Fragment.from($from.node(depth + 1).copy(inner.content));
            }
            if (placedHere) {
                content = content.append(placedHere.content);
                openRight = placedHere.openRight;
            }
            if (placedBelow) {
                content = content.append($from.node(depth).contentMatchAt($from.indexAfter(depth)).fillBefore(Fragment.empty, true));
                openRight = 0;
            }
            return {
                content: content,
                openRight: openRight
            };
        }
        function fitLeft($from, placed) {
            var ref = fitLeftInner($from, 0, placed, false);
            var content = ref.content;
            var openRight = ref.openRight;
            return new Slice(content, $from.depth, openRight || 0);
        }
        function fitRightJoin(content, parent, $from, $to, depth, openLeft, openRight) {
            var match,
                count = content.childCount,
                matchCount = count - (openRight > 0 ? 1 : 0);
            if (openLeft < 0) {
                match = parent.contentMatchAt(matchCount);
            } else if (count == 1 && openRight > 0) {
                match = $from.node(depth).contentMatchAt(openLeft ? $from.index(depth) : $from.indexAfter(depth));
            } else {
                match = $from.node(depth).contentMatchAt($from.indexAfter(depth)).matchFragment(content, count > 0 && openLeft ? 1 : 0, matchCount);
            }
            var toNode = $to.node(depth);
            if (openRight > 0 && depth < $to.depth) {
                var after = toNode.content.cutByIndex($to.indexAfter(depth)).addToStart(content.lastChild);
                var joinable$1 = match.fillBefore(after, true);
                if (joinable$1 && joinable$1.size && openLeft > 0 && count == 1) {
                    joinable$1 = null;
                }
                if (joinable$1) {
                    var inner = fitRightJoin(content.lastChild.content, content.lastChild, $from, $to, depth + 1, count == 1 ? openLeft - 1 : -1, openRight - 1);
                    if (inner) {
                        var last = content.lastChild.copy(inner);
                        if (joinable$1.size) {
                            return content.cutByIndex(0, count - 1).append(joinable$1).addToEnd(last);
                        } else {
                            return content.replaceChild(count - 1, last);
                        }
                    }
                }
            }
            if (openRight > 0) {
                match = match.matchNode(count == 1 && openLeft > 0 ? $from.node(depth + 1) : content.lastChild);
            }
            var toIndex = $to.index(depth);
            if (toIndex == toNode.childCount && !toNode.type.compatibleContent(parent.type)) {
                return null;
            }
            var joinable = match.fillBefore(toNode.content, true, toIndex);
            if (!joinable) {
                return null;
            }
            if (openRight > 0) {
                var closed = fitRightClosed(content.lastChild, openRight - 1, $from, depth + 1, count == 1 ? openLeft - 1 : -1);
                content = content.replaceChild(count - 1, closed);
            }
            content = content.append(joinable);
            if ($to.depth > depth) {
                content = content.addToEnd(fitRightSeparate($to, depth + 1));
            }
            return content;
        }
        function fitRightClosed(node, openRight, $from, depth, openLeft) {
            var match,
                content = node.content,
                count = content.childCount;
            if (openLeft >= 0) {
                match = $from.node(depth).contentMatchAt($from.indexAfter(depth)).matchFragment(content, openLeft > 0 ? 1 : 0, count);
            } else {
                match = node.contentMatchAt(count);
            }
            if (openRight > 0) {
                var closed = fitRightClosed(content.lastChild, openRight - 1, $from, depth + 1, count == 1 ? openLeft - 1 : -1);
                content = content.replaceChild(count - 1, closed);
            }
            return node.copy(content.append(match.fillBefore(Fragment.empty, true)));
        }
        function fitRightSeparate($to, depth) {
            var node = $to.node(depth);
            var fill = node.contentMatchAt(0).fillBefore(node.content, true, $to.index(depth));
            if ($to.depth > depth) {
                fill = fill.addToEnd(fitRightSeparate($to, depth + 1));
            }
            return node.copy(fill);
        }
        function normalizeSlice(content, openLeft, openRight) {
            while (openLeft > 0 && openRight > 0 && content.childCount == 1) {
                content = content.firstChild.content;
                openLeft--;
                openRight--;
            }
            return new Slice(content, openLeft, openRight);
        }
        function fitRight($from, $to, slice) {
            var fitted = fitRightJoin(slice.content, $from.node(0), $from, $to, 0, slice.openLeft, slice.openRight);
            if (!fitted) {
                return null;
            }
            return normalizeSlice(fitted, slice.openLeft, $to.depth);
        }
        function fitsTrivially($from, $to, slice) {
            return !slice.openLeft && !slice.openRight && $from.start() == $to.start() && $from.parent.canReplace($from.index(), $to.index(), slice.content);
        }
        function canMoveText($from, $to, slice) {
            if (!$to.parent.isTextblock) {
                return false;
            }
            var match;
            if (!slice.openRight) {
                var parent = $from.node($from.depth - (slice.openLeft - slice.openRight));
                if (!parent.isTextblock) {
                    return false;
                }
                match = parent.contentMatchAt(parent.childCount);
                if (slice.size) {
                    match = match.matchFragment(slice.content, slice.openLeft ? 1 : 0);
                }
            } else {
                var parent$1 = nodeRight(slice.content, slice.openRight);
                if (!parent$1.isTextblock) {
                    return false;
                }
                match = parent$1.contentMatchAt(parent$1.childCount);
            }
            match = match.matchFragment($to.parent.content, $to.index());
            return match && match.validEnd();
        }
        function nodeLeft(content, depth) {
            for (var i = 1; i < depth; i++) {
                content = content.firstChild.content;
            }
            return content.firstChild;
        }
        function nodeRight(content, depth) {
            for (var i = 1; i < depth; i++) {
                content = content.lastChild.content;
            }
            return content.lastChild;
        }
        function placeSlice($from, slice) {
            var dFrom = $from.depth,
                unplaced = null;
            var placed = [],
                parents = null;
            for (var dSlice = slice.openLeft; ; --dSlice) {
                var curType = (void 0),
                    curAttrs = (void 0),
                    curFragment = (void 0);
                if (dSlice >= 0) {
                    if (dSlice > 0) {
                        ;
                        var assign;
                        ((assign = nodeLeft(slice.content, dSlice), curType = assign.type, curAttrs = assign.attrs, curFragment = assign.content));
                    } else if (dSlice == 0) {
                        curFragment = slice.content;
                    }
                    if (dSlice < slice.openLeft) {
                        curFragment = curFragment.cut(curFragment.firstChild.nodeSize);
                    }
                } else {
                    curFragment = Fragment.empty;
                    var parent = parents[parents.length + dSlice - 1];
                    curType = parent.type;
                    curAttrs = parent.attrs;
                }
                if (unplaced) {
                    curFragment = curFragment.addToStart(unplaced);
                }
                if (curFragment.size == 0 && dSlice <= 0) {
                    break;
                }
                var found = findPlacement(curFragment, $from, dFrom, placed);
                if (found) {
                    if (found.fragment.size > 0) {
                        placed[found.depth] = {
                            content: found.fragment,
                            openRight: endOfContent(slice, dSlice) ? slice.openRight - dSlice : 0,
                            depth: found.depth
                        };
                    }
                    if (dSlice <= 0) {
                        break;
                    }
                    unplaced = null;
                    dFrom = found.depth - (curType == $from.node(found.depth).type ? 1 : 0);
                } else {
                    if (dSlice == 0) {
                        var top = $from.node(0);
                        var wrap = top.contentMatchAt($from.index(0)).findWrappingFor(curFragment.firstChild);
                        if (!wrap || wrap.length == 0) {
                            break;
                        }
                        var last = wrap[wrap.length - 1];
                        if (!last.type.contentExpr.matches(last.attrs, curFragment)) {
                            break;
                        }
                        parents = [{
                            type: top.type,
                            attrs: top.attrs
                        }].concat(wrap);
                        ;
                        var assign$1;
                        ((assign$1 = last, curType = assign$1.type, curAttrs = assign$1.attrs));
                    }
                    if (curFragment.size) {
                        curFragment = curType.contentExpr.start(curAttrs).fillBefore(curFragment, true).append(curFragment);
                        unplaced = curType.create(curAttrs, curFragment);
                    } else {
                        unplaced = null;
                    }
                }
            }
            return placed;
        }
        function endOfContent(slice, depth) {
            for (var i = 0,
                     content = slice.content; i < depth; i++) {
                if (content.childCount > 1) {
                    return false;
                }
                content = content.firstChild.content;
            }
            return true;
        }
        function findPlacement(fragment, $from, start, placed) {
            var hasMarks = false;
            for (var i = 0; i < fragment.childCount; i++) {
                if (fragment.child(i).marks.length) {
                    hasMarks = true;
                }
            }
            for (var d = start; d >= 0; d--) {
                var startMatch = $from.node(d).contentMatchAt($from.indexAfter(d));
                var existing = placed[d];
                if (existing) {
                    startMatch = startMatch.matchFragment(existing.content);
                }
                var match = startMatch.fillBefore(fragment);
                if (match) {
                    return {
                        depth: d,
                        fragment: (existing ? existing.content.append(match) : match).append(fragment)
                    };
                }
                if (hasMarks) {
                    var stripped = matchStrippingMarks(startMatch, fragment);
                    if (stripped) {
                        return {
                            depth: d,
                            fragment: existing ? existing.content.append(stripped) : stripped
                        };
                    }
                }
            }
        }
        function matchStrippingMarks(match, fragment) {
            var newNodes = [];
            for (var i = 0; i < fragment.childCount; i++) {
                var node = fragment.child(i),
                    stripped = node.mark(node.marks.filter(function(m) {
                        return match.allowsMark(m.type);
                    }));
                match = match.matchNode(stripped);
                if (!match) {
                    return null;
                }
                newNodes.push(stripped);
            }
            return Fragment.from(newNodes);
        }
        return module.exports;
    });

    $__System.registerDynamic("40", ["3b", "39", "3e", "3d", "38", "3c", "3a", "3f"], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        ;
        var assign;
        ((assign = $__require('3b'), exports.Transform = assign.Transform, exports.TransformError = assign.TransformError));
        ;
        var assign$1;
        ((assign$1 = $__require('39'), exports.Step = assign$1.Step, exports.StepResult = assign$1.StepResult));
        ;
        var assign$2;
        ((assign$2 = $__require('3e'), exports.joinPoint = assign$2.joinPoint, exports.canJoin = assign$2.canJoin, exports.canSplit = assign$2.canSplit, exports.insertPoint = assign$2.insertPoint, exports.liftTarget = assign$2.liftTarget, exports.findWrapping = assign$2.findWrapping));
        ;
        var assign$3;
        ((assign$3 = $__require('3d'), exports.StepMap = assign$3.StepMap, exports.MapResult = assign$3.MapResult, exports.Mapping = assign$3.Mapping));
        ;
        var assign$4;
        ((assign$4 = $__require('38'), exports.AddMarkStep = assign$4.AddMarkStep, exports.RemoveMarkStep = assign$4.RemoveMarkStep));
        ;
        var assign$5;
        ((assign$5 = $__require('3c'), exports.ReplaceStep = assign$5.ReplaceStep, exports.ReplaceAroundStep = assign$5.ReplaceAroundStep));
        $__require('3a');
        ;
        var assign$6;
        ((assign$6 = $__require('3f'), exports.replaceStep = assign$6.replaceStep));
        return module.exports;
    });

    $__System.registerDynamic("9", ["40"], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        module.exports = $__require('40');
        return module.exports;
    });

    $__System.registerDynamic("41", [], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        function OrderedMap(content) {
            this.content = content;
        }
        OrderedMap.prototype = {
            constructor: OrderedMap,
            find: function(key) {
                for (var i = 0; i < this.content.length; i += 2)
                    if (this.content[i] === key)
                        return i;
                return -1;
            },
            get: function(key) {
                var found = this.find(key);
                return found == -1 ? undefined : this.content[found + 1];
            },
            update: function(key, value, newKey) {
                var self = newKey && newKey != key ? this.remove(newKey) : this;
                var found = self.find(key),
                    content = self.content.slice();
                if (found == -1) {
                    content.push(newKey || key, value);
                } else {
                    content[found + 1] = value;
                    if (newKey)
                        content[found] = newKey;
                }
                return new OrderedMap(content);
            },
            remove: function(key) {
                var found = this.find(key);
                if (found == -1)
                    return this;
                var content = this.content.slice();
                content.splice(found, 2);
                return new OrderedMap(content);
            },
            addToStart: function(key, value) {
                return new OrderedMap([key, value].concat(this.remove(key).content));
            },
            addToEnd: function(key, value) {
                var content = this.remove(key).content.slice();
                content.push(key, value);
                return new OrderedMap(content);
            },
            addBefore: function(place, key, value) {
                var without = this.remove(key),
                    content = without.content.slice();
                var found = without.find(place);
                content.splice(found == -1 ? content.length : found, 0, key, value);
                return new OrderedMap(content);
            },
            forEach: function(f) {
                for (var i = 0; i < this.content.length; i += 2)
                    f(this.content[i], this.content[i + 1]);
            },
            prepend: function(map) {
                map = OrderedMap.from(map);
                if (!map.size)
                    return this;
                return new OrderedMap(map.content.concat(this.subtract(map).content));
            },
            append: function(map) {
                map = OrderedMap.from(map);
                if (!map.size)
                    return this;
                return new OrderedMap(this.subtract(map).content.concat(map.content));
            },
            subtract: function(map) {
                var result = this;
                map = OrderedMap.from(map);
                for (var i = 0; i < map.content.length; i += 2)
                    result = result.remove(map.content[i]);
                return result;
            },
            get size() {
                return this.content.length >> 1;
            }
        };
        OrderedMap.from = function(value) {
            if (value instanceof OrderedMap)
                return value;
            var content = [];
            if (value)
                for (var prop in value)
                    content.push(prop, value[prop]);
            return new OrderedMap(content);
        };
        module.exports = OrderedMap;
        return module.exports;
    });

    $__System.registerDynamic("42", ["41"], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        module.exports = $__require('41');
        return module.exports;
    });

    $__System.registerDynamic("43", ["44"], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        var ref = $__require('44');
        var Mark = ref.Mark;
        var ResolvedPos = function(pos, path, parentOffset) {
            this.pos = pos;
            this.path = path;
            this.depth = path.length / 3 - 1;
            this.parentOffset = parentOffset;
        };
        var prototypeAccessors = {
            parent: {},
            textOffset: {},
            nodeAfter: {},
            nodeBefore: {}
        };
        ResolvedPos.prototype.resolveDepth = function(val) {
            if (val == null) {
                return this.depth;
            }
            if (val < 0) {
                return this.depth + val;
            }
            return val;
        };
        prototypeAccessors.parent.get = function() {
            return this.node(this.depth);
        };
        ResolvedPos.prototype.node = function(depth) {
            return this.path[this.resolveDepth(depth) * 3];
        };
        ResolvedPos.prototype.index = function(depth) {
            return this.path[this.resolveDepth(depth) * 3 + 1];
        };
        ResolvedPos.prototype.indexAfter = function(depth) {
            depth = this.resolveDepth(depth);
            return this.index(depth) + (depth == this.depth && !this.textOffset ? 0 : 1);
        };
        ResolvedPos.prototype.start = function(depth) {
            depth = this.resolveDepth(depth);
            return depth == 0 ? 0 : this.path[depth * 3 - 1] + 1;
        };
        ResolvedPos.prototype.end = function(depth) {
            depth = this.resolveDepth(depth);
            return this.start(depth) + this.node(depth).content.size;
        };
        ResolvedPos.prototype.before = function(depth) {
            depth = this.resolveDepth(depth);
            if (!depth) {
                throw new RangeError("There is no position before the top-level node");
            }
            return depth == this.depth + 1 ? this.pos : this.path[depth * 3 - 1];
        };
        ResolvedPos.prototype.after = function(depth) {
            depth = this.resolveDepth(depth);
            if (!depth) {
                throw new RangeError("There is no position after the top-level node");
            }
            return depth == this.depth + 1 ? this.pos : this.path[depth * 3 - 1] + this.path[depth * 3].nodeSize;
        };
        prototypeAccessors.textOffset.get = function() {
            return this.pos - this.path[this.path.length - 1];
        };
        prototypeAccessors.nodeAfter.get = function() {
            var parent = this.parent,
                index = this.index(this.depth);
            if (index == parent.childCount) {
                return null;
            }
            var dOff = this.pos - this.path[this.path.length - 1],
                child = parent.child(index);
            return dOff ? parent.child(index).cut(dOff) : child;
        };
        prototypeAccessors.nodeBefore.get = function() {
            var index = this.index(this.depth);
            var dOff = this.pos - this.path[this.path.length - 1];
            if (dOff) {
                return this.parent.child(index).cut(0, dOff);
            }
            return index == 0 ? null : this.parent.child(index - 1);
        };
        ResolvedPos.prototype.marks = function(after) {
            var parent = this.parent,
                index = this.index();
            if (parent.content.size == 0) {
                return Mark.none;
            }
            if ((after && index < parent.childCount) || index == 0 || this.textOffset) {
                return parent.child(index).marks;
            }
            var marks = parent.child(index - 1).marks;
            for (var i = 0; i < marks.length; i++) {
                if (marks[i].type.spec.inclusiveRight === false) {
                    marks = marks[i--].removeFromSet(marks);
                }
            }
            return marks;
        };
        ResolvedPos.prototype.sharedDepth = function(pos) {
            var this$1 = this;
            for (var depth = this.depth; depth > 0; depth--) {
                if (this$1.start(depth) <= pos && this$1.end(depth) >= pos) {
                    return depth;
                }
            }
            return 0;
        };
        ResolvedPos.prototype.blockRange = function(other, pred) {
            var this$1 = this;
            if (other === void 0)
                other = this;
            if (other.pos < this.pos) {
                return other.blockRange(this);
            }
            for (var d = this.depth - (this.parent.isTextblock || this.pos == other.pos ? 1 : 0); d >= 0; d--) {
                if (other.pos <= this$1.end(d) && (!pred || pred(this$1.node(d)))) {
                    return new NodeRange(this$1, other, d);
                }
            }
        };
        ResolvedPos.prototype.sameParent = function(other) {
            return this.pos - this.parentOffset == other.pos - other.parentOffset;
        };
        ResolvedPos.prototype.toString = function() {
            var this$1 = this;
            var str = "";
            for (var i = 1; i <= this.depth; i++) {
                str += (str ? "/" : "") + this$1.node(i).type.name + "_" + this$1.index(i - 1);
            }
            return str + ":" + this.parentOffset;
        };
        ResolvedPos.resolve = function(doc, pos) {
            if (!(pos >= 0 && pos <= doc.content.size)) {
                throw new RangeError("Position " + pos + " out of range");
            }
            var path = [];
            var start = 0,
                parentOffset = pos;
            for (var node = doc; ; ) {
                var ref = node.content.findIndex(parentOffset);
                var index = ref.index;
                var offset = ref.offset;
                var rem = parentOffset - offset;
                path.push(node, index, start + offset);
                if (!rem) {
                    break;
                }
                node = node.child(index);
                if (node.isText) {
                    break;
                }
                parentOffset = rem - 1;
                start += offset + 1;
            }
            return new ResolvedPos(pos, path, parentOffset);
        };
        ResolvedPos.resolveCached = function(doc, pos) {
            for (var i = 0; i < resolveCache.length; i++) {
                var cached = resolveCache[i];
                if (cached.pos == pos && cached.node(0) == doc) {
                    return cached;
                }
            }
            var result = resolveCache[resolveCachePos] = ResolvedPos.resolve(doc, pos);
            resolveCachePos = (resolveCachePos + 1) % resolveCacheSize;
            return result;
        };
        Object.defineProperties(ResolvedPos.prototype, prototypeAccessors);
        exports.ResolvedPos = ResolvedPos;
        var resolveCache = [],
            resolveCachePos = 0,
            resolveCacheSize = 6;
        var NodeRange = function($from, $to, depth) {
            this.$from = $from;
            this.$to = $to;
            this.depth = depth;
        };
        var prototypeAccessors$1 = {
            start: {},
            end: {},
            parent: {},
            startIndex: {},
            endIndex: {}
        };
        prototypeAccessors$1.start.get = function() {
            return this.$from.before(this.depth + 1);
        };
        prototypeAccessors$1.end.get = function() {
            return this.$to.after(this.depth + 1);
        };
        prototypeAccessors$1.parent.get = function() {
            return this.$from.node(this.depth);
        };
        prototypeAccessors$1.startIndex.get = function() {
            return this.$from.index(this.depth);
        };
        prototypeAccessors$1.endIndex.get = function() {
            return this.$to.indexAfter(this.depth);
        };
        Object.defineProperties(NodeRange.prototype, prototypeAccessors$1);
        exports.NodeRange = NodeRange;
        return module.exports;
    });

    $__System.registerDynamic("45", ["46", "44", "47", "43", "48"], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        var ref = $__require('46');
        var Fragment = ref.Fragment;
        var ref$1 = $__require('44');
        var Mark = ref$1.Mark;
        var ref$2 = $__require('47');
        var Slice = ref$2.Slice;
        var replace = ref$2.replace;
        var ref$3 = $__require('43');
        var ResolvedPos = ref$3.ResolvedPos;
        var ref$4 = $__require('48');
        var compareDeep = ref$4.compareDeep;
        var emptyAttrs = Object.create(null);
        var warnedAboutMarksAt = false;
        var Node = function(type, attrs, content, marks) {
            this.type = type;
            this.attrs = attrs;
            this.content = content || Fragment.empty;
            this.marks = marks || Mark.none;
        };
        var prototypeAccessors = {
            nodeSize: {},
            childCount: {},
            textContent: {},
            firstChild: {},
            lastChild: {},
            isBlock: {},
            isTextblock: {},
            isInline: {},
            isText: {},
            isLeaf: {}
        };
        prototypeAccessors.nodeSize.get = function() {
            return this.isLeaf ? 1 : 2 + this.content.size;
        };
        prototypeAccessors.childCount.get = function() {
            return this.content.childCount;
        };
        Node.prototype.child = function(index) {
            return this.content.child(index);
        };
        Node.prototype.maybeChild = function(index) {
            return this.content.maybeChild(index);
        };
        Node.prototype.forEach = function(f) {
            this.content.forEach(f);
        };
        Node.prototype.nodesBetween = function(from, to, f, pos) {
            if (pos === void 0)
                pos = 0;
            this.content.nodesBetween(from, to, f, pos, this);
        };
        Node.prototype.descendants = function(f) {
            this.nodesBetween(0, this.content.size, f);
        };
        prototypeAccessors.textContent.get = function() {
            return this.textBetween(0, this.content.size, "");
        };
        Node.prototype.textBetween = function(from, to, blockSeparator, leafText) {
            return this.content.textBetween(from, to, blockSeparator, leafText);
        };
        prototypeAccessors.firstChild.get = function() {
            return this.content.firstChild;
        };
        prototypeAccessors.lastChild.get = function() {
            return this.content.lastChild;
        };
        Node.prototype.eq = function(other) {
            return this == other || (this.sameMarkup(other) && this.content.eq(other.content));
        };
        Node.prototype.sameMarkup = function(other) {
            return this.hasMarkup(other.type, other.attrs, other.marks);
        };
        Node.prototype.hasMarkup = function(type, attrs, marks) {
            return this.type == type && compareDeep(this.attrs, attrs || type.defaultAttrs || emptyAttrs) && Mark.sameSet(this.marks, marks || Mark.none);
        };
        Node.prototype.copy = function(content) {
            if (content === void 0)
                content = null;
            if (content == this.content) {
                return this;
            }
            return new this.constructor(this.type, this.attrs, content, this.marks);
        };
        Node.prototype.mark = function(marks) {
            return marks == this.marks ? this : new this.constructor(this.type, this.attrs, this.content, marks);
        };
        Node.prototype.cut = function(from, to) {
            if (from == 0 && to == this.content.size) {
                return this;
            }
            return this.copy(this.content.cut(from, to));
        };
        Node.prototype.slice = function(from, to, includeParents) {
            if (to === void 0)
                to = this.content.size;
            if (includeParents === void 0)
                includeParents = false;
            if (from == to) {
                return Slice.empty;
            }
            var $from = this.resolve(from),
                $to = this.resolve(to);
            var depth = includeParents ? 0 : $from.sharedDepth(to);
            var start = $from.start(depth),
                node = $from.node(depth);
            var content = node.content.cut($from.pos - start, $to.pos - start);
            return new Slice(content, $from.depth - depth, $to.depth - depth);
        };
        Node.prototype.replace = function(from, to, slice) {
            return replace(this.resolve(from), this.resolve(to), slice);
        };
        Node.prototype.nodeAt = function(pos) {
            for (var node = this; ; ) {
                var ref = node.content.findIndex(pos);
                var index = ref.index;
                var offset = ref.offset;
                node = node.maybeChild(index);
                if (!node) {
                    return null;
                }
                if (offset == pos || node.isText) {
                    return node;
                }
                pos -= offset + 1;
            }
        };
        Node.prototype.childAfter = function(pos) {
            var ref = this.content.findIndex(pos);
            var index = ref.index;
            var offset = ref.offset;
            return {
                node: this.content.maybeChild(index),
                index: index,
                offset: offset
            };
        };
        Node.prototype.childBefore = function(pos) {
            if (pos == 0) {
                return {
                    node: null,
                    index: 0,
                    offset: 0
                };
            }
            var ref = this.content.findIndex(pos);
            var index = ref.index;
            var offset = ref.offset;
            if (offset < pos) {
                return {
                    node: this.content.child(index),
                    index: index,
                    offset: offset
                };
            }
            var node = this.content.child(index - 1);
            return {
                node: node,
                index: index - 1,
                offset: offset - node.nodeSize
            };
        };
        Node.prototype.resolve = function(pos) {
            return ResolvedPos.resolveCached(this, pos);
        };
        Node.prototype.resolveNoCache = function(pos) {
            return ResolvedPos.resolve(this, pos);
        };
        Node.prototype.marksAt = function(pos, useAfter) {
            if (!warnedAboutMarksAt && typeof console != "undefined" && console.warn) {
                warnedAboutMarksAt = true;
                console.warn("Node.marksAt is deprecated. Use ResolvedPos.marks instead.");
            }
            return this.resolve(pos).marks(useAfter);
        };
        Node.prototype.rangeHasMark = function(from, to, type) {
            var found = false;
            this.nodesBetween(from, to, function(node) {
                if (type.isInSet(node.marks)) {
                    found = true;
                }
                return !found;
            });
            return found;
        };
        prototypeAccessors.isBlock.get = function() {
            return this.type.isBlock;
        };
        prototypeAccessors.isTextblock.get = function() {
            return this.type.isTextblock;
        };
        prototypeAccessors.isInline.get = function() {
            return this.type.isInline;
        };
        prototypeAccessors.isText.get = function() {
            return this.type.isText;
        };
        prototypeAccessors.isLeaf.get = function() {
            return this.type.isLeaf;
        };
        Node.prototype.toString = function() {
            var name = this.type.name;
            if (this.content.size) {
                name += "(" + this.content.toStringInner() + ")";
            }
            return wrapMarks(this.marks, name);
        };
        Node.prototype.contentMatchAt = function(index) {
            return this.type.contentExpr.getMatchAt(this.attrs, this.content, index);
        };
        Node.prototype.canReplace = function(from, to, replacement, start, end) {
            return this.type.contentExpr.checkReplace(this.attrs, this.content, from, to, replacement, start, end);
        };
        Node.prototype.canReplaceWith = function(from, to, type, attrs, marks) {
            return this.type.contentExpr.checkReplaceWith(this.attrs, this.content, from, to, type, attrs, marks || Mark.none);
        };
        Node.prototype.canAppend = function(other) {
            if (other.content.size) {
                return this.canReplace(this.childCount, this.childCount, other.content);
            } else {
                return this.type.compatibleContent(other.type);
            }
        };
        Node.prototype.defaultContentType = function(at) {
            var elt = this.contentMatchAt(at).nextElement;
            return elt && elt.defaultType();
        };
        Node.prototype.toJSON = function() {
            var this$1 = this;
            var obj = {type: this.type.name};
            for (var _ in this$1.attrs) {
                obj.attrs = this$1.attrs;
                break;
            }
            if (this.content.size) {
                obj.content = this.content.toJSON();
            }
            if (this.marks.length) {
                obj.marks = this.marks.map(function(n) {
                    return n.toJSON();
                });
            }
            return obj;
        };
        Node.fromJSON = function(schema, json) {
            var marks = json.marks && json.marks.map(schema.markFromJSON);
            if (json.type == "text") {
                return schema.text(json.text, marks);
            }
            return schema.nodeType(json.type).create(json.attrs, Fragment.fromJSON(schema, json.content), marks);
        };
        Object.defineProperties(Node.prototype, prototypeAccessors);
        exports.Node = Node;
        var TextNode = (function(Node) {
            function TextNode(type, attrs, content, marks) {
                Node.call(this, type, attrs, null, marks);
                if (!content) {
                    throw new RangeError("Empty text nodes are not allowed");
                }
                this.text = content;
            }
            if (Node)
                TextNode.__proto__ = Node;
            TextNode.prototype = Object.create(Node && Node.prototype);
            TextNode.prototype.constructor = TextNode;
            var prototypeAccessors$1 = {
                textContent: {},
                nodeSize: {}
            };
            TextNode.prototype.toString = function() {
                return wrapMarks(this.marks, JSON.stringify(this.text));
            };
            prototypeAccessors$1.textContent.get = function() {
                return this.text;
            };
            TextNode.prototype.textBetween = function(from, to) {
                return this.text.slice(from, to);
            };
            prototypeAccessors$1.nodeSize.get = function() {
                return this.text.length;
            };
            TextNode.prototype.mark = function(marks) {
                return new TextNode(this.type, this.attrs, this.text, marks);
            };
            TextNode.prototype.withText = function(text) {
                if (text == this.text) {
                    return this;
                }
                return new TextNode(this.type, this.attrs, text, this.marks);
            };
            TextNode.prototype.cut = function(from, to) {
                if (from === void 0)
                    from = 0;
                if (to === void 0)
                    to = this.text.length;
                if (from == 0 && to == this.text.length) {
                    return this;
                }
                return this.withText(this.text.slice(from, to));
            };
            TextNode.prototype.eq = function(other) {
                return this.sameMarkup(other) && this.text == other.text;
            };
            TextNode.prototype.toJSON = function() {
                var base = Node.prototype.toJSON.call(this);
                base.text = this.text;
                return base;
            };
            Object.defineProperties(TextNode.prototype, prototypeAccessors$1);
            return TextNode;
        }(Node));
        exports.TextNode = TextNode;
        function wrapMarks(marks, str) {
            for (var i = marks.length - 1; i >= 0; i--) {
                str = marks[i].type.name + "(" + str + ")";
            }
            return str;
        }
        return module.exports;
    });

    $__System.registerDynamic("49", ["42", "45", "46", "44", "4a"], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        var OrderedMap = $__require('42');
        var ref = $__require('45');
        var Node = ref.Node;
        var TextNode = ref.TextNode;
        var ref$1 = $__require('46');
        var Fragment = ref$1.Fragment;
        var ref$2 = $__require('44');
        var Mark = ref$2.Mark;
        var ref$3 = $__require('4a');
        var ContentExpr = ref$3.ContentExpr;
        function defaultAttrs(attrs) {
            var defaults = Object.create(null);
            for (var attrName in attrs) {
                var attr = attrs[attrName];
                if (attr.default === undefined) {
                    return null;
                }
                defaults[attrName] = attr.default;
            }
            return defaults;
        }
        function computeAttrs(attrs, value) {
            var built = Object.create(null);
            for (var name in attrs) {
                var given = value && value[name];
                if (given == null) {
                    var attr = attrs[name];
                    if (attr.default !== undefined) {
                        given = attr.default;
                    } else if (attr.compute) {
                        given = attr.compute();
                    } else {
                        throw new RangeError("No value supplied for attribute " + name);
                    }
                }
                built[name] = given;
            }
            return built;
        }
        function initAttrs(attrs) {
            var result = Object.create(null);
            if (attrs) {
                for (var name in attrs) {
                    result[name] = new Attribute(attrs[name]);
                }
            }
            return result;
        }
        var NodeType = function(name, schema, spec) {
            this.name = name;
            this.schema = schema;
            this.spec = spec;
            this.attrs = initAttrs(spec.attrs);
            this.defaultAttrs = defaultAttrs(this.attrs);
            this.contentExpr = null;
            this.isBlock = !(spec.inline || name == "text");
            this.isText = name == "text";
        };
        var prototypeAccessors = {
            isInline: {},
            isTextblock: {},
            isLeaf: {}
        };
        prototypeAccessors.isInline.get = function() {
            return !this.isBlock;
        };
        prototypeAccessors.isTextblock.get = function() {
            return this.isBlock && this.contentExpr.inlineContent;
        };
        prototypeAccessors.isLeaf.get = function() {
            return this.contentExpr.isLeaf;
        };
        NodeType.prototype.hasRequiredAttrs = function(ignore) {
            var this$1 = this;
            for (var n in this$1.attrs) {
                if (this$1.attrs[n].isRequired && (!ignore || !(n in ignore))) {
                    return true;
                }
            }
            return false;
        };
        NodeType.prototype.compatibleContent = function(other) {
            return this == other || this.contentExpr.compatible(other.contentExpr);
        };
        NodeType.prototype.computeAttrs = function(attrs) {
            if (!attrs && this.defaultAttrs) {
                return this.defaultAttrs;
            } else {
                return computeAttrs(this.attrs, attrs);
            }
        };
        NodeType.prototype.create = function(attrs, content, marks) {
            if (typeof content == "string") {
                throw new Error("Calling create with string");
            }
            return new Node(this, this.computeAttrs(attrs), Fragment.from(content), Mark.setFrom(marks));
        };
        NodeType.prototype.createChecked = function(attrs, content, marks) {
            attrs = this.computeAttrs(attrs);
            content = Fragment.from(content);
            if (!this.validContent(content, attrs)) {
                throw new RangeError("Invalid content for node " + this.name);
            }
            return new Node(this, attrs, content, Mark.setFrom(marks));
        };
        NodeType.prototype.createAndFill = function(attrs, content, marks) {
            attrs = this.computeAttrs(attrs);
            content = Fragment.from(content);
            if (content.size) {
                var before = this.contentExpr.start(attrs).fillBefore(content);
                if (!before) {
                    return null;
                }
                content = before.append(content);
            }
            var after = this.contentExpr.getMatchAt(attrs, content).fillBefore(Fragment.empty, true);
            if (!after) {
                return null;
            }
            return new Node(this, attrs, content.append(after), Mark.setFrom(marks));
        };
        NodeType.prototype.validContent = function(content, attrs) {
            return this.contentExpr.matches(attrs, content);
        };
        NodeType.compile = function(nodes, schema) {
            var result = Object.create(null);
            nodes.forEach(function(name, spec) {
                return result[name] = new NodeType(name, schema, spec);
            });
            if (!result.doc) {
                throw new RangeError("Every schema needs a 'doc' type");
            }
            if (!result.text) {
                throw new RangeError("Every schema needs a 'text' type");
            }
            return result;
        };
        Object.defineProperties(NodeType.prototype, prototypeAccessors);
        exports.NodeType = NodeType;
        var Attribute = function(options) {
            this.default = options.default;
            this.compute = options.compute;
        };
        var prototypeAccessors$1 = {isRequired: {}};
        prototypeAccessors$1.isRequired.get = function() {
            return this.default === undefined && !this.compute;
        };
        Object.defineProperties(Attribute.prototype, prototypeAccessors$1);
        var MarkType = function(name, rank, schema, spec) {
            this.name = name;
            this.schema = schema;
            this.spec = spec;
            this.attrs = initAttrs(spec.attrs);
            this.rank = rank;
            var defaults = defaultAttrs(this.attrs);
            this.instance = defaults && new Mark(this, defaults);
        };
        MarkType.prototype.create = function(attrs) {
            if (!attrs && this.instance) {
                return this.instance;
            }
            return new Mark(this, computeAttrs(this.attrs, attrs));
        };
        MarkType.compile = function(marks, schema) {
            var result = Object.create(null),
                rank = 0;
            marks.forEach(function(name, spec) {
                return result[name] = new MarkType(name, rank++, schema, spec);
            });
            return result;
        };
        MarkType.prototype.removeFromSet = function(set) {
            var this$1 = this;
            for (var i = 0; i < set.length; i++) {
                if (set[i].type == this$1) {
                    return set.slice(0, i).concat(set.slice(i + 1));
                }
            }
            return set;
        };
        MarkType.prototype.isInSet = function(set) {
            var this$1 = this;
            for (var i = 0; i < set.length; i++) {
                if (set[i].type == this$1) {
                    return set[i];
                }
            }
        };
        exports.MarkType = MarkType;
        var Schema = function(spec) {
            var this$1 = this;
            this.nodeSpec = OrderedMap.from(spec.nodes);
            this.markSpec = OrderedMap.from(spec.marks);
            this.nodes = NodeType.compile(this.nodeSpec, this);
            this.marks = MarkType.compile(this.markSpec, this);
            for (var prop in this$1.nodes) {
                if (prop in this$1.marks) {
                    throw new RangeError(prop + " can not be both a node and a mark");
                }
                var type = this$1.nodes[prop];
                type.contentExpr = ContentExpr.parse(type, this$1.nodeSpec.get(prop).content || "", this$1.nodeSpec);
            }
            this.cached = Object.create(null);
            this.cached.wrappings = Object.create(null);
            this.nodeFromJSON = this.nodeFromJSON.bind(this);
            this.markFromJSON = this.markFromJSON.bind(this);
        };
        Schema.prototype.node = function(type, attrs, content, marks) {
            if (typeof type == "string") {
                type = this.nodeType(type);
            } else if (!(type instanceof NodeType)) {
                throw new RangeError("Invalid node type: " + type);
            } else if (type.schema != this) {
                throw new RangeError("Node type from different schema used (" + type.name + ")");
            }
            return type.createChecked(attrs, content, marks);
        };
        Schema.prototype.text = function(text$1, marks) {
            var type = this.nodes.text;
            return new TextNode(type, type.defaultAttrs, text$1, Mark.setFrom(marks));
        };
        Schema.prototype.mark = function(type, attrs) {
            if (typeof type == "string") {
                type = this.marks[type];
            }
            return type.create(attrs);
        };
        Schema.prototype.nodeFromJSON = function(json) {
            return Node.fromJSON(this, json);
        };
        Schema.prototype.markFromJSON = function(json) {
            return Mark.fromJSON(this, json);
        };
        Schema.prototype.nodeType = function(name) {
            var found = this.nodes[name];
            if (!found) {
                throw new RangeError("Unknown node type: " + name);
            }
            return found;
        };
        exports.Schema = Schema;
        return module.exports;
    });

    $__System.registerDynamic("4a", ["46", "44"], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        var ref = $__require('46');
        var Fragment = ref.Fragment;
        var ref$1 = $__require('44');
        var Mark = ref$1.Mark;
        var ContentExpr = function(nodeType, elements, inlineContent) {
            this.nodeType = nodeType;
            this.elements = elements;
            this.inlineContent = inlineContent;
        };
        var prototypeAccessors = {isLeaf: {}};
        prototypeAccessors.isLeaf.get = function() {
            return this.elements.length == 0;
        };
        ContentExpr.prototype.start = function(attrs) {
            return new ContentMatch(this, attrs, 0, 0);
        };
        ContentExpr.prototype.atType = function(parentAttrs, type, attrs, marks) {
            var this$1 = this;
            if (marks === void 0)
                marks = Mark.none;
            for (var i = 0; i < this.elements.length; i++) {
                if (this$1.elements[i].matchesType(type, attrs, marks, parentAttrs, this$1)) {
                    return new ContentMatch(this$1, parentAttrs, i, 0);
                }
            }
        };
        ContentExpr.prototype.matches = function(attrs, fragment, from, to) {
            return this.start(attrs).matchToEnd(fragment, from, to);
        };
        ContentExpr.prototype.getMatchAt = function(attrs, fragment, index) {
            if (index === void 0)
                index = fragment.childCount;
            if (this.elements.length == 1) {
                return new ContentMatch(this, attrs, 0, index);
            } else {
                return this.start(attrs).matchFragment(fragment, 0, index);
            }
        };
        ContentExpr.prototype.checkReplace = function(attrs, content, from, to, replacement, start, end) {
            var this$1 = this;
            if (replacement === void 0)
                replacement = Fragment.empty;
            if (start === void 0)
                start = 0;
            if (end === void 0)
                end = replacement.childCount;
            if (this.elements.length == 1) {
                var elt = this.elements[0];
                if (!checkCount(elt, content.childCount - (to - from) + (end - start), attrs, this)) {
                    return false;
                }
                for (var i = start; i < end; i++) {
                    if (!elt.matches(replacement.child(i), attrs, this$1)) {
                        return false;
                    }
                }
                return true;
            }
            var match = this.getMatchAt(attrs, content, from).matchFragment(replacement, start, end);
            return match ? match.matchToEnd(content, to) : false;
        };
        ContentExpr.prototype.checkReplaceWith = function(attrs, content, from, to, type, typeAttrs, marks) {
            if (this.elements.length == 1) {
                var elt = this.elements[0];
                if (!checkCount(elt, content.childCount - (to - from) + 1, attrs, this)) {
                    return false;
                }
                return elt.matchesType(type, typeAttrs, marks, attrs, this);
            }
            var match = this.getMatchAt(attrs, content, from).matchType(type, typeAttrs, marks);
            return match ? match.matchToEnd(content, to) : false;
        };
        ContentExpr.prototype.compatible = function(other) {
            var this$1 = this;
            for (var i = 0; i < this.elements.length; i++) {
                var elt = this$1.elements[i];
                for (var j = 0; j < other.elements.length; j++) {
                    if (other.elements[j].compatible(elt)) {
                        return true;
                    }
                }
            }
            return false;
        };
        ContentExpr.prototype.generateContent = function(attrs) {
            return this.start(attrs).fillBefore(Fragment.empty, true);
        };
        ContentExpr.parse = function(nodeType, expr, specs) {
            var elements = [],
                pos = 0,
                inline = null;
            for (; ; ) {
                pos += /^\s*/.exec(expr.slice(pos))[0].length;
                if (pos == expr.length) {
                    break;
                }
                var types = /^(?:(\w+)|\(\s*(\w+(?:\s*\|\s*\w+)*)\s*\))/.exec(expr.slice(pos));
                if (!types) {
                    throw new SyntaxError("Invalid content expression '" + expr + "' at " + pos);
                }
                pos += types[0].length;
                var attrs = /^\[([^\]]+)\]/.exec(expr.slice(pos));
                if (attrs) {
                    pos += attrs[0].length;
                }
                var marks = /^<(?:(_)|\s*(\w+(?:\s+\w+)*)\s*)>/.exec(expr.slice(pos));
                if (marks) {
                    pos += marks[0].length;
                }
                var repeat = /^(?:([+*?])|\{\s*(\d+|\.\w+)\s*(,\s*(\d+|\.\w+)?)?\s*\})/.exec(expr.slice(pos));
                if (repeat) {
                    pos += repeat[0].length;
                }
                var nodeTypes = expandTypes(nodeType.schema, specs, types[1] ? [types[1]] : types[2].split(/\s*\|\s*/));
                for (var i = 0; i < nodeTypes.length; i++) {
                    if (inline == null) {
                        inline = nodeTypes[i].isInline;
                    } else if (inline != nodeTypes[i].isInline) {
                        throw new SyntaxError("Mixing inline and block content in a single node");
                    }
                }
                var attrSet = !attrs ? null : parseAttrs(nodeType, attrs[1]);
                var markSet = !marks ? false : marks[1] ? true : checkMarks(nodeType.schema, marks[2].split(/\s+/));
                var ref = parseRepeat(nodeType, repeat);
                var min = ref.min;
                var max = ref.max;
                if (min != 0 && (nodeTypes[0].hasRequiredAttrs(attrSet) || nodeTypes[0].isText)) {
                    throw new SyntaxError("Node type " + types[0] + " in type " + nodeType.name + " is required, but has non-optional attributes");
                }
                var newElt = new ContentElement(nodeTypes, attrSet, markSet, min, max);
                for (var i$1 = elements.length - 1; i$1 >= 0; i$1--) {
                    var prev = elements[i$1];
                    if (prev.min != prev.max && prev.overlaps(newElt)) {
                        throw new SyntaxError("Possibly ambiguous overlapping adjacent content expressions in '" + expr + "'");
                    }
                    if (prev.min != 0) {
                        break;
                    }
                }
                elements.push(newElt);
            }
            return new ContentExpr(nodeType, elements, !!inline);
        };
        Object.defineProperties(ContentExpr.prototype, prototypeAccessors);
        exports.ContentExpr = ContentExpr;
        var ContentElement = function(nodeTypes, attrs, marks, min, max) {
            this.nodeTypes = nodeTypes;
            this.attrs = attrs;
            this.marks = marks;
            this.min = min;
            this.max = max;
        };
        ContentElement.prototype.matchesType = function(type, attrs, marks, parentAttrs, parentExpr) {
            var this$1 = this;
            if (this.nodeTypes.indexOf(type) == -1) {
                return false;
            }
            if (this.attrs) {
                if (!attrs) {
                    return false;
                }
                for (var prop in this$1.attrs) {
                    if (attrs[prop] != resolveValue(this$1.attrs[prop], parentAttrs, parentExpr)) {
                        return false;
                    }
                }
            }
            if (this.marks === true) {
                return true;
            }
            if (this.marks === false) {
                return marks.length == 0;
            }
            for (var i = 0; i < marks.length; i++) {
                if (this$1.marks.indexOf(marks[i].type) == -1) {
                    return false;
                }
            }
            return true;
        };
        ContentElement.prototype.matches = function(node, parentAttrs, parentExpr) {
            return this.matchesType(node.type, node.attrs, node.marks, parentAttrs, parentExpr);
        };
        ContentElement.prototype.compatible = function(other) {
            var this$1 = this;
            for (var i = 0; i < this.nodeTypes.length; i++) {
                if (other.nodeTypes.indexOf(this$1.nodeTypes[i]) != -1) {
                    return true;
                }
            }
            return false;
        };
        ContentElement.prototype.constrainedAttrs = function(parentAttrs, expr) {
            var this$1 = this;
            if (!this.attrs) {
                return null;
            }
            var attrs = Object.create(null);
            for (var prop in this$1.attrs) {
                attrs[prop] = resolveValue(this$1.attrs[prop], parentAttrs, expr);
            }
            return attrs;
        };
        ContentElement.prototype.createFiller = function(parentAttrs, expr) {
            var type = this.nodeTypes[0],
                attrs = type.computeAttrs(this.constrainedAttrs(parentAttrs, expr));
            return type.create(attrs, type.contentExpr.generateContent(attrs));
        };
        ContentElement.prototype.defaultType = function() {
            var first = this.nodeTypes[0];
            if (!(first.hasRequiredAttrs() || first.isText)) {
                return first;
            }
        };
        ContentElement.prototype.overlaps = function(other) {
            return this.nodeTypes.some(function(t) {
                return other.nodeTypes.indexOf(t) > -1;
            });
        };
        ContentElement.prototype.allowsMark = function(markType) {
            return this.marks === true || this.marks && this.marks.indexOf(markType) > -1;
        };
        var ContentMatch = function(expr, attrs, index, count) {
            this.expr = expr;
            this.attrs = attrs;
            this.index = index;
            this.count = count;
        };
        var prototypeAccessors$1 = {
            element: {},
            nextElement: {}
        };
        prototypeAccessors$1.element.get = function() {
            return this.expr.elements[this.index];
        };
        prototypeAccessors$1.nextElement.get = function() {
            var this$1 = this;
            for (var i = this.index,
                     count = this.count; i < this.expr.elements.length; i++) {
                var element = this$1.expr.elements[i];
                if (this$1.resolveValue(element.max) > count) {
                    return element;
                }
                count = 0;
            }
        };
        ContentMatch.prototype.move = function(index, count) {
            return new ContentMatch(this.expr, this.attrs, index, count);
        };
        ContentMatch.prototype.resolveValue = function(value) {
            return value instanceof AttrValue ? resolveValue(value, this.attrs, this.expr) : value;
        };
        ContentMatch.prototype.matchNode = function(node) {
            return this.matchType(node.type, node.attrs, node.marks);
        };
        ContentMatch.prototype.matchType = function(type, attrs, marks) {
            var this$1 = this;
            if (marks === void 0)
                marks = Mark.none;
            for (var ref = this,
                     index = ref.index,
                     count = ref.count; index < this.expr.elements.length; index++, count = 0) {
                var elt = this$1.expr.elements[index],
                    max = this$1.resolveValue(elt.max);
                if (count < max && elt.matchesType(type, attrs, marks, this$1.attrs, this$1.expr)) {
                    count++;
                    return this$1.move(index, count);
                }
                if (count < this$1.resolveValue(elt.min)) {
                    return null;
                }
            }
        };
        ContentMatch.prototype.matchFragment = function(fragment, from, to) {
            var this$1 = this;
            if (from === void 0)
                from = 0;
            if (to === void 0)
                to = fragment.childCount;
            if (from == to) {
                return this;
            }
            var fragPos = from,
                end = this.expr.elements.length;
            for (var ref = this,
                     index = ref.index,
                     count = ref.count; index < end; index++, count = 0) {
                var elt = this$1.expr.elements[index],
                    max = this$1.resolveValue(elt.max);
                while (count < max && fragPos < to) {
                    if (elt.matches(fragment.child(fragPos), this$1.attrs, this$1.expr)) {
                        count++;
                        if (++fragPos == to) {
                            return this$1.move(index, count);
                        }
                    } else {
                        break;
                    }
                }
                if (count < this$1.resolveValue(elt.min)) {
                    return null;
                }
            }
            return false;
        };
        ContentMatch.prototype.matchToEnd = function(fragment, start, end) {
            var matched = this.matchFragment(fragment, start, end);
            return matched && matched.validEnd() || false;
        };
        ContentMatch.prototype.validEnd = function() {
            var this$1 = this;
            for (var i = this.index,
                     count = this.count; i < this.expr.elements.length; i++, count = 0) {
                if (count < this$1.resolveValue(this$1.expr.elements[i].min)) {
                    return false;
                }
            }
            return true;
        };
        ContentMatch.prototype.fillBefore = function(after, toEnd, startIndex) {
            var this$1 = this;
            var added = [],
                match = this,
                index = startIndex || 0,
                end = this.expr.elements.length;
            for (; ; ) {
                var fits = match.matchFragment(after, index);
                if (fits && (!toEnd || fits.validEnd())) {
                    return Fragment.from(added);
                }
                if (fits === false) {
                    return null;
                }
                var elt = match.element;
                if (match.count < this$1.resolveValue(elt.min)) {
                    added.push(elt.createFiller(this$1.attrs, this$1.expr));
                    match = match.move(match.index, match.count + 1);
                } else if (match.index < end) {
                    match = match.move(match.index + 1, 0);
                } else if (after.childCount > index) {
                    return null;
                } else {
                    return Fragment.from(added);
                }
            }
        };
        ContentMatch.prototype.possibleContent = function() {
            var this$1 = this;
            var found = [];
            for (var i = this.index,
                     count = this.count; i < this.expr.elements.length; i++, count = 0) {
                var elt = this$1.expr.elements[i],
                    attrs = elt.constrainedAttrs(this$1.attrs, this$1.expr);
                if (count < this$1.resolveValue(elt.max)) {
                    for (var j = 0; j < elt.nodeTypes.length; j++) {
                        var type = elt.nodeTypes[j];
                        if (!type.hasRequiredAttrs(attrs) && !type.isText) {
                            found.push({
                                type: type,
                                attrs: attrs
                            });
                        }
                    }
                }
                if (this$1.resolveValue(elt.min) > count) {
                    break;
                }
            }
            return found;
        };
        ContentMatch.prototype.allowsMark = function(markType) {
            return this.element.allowsMark(markType);
        };
        ContentMatch.prototype.findWrapping = function(target, targetAttrs, targetMarks) {
            var seen = Object.create(null),
                first = {
                    match: this,
                    via: null
                },
                active = [first];
            while (active.length) {
                var current = active.shift(),
                    match = current.match;
                if (match.matchType(target, targetAttrs, targetMarks)) {
                    var result = [];
                    for (var obj = current; obj != first; obj = obj.via) {
                        result.push({
                            type: obj.match.expr.nodeType,
                            attrs: obj.match.attrs
                        });
                    }
                    return result.reverse();
                }
                var possible = match.possibleContent();
                for (var i = 0; i < possible.length; i++) {
                    var ref = possible[i];
                    var type = ref.type;
                    var attrs = ref.attrs;
                    var fullAttrs = type.computeAttrs(attrs);
                    if (!type.isLeaf && !(type.name in seen) && (current == first || match.matchType(type, fullAttrs).validEnd())) {
                        active.push({
                            match: type.contentExpr.start(fullAttrs),
                            via: current
                        });
                        seen[type.name] = true;
                    }
                }
            }
        };
        ContentMatch.prototype.findWrappingFor = function(node) {
            return this.findWrapping(node.type, node.attrs, node.marks);
        };
        Object.defineProperties(ContentMatch.prototype, prototypeAccessors$1);
        exports.ContentMatch = ContentMatch;
        var AttrValue = function(attr) {
            this.attr = attr;
        };
        function parseValue(nodeType, value) {
            if (value.charAt(0) == ".") {
                var attr = value.slice(1);
                if (!nodeType.attrs[attr]) {
                    throw new SyntaxError("Node type " + nodeType.name + " has no attribute " + attr);
                }
                return new AttrValue(attr);
            } else {
                return JSON.parse(value);
            }
        }
        function checkMarks(schema, marks) {
            var found = [];
            for (var i = 0; i < marks.length; i++) {
                var mark = schema.marks[marks[i]];
                if (mark) {
                    found.push(mark);
                } else {
                    throw new SyntaxError("Unknown mark type: '" + marks[i] + "'");
                }
            }
            return found;
        }
        function resolveValue(value, attrs, expr) {
            if (!(value instanceof AttrValue)) {
                return value;
            }
            var attrVal = attrs && attrs[value.attr];
            return attrVal !== undefined ? attrVal : expr.nodeType.defaultAttrs[value.attr];
        }
        function checkCount(elt, count, attrs, expr) {
            return count >= resolveValue(elt.min, attrs, expr) && count <= resolveValue(elt.max, attrs, expr);
        }
        function expandTypes(schema, specs, types) {
            var result = [];
            types.forEach(function(type) {
                var found = schema.nodes[type];
                if (found) {
                    if (result.indexOf(found) == -1) {
                        result.push(found);
                    }
                } else {
                    specs.forEach(function(name, spec) {
                        if (spec.group && spec.group.split(" ").indexOf(type) > -1) {
                            found = schema.nodes[name];
                            if (result.indexOf(found) == -1) {
                                result.push(found);
                            }
                        }
                    });
                }
                if (!found) {
                    throw new SyntaxError("Node type or group '" + type + "' does not exist");
                }
            });
            return result;
        }
        var many = 2e9;
        function parseRepeat(nodeType, match) {
            var min = 1,
                max = 1;
            if (match) {
                if (match[1] == "+") {
                    max = many;
                } else if (match[1] == "*") {
                    min = 0;
                    max = many;
                } else if (match[1] == "?") {
                    min = 0;
                } else if (match[2]) {
                    min = parseValue(nodeType, match[2]);
                    if (match[3]) {
                        max = match[4] ? parseValue(nodeType, match[4]) : many;
                    } else {
                        max = min;
                    }
                }
                if (max == 0 || min > max) {
                    throw new SyntaxError("Invalid repeat count in '" + match[0] + "'");
                }
            }
            return {
                min: min,
                max: max
            };
        }
        function parseAttrs(nodeType, expr) {
            var parts = expr.split(/\s*,\s*/);
            var attrs = Object.create(null);
            for (var i = 0; i < parts.length; i++) {
                var match = /^(\w+)=(\w+|\"(?:\\.|[^\\])*\"|\.\w+)$/.exec(parts[i]);
                if (!match) {
                    throw new SyntaxError("Invalid attribute syntax: " + parts[i]);
                }
                attrs[match[1]] = parseValue(nodeType, match[2]);
            }
            return attrs;
        }
        return module.exports;
    });

    $__System.registerDynamic("4b", [], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        function findDiffStart(a, b, pos) {
            for (var i = 0; ; i++) {
                if (i == a.childCount || i == b.childCount) {
                    return a.childCount == b.childCount ? null : pos;
                }
                var childA = a.child(i),
                    childB = b.child(i);
                if (childA == childB) {
                    pos += childA.nodeSize;
                    continue;
                }
                if (!childA.sameMarkup(childB)) {
                    return pos;
                }
                if (childA.isText && childA.text != childB.text) {
                    for (var j = 0; childA.text[j] == childB.text[j]; j++) {
                        pos++;
                    }
                    return pos;
                }
                if (childA.content.size || childB.content.size) {
                    var inner = findDiffStart(childA.content, childB.content, pos + 1);
                    if (inner != null) {
                        return inner;
                    }
                }
                pos += childA.nodeSize;
            }
        }
        exports.findDiffStart = findDiffStart;
        function findDiffEnd(a, b, posA, posB) {
            for (var iA = a.childCount,
                     iB = b.childCount; ; ) {
                if (iA == 0 || iB == 0) {
                    return iA == iB ? null : {
                        a: posA,
                        b: posB
                    };
                }
                var childA = a.child(--iA),
                    childB = b.child(--iB),
                    size = childA.nodeSize;
                if (childA == childB) {
                    posA -= size;
                    posB -= size;
                    continue;
                }
                if (!childA.sameMarkup(childB)) {
                    return {
                        a: posA,
                        b: posB
                    };
                }
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
                    if (inner) {
                        return inner;
                    }
                }
                posA -= size;
                posB -= size;
            }
        }
        exports.findDiffEnd = findDiffEnd;
        return module.exports;
    });

    $__System.registerDynamic("46", ["4b"], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        var ref = $__require('4b');
        var findDiffStart = ref.findDiffStart;
        var findDiffEnd = ref.findDiffEnd;
        var Fragment = function(content, size) {
            var this$1 = this;
            this.content = content;
            this.size = size || 0;
            if (size == null) {
                for (var i = 0; i < content.length; i++) {
                    this$1.size += content[i].nodeSize;
                }
            }
        };
        var prototypeAccessors = {
            firstChild: {},
            lastChild: {},
            childCount: {}
        };
        Fragment.prototype.nodesBetween = function(from, to, f, nodeStart, parent) {
            var this$1 = this;
            for (var i = 0,
                     pos = 0; pos < to; i++) {
                var child = this$1.content[i],
                    end = pos + child.nodeSize;
                if (end > from && f(child, nodeStart + pos, parent, i) !== false && child.content.size) {
                    var start = pos + 1;
                    child.nodesBetween(Math.max(0, from - start), Math.min(child.content.size, to - start), f, nodeStart + start);
                }
                pos = end;
            }
        };
        Fragment.prototype.textBetween = function(from, to, blockSeparator, leafText) {
            var text = "",
                separated = true;
            this.nodesBetween(from, to, function(node, pos) {
                if (node.isText) {
                    text += node.text.slice(Math.max(from, pos) - pos, to - pos);
                    separated = !blockSeparator;
                } else if (node.isLeaf && leafText) {
                    text += leafText;
                    separated = !blockSeparator;
                } else if (!separated && node.isBlock) {
                    text += blockSeparator;
                    separated = true;
                }
            }, 0);
            return text;
        };
        Fragment.prototype.append = function(other) {
            if (!other.size) {
                return this;
            }
            if (!this.size) {
                return other;
            }
            var last = this.lastChild,
                first = other.firstChild,
                content = this.content.slice(),
                i = 0;
            if (last.isText && last.sameMarkup(first)) {
                content[content.length - 1] = last.withText(last.text + first.text);
                i = 1;
            }
            for (; i < other.content.length; i++) {
                content.push(other.content[i]);
            }
            return new Fragment(content, this.size + other.size);
        };
        Fragment.prototype.cut = function(from, to) {
            var this$1 = this;
            if (to == null) {
                to = this.size;
            }
            if (from == 0 && to == this.size) {
                return this;
            }
            var result = [],
                size = 0;
            if (to > from) {
                for (var i = 0,
                         pos = 0; pos < to; i++) {
                    var child = this$1.content[i],
                        end = pos + child.nodeSize;
                    if (end > from) {
                        if (pos < from || end > to) {
                            if (child.isText) {
                                child = child.cut(Math.max(0, from - pos), Math.min(child.text.length, to - pos));
                            } else {
                                child = child.cut(Math.max(0, from - pos - 1), Math.min(child.content.size, to - pos - 1));
                            }
                        }
                        result.push(child);
                        size += child.nodeSize;
                    }
                    pos = end;
                }
            }
            return new Fragment(result, size);
        };
        Fragment.prototype.cutByIndex = function(from, to) {
            if (from == to) {
                return Fragment.empty;
            }
            if (from == 0 && to == this.content.length) {
                return this;
            }
            return new Fragment(this.content.slice(from, to));
        };
        Fragment.prototype.replaceChild = function(index, node) {
            var current = this.content[index];
            if (current == node) {
                return this;
            }
            var copy = this.content.slice();
            var size = this.size + node.nodeSize - current.nodeSize;
            copy[index] = node;
            return new Fragment(copy, size);
        };
        Fragment.prototype.addToStart = function(node) {
            return new Fragment([node].concat(this.content), this.size + node.nodeSize);
        };
        Fragment.prototype.addToEnd = function(node) {
            return new Fragment(this.content.concat(node), this.size + node.nodeSize);
        };
        Fragment.prototype.eq = function(other) {
            var this$1 = this;
            if (this.content.length != other.content.length) {
                return false;
            }
            for (var i = 0; i < this.content.length; i++) {
                if (!this$1.content[i].eq(other.content[i])) {
                    return false;
                }
            }
            return true;
        };
        prototypeAccessors.firstChild.get = function() {
            return this.content.length ? this.content[0] : null;
        };
        prototypeAccessors.lastChild.get = function() {
            return this.content.length ? this.content[this.content.length - 1] : null;
        };
        prototypeAccessors.childCount.get = function() {
            return this.content.length;
        };
        Fragment.prototype.child = function(index) {
            var found = this.content[index];
            if (!found) {
                throw new RangeError("Index " + index + " out of range for " + this);
            }
            return found;
        };
        Fragment.prototype.offsetAt = function(index) {
            var this$1 = this;
            var offset = 0;
            for (var i = 0; i < index; i++) {
                offset += this$1.content[i].nodeSize;
            }
            return offset;
        };
        Fragment.prototype.maybeChild = function(index) {
            return this.content[index];
        };
        Fragment.prototype.forEach = function(f) {
            var this$1 = this;
            for (var i = 0,
                     p = 0; i < this.content.length; i++) {
                var child = this$1.content[i];
                f(child, p, i);
                p += child.nodeSize;
            }
        };
        Fragment.prototype.findDiffStart = function(other, pos) {
            if (pos === void 0)
                pos = 0;
            return findDiffStart(this, other, pos);
        };
        Fragment.prototype.findDiffEnd = function(other, pos, otherPos) {
            if (pos === void 0)
                pos = this.size;
            if (otherPos === void 0)
                otherPos = other.size;
            return findDiffEnd(this, other, pos, otherPos);
        };
        Fragment.prototype.findIndex = function(pos, round) {
            var this$1 = this;
            if (round === void 0)
                round = -1;
            if (pos == 0) {
                return retIndex(0, pos);
            }
            if (pos == this.size) {
                return retIndex(this.content.length, pos);
            }
            if (pos > this.size || pos < 0) {
                throw new RangeError(("Position " + pos + " outside of fragment (" + (this) + ")"));
            }
            for (var i = 0,
                     curPos = 0; ; i++) {
                var cur = this$1.child(i),
                    end = curPos + cur.nodeSize;
                if (end >= pos) {
                    if (end == pos || round > 0) {
                        return retIndex(i + 1, end);
                    }
                    return retIndex(i, curPos);
                }
                curPos = end;
            }
        };
        Fragment.prototype.toString = function() {
            return "<" + this.toStringInner() + ">";
        };
        Fragment.prototype.toStringInner = function() {
            return this.content.join(", ");
        };
        Fragment.prototype.toJSON = function() {
            return this.content.length ? this.content.map(function(n) {
                return n.toJSON();
            }) : null;
        };
        Fragment.fromJSON = function(schema, value) {
            return value ? new Fragment(value.map(schema.nodeFromJSON)) : Fragment.empty;
        };
        Fragment.fromArray = function(array) {
            if (!array.length) {
                return Fragment.empty;
            }
            var joined,
                size = 0;
            for (var i = 0; i < array.length; i++) {
                var node = array[i];
                size += node.nodeSize;
                if (i && node.isText && array[i - 1].sameMarkup(node)) {
                    if (!joined) {
                        joined = array.slice(0, i);
                    }
                    joined[joined.length - 1] = node.withText(joined[joined.length - 1].text + node.text);
                } else if (joined) {
                    joined.push(node);
                }
            }
            return new Fragment(joined || array, size);
        };
        Fragment.from = function(nodes) {
            if (!nodes) {
                return Fragment.empty;
            }
            if (nodes instanceof Fragment) {
                return nodes;
            }
            if (Array.isArray(nodes)) {
                return this.fromArray(nodes);
            }
            return new Fragment([nodes], nodes.nodeSize);
        };
        Object.defineProperties(Fragment.prototype, prototypeAccessors);
        exports.Fragment = Fragment;
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

    $__System.registerDynamic("47", ["46"], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        var ref = $__require('46');
        var Fragment = ref.Fragment;
        var ReplaceError = (function(Error) {
            function ReplaceError(message) {
                Error.call(this, message);
                this.message = message;
            }
            if (Error)
                ReplaceError.__proto__ = Error;
            ReplaceError.prototype = Object.create(Error && Error.prototype);
            ReplaceError.prototype.constructor = ReplaceError;
            return ReplaceError;
        }(Error));
        exports.ReplaceError = ReplaceError;
        var Slice = function(content, openLeft, openRight) {
            this.content = content;
            this.openLeft = openLeft;
            this.openRight = openRight;
        };
        var prototypeAccessors = {size: {}};
        prototypeAccessors.size.get = function() {
            return this.content.size - this.openLeft - this.openRight;
        };
        Slice.prototype.insertAt = function(pos, fragment) {
            var content = insertInto(this.content, pos + this.openLeft, fragment, null);
            return content && new Slice(content, this.openLeft, this.openRight);
        };
        Slice.prototype.removeBetween = function(from, to) {
            return new Slice(removeRange(this.content, from + this.openLeft, to + this.openLeft), this.openLeft, this.openRight);
        };
        Slice.prototype.eq = function(other) {
            return this.content.eq(other.content) && this.openLeft == other.openLeft && this.openRight == other.openRight;
        };
        Slice.prototype.toString = function() {
            return this.content + "(" + this.openLeft + "," + this.openRight + ")";
        };
        Slice.prototype.toJSON = function() {
            if (!this.content.size) {
                return null;
            }
            return {
                content: this.content.toJSON(),
                openLeft: this.openLeft,
                openRight: this.openRight
            };
        };
        Slice.fromJSON = function(schema, json) {
            if (!json) {
                return Slice.empty;
            }
            return new Slice(Fragment.fromJSON(schema, json.content), json.openLeft, json.openRight);
        };
        Slice.maxOpen = function(fragment) {
            var openLeft = 0,
                openRight = 0;
            for (var n = fragment.firstChild; n && !n.isLeaf; n = n.firstChild) {
                openLeft++;
            }
            for (var n$1 = fragment.lastChild; n$1 && !n$1.isLeaf; n$1 = n$1.lastChild) {
                openRight++;
            }
            return new Slice(fragment, openLeft, openRight);
        };
        Object.defineProperties(Slice.prototype, prototypeAccessors);
        exports.Slice = Slice;
        function removeRange(content, from, to) {
            var ref = content.findIndex(from);
            var index = ref.index;
            var offset = ref.offset;
            var child = content.maybeChild(index);
            var ref$1 = content.findIndex(to);
            var indexTo = ref$1.index;
            var offsetTo = ref$1.offset;
            if (offset == from || child.isText) {
                if (offsetTo != to && !content.child(indexTo).isText) {
                    throw new RangeError("Removing non-flat range");
                }
                return content.cut(0, from).append(content.cut(to));
            }
            if (index != indexTo) {
                throw new RangeError("Removing non-flat range");
            }
            return content.replaceChild(index, child.copy(removeRange(child.content, from - offset - 1, to - offset - 1)));
        }
        function insertInto(content, dist, insert, parent) {
            var ref = content.findIndex(dist);
            var index = ref.index;
            var offset = ref.offset;
            var child = content.maybeChild(index);
            if (offset == dist || child.isText) {
                if (parent && !parent.canReplace(index, index, insert)) {
                    return null;
                }
                return content.cut(0, dist).append(insert).append(content.cut(dist));
            }
            var inner = insertInto(child.content, dist - offset - 1, insert);
            return inner && content.replaceChild(index, child.copy(inner));
        }
        Slice.empty = new Slice(Fragment.empty, 0, 0);
        function replace($from, $to, slice) {
            if (slice.openLeft > $from.depth) {
                throw new ReplaceError("Inserted content deeper than insertion position");
            }
            if ($from.depth - slice.openLeft != $to.depth - slice.openRight) {
                throw new ReplaceError("Inconsistent open depths");
            }
            return replaceOuter($from, $to, slice, 0);
        }
        exports.replace = replace;
        function replaceOuter($from, $to, slice, depth) {
            var index = $from.index(depth),
                node = $from.node(depth);
            if (index == $to.index(depth) && depth < $from.depth - slice.openLeft) {
                var inner = replaceOuter($from, $to, slice, depth + 1);
                return node.copy(node.content.replaceChild(index, inner));
            } else if (!slice.content.size) {
                return close(node, replaceTwoWay($from, $to, depth));
            } else if (!slice.openLeft && !slice.openRight && $from.depth == depth && $to.depth == depth) {
                var parent = $from.parent,
                    content = parent.content;
                return close(parent, content.cut(0, $from.parentOffset).append(slice.content).append(content.cut($to.parentOffset)));
            } else {
                var ref = prepareSliceForReplace(slice, $from);
                var start = ref.start;
                var end = ref.end;
                return close(node, replaceThreeWay($from, start, end, $to, depth));
            }
        }
        function checkJoin(main, sub) {
            if (!sub.type.compatibleContent(main.type)) {
                throw new ReplaceError("Cannot join " + sub.type.name + " onto " + main.type.name);
            }
        }
        function joinable($before, $after, depth) {
            var node = $before.node(depth);
            checkJoin(node, $after.node(depth));
            return node;
        }
        function addNode(child, target) {
            var last = target.length - 1;
            if (last >= 0 && child.isText && child.sameMarkup(target[last])) {
                target[last] = child.withText(target[last].text + child.text);
            } else {
                target.push(child);
            }
        }
        function addRange($start, $end, depth, target) {
            var node = ($end || $start).node(depth);
            var startIndex = 0,
                endIndex = $end ? $end.index(depth) : node.childCount;
            if ($start) {
                startIndex = $start.index(depth);
                if ($start.depth > depth) {
                    startIndex++;
                } else if ($start.textOffset) {
                    addNode($start.nodeAfter, target);
                    startIndex++;
                }
            }
            for (var i = startIndex; i < endIndex; i++) {
                addNode(node.child(i), target);
            }
            if ($end && $end.depth == depth && $end.textOffset) {
                addNode($end.nodeBefore, target);
            }
        }
        function close(node, content) {
            if (!node.type.validContent(content, node.attrs)) {
                throw new ReplaceError("Invalid content for node " + node.type.name);
            }
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
                if (openLeft) {
                    addNode(close(openLeft, replaceTwoWay($from, $start, depth + 1)), content);
                }
                addRange($start, $end, depth, content);
                if (openRight) {
                    addNode(close(openRight, replaceTwoWay($end, $to, depth + 1)), content);
                }
            }
            addRange($to, null, depth, content);
            return new Fragment(content);
        }
        function replaceTwoWay($from, $to, depth) {
            var content = [];
            addRange(null, $from, depth, content);
            if ($from.depth > depth) {
                var type = joinable($from, $to, depth + 1);
                addNode(close(type, replaceTwoWay($from, $to, depth + 1)), content);
            }
            addRange($to, null, depth, content);
            return new Fragment(content);
        }
        function prepareSliceForReplace(slice, $along) {
            var extra = $along.depth - slice.openLeft,
                parent = $along.node(extra);
            var node = parent.copy(slice.content);
            for (var i = extra - 1; i >= 0; i--) {
                node = $along.node(i).copy(Fragment.from(node));
            }
            return {
                start: node.resolveNoCache(slice.openLeft + extra),
                end: node.resolveNoCache(node.content.size - slice.openRight - extra)
            };
        }
        return module.exports;
    });

    $__System.registerDynamic("48", [], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        function compareDeep(a, b) {
            if (a === b) {
                return true;
            }
            if (!(a && typeof a == "object") || !(b && typeof b == "object")) {
                return false;
            }
            var array = Array.isArray(a);
            if (Array.isArray(b) != array) {
                return false;
            }
            if (array) {
                if (a.length != b.length) {
                    return false;
                }
                for (var i = 0; i < a.length; i++) {
                    if (!compareDeep(a[i], b[i])) {
                        return false;
                    }
                }
            } else {
                for (var p in a) {
                    if (!(p in b) || !compareDeep(a[p], b[p])) {
                        return false;
                    }
                }
                for (var p$1 in b) {
                    if (!(p$1 in a)) {
                        return false;
                    }
                }
            }
            return true;
        }
        exports.compareDeep = compareDeep;
        return module.exports;
    });

    $__System.registerDynamic("44", ["48"], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        var ref = $__require('48');
        var compareDeep = ref.compareDeep;
        var Mark = function(type, attrs) {
            this.type = type;
            this.attrs = attrs;
        };
        Mark.prototype.addToSet = function(set) {
            var this$1 = this;
            for (var i = 0; i < set.length; i++) {
                var other = set[i];
                if (other.type == this$1.type) {
                    if (this$1.eq(other)) {
                        return set;
                    }
                    var copy = set.slice();
                    copy[i] = this$1;
                    return copy;
                }
                if (other.type.rank > this$1.type.rank) {
                    return set.slice(0, i).concat(this$1).concat(set.slice(i));
                }
            }
            return set.concat(this);
        };
        Mark.prototype.removeFromSet = function(set) {
            var this$1 = this;
            for (var i = 0; i < set.length; i++) {
                if (this$1.eq(set[i])) {
                    return set.slice(0, i).concat(set.slice(i + 1));
                }
            }
            return set;
        };
        Mark.prototype.isInSet = function(set) {
            var this$1 = this;
            for (var i = 0; i < set.length; i++) {
                if (this$1.eq(set[i])) {
                    return true;
                }
            }
            return false;
        };
        Mark.prototype.eq = function(other) {
            if (this == other) {
                return true;
            }
            if (this.type != other.type) {
                return false;
            }
            if (!compareDeep(other.attrs, this.attrs)) {
                return false;
            }
            return true;
        };
        Mark.prototype.toJSON = function() {
            var this$1 = this;
            var obj = {type: this.type.name};
            for (var _ in this$1.attrs) {
                obj.attrs = this$1.attrs;
                break;
            }
            return obj;
        };
        Mark.fromJSON = function(schema, json) {
            return schema.marks[json.type].create(json.attrs);
        };
        Mark.sameSet = function(a, b) {
            if (a == b) {
                return true;
            }
            if (a.length != b.length) {
                return false;
            }
            for (var i = 0; i < a.length; i++) {
                if (!a[i].eq(b[i])) {
                    return false;
                }
            }
            return true;
        };
        Mark.setFrom = function(marks) {
            if (!marks || marks.length == 0) {
                return Mark.none;
            }
            if (marks instanceof Mark) {
                return [marks];
            }
            var copy = marks.slice();
            copy.sort(function(a, b) {
                return a.type.rank - b.type.rank;
            });
            return copy;
        };
        exports.Mark = Mark;
        Mark.none = [];
        return module.exports;
    });

    $__System.registerDynamic("4c", ["46", "47", "44"], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        var ref = $__require('46');
        var Fragment = ref.Fragment;
        var ref$1 = $__require('47');
        var Slice = ref$1.Slice;
        var ref$2 = $__require('44');
        var Mark = ref$2.Mark;
        var DOMParser = function(schema, rules) {
            var this$1 = this;
            this.schema = schema;
            this.rules = rules;
            this.tags = [];
            this.styles = [];
            rules.forEach(function(rule) {
                if (rule.tag) {
                    this$1.tags.push(rule);
                } else if (rule.style) {
                    this$1.styles.push(rule);
                }
            });
        };
        DOMParser.prototype.parse = function(dom, options) {
            if (options === void 0)
                options = {};
            var context = new ParseContext(this, options, false);
            context.addAll(dom, null, options.from, options.to);
            return context.finish();
        };
        DOMParser.prototype.parseSlice = function(dom, options) {
            if (options === void 0)
                options = {};
            var context = new ParseContext(this, options, true);
            context.addAll(dom, null, options.from, options.to);
            return Slice.maxOpen(context.finish());
        };
        DOMParser.prototype.matchTag = function(dom) {
            var this$1 = this;
            for (var i = 0; i < this.tags.length; i++) {
                var rule = this$1.tags[i];
                if (matches(dom, rule.tag)) {
                    if (rule.getAttrs) {
                        var result = rule.getAttrs(dom);
                        if (result === false) {
                            continue;
                        }
                        rule.attrs = result;
                    }
                    return rule;
                }
            }
        };
        DOMParser.prototype.matchStyle = function(prop, value) {
            var this$1 = this;
            for (var i = 0; i < this.styles.length; i++) {
                var rule = this$1.styles[i];
                if (rule.style == prop) {
                    if (rule.getAttrs) {
                        var result = rule.getAttrs(value);
                        if (result === false) {
                            continue;
                        }
                        rule.attrs = result;
                    }
                    return rule;
                }
            }
        };
        DOMParser.schemaRules = function(schema) {
            var result = [];
            function insert(rule) {
                var priority = rule.priority == null ? 50 : rule.priority,
                    i = 0;
                for (; i < result.length; i++) {
                    var next = result[i],
                        nextPriority = next.priority == null ? 50 : next.priority;
                    if (nextPriority < priority) {
                        break;
                    }
                }
                result.splice(i, 0, rule);
            }
            var loop = function(name) {
                var rules = schema.marks[name].spec.parseDOM;
                if (rules) {
                    rules.forEach(function(rule) {
                        insert(rule = copy(rule));
                        rule.mark = name;
                    });
                }
            };
            for (var name in schema.marks)
                loop(name);
            var loop$1 = function(name) {
                var rules$1 = schema.nodes[name$1].spec.parseDOM;
                if (rules$1) {
                    rules$1.forEach(function(rule) {
                        insert(rule = copy(rule));
                        rule.node = name$1;
                    });
                }
            };
            for (var name$1 in schema.nodes)
                loop$1(name);
            return result;
        };
        DOMParser.fromSchema = function(schema) {
            return schema.cached.domParser || (schema.cached.domParser = new DOMParser(schema, DOMParser.schemaRules(schema)));
        };
        exports.DOMParser = DOMParser;
        var blockTags = {
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
        var ignoreTags = {
            head: true,
            noscript: true,
            object: true,
            script: true,
            style: true,
            title: true
        };
        var listTags = {
            ol: true,
            ul: true
        };
        var OPT_PRESERVE_WS = 1,
            OPT_OPEN_LEFT = 2;
        var NodeContext = function(type, attrs, solid, match, options) {
            this.type = type;
            this.attrs = attrs;
            this.solid = solid;
            this.match = match || (options & OPT_OPEN_LEFT ? null : type.contentExpr.start(attrs));
            this.options = options;
            this.content = [];
        };
        NodeContext.prototype.findWrapping = function(type, attrs) {
            if (!this.match) {
                if (!this.type) {
                    return [];
                }
                var found = this.type.contentExpr.atType(this.attrs, type, attrs);
                if (!found) {
                    var start = this.type.contentExpr.start(this.attrs),
                        wrap;
                    if (wrap = start.findWrapping(type, attrs)) {
                        this.match = start;
                        return wrap;
                    }
                }
                if (found) {
                    this.match = found;
                } else {
                    return null;
                }
            }
            return this.match.findWrapping(type, attrs);
        };
        NodeContext.prototype.finish = function(openRight) {
            if (!(this.options & OPT_PRESERVE_WS)) {
                var last = this.content[this.content.length - 1],
                    m;
                if (last && last.isText && (m = /\s+$/.exec(last.text))) {
                    if (last.text.length == m[0].length) {
                        this.content.pop();
                    } else {
                        this.content[this.content.length - 1] = last.withText(last.text.slice(0, last.text.length - m[0].length));
                    }
                }
            }
            var content = Fragment.from(this.content);
            if (!openRight && this.match) {
                content = content.append(this.match.fillBefore(Fragment.empty, true));
            }
            return this.type ? this.type.create(this.attrs, content) : content;
        };
        var ParseContext = function(parser, options, open) {
            this.parser = parser;
            this.options = options;
            this.isOpen = open;
            var topNode = options.topNode,
                topContext;
            var topOptions = (options.preserveWhitespace ? OPT_PRESERVE_WS : 0) | (open ? OPT_OPEN_LEFT : 0);
            if (topNode) {
                topContext = new NodeContext(topNode.type, topNode.attrs, true, topNode.contentMatchAt(options.topStart || 0), topOptions);
            } else if (open) {
                topContext = new NodeContext(null, null, true, null, topOptions);
            } else {
                topContext = new NodeContext(parser.schema.nodes.doc, null, true, null, topOptions);
            }
            this.nodes = [topContext];
            this.marks = Mark.none;
            this.open = 0;
            this.find = options.findPositions;
        };
        var prototypeAccessors = {
            top: {},
            currentPos: {}
        };
        prototypeAccessors.top.get = function() {
            return this.nodes[this.open];
        };
        ParseContext.prototype.addMark = function(mark) {
            var old = this.marks;
            this.marks = mark.addToSet(this.marks);
            return old;
        };
        ParseContext.prototype.addDOM = function(dom) {
            if (dom.nodeType == 3) {
                this.addTextNode(dom);
            } else if (dom.nodeType == 1) {
                var style = dom.getAttribute("style");
                if (style) {
                    this.addElementWithStyles(parseStyles(style), dom);
                } else {
                    this.addElement(dom);
                }
            }
        };
        ParseContext.prototype.addTextNode = function(dom) {
            var value = dom.nodeValue;
            var top = this.top;
            if ((top.type && top.type.isTextblock) || /\S/.test(value)) {
                if (!(top.options & OPT_PRESERVE_WS)) {
                    value = value.replace(/\s+/g, " ");
                    if (/^\s/.test(value)) {
                        var nodeBefore = top.content[top.content.length - 1];
                        if (!nodeBefore || nodeBefore.isText && /\s$/.test(nodeBefore.text)) {
                            value = value.slice(1);
                        }
                    }
                }
                if (value) {
                    this.insertNode(this.parser.schema.text(value, this.marks));
                }
                this.findInText(dom);
            } else {
                this.findInside(dom);
            }
        };
        ParseContext.prototype.addElement = function(dom) {
            var name = dom.nodeName.toLowerCase();
            if (listTags.hasOwnProperty(name)) {
                normalizeList(dom);
            }
            var rule = (this.options.ruleFromNode && this.options.ruleFromNode(dom)) || this.parser.matchTag(dom);
            if (rule ? rule.ignore : ignoreTags.hasOwnProperty(name)) {
                this.findInside(dom);
            } else if (!rule || rule.skip) {
                if (rule && rule.skip.nodeType) {
                    dom = rule.skip;
                }
                var sync = blockTags.hasOwnProperty(name) && this.top;
                this.addAll(dom);
                if (sync) {
                    this.sync(sync);
                }
            } else {
                this.addElementByRule(dom, rule);
            }
        };
        ParseContext.prototype.addElementWithStyles = function(styles, dom) {
            var this$1 = this;
            var oldMarks = this.marks,
                ignore = false;
            for (var i = 0; i < styles.length; i += 2) {
                var rule = this$1.parser.matchStyle(styles[i], styles[i + 1]);
                if (!rule) {
                    continue;
                }
                if (rule.ignore) {
                    ignore = true;
                    break;
                }
                this$1.addMark(this$1.parser.schema.marks[rule.mark].create(rule.attrs));
            }
            if (!ignore) {
                this.addElement(dom);
            }
            this.marks = oldMarks;
        };
        ParseContext.prototype.addElementByRule = function(dom, rule) {
            var this$1 = this;
            var sync,
                before,
                nodeType,
                markType,
                mark;
            if (rule.node) {
                nodeType = this.parser.schema.nodes[rule.node];
                if (nodeType.isLeaf) {
                    this.insertNode(nodeType.create(rule.attrs, null, this.marks));
                } else {
                    sync = this.enter(nodeType, rule.attrs, rule.preserveWhitespace) && this.top;
                }
            } else {
                markType = this.parser.schema.marks[rule.mark];
                before = this.addMark(mark = markType.create(rule.attrs));
            }
            if (nodeType && nodeType.isLeaf) {
                this.findInside(dom);
            } else if (rule.getContent) {
                this.findInside(dom);
                rule.getContent(dom).forEach(function(node) {
                    return this$1.insertNode(mark ? node.mark(mark.addToSet(node.marks)) : node);
                });
            } else {
                var contentDOM = rule.contentElement;
                if (typeof contentDOM == "string") {
                    contentDOM = dom.querySelector(contentDOM);
                }
                if (!contentDOM) {
                    contentDOM = dom;
                }
                this.findAround(dom, contentDOM, true);
                this.addAll(contentDOM, sync);
                if (sync) {
                    this.sync(sync);
                    this.open--;
                } else if (before) {
                    this.marks = before;
                }
                this.findAround(dom, contentDOM, true);
            }
            return true;
        };
        ParseContext.prototype.addAll = function(parent, sync, startIndex, endIndex) {
            var this$1 = this;
            var index = startIndex || 0;
            for (var dom = startIndex ? parent.childNodes[startIndex] : parent.firstChild,
                     end = endIndex == null ? null : parent.childNodes[endIndex]; dom != end; dom = dom.nextSibling, ++index) {
                this$1.findAtPoint(parent, index);
                this$1.addDOM(dom);
                if (sync && blockTags.hasOwnProperty(dom.nodeName.toLowerCase())) {
                    this$1.sync(sync);
                }
            }
            this.findAtPoint(parent, index);
        };
        ParseContext.prototype.findPlace = function(type, attrs) {
            var this$1 = this;
            var route,
                sync;
            for (var depth = this.open; depth >= 0; depth--) {
                var node = this$1.nodes[depth];
                var found = node.findWrapping(type, attrs);
                if (found && (!route || route.length > found.length)) {
                    route = found;
                    sync = node;
                    if (!found.length) {
                        break;
                    }
                }
                if (node.solid) {
                    break;
                }
            }
            if (!route) {
                return false;
            }
            this.sync(sync);
            for (var i = 0; i < route.length; i++) {
                this$1.enterInner(route[i].type, route[i].attrs, false);
            }
            return true;
        };
        ParseContext.prototype.insertNode = function(node) {
            if (this.findPlace(node.type, node.attrs)) {
                this.closeExtra();
                var top = this.top;
                if (top.match) {
                    var match = top.match.matchNode(node);
                    if (!match) {
                        node = node.mark(node.marks.filter(function(mark) {
                            return top.match.allowsMark(mark.type);
                        }));
                        match = top.match.matchNode(node);
                    }
                    top.match = match;
                }
                top.content.push(node);
            }
        };
        ParseContext.prototype.enter = function(type, attrs, preserveWS) {
            var ok = this.findPlace(type, attrs);
            if (ok) {
                this.enterInner(type, attrs, true, preserveWS);
            }
            return ok;
        };
        ParseContext.prototype.enterInner = function(type, attrs, solid, preserveWS) {
            this.closeExtra();
            var top = this.top;
            top.match = top.match && top.match.matchType(type, attrs);
            var options = preserveWS == null ? top.options & OPT_PRESERVE_WS : preserveWS ? OPT_PRESERVE_WS : 0;
            if ((top.options & OPT_OPEN_LEFT) && top.content.length == 0) {
                options |= OPT_OPEN_LEFT;
            }
            this.nodes.push(new NodeContext(type, attrs, solid, null, options));
            this.open++;
        };
        ParseContext.prototype.closeExtra = function(openRight) {
            var this$1 = this;
            var i = this.nodes.length - 1;
            if (i > this.open) {
                this.marks = Mark.none;
                for (; i > this.open; i--) {
                    this$1.nodes[i - 1].content.push(this$1.nodes[i].finish(openRight));
                }
                this.nodes.length = this.open + 1;
            }
        };
        ParseContext.prototype.finish = function() {
            this.open = 0;
            this.closeExtra(this.isOpen);
            return this.nodes[0].finish(this.isOpen || this.options.topOpen);
        };
        ParseContext.prototype.sync = function(to) {
            var this$1 = this;
            for (var i = this.open; i >= 0; i--) {
                if (this$1.nodes[i] == to) {
                    this$1.open = i;
                    return;
                }
            }
        };
        prototypeAccessors.currentPos.get = function() {
            var this$1 = this;
            this.closeExtra();
            var pos = 0;
            for (var i = this.open; i >= 0; i--) {
                var content = this$1.nodes[i].content;
                for (var j = content.length - 1; j >= 0; j--) {
                    pos += content[j].nodeSize;
                }
                if (i) {
                    pos++;
                }
            }
            return pos;
        };
        ParseContext.prototype.findAtPoint = function(parent, offset) {
            var this$1 = this;
            if (this.find) {
                for (var i = 0; i < this.find.length; i++) {
                    if (this$1.find[i].node == parent && this$1.find[i].offset == offset) {
                        this$1.find[i].pos = this$1.currentPos;
                    }
                }
            }
        };
        ParseContext.prototype.findInside = function(parent) {
            var this$1 = this;
            if (this.find) {
                for (var i = 0; i < this.find.length; i++) {
                    if (this$1.find[i].pos == null && parent.contains(this$1.find[i].node)) {
                        this$1.find[i].pos = this$1.currentPos;
                    }
                }
            }
        };
        ParseContext.prototype.findAround = function(parent, content, before) {
            var this$1 = this;
            if (parent != content && this.find) {
                for (var i = 0; i < this.find.length; i++) {
                    if (this$1.find[i].pos == null && parent.contains(this$1.find[i].node)) {
                        var pos = content.compareDocumentPosition(this$1.find[i].node);
                        if (pos & (before ? 2 : 4)) {
                            this$1.find[i].pos = this$1.currentPos;
                        }
                    }
                }
            }
        };
        ParseContext.prototype.findInText = function(textNode) {
            var this$1 = this;
            if (this.find) {
                for (var i = 0; i < this.find.length; i++) {
                    if (this$1.find[i].node == textNode) {
                        this$1.find[i].pos = this$1.currentPos - (textNode.nodeValue.length - this$1.find[i].offset);
                    }
                }
            }
        };
        Object.defineProperties(ParseContext.prototype, prototypeAccessors);
        function normalizeList(dom) {
            for (var child = dom.firstChild,
                     prevItem = null; child; child = child.nextSibling) {
                var name = child.nodeType == 1 ? child.nodeName.toLowerCase() : null;
                if (name && listTags.hasOwnProperty(name) && prevItem) {
                    prevItem.appendChild(child);
                    child = prevItem;
                } else if (name == "li") {
                    prevItem = child;
                } else if (name) {
                    prevItem = null;
                }
            }
        }
        function matches(dom, selector) {
            return (dom.matches || dom.msMatchesSelector || dom.webkitMatchesSelector || dom.mozMatchesSelector).call(dom, selector);
        }
        function parseStyles(style) {
            var re = /\s*([\w-]+)\s*:\s*([^;]+)/g,
                m,
                result = [];
            while (m = re.exec(style)) {
                result.push(m[1], m[2].trim());
            }
            return result;
        }
        function copy(obj) {
            var copy = {};
            for (var prop in obj) {
                copy[prop] = obj[prop];
            }
            return copy;
        }
        return module.exports;
    });

    $__System.registerDynamic("4d", [], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        var DOMSerializer = function(nodes, marks) {
            this.nodes = nodes || {};
            this.marks = marks || {};
        };
        DOMSerializer.prototype.serializeFragment = function(fragment, options, target) {
            var this$1 = this;
            if (options === void 0)
                options = {};
            if (!target) {
                target = doc(options).createDocumentFragment();
            }
            var top = target,
                active = null;
            fragment.forEach(function(node) {
                if (active || node.marks.length) {
                    if (!active) {
                        active = [];
                    }
                    var keep = 0;
                    for (; keep < Math.min(active.length, node.marks.length); ++keep) {
                        if (!node.marks[keep].eq(active[keep])) {
                            break;
                        }
                    }
                    while (keep < active.length) {
                        active.pop();
                        top = top.parentNode;
                    }
                    while (active.length < node.marks.length) {
                        var add = node.marks[active.length];
                        active.push(add);
                        top = top.appendChild(this$1.serializeMark(add, options));
                    }
                }
                top.appendChild(this$1.serializeNode(node, options));
            });
            return target;
        };
        DOMSerializer.prototype.serializeNode = function(node, options) {
            if (options === void 0)
                options = {};
            return this.renderStructure(this.nodes[node.type.name](node), node, options);
        };
        DOMSerializer.prototype.serializeNodeAndMarks = function(node, options) {
            var this$1 = this;
            if (options === void 0)
                options = {};
            var dom = this.serializeNode(node, options);
            for (var i = node.marks.length - 1; i >= 0; i--) {
                var wrap = this$1.serializeMark(node.marks[i], options);
                wrap.appendChild(dom);
                dom = wrap;
            }
            return dom;
        };
        DOMSerializer.prototype.serializeMark = function(mark, options) {
            if (options === void 0)
                options = {};
            return this.renderStructure(this.marks[mark.type.name](mark), null, options);
        };
        DOMSerializer.renderSpec = function(doc, structure) {
            if (typeof structure == "string") {
                return {dom: doc.createTextNode(structure)};
            }
            if (structure.nodeType != null) {
                return {dom: structure};
            }
            var dom = doc.createElement(structure[0]),
                contentDOM = null;
            var attrs = structure[1],
                start = 1;
            if (attrs && typeof attrs == "object" && attrs.nodeType == null && !Array.isArray(attrs)) {
                start = 2;
                for (var name in attrs) {
                    if (name == "style") {
                        dom.style.cssText = attrs[name];
                    } else if (attrs[name] != null) {
                        dom.setAttribute(name, attrs[name]);
                    }
                }
            }
            for (var i = start; i < structure.length; i++) {
                var child = structure[i];
                if (child === 0) {
                    if (i < structure.length - 1 || i > start) {
                        throw new RangeError("Content hole must be the only child of its parent node");
                    }
                    return {
                        dom: dom,
                        contentDOM: dom
                    };
                } else {
                    var ref = DOMSerializer.renderSpec(doc, child);
                    var inner = ref.dom;
                    var innerContent = ref.contentDOM;
                    dom.appendChild(inner);
                    if (innerContent) {
                        if (contentDOM) {
                            throw new RangeError("Multiple content holes");
                        }
                        contentDOM = innerContent;
                    }
                }
            }
            return {
                dom: dom,
                contentDOM: contentDOM
            };
        };
        DOMSerializer.prototype.renderStructure = function(structure, node, options) {
            var ref = DOMSerializer.renderSpec(doc(options), structure);
            var dom = ref.dom;
            var contentDOM = ref.contentDOM;
            if (node && !node.isLeaf) {
                if (!contentDOM) {
                    throw new RangeError("No content hole in template for non-leaf node");
                }
                if (options.onContent) {
                    options.onContent(node, contentDOM, options);
                } else {
                    this.serializeFragment(node.content, options, contentDOM);
                }
            } else if (contentDOM) {
                throw new RangeError("Content hole not allowed in a mark or leaf node spec");
            }
            return dom;
        };
        DOMSerializer.fromSchema = function(schema) {
            return schema.cached.domSerializer || (schema.cached.domSerializer = new DOMSerializer(this.nodesFromSchema(schema), this.marksFromSchema(schema)));
        };
        DOMSerializer.nodesFromSchema = function(schema) {
            return gatherToDOM(schema.nodes);
        };
        DOMSerializer.marksFromSchema = function(schema) {
            return gatherToDOM(schema.marks);
        };
        exports.DOMSerializer = DOMSerializer;
        function gatherToDOM(obj) {
            var result = {};
            for (var name in obj) {
                var toDOM = obj[name].spec.toDOM;
                if (toDOM) {
                    result[name] = toDOM;
                }
            }
            return result;
        }
        function doc(options) {
            return options.document || window.document;
        }
        return module.exports;
    });

    $__System.registerDynamic("4e", ["45", "43", "46", "47", "44", "49", "4a", "4c", "4d"], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        exports.Node = $__require('45').Node;
        ;
        var assign;
        ((assign = $__require('43'), exports.ResolvedPos = assign.ResolvedPos, exports.NodeRange = assign.NodeRange));
        exports.Fragment = $__require('46').Fragment;
        ;
        var assign$1;
        ((assign$1 = $__require('47'), exports.Slice = assign$1.Slice, exports.ReplaceError = assign$1.ReplaceError));
        exports.Mark = $__require('44').Mark;
        ;
        var assign$2;
        ((assign$2 = $__require('49'), exports.Schema = assign$2.Schema, exports.NodeType = assign$2.NodeType, exports.MarkType = assign$2.MarkType));
        ;
        var assign$3;
        ((assign$3 = $__require('4a'), exports.ContentMatch = assign$3.ContentMatch));
        exports.DOMParser = $__require('4c').DOMParser;
        exports.DOMSerializer = $__require('4d').DOMSerializer;
        return module.exports;
    });

    $__System.registerDynamic("3", ["4e"], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        module.exports = $__require('4e');
        return module.exports;
    });

    $__System.registerDynamic("4f", ["9", "3"], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        var ref = $__require('9');
        var findWrapping = ref.findWrapping;
        var liftTarget = ref.liftTarget;
        var canSplit = ref.canSplit;
        var ReplaceAroundStep = ref.ReplaceAroundStep;
        var ref$1 = $__require('3');
        var Slice = ref$1.Slice;
        var Fragment = ref$1.Fragment;
        var NodeRange = ref$1.NodeRange;
        var orderedList = {
            attrs: {order: {default: 1}},
            parseDOM: [{
                tag: "ol",
                getAttrs: function getAttrs(dom) {
                    return {order: dom.hasAttribute("start") ? +dom.getAttribute("start") : 1};
                }
            }],
            toDOM: function toDOM(node) {
                return ["ol", {start: node.attrs.order == 1 ? null : node.attrs.order}, 0];
            }
        };
        exports.orderedList = orderedList;
        var bulletList = {
            parseDOM: [{tag: "ul"}],
            toDOM: function toDOM() {
                return ["ul", 0];
            }
        };
        exports.bulletList = bulletList;
        var listItem = {
            parseDOM: [{tag: "li"}],
            toDOM: function toDOM() {
                return ["li", 0];
            },
            defining: true
        };
        exports.listItem = listItem;
        function add(obj, props) {
            var copy = {};
            for (var prop in obj) {
                copy[prop] = obj[prop];
            }
            for (var prop$1 in props) {
                copy[prop$1] = props[prop$1];
            }
            return copy;
        }
        function addListNodes(nodes, itemContent, listGroup) {
            return nodes.append({
                ordered_list: add(orderedList, {
                    content: "list_item+",
                    group: listGroup
                }),
                bullet_list: add(bulletList, {
                    content: "list_item+",
                    group: listGroup
                }),
                list_item: add(listItem, {content: itemContent})
            });
        }
        exports.addListNodes = addListNodes;
        function wrapInList(nodeType, attrs) {
            return function(state, dispatch) {
                var ref = state.selection;
                var $from = ref.$from;
                var $to = ref.$to;
                var range = $from.blockRange($to),
                    doJoin = false,
                    outerRange = range;
                if (range.depth >= 2 && $from.node(range.depth - 1).type.compatibleContent(nodeType) && range.startIndex == 0) {
                    if ($from.index(range.depth - 1) == 0) {
                        return false;
                    }
                    var $insert = state.doc.resolve(range.start - 2);
                    outerRange = new NodeRange($insert, $insert, range.depth);
                    if (range.endIndex < range.parent.childCount) {
                        range = new NodeRange($from, state.doc.resolve($to.end(range.depth)), range.depth);
                    }
                    doJoin = true;
                }
                var wrap = findWrapping(outerRange, nodeType, attrs, range);
                if (!wrap) {
                    return false;
                }
                if (dispatch) {
                    dispatch(doWrapInList(state.tr, range, wrap, doJoin, nodeType).scrollIntoView());
                }
                return true;
            };
        }
        exports.wrapInList = wrapInList;
        function doWrapInList(tr, range, wrappers, joinBefore, nodeType) {
            var content = Fragment.empty;
            for (var i = wrappers.length - 1; i >= 0; i--) {
                content = Fragment.from(wrappers[i].type.create(wrappers[i].attrs, content));
            }
            tr.step(new ReplaceAroundStep(range.start - (joinBefore ? 2 : 0), range.end, range.start, range.end, new Slice(content, 0, 0), wrappers.length, true));
            var found = 0;
            for (var i$1 = 0; i$1 < wrappers.length; i$1++) {
                if (wrappers[i$1].type == nodeType) {
                    found = i$1 + 1;
                }
            }
            var splitDepth = wrappers.length - found;
            var splitPos = range.start + wrappers.length - (joinBefore ? 2 : 0),
                parent = range.parent;
            for (var i$2 = range.startIndex,
                     e = range.endIndex,
                     first = true; i$2 < e; i$2++, first = false) {
                if (!first && canSplit(tr.doc, splitPos, splitDepth)) {
                    tr.split(splitPos, splitDepth);
                }
                splitPos += parent.child(i$2).nodeSize + (first ? 0 : 2 * splitDepth);
            }
            return tr;
        }
        function splitListItem(nodeType) {
            return function(state, dispatch) {
                var ref = state.selection;
                var $from = ref.$from;
                var $to = ref.$to;
                var node = ref.node;
                if ((node && node.isBlock) || !$from.parent.content.size || $from.depth < 2 || !$from.sameParent($to)) {
                    return false;
                }
                var grandParent = $from.node(-1);
                if (grandParent.type != nodeType) {
                    return false;
                }
                var nextType = $to.pos == $from.end() ? grandParent.defaultContentType($from.indexAfter(-1)) : null;
                var tr = state.tr.delete($from.pos, $to.pos);
                var types = nextType && [null, {type: nextType}];
                if (!canSplit(tr.doc, $from.pos, 2, types)) {
                    return false;
                }
                if (dispatch) {
                    dispatch(tr.split($from.pos, 2, types).scrollIntoView());
                }
                return true;
            };
        }
        exports.splitListItem = splitListItem;
        function liftListItem(nodeType) {
            return function(state, dispatch) {
                var ref = state.selection;
                var $from = ref.$from;
                var $to = ref.$to;
                var range = $from.blockRange($to, function(node) {
                    return node.childCount && node.firstChild.type == nodeType;
                });
                if (!range || range.depth < 2 || $from.node(range.depth - 1).type != nodeType) {
                    return false;
                }
                if (dispatch) {
                    var tr = state.tr,
                        end = range.end,
                        endOfList = $to.end(range.depth);
                    if (end < endOfList) {
                        tr.step(new ReplaceAroundStep(end - 1, endOfList, end, endOfList, new Slice(Fragment.from(nodeType.create(null, range.parent.copy())), 1, 0), 1, true));
                        range = new NodeRange(tr.doc.resolveNoCache($from.pos), tr.doc.resolveNoCache(endOfList), range.depth);
                    }
                    dispatch(tr.lift(range, liftTarget(range)).scrollIntoView());
                }
                return true;
            };
        }
        exports.liftListItem = liftListItem;
        function sinkListItem(nodeType) {
            return function(state, dispatch) {
                var ref = state.selection;
                var $from = ref.$from;
                var $to = ref.$to;
                var range = $from.blockRange($to, function(node) {
                    return node.childCount && node.firstChild.type == nodeType;
                });
                if (!range) {
                    return false;
                }
                var startIndex = range.startIndex;
                if (startIndex == 0) {
                    return false;
                }
                var parent = range.parent,
                    nodeBefore = parent.child(startIndex - 1);
                if (nodeBefore.type != nodeType) {
                    return false;
                }
                if (dispatch) {
                    var nestedBefore = nodeBefore.lastChild && nodeBefore.lastChild.type == parent.type;
                    var inner = Fragment.from(nestedBefore ? nodeType.create() : null);
                    var slice = new Slice(Fragment.from(nodeType.create(null, Fragment.from(parent.copy(inner)))), nestedBefore ? 3 : 1, 0);
                    var before = range.start,
                        after = range.end;
                    dispatch(state.tr.step(new ReplaceAroundStep(before - (nestedBefore ? 3 : 1), after, before, after, slice, 1, true)).scrollIntoView());
                }
                return true;
            };
        }
        exports.sinkListItem = sinkListItem;
        return module.exports;
    });

    $__System.registerDynamic("2a", ["4f"], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        module.exports = $__require('4f');
        return module.exports;
    });

    $__System.register("50", ["3", "4", "7", "26", "37", "2a"], function (_export) {
        "use strict";

        var Schema, DOMParser, DOMSerializer, baseSchema, EditorState, MenuBarEditorView, exampleSetup, buildMenuItems, EditorView, addListNodes, schema, proseMirrorMap, parser;

        _export("getProseMirror", getProseMirror);

        _export("getPMContent", getPMContent);

        _export("createProseMirror", createProseMirror);

        function getProseMirror(id) {
            return proseMirrorMap[id];
        }

        function getPMContent(id) {
            var pm = proseMirrorMap[id];
            var fragment = DOMSerializer.fromSchema(schema).serializeFragment(pm.editor.state.doc.content);
            var tmp = document.createElement("div");
            tmp.appendChild(fragment);
            return tmp.innerHTML;
        }

        function createProseMirror(id, opts) {
            var place = document.getElementById(id);
            proseMirrorMap[id] = new MenuBarEditorView(place, {
                floatingMenu: true,
                //menuContent: buildMenuItems(schema).fullMenu,
                state: EditorState.create({
                    //schema: schema,
                    doc: parser(place),
                    plugins: exampleSetup({ schema: schema })
                }),
                onAction: function onAction(action) {
                    proseMirrorMap[id].updateState(proseMirrorMap[id].editor.state.applyAction(action));
                }
            });
            return proseMirrorMap[id];
        }

        return {
            setters: [function (_3) {
                Schema = _3.Schema;
                DOMParser = _3.DOMParser;
                DOMSerializer = _3.DOMSerializer;
            }, function (_4) {
                baseSchema = _4.schema;
            }, function (_) {
                EditorState = _.EditorState;
            }, function (_2) {
                MenuBarEditorView = _2.MenuBarEditorView;
            }, function (_5) {
                exampleSetup = _5.exampleSetup;
                buildMenuItems = _5.buildMenuItems;
            }, function (_a) {
                EditorView = _a.EditorView;
                addListNodes = _a.addListNodes;
            }],
            execute: function () {
                schema = new Schema({
                    nodes: addListNodes(baseSchema.nodeSpec, "paragraph block*", "block"),
                    marks: baseSchema.markSpec
                });
                proseMirrorMap = {};
                ;

                ;

                parser = function parser(slot) {
                    var content = $(slot).find('.card-content').val();
                    var domNode = document.createElement("div");
                    domNode.innerHTML = content;
                    return DOMParser.fromSchema(schema).parse(domNode);
                };

                ;
            }
        };
    });
    $__System.registerDynamic("1", ["50"], true, function($__require, exports, module) {
        ;
        var define,
            global = this,
            GLOBAL = this;
        pm = $__require('50');
        createProseMirror = pm.createProseMirror;
        getProseMirror = pm.getProseMirror;
        getProseMirrorContent = pm.getPMContent;
        return module.exports;
    });

})
(function(factory) {
    factory();
});
//# sourceMappingURL=script_prosemirror.js.map