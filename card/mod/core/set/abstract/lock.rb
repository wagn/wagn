def lock
  was_already_locked = locked?
  return if was_already_locked
  Auth.as_bot do
    lock!
    yield
  end
ensure
  unlock! unless was_already_locked
end

def lock_cache_key
  "UPDATE-LOCK:#{key}"
end

def locked?
  Card.cache.read lock_cache_key
end

def lock!
  Card.cache.write lock_cache_key, true
end

def unlock!
  Card.cache.write lock_cache_key, false
end
