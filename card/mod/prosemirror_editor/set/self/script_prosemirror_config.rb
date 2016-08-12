include_set Abstract::CodeFile

Self::ScriptEditors.add_to_basket :item_codenames, :script_prosemirror_config
Self::Head::Javascript::HtmlFormat.add_to_basket(
  :mod_js_config, [:prose_mirror, "setProseMirrorConfig"]
)
