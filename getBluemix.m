function  getBluemix( filename1, filename2 )
    f1 = fopen(filename1,'r');
    f2 = fopen(filename2, 'w');
    while ~feof(f1)
        line = fgetl(f1);
        fprintf(f2,translate((line)));
        fprintf(f2, '\n');
    end
    fclose(f1);
    fclose(f2);
end

function res = translate(s)
    syscmd = sprintf('curl --fail --silent /dev/null -u 6edef9ec-2fb6-4eae-86dc-f5eaf3a68145:ZcBIEQn42MuH -X POST -F "text=%s" -F "source=french" -F "target=en" "https://gateway.watsonplatform.net/language-translator/api/v2/translate"', s);
    [~,res] = system(syscmd);
end
