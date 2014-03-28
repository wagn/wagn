
format :html do
  view :core do |args|
    oldmem = session[:memory]
    session[:memory] = newmem = card.profile_memory
    stats = %{
      <h2>Stats</h2>
      <p>cards:         #{ Card.where(:trash=>false).count }</p>
      <p>trashed cards: #{ Card.where(:trash=>true).count  }</p>
      <p>revisions:     #{ Card::Revision.count            }</p>
      <p>references:    #{ Card::Reference.count           }</p>
      <p>memory usage now: #{ newmem                      }M</p>
    }
    if oldmem
      stats += %{
        <p>memory usage previous: #{ oldmem               }M</p>
        <p>memory usage diff:     #{ newmem - oldmem      }M</p>
        
      }
    end
    stats
  end
  

end



def get_current_memory_usage
  `ps -o rss= -p #{Process.pid}`.to_i
end

def profile_memory(&block)
  before = get_current_memory_usage
  file, line, _ = caller[0].split(':')
  if block_given?
    instance_eval(&block)
    (get_current_memory_usage - before) / 1024
  else
    before = 0
    (get_current_memory_usage - before) / 1024
  end.to_i
end
