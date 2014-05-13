class SearchController < ApplicationController
  def index
    @address = Array.new
    @geocode_location = Array.new
    @name_to_urls = Hash.new

    require 'rest-client'
    require 'crack'
    def address_to_coordinates(address)
      @address = address
      @base_google_url = "http://maps.googleapis.com/maps/api/geocode/xml?sensor=false&address="
      res = RestClient.get(URI.encode("#{@base_google_url}#{@address}"))
      @spaghetti  = URI.encode("#{@base_google_url}#{@address}")
      parsed_res = Crack::XML.parse(res) #parsing XML 
      begin
        lat = parsed_res["GeocodeResponse"]["result"]["geometry"]["location"]["lat"]
        lng = parsed_res["GeocodeResponse"]["result"]["geometry"]["location"]["lng"]
      rescue
        @weird_lat = parsed_res["GeocodeResponse"]["result"]
        @weird_lng = parsed_res["GeocodeResponse"]["result"]
      end  
      # @coordinates = "#{lat},#{lng}"
      return "#{lat},#{lng}" #important to use double quotes for string interp.
    end

    def time
      start = Time.now
      yield
      @request_time = Time.now - start
    end 

    def format_query(params)
      #evaluate the input and store values into geocode_location coordinates
      @query = params[:q]
      @location = params[:location]
      @location1 = params[:location1]

      #NEED-MODIFICATION: TAKE LIST OF CITIES AND PLACE COORD INTO GEOCODE_LOCATION
      #14 STATIC CITIES
      @name_to_urls["Montreal, Canada"] = "geocode:" + "45.505730,-73.579928,2mi"
      @name_to_urls["San Francisco, USA"] = "geocode:" + "37.781157,-122.398720,2mi"
      @name_to_urls["Vancouver, Canada"] = "geocode:" + "49.2612260,-123.1139268,2mi"
      @name_to_urls["Toronto, Canada"] = "geocode:" + "43.6532260,-79.3831843,2mi"
      @name_to_urls["New York, USA"] = "geocode:" + "40.7056308,-73.9780035,2mi"
      @name_to_urls["Los Angeles, USA"] = "geocode:" + "34.0522342,-118.2436849,2mi "
      @name_to_urls["London, England"] = "geocode:" + "51.5085150,-0.1254872,2mi "
      @name_to_urls["Paris, France"] = "geocode:" + "48.8566140,2.3522219,2mi "
      @name_to_urls["Berlin, Germany"] = "geocode:" + "52.5200066,13.4049540,2mi "
      @name_to_urls["Hong Kong, Hong Kong"] = "geocode:" + "22.3964280,114.1094970,2mi "
      @name_to_urls["Taipei, Taiwan"] = "geocode:" + "25.0910750,121.5598345,2mi "
      @name_to_urls["Tokyo, Japan"] = "geocode:" + "35.6894875,139.6917064,2mi"
      @name_to_urls["Seoul, South Korea"] = "geocode:" + "37.5665350,126.9779692,2mi"
      @name_to_urls["Sydney, Australia"] = "geocode:" + "-33.8674869,151.2069902,2mi"

      #...

      #2 DYNAMIC CITIES
      unless (params[:location].blank?)
        @name_to_urls["#{params[:location]}"] = @query + " " + "geocode:" + address_to_coordinates(params[:location]) + ",2mi"
      end
      unless (params[:location1].blank?)
        @name_to_urls["#{params[:location1]}"] = @query + " " + "geocode:" + address_to_coordinates(params[:location1]) + ",2mi"
      end
    end

    #send query to twitter api
    require 'twitter'
    require 'thread'

    client = ""
    def twitter_request(client)
      #find twitter client (ISSUE: should this be in quotations?)
      client = Twitter::REST::Client.new do |config|
        config.consumer_key     = ENV["TWITTER_CONSUMER_KEY"]
        config.consumer_secret    = ENV["TWITTER_CONSUMER_SECRET"]
        config.access_token     = ENV["TWITTER_ACCESS_TOKEN"]
        config.access_token_secret = ENV["TWITTER_ACCESS_TOKEN_SECRET"]
        config.bearer_token     = ENV["TWTTER_BEARER_TOKEN"]
      end 
      # @client_user = client.user("charlesliu2012")
      @client_bearer_token = client.bearer_token
    
      #multiple requests
      @urls_to_name = @name_to_urls.invert
      @tweets = Hash.new 
      #delete later
      @clone_tweets = Array.new
      #conduct multiple requests
      threads = []
      
      #timing start
      time do
        @name_to_urls.each do |name, url|
          threads << Thread.new{
            #begin 
            tweet = client.search(url, :result_type => "recent").take(1).pop.text
            name = @urls_to_name["#{url}"]
            @tweets["#{name}"] = tweet
            # @tweets.push(client.search(city_query, :result_type => "recent").take(1).pop.text)
            #rescue
            #name = @urls_to_name["#{url}"]
            #@tweets["#{name}"] = "No tweets available!"
            #end
          }
        end
        threads.each(&:join) #waits for all the requests  
      end  
    end


    #Main methods
    format_query(params)
    twitter_request(client)
  
    #5/11
    #tried installing google-maps-for-rail
    #completed steps including install underscore and npm (nodeJS package manager), but somehow running the server "rails s" gives me error.    

end

end
