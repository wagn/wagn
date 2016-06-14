# -*- encoding : utf-8 -*-

# include is private in ruby 1.9.3
# Object.include CoreExtensions::Object
# Module.include CoreExtensions::Module
# Hash.include CoreExtensions::Hash::Merging
# Array.include CoreExtensions::Array
class Object
  include CoreExtensions::Object
end

class Module
  include CoreExtensions::Module
end

class Hash
  include CoreExtensions::Hash::Merging
end

class Array
  include CoreExtensions::Array
end

Hash.extend CoreExtensions::Hash::ClassMethods::Nesting
