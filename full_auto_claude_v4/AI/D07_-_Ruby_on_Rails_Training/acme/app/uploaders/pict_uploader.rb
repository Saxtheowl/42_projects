class PictUploader < CarrierWave::Uploader::Base
  include Cloudinary::CarrierWave

  def public_id
    "acme/products/#{model.id}/pict"
  end

  version :thumb do
    eager
    cloudinary_transformation width: 150, height: 150, crop: :fill
  end

  def extension_allowlist
    %w[jpg jpeg gif png webp]
  end
end
