module VirtualColumnService
    class GetSimilarityScore < ApplicationService

        def initialize(model, string, attribute_names)
            @model = model
            @string = string
            @attribute_names = attribute_names
        end

        def call
            get_where_indicators
            return @model
            .select(@where_indicator)
        end

        private

        def get_where_indicators
            @where_indicator = "`#{@model.table_name}`.*, MATCH(#{@attribute_names.map {|attribute_name| "#{attribute_name}"}.join(", ")}) AGAINST ('#{@string}' IN NATURAL LANGUAGE MODE) as score"
        end

    end

end