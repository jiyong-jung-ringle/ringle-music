module FeedService
  class SearchkickModelGetter < ApplicationService
    def initialize(model, keyword = nil, filter, accepted_filters, attribute_names, limit, page_number)
      @model = model
      @keyword = keyword.present? && filter == OrderFilterStatus::EXACT ? ActiveRecord::Base.connection.quote(keyword.squish) : nil # Prevent SQL injection
      @filter = filter
      @accepted_filters = accepted_filters
      @attribute_names = attribute_names
      @limit = limit
      @page_number = page_number
    end

    def call
      check_attributes
      get_order
      get_scoring_model_ids
      get_ordered_model
    end

      private
        def check_attributes
          @has_created_at = @accepted_filters.include?(OrderFilterStatus::RECENT)
          @has_likes_count = @accepted_filters.include?(OrderFilterStatus::POPULAR)
        end

        def get_order
          @order = case @filter
                   when OrderFilterStatus::RECENT
                     {}.merge!(@has_created_at ? { created_at: :desc } : {}, @has_likes_count ? { likes_count: :desc } : {})
                   when OrderFilterStatus::POPULAR
                     {}.merge!(@has_likes_count ? { likes_count: :desc } : {}, @has_created_at ? { created_at: :desc } : {})
                   else
                     {}.merge!(@has_likes_count ? { likes_count: :desc } : {}, @has_created_at ? { created_at: :desc } : {})
          end
        end

        def get_scoring_model_ids
          searchkick_model = @model.search(@keyword ? @keyword : "*", fields: @attribute_names,
            limit: @limit, offset: @limit * @page_number, order: (@keyword ? { _score: :desc } : {}).merge!(@order))
          @total_count = searchkick_model.total_count
          @scoring_mdoel_ids = searchkick_model.map(&:id)
        end

        def get_ordered_model
          {
            total: @total_count,
            model: @model.where(id: @scoring_mdoel_ids).order(Arel.sql("(field(id, #{@scoring_mdoel_ids.join(',')}))"))
          }
          end
  end
end
