require 'sidekiq'
require 'net/http'

class PublishWorker
  include ::Sidekiq::Worker

  def perform(cookbook_name)
    parsed = JSON.parse(get_supermarket_response(cookbook_name))

    parsed['name'] == cookbook_name ? failure = false : failure = true

    Net::HTTP.post_form(
      URI.parse("#{ENV['FIERI_SUPERMARKET_ENDPOINT']}/api/v1/cookbook-versions/publish_evaluation"),
      fieri_key: ENV['FIERI_KEY'],
      cookbook_name: cookbook_name,
      publish_failure: failure,
      publish_feedback: 'something'
    )
  end

  private

  def supermarket_uri(cookbook_name)
    URI.parse("#{ENV['FIERI_SUPERMARKET_ENDPOINT']}/api/v1/cookbooks/#{cookbook_name}")
  end

  def get_supermarket_response(cookbook_name)
    Net::HTTP.get(supermarket_uri(cookbook_name))
  end
end
