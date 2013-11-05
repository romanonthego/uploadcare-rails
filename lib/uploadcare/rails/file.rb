module Uploadcare
  module Rails
    class File < OpenStruct

      attr_reader :uuid
      alias_method :file_id, :uuid

      def initialize(api, cdn_url)
        @api = api
        @cdn_url = cdn_url
        @uuid = @api.uuid(cdn_url)
        super uuid: @uuid, cdn_url: @cdn_url
      end

      def cdn_url(*operations)
        @api.cdn_url(@cdn_url, *operations)
      end

      alias_method :public_url, :cdn_url

      def api
        @file ||= @api.file(@cdn_url)
      end

      alias_method :info, :api

      def to_json
        marshal_dump
      end
    end
  end
end
