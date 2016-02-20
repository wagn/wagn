# -*- encoding : utf-8 -*-

class Card::Cache::Persistent
  attr_reader :prefix

  def initialize opts
    @store = opts[:store]
    self.system_prefix =
      opts[:prefix] || Card::Cache.system_prefix(opts[:class])
  end

  def system_prefix= system_prefix
    @system_prefix = system_prefix
    @prefix = "#{system_prefix}/"
  end

  def read key
    @store.read(full_key(key))
  end

  def write_variable key, variable, value
    if @store && (object = @store.read key)
      object.instance_variable_set "@#{variable}", value
      @store.write key, object
    end
    value
  end

  def write key, value
    @store.write(full_key(key), value)
  end

  def fetch key, &block
    @store.fetch full_key(key), &block
  end

  def delete key
    @store.delete full_key(key)
  end

  def reset
    @store.clear
  rescue => e
    Rails.logger.debug "Problem clearing cache: #{e.message}"
  end

  def exist? key
    @store.exist? full_key(key)
  end

  def full_key key
    @prefix + key
  end
end
