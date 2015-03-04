require 'spec_helper'

RSpec.describe ClusteringAPI, type: :api do
  include Rack::Test::Methods

  def app
    ClusteringAPI
  end

  before do
  end

  describe "'GET' /clustering" do
    subject { get :clustering, params }

    let(:params) do
      {}
    end

    it do
      subject
      expect(last_response.status).to eq 200
    end

    it do
      subject
      parsed_body = JSON.parse(last_response.body)
      expect(parsed_body["message"]).to eq "Nice to meet you!John Doe!"
    end

    context "when :to param is not given" do
      let(:params) do
        {}
      end

      it do
        expect{subject}.to_not raise_error
        expect(last_response.status).to eq 400
      end
    end
  end
end
