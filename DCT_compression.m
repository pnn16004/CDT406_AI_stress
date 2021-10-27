function y = DCT_compression(inputFilePath)
%DCT-based image compression and decompression algorithm

% Take a look at the image in 8-by-8 chunks
BlkSize = 8;
Blk = BlkSize - 1;
Blk2 = BlkSize / 2;

x = imread(inputFilePath);
[Rows, Cols, Ncolors] = size(x);

y = single(zeros(size(x)));

% Assume x dimensions are divisible by BlkSize

for k = 1:Ncolors % Loop through all colors
    for m = 1:BlkSize:Rows % Loop through all rows
        for n = 1:BlkSize:Cols % Loop through columns
            
        % Compress the image    
            
            % Construct a block DCT
            b = x(m:m + Blk, n:n + Blk, k);
            d = dct2(b);            %d = dct(dct((double(b))).').');
            c = d(1:Blk2, 1:Blk2);
            
            % Throw away extra DCT coefficients
            d(d < 1) = 0.0;
            d(1:Blk2, 1:Blk2) = c;
            
            
          % Decompress the image
            
            % Reconstruct lower-rank DCT and block image
            r = idct2(d);            % r = (idct(idct(d)')');
            y(m:m + Blk, n:n + Blk, k) = r;
            
        end % of n
    end % of m
end % of k