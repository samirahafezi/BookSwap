class BorrowReminderJob < ApplicationJob
  queue_as :default

  def perform
    Borrow.active.with_due_date.find_each do |borrow|
      send_due_soon_reminder(borrow)
      send_overdue_reminder(borrow)
    end
  end

  private

  def send_due_soon_reminder(borrow)
    return if borrow.due_soon_reminder_sent_at.present?
    return unless borrow.due_soon?

    BorrowsMailer.due_soon(borrow).deliver_later
    borrow.update_column(:due_soon_reminder_sent_at, Time.current)
  end

  def send_overdue_reminder(borrow)
    return unless borrow.overdue?

    if borrow.overdue_reminder_sent_at.nil? || borrow.overdue_reminder_sent_at < 24.hours.ago
      BorrowsMailer.overdue(borrow).deliver_later
      borrow.update_column(:overdue_reminder_sent_at, Time.current)
    end
  end
end

