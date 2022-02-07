require 'base64'
require 'net/http'
require 'uri'

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

    class BearerAuth
      attr_reader :access_token

      def initialize(access_token:)
        @access_token = access_token
      end

      def make_get(path)
        Net::HTTP::Get.new(path).tap do |request|
          request['Authorization'] = "Bearer #{access_token}"
        end
      end
    end

    class Client
      API_URL = 'https://api.linode.com'.freeze
      KUBECONFIG_PATH = '/v4/lke/clusters/%{cluster_id}/kubeconfig'.freeze

      def self.create(access_token:)
        uri = URI(API_URL)

        connection = Net::HTTP.new(uri.host, uri.port).tap do |http|
          http.use_ssl = true if uri.scheme == 'https'
        end

        auth = BearerAuth.new(access_token: access_token)
        new(connection, auth)
      end

      attr_reader :connection, :auth

      def initialize(connection, auth)
        @connection = connection
        @auth = auth
      end

      def kubeconfig(cluster_id)
        response = get_json(KUBECONFIG_PATH % { cluster_id: cluster_id })
        Base64.decode64(response['kubeconfig'])
      end

      private

      def get_json(path)
        request = auth.make_get(path)
        request['Accept'] = 'application/json'
        response = connection.request(request)
        potentially_raise_error!(response)
        JSON.parse(response.body)
      end

      def potentially_raise_error!(response)
        case response.code.to_i
          when 401
            raise UnauthorizedError, "401 Unauthorized: #{response.message}"
          when 404
            raise NotFoundError, "404 Not Found: #{response.message}"
          else
            if failure_response?(response)
              raise ApiError.new(
                "HTTP #{response.code}: #{response.message}, body: #{response.body}",
                response.code
              )
            end
        end
      end

      def failure_response?(response)
        data = JSON.parse(response.body) rescue {}
        (response.code.to_i / 100) != 2 || data['message'] == 'failure'
      end
    end
  end
end
