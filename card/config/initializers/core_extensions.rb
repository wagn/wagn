# -*- encoding : utf-8 -*-

# extend core Ruby object classes

class Class
  def include_extension extension
    include extension
  end
end

module CoreExtensions
  ::Object.include_extension Object
  ::Module.include_extension Module
  ::Array.include_extension Array
  ::Hash.include_extension Hash::Merging
  ::Hash.extend Hash::ClassMethods::Nesting
rescue
  binding.pry
end
