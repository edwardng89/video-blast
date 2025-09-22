class AddOverdueEmailStampsToRentals < ActiveRecord::Migration[7.1]
  def change
    add_column :rentals, :overdue_notice_sent_at, :datetime
    add_column :rentals, :overdue_escalation_sent_at, :datetime
  end
end
