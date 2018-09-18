class Person < ApplicationRecord
  after_save :store_photo
    validates_presence_of :name
    validates_presence_of :secret, message: "must be provided so we can recognize you in the future"
    validates_length_of :secret, in: 6..24
    validates_format_of :secret, with: /[0-9]/, message: "must contain at least one number"
    validates_format_of :secret, with: /[A-Z]/, message: "must contain at least one upper case character"
    validates_format_of :secret, with: /[a-z]/, message: "must contain at least one lower case character"
    
    validates_inclusion_of :country, in: ['Canada', 'Mexico', 'UK', 'USA'],
    message: "must be one of Canada, Mexico, UK or USA"
    validates_format_of :email,
    with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i,
    message: "doesn't look like a proper email address"
    
    validates_uniqueness_of :email, case_sensitive: false,
    message: "has already been entered, you can't sign in twice"
    
    validates_uniqueness_of :email, case_sensitive: false,
    scope: [:name, :secret],
    message: "has already been entered, you can't sign in twice"
    
    validates_numericality_of :graduation_year, allow_nil: true,
    greater_than: 1920, less_than_or_equal_to: Time.now.year,
    only_integer: true
    
    validates_numericality_of :body_temperature, allow_nil: true,
    greater_than_or_equal_to: 60,
    less_than_or_equal_to: 130, only_integer: false

    validates_numericality_of :price, allow_nil: true,
    only_integer: false
  
    validates_inclusion_of :birthday,
    in: Date.civil(1900, 1, 1) .. Date.today,
    message: "must be between January 1st, 1900 and today"
  
    validates_presence_of :favorite_time
    
    validates_presence_of :description, if: :require_description_presence?
    
    validate :description_length_words
    
    def require_description_presence?
        self.can_send_email
    end
    
    
    
    def description_length_words
  unless self.description.blank? then
    num_words = self.description.split.length
    if num_words < 5 then
      self.errors.add(:description, "must be at least 5 words long")
    elsif num_words > 50 then
      self.errors.add(:description, "must be at most 50 words long")
    end
  end
end

# for later and assign the file extension, e.g., ".jpg"
def photo=(file_data)
  unless file_data.blank?
    # store the uploaded data into a private instance variable
    @file_data = file_data
    # figure out the last part of the filename and use this as
    # the file extension. e.g., from "me.jpg" will return "jpg"
    self.extension = file_data.original_filename.split('.').last.downcase
  end
end

# File.join is a cross-platform way of joining directories;
# we could have written "{Rails.root}/public/photo_store"
PHOTO_STORE = File.join Rails.root, 'public', 'photo_store'

# where to write the image file to
  def photo_filename
    File.join PHOTO_STORE, "#{id}.#{extension}"
  end

# return a path we can use in HTML for the image
  def photo_path
    "/photo_store/#{id}.#{extension}"
  end
  
  # if a photo file exists, then we have a photo
  def has_photo?
    File.exists? photo_filename
  end

private

# called after saving, to write the uploaded image to the filesystem
def store_photo
  if @file_data
    # make the photo_store directory if it doesn't exist already
    FileUtils.mkdir_p PHOTO_STORE
    # write out the image data to the file
    File.open(photo_filename, 'wb') do |f|
      f.write(@file_data.read)
    end
    # avoid repeat-saving
    @file_data = nil
  end
end

end
