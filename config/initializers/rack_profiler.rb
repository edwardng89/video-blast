# frozen_string_literal: true

Rack::MiniProfiler.config.skip_schema_queries = true
Rack::MiniProfiler.config.authorization_mode = :whitelist if Rails.env.production?
Rack::MiniProfiler.config.storage = Rack::MiniProfiler::MemoryStore

if ENV['REDIS_URL']
  uri = URI.parse(ENV['REDIS_URL'])
  Rack::MiniProfiler.config.storage_options = { host: uri.host, port: uri.port, password: uri.password }
  Rack::MiniProfiler.config.storage = Rack::MiniProfiler::RedisStore
end
