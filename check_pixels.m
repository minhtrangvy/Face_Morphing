function [ a, b ] = check_pixels( x, y, h, w, r, c )
    if (x > 0) && (x < h) && (y > 0) && (y < w)
        a = x;
        b = y;
    else
        a = r;
        b = c;
    end 
end

