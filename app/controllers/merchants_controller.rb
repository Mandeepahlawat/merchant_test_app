class MerchantsController < ApplicationController
	before_action :set_sort_order_session
	before_action :set_order_by
  
  def index
  	@options = {
      avg_rating:         params[:ratings].try(:to_i),
      genders: 						params[:gender_ids],
      specializations:  	params[:specialization_ids],
      availability:       params[:available_ids],
      sort_by: 						@order_by
    }
    merge_in_options(params[:price], "price")
    merge_in_options(params[:session], "session_length")
    @specializations 	=		Specialization.all
  	@merchants 				= 	Merchant.search(params[:search], @options).records.records
  end

  private

  	def merge_in_options(params, variable)
  		@options.merge!(variable.to_sym => {start_val: params.try(:split, ",").try(:first), end_val: params.try(:split, ",").try(:last)})
  	end

  	def set_sort_order_session
  		if session[:sort_order].nil? && params[:sort_by].nil? 
  			session[:sort_order] = '1'  
			elsif params[:sort_by].present?
				session[:sort_order] = params[:sort_by]
			end
  	end

  	def set_order_by
  		case session[:sort_order]
			when '1'
			  @order_by = {1 => {}}
			when '2'
			  @order_by = {2 => {avg_rating: {order: "desc"}}}
			when '3'
			  @order_by = {3 => {price: {order: "asc"}}}
			when '4'
				@order_by = {4 => {price: {order: "desc"}}}
			when '5'
			  @order_by = {5 => {"openings.session_time_in_sec" => {order: "asc"}}}
			else
				@order_by = {6 => {"openings.session_time_in_sec" => {order: "desc"}}}
			end
  	end
end