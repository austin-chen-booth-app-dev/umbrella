### IMPORTS ###
require "json"
require "open-uri"
require 'ascii_charts'

### CONSTANTS ###
INTRO_STRING = <<-INTRO
========================================
    Will you need an umbrella today?    
========================================

INTRO

GMAPS_KEY = ENV.fetch("GMAPS_KEY")
DARKSKY_KEY = ENV.fetch("DARK_SKY_KEY")

GMAPS_API_BASE_URI = "https://maps.googleapis.com/maps/api/geocode/json?address="
DARKSKY_API_BASE_URI = "https://api.darksky.net/forecast/"

### HELPER FUNCTIONS ###
def get_full_gmaps_api_uri(location)
  return "#{GMAPS_API_BASE_URI}#{location}&key=#{GMAPS_KEY}"
end

def get_full_darksky_api_uri(latitude, longitude)
  return "#{DARKSKY_API_BASE_URI}#{DARKSKY_KEY}/#{latitude},#{longitude}"
end

def titleize(str)
  str.split(/ |\_/).map(&:capitalize).join(" ")
end

### SCRIPT ###

puts(INTRO_STRING)
puts("Where are you?")

user_location = gets.chomp.strip

puts("Checking the weather at #{titleize(user_location)}....")

# Get Google Maps data
gmaps_api_endpoint = get_full_gmaps_api_uri(user_location)
raw_data = URI.open(gmaps_api_endpoint).read
results = JSON.parse(raw_data).fetch("results")
latitude = results[0]["geometry"]["location"]["lat"]
longitude = results[0]["geometry"]["location"]["lng"]
puts("Your coodinates are #{latitude}, #{longitude}.")

# Get Darksky data
darksky_api_endpoint = get_full_darksky_api_uri(latitude, longitude)
raw_data = URI.open(darksky_api_endpoint).read
results = JSON.parse(raw_data)

# Interpret Darksky results
current_temperature = results["currently"]["temperature"]
next_hour_summary = results["minutely"]["summary"]

should_take_umbrella = false
graph_rendering = []

for hour in (0..12)
  rain_chance = (results["hourly"]["data"][hour]["precipProbability"] * 100).ceil
  if hour >= 1
    graph_rendering.push([hour, rain_chance])
  end
  puts("In #{hour} hours, there is a #{rain_chance}% chance of precipitation.")
  if rain_chance >= 50
    should_take_umbrella = true
  end
end

if should_take_umbrella == true
  puts("You might want to take an umbrella!")
elsif
  puts("You should be okay without an umbrella.")
end

# Draw graph
puts()
puts("Hours from now vs Precipitation probability")
puts(AsciiCharts::Cartesian.new(graph_rendering).draw)
