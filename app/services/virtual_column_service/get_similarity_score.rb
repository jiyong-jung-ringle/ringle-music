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
            return @model
            .select(@select_indicator)
        end

        private

        def get_score_indicators
            @score_indicators = @attribute_names.map {|attribute_name| score_indicator(attribute_name)}.join("+")
        end

        def score_indicator(attribute_name)
            "((#{attribute_name} LIKE '%#{@string}%')+('#{@string}' LIKE CONCAT('%', #{attribute_name}, '%'))+(#{attribute_name} LIKE '#{@string}'))/3"
        end

        def get_select_indicator
            @select_indicator = "`#{@model.table_name}`.*, #{@score_indicators} as score"
        end

    end

end