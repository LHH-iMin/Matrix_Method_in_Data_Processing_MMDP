function llr_mean= LLR(cleanFile, enhancedFile)
% ----------------------------------------------------------------------
%    Log likelihood Ratio(LLR) Objective Speech Quality Measure
%    This function implements the Log Likelihood Ratio Measure
%    defined on page 291(see Equation 14.3)
%    Usage: llr=LLR(cleanFile.wav,enhancedFile.wav)
%         cleanFile.wav -clean input file in .wav format
%         enhanced File  - enhanced output file in .wav format
%         llr           - computed likelihood ratio
%         Note that the LLR measure is limited in the range[0,2].
%  Example call:  llr =LLR('sp04.wav','enhanced.wav')
% ----------------------------------------------------------------------
if nargin~=2
fprintf('USAGE: LLR=LLR(cleanFile.wav, enhancedFile.wav)\n');
fprintf('For more help, type: help LLR\n\n');
return;
end
alpha=0.95;
[data1, Srate1]= audioread(cleanFile);
[data2, Srate2]= audioread(enhancedFile);
% if ( Srate1~= Srate2) | ( Nbits1~= Nbits2)
% error( 'The two files do not match!\n');
% end
len= min( length( data1), length( data2));
data1= data1( 1: len)+eps;
data2= data2( 1: len)+eps;
IS_dist= llr( data1, data2,Srate1);
IS_len= round( length( IS_dist)* alpha);
IS= sort( IS_dist);
llr_mean= mean( IS( 1: IS_len));
function distortion = llr(clean_speech, processed_speech,sample_rate)
% ----------------------------------------------------------------------
%Check the length of the clean and processed speech.Must be the same.
% ----------------------------------------------------------------------
clean_length      = length(clean_speech);
processed_length  = length(processed_speech);
if (clean_length ~= processed_length)
disp('Error: Both Speech Files must be same length.');
return
end
winlength   = round(30*sample_rate/1000); %240;		% window length in samples
skiprate    = floor(winlength/4);		% window skip in samples
if sample_rate<10000
   P           = 10;		   % LPC Analysis Order
else
    P=16;     % this could vary depending on sampling frequency.
end
% ----------------------------------------------------------------------
%  For each frame of input speech, calculate the Log Likelihood Ratio
% ----------------------------------------------------------------------
num_frames = clean_length/skiprate-(winlength/skiprate); % number of frames
start      = 1;					% starting sample
window     = 0.5*(1 - cos(2*pi*(1:winlength)'/(winlength+1)));
for frame_count = 1:num_frames
   % ----------------------------------------------------------
   % (1) Get the Frame for the test and reference speech.
   %   Multiply by Hanning Window
   % ----------------------------------------------------------
   clean_frame = clean_speech(start:start+winlength-1);
   processed_frame = processed_speech(start:start+winlength-1);
   clean_frame = clean_frame.*window;
   processed_frame = processed_frame.*window;
   % ----------------------------------------------------------
   % (2) Get the autocorrelation lags and LPC parameters used
%  to compute the LLR measure.
   % ----------------------------------------------------------
   [R_clean, Ref_clean, A_clean] = ...
lpcoeff(clean_frame, P);
   [R_processed, Ref_processed, A_processed] = ...
lpcoeff(processed_frame, P);
   % ----------------------------------------------------------
   % (3) Compute the LLR measure
   % ----------------------------------------------------------
numerator   = A_processed*toeplitz(R_clean)*A_processed';
denominator = A_clean*toeplitz(R_clean)*A_clean';
distortion(frame_count) = min(2,log(numerator/denominator));
start = start + skiprate;
end
function [acorr, refcoeff, lpparams] = lpcoeff(speech_frame, model_order)
   % ----------------------------------------------------------
   % (1) Compute Autocorrelation Lags
   % ----------------------------------------------------------
winlength = max(size(speech_frame));
for k=1:model_order+1
R(k) = sum(speech_frame(1:winlength-k+1) ...
		     .*speech_frame(k:winlength));
end
   % ----------------------------------------------------------
   % (2) Levinson-Durbin
   % ----------------------------------------------------------
   a = ones(1,model_order);
E(1)=R(1);
for i=1:model_order
      a_past(1:i-1) = a(1:i-1);
      sum_term = sum(a_past(1:i-1).*R(i:-1:2));
rcoeff(i)=(R(i+1) - sum_term) / E(i);
a(i)=rcoeff(i);
a(1:i-1) = a_past(1:i-1) - rcoeff(i).*a_past(i-1:-1:1);
E(i+1)=(1-rcoeff(i)*rcoeff(i))*E(i);
end
acorr    = R;
refcoeff = rcoeff;
lpparams = [1 -a];

