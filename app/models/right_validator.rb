class RightValidator < ActiveModel::Validator
  def initialize options
   super options
   @right_names ||= {}
   return unless attrs = options[:attributes]
   with_value = Card[options[:with]].name
   attrs.each { |attr| @right_names[attr] = with_value }
warn "validate options #{@right_names.inspect}"
  end

  def validate_each(rec, attr, value)
    warn "validate #{attr}, #{value}, #{rec.name.right} == #{@right_names[attr]}"
    rec.errors.add attr, "not right-name" if rec.name.right == @right_names[attr]
  end
end
