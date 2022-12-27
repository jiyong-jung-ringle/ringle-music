module Feed
    class OrderedModelGetter < ApplicationService

        def initialize(model, filter, keyword, attribute_names)
            @model = model
            @keyword = keyword
            @filter = filter
            @attribute_names = attribute_names
        end

        def call
            get_order
            return @model_ordered
        end

        private
        def get_order
            @order = (@keyword!=nil && @keyword!="") ?
                case @filter
                when OrderFilterStatus::RECENT
                    {created_at: :desc, likes_count: :desc}
                when OrderFilterStatus::POPULAR
                    {likes_count: :desc, created_at: :desc}
                else
                    {score: :desc, created_at: :desc, likes_count: :desc}
                end
            :
                case @filter
                when OrderFilterStatus::RECENT
                    {created_at: :desc, likes_count: :desc}
                when OrderFilterStatus::POPULAR
                    {likes_count: :desc, created_at: :desc}
                else
                    {created_at: :desc, likes_count: :desc}
                end
            @model_ordered = ((@keyword!=nil && @keyword!="") ? VirtualColumn::GetSimilarityScore.call(@model, @keyword, @attribute_names) : @model).order(@order)
        end
    end

end