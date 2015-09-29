include Pointer

def history?
  false
end

def followable?
  false
end

event :store_in_session, before: :approve, on: :save, changed: :content do
  Env.session[key] = db_content
  self.db_content = ''
end

event :delete_in_session, after: :approve, on: :delete do
  Env.session[key] = nil
  abort :success
end

def content
  Env.session[key]
end

format do
  include Pointer::Format
end

format :html do
  include Pointer::HtmlFormat

  def default_core_args args
    args[:item] = :name
  end
end

