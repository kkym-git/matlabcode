function mat2ann(ann,filename)
%mat2ann 将2列mat数据转换成ann数据
%   原理：先将mat文件转换成空格间隔的txt文件，之后重写成ann文件
%   ann: 2列的数据
%   filename 文件名

fileID = fopen('mat2anntmp.txt', 'wt');
% 检查文件是否成功打开
if fileID == -1
    error('File cannot be opened');
end
% 遍历数组的每一行
for row = 1:size(ann, 1)
    % 写入当前行的两个数字，用空格分隔
    fprintf(fileID, '%g %g\n', ann(row, 1), ann(row, 2));
end
% 关闭文件
fclose(fileID);

originalFileName = 'test.txt';
% 新文件名
newFileName = filename;
% 重命名文件
movefile(originalFileName, newFileName);


end