module Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    mappings do
    end

    def self.search(query)
      __elasticsearch__.search(
        {
          query: {
            multi_match: {
              query: query,
              fields: ['name^1', 'about^2', 'specializations.name^3']
            }
          }
        }
      )
    end

    def as_indexed_json(options={})
      as_json(
        only: [:name, :about],
        include: {
          specializations: {only: [:name, :id]},
          openings: {only: [:start_time, :end_time, :session_time_in_sec, :status, :id]}
        }
      )
    end
  end
end