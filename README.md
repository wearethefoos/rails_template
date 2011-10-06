# Rails template

## Features

  * Mongoid
  * Rspec
  * Cucumber
  * Devise + Cancan
  * Oauth with Facebook and Google login
  * Carrierwave
  * Fixes for Carrierwave and Mongoid nested documents
  
## Usage

Fork off and clone! 

Find and replace all `MyApp` occurences with `YourAppName`.

Also have a looksy in config/mongoid.yml and change the database names appropriately.

Enjoy :)

## Carrierwave fix for embedded documents

I fixed some issues with Carrierwave and embedded documents, mostly with code from the community.

### Embeds one example

With the fixes included in this template, you can easily use embedded uploaders, like so:

_(in `models/profile.rb`)_

```ruby
class Profile
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :name, :type => String
  field :about, :type => String
  field :user_id, :type => String
  
  embeds_one :photo
  accepts_nested_attributes_for :photo, :allow_destroy => true, :reject_if => :all_blank
  
  # Mount the embedded uploader
  mount_embedded_uploader :photo, :file
  
  belongs_to :user
  
end
```

### Embeds many example

If you have a model that embeds a lot of photos, however, the above will not work. You will need something like this:

_(in `models/post.rb`)_

```ruby
def Post
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :title
  field :body
  
  embeds_many :photos
  accepts_nested_attributes_for :photos, :allow_destroy => true
  
  after_save :save_photos
  
  # Save photos callback
  def save_photos
    photos.each do |photo|
      if photo.new_record? and photo.file.present?
        photo.save!
      end
    end
  end

  def _send_to_each_embedded_document(method, *args, &block)
    self.class.associations.each_pair do |name, meta|

      if meta.association == Mongoid::Associations::EmbedsMany
        assoc = self.send(name)
        assoc.each{|doc| doc.send(method, *args)} if assoc.present?

      elsif meta.association == Mongoid::Associations::EmbedsOne
        assoc = self.send(name)
        assoc.send(method, *args) if assoc.present?

      end
    end
  end


  # forward validation to embedded documents
  def valid?(*)
     _run_validation_callbacks { super }
     _send_to_each_embedded_document(:_run_validation_callbacks)
  end

  # bubble callbacks to embedded associations
  def run_callbacks(kind, *args, &block)

    parent_callback_result = super(kind, *args, &block)  # defer to parent

    # now bubble callbacks down
    _send_to_each_embedded_document(:run_callbacks, kind, *args, &block)

    parent_callback_result
  end
end
```