clear;
close all;

load('datosIrradiancia.mat')
figure,plot(dataFechas,dataValues,'.');
rParabEmd=rParabEmd__L(dataValues,50,50,1);
desc=5;
colores='rgkgrk';
datosEmd=zeros(size(rParabEmd,1),1);
datosEmdArr=zeros(size(rParabEmd,1),desc);
for i=1:desc
    datosEmd=datosEmd+rParabEmd(:,size(rParabEmd,2)-i+1);
    datosEmdArr(:,i)=datosEmd;
end

for i=3:5
    hold on;plot(dataFechas,datosEmdArr(:,i),colores(i),'LineWidth',2.5);
end

grid on;
xlabel('Año');
ylabel('Irradiancia Solar Total (W m^-^2)');
a=gca;
set(a,'FontSize',15);
f=gcf;
%print(f,'irradianciaEMD.png','-dpng');

% for i=1:3
%     for j=2:size(datosEmdArr(1))-1
%         deriv=datosEmdArr(j,i)-datosEmdArr(j
%     end
% end

signals=datosEmdArr(:,3:5);
signalsderiv=zeros(size(signals));
signalsderiv2=zeros(size(signals));

for i=1:3
    deriv=diff(signals(:,i))';
    signalsderiv(1,i)=deriv(1);
    signalsderiv(2:size(signals,1),i)=deriv;
end

for i=1:3
    deriv=diff(signalsderiv(:,i))';
    signalsderiv2(1,i)=deriv(1);
    signalsderiv2(2:size(signals,1),i)=deriv;
end


X=[signals,signalsderiv,signalsderiv2]';
T=rand(12819,1)';

load datosONI.mat;
oniFechas=oniFechas(157:numel(oniFechas));
oniValues=oniValues(157:numel(oniValues));

cropdataFechas=floor(yyyymmdd(dataFechas)/100);

for i=1:numel(oniValues)
    [minimo,ind]=min(abs(cropdataFechas-oniFechas(i)));
    newIDT(:,i)=X(:,ind(1));
end

X=newIDT;
T=oniValues;

trainperc=0.7;

Xt=newIDT(:,1:round(size(newIDT,2)*trainperc));
Tt=oniValues(1:size(Xt,2))';

%filas=size(raw,1)-1;
%X=table2array(cell2table(raw(2:filas,2:6)))';
%T=table2array(cell2table(raw(2:filas,7)))';

net = feedforwardnet(10);
net = configure(net,Xt,Tt);
y1 = net(Xt)
net = train(net,Xt,Tt);
y2 = net(Xt)
%p = [1,0.5, 0.1, 0.8, 0.9]';
%p=[4	0.120451327	0.947858072	0.207297174	0.939846853];
%y = sim(net,p)

for i=1:size(X,2)
    vec=X(:,i);
    y(i)=sim(net,vec);
end

%figure,plot(oniFechas,y,'.r','MarkerSize',20);
%hold on,plot(oniFechas,oniValues,'.b','MarkerSize',20);

vtrain=round(numel(oniFechas)*trainperc);

figure,plot(oniFechas(1:vtrain),y(1:vtrain),'.r','MarkerSize',20);
hold on,plot(oniFechas(vtrain+1:numel(oniFechas)),y(vtrain+1:numel(oniFechas)),'.g','MarkerSize',20);


hold on,plot(oniFechas,oniValues,'b','LineWidth',3);