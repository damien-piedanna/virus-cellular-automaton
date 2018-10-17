# -*- cod# -*- coding: utf-8 -*-

import copy
from random import *
from tkinter import *

from classes.virus import *
from classes.zoneUrbaine import *
from classes.deplacement import *
from classes.carre import *
from classes.deplacement import *

# La classe Grille représente la carte
class Grille:
    def __init__(self, fenetre, nbCelluleHauteur, nbCelluleLargeur, virus, nbPers):
        print("Génération de la grille...")

        # Initialisation des attributs de la grille
        self.nbCelluleHauteur = nbCelluleHauteur
        self.nbCelluleLargeur = nbCelluleLargeur
        self.virus = virus
        self.nbPers = nbPers
        self.nbInfecte = 0
        self.nbSain = 0

        hauteurEcranPx = fenetre.winfo_screenheight()
        largeurEcranPx = fenetre.winfo_screenwidth()
        self.tailleCellule = int((hauteurEcranPx-200)/nbCelluleHauteur)
        if (nbCelluleLargeur*self.tailleCellule > largeurEcranPx):
            self.tailleCellule = int(largeurEcranPx/nbCelluleLargeur)

        self.grille = Canvas(fenetre, width=self.tailleCellule*nbCelluleLargeur, height=self.tailleCellule*self.nbCelluleHauteur, background='white')

        self.matCarre = []

        self.deplacements = []

        # Affectation des actions de la souris
        self.grille.bind("<Button-1>", self.infecterManu)
        self.grille.bind("<Button-2>", self.propagerUneFois)
        self.grille.bind("<Button-3>", self.guerirManu)
        self.grille.pack()

        # Création des zones urbaines
        self.zonesUrbaines = self.genererZonesUrbaines()

        #Crée les carrés composant la grille et les range dans une matrice
        for y in range (0, nbCelluleHauteur):
            ligne = []
            for x in range (0, nbCelluleLargeur):
                estDansUneZoneUrbaine = False

                # Parcours de toutes les zones urbaines de la grille
                for i in range (0, len(self.zonesUrbaines)):
                    zoneUrbaine = self.zonesUrbaines[i]
                    if (zoneUrbaine.contient(x,y)):
                        if (zoneUrbaine.genre == "ZonePeuplee"):
                            if (randint(1,4) == 1): # 1 chance sur 4 qu'un carré soit peuplé dans une zone peuplée
                                ageMoy = CarrePopulation.genenerAgeMoyen(self.nbPers)
                                ligne.append(CarrePopulation(self.tailleCellule, "sain", ageMoy))
                                self.nbSain = self.nbSain + 1
                            else:
                                ligne.append(Carre(self.tailleCellule, "vide"))
                        else:
                            probaPop = (-75/zoneUrbaine.rayon)*zoneUrbaine.distanceAuCentre(x,y) + 100 # Calcul expliqué dans le fichier calculsZone.txt
                            if (randint(0,100) < probaPop): # Plus on est loin du centre moins la population est dense
                                ageMoy = CarrePopulation.genenerAgeMoyen(self.nbPers)
                                ligne.append(CarrePopulation(self.tailleCellule, "sain", ageMoy))
                                self.nbSain = self.nbSain + 1
                            else:
                                ligne.append(Carre(self.tailleCellule, "vide"))
                        estDansUneZoneUrbaine = True
                        break # Pas besoin de parcourir les autres zones car une cellule ne peut être que dans une seule zone

                if(not(estDansUneZoneUrbaine)):
                    if (randint(1,8) == 1): # 1 chance sur 8 qu'un carré soit peuplé si il est en dehors d'une zone urbaine
                        ageMoy = CarrePopulation.genenerAgeMoyen(self.nbPers)
                        ligne.append(CarrePopulation(self.tailleCellule, "sain", ageMoy))
                        self.nbSain = self.nbSain + 1
                    else:
                        ligne.append(Carre(self.tailleCellule, "vide"))

            self.matCarre.append(ligne)
        if(randint(0,2)): # 2 chance sur 3 d'avoir un fleuve
            self.genererFleuve()

        self.genererDeplacements()

        print("Grille générée !")

    # genererZonesUrbaines génère aléatoirement des zones urbaines dans la grille
    def genererZonesUrbaines(self):
        zonesUrbaines = []

        if(randint(1,6) == 1): # 1 chance sur 6 qu'il est une métropole
            metropole = ZoneUrbaine(self,"Metropole")
            zonesUrbaines.append(metropole)
        for i in range (0, randint(2,4)): # Entre 2 et 4 villes
            for j in range (0,10): # Créer une nouvelle zone tant qu'elle en chevauche une autre (10 essai max avant abandon)
                zone = ZoneUrbaine(self,"Ville")
                nbZonesChevauchees = 0
                for i in range (0, len(zonesUrbaines)):
                    if (zone.chevauche(zonesUrbaines [i])):
                        nbZonesChevauchees = nbZonesChevauchees + 1
                if (nbZonesChevauchees == 0):
                    zonesUrbaines.append(zone)
                    break
        for i in range (0, randint(5,10)): # Entre 5 et 10 villages
            for j in range (0,10): # Créer une nouvelle zone tant qu'elle en chevauche une autre (10 essai max avant abandon)
                zone = ZoneUrbaine(self,"Village")
                nbZonesChevauchees = 0
                for i in range (0, len(zonesUrbaines)):
                    if (zone.chevauche(zonesUrbaines [i])):
                        nbZonesChevauchees = nbZonesChevauchees + 1
                if (nbZonesChevauchees == 0):
                    zonesUrbaines.append(zone)
                    break
        for i in range (0, randint(0,2)): # Entre 0 et 2 zones peuplées
            for j in range (0,10): # Créer une nouvelle zone tant qu'elle en chevauche une autre (10 essai max avant abandon)
                zone = ZoneUrbaine(self,"ZonePeuplee")
                nbZonesChevauchees = 0
                for i in range (0, len(zonesUrbaines)):
                    if (zone.chevauche(zonesUrbaines [i])):
                        nbZonesChevauchees = nbZonesChevauchees + 1
                if (nbZonesChevauchees == 0):
                    zonesUrbaines.append(zone)
                    break


        print(repr(len(zonesUrbaines)) + " zones urbaines :")
        for i in range (0, len(zonesUrbaines)):
            print("La zone " + repr(i) + " est un(e) " + zonesUrbaines[i].genre + " de centre (" + repr(zonesUrbaines[i].posX) + "," + repr(zonesUrbaines[i].posY) + ") et de rayon " + repr(zonesUrbaines[i].rayon))

        return zonesUrbaines

    # genererFleuve génère un fleuve aléatoire dans la grille
    def genererFleuve(self):
        print("Création d'un fleuve...")
        # Taille minimal pour générer un fleuve
        if(self.nbCelluleLargeur < 30 or self.nbCelluleHauteur < 30):
            return
        # Largueur du fleuve maximum 1/15 de la taille max de la grille
        # Si largeur est paire, le fleuve est représenté avec une largeur de largeur+1
        if (self.nbCelluleHauteur < self.nbCelluleLargeur):
            largeur = randint(3,int(self.nbCelluleHauteur/10))
        else:
            largeur = randint(3,int(self.nbCelluleLargeur/10))

        # 1 chance sur 2 pour que le fleuve parte du haut ou de la gauche de la grille
        if(randint(0,1)):
            posX = 0 # Départ à gauche
            posY = randint(5, self.nbCelluleHauteur-5) # Le fleuve ne peut pas partir des autres bords
            # Tant que le fleuve n'atteind pas un bord
            while (posX < self.nbCelluleLargeur and posY > 0 and posY < self.nbCelluleHauteur):
                # On créer une nouvelle cellule du fleuve
                self.matCarre[posY][posX] = Carre(self.tailleCellule, "eau")

                # Création des ponts
                if(not(randint(0,10)) and posY+int(largeur/2)+1 < self.nbCelluleHauteur and posY-int(largeur/2)-1 > 0):
                    self.deplacements.append(Deplacement("pont", posX, posY+int(largeur/2)+1, posX, posY-int(largeur/2)-1, self.tailleCellule))

                # On étend la largeur du fleuve
                for i in range (1,int(largeur/2)+1):
                    if (posY-i >= 0):
                        self.matCarre[posY-i][posX] = Carre(self.tailleCellule, "eau")
                    if (posY+i < self.nbCelluleHauteur):
                        self.matCarre[posY+i][posX] = Carre(self.tailleCellule, "eau")

                # Position de la prochaine cellule du fleuve
                posX = posX+1
                posY = randint(posY-1, posY+1)
        else:
            posY = 0 # Départ à droite
            posX = randint(5, self.nbCelluleLargeur-5) # Le fleuve ne peut pas partir des autres bords
            # Tant que le fleuve n'atteind pas un bord
            while (posY < self.nbCelluleHauteur and posX > 0 and posX < self.nbCelluleLargeur):
                # On créer une nouvelle cellule du fleuve
                self.matCarre[posY][posX] = Carre(self.tailleCellule, "eau")

                # Création des ponts
                if(not(randint(0,10)) and posX+int(largeur/2)+1 < self.nbCelluleLargeur and posX-int(largeur/2)-1 > 0):
                    self.deplacements.append(Deplacement("pont", posX+int(largeur/2)+1, posY, posX-int(largeur/2)-1, posY, self.tailleCellule))

                # On étend la largeur du fleuve
                for i in range (1,int(largeur/2)+1):
                    if (posX-i >= 0):
                        self.matCarre[posY][posX-i] = Carre(self.tailleCellule, "eau")
                    if (posX+i < self.nbCelluleLargeur):
                        self.matCarre[posY][posX+i] = Carre(self.tailleCellule, "eau")

                # Position de la prochaine cellule du fleuve
                posX = randint(posX-1, posX+1)
                posY = posY+1
        print("Fleuve de largeur " + repr(largeur) + " généré.")

    # Génère tous les déplacements de la grille
    def genererDeplacements(self):
        for i in range (0, len(self.zonesUrbaines)-1):
            centerX = self.zonesUrbaines[i].posX
            centerY = self.zonesUrbaines[i].posY
            centerX1 = self.zonesUrbaines[i+1].posX
            centerY1 = self.zonesUrbaines[i+1].posY
            # Voies ferrées
            if ((self.zonesUrbaines[i].genre == "Ville" or self.zonesUrbaines[i].genre == "Metropole") and (self.zonesUrbaines[i+1].genre == "Ville" or self.zonesUrbaines[i+1].genre == "Metropole")):
                self.deplacements.append(Deplacement("voieFerree", centerX, centerY, centerX1, centerY1, self.tailleCellule))

            # Ponts



    # Afficher tous les déplacements de la grille
    def afficherDeplacements(self):
        for i in range (0, len(self.deplacements)):
            self.deplacements[i].afficher(self.grille)

    # Affiche la grille
    def afficher(self):
        for y in range(len(self.matCarre)):
            for x in range(len(self.matCarre[0])):
                self.matCarre[y][x].afficher(self.grille, x, y)
        self.afficherDeplacements()


    # Infecte la cellule lorsqu'on clique gauche dessus
    def infecterManu(self, event):
        x = event.x - (event.x%self.tailleCellule)
        y = event.y - (event.y%self.tailleCellule)

        i = int(x/self.tailleCellule)
        j = int(y/self.tailleCellule)

        if(self.matCarre[j][i].etat == "sain"):
            self.matCarre[j][i].setEtat("infecte")
            self.matCarre[j][i].afficher(self.grille, i, j)
            self.afficherDeplacements()
            print("la cellule " + repr(i) + " ; " + repr(j) + " a été infectée.")
            self.nbSain = self.nbSain - 1
            self.nbInfecte = self.nbInfecte + 1

    # Soigne la cellule lorsqu'on clique droit dessus
    def guerirManu(self, event):
        x = event.x -(event.x%self.tailleCellule)
        y = event.y -(event.y%self.tailleCellule)

        i = int(x/self.tailleCellule)
        j = int(y/self.tailleCellule)

        if(self.matCarre[j][i].etat == "infecte"):
            self.matCarre[j][i].setEtat("sain")
            self.matCarre[j][i].afficher(self.grille, i, j)
            self.afficherDeplacements()
            print("la cellule " + repr(i) + " ; " + repr(j) + " a été guérie.")
            self.nbSain = self.nbSain + 1
            self.nbInfecte = self.nbInfecte - 1

    # Défini si la cellule(posX, posY) devient infectée dans la grille matDeTest
    def soumettreAuVirus (self, matDeTest,posX, posY):
        tauxInfection = 0.0
        # 01 02 03 04 05 #
        # 06 07 08 09 10 #
        # 11 12 XX 13 14 #
        # 15 16 17 18 19 #
        # 20 21 22 23 24 #

        #Récupère le nombre de cellule inféctées pour chaque cellule et ajoute si c'est le cas un taux.
        if(posY >= 2):
            if (posX >= 2 and matDeTest[posY-2][posX-2].etat == "infecte"): #1
                tauxInfection = tauxInfection + 0.25
            if (posX >= 1 and matDeTest[posY-2][posX-1].etat == "infecte"): #2
                tauxInfection = tauxInfection + 0.5
            if (posX < self.nbCelluleLargeur and matDeTest[posY-2][posX].etat == "infecte"): #3
                tauxInfection = tauxInfection + 0.75
            if (posX < self.nbCelluleLargeur-1 and matDeTest[posY-2][posX+1].etat == "infecte"): #4
                tauxInfection = tauxInfection + 0.5
            if (posX < self.nbCelluleLargeur-2 and matDeTest[posY-2][posX+2].etat == "infecte"): #5
                tauxInfection = tauxInfection + 0.25

        if(posY >= 1 ):
            if (posX >= 2 and matDeTest[posY-1][posX-2].etat == "infecte"): #6
                tauxInfection = tauxInfection + 0.5
            if (posX >= 1 and matDeTest[posY-1][posX-1].etat == "infecte"): #7
                tauxInfection = tauxInfection + 0.75
            if (posX < self.nbCelluleLargeur and matDeTest[posY-1][posX].etat == "infecte"): #8
                tauxInfection = tauxInfection + 1
            if (posX < self.nbCelluleLargeur-1 and matDeTest[posY-1][posX+1].etat == "infecte"): #9
                tauxInfection = tauxInfection + 0.75
            if (posX < self.nbCelluleLargeur-2 and matDeTest[posY-1][posX+2].etat == "infecte"): #10
                tauxInfection = tauxInfection + 0.5

        if(posY < self.nbCelluleHauteur):
            if (posX >= 2 and matDeTest[posY][posX-2].etat == "infecte"): #11
                tauxInfection = tauxInfection + 0.75
            if (posX >= 1 and matDeTest[posY][posX-1].etat == "infecte"): #12
                tauxInfection = tauxInfection + 1
            if (posX < self.nbCelluleLargeur-1 and matDeTest[posY][posX+1].etat == "infecte"): #13
                tauxInfection = tauxInfection + 1        
            if (posX < self.nbCelluleLargeur-2 and matDeTest[posY][posX+2].etat == "infecte"): #14
                tauxInfection = tauxInfection + 0.75

        if(posY < self.nbCelluleHauteur-1):
            if (posX >= 2 and matDeTest[posY+1][posX-2].etat == "infecte"): #15
                tauxInfection = tauxInfection + 0.5
            if (posX >= 1 and matDeTest[posY+1][posX-1].etat == "infecte"): #16
                tauxInfection = tauxInfection + 0.75
            if (posX < self.nbCelluleLargeur and matDeTest[posY+1][posX].etat == "infecte"): #17
                tauxInfection = tauxInfection + 1
            if (posX < self.nbCelluleLargeur-1 and matDeTest[posY+1][posX+1].etat == "infecte"): #18
                tauxInfection = tauxInfection + 0.75
            if (posX < self.nbCelluleLargeur-2 and matDeTest[posY+1][posX+2].etat == "infecte"): #19
                tauxInfection = tauxInfection + 0.5

        if(posY < self.nbCelluleHauteur-2):
            if (posX >= 2 and matDeTest[posY+2][posX-2].etat == "infecte"): #20
                tauxInfection = tauxInfection + 0.25
            if (posX >= 1 and matDeTest[posY+2][posX-1].etat == "infecte"): #21
                tauxInfection = tauxInfection + 0.5
            if (posX < self.nbCelluleLargeur and matDeTest[posY+2][posX].etat == "infecte"): #22
                tauxInfection = tauxInfection + 0.75
            if (posX < self.nbCelluleLargeur-1 and matDeTest[posY+2][posX+1].etat == "infecte"): #23
                tauxInfection = tauxInfection + 0.5
            if (posX < self.nbCelluleLargeur-2 and matDeTest[posY+2][posX+2].etat == "infecte"): #24
                tauxInfection = tauxInfection + 0.25


        if (tauxInfection > 0):
            #Defini si la cellule devient infectée
            nbAlea = randint(0,100)
            if (nbAlea < tauxInfection*self.virus.tauxReproduction):
                self.matCarre[posY][posX].setEtat("infecte")
                self.matCarre[posY][posX].afficher(self.grille, posX, posY)
                self.nbSain = self.nbSain - 1
                self.nbInfecte = self.nbInfecte + 1

    # Propage le virus jour par jour automatiquement
    def propager (self):
        matDeTest = copy.deepcopy(self.matCarre)
        for y in range(self.nbCelluleHauteur):
            for x in range(self.nbCelluleLargeur):
                if (self.matCarre[y][x].etat == "sain"):
                    self.soumettreAuVirus(matDeTest, x, y)
        self.afficherDeplacements()

    # Propage le virus d'un jour                
    def propagerUneFois (self, event):
        self.propager()