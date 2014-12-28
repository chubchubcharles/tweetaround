class SearchController < ApplicationController
  def index
    @address = Array.new
    @geocode_location = Array.new
    @name_to_lat = Hash.new
    @name_to_lng = Hash.new
    @name_to_urls = Hash.new
    @test_var = "hi"

    require 'rest-client'
    require 'crack'
    def address_to_coordinates(address)
      @address = address
      @base_google_url = "http://maps.googleapis.com/maps/api/geocode/xml?sensor=false&address="
      res = RestClient.get(URI.encode("#{@base_google_url}#{@address}"))
      parsed_res = Crack::XML.parse(res) #parsing XML 
      begin
        @name_to_lat[address] = parsed_res["GeocodeResponse"]["result"]["geometry"]["location"]["lat"]
        @name_to_lng[address] = parsed_res["GeocodeResponse"]["result"]["geometry"]["location"]["lng"]
      rescue
        @weird_lat = parsed_res["GeocodeResponse"]["result"]
        @weird_lng = parsed_res["GeocodeResponse"]["result"]
        @name_to_lat[address] = " "
        @name_to_lng[address] = " "
        @google_maps_api_error = "Google Maps API Error"
        # @weird_coord = "#{lat},#{lng}"
      end  
      # @coordinates = "#{lat},#{lng}"
      # return "#{lat},#{lng}" #important to use double quotes for string interp.
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

      #NEED-MODIFICATION: TAKE LIST OF CITIES AND PLACE COORD INTO GEOCODE_LOCATION
      #11 STATIC CITIES
      # @static_cities = ["Montreal, Canada" , "Toronto, Canada" , "San Francisco, US" , "New York, US" , "Los Angeles, US" , "London, England" , "Paris, France" , "Berlin, Germany" , "Hong Kong" , "Taipei, Taiwan" , "Tokyo, Japan"]
      @static_cities = ["Montreal, Canada" , "Toronto, Canada" , "San Francisco, US" , "New York, US" , "Los Angeles, US" , "London, England" , "Paris, France" , "Berlin, Germany" , "Hong Kong" , "Taipei, Taiwan" , "Tokyo, Japan" , "Seoul, South Korea", "Sydney, Australia", "Rio de Janeiro, Brazil", "Johannesburg, South Africa"]
      @static_cities.each do |static_city|
        address_to_coordinates(static_city)
        @name_to_urls[static_city] = @query + " geocode:" + "#{@name_to_lat[static_city]},#{@name_to_lng[static_city]},2mi"
      end

      #2 DYNAMIC CITIES
      unless (@location.blank?)
        # if address_to_coordinates(params[:location]) == "N/A,N/A"
        #   @name_to_urls["#{params[:location]}"] = "Location not found."
        # else
          @name_to_urls["#{@location}"] = @query + " " + "geocode:" + "#{@name_to_lat[@location]},#{@name_to_lng[@location]},2mi"
        # end
      end
    end

    #send query to twitter api
    require 'twitter'
    require 'thread'

    client = ""
    def twitter_request(client)
      #find twitter client (ISSUE: should this be in quotations?)
      client = Twitter::REST::Client.new do |config|
        config.consumer_key     = "#{ENV["TWITTER_CONSUMER_KEY"]}"
        config.consumer_secret    = "#{ENV["TWITTER_CONSUMER_SECRET"]}" 
        config.access_token     = "#{ENV["TWITTER_ACCESS_TOKEN"]}" 
        config.access_token_secret = "#{ENV["TWITTER_ACCESS_TOKEN_SECRET"]}" 
        config.bearer_token     =  "#{ENV["TWITTER_BEARER_TOKEN"]}" 
      end 
      # @client_user = client.user("charlesliu2012")
      @client_bearer_token = client.bearer_token
    
      #multiple requests
      @urls_to_name = @name_to_urls.invert
      @tweets = Hash.new 
      #conduct multiple requests
      threads = []
      
      #timing start
      time do
        @name_to_urls.each do |name, url|
          threads << Thread.new{
            begin 
              tweet = client.search(url, :result_type => "recent").take(1).pop.text
              name = @urls_to_name["#{url}"]
              tweet = tweet.to_s.gsub(/\n/," ")
              @tweets["#{name}"] = "#{tweet}"
            rescue
              @tweets["#{name}"] = "No tweets available!"
              name = @urls_to_name["#{url}"]
            end
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
