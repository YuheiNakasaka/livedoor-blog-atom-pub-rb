require "livedoor_blog_atom_pub/version"
require 'wsse'
require 'uri'
require 'tempfile'
require 'base64'

module LivedoorBlogAtomPub
  def self.root_path
    File.dirname __dir__
  end

  class Client
    SERVER_HOST = "livedoor.blogcms.jp"
    def initialize(username, api_key, blog_id: nil)
      @username = username # required
      @api_key  = api_key # required
      @blog_id  = blog_id || @username # optional
    end

    def post_entry(title, content, categories: [], draft_flag: false)
      xml = generate_entry(title, content, categories: categories, draft_flag: draft_flag)
      http = Net::HTTP.start(SERVER_HOST)
      response = http.post("/atom/blog/#{@blog_id}/article", xml, {'X-WSSE' => WSSE::header(@username,  @api_key)})
    end

    # return image url as string
    def upload_image(image_path: nil, image_url: nil)
      if !image_path.nil? || !image_url.nil?
        image = image_path || image_url
        bin = read_image(image)
        ext = get_image_extension(bin)

        # use new AtomPub API
        # it's only ssl version
        https = Net::HTTP.new(SERVER_HOST, '443')
        https.use_ssl = true
        https.verify_mode = OpenSSL::SSL::VERIFY_NONE
        req = Net::HTTP::Post.new("/atompub/#{@blog_id}/image")
        req['Authorization'] = 'WSSE profile="UsernameToken"'
        req['X-WSSE'] = WSSE::header(@username,  @api_key)
        req['Content-Type'] = "image/#{ext}"
        req.body = bin
        response = https.request(req)
        # parse the reponse of xml style and fetch an image url
        url = response.body.match(/<content.+src="(.+)?"/)[1]
      end
    end

    private
    def generate_entry(title, content, categories: [], draft_flag: false)
      cat_name = nil
      draft = draft_flag ? "yes": "no"
      out = StringIO.new
      out.puts "<entry xmlns='http://www.w3.org/2005/Atom'"
      out.puts "    xmlns:app='http://www.w3.org/2007/app'"
      out.puts "    xmlns:blogcms='http://blogcms.jp/-/spec/atompub/1.0/'>"
      out.puts "    <title>#{title}</title>"
      out.puts "    <updated>#{Time.now.iso8601}</updated>"
      out.puts "    <published>#{Time.now.iso8601}</published>"
      out.puts "    <author><name>#{@username}</name></author>"
      out.puts "    <category scheme='http://livedoor.blogcms.jp/blog/#{@blog_id}/category' term='#{cat_name}' />" while cat_name = categories.shift
      out.puts "    <blogcms:source>"
      out.puts "        <blogcms:body><![CDATA[<p>#{content}</p>]]></blogcms:body>"
      out.puts "    </blogcms:source>"
      out.puts "    <app:control>"
      out.puts "        <app:draft>#{draft}</app:draft>"
      out.puts "    </app:control>"
      out.puts "</entry>"
      out.string
    end

    def read_image(image)
      if uri?(image)
        open(image).read
      else
        File.open(image).read
      end
    end

    def uri?(target)
      begin
        uri = URI.parse(target)
      rescue URI::InvalidURIError
        return false
      end
      uri.scheme =~ /^http/
    end

    # get file extension from binary
    # referenced from http://stackoverflow.com/a/16635245
    def get_image_extension(binary)
      png = Regexp.new("\x89PNG".force_encoding("binary"))
      jpg = Regexp.new("\xff\xd8\xff\xe0\x00\x10JFIF".force_encoding("binary"))
      jpg2 = Regexp.new("\xff\xd8\xff\xe1(.*){2}Exif".force_encoding("binary"))
      # if image read with File.open, the binary is utf-8 from Ruby 2.0
      case binary.force_encoding("binary")
      when /^GIF8/
        'gif'
      when /^#{png}/
        'png'
      when /^#{jpg}/
        'jpg'
      when /^#{jpg2}/
        'jpg'
      end
    end
  end
end
