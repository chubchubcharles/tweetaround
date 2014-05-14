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
      @location1 = params[:location1]

      #NEED-MODIFICATION: TAKE LIST OF CITIES AND PLACE COORD INTO GEOCODE_LOCATION
      #14 STATIC CITIES
      @static_cities = ["Montreal, Canada" , "Toronto, Canada" , "San Francisco, US" , "New York, US" , "Los Angeles, US" , "London, England" "Paris, France" , "Berlin, Germany" , "Hong Kong" , "Taipei, Taiwan" , "Tokyo, Japan"]
      # @static_cities = ["Montreal, Canada" , "Toronto, Canada" , "San Francisco, US" , "New York, US" , "Los Angeles, US" , "London, England" , "Paris, France" , "Berlin, Germany" , "Hong Kong" , "Taipei, Taiwan" , "Tokyo, Japan" , "Seoul, South Korea"]
      @static_cities.each do |static_city|
        address_to_coordinates(static_city)
        @name_to_urls[static_city] = @query + " geocode:" + "#{@name_to_lat[static_city]},#{@name_to_lng[static_city]},2mi"
      end

      # @name_to_urls["Montreal, Canada"] = @query + " " + "geocode:" + "45.505730,-73.579928,2mi"
      # @name_to_urls["San Francisco, US"] = @query + " " + "geocode:" + "37.781157,-122.398720,2mi"
      # @name_to_urls["Vancouver, Canada"] = @query + " " + "geocode:" + "49.2612260,-123.1139268,2mi"
      # @name_to_urls["Toronto, Canada"] = @query + " " + "geocode:" + "43.6532260,-79.3831843,2mi"
      # @name_to_urls["New York, US"] = @query + " " + "geocode:" + "40.7056308,-73.9780035,2mi"
      # @name_to_urls["Los Angeles, US"] = @query + " " + "geocode:" + "34.0522342,-118.2436849,2mi "
      # @name_to_urls["London, England"] = @query + " " + "geocode:" + "51.5085150,-0.1254872,2mi "
      # @name_to_urls["Paris, France"] = @query + " " + "geocode:" + "48.8566140,2.3522219,2mi "
      # @name_to_urls["Berlin, Germany"] = @query + " " + "geocode:" + "52.5200066,13.4049540,2mi "
      # @name_to_urls["Hong Kong, Hong Kong"] = @query + " " + "geocode:" + "22.3964280,114.1094970,2mi "
      # @name_to_urls["Taipei, Taiwan"] = @query + " " + "geocode:" + "25.0910750,121.5598345,2mi "
      # @name_to_urls["Tokyo, Japan"] = @query + " " + "geocode:" + "35.6894875,139.6917064,2mi"
      # @name_to_urls["Seoul, South Korea"] = @query + " " + "geocode:" + "37.5665350,126.9779692,2mi"
      # @name_to_urls["Sydney, Australia"] = @query + " " + "geocode:" + "-33.8674869,151.2069902,2mi"

      #...

      #2 DYNAMIC CITIES
      unless (@location.blank?)
        # if address_to_coordinates(params[:location]) == "N/A,N/A"
        #   @name_to_urls["#{params[:location]}"] = "Location not found."
        # else
          @name_to_urls["#{@location}"] = @query + " " + "geocode:" + "#{@name_to_lat[@location]},#{@name_to_lng[@location]},2mi"
        # end
      end
      unless (@location1.blank?)
        # if address_to_coordinates(params[:location1]) == "N/A,N/A"
        #   @name_to_urls["#{params[:location1]}"] = "Location not found."
        # else 
          @name_to_urls["#{@location1}"] = @query + " " + "geocode:" + "#{@name_to_lat[@location1]},#{@name_to_lng[@location1]},2mi"
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
              @tweets["#{name}"] = tweet
            rescue
              name = @urls_to_name["#{url}"]
              @tweets["#{name}"] = "No tweets available!"
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
