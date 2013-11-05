require 'uploadcare/rails/file'

module Uploadcare
  module Rails
    module ActiveRecord
      @@UUID_REGEX = /[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}/i

      def is_uploadcare_file attribute, options = {}
        options.symbolize_keys!
        opts = {
          autostore: true,
          force_autostore: false
        }.update options

        define_method "#{attribute}" do
          cdn_url = attributes[attribute.to_s].to_s
          return nil if cdn_url.empty?

          if instance_variable_defined?("@#{attribute}_cached")
            instance_variable_get("@#{attribute}_cached")
          else
            api = ::Rails.application.config.uploadcare.api
            file_data = File.new(api, cdn_url)
            instance_variable_set("@#{attribute}_cached", file_data)
            # file_data
            OpenStruct.new :cdn_url => file_data.cdn_url, :uuid =>file_data.uuid
          end
        end

        if opts[:autostore]
          after_save "store_#{attribute}"

          define_method "store_#{attribute}" do
            matched = @@UUID_REGEX.match(attributes[attribute.to_s])
            return unless matched && matched[0]

            uuid = matched[0]

            stored = ::Rails.cache.exist?(
              "uploadcare.file.#{uuid}.store",
              force: opts[:force_autostore]
            )

            unless stored
              begin
                send(attribute).api.store
                ::Rails.cache.write("uploadcare.file.#{uuid}.store", true)
              rescue ArgumentError => e

                logger.error "\nError while saving a file: #{e.class} (#{e.message}):"
                logger.error "#{::Rails.backtrace_cleaner.clean(e.backtrace).join("\n ")}"

                raise e unless ::Rails.application.config.uploadcare.silence_save_errors
              end
            end
          end
        end
      end
    end
  end
end

ActiveRecord::Base.extend Uploadcare::Rails::ActiveRecord
