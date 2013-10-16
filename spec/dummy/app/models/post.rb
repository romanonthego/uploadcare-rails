class Post < ActiveRecord::Base
  is_uploadcare_file :file
end
