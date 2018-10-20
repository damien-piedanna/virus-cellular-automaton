# -*- cod# -*- coding: utf-8 -*-

from tkinter import *

from classes.grille import *
from classes.threads import *

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
grille = Grille(root, 80, 80, Virus("Variole"), 5)
grille.afficher()

# Création d'un thread pour la propagation
commandes = ThreadCommands(grille, compteur, pctInfecte)
commandes.start()

# Arrête le processus créé par le thread lorsque la fenêtre est fermée
root.protocol("WM_DELETE_WINDOW", commandes.stop)

# Creation des boutons
boutonStart = Button(root, text="Start", command=commandes.continu)
boutonStart.pack()
boutonPause = Button(root, text="Pause", command=commandes.pause)
boutonPause.pack()
boutonStop = Button(root, text="Stop", command=commandes.stop)
boutonStop.pack()

# Lancement de la fenêtre
root.mainloop()
