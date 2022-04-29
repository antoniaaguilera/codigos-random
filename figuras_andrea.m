close all
clear
%% Set route and parameters
user = 'Isa';


switch user
    case 'Isa'
        pathData=['C:\Users\ij1376\ConsiliumBots Dropbox\Isabel Jacas\data\'];
end

%%

schools = readtable([pathData 'bases andrea_marcy/colegio_26352.csv']);
schools = sortrows(schools,'postulantes','descend');

nozeros = schools(schools.postulantes>0,:);

nozeros.postulantes = nozeros.postulantes./nozeros.cupos_totales;
nozeros = sortrows(nozeros,'postulantes','descend');


figure
b = bar(find(nozeros.perfildigital == 1),[nozeros.postulantes(nozeros.perfildigital == 1)]);
hold on
bs = bar(find(nozeros.perfildigital == 0),[nozeros.postulantes(nozeros.perfildigital == 0)]);
hold on
b1 = bar(find(nozeros.rbd == 26352),nozeros.postulantes(find(nozeros.rbd == 26352)));
grid
% ylabel('Número de Postulantes entre PreK y 8vo Básico')
ylabel('Ratoi de Postulantes sobre Cupos entre PreK y 8vo Básico')
xticklabels({})
box off



schools = sortrows(schools,'clicks_card','descend');
nozeros = schools(schools.clicks_card>0,:);


figure
b = bar(find(nozeros.perfildigital == 1),[nozeros.clicks_card(nozeros.perfildigital == 1)]);
hold on
bs = bar(find(nozeros.perfildigital == 0),[nozeros.clicks_card(nozeros.perfildigital == 0)]);
hold on
b1 = bar(find(nozeros.rbd == 26352),nozeros.clicks_card(find(nozeros.rbd == 26352)));
grid
ylabel('Número de Clicks en el Mapa')
xticklabels({})
box off



schools = sortrows(schools,'clicks_profile','descend');
nozeros = schools(schools.clicks_profile>0,:);


figure
b = bar(find(nozeros.perfildigital == 1),[nozeros.clicks_profile(nozeros.perfildigital == 1)]);
hold on
bs = bar(find(nozeros.perfildigital == 0),[nozeros.clicks_profile(nozeros.perfildigital == 0)]);
hold on
b1 = bar(find(nozeros.rbd == 26352),nozeros.clicks_profile(find(nozeros.rbd == 26352)));
grid
ylabel('Número de Entradas en el Perfil')
xticklabels({})
box off



post = readtable([pathData 'para_andrea/postulantes_quintaNormal.csv']);

figure
histogram([table2array(post(:,2))])





nozeros = schools(schools.cupos_remanentes>0,:);

nozeros.cupos_remanentes = nozeros.cupos_remanentes./nozeros.cupos_totales;
nozeros = sortrows(nozeros,'cupos_remanentes','ascend');


figure
b = bar(find(nozeros.perfildigital == 1),[nozeros.cupos_remanentes(nozeros.perfildigital == 1)],'BarWidth',0.4);
hold on
bs = bar(find(nozeros.perfildigital == 0),[nozeros.cupos_remanentes(nozeros.perfildigital == 0)]);
hold on
b1 = bar(find(nozeros.rbd == 26352),nozeros.cupos_remanentes(find(nozeros.rbd == 26352)));
grid
% ylabel('Número de Postulantes entre PreK y 8vo Básico')
ylabel('Cupos remanentes (% del total) entre PreK y 8vo Básico')
xticklabels({})
legend('Con Perfil Digital','Sin Perfil Digital','Esc. Profesor Felix Alvarez','Location','northwest')
box off








%% Pins y Profiles
colorsT = [0.45,0.91,0.77 ; 0.28,0.66,0.65];

pps = readtable([pathData '/para_andrea/grafico_perfildigital.csv']);
pps = table2struct(pps);

toplot = zeros(2,3);
toplot(1,1) = 0;
toplot(2,1) = 1;

toplot(1,2) = nanmean([pps([pps.perfildigital] == 0).pins]);
toplot(2,2) = nanmean([pps([pps.perfildigital] == 1).pins]);

toplot(1,3) = nanmean([pps([pps.perfildigital] == 0).profile]);
toplot(2,3) = nanmean([pps([pps.perfildigital] == 1).profile]);

figure
b1 = bar(toplot(:,1),[toplot(:,2) toplot(:,3)]);
legend('Clicks','Entradas a Perfil','Location','northwest')
set(b1(1),'FaceColor',colorsT(2,:),'EdgeColor',colorsT(2,:),'FaceAlpha',0.5)
set(b1(2),'FaceColor',colorsT(1,:),'EdgeColor',colorsT(1,:),'FaceAlpha',0.5)
box on
axis on
legend boxoff
grid
