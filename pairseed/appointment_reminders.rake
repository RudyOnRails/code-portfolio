desc "Sends Daily Appointment Reminders"

task :send_appointment_reminders => :environment do
  todays_appts = Appointment.where("date_and_time BETWEEN ? AND ?", DateTime.now.beginning_of_day, DateTime.now.end_of_day)
  todays_appts.each do |appointment|
    AppointmentMailer.appointment_reminder(appointment.id).deliver
  end
end