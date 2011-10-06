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

See below for an example uploader.

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

## Example uploader

_(in `models/photo.rb`)_

```ruby
require 'carrierwave/mongoid'

class Photo
  include Mongoid::Document
  
  field :caption, :type => String
  
  mount_uploader :file, PhotoUploader
  
  embedded_in :recipe
  embedded_in :post
  embedded_in :user
  
  validates_presence_of :file
end
```

_(in `uploaders/photo_uploader.rb`)_

```ruby
class PhotoUploader < CarrierWave::Uploader::Base

  # Include RMagick or ImageScience support:
  # include CarrierWave::RMagick
  include CarrierWave::MiniMagick
  # include CarrierWave::ImageScience

  # Choose what kind of storage to use for this uploader:
  # storage :file
  storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  process :resize_to_limit => [640, 640]
  process :convert => :png
  
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  version :thumb do
    process :convert => :png 
    process :resize_and_pad => [40, 40, :white]
  end
  
  version :small do
    process :convert => :png 
    process :resize_and_pad => [100, 100, :white]
  end
  
  version :medium do
    process :convert => :png 
    process :resize_and_pad => [460, 460, :white]
  end
  
  version :large do
    process :convert => :png 
    process :resize_and_pad => [640, 640, :white]
  end
  
  version :huge do
    process :convert => :png 
    process :resize_to_limit => [960, 960]
  end
      

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w(jpg jpeg gif png)
  end
  
  def filename
    if not super.nil?
      super.chomp(File.extname(super)) + '.png'
    end
  end

end
```