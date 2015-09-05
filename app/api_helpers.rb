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

  def authenticated?
    token = request.env['HTTP_AUTHORIZATION'].to_s.split(' ').last
    token.present?
  end

  def authenticated_user
    begin
      token = request.env['HTTP_AUTHORIZATION'].to_s.split(' ').last
      User.find_by_auth_token(token)
    rescue SecurityError
      halt 401, {error: 'Authentication required'}.to_json
    end
  end

  def load_entity(entity_class)
    begin
      entity_class.find params[:id]
    rescue Elasticsearch::Persistence::Repository::DocumentNotFound
      halt 404, {error: "#{entity_class} not found."}.to_json
    end
  end

  def get_entity(entity_class)
    entity = load_entity(entity_class)
    hash = entity.to_h
    hash[:id] = entity.id
    hash[:can_edit] = entity.owned_by?(authenticated_user) if authenticated?
    hash
  end

  def create_entity(entity_class)
    entity = entity_class.new parse_request
    entity.owner = authenticated_user

    halt 422, entity.errors.to_json unless entity.valid?

    entity.save
    status 201
    entity.to_json
  end

  def update_entity(entity_class)
    user = authenticated_user
    entity = load_entity(entity_class)
    halt 401, {error: 'Authentication required.'}.to_json unless entity.owned_by?(user)

    request = parse_request
    entity_class.attribute_set.each do |attr|
      entity[attr.name] = request[attr.name.to_s] unless request[attr.name.to_s].nil?
    end
    halt 422, entity.errors.to_json unless entity.valid?

    entity.save
    halt 200
  end
end