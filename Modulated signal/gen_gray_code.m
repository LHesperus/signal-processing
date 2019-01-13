%generate gray code,first data is 0 vector
%N>=2
%hint:
%0 => 0   0  => 00  10 =>00  => 00  00 => 0 00  1 00......
%1    1   1     01  11   01     01  01    0 01  1 01
%                        11     11  11    0 11  1 11
%                        10     10  10    0 10  1 10
%
function gray_code=gen_gray_code(N)
sub_gray=[0;1];
for n=2:N
    if N==2
        gray_code=sub_gray;
    elseif N>2
        top_gray=[zeros(1,2^(n-1))' sub_gray];
        bottom_gray=[ones(1,2^(n-1))' sub_gray];
        bottom_gray=bottom_gray(end:-1:1,:);
        sub_gray=[top_gray;bottom_gray];
    end
gray_code=sub_gray;
end
