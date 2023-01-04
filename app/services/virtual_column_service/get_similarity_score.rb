module VirtualColumnService
    class GetSimilarityScore < ApplicationService

        def initialize(model, string, attribute_names)
            @model = model
            @string = string
            @attribute_names = attribute_names
        end

        def call
            get_score_indicators
            get_select_indicator
            get_scoring_model 
        end

        private

        def get_score_indicators
            @score_indicators = @attribute_names.map {|attribute_name| score_indicator(attribute_name)}.join("+")
        end

        def score_indicator(attribute_name)
            "(LOWER(#{attribute_name}) SOUNDS LIKE LOWER('#{@string}'))/4 +
            ((LOWER(#{attribute_name}) LIKE LOWER('%#{@string}%'))+(LOWER('#{@string}') LIKE LOWER(CONCAT('%', #{attribute_name}, '%')))+(LOWER(#{attribute_name}) LIKE LOWER('#{@string}')))*3/4"
        end

        def get_select_indicator
            @select_indicator = "#{@score_indicators} as score"
        end

        def get_scoring_model
            @model.select(@select_indicator)
        end

    end

end