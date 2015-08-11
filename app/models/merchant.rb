class Merchant < ActiveRecord::Base
	include Searchable

	enum status: [ :active, :inactive ]
	enum gender: [ :male, :female, :other ]

	SORT_ORDER = {1 => "Relevance", 2 => "Rating", 3 => "Price Up", 4 => "Price Down", 5 => "Session Up", 6 => "Session Down"}

	has_many :openings
	has_and_belongs_to_many :specializations, -> { uniq }

	validates :name, :email, :status, :about, :gender, :price, :review_count, :avg_rating, presence: true
end
Merchant.import # for auto sync model with elastic search
