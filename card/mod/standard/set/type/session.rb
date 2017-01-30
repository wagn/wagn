include_set Pointer

def history?
  false
end

def followable?
  false
end

event :store_in_session, :initialize, on: :save, changed: :content do
  Env.session[key] = db_content
  self.db_content = ""
end

event :delete_in_session, :validate, on: :delete do
  Env.session[key] = nil
  abort :success
end

def content
  Env.session[key]
end

format :html do
  def default_core_args args
    args[:items] = { view: :name }
  end
end
