module ActsLikeGit
  module ActiveRecordExt
    module Base
      def self.extended(target)
        target.class_eval do
          class_inheritable_accessor :git_settings
        end
      end
      
      # Define the details for connecting to your git repository with this
      # method.  Without these details there will be no connection to a
      # git repository, which is the whole point of the plugin.
      #
      # An example:
      #
      #   versioning(:title, :body) do |v|
      #     v.repository = "/path/to/my/repository"
      #   end
      #
      def versioning(*fields, &block)
        return unless ActsLikeGit.versioning_enabled?
        
        include Callbacks, Git, VersionMethods
        ActsLikeGit.all_versioned_models |= [self.name] if ActsLikeGit.all_versioned_models
        
        self.git_settings ||= ModelInit.new(self, &block)
        git_settings.versioned_fields = [fields].flatten

        # Make sure we load all the methods, as well as any permalink-fu overriding of methods.
        define_attribute_methods
        
        self.git_settings.versioned_fields.each do |column|
          git_read_method = "def #{column}; read_git_method('#{column}'); end"          
          generated_attribute_methods.module_eval(git_read_method, __FILE__, __LINE__)
          
          git_write_method = "def #{column}=(val); write_git_method('#{column}', val); end"          
          generated_attribute_methods.module_eval(git_write_method, __FILE__, __LINE__)
        end
        
        after_save    :git_commit
        after_destroy :git_delete
      end
    end
  end
end
