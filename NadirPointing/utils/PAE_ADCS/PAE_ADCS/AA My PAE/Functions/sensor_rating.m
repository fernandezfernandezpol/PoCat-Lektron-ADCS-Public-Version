function [output]=sensor_rating (input,max,min,increment)

    for i=1:length(input)
        if input(i) >= max
            output(i) = max;
        else if input(i) <= min
                output(i)=min;
            else
                a1=input(i)/increment;
                if a1 >= 0
                    b1=floor(a1);
                else
                    b1 = floor(a1)+1;
                end
                output(i)=b1*increment;
            end
        end
    end

end
