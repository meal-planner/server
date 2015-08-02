module ApiHelpers
  def parse_request
    body = request.body.read
    halt 400, {error: 'Payload is missing.'}.to_json if body.empty?
    begin
      request = JSON.parse(body)
    rescue
      halt 400, {error: 'Request could not be processed.'}.to_json
    end
    request
  end

  def load_entity(entity)
    begin
      entity.find params[:id]
    rescue Elasticsearch::Persistence::Repository::DocumentNotFound
      halt 404, {error: "#{entity} not found."}.to_json
    end
  end

  def create_entity(entity_class)
    entity = entity_class.new parse_request

    halt 422, entity.errors.to_json unless entity.valid?

    entity.save
    status 201
    entity.to_json
  end

  def update_entity(entity_class)
    entity = load_entity(entity_class)
    request = parse_request

    entity_class.attribute_set.each do |attr|
      entity[attr.name] = request[attr.name.to_s] unless request[attr.name.to_s].nil?
    end
    halt 422, entity.errors.to_json unless entity.valid?

    entity.save
    halt 200
  end
end