class Module
  def delegate_to(object, *collection)
    collection = [*collection]
    is_hash = ((collection.size == 1) and collection.first.kind_of?(Hash))
    hash = is_hash ? collection.first : nil
  
    delegate_to_method = lambda do |as, method|
      module_eval() do
        define_method(as) do |*args|
          send(object).send(method, *args)
        end
      end
    end
  
    if hash
      hash.each { |as, method| delegate_to_method.call(as, method) }
    else
      collection.each { |method| delegate_to_method.call(method, method) }
    end
  end
end