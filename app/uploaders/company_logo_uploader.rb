class CompanyLogoUploader < ImageUploader

  version :thumb

  version :thumb do
    process resize_to_fill: [160, 75]
    process convert: :png
  end

end
