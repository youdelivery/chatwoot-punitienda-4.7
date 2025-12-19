# https://docs.360dialog.com/whatsapp-api/whatsapp-api/media
# https://developers.facebook.com/docs/whatsapp/api/media/

class Whatsapp::IncomingMessageWhatsappCloudService < Whatsapp::IncomingMessageBaseService
  private

  def processed_params
    return @processed_params if defined?(@processed_params) && @processed_params.present?

    entry = params[:entry] || params['entry']
    first_entry = entry.is_a?(Array) ? entry.first : nil
    changes = first_entry&.[](:changes) || first_entry&.[]('changes')
    first_change = changes.is_a?(Array) ? changes.first : nil
    value = first_change&.dig(:value) || first_change&.dig('value')

    @processed_params = value.is_a?(Hash) ? value.deep_symbolize_keys : value
  end

  def download_attachment_file(attachment_payload)
    url_response = HTTParty.get(
      inbox.channel.media_url(
        attachment_payload[:id],
        inbox.channel.provider_config['phone_number_id']
      ),
      headers: inbox.channel.api_headers
    )
    # This url response will be failure if the access token has expired.
    inbox.channel.authorization_error! if url_response.unauthorized?
    Down.download(url_response.parsed_response['url'], headers: inbox.channel.api_headers) if url_response.success?
  end
end
