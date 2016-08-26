module MealPlanner
  module Helper
    # API request parsing helper
    module Request
      def parse_request
        body = request.body.read
        halt 400, { error: 'Payload is missing' } if body.empty?
        begin
          JSON.parse(body, symbolize_names: true)
        rescue
          halt 400, { error: 'Request could not be processed' }
        end
      end

      def add_cors_headers
        headers 'Access-Control-Allow-Origin' => ENV['ALLOWED_CORS'],
          'Access-Control-Allow-Methods'      => %w(OPTIONS GET POST),
          'Access-Control-Allow-Headers'      => 'Content-Type, Authorization'
      end
    end
  end
end
