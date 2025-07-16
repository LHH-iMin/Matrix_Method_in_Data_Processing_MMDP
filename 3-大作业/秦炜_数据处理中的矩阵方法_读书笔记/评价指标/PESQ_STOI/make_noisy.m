%% 加噪声，调整输入信噪比，得到带噪语音
fs=8000;frame=512;fstep=128;
    pathstr='d:/';
    str1='libo*.wav';
    filelist = dir([pathstr filesep str1]);
    fileNames = {filelist.name};
    file_len=length(fileNames);
    a=0.3;
    for j=1:file_len
        IN_SNR=-1000000;
        fin0=fileNames{j};
        fin=[pathstr filesep fin0];
        clean=wavread(fin);
        le=length(clean);
        noi=noi_source(1:le);
%%设定希望输出信噪比的范围
        low=14;  %最低值
        hig=14.5;%最高值
       
        while IN_SNR>hig || IN_SNR<low
            if IN_SNR>hig
                a=a+0.001;
            elseif IN_SNR<low
                a=a-0.001;
            end
        noi2=noi*a;                     %后面的整数代表噪声的含量
        noisy=clean+noi2;               % 带噪语音生成
        [IN_SNR,SNRO,IN_segSNR,segSNRO,IN_LSD,LSDO,IN_PESQ,PESQ_O]=res_eva(clean,noi2,noisy,fs,frame,fstep);%%这里可以简化一下，只算信噪比即可
        end
        sn=strrep(num2str(IN_SNR,3),'.','-');
        fout0=strrep(fin0,'.wav',['_white_' sn 'db']);
        fout=['d:/' fout0];
        wavwrite(noisy,fs,fout);
    end
    