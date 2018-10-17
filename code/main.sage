# -*- cod# -*- coding: utf-8 -*-

#https://fr.statista.com/statistiques/472349/repartition-population-groupe-dage-france/
#https://www.insee.fr/fr/statistiques/1892088?sommaire=1912926

from tkinter import *

from classes.grille import *
from classes.thread import *
from classes.virus import *

# Création de la fenêtre
root = Tk()
root.title('Propagation virus')

# Création compteur de jour
compteur = Label(root, text="Jour 0")
compteur.pack()

# Affichage du pourcentage de cellules inféctées
pctInfecte = Label(root, text="Infecte : 0%")
pctInfecte.pack()

# Création de la grille représentative de la population
# Paramètres = fenetre, hauteur, largeur, virus, nb de personne dans un carré
grille = Grille(root, 30, 30, Virus("Peste noire"), 5)
grille.afficher()

# Création d'un thread pour la propagation
thread = Thread(grille, compteur, pctInfecte)
thread.start()

# Arrête le processus créé par le thread lorsque la fenêtre est fermée
root.protocol("WM_DELETE_WINDOW", thread.stop)

# Creation des boutons
boutonStart = Button(root, text="Start", command=thread.continu)
boutonStart.pack()
boutonPause = Button(root, text="Pause", command=thread.pause)
boutonPause.pack()
boutonStop = Button(root, text="Stop", command=thread.stop)
boutonStop.pack()

# Lancement de la fenêtre
root.mainloop()