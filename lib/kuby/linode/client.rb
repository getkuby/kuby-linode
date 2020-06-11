require 'base64'
require 'faraday'

module Kuby
  module Linode
    class ApiError < StandardError
      attr_reader :status_code

      def initialize(message, status_code)
        super(message)
        @status_code = status_code
      end
    end

    class UnauthorizedError < ApiError
      def initialize(message)
        super(message, 401)
      end
    end

    class NotFoundError < ApiError
      def initialize(message)
        super(message, 404)
      end
    end

    class Client
      API_URL = 'https://api.linode.com'.freeze
      KUBECONFIG_PATH = '/v4/lke/clusters/%{cluster_id}/kubeconfig'.freeze

      def self.create(access_token:)
        options = {
          url: API_URL,
          headers: {
            Accept: 'application/json',
            Authorization: "Bearer #{access_token}"
          }
        }

        new(
          Faraday.new(options) do |faraday|
            faraday.request(:retry, max: 3)
            faraday.adapter(:net_http)
          end
        )
      end

      attr_reader :connection

      def initialize(connection)
        @connection = connection
      end

      def kubeconfig(cluster_id)
        response = get_json(KUBECONFIG_PATH % { cluster_id: cluster_id })
        Base64.decode64(response['kubeconfig'])
      end

      private

      def get(url, params = {})
        act(:get, url, params)
      end

      def get_json(url, params = {})
        response = get(url, params)
        JSON.parse(response.body)
      end

      def act(verb, *args)
        connection.send(verb, *args).tap do |response|
          potentially_raise_error!(response)
        end
      end

      def potentially_raise_error!(response)
        case response.status
          when 401
            raise UnauthorizedError, "401 Unauthorized: #{response.env.url}"
          when 404
            raise NotFoundError, "404 Not Found: #{response.env.url}"
          else
            if failure_response?(response)
              raise ApiError.new(
                "HTTP #{response.status}: #{response.env.url}, body: #{response.body}",
                response.status
              )
            end
        end
      end

      def failure_response?(response)
        data = JSON.parse(response.body) rescue {}
        (response.status / 100) != 2 || data['message'] == 'failure'
      end
    end
  end
end
