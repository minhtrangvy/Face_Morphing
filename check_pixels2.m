function [ a, b ] = check_pixels2( x, y, h, w )
    if (x < 0)
        a = 0;
    elseif (x > h)
        a = h;
    end
    if (y < 0)
        b = 0;
    elseif (y > w)
        b = w;
    end
    a = x;
    b = y;
end

