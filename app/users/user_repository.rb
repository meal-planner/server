class UserRepository
  include Elasticsearch::Persistence::Repository
  include MealPlanner::Repository::Store
  extend MealPlanner::Repository::TermQuery

  klass User

  index :users
  type :user

  class << self

    def find_by_email(email)
      term_query(:email, email).first.presence
    end

    def find_by_oauth(provider_name, provider_id)
      term_query(provider_name, provider_id).first.presence
    end

    def find_by_password_token(token)
      term_query(:password_token, token).first.presence
    end

    def find_by_auth_token(token)
      payload = Token.new(token)
      raise SecurityError, 'Token invalid.' unless payload.valid?

      find(payload.user_id)
    end

    def persist(document)
      if document.id
        update document
      else
        result = save document
        document.id = result['_id']
      end
    end

  end
end