function outSentence = preprocess(inSentence, language )
%
%  preprocess
%
%  This function preprocesses the input text according to language-specific rules.
%  Specifically, we separate contractions according to the source language, convert
%  all tokens to lower-case, and separate end-of-sentence punctuation 
%
%  INPUTS:
%       inSentence     : (string) the original sentence to be processed 
%                                 (e.g., a line from the Hansard)
%       language       : (string) either 'e' (English) or 'f' (French) 
%                                 according to the language of inSentence
%
%  OUTPUT:
%       outSentence    : (string) the modified sentence
%
%  Template (c) 2011 Frank Rudzicz 

  global CSC401_A2_DEFNS
  
  % first, convert the input sentence to lower-case and add sentence marks 
  inSentence = [CSC401_A2_DEFNS.SENTSTART ' ' lower( inSentence ) ' ' CSC401_A2_DEFNS.SENTEND];

  % trim whitespaces down 
  inSentence = regexprep( inSentence, '\s+', ' '); 

  % initialize outSentence
  outSentence = inSentence;

  % perform language-agnostic changes
  % TODO: your code here
  %    e.g., outSentence = regexprep( outSentence, 'TODO', 'TODO');
  outSentence = regexprep(outSentence, '(\w|\d)([^\w\d]+) SENTEND', '$1 $2 SENTEND');
  outSentence = regexprep(outSentence,'([;!:=<>"#@%\?\*\$\^\+\(\)\[\]\{\}])',' $1 ');
  outSentence = regexprep(outSentence,'([^0-9]),','$1 , ');  % do not break such as 111,000
  outSentence = regexprep(outSentence,'(,([^0-9])',' , $1');
  outSentence = regexprep(outSentence,'(\d)-(\d)','$1 - $2');
  outSentence = regexprep(outSentence,'(\s)(\-)+',' $2 ');
  outSentence = regexprep(outSentence,'(\-)+(\s)',' $1 ');
  outSentence = regexprep(outSentence,'(''('')+)',' $1 ');  % ``...''
  outSentence = regexprep(outSentence,'(`(`)+)',' $1 ');  
  outSentence = regexprep(outSentence,'\s''(\w)',' '' $1');
  outSentence = regexprep(outSentence,'(\w)''\s','$1 '' ');
  switch language
   case 'e'
     outSentence = regexprep(outSentence,'(\w)''(\w)','$1 ''$2');
     outSentence = regexprep(outSentence,'n ''t',' n''t ');
   case 'f'
     outSentence = regexprep(outSentence,' (c|n|l|j|qu|t|puisqu|lorsqu)''([aeihyou])',' $1'' $2');
  end
  
  outSentence = regexprep( outSentence, '\s+', ' '); 

  % change unpleasant characters to codes that can be keys in dictionaries
 outSentence = convertSymbols( outSentence );

