cmap=colormap;
contmap=contrast(Z,size(cmap,1));
I=contmap(:,1);
I=round(I*size(cmap,1));
cmap2=cmap(I,:);
cmap3=(cmap2*1 + cmap*2)/3;
colormap(cmap3);

