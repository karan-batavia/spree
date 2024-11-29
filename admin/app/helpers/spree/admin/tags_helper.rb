module Spree
  module Admin
    module TagsHelper
      def tags_scope
        @tags_scope ||= ActsAsTaggableOn::Tag.for_context(:tags)
      end

      def tags_json_array
        @tags_json_array ||= tags_scope.pluck(:id, :name).map { |id, name| { id: id, name: name } }.as_json
      end
    end
  end
end
