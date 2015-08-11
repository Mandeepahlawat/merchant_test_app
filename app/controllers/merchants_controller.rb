class MerchantsController < ApplicationController
	before_action :set_sort_order_session
	before_action :set_order_by
  
  def index
  	options = {
      price:       				{start_val: params[:price].try(:split,",").try(:first), end_val: params[:price].try(:split,",").try(:last)},
      avg_rating:         params[:ratings].try(:to_i),
      genders: 						params[:gender_ids],
      specializations:  	params[:specialization_ids],
      session_length:     {start_val: params[:session].try(:split,",").try(:first).try(:to_i), end_val: params[:session].try(:split,",").try(:last).try(:to_i)},
      availability:       params[:available_ids]
    }
    @specializations 	=		Specialization.all
  	@merchants 				= 	Merchant.search(params[:search], options).records.records
  end

  private

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
			  @order_by = {1 => "merchants.id"}
			when '2'
			  @order_by = {2 => "merchants.avg_rating desc"}
			when '3'
			  @order_by = {3 => "merchants.price"}
			when '4'
				@order_by = {4 => "merchants.price desc"}
			when '5'
			  @order_by = {5 => "openings.session_time_in_sec"}
			else
				@order_by = {6 => "openings.session_time_in_sec desc"}
			end
  	end
end