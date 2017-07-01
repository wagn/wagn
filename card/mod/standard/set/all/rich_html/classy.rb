format :html do
  # Classy home for classes and klasses
  def class_up klass, classier, force=false
    key = klass.to_s
    return if !force && class_list[key]
    class_list[key] = [class_list[key], classier.to_s].compact.join(" ")
  end

  def class_down klass, classier
    class_list.delete klass if class_list[klass] == classier
  end

  def with_class_up klass, classier, force=false
    class_up klass, classier, force
    yield
  ensure
    class_down klass, classier
  end

  # don't use in the given block the additional class that
  # was added to `klass`
  def without_upped_class klass
    tmp_class = class_list.delete klass
    result = yield tmp_class
    class_list[klass] = tmp_class
    result
  end

  def class_list
    @class_list ||= {}
  end

  def classy *classes
    classes = Array.wrap(classes).flatten
    [classes, class_list[classes.first]].flatten.compact.join " "
  end
end
