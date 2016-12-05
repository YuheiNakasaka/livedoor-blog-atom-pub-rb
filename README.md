# LivedoorBlogAtomPub

This is a client library to use a Livedoor blog atom pub api.

A document of Livedoor blog atom pub api is available from [here](http://help.blogpark.jp/archives/52372407.html)

## Installation

```ruby
gem 'livedoor_blog_atom_pub'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install livedoor_blog_atom_pub

## Usage

### Initialize

####  Authentication

You can use only WSSE authentication in this library.

Username and api_key is required.

```ruby
@client = LivedoorBlogAtomPub::Client.new('username', 'your_api_key')
```

#### Set original blog id

This is optional.

When username is different from blog id

```ruby
@client = LivedoorBlogAtomPub::Client.new('yuhei', 'your_api_key', blog_id: 'other_id')
```

### Post

```ruby
@client.post_entry('Title', 'Content')
```

#### Set categories

```ruby
@client.post_entry('Title', 'Content', categories: ['cat1', 'cat2'])
```

#### Post as a draft version

```ruby
@client.post_entry('Title', 'Content', draft_flag: true)
```

### Upload image

Return a image url like  http://livedoor.blogimg.jp/example/imgs/0/a/abcdefg.jpg

#### Set a url

```ruby
@client.upload_image(image_url: 'http://example.com/1.jpg')
```

#### Set a local file path

```ruby
@client.upload_image(image_path: '/src/image/1.jpg')
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/YuheiNakasaka/livedoor_blog_atom_pub.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
