module MealPlanner
  module Helper
    module Entity
      def create_entity_in(repository)
        entity = repository.klass.new parse_request
        entity.owner = authenticated_user

        validator = repository.validator.new
        halt 422, validator.errors.to_json unless validator.valid?(entity)

        repository.save entity
        status 201
        entity.to_json
      end

      def update_entity_in(repository)
        user = authenticated_user
        entity = load_entity_from repository
        halt 401, {error: 'Authentication required.'}.to_json unless entity.owned_by?(user)

        request = parse_request
        repository.klass.attribute_set.each do |attr|
          entity[attr.name] = request[attr.name] unless request[attr.name].nil?
        end
        validator = repository.validator.new
        halt 422, validator.errors.to_json unless validator.valid?(entity)

        repository.update entity
        status 200
      end

      def get_entity_from(repository)
        entity = load_entity_from repository
        hash = entity.to_h
        hash[:id] = entity.id
        hash[:can_edit] = entity.owned_by?(authenticated_user) if authenticated?
        hash.delete(:owner_id)
        hash
      end

      def search_entities_in(repository)
        repository.filtered_search(
            text: params[:query],
            filter_by: params[:filter_by],
            filter_value: params[:filter_value],
            start: params[:start],
            size: params[:size]
        )
      end

      private

      def load_entity_from(repository)
        begin
          repository.find params[:id]
        rescue Elasticsearch::Persistence::Repository::DocumentNotFound
          halt 404, {error: 'Not Found'}.to_json
        end
      end
    end
  end
end