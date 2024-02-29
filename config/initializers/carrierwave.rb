if ENV['S3_BUCKET']
  Aws.config.update({ region: ENV['S3_REGION'],
                      access_key_id: ENV['AWS_KEY'], secret_access_key: ENV['AWS_SECRET'] })
end

CarrierWave.configure do |config|
  if ENV['S3_BUCKET']
    config.fog_provider = 'fog/aws'
    config.fog_credentials = {
      provider: 'AWS',
      aws_access_key_id: ENV['AWS_KEY'],
      aws_secret_access_key: ENV['AWS_SECRET'],
      region: ENV['S3_REGION']
    }
    config.fog_directory = ENV['S3_BUCKET']
    config.storage = :fog
    config.fog_public = false
  else
    config.asset_host = ENV['APP_SELF_URL'] || 'http://localhost:3000' # Need full path e.g. WickedPDF
    config.storage = :file
    config.root = "#{Rails.root}/public"
  end
end
class CarrierWave::Uploader::Base
  def store_dir
    folder_path = ''

    # If we've defined a special uploader_parents method on the Model then add extra parent folders
    if model.respond_to?(:uploader_parents)
      parents = [model&.uploader_parents].flatten
      parents.each do |parent|
        folder_path += "#{parent.class.to_s.underscore.pluralize.gsub('/', '-')}/#{'%08i' % parent.id}/"
      end
    end
    folder_path + "#{model.class.to_s.underscore.pluralize.gsub('/', '-')}/#{'%08i' % model.id}/#{mounted_as}"
  end
end
