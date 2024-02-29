##
# File Uploader
class FileUploader < BaseUploader
  include CarrierWave::MiniMagick

  def extension_white_list
    %w[pdf doc docx xls xlsx jpg jpeg gif png]
  end

  version :thumb, if: :is_picture? do
    process resize_to_fill: [200, 200]
  end
end
