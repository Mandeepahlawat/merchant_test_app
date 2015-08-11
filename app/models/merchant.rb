class Merchant < ActiveRecord::Base
	include Searchable

	enum status: [ :active, :inactive ]
	enum gender: [ :male, :female, :other ]

	SORT_ORDER = {1 => "Relevance", 2 => "Rating", 3 => "Price Up", 4 => "Price Down", 5 => "Session Up", 6 => "Session Down"}

	has_many :openings
	has_and_belongs_to_many :specializations, -> { uniq }

	validates :name, :email, :status, :about, :gender, :price, :review_count, :avg_rating, presence: true

	scope :with_openings, ->  {includes(:openings).where("openings.start_time <= ? AND openings.status = ?", 1.days.from_now, 0).order("start_time").references(:openings)}

	# scope :by_specialization, -> (specialization_ids) {where("specializations.id IN (?)", specialization_ids).references(:specializations)}
	# scope :by_gender, -> (gender_ids) {where("merchants.gender IN (?)", gender_ids).references(:merchants)}
	# scope :by_price_range, -> (start_val, end_val) {where('merchants.price <= ? and merchants.price >= ?', end_val, start_val)}
	# scope :by_avg_rating, -> (ratings) {where('merchants.avg_rating <= ?', ratings)}
	# scope :by_session_length, -> (start_val, end_val) {where('openings.session_time_in_sec <= ? and openings.session_time_in_sec >= ?', end_val.to_i * 60, start_val.to_i * 60).references(:openings)}
	scope :by_availability, -> (start_val, end_val) {where("openings.start_time >= ? AND openings.start_time <= ? AND openings.status = ?", start_val, end_val, 0).references(:openings)}
	scope	:available_right_now, -> {where("openings.start_time = ? AND openings.status = ?", Time.zone.now, 0).references(:openings)}
	# scope :availability, -> {where("(openings.start_time = ? AND openings.status = ?) OR (openings.start_time >= ? AND openings.start_time <= ? AND openings.status = ?)", Time.zone.now, 0).references(:openings)}
	

	# def self.search_by_specialization(specialization_ids, sort_by)
	# 	__elasticsearch__.search(
	# 		{
	#       query: {
	#       	filtered:{
	#       		query: { match_all: {}},
	#       		filter: {
	#       			terms: { "specializations.id" => specialization_ids }
	#       		}
	#       	}
	#       }
	#     }
	#   )
	# end


	# available at this moment

	# available from next days 9:00 - 12:00
	def self.available_in_morning merchants
	  next_day_morning = 1.day.from_now.beginning_of_day + 9.hours
	  merchants.by_availability(next_day_morning, next_day_morning + 3.hours)
	end

	# available from next days 12:00 - 16:00
	def self.available_in_afternoon merchants
		next_day_afternoon = 1.day.from_now.beginning_of_day + 12.hours
		merchants.by_availability(next_day_afternoon, next_day_afternoon + 4.hours)
	end

	# available from next days 16:00 - 19:00
	def self.available_in_evening merchants
		next_day_evening = 1.day.from_now.beginning_of_day + 16.hours
		merchants.by_availability(next_day_evening, next_day_evening + 3.hours)
	end

	# available from next days 19:00 - 22:00
	def self.available_in_night merchants
		next_day_night = 1.day.from_now.beginning_of_day + 19.hours
		merchants.by_availability(next_day_night, next_day_night + 3.hours)
	end

	# available today
	def self.available_today merchants
		start_of_today = Time.zone.now.beginning_of_day
		merchants.by_availability(start_of_today, start_of_today + 24.hours)
	end

	# available tomorrow
	def self.available_tomorrow merchants
		start_of_next_day = 1.day.from_now.beginning_of_day
		merchants.by_availability(start_of_next_day, start_of_next_day + 24.hours)
	end

	# available this week
	def self.available_this_week merchants
		start_of_this_week = Time.zone.now.at_beginning_of_week
		merchants.by_availability(start_of_this_week, start_of_this_week + 7.days)
	end


	def self.find_available_merchants merchants, params
		merchants =  merchants.available_right_now 		if params.include? "1"
		merchants =  available_in_morning merchants 	if params.include? "2"
		merchants =  available_in_afternoon merchants if params.include? "3"
		merchants =  available_in_evening merchants 	if params.include? "4"
		merchants =  available_in_night merchants 		if params.include? "5"
		merchants =  available_today merchants 				if params.include? "6"
		merchants =  available_tomorrow merchants 		if params.include? "7"
		merchants =  available_this_week merchants 		if params.include? "8"
		merchants
	end
end
Merchant.import # for auto sync model with elastic search
