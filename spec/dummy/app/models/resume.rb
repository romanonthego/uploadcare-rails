class Resume < ActiveRecord::Base
  is_uploadcare_file :attachment
end
