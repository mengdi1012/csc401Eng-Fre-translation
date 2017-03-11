function evalALign()
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
% if exist(fn_LME,'file')==0
   LME = lm_train( trainDir, 'e', fn_LME );
% else 
%    load(fn_LME,'-mat','LM');
%    LME = LM;
% end

% if exist(fn_LMF,'file')==0
%    LMF = lm_train( trainDir, 'f', fn_LMF );
% else
%    load(fn_LMF,'-mat','LM');
%    LFM = LM;
% end
% Train your alignment model of French, given English
% if exist(fn_AM,'file')==0
    AMFE = align_ibm1( trainDir, numSentences, 10,fn_AM );
% else
%    load(fn_AM, '-mat','AM');
%    AMFE = AM;
% end
% ... TODO: more 

% TODO: a bit more work to grab the English and French sentences. 
%       You can probably reuse your previous code for this  

vocabSize    = length(fieldnames(LME.uni)); 
% Decode the test sentence 'fre

fre_sents = textread([testDir, filesep, 'Task5.f'], '%s','delimiter','\n');
sent_num = length(fre_sents);
eng_sents = cell(sent_num);
for i=1:sent_num
    fre = preprocess(fre_sents{i},'f');
    eng = decode2( fre, LME, AMFE, lm_type, delta, vocabSize );
    eng = regexprep(eng,' NULL( NULL)* ',' ');
    eng_sents{i} = eng;
    disp(fre);
    disp(eng);
end
% TODO: perform some analysis
% add BlueMix code here 
getBluemix('/u/cs401/A2_SMT/data/Hansard/Testing/Task5.f','Task5.ref3.e');
ref3 = textread( 'Task5.ref3.e', '%s','delimiter','\n');
ref1 = textread([testDir, filesep, 'Task5.e'], '%s','delimiter','\n');
ref2 = textread([testDir, filesep, 'Task5.google.e'], '%s','delimiter','\n');
avgbleu = cell(1,3);
avgbleu{1} = 0;
avgbleu{2} = 0;
avgbleu{3} = 0;

for i=1:sent_num
    r1 = strsplit(' ',preprocess(ref1{i},'e'));
    r2 = strsplit(' ',preprocess(ref2{i},'e'));
    r3 = strsplit(' ',preprocess(ref3{i},'e'));
    cand = strsplit(' ',eng_sents{i});
    fprintf('sentence %2d, ',i);
    for n = 1:3
        bleu = bleu_score(cand, {r1, r2,r3}, n);
        fprintf('bleu_n:%d = %.4f ',n,bleu);  
        avgbleu{n} = avgbleu{n} + (bleu/sent_num);
    end 
    fprintf('\n');
end
disp(avgbleu);


%[status, result] = unix('');

end

function bleu = bleu_score(cand, refs, n)
   n_ref = length(refs);
   lref = cell(n_ref);
   for i=1:n_ref
      lref{i} = length(refs{i});
   end
   lcand = length(cand);
   bestlen = lref{1};
   for i=2:n_ref
     if abs(lcand-bestlen) >= abs(lcand-lref{i})
         bestlen = lref{i}; 
     end 
   end
   brevity = bestlen/lcand;
   if brevity >= 1
     bp = exp(1-brevity);
   else
     bp = 1;
   end
   
   ngrams_ref = cell(n);
   for i=1:n
      ngrams_ref{i} = get_ngram(refs{1},i);
      for j=2:n_ref
         tmp = fieldnames(get_ngram(refs{j},i));
         for k=1:length(tmp)
             if ~isfield(ngrams_ref{i},tmp{k})
                ngrams_ref{i}.(tmp{k}) = 1;
             end
         end
      end
   end

   p = 1;
   for i=1:n
      c = 0;
      ngrams = get_ngram(cand,i);
      tmp = fieldnames(ngrams);
      for j=1:length(tmp)
         x = tmp{j};
         if isfield(ngrams_ref{i},x)
            c = c + ngrams.(x);
         end  
      end
      pn = c / (length(cand) - (i-1)); 
      p = p * pn;
   end
   
   bleu = bp*power(p,1/n);
end

function ngrams = get_ngram(words, n)
   ngrams = {};
   for i=1:length(words) + 1 - n
      ww = words{i};
      for j=2:n
         ww = strcat(ww, '__', words{i+j-1});
      end
      if isfield(ngrams,ww)
          ngrams.(ww) = ngrams.(ww) +1;
      else
          ngrams.(ww) = 1;
      end
   end
end