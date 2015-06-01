def history?
  false
end

event :store_in_session, :after=>:approve, :on=>:create do
  Env.session[key] = db_content
  self.db_content = ''
end

event :update_in_session, :after=>:approve, :on=>:update do
  if db_content_changed?
    Env.session[key] = db_content
    self.db_content = ''
  end
end

event :delete_in_session, :after=>:approve, :on=>:delete do
  Env.session[key] = nil
  abort :success
end

def content
  Env.session[key]
end

format :html do
  view :editor, :mod=>PlainText::HtmlFormat
end

