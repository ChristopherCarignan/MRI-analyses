function [ nasaltracks ] = nasal_tracks(artsigs,mrinfo)

speaker = mrinfo.speaker;

nasaltracks = {};
x = 1;

for i = 1:length(mrinfo.trial2)
    item = char(mrinfo.item(mrinfo.trial2(i)));
    
    prev = char(mrinfo.prev(i));
    
    vowel = char(mrinfo.vowel(i));
    
    post = char(mrinfo.post(i));
    
    nasality = char(mrinfo.nasality(i));
    
    mystr = strsplit(item,'_');
    
    if length(mystr) > 3
        include = 0;
    else
        include = 1;
    end
    
    stress = char(mrinfo.stress(i));
    
    start_f = mrinfo.start(mrinfo.trial2(i)).vframe;
    end_f = mrinfo.end(mrinfo.trial2(i)).vframe;
    
    nassig1 = artsigs.velum1(start_f:end_f);
    nassig2 = artsigs.velum2(start_f:end_f);
    alvsig = artsigs.alv(start_f:end_f);
    palsig = artsigs.pal(start_f:end_f);
    velarsig = artsigs.velar(start_f:end_f);
    hypersig = artsigs.hyperph(start_f:end_f);
    hyposig = artsigs.hypoph(start_f:end_f);
    
    for j = 1:length(nassig1)
        nasaltracks{x,1} = include;
        nasaltracks{x,2} = speaker;
        
        if length(stress) == 1
            nasaltracks{x,3} = mystr{1};
            nasaltracks{x,4} = mystr{2};
        else
            nasaltracks{x,3} = '?';
            nasaltracks{x,4} = '?';
        end
        
        nasaltracks{x,5} = nasality;
        
        nasaltracks{x,6} = prev;
        nasaltracks{x,7} = vowel;
        nasaltracks{x,8} = post;
        
        nasaltracks{x,9} = i;
        nasaltracks{x,10} = x;
        
        nasaltracks{x,11} = nassig1(j);
        nasaltracks{x,12} = nassig2(j);
        
        nasaltracks{x,13} = alvsig(j);
        
        nasaltracks{x,14} = palsig(j);
        
        nasaltracks{x,15} = velarsig(j);
        
        nasaltracks{x,16} = hypersig(j);
        
        nasaltracks{x,17} = hyposig(j);
        
        nasaltracks{x,18} = (j - 1)/(length(nassig1) - 1);
        
        x = x+1;
    end
end
end