# -*- cod# -*- coding: utf-8 -*-
##############################
#
# Fichier de départ du projet
#
##############################

from tkinter import *

from classes.grille import *
from classes.threads import *

# Lance la simulation
def lancerSimulation():
	# Test si les entrées sont bien des entiers
	try:	
		nbCellulesHauteur = int(hauteurEntry.get())
		nbCellulesLargeur = int(largeurEntry.get())
	except ValueError:
		return

	# La grille ne peut pas faire moins de 1px de largeur ou de hauteur
	if (nbCellulesHauteur < 1 or nbCellulesLargeur < 1):
		return

	nomVirus = var.get()

	# Création de la fenêtre
	simulation = Tk()
	simulation.title('Propagation ' + nomVirus)

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
virus = ["Peste noire", "Rougeole", "Coqueluche", "Diphtérie", "Variole", "Poliomyélite", "Grippe"]
radioVirus = []

root = Tk()

root.title('Menu')

# Entrée nombre de cellules hauteur
Label(root, text="Nombre de cellule en hauteur").pack()
hauteurDefaut = StringVar(root, value='60')
hauteurEntry = Entry(root, textvariable=hauteurDefaut)
hauteurEntry.pack()

# Entrée nombre de cellules largeur
Label(root, text="Nombre de cellule en largeur").pack()
largeurDefaut = StringVar(root, value='90')
largeurEntry = Entry(root, textvariable=largeurDefaut)
largeurEntry.pack()

# Proposition des virus
var = StringVar()
Label(root, text="Choisir le virus").pack()
for i in range (len(virus)):
	radioVirus.append(Radiobutton(root, text=virus[i], variable=var, value=virus[i]))
	radioVirus[i].pack()

# On selectionne par defaut le premier virus
for radio in radioVirus:
	radio.deselect()
radioVirus[0].select()

# Bouton pour lancer la simulation
boutonBegin = Button(root, text="Commencer", command=lancerSimulation)
boutonBegin.pack()

root.mainloop()
