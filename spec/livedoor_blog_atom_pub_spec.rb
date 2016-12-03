require 'spec_helper'
require 'webmock/rspec'

describe LivedoorBlogAtomPub do
  it 'has a version number' do
    expect(LivedoorBlogAtomPub::VERSION).not_to be nil
  end

  describe "Client" do
    before do
      WebMock.enable!
    end

    context "initialize" do
      before do
        @username = 'john'
        @api_key  = 'ABCDEFG'
      end

      it "should set username and api_key" do
        expect{ LivedoorBlogAtomPub::Client.new }.to raise_error(ArgumentError)
      end

      it "is able to set blog_id if username is different from blog_id" do
        @client = LivedoorBlogAtomPub::Client.new(@username, @api_key, blog_id: 'spider')
        expect( @client.instance_variable_get(:@blog_id) ).to eq 'spider'
      end
    end

    context "post_entry" do
      before do
        @username = 'john'
        @api_key  = 'ABCDEFG'
        server_host = "livedoor.blogcms.jp"
        path = "/atom/blog/#{@username}/article"
        WebMock.stub_request(:post, "http://" + server_host + path).to_return(
                  body: "created",
                  status: 201,
                  headers: { 'Content-Type' =>  'application/text' })
      end

      it "posts entry" do
        title = 'Hello'
        content = 'Atom World!'
        @client = LivedoorBlogAtomPub::Client.new(@username, @api_key)
        expect( @client.post_entry(title, content).code ).to eq 201
      end
    end
  end
end
