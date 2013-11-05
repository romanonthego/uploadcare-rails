module Uploadcare
  module Rails
    class File < OpenStruct

      attr_reader :uuid
      alias_method :file_id, :uuid

      def initialize(api, cdn_url)
        @api = api
        @cdn_url = cdn_url
        @uuid = @api.uuid(cdn_url)
      end

      def to_builder
        Jbuilder.new do |file|
          file.(self, :cdn_url, :uuid)
        end
      end

      def to_json
        {
          cdn_url: @cdn_url,
          uuid: @uuid
        }
      end

      def cdn_url(*operations)
        @api.cdn_url(@cdn_url, *operations)
      end

      alias_method :public_url, :cdn_url

      def api
        @file ||= @api.file(@cdn_url)
      end

      alias_method :info, :api

    end
  end
end
