class Specialization < ActiveRecord::Base
	has_and_belongs_to_many :merchants, -> { uniq }
end
