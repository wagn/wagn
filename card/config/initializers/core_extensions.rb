# -*- encoding : utf-8 -*-

# extend core Ruby object classes
module CoreExtensions
  ::Object.include Object
  ::Module.include Module
  ::Hash.include Hash::Merging
  ::Hash.extend Hash::ClassMethods::Nesting
  ::Array.include Array
end
