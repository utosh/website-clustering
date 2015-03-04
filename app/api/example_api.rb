class ExampleAPI < Grape::API
  default_format :json

  desc "GET /hello"
  params do
    requires :to, type: String
    optional :msg, type: String
  end
  get :hello do
    {
      message: "#{params[:msg]}#{params[:to]}!"
    }
  end
end
