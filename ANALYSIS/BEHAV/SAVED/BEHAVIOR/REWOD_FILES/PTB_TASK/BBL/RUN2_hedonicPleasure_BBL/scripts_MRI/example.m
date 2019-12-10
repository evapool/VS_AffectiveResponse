function example()
% example() : montre l'utilisation de l'interface Matlab pour
% l'olphactom�tre (plus int�ressant � lire qu'� ex�cuter:-)

% Cet example montre l'usage de triggers pour signaler les commutations
% d'odeurs, donc on les configure

config_io();

% Ouverture de la session de l'olphactom�tre sur le port COM2, 16 relais

oInit(6,true);

% on attend un peu...

pause(1);

% puis on demande la pr�sentation de deux stimuli difforents sur chaque
% narine

oStimulus(1,10); % pour la narine gauche
%oStimulus(1,2); % pour la narine droite
    
% A ce stade, rien ne s'est produit. il faut r�percuter les changements
% avec la fonction oCommit(), ce que nous allons signaler par un trigger.
% Il y a un d�lai de 12-18.2 mS entre le trigger etle d�clanchement
% des relais (Merci Sylvain pour l'oscilloscope USB... :-))

outp(hex2dec('378'),2);
oCommit();
outp(hex2dec('378'),0);

% Maintenant, les odeurs s�l�ctionn�es s'�coulent dans les narines du
% sujet. Laissons durer un peu le stimulus...

pause(2);
    
% puis revenons � un flux d'air sans odeur pour les deux narines.

%oInterStimulus(0); % pour la narine gauche
oInterStimulus(1); % pour la narine droite

% A nouveau, rien ne s'est produit. il faut r�percuter les changements
% avec la fonction oCommit(), ce que nous allons signaler par un trigger.

outp(hex2dec('378'),1);
oCommit();
outp(hex2dec('378'),0);

% Cet exemple est termin�, nous pouvons fermer la session

oClose();
disp ('fine')