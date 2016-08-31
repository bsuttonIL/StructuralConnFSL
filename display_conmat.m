function display_conmat(CSVmat,rot)
%DISPLAY_CONMAT displays and rotates connectivity matrix tick labels
%   DISPLAY_CONMAT(H,ROT) is the calling form where H is a handle to
%   the axis that contains the XTickLabels that are to be rotated. ROT is
%   an optional parameter that specifies the angle of rotation. The default
%   angle is 90.
%
%   Use axis equal to get a square matrix if labels size is not an issue.
%
%   This script rotates the x-axis labels thanks to the ROTATETICKLABEL 
%   script written by Andy Bliss detailed at the end of this file.
%
%   Written Oct 30, 2013 by Michael Dayan (mdayan.research@gmail.com)

% Read connectivity matrix data
conmat = csvread(CSVmat,1,0);
% Read connectivity matrix labels (header)
fid = fopen(CSVmat);
conmat_header = strsplit(fgetl(fid),',');
fclose(fid);

% Display connectivity matrix 
% Set default rotation
if nargin==1
    rot=90;
end
figure, imagesc(conmat)
set(gca,'Xtick',1:size(conmat,1),'YTick',1:size(conmat,1),'XTickLabel',conmat_header,'YTickLabel',conmat_header)
rotateticklabel(gca,rot)

function th=rotateticklabel(h,rot,demo)
%ROTATETICKLABEL rotates tick labels
%   TH=ROTATETICKLABEL(H,ROT) is the calling form where H is a handle to
%   the axis that contains the XTickLabels that are to be rotated. ROT is
%   an optional parameter that specifies the angle of rotation. The default
%   angle is 90. TH is a handle to the text objects created. For long
%   strings such as those produced by datetick, you may have to adjust the
%   position of the axes so the labels don't get cut off.
%
%   Of course, GCA can be substituted for H if desired.
%
%   TH=ROTATETICKLABEL([],[],'demo') shows a demo figure.
%
%   Known deficiencies: if tick labels are raised to a power, the power
%   will be lost after rotation.
%
%   See also datetick.

%   Written Oct 14, 2005 by Andy Bliss
%   Copyright 2005 by Andy Bliss

%DEMO:
if nargin==3
    x=[now-.7 now-.3 now];
    y=[20 35 15];
    figure
    plot(x,y,'.-')
    datetick('x',0,'keepticks')
    h=gca;
    set(h,'position',[0.13 0.35 0.775 0.55])
    rot=90;
end

%set the default rotation if user doesn't specify
if nargin==1
    rot=90;
end
%make sure the rotation is in the range 0:360 (brute force method)
while rot>360
    rot=rot-360;
end
while rot<0
    rot=rot+360;
end
%get current tick labels
a=get(h,'XTickLabel');
%erase current tick labels from figure
set(h,'XTickLabel',[]);
%get tick label positions
b=get(h,'XTick');
c=get(h,'YTick');
%make new tick labels
if rot<180
    th=text(b,repmat(c(end)-.1*(c(end-1)-c(end)),length(b),1),a,'HorizontalAlignment','right','rotation',rot);
else
    th=text(b,repmat(c(end)-.1*(c(end-1)-c(end)),length(b),1),a,'HorizontalAlignment','left','rotation',rot);
end

