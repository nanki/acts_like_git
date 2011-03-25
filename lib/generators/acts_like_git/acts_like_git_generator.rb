require 'rails/generators/active_record/migration/migration_generator'

class ActsLikeGitGenerator < ActiveRecord::Generators::MigrationGenerator
  self.source_root superclass.source_root
  remove_argument :attributes

  def create_migration_file
    @migration_action = "add"
    @file_name = "add_version_field_to_#{table_name}"
    @attributes = [Rails::Generators::GeneratedAttribute.new("version", "string")]
    super
  end
end
