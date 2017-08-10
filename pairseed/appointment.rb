class Appointment < ActiveRecord::Base
  scope :scheduled, -> { where(:state => "scheduled") }
  scope :cancelled, -> { where(:state => "cancelled") }

  attr_accessible :date_and_time, :helpee_id, :helper_id, :topic_id, :place, :offer_id

  belongs_to :topic
  belongs_to :offer
  has_one :screenshare

  state_machine :initial => :scheduled do

    after_transition :on => :cancel, :do => :do_cancel_stuff

    event :cancel do
      transition [:scheduled] => :cancelled
    end

    event :generate_screenshare do
      transition [:scheduled] => :screenshare_generated
    end

  end

  def do_cancel_stuff
    self.topic.cancel_appointment
    self.offer.cancel_appointment
    AppointmentMailer.cancel_appointment(self.id).deliver
  end

end
