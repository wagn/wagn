class Card::Cache::Temporary
  attr_reader :store

  def initialize
    @store = {}
  end

  def read key
    return unless @store.key? key
    @store[key]
  end

  def write key, value
    @store[key] = value
  end

  def fetch key, &_block
    read(key) || write(key, yield)
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
    @store.key? key
  end
end
