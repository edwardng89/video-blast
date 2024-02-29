##
# Base Uploader
class BaseUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  def self.display_image(file)
    if file&.file.present?
      if file.versions.include?(:thumb)
        file.url(:thumb)
      else
        file.url
      end
    else
      '#'
    end
  end

  private

  ##
  # To check whether file is a pdf object and if object is persisted
  # @param new_file (File)
  # @return Boolean
  def is_pdf?(new_file = file)
    return false if new_file.nil?

    new_file.content_type&.include?('pdf')
  end

  ##
  # Check if uploaded file is an image by checking file content type
  # @param new_file (File)
  # @return Boolean
  def is_picture?(file)
    file&.content_type.to_s.include?('image')
  end
end
