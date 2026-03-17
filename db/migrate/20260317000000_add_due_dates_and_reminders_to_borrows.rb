class AddDueDatesAndRemindersToBorrows < ActiveRecord::Migration[8.0]
  def change
    add_column :borrows, :due_at, :datetime
    add_column :borrows, :due_soon_reminder_sent_at, :datetime
    add_column :borrows, :overdue_reminder_sent_at, :datetime
  end
end

