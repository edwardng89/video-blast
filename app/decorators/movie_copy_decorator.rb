class MovieCopyDecorator < ApplicationDecorator
  delegate_all
  # Methods Start
  # Methods End

  ##
  # @return [Hash] A hash of data we want in the XLSX export
  def as_xls
    {
      # Columns Start
      # Columns End
    }
  end
end
