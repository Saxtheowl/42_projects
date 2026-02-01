class AvatarUploader < CarrierWave::Uploader::Base
  include Cloudinary::CarrierWave

  def public_id
    "acme/brands/#{model.id}/avatar"
  end

  version :thumb do
    eager
    cloudinary_transformation width: 100, height: 100, crop: :fill
  end

  def extension_allowlist
    %w[jpg jpeg gif png webp]
  end
end
