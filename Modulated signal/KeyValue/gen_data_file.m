function gen_data_file(data,filename)
    fid = fopen(filename,'w');

    for ii=1:size(data,2)
        fprintf(fid,'%f \t ',data(ii)); 
        fprintf(fid,'\r\n');  % »»ÐÐ  
    end
    fclose(fid);
end