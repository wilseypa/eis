function	[tf,f] = eis_tf_new(original_filename, start, stop)
% 
% function to process eit data from stroke patients
% 
% function	[tf,f] = eis_tf_new(original_filename, start, stop)
%
% original_filename: original filename of the EIS data
% Example:
% [tf,f] = eis_tf_new('Alferedo2011test1.bin',1,300);
%	 S. Iwaki	last modified 9/4/2006
%   G. Bonmassar  October 2011

detrend_kernel_length = 10; % [sec]

infilename = original_filename;

if (stop - start <= detrend_kernel_length*2)
  tmp = stop - start;
  stop = start + detrend_kernel_length*2;
end
cal = 470+470+5*98; % resistance of phantom
LFS = 100; %start low frequency
num_channels = 8;
sampling_freq = 100000; %[Hz]
HFS = sampling_freq/2; %start low frequency

%% Load data from the original binary file
% open original data file
fprintf(1, '%s: loading data...', infilename);
fid = fopen(infilename, 'r', 'b');
% read header
%num_channels = fread(fid, 1, 'single');  % skip header in the original data file
%sampling_freq = double(fread(fid, 1, 'single'));
fprintf(1, '%d channels sampled at %d [Hz]...\n', num_channels, sampling_freq);
% skip to start
skip_samples = start*sampling_freq;
fseek(fid, skip_samples*num_channels, 'cof');
% read data
fprintf(1, '\treading data %3.2f-%3.2f[sec]...', start, stop);
num_samples = (stop-start)*sampling_freq;
data = fread(fid, [num_channels,num_samples], 'single');  % change here for data format
fclose(fid);
data = single(data);
if (num_samples > size(data,2))
  num_samples = size(data,2);
  fprintf(1, '(actual duration %3.2f-%3.2f[sec])...', start, start+num_samples/sampling_freq);
end
fprintf(1, 'done\n')

detrend_fft_length = 2^(log2(detrend_kernel_length*sampling_freq));


%% Detrend original data
if 0
fprintf(1, 'detrending...\n');
ma = [ones(1,uint32(sampling_freq)) zeros(1,uint32(detrend_fft_length-sampling_freq))];
mafft = fft(ma);
clear('ma');
trend = zeros(1,num_samples);
for nch=1:num_channels
  count = 1;
  fprintf(1, '\tch. %d: ', nch);
  % calculate trends
  fprintf(1, 'calculating trends..');
  while (count + detrend_fft_length <= size(data,2))
    fprintf(1, '.');
    tmpdata = double(data(nch,count:count+uint32(detrend_fft_length-1)));
    y = fft(tmpdata);
    z = ifft(conj(mafft) .* y);
    trend(count:count+uint32(detrend_fft_length-sampling_freq)-1) = single(real(z(1:uint32(uint32(detrend_fft_length-sampling_freq))))/sampling_freq);
    count = count + uint32(detrend_fft_length - sampling_freq);
  end

  % subtract trends from original data
  fprintf(1, 'detrending...');
  data(nch,:) = single(data(nch,:) - trend);
  fprintf(1, 'done\n');
end
end
%% generate bipolar data
fprintf(1, 'calculating bipolar data...');

bipolar(1,:) = single(data(2,1:size(data,2)) - data(1,1:size(data,2))); % C4-F8
bipolar(2,:) = single(data(3,1:size(data,2)) - data(2,1:size(data,2))); % T6-C4
bipolar(3,:) = single(data(3,1:size(data,2)) - data(1,1:size(data,2))); % T6-F8
bipolar(4,:) = single(data(4,:)); % reference channel
bipolar(5,:) = single(data(5,1:size(data,2)) - data(6,1:size(data,2))); % T5-C3
bipolar(6,:) = single(data(6,1:size(data,2)) - data(7,1:size(data,2)));% C3-F7
bipolar(7,:) = single(data(5,1:size(data,2)) - data(7,1:size(data,2))); % T5-F7
bipolar(8,:) = single(data(8,1:size(data,2))); % stimulus channel
%clear('data', 'trend');
fprintf(1, 'done\n');

%% Transfer function calculation
fprintf(1,'calculating transfer function...\n');
% window_length = 65536;  % [samples]
window_length = 65536/16;  % [samples]
stim_ch = 8;
stim_ref_ch = 4;
fft_length = window_length;
noverlap = fft_length/2;
fprintf(1, '\tch. ');
for nch=[1,2,3,5,6,7]
  fprintf(1, '%d...', nch);
  [temp,f] = tfestimate(bipolar(stim_ch,:),bipolar(nch,:), hanning(fft_length), .5, fft_length, sampling_freq);
  tf(nch,:) = cal*temp';
end
fprintf(1, 'done\n');
for i=[1,2,3,5,6,7],
    tf(i,:)=tf(i,:)/tf(i,LFS);
end

leg=['C4-F8';'T6-C4';'T5-C3';'C3-F7';'T6-F8';'T5-F7'];
ch=[1,2,3,5,6,7]
figure
loglog(f(LFS:end),abs(real(tf(ch,LFS:end))))
legend('C4-F8','T6-C4','T5-C3','C3-F7','T6-F8','T5-F7')
axis([0.1 45000 0.1 5])
grid on
tit=sprintf('Impedance (Real Part) - %s\n',infilename);
title(tit)
figure
loglog(f(LFS:end),abs(imag(tf(ch,LFS:end))))
legend('C4-F8','T6-C4','T5-C3','C3-F7','T6-F8','T5-F7')
axis([1000 45000 0.00001 50])
tit=sprintf('Impedance (Imaginary Part) - %s\n',infilename);
title(tit)
grid on
if 0
for t=1:6,
    figure
    plot(tf(ch(t),:))
    title(sprintf('Nyquist Plot of %s',leg(t,LFS:end)))
end
end
