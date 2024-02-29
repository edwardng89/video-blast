require 'date'

class Date
  alias to_s to_fs
end

class Time
  alias to_s to_fs
end

class DateTime
  alias to_s to_fs
end

class ActiveSupport::TimeWithZone
  alias to_s to_fs
end
