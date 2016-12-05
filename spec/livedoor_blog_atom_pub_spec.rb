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
                  headers: { 'Content-Type' =>  'application/atom+xml' })
      end

      it "posts entry" do
        title = 'Hello'
        content = 'Atom World!'
        @client = LivedoorBlogAtomPub::Client.new(@username, @api_key)
        expect( @client.post_entry(title, content).code ).to eq "201"
      end
    end

    context "upload_image" do
      before do
        @username = 'john'
        @api_key  = 'ABCDEFG'

        server_host = "livedoor.blogcms.jp"
        path = "/atompub/#{@username}/image"
        @local_image = LivedoorBlogAtomPub.root_path + '/spec/test.jpg'
        @image_url = 'http://example.com/test.jpg'
        @expected_url = 'http://livedoor.blogimg.jp/example/imgs/0/a/abcdefg.jpg'
        WebMock.stub_request(:post, "https://" + server_host + path).to_return(
                  body: "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<entry xmlns=\"http://www.w3.org/2005/Atom\"\n    xmlns:app=\"http://www.w3.org/2007/app\">\n\n    <title>no title</title>\n    <link rel=\"edit\" href=\"https://livedoor.blogcms.jp/atompub/example/image/01234567\" />\n    \n    <id>tag:.blogcms.jp,2016-12-05:image-.01234567</id>\n    <updated>2016-12-05T18:00:00+00:00</updated>\n    <author><name>example</name></author>\n    <content type=\"image/x-jpg\" src=\"#{@expected_url}\"/>\n</entry>\n",
                  status: 201,
                  headers: { 'Content-Type' =>  'application/atom+xml' })
        WebMock.stub_request(:get, @image_url).to_return(
                  body: File.open(@local_image),
                  status: 200,
                  headers: { 'Content-Type' =>  'image/jpg' })
      end

      it "upload image with url" do
        @client = LivedoorBlogAtomPub::Client.new(@username, @api_key)
        expect( @client.upload_image(image_url: @image_url) ).to eq @expected_url
      end

      it "upload image with file path" do
        @client = LivedoorBlogAtomPub::Client.new(@username, @api_key)
        expect( @client.upload_image(image_path: @local_image) ).to eq @expected_url
      end
    end
  end
end
