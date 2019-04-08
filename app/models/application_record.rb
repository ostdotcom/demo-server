class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  self.establish_connection( YAML.load( ERB.new( File.read( "#{Rails.root}/config/database.yml" )).result)[Rails.env])
end
