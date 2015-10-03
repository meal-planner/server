module MealPlanner
  module Repository
    module Model
      # model has image, stored at Amazon AWS S3
      # image content is passed into 'image_crop' attribute as base64 encoded data-uri
      module HasImage
        include Virtus.module

        attribute :image_url, String

        def image_crop=(data)
          return unless data.present?
          remove_image

          entity = self.class.name.downcase
          file = "#{id}-#{Time.now.to_i}.jpg"
          @image_url = "#{entity}/image/#{file[0..3]}/#{file[4..6]}/#{file}"

          save_image data
        end

        private

        def aws_s3
          Aws::S3::Resource.new(
            credentials: Aws::Credentials.new(ENV['AWS_KEY'], ENV['AWS_SECRET'])
          )
        end

        def remove_image
          return unless @image_url

          image = aws_s3.bucket(ENV['AWS_IMG_BUCKET']).object(@image_url)
          image.delete
        end

        def save_image(data)
          image = aws_s3.bucket(ENV['AWS_IMG_BUCKET']).object(@image_url)
          uri = URI::Data.new data
          image.put(body: uri.data)
        end
      end
    end
  end
end
