class DiscussionDatatype < Datatype::Base
  
  register "Discussion"
  editor_type "RichText"
  
  description %{
    Describe Discussion datatype here.
  }     
  
  def post_render(content)
    name = User.current_user ? "" : %{
      <label>My Name is:</label>
      <input type=text value="Anonymous" onClick="this.value=''" />   
    }
    textarea = %{    
      <div class="discussion">
      <form>
        
        <label>Comment:</label><br/>
        <textarea></textarea><br/>
        #{name}      
        <input type="submit" value="Comment"/>
      
      </form>
      </div>
    }
    content.replace(content + textarea)
  end
  
end
