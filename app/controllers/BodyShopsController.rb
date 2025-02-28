class BodyShopsController < ApplicationController
    require 'httparty'

def search
    lat = params[:latitude]
    lng = params[:longitude]
    radius = 20123
    api_key = ENV['GOOGLE_PLACES_API_KEY']

    url = "https://places.googleapis.com/v1/places:searchNearby"
    headers = {
        "Content-Type" => "application/json",
        "X-Goog-Api-Key" => api_key,
        "X-Goog-FieldMask" => "places.displayName,places.formattedAddress,places.location,places.types"
      }
  
      body = {
        "includedTypes" => ["car_repair"],
        "maxResultCount" => 20,
        "locationRestriction" => {
          "circle" => {
            "center" => { "latitude" => lat.to_f, "longitude" => lng.to_f },
            "radius" => radius
          }
        }
      }
  
      response = HTTParty.post(url, headers: headers, body: body.to_json)
      Rails.logger.info("Google Places API response: #{response.parsed_response.inspect}")
      
      # Check if the API response contains an error
      if response.parsed_response["error"]
        error_message = response.parsed_response["error"]["message"]
        Rails.logger.error("Google Places API error: #{error_message}")
        render json: { error: error_message }, status: :bad_request and return
      end
      
      results = response.parsed_response["places"]

  
    # Ensure results is not nil before iterating
    if results.present?
      results.each do |shop|
        unwanted_types = ["grocery_store", "liquor_store", "supermarket","department_store", "sporting_goods_store", "clothing_store","truck_stop", "convenience_store", "gas_station"]
  
        if (shop["types"] & unwanted_types).empty?
          BodyShop.create(
            name: shop["displayName"]["text"],
            address: shop["formattedAddress"],
            latitude: shop["location"]["latitude"],
            longitude: shop["location"]["longitude"]
          )
        else
          Rails.logger.info("Skipping shop #{shop['displayName']['text']} due to unwanted types: #{shop['types'] & unwanted_types}")
        end
      end
    else
      Rails.logger.error("No places found in the API response.")
      render json: { error: "No places found" }, status: :not_found and return
    end

    render json: results
  end
end