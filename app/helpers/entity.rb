module MealPlanner
  module Helper
    # Entity (Ingredient & Recipe) API helper
    module Entity
      def create_entity_in(repository)
        entity       = repository.klass.new(parse_request)
        entity.owner = authenticated_user
        validate_entity(repository, entity)
        repository.persist(entity)

        halt 201, { id: entity.id }
      end

      def update_entity_in(repository)
        entity = load_entity_from(repository)
        unless entity.owned_by?(authenticated_user)
          halt 401, { error: 'AccessDenied' }
        end

        entity.attributes = parse_request
        validate_entity(repository, entity)
        repository.persist(entity)

        halt 200, { id: entity.id }
      end

      def get_entity_from(repository)
        entity          = load_entity_from(repository)
        hash            = entity.to_h
        hash[:can_edit] = entity.owned_by?(authenticated_user) if authenticated?
        hash.delete(:owner_id)
        hash
      end

      def search_entities_in(repository)
        repository.filtered_search(
          text:         params[:query],
          filter_by:    params[:filter_by],
          filter_value: params[:filter_value],
          start:        params[:start],
          size:         params[:size],
          sort:         params[:sort]
        )
      end

      def remove_empty_params
        params.each { |key, val| params[key] = nil if val && val.empty? }
      end

      private
      def load_entity_from(repository)
        repository.find(params[:id])
      rescue Elasticsearch::Persistence::Repository::DocumentNotFound
        halt 404, { error: 'NotFound' }
      end

      private
      def validate_entity(repository, entity)
        validator = repository.validator.new
        halt 422, validator.errors unless validator.valid?(entity)
      end
    end
  end
end
