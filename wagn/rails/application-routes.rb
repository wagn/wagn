Wagn.application.routes.draw do
  if !Rails.env.production? && Object.const_defined?(:JasmineRails)
    mount Object.const_get(:JasmineRails).const_get(:Engine) => "/specs"
  end
  mount Decko::Engine => "/"
end
