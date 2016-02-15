require "./lib/geolocation"
require "sinatra/base"
require "net/http"
require "json"
require 'pry'

require "dotenv"
Dotenv.load

def locate
  @ip = request.ip
  @geolocation = Geolocation.new(@ip)
end

def local_weather
  locate
  wukey = ENV["WUNDERGROUND_API_KEY"]
  url = "http://api.wunderground.com/api/#{wukey}/conditions/q/"
  url += "#{@geolocation.state_code}/#{@geolocation.city}.json"

  uri = URI(url)
  response = Net::HTTP.get_response(uri)
  @temp = JSON.parse(response.body)["current_observation"]["temperature_string"]
end

def get_news
  nytkey = ENV["NYTIMES_API_KEY"]
  uri = URI("http://api.nytimes.com/svc/topstories/v1/home.json?api-key=#{nytkey}")
  response = Net::HTTP.get_response(uri)
  @news = JSON.parse(response.body)["results"]
end

def get_events
  set_location
  city = @city
  state = @state
  today = Time.now.strftime("%Y-%m-%d")

  url = "http://api.seatgeek.com/2/events"
  url += "?venue.city=#{city}"
  url += "&datetime_local.gte=#{today}"

  uri = URI(url)
  response = Net::HTTP.get_response(uri)
  @events = JSON.parse(response.body)["events"]
end

class Dashboard < Sinatra::Base
  get("/") do
    locate
    local_weather
    get_news
    get_events

    erb :dashboard
  end
end
