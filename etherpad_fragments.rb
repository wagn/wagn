

  # before and after action hook code, move to set based models and views
  # whenever we can, most of this should be able to go
  def after_update_type_epad
    # to after_load hook
    if model_action == :update
      cardargs[:content] = qcard.get_pad_content if qcard.respond_to? :get_pad_content
    end
  end

  
=begin
  from edit/_content.rhtml (getting etherpad content into saved data)

  This is where I was hooking using the cardtype to decide to do my slot_save
  instead of the on-submit.  Where the .onsubmit is called in pad_save is
  actually in a callback block.  pad_save returns with this handler set for
  when the remote responds (or times out).

=end
      <%= button_to_function "Save", (card.typename == 'Etherpad') ? "Wagn.pad_save('#{slot.context}', '<need real config of epad app here>/epad/p/#{card.key}')" : "this.form.onsubmit()", :class=>'save-card-button' %>

  # Javascript part, fetch the exported form of the pad, save the data in
  # the content field of the form and trigger the submit action
  pad_save: function(ctx, url) {
  // perform an ajax call on contentsUrl and write it to the parent
  var targetUrl = url + '/export/html'
  jQuery.get(targetUrl, function(data) {
    jQuery('#' + ctx + '-hidden-content')[0].value = data
    jQuery('#'+ctx+'-form')[0].onsubmit();
    //jQuery('#' + ctx + '-epad')[0].value = data
  });
  }
});
