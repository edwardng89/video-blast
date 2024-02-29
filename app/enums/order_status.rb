##
#
class OrderStatus < ClassyEnum::Base
end

##
#
class OrderStatus::AwaitingCustomer < OrderStatus
end

##
#
class OrderStatus::InProgress < OrderStatus
end

##
#
class OrderStatus::Rented < OrderStatus
end
