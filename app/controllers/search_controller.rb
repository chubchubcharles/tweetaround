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
		require 'twitter'
		client = Twitter::REST::Client.new do |config|
			config.consumer_key			= "6SyArVlzO5k0gb32QwM4qMDjf"
			config.consumer_secret 		= "8XA6yi4W4zatX23mA1iLNV4zjiQggR7USSuODPuvVKydrz4pqx"
			#config.access_token 		= "61216133-pXgXx4MVF2Fs7AD5ADDwef2duo1w85CRCAgY8y7Q3"
			#config.access_token_secret 	= "Enp0cedAxIWOrAzsQ01BnbsMRe45OpAURZ1bt5GkiCQKX"
			config.bearer_token  		= "AAAAAAAAAAAAAAAAAAAAABLAXQAAAAAAQ3dr6Cn%2BgZLlhT335poTiuYSRs0%3DUQDRvF2byG3KIbQuf9pqqfawHbOMGeHZggGcyK2DF1maqovWDW"
		end 

		@client_user = client.user("charlesliu2012")
		@client_bearer_token = client.bearer_token

		def send_request
			require 'net/http'
			@response = Net::HTTP.get(URI.parse('https://api.twitter.com/1.1/search/tweets.json?q=geo&geocode=45.505730%2C-73.579928%2C1mi&result_type=recent'))
		end
		# @tweets = client.user_timeline( count:2)
		#for each major city

			#search for hashtag in twitter api
	end


end
