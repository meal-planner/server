module MealPlanner
  module Helper
    module Request
      def parse_request
        body = request.body.read
        halt 400, {error: 'Payload is missing'}.to_json if body.empty?
        begin
          request = JSON.parse(body, symbolize_names: true)
        rescue
          halt 400, {error: 'Request could not be processed'}.to_json
        end
        request
      end
    end
  end
end