class AddressesController < ApplicationController
  def autocomplete
    query = params[:query]
    Rails.logger.info "Received autocomplete query: #{query}"

    if query.present?
      begin
        results = Geocoder.search(query)
        addresses = results.map do |result|
          {
            formatted_address: result.address,
            latitude: result.coordinates[0],
            longitude: result.coordinates[1]
          }
        end
        Rails.logger.info "Geocoder results: #{addresses}"
      rescue => e
        Rails.logger.error "Geocoder error: #{e.message}"
        addresses = []
      end
    else
      Rails.logger.error "No addresses yet"
      addresses = []
    end

    render json: addresses
  end
end
