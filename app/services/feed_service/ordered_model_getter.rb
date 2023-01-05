module FeedService
    class OrderedModelGetter < ApplicationService

        def initialize(model, keyword=nil, filter, accepted_filters, attribute_names)
            @model = model
            @keyword = keyword
            @filter = filter
            @accepted_filters = accepted_filters
            @attribute_names = attribute_names
        end

        def call
            check_attributes
            get_ordered_model
        end

        private
        def check_attributes
            @has_created_at = @accepted_filters.include?(OrderFilterStatus::RECENT)
            @has_likes_count = @accepted_filters.include?(OrderFilterStatus::POPULAR)
        end

        def get_ordered_model
            scoring_condition = @keyword.present? && @filter == OrderFilterStatus::EXACT
            order = case @filter
                when OrderFilterStatus::RECENT
                    {}.merge!(@has_created_at ? {created_at: :desc} : {}, @has_likes_count ? {likes_count: :desc} : {})
                when OrderFilterStatus::POPULAR
                    {}.merge!(@has_likes_count ? {likes_count: :desc} : {}, @has_created_at ? {created_at: :desc} : {})
                else
                    {}.merge!(scoring_condition ? {score: :desc} : {}, @has_likes_count ? {likes_count: :desc} : {}, @has_created_at ? {created_at: :desc} : {})
                end
            (scoring_condition ? VirtualColumnService::GetSimilarityScore.call(@model, @keyword, @attribute_names) : @model).order(order)
        end
    
    end
end