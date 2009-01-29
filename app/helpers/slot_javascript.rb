class SlotJavascript
  attr_accessor :slot
  
  def initialize( slot )
    @slot = slot
  end
  
  def update
    "#{slot.selector}.update( request.responseText )"
  end
  
  def redirect( opts = {} )
    "document.location.href=request.responseText; Wagn.Messenger.alert('#{opts[:msg]}')"
  end
  
end
