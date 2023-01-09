module VirtualColumnService
  class GetSimilarityScore < ApplicationService
    def initialize(model, string, attribute_names)
      @model = model
      @sanitized_string = ActiveRecord::Base.connection.quote(string.squish) # Prevent SQL injection
      @attribute_names = attribute_names
    end

    def call
      get_score_indicators
      get_select_indicator
      get_scoring_model
    end

      private
        def get_score_indicators
          @score_indicators = @attribute_names.map { |attribute_name| score_indicator(attribute_name) }.join("+").squish
        end

        def score_indicator(attribute_name)
          """(LOWER(#{attribute_name}) SOUNDS LIKE LOWER(#{@sanitized_string}))/4 +
            (
                (LOWER(#{attribute_name}) LIKE LOWER(CONCAT('%', #{@sanitized_string}, '%'))) +
                (LOWER(#{@sanitized_string}) LIKE LOWER(CONCAT('%', #{attribute_name}, '%'))) +
                (LOWER(#{attribute_name}) LIKE LOWER(#{@sanitized_string}))
            )*3/4"""
        end

        def get_select_indicator
          @select_indicator = "#{@score_indicators} as score"
        end

        def get_scoring_model
          @model.select(@select_indicator)
        end
  end
end
