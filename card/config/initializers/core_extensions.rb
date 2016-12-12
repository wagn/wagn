# -*- encoding : utf-8 -*-

module CoreExtensions
  ::Object.include Object
  ::Module.include Module
  ::Hash.include Hash::Merging
  ::Hash.extend Hash::ClassMethods::Nesting
  ::Array.include Array
end