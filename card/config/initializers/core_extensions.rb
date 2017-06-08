# -*- encoding : utf-8 -*-

# extend core Ruby object classes

class Module
  def include_extension extension
    include extension
  end
end

module CoreExtensions
  ::Kernel.include_extension Kernel
  ::Object.include_extension Object
  ::Module.include_extension Module
  ::Array.include_extension Array
  ::Hash.include_extension Hash::Merging
  ::Symbol.include_extension PersistentIdentifier
  ::Integer.include_extension PersistentIdentifier
  ::Hash.extend Hash::ClassMethods::Nesting
end
