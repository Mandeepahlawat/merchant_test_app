class MerchantsController < ApplicationController
	before_action :set_sort_order_session
	before_action :set_order_by
  
  def index
	  	@merchants 			 	= Merchant.includes(:openings, :specializations)
	  	@specializations 	= Specialization.all
	  	@merchants 				= @merchants.by_specialization(params[:specialization_ids]) if params[:specialization_ids]
	  	@merchants 				= @merchants.by_gender(params[:gender_ids]) if params[:gender_ids]
	  	@merchants        = @merchants.by_price_range(params[:price].split(",")[0], params[:price].split(",")[1]) if params[:price]
	  	@merchants        = @merchants.by_avg_rating(params[:ratings]) if params[:ratings]
	  	@merchants 				= @merchants.by_session_length(params[:session].split(",")[0], params[:session].split(",")[1]) if params[:session]
	  	@merchants 				= @merchants.find_available_merchants(@merchants,params[:available_ids]) if params[:available_ids]	
	  	@merchants        = @merchants.order(@order_by.first[1])
	  	search_by_elastic if params[:search].present?
  end

  private

  	def search_by_elastic
  		@merchants 				= Merchant.search(params[:search]).records.records 
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