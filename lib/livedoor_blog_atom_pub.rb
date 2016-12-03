require "livedoor_blog_atom_pub/version"
require 'wsse'

module LivedoorBlogAtomPub
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
  end
end
