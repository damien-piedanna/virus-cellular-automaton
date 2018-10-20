# -*- cod# -*- coding: utf-8 -*-
#####################################
#
# Boucle principale de la simulation
#
#####################################

from tkinter import *

from classes.grille import *
from classes.threads import *

# Lance la simulation
def lancerSimulation():
	nbCellulesHauteur = int(hauteurEntry.get())
	nbCellulesLargeur = int(largeurEntry.get())
	if (nbCellulesHauteur < 1):
		nbCellulesHauteur = 60
	if (nbCellulesLargeur < 1):
		nbCellulesLargeur = 90

	nomVirus = virus.get()
	if (nomVirus != "Peste noire" and nomVirus != "Rougeole" and nomVirus != "Coqueluche" and nomVirus != "Diphtérie" and nomVirus != "Variole" and nomVirus != "Poliomyélite" and nomVirus != "Grippe"):
		nomVirus = "Inconnu"

	# Création de la fenêtre
	simulation = Tk()
	simulation.title('Propagation nomVirus')

	# Création compteur de jour
	compteur = Label(simulation, text="Jour 0")
	compteur.pack()

	# Affichage du pourcentage de cellules inféctées
	pctInfecte = Label(simulation, text="Infecte : 0%")
	pctInfecte.pack()

	# Affiche le nom du virus
	Label(simulation, text="Virus : " + nomVirus).pack()

	# Création de la grille représentative de la population
	# Paramètres = fenetre, hauteur, largeur, nomVirus, nb de personne dans un carré
	grille = Grille(simulation, nbCellulesHauteur, nbCellulesLargeur, Virus(nomVirus), 5)
	grille.afficher()

	# Création d'un thread pour la propagation
	commandes = ThreadCommands(grille, compteur, pctInfecte)
	commandes.start()

	# Arrête le processus créé par le thread lorsque la fenêtre est fermée
	simulation.protocol("WM_DELETE_WINDOW", commandes.stop)

	# Creation des boutons
	boutonStart = Button(simulation, text="Start", command=commandes.continu)
	boutonStart.pack()
	boutonPause = Button(simulation, text="Pause", command=commandes.pause)
	boutonPause.pack()
	boutonStop = Button(simulation, text="Stop", command=commandes.stop)
	boutonStop.pack()

	# Lancement de la fenêtre
	simulation.mainloop()


# FONCTION MAIN #
root = Tk()
root.geometry("500x300")
root.title('Menu')

Label(root, text="Nombre de cellule en hauteur").pack()
hauteurEntry = Entry(root)
hauteurEntry.pack()

Label(root, text="Nombre de cellule en largeur").pack()
largeurEntry = Entry(root)
largeurEntry.pack()

Label(root, text="Choisir le virus").pack()
Label(root, text="(Peste noire, Rougeole, Coqueluche, Diphtérie, Variole, Poliomyélite, Grippe)").pack()
virus = Entry(root)
virus.pack()

boutonBegin = Button(root, text="Commencer", command=lancerSimulation)
boutonBegin.pack()

root.mainloop()
