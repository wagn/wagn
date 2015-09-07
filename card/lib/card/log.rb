
class Card
  def self.with_logging method, opts, &block
    if Card::Log::Performance.enabled_method? method
      Card::Log::Performance.with_timer(method, opts) do
        block.call
      end
    else
      block.call
    end
  end
end

