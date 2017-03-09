%
% evalAlign
%
%  This is simply the script (not the function) that you use to perform your evaluations in 
%  Task 5. 

% some of your definitions
trainDir     = '/u/cs401/A2_SMT/data/Hansard/Training';
testDir      = '/u/cs401/A2_SMT/data/Hansard/Testing';
fn_LME       = 'LM_E';
fn_LMF       = 'LM_F';
lm_type      = 'smooth';
delta        = 0.5;
numSentences = 1000;
fn_AM = strcat('AM_FE',num2str(numSentences));

% Train your language models. This is task 2 which makes use of task 1
if exist(fn_LME,'file')==0
   LME = lm_train( trainDir, 'e', fn_LME );
else 
   load(fn_LME,'-mat','LME'); 
end
if exist(fn_LMF,'file')==0
   LMF = lm_train( trainDir, 'f', fn_LMF );
else
   load(fn_LMF,'-mat','LMF');
end

% Train your alignment model of French, given English
if exist(fn_AM,'file')==0
   AMFE = align_ibm1( trainDir, numSentences, 10,fn_AM );
else
   load(fn_AM, '-mat','AMFE');
end
% ... TODO: more 

% TODO: a bit more work to grab the English and French sentences. 
%       You can probably reuse your previous code for this  

vocabSize    = length(fieldnames(LME.uni)); 
% Decode the test sentence 'fre

fre_sents = textread([testDir, filesep, 'Task5.f'], '%s','delimiter','\n');
eng_sent = cell(length(fre_sents));
num = length(fre_sents);
for i=1:length(fre_sents)
    fre = preprocess(fre_sents{i},'f');
    eng = decode2( fre, LME, AMFE, 'smooth', delta, vocabSize );
    eng_sent{i} = eng;
    disp(fre);
    disp(eng);
end

% TODO: perform some analysis
% add BlueMix code here 
ref1 = textread([testDir, filesep, 'Task5.e'], '%s','delimiter','\n');
ref2 = textread([testDir, filesep, 'Task5.google.e'], '%s','delimiter','\n');
avgbleu = 0;

for i=1:num
    can = eng_sents{i};
    lcan = length(can);
    r1 = preprocess(ref1{i},'e');
    r2 = preprocess(ref2{i},'e');
    lr1 = length(r1);
    lr2 = length(r2);
    if abs(lcan-lr1) >= abs(lcan-lr2)
        brevity = lr2/lcan;
    else
        brevity = lr1/lcan;
    end   
    if brevity >= 1
       Bp = exp(1-brevity);
    else
       Bp = 1;
    end
    ngrams_r1 = ngram(r1);
    ngrams_r2 = ngram(r2);
    ngrams_can = ngram(can);
    c = 0;
    uni = fieldnames(ngrams_can.uni);
    for j=1:length(uni)
        x = uni{j};
        if isfield(ngrams_r1.uni,x) || isfield(ngrams_r2.uni,x)
            c = c + ngrams_can.uni.(x);
        end  
    end
    p1 = c/lcan;
    
    c = 0;
    bi = fieldnames(ngrams_can.bi);
    for j=1:length(bi)
        x = bi{j};
        if isfield(ngrams_r1.bi,x) || isfield(ngrams_r2.bi,x)
            disp(x);
            c = c + ngrams_can.bi.(x);
        end  
    end
    p2 = c/(lcan -1);
    
    c = 0;
    tri = fieldnames(ngrams_can.tri);
    for j=1:length(tri)
        x = tri{j};
        if isfield(ngrams_r1.tri,x) || isfield(ngrams_r2.tri,x)
            c = c + ngrams_can.tri.(x);
        end  
    end
    p3 = c/(lcan-2); 
    
    bleu = Bp*power((p1*p2*p3),(1/3));
    avgbleu = avgbleu + (bleu/num);

end
disp(avgbleu);




[status, result] = unix('');

function ngrams = ngram(sent)
   ngrams = struct()
   ngrams.uni = struct();
   ngrams.bi = struct();
   ngrams.tri = struct();
   
   words = strsplit(' ', sent);
   for w=1:length(words)
       w1 = words{w};
       if isfield(ngrams.uni,w1)
           ngrams.uni.(w1) = ngrams.uni.(w1) + 1;
       else
           ngrams.uni.(w1) = 1;
       end
       if w < length(words)
           w2 = words{w+1};
           if isfield(ngrams.bi,w1) && isfield(ngrams.bi.(w1),w2)
               ngrams.bi.(w1).(w2) = ngrams.bi.(w1).(w2) + 1;
           else
               ngrams.bi.(w1).(w2) = 1;
           end
       end
       if w < (length(words)-1)
           w3 = words{w+2};
           if isfield(ngrams.tri,w1) && isfield(ngrams.tri.(w1),(w2)) ...
                   && isfield(ngrams.tri.(w1).(w2),w3)
               ngrams.tri.(w1).(w2).(w3) = ngrams.tri.(w1).(w2).(w3) + 1;
           else
               ngrams.tri.(w1).(w2).(w3) = 1;
           end
       end
   end
end