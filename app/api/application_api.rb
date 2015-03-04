class ApplicationAPI < Grape::API
  version 'v1', using: :path
  default_format :json

  mount ExampleAPI
end
