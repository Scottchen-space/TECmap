clc;
clear;
close all;

%  緯度跨-87.5到87.5 間隔2.5 71個緯度資料
%  經度跨-180到180 間隔2.5 73個緯度資料
lat = 87.5:-2.5:-87.5;
lon = -180:5:180; 

% 建立符合經緯尺寸的空矩陣
TEC = zeros(length(lat),length(lon),25);

% 開啟檔案設定讀取模式
data = fopen("COD0OPSFIN_20250010000_01D_01H_GIM.INX",'r');

lat_idx = 1;
map_idx = 1;

% 讀逐行資料
while ~feof(data)
    % 讀取一行
    tmp = fgetl(data);
    
    if contains(tmp,'LAT/LON1/LON2/DLON/H')
       tectmp = [];
        
        for i = 1:5
            tmp = fgetl(data);
            tectmp = [tectmp,sscanf(tmp, '%f')'];  % sscanf(欲解析之字串,'欲解析成的檔案格式')
        end
    TEC(lat_idx,:,map_idx) = tectmp;
    lat_idx = lat_idx+1;
    elseif contains(tmp, 'END OF TEC MAP')
        map_idx = map_idx + 1;
        lat_idx = 1;
        if map_idx > 25
            break;
        end
    end
end
fclose(data);


[xx, yy] = meshgrid(lon, lat);
zz = TEC*0.1;
load coastlines;  % 世界地圖

figure;
for t=1:25
    zz_tmp = zz(:,:,t);
    contourf(xx,yy,zz_tmp,100, 'LineStyle', 'none'); % contourf 填滿的等高線
    colormap('jet'); % jet指彩虹色（由藍色漸變至青色、黃色，最後到紅色）
    colorbar;
    clim([0 100]); % 統一色彩標準
    axis([-180, 180, -87.5, 87.5]); 
    axis equal;

    xlabel('Longitude [deg]');
    ylabel('Latitude [deg]');
    title(sprintf('Global Ionospheric Map - %02d:00 TEC Contour', t-1));
    hold on;
    
    plot(coastlon, coastlat, 'k', 'LineWidth', 1.5);
    pause(1);
    hold off;
end
