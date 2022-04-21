close all
clear
%% Set route and parameters
user = 'Isa';


switch user
    case 'Isa'
        pathData=['C:\Users\ij1376\ConsiliumBots Dropbox\Isabel Jacas\data\'];
end

%%

schools = readtable([pathData 'para_andrea/colegio_26352.csv']);
schools = sortrows(schools,'postulantes','descend');

nozeros = schools(schools.postulantes>0,:);

figure
b = bar([1:size(nozeros,1)],[nozeros.postulantes]);
hold on
b1 = bar(find(nozeros.rbd == 26352),nozeros.postulantes(find(nozeros.rbd == 26352)));
grid
ylabel('Número de Postulantes entre PreK y 8vo Básico')
xticklabels({})
box off


prek = readtable([pathData 'para_andrea/colegio_26352_prek.csv']);
prek = sortrows(prek,'postulantes','descend');
nozerosprek = prek(prek.postulantes>0,:);

figure
b = bar([1:size(nozerosprek,1)],[nozerosprek.postulantes]);
hold on
b1 = bar(find(nozerosprek.rbd == 26352),nozerosprek.postulantes(find(nozerosprek.rbd == 26352)));
grid
ylabel('Número de Postulantes entre PreK y 8vo Básico')
xticklabels({})
box off




schools = sortrows(schools,'clicks_card','descend');
nozeros = schools(schools.clicks_card>0,:);


figure
b = bar([1:size(nozeros,1)],[nozeros.clicks_card]);
hold on
b1 = bar(find(nozeros.rbd == 26352),nozeros.clicks_card(find(nozeros.rbd == 26352)));
grid
ylabel('Número de Clicks en el Mapa')
xticklabels({})
box off



schools = sortrows(schools,'clicks_profile','descend');
nozeros = schools(schools.clicks_profile>0,:);


figure
b = bar([1:size(nozeros,1)],[nozeros.clicks_profile]);
hold on
b1 = bar(find(nozeros.rbd == 26352),nozeros.clicks_profile(find(nozeros.rbd == 26352)));
grid
ylabel('Número de Entradas en el Perfil')
xticklabels({})
box off



post = readtable([pathData 'para_andrea/postulantes_quintaNormal.csv']);

figure
histogram([table2array(post(:,2))])



