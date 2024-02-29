##
#
class AdminRole < ClassyEnum::Base
end

##
#
class AdminRole::Basic < AdminRole
end

##
#
class AdminRole::Normal < AdminRole
end

##
#
class AdminRole::SuperUser < AdminRole
end
