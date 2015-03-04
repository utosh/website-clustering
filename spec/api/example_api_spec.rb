require 'spec_helper'

RSpec.describe ExampleAPI, type: :api do
  include Rack::Test::Methods

  def app
    ExampleAPI
  end

  before do
  end

  describe "'GET' /hello" do
    subject { get :hello, params }

    let(:params) do
      {
        to: "John Doe",
        msg: "Nice to meet you!"
      }
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
