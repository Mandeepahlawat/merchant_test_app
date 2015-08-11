module Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model

    # Customize the index name
    #
    index_name [Rails.application.engine_name, Rails.env].join('_')

    # Set up index configuration and mapping
    #
    settings index: { number_of_shards: 1, number_of_replicas: 0 } do
      mapping do
        indexes :name, type: 'multi_field' do
          indexes :name,     analyzer: 'snowball'
          indexes :tokenized, analyzer: 'simple'
        end

        indexes :about, type: 'multi_field' do
          indexes :about,   analyzer: 'snowball'
          indexes :tokenized, analyzer: 'simple'
        end

        indexes :gender, type: 'multi_field'
        indexes :price, type: 'multi_field'
        indexes :review_count, type: 'multi_field'
        indexes :avg_rating, type: 'multi_field'

        indexes :openings do
          indexes :start_time, type: 'date'
          indexes :end_time, type: 'date'
          indexes :status, type: 'keyword'
          indexes :session_time_in_sec, type: 'multi_field'
        end

        indexes :specializations do#, analyzer: 'keyword'
          indexes :id, index: :not_analyzed
          indexes :name, type: 'keyword'
        end
      end
    end

    
    #use default callbacks
    include Elasticsearch::Model::Callbacks

    # Customize the JSON serialization for Elasticsearch
    #
    def as_indexed_json(options={})
      hash = self.as_json(
        include: { 
                   openings:   { only: [:start_time, :end_time, :session_time_in_sec, :status] },
                   specializations: {only: [:name, :id]}
                 })
      hash
    end

    # Search in name and about fields for `query`, include highlights in response
    #
    # @param query [String] The user query
    # @return [Elasticsearch::Model::Response::Response]
    #
    def self.search(query, options={})

      # Prefill and set the filters (top-level `filter` elements)
      #
      __set_filters = lambda do |key, f|
        @search_definition[:filter][:and] ||= []
        @search_definition[:filter][:and]  |= [f]
      end

      @search_definition = {
        query: {},

        highlight: {
          pre_tags: ['<em class="label label-highlight">'],
          post_tags: ['</em>'],
          fields: {
            name:    { number_of_fragments: 0 },
            about:  { fragment_size: 50 }
          }
        },

        filter: {}
      }

      unless query.blank?
        @search_definition[:query] = {
          bool: {
            should: [
              { multi_match: {
                  query: query,
                  fields: ['name^1', 'about^2', 'specializations.name^3'],
                  operator: 'and'
                }
              }
            ]
          }
        }
        @search_definition[:sort]  = options[:sort_by].values.first
      else
        @search_definition[:query] = { match_all: {} }
        @search_definition[:sort]  = options[:sort_by].values.first 
      end

      #accepts price range as a hash of start_val and end_val; float values
      if options[:price][:start_val] && options[:price][:end_val]
        f = {
          range: {
            price: {
              gte: options[:price][:start_val],
              lte: options[:price][:end_val]
            }
          }
        }
        __set_filters.(:price, f)
      end

      #accepts integer avg_rating
      if options[:avg_rating]
        f = {
          range: {
            avg_rating: {
              lte: options[:avg_rating]
            }
          }
        }
        __set_filters.(:avg_rating, f)
      end

      #accepts string values = ["female", "male", "other"]
      if options[:genders]
        f = {
          terms: {
            gender: options[:genders]
          }
        }
        __set_filters.(:gender, f)
      end

      #accepts specialization ids as integer values = [1,2]
      if options[:specializations]
        f = { terms: { "specializations.id" =>  options[:specializations] } }

        __set_filters.(:specializations, f)
        # __set_filters.(:published, f)
      end

      #accepts session_length as a hash of start_val and end_val
      if options[:session_length][:start_val] && options[:session_length][:start_val]
        f = {
          range: {
            "openings.session_time_in_sec" => {
              # convert session length from minutes to seconds
              gte: (options[:session_length][:start_val].to_i * 60),
              lte: (options[:session_length][:end_val].to_i * 60)
            }
          }
        }
        __set_filters.(:session_length, f)
      end

      if options[:availability]
        @availability_filter = {}
        __set_availability_filters = lambda do |key, f|
          @availability_filter[:or] ||= []
          @availability_filter[:or]  |= [f]
        end

        if options[:availability].include? "1"
          f = {
                and: [
                  {term: {"openings.start_time" => Time.zone.now}},
                  {term: {"openings.status" => "available"}}
                ]
              }
          __set_availability_filters.(:availability, f)
          # __set_availability_filters.(f)
        end

        #available from next days 9:00 - 12:00
        if options[:availability].include? "2"
          next_day_morning = 1.day.from_now.beginning_of_day + 9.hours

          f = __check_by_availability_time(next_day_morning, (next_day_morning + 3.hours))
  
          __set_availability_filters.(:availability, f)
        end

        # available from next days 12:00 - 16:00
        if options[:availability].include? "3"
          next_day_afternoon = 1.day.from_now.beginning_of_day + 12.hours

          f = __check_by_availability_time(next_day_afternoon, (next_day_afternoon + 4.hours))
  
          __set_availability_filters.(:availability, f)
        end

        # available from next days 16:00 - 19:00
        if options[:availability].include? "4"
          next_day_evening = 1.day.from_now.beginning_of_day + 16.hours

          f = __check_by_availability_time(next_day_evening, (next_day_evening + 3.hours))
  
          __set_availability_filters.(:availability, f)
        end

        # available from next days 19:00 - 22:00
        if options[:availability].include? "5"
          next_day_night = 1.day.from_now.beginning_of_day + 19.hours

          f = __check_by_availability_time(next_day_night, (next_day_night + 3.hours))
  
          __set_availability_filters.(:availability, f)
        end

        #available today
        if options[:availability].include? "6"
          start_of_today = Time.zone.now.beginning_of_day

          f = __check_by_availability_time(start_of_today, (start_of_today + 24.hours))
  
          __set_availability_filters.(:availability, f)
        end

        # available tomorrow
        if options[:availability].include? "7"
          start_of_next_day = 1.day.from_now.beginning_of_day

          f = __check_by_availability_time(start_of_next_day, (start_of_next_day + 24.hours))
  
          __set_availability_filters.(:availability, f)
        end

        # available this week
        if options[:availability].include? "8"
          start_of_this_week = Time.zone.now.at_beginning_of_week

          f = __check_by_availability_time(next_day_night, (start_of_this_week + 7.days))
  
          __set_availability_filters.(:availability, f)
        end 
        __set_filters.(:availability, @availability_filter)
      end

      unless query.blank?
        @search_definition[:suggest] = {
          text: query,
          suggest_title: {
            term: {
              field: 'name.tokenized',
              suggest_mode: 'always'
            }
          },
          suggest_body: {
            term: {
              field: 'about.tokenized',
              suggest_mode: 'always'
            }
          }
        }
      end
      __elasticsearch__.search(@search_definition)
    end

    def self.__check_by_availability_time(start_val,end_val)
      {
        and: [
          {
            range: {
              "openings.start_time" => {
                gte: start_val,
                lte: end_val
              }
            }
          },
          {term: {"openings.status" => "available"}}
        ]
      }
    end
  end
end
