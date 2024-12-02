figure
plot(x_probe1,time_component_probe1,'r','LineWidth', 1.5);
hold on; 
plot(x_probe1(locs_probe1), pks_probe1, 'ko');
hold on
% scatter(iEMGuse, ones(length(iEMGuse),1), 1000000,'|')
% hold on
plot(x_probe2,time_component_probe2,'g','LineWidth', 1.5);
hold on; 
plot(x_probe2(locs_probe2), pks_probe2, 'ko');
hold on;

%% 绘制iEMG激活序列右侧的阴影区域
fsampu = 1000; % 采样率
data = importdata(['iEMG_S1_M1_level2_trial1_24-06-21_UUS_new.eaf']); % 读取eaf文件
muNum = max(data.data(:,2)); % MU的个数
iPulses_1000 = {};
for mu = 1:muNum
    % iPulses就是这个eaf文件里分解得到的spike train，每个cell表示一个MU，里面的数字是该MU每次放电的时刻
    iPulses_1000{mu} = round(data.data(find(data.data(:,2)==mu),1)'*fsampu); 
end


x_positions_raw = iPulses_1000{1,1}; %iEMG的激活MUAPT
% % 补偿超声信号的时间延迟
% for i = 1:10000
% x_positions_raw(x_positions_raw > (i-1) & x_positions_raw <= i) = x_positions_raw(x_positions_raw > (i-1) & x_positions_raw <= i) - i*4.3/10000*2;
% end

x_Index_left=3*fsampu;
x_Index_right=13*fsampu;
x_positions = x_positions_raw((x_positions_raw > x_Index_left) & (x_positions_raw < x_Index_right)) - x_Index_left;


%figure
for i = 1:length(x_positions)
x_probe3 = x_positions(i);
line_style = 'm--';
h2 = plot([x_probe3, x_probe3], ylim, line_style,'LineWidth', 1.2); % 绘制虚线
hold on; 
% 创建对应的阴影区域
flag_shadow=true;
shadow_width=30;

if flag_shadow
x_end = x_probe3 + shadow_width; % 阴影区域的结束x坐标位置
y_bottom = min(ylim); % 阴影区域的底部
y_top = max(ylim); % 阴影区域的顶部
rectangle('Position', [x_probe3, y_bottom, shadow_width, y_top - y_bottom], 'FaceColor', [0.7, 0.7, 0.7], 'EdgeColor', 'none');
hold on
end
end
xlim([0,10000]);
hold off;
xlabel('Time(s)')
ylabel('Velocity')
set(gca, 'YTick', []);