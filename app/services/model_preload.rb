class ModelPreload < ApplicationService

    def initialize(model, predictor)
        @model = model.where(predictor)
    end

    def call(indicator)
        indicator_array = indicator.map {|k, v| {"#{k}": v}}
        @result = @model.select{ |entity|
            select_indicator = indicator_array.inject(true) {|cum, entry| 
                cum &&
                (entity[entry.keys[0]] == entry[entry.keys[0]])
            }
        }
        if (@result.instance_of? Array) && @result.length==0
            nil
        elsif (@result.instance_of? Array) && @result.length==1
            @result[0]
        else
            @result
        end
    end
end
