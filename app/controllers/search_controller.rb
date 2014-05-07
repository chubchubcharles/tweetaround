class SearchController < ApplicationController
	def index
		@query = params[:q]

		#test for montreal,canada
		@geocode = "45.505730%2C-73.579928%"

		#structuring query
		@base_query = "https://api.twitter.com/1.1/search/tweets.json?"
		@query_query = "q=" + @query
		@geocode_query = "&geocode=" + @geocode 
		@tail_query = "2C1mi&result_type=recent"

		@final_query = @base_query + @query_query + @geocode_query + @tail_query

		#send query to twitter api

		
		#for each major city

			#search for hashtag in twitter api



	end


end
