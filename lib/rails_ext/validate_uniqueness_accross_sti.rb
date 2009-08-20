# module ActiveRecord
#   module Validations  
#     module ClassMethods
# 
#       def validates_uniqueness_of(*attr_names)
#         configuration = { :message =>  I18n.translate('activerecord.errors.messages.taken'), :case_sensitive => true }
#         configuration.update(attr_names.pop) if attr_names.last.is_a?(Hash)
# 
#         validates_each(attr_names,configuration) do |record, attr_name, value|
#           if value.nil? || (configuration[:case_sensitive] || !columns_hash[attr_name.to_s].text?)
#             condition_sql = "#{record.class.table_name}.#{attr_name} #{attribute_condition(value)}"
#             condition_params = [value]
#           else
#             condition_sql = "LOWER(#{record.class.table_name}.#{attr_name}) #{attribute_condition(value)}"
#             condition_params = [value.downcase]
#           end
#           if scope = configuration[:scope]
#             Array(scope).map do |scope_item|
#               scope_value = record.send(scope_item)
#               condition_sql << " AND #{record.class.table_name}.#{scope_item} #{attribute_condition(scope_value)}"
#               condition_params << scope_value
#             end
#           end
#           unless record.new_record?
#             condition_sql << " AND #{record.class.table_name}.#{record.class.primary_key} <> ?"
#             condition_params << record.send(:id)
#           end
#           if find(:first, :conditions => [condition_sql, *condition_params])
#             record.errors.add(attr_name, configuration[:message])
#           end
#         end
#       end
#       
#     end
#   end
# end    
# 
# ActiveRecord::Base.extend ActiveRecord::Validations::ClassMethods
