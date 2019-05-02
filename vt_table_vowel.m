function [ vttable ] = vt_table_vowel(apertures,mrinfo)

mypath = mrinfo.path;
filename = mrinfo.filename;
speaker = mrinfo.speaker;

eval(strcat('load(''',mypath,filename,'_cut_tg_code_table.mat'')'));
sampa = label;
sampanums = data(:,1);

eval(strcat('load(''',mypath,filename,'_cut_tg.mat'')'));

vttable = {};
x = 1;

resolution = 1.4118^2;

for i = 1:length(sampanums)
    item = sampanums(i);
    
    sampastr = sampa(i,:);
    
    prev = sampastr(1:3);
    prev = erase(prev,'_');
    
    vowel = sampastr(4:5);
    vowel = erase(vowel,'_');
    
    post = sampastr(6:8);
    post = erase(post,'_');
    
    if contains(post,'n') || contains(post,'m') || contains(post,'N')
        nasality = 'nasal';
    else
        nasality = 'oral';
    end
    
    timepoints = data(data(:,4)==item,:);
    strdat = label(data(:,4)==item,:);
    
    mystr = strdat(1,:);
    mystr = strsplit(mystr,'_');
    
    if length(mystr) > 3 || strcmp(sampastr(10),'n')
        include = 0;
    else
        include = 1;
    end
    
    sizes = cellfun('length', mystr);
    [~,stress] = min(sizes);
    
    start_f = mrinfo.start(item).vframe;
    end_f = mrinfo.end(item).vframe;
    
    theseaps = apertures(start_f:end_f,:);

    for k = 1:size(theseaps,1)
        for j = 1:size(theseaps,2)
            vttable{x,1} = include;
            vttable{x,2} = speaker;
            
            if sizes(stress) == 1
                vttable{x,3} = mystr{stress-1};
                vttable{x,4} = mystr{stress};
            else
                vttable{x,3} = '?';
                vttable{x,4} = '?';
            end
            
            vttable{x,5} = nasality;
            
            vttable{x,6} = prev;
            vttable{x,7} = vowel;
            vttable{x,8} = post;
            
            vttable{x,9} = i;
            vttable{x,10} = x;
            vttable{x,11} = j;
            vttable{x,12} = (k - 1)/(size(theseaps,1) - 1);
            
            vttable{x,13} = resolution*theseaps(k,j);
            
            x = x+1;
        end
    end
end
end