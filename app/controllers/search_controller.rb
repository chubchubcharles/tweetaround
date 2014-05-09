class SearchController < ApplicationController
  def index
    @geocode_location = Array.new
    @urls = Array.new

    def format_query(params)
      #evaluate the input and store values into geocode_location coordinates
      @query = params[:q]

      #NEED-MODIFICATION: TAKE LIST OF CITIES AND PLACE COORD INTO GEOCODE_LOCATION
      @geocode_location << "geocode:" + "45.505730,-73.579928,1mi"
      @geocode_location << "geocode:" + "37.781157,-122.398720,1mi"

      #helper method to insert 
      @geocode_location.each do |geocode|
        @urls << @query + " " + geocode
      end

    end

    #send query to twitter api
    require 'twitter'
    require 'thread'

    client = ""
    def twitter_request(client)
      #find twitter client
      client = Twitter::REST::Client.new do |config|
        config.consumer_key     = ENV["TWITTER_CONSUMER_KEY"]
        config.consumer_secret    = ENV["TWITTER_CONSUMER_SECRET"]
        config.bearer_token     = ENV["TWTTER_BEARER_TOKEN"]
      end 
      @client_user = client.user("charlesliu2012")
      @client_bearer_token = client.bearer_token
    

      #multiple requests
      @tweets = Array.new 
      #delete later
      @clone_tweets = Array.new
      #conduct multiple requests
      threads = []
      @urls.each do |city_query|
        threads << Thread.new{
          begin 
          @tweets.push(client.search(city_query, :result_type => "recent").take(1).pop.text)
          rescue
          @tweets.push("No tweets available!")
          end
        }
      end
      threads.each(&:join) #waits for all the requests   
    end

    #Main methods
    format_query(params)
    twitter_request(client)


   # def send_request
      # client.search(@request, :result_type => "recent").take(3).each do |tweet|
      #   # puts tweet.text
      #   @tweets.push(tweet.text)
      # end
    # end

    # @tweets = client.user_timeline( count:2)
    #for each major city

      #search for hashtag in twitter api

end

end
