class Opening < ActiveRecord::Base
	enum status: [ :available, :booked, :complete ]

	AVAILABILITY = { 1 => "Now", 2 => "Morning", 3 => "Afternoon", 4 => "Evening", 5 => "Night", 6 => "Today", 7 => "Tomorrow", 8 => "This Week"}

	belongs_to :merchant
	validates :merchant_id, :start_time, :end_time, presence: true
	validate 	:end_date_greater_than_start_date, on: :save

	before_save :assign_session_time

	default_scope {order('start_time')}

	scope :upto_tomorrow, ->  {where("openings.start_time <= ?", 1.days.from_now).order("start_time") }


	private

	def end_date_greater_than_start_date
		errors.add(:base, "End Date can't be equal or earlier than Start Date") if start_time && end_time && (end_time <= start_time)
	end

	def assign_session_time
		self.session_time_in_sec = end_time - start_time if start_time && end_time
	end
end
