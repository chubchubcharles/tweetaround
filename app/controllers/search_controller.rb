class SearchController < ApplicationController
  def index
    @query = params[:q]

    #test for montreal,canada
    @geocode = "45.505730%2C-73.579928%"
    #for SF: 37.781157,-122.398720,1mi  
    @geocode_search = "geocode:" + "45.505730,-73.579928,1mi"

    #structuring query
    @base_query = "https://api.twitter.com/1.1/search/tweets.json?"
    @query_query = "q=" + @query
    @geocode_query = "&geocode=" + @geocode 
    @tail_query = "2C1mi&result_type=recent"

    @final_query = @base_query + @query_query + @geocode_query + @tail_query

    #send query to twitter api
    require 'twitter'
    client = Twitter::REST::Client.new do |config|
      config.consumer_key     = ENV["TWITTER_CONSUMER_KEY"]
      config.consumer_secret    = ENV["TWITTER_CONSUMER_SECRET"]
      #config.access_token    = "61216133-pXgXx4MVF2Fs7AD5ADDwef2duo1w85CRCAgY8y7Q3"
      #config.access_token_secret   = "Enp0cedAxIWOrAzsQ01BnbsMRe45OpAURZ1bt5GkiCQKX"
      config.bearer_token     = ENV["TWTTER_BEARER_TOKEN"]
    end 

    @client_user = client.user("charlesliu2012")
    @client_bearer_token = client.bearer_token
    @tweets = Array.new 
    @request = @query + " " + @geocode_search

   # def send_request
      client.search(@request, :result_type => "recent").take(3).each do |tweet|
        # puts tweet.text
        @tweets.push(tweet.text)
      end
    # end

    # @tweets = client.user_timeline( count:2)
    #for each major city

      #search for hashtag in twitter api

end

end
