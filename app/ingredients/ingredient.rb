# Ingredient entity
class Ingredient
  include Virtus.model
  include MealPlanner::Repository::Model
  include MealPlanner::Repository::Model::CanBeOwned
  # Ingredient measure entity
  class Measure
    include Virtus.model

    attribute :qty, Integer
    attribute :eqv, Integer
    attribute :label, String
    attribute :nutrients, Hash[Symbol => Float]
  end

  attribute :ndbno, String
  attribute :name, String
  attribute :group, String
  attribute :generic, Boolean, default: false
  attribute :image_url, String
  attribute :measures, Array[Measure]

  def image_crop=(data)
    return if data.blank?

    uri = URI::Data.new data
    s3 = Aws::S3::Resource.new(
      credentials: Aws::Credentials.new(ENV['AWS_KEY'], ENV['AWS_SECRET'])
    )
    @image_url = "ingredient/image/#{id}-#{Time.now.to_i}.jpg"
    obj = s3.bucket(ENV['AWS_IMG_BUCKET']).object(@image_url)
    obj.put(body: uri.data)
  end
end
