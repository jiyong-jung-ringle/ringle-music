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
            get_order
            return @model_ordered
        end

        private
        def check_attributes
            @has_created_at = @accepted_filters.include?(OrderFilterStatus::RECENT)
            @has_likes_count = @accepted_filters.include?(OrderFilterStatus::POPULAR)
        end

        def get_order
            order = {}
            @order = (@keyword!=nil && @keyword!="") ?
                case @filter
                when OrderFilterStatus::RECENT
                    order.merge!(created_at: :desc) if @has_created_at
                    order.merge!(likes_count: :desc) if @has_likes_count
                    order
                when OrderFilterStatus::POPULAR
                    order.merge!(likes_count: :desc) if @has_likes_count
                    order.merge!(created_at: :desc) if @has_created_at
                    order
                else
                    order.merge!(score: :desc)
                    order.merge!(likes_count: :desc) if @has_likes_count
                    order.merge!(created_at: :desc) if @has_created_at
                    order
                end
            :
                case @filter
                when OrderFilterStatus::RECENT
                    order.merge!(created_at: :desc) if @has_created_at
                    order.merge!(likes_count: :desc) if @has_likes_count
                    order
                when OrderFilterStatus::POPULAR
                    order.merge!(likes_count: :desc) if @has_likes_count
                    order.merge!(created_at: :desc) if @has_created_at
                    order
                else
                    order.merge!(created_at: :desc) if @has_created_at
                    order.merge!(likes_count: :desc) if @has_likes_count
                    order
                end
            @model_ordered = ((@keyword!=nil && @keyword!="") ? VirtualColumnService::GetSimilarityScore.call(@model, @keyword, @attribute_names) : @model).order(@order)
        end
    
    end
end