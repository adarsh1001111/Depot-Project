class UrlValidator < ActiveModel::EachValidator
  ALLOWED_IMAGE_EXTENSION_REGEX = /\Ahttps?:\/\/.+\.(gif|jpeg|png|webp)\z/.freeze

  def validate_each(record, attribute, value)
    unless value =~ ALLOWED_IMAGE_EXTENSION_REGEX
      record.errors.add(attribute, (options[:message] || "must be a valid image URL (gif, jpeg, png, webp)"))
    end
  end
end
