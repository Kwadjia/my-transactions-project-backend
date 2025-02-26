class BodyShopsController < ApplicationController
    require 'httparty'

def search
    lat = params[:latitude]
    lng = params[:longitude]
    radius = 40235
    api_key = ENV['GOOGLE_PLACES_API_KEY']

    url = "https://places.googleapis.com/v1/places:searchNearby"
    headers = {
        "Content-Type" => "application/json",
        "X-Goog-Api-Key" => api_key,
        "X-Goog-FieldMask" => "places.displayName,places.formattedAddress,places.location"
      }
  
      body = {
        "includedTypes" => ["car_repair"],
        "maxResultCount" => 5,
        "locationRestriction" => {
          "circle" => {
            "center" => { "latitude" => lat.to_f, "longitude" => lng.to_f },
            "radius" => radius
          }
        }
      }
  
      response = HTTParty.post(url, headers: headers, body: body.to_json)
      # Rails.logger.info("Google Places API response: #{response.parsed_response.inspect}")

      results = response.parsed_response["places"]

  
      # Save to MySQL
      results.each do |shop|
        BodyShop.create(
          name: shop["displayName"]["text"],
          address: shop["formattedAddress"],
          latitude: shop["location"]["latitude"],
          longitude: shop["location"]["longitude"]
        )
      end
  
      render json: results
    end
  end