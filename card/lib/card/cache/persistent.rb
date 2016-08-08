# -*- encoding : utf-8 -*-

class Card::Cache::Persistent
  attr_accessor :prefix

  class << self
    def database_name
      @database_name ||= (cfg = Cardio.config) &&
                         (dbcfg = cfg.database_configuration) &&
                         dbcfg[Rails.env]["database"]
    end
  end

  def initialize opts
    @store = opts[:store]
    @klass = opts[:class]
    @class_key = @klass.to_s.to_name.key
    @database = opts[:database] || self.class.database_name
  end

  def renew
    @stamp = nil
    @prefix = nil
  end

  def reset
    @stamp = new_stamp
    @prefix = nil
    Cardio.cache.write stamp_key, @stamp
  end

  def stamp
    @stamp ||= Cardio.cache.fetch stamp_key { new_stamp }
  end

  def stamp_key
    "#{@database}/#{@class_key}/stamp"
  end

  def new_stamp
    Time.now.to_i.to_s 32
  end

  def prefix
    @prefix ||= "#{@database}/#{@class_key}/#{stamp}"
  end

  def full_key key
    "#{prefix}/#{key}"
  end

  def read key
    @store.read full_key(key)
  end

  def write_variable key, variable, value
    if @store && (object = read key)
      object.instance_variable_set "@#{variable}", value
      write key, object
    end
    value
  end

  def write key, value
    @store.write full_key(key), value
  end

  def fetch key, &block
    @store.fetch full_key(key), &block
  end

  def delete key
    @store.delete full_key(key)
  end

  def annihilate
    @store.clear
  end

  def exist? key
    @store.exist? full_key(key)
  end
end
