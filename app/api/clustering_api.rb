class ClusteringAPI < Grape::API
  default_format :json

  namespace :clustering do
    desc "GET /clustering"
    params do
      requires :url, type: String
    end
    get do
    end
  end
end
