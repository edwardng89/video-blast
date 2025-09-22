class RentalItem < ApplicationRecord
    belongs_to :rental
    belongs_to :copy
    validates :copy_id, uniqueness: { scope: :rental_id }
end
