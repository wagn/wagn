class Card::Cache::Temporary
  attr_reader :store

  def initialize
    @store = Hash.new
  end

  def read key
    return unless @store.has_key? key
    @store[key]
  end

  def write key, value
    @store[key] = value
  end

  def fetch key, &block
    read(key) || write(key, block.call)
  end

  def delete key
    @store.delete key
  end

  def dump
    @store.each do |k, v|
      p "#{k} --> #{v.inspect[0..30]}"
    end
  end

  def reset
    @store = {}
  end

  def exist? key
    @store.has_key? key
  end
end
