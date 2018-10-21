# -*- cod# -*- coding: utf-8 -*-
#############################################################################################
#
# Ce fichier contient les classes relatives à la carte sur laquelle se déroule la simulation
#
#############################################################################################

from tkinter import *
from random import *
import time
import copy

from utils import *
from classes.virus import *
from classes.cellule import *
from classes.elementsGrille import *


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

        self.matCell = []

        self.deplacements = []

        # Affectation des actions de la souris
        self.grille.bind("<Button-1>", self.infecterManu)
        self.grille.bind("<Button-2>", self.propagerUneFois)
        self.grille.bind("<Button-3>", self.guerirManu)
        self.grille.pack()

        # Création des zones urbaines
        self.zonesUrbaines = self.genererZonesUrbaines()

        #Crée les carrés composant la grille et les range dans une matrice
        for y in range (nbCelluleHauteur):
            ligne = []
            for x in range (nbCelluleLargeur):
                estDansUneZoneUrbaine = False

                # Parcours de toutes les zones urbaines de la grille
                for i in range (len(self.zonesUrbaines)):
                    zoneUrbaine = self.zonesUrbaines[i]
                    if (zoneUrbaine.contient(Position(x,y))):
                        if (zoneUrbaine.genre == "ZonePeuplee"):
                            if (randint(1,4) == 1): # 1 chance sur 4 qu'un carré soit peuplé dans une zone peuplée
                                ageMoy = CellulePopulation.genenerAgeMoyen(self.nbPers)
                                ligne.append(CellulePopulation(self.tailleCellule, "sain", ageMoy))
                                self.nbSain = self.nbSain + 1
                                # Mise à jour population par zone urbaine
                                for numZone in range (len(self.zonesUrbaines)):
                                    zone = self.zonesUrbaines[numZone]
                                    if (zone.contient(Position(x,y))):
                                        zone.nbSain += 1
                            else:
                                ligne.append(Cellule(self.tailleCellule, "vide"))
                        else:
                            probaPop = (-75/zoneUrbaine.rayon)*zoneUrbaine.distanceAuCentre(Position(x,y)) + 100 # Calcul expliqué dans le fichier calculsZone.txt
                            if (randint(0,100) < probaPop): # Plus on est loin du centre moins la population est dense
                                ageMoy = CellulePopulation.genenerAgeMoyen(self.nbPers)
                                ligne.append(CellulePopulation(self.tailleCellule, "sain", ageMoy))
                                self.nbSain = self.nbSain + 1
                                # Mise à jour population par zone urbaine
                                for numZone in range (len(self.zonesUrbaines)):
                                    zone = self.zonesUrbaines[numZone]
                                    if (zone.contient(Position(x,y))):
                                        zone.nbSain += 1
                            else:
                                ligne.append(Cellule(self.tailleCellule, "vide"))
                        estDansUneZoneUrbaine = True
                        break # Pas besoin de parcourir les autres zones car une cellule ne peut être que dans une seule zone

                if(not(estDansUneZoneUrbaine)):
                    if (randint(1,8) == 1): # 1 chance sur 8 qu'un carré soit peuplé si il est en dehors d'une zone urbaine
                        ageMoy = CellulePopulation.genenerAgeMoyen(self.nbPers)
                        ligne.append(CellulePopulation(self.tailleCellule, "sain", ageMoy))
                        self.nbSain = self.nbSain + 1
                        # Mise à jour population par zone urbaine
                        for numZone in range (len(self.zonesUrbaines)):
                            zone = self.zonesUrbaines[numZone]
                            if (zone.contient(Position(x,y))):
                                zone.nbSain += 1
                    else:
                        ligne.append(Cellule(self.tailleCellule, "vide"))

            self.matCell.append(ligne)
        # Taille minimal pour générer un fleuve
        if(self.nbCelluleLargeur >= 30 and self.nbCelluleHauteur >= 30):
            self.fleuve = Fleuve(self)

        self.genererDeplacements()

        print("Grille générée !")

    # genererZonesUrbaines génère aléatoirement des zones urbaines dans la grille
    def genererZonesUrbaines(self):
        zonesUrbaines = []

        if(randint(1,6) == 1): # 1 chance sur 6 qu'il est une métropole
            metropole = ZoneUrbaine(self,"Metropole")
            zonesUrbaines.append(metropole)
        if(randint(1,6) == 1): # 1 chance sur 6 qu'il est une métropole
            metropole = ZoneUrbaine(self,"Metropole")
            zonesUrbaines.append(metropole)
        for i in range (randint(2,4)): # Entre 2 et 4 villes
            for j in range (10): # Créer une nouvelle zone tant qu'elle en chevauche une autre (10 essai max avant abandon)
                zone = ZoneUrbaine(self,"Ville")
                nbZonesChevauchees = 0
                for i in range (len(zonesUrbaines)):
                    if (zone.chevauche(zonesUrbaines [i])):
                        nbZonesChevauchees = nbZonesChevauchees + 1
                if (nbZonesChevauchees == 0):
                    zonesUrbaines.append(zone)
                    break
        for i in range (randint(5,10)): # Entre 5 et 10 villages
            for j in range (10): # Créer une nouvelle zone tant qu'elle en chevauche une autre (10 essai max avant abandon)
                zone = ZoneUrbaine(self,"Village")
                nbZonesChevauchees = 0
                for i in range (len(zonesUrbaines)):
                    if (zone.chevauche(zonesUrbaines [i])):
                        nbZonesChevauchees = nbZonesChevauchees + 1
                if (nbZonesChevauchees == 0):
                    zonesUrbaines.append(zone)
                    break
        for i in range (randint(0,2)): # Entre 0 et 2 zones peuplées
            for j in range (10): # Créer une nouvelle zone tant qu'elle en chevauche une autre (10 essai max avant abandon)
                zone = ZoneUrbaine(self,"ZonePeuplee")
                nbZonesChevauchees = 0
                for i in range (len(zonesUrbaines)):
                    if (zone.chevauche(zonesUrbaines [i])):
                        nbZonesChevauchees = nbZonesChevauchees + 1
                if (nbZonesChevauchees == 0):
                    zonesUrbaines.append(zone)
                    break

        return zonesUrbaines

    # Génère tous les déplacements de la grille
    def genererDeplacements(self):
        # Taille minimal pour générer un fleuve
        if(self.nbCelluleLargeur >= 30 and self.nbCelluleHauteur >= 30):
            # Création des ponts
            if (self.fleuve.departAGauche):
                i = 0
                while (i < len(self.fleuve.parcours)):
                    pos = self.fleuve.parcours[i]
                    if(not(randint(0,10)) and pos.Y+int(self.fleuve.largeur/2)+1 < self.nbCelluleHauteur and pos.Y-int(self.fleuve.largeur/2)-1 >= 0 and pos.X >= 0 and pos.X < self.nbCelluleLargeur):
                        # Les cellules de départ et d'arrivée doivent être peuplées
                        if (self.matCell[pos.Y+int(self.fleuve.largeur/2)+1][pos.X].etat == "vide"):
                            self.matCell[pos.Y+int(self.fleuve.largeur/2)+1][pos.X] = CellulePopulation(self.tailleCellule, "sain", CellulePopulation.genenerAgeMoyen(self.nbPers))
                            self.nbSain += 1
                        if (self.matCell[pos.Y-int(self.fleuve.largeur/2)-1][pos.X].etat == "vide"):
                            self.matCell[pos.Y-int(self.fleuve.largeur/2)-1][pos.X] = CellulePopulation(self.tailleCellule, "sain", CellulePopulation.genenerAgeMoyen(self.nbPers))
                            self.nbSain += 1
                        self.deplacements.append(Deplacement("pont", Position(pos.X, pos.Y+int(self.fleuve.largeur/2)+1), Position(pos.X, pos.Y-int(self.fleuve.largeur/2)-1), self.tailleCellule))
                        i += 5 # Ponts espacés de 4 cellules minimum
                    else:
                        i += 1
            else: # Depart en haut
                i = 0
                while (i < len(self.fleuve.parcours)):
                    pos = self.fleuve.parcours[i]
                    if(not(randint(0,10)) and pos.X+int(self.fleuve.largeur/2)+1 < self.nbCelluleLargeur and pos.X-int(self.fleuve.largeur/2)-1 >= 0 and pos.Y >= 0 and pos.Y < self.nbCelluleHauteur):
                        if (self.matCell[pos.Y][pos.X+int(self.fleuve.largeur/2)+1].etat == "vide"):
                            self.matCell[pos.Y][pos.X+int(self.fleuve.largeur/2)+1] = CellulePopulation(self.tailleCellule, "sain", CellulePopulation.genenerAgeMoyen(self.nbPers))
                            self.nbSain += 1
                        if (self.matCell[pos.Y][pos.X-int(self.fleuve.largeur/2)-1].etat == "vide"):
                            self.matCell[pos.Y][pos.X-int(self.fleuve.largeur/2)-1] = CellulePopulation(self.tailleCellule, "sain", CellulePopulation.genenerAgeMoyen(self.nbPers))
                            self.nbSain += 1
                        self.deplacements.append(Deplacement("pont", Position(pos.X+int(self.fleuve.largeur/2)+1, pos.Y), Position(pos.X-int(self.fleuve.largeur/2)-1, pos.Y), self.tailleCellule))
                        i += 5 # Ponts espacés de 4 cellules minimum
                    else:
                        i += 1

        concatener(self.deplacements, algoPrim(self, "route"))
        concatener(self.deplacements, algoPrim(self, "voieFerree"))
        concatener(self.deplacements, algoPrim(self, "ligneAerienne"))

    def lancerVoyages(self):
        for i in range (len(self.deplacements)):
            deplacement = self.deplacements[i]
            # Probabilité qu'un voyage soit réalisé
            if (randint(0, 100) < deplacement.probaVoyage):
                # Une chance sur deux que le voyage soit dans un sens ou dans l'autre
                if (randint(0,1)):
                    depart = deplacement.pos1
                    arrivee = deplacement.pos2
                else:
                    depart = deplacement.pos2
                    arrivee = deplacement.pos1
                # Les ponts gérés différement
                if (deplacement.etat != "pont"):
                    # Récupération de la zone urbaine de départ
                    zone = 0
                    for numZone in range (len(self.zonesUrbaines)):
                        zone = self.zonesUrbaines[numZone]
                        if (zone.pos == depart):
                            break

                    # On détermine si le voyageur est sain en fonction du nombre de sains dans la zone de départ
                    if (zone.nbSain+zone.nbInfecte == 0):
                        tauxInfecte = 0
                    else:
                        tauxInfecte = zone.nbInfecte/(zone.nbSain+zone.nbInfecte)*100

                    if (randint(0, 100) < tauxInfecte):
                        voyageur = "infecte"
                    else:
                        voyageur = "sain"

                    self.animationDeplacement(deplacement, depart, arrivee, voyageur)
                    if (voyageur == "infecte"):
                        if(self.matCell[arrivee.Y][arrivee.X].etat == "sain"):
                            self.matCell[arrivee.Y][arrivee.X].soigner = True # La cellule d'arrivée n'est infectée que pendant un tour
                            self.matCell[arrivee.Y][arrivee.X].setEtat("infecte")
                            self.nbInfecte += 1
                            self.nbSain -= 1
                            self.matCell[arrivee.Y][arrivee.X].afficher(self.grille, arrivee.X, arrivee.Y)
                else: # Le déplacement est un pont
                    if (self.matCell[depart.Y][depart.X].etat == "infecte"):
                        if(self.matCell[arrivee.Y][arrivee.X].etat == "sain"):
                            self.matCell[arrivee.Y][arrivee.X].setEtat("infecte")
                            self.nbInfecte += 1
                            self.nbSain -= 1
                            self.matCell[arrivee.Y][arrivee.X].afficher(self.grille, arrivee.X, arrivee.Y)

    # Affiche l'animation d'un voyage sur le deplacement allant de depart à arrivee
    def animationDeplacement(self, deplacement, depart, arrivee, voyageur):
        if(voyageur == "sain"):
            couleur = 'green'
        else:
            couleur = 'red'
        
        # Le cercle représentant le voyageur est de diamètre 80% de la taille d'une cellule, mais minimum 16 pixels
        if (self.tailleCellule < 16):
            rayon = 8
        else:
            rayon = int(40/100 * self.tailleCellule)

        x0 = depart.X*self.tailleCellule + self.tailleCellule/2 - rayon
        y0 = depart.Y*self.tailleCellule + self.tailleCellule/2 - rayon
        x1 = depart.X*self.tailleCellule + self.tailleCellule/2 + rayon
        y1 = depart.Y*self.tailleCellule + self.tailleCellule/2 + rayon

        train = self.grille.create_oval(x0, y0, x1, y1, fill=couleur, width=2)
        self.grille.update()

        deltaX = (arrivee.X - depart.X)*self.tailleCellule
        deltaY = (arrivee.Y - depart.Y)*self.tailleCellule

        # Tant que le rond n'est pas à l'arrivée
        while(Position(self.grille.coords(train)[0], self.grille.coords(train)[1]).distance(Position(depart.X*self.tailleCellule, depart.Y*self.tailleCellule)) < Position(depart.X*self.tailleCellule, depart.Y*self.tailleCellule).distance(Position(arrivee.X*self.tailleCellule, arrivee.Y*self.tailleCellule))):
            self.grille.move(train, deltaX*(deplacement.vitesse/100), deltaY*(deplacement.vitesse/100))
            self.grille.update()
            time.sleep(0.025)

        self.grille.delete(train)

    # Afficher tous les déplacements de la grille
    def afficherDeplacements(self):
        for i in range (len(self.deplacements)):
            self.deplacements[i].afficher(self.grille)

    # Affiche la grille
    def afficher(self):
        for y in range(len(self.matCell)):
            for x in range(len(self.matCell[0])):
                self.matCell[y][x].afficher(self.grille, x, y)
        self.afficherDeplacements()


    # Infecte la cellule lorsqu'on clique gauche dessus
    def infecterManu(self, event):
        x = event.x - (event.x%self.tailleCellule)
        y = event.y - (event.y%self.tailleCellule)

        i = int(x/self.tailleCellule)
        j = int(y/self.tailleCellule)

        if(self.matCell[j][i].etat == "sain"):
            self.matCell[j][i].setEtat("infecte")
            self.matCell[j][i].afficher(self.grille, i, j)
            self.afficherDeplacements()
            print("Cellule (" + repr(i) + " ; " + repr(j) + ") infectée manuellement.")
            self.nbSain -= 1
            self.nbInfecte += 1
            for numZone in range (len(self.zonesUrbaines)):
                zone = self.zonesUrbaines[numZone]
                if (zone.contient(Position(i,j))):
                    zone.nbSain -= 1
                    zone.nbInfecte += 1

    # Soigne la cellule lorsqu'on clique droit dessus
    def guerirManu(self, event):
        x = event.x -(event.x%self.tailleCellule)
        y = event.y -(event.y%self.tailleCellule)

        i = int(x/self.tailleCellule)
        j = int(y/self.tailleCellule)

        if(self.matCell[j][i].etat == "infecte"):
            self.matCell[j][i].setEtat("sain")
            self.matCell[j][i].afficher(self.grille, i, j)
            self.afficherDeplacements()
            print("Cellule (" + repr(i) + " ; " + repr(j) + ") guérie manuellement.")
            self.nbSain += 1
            self.nbInfecte -= 1
            for numZone in range (len(self.zonesUrbaines)):
                zone = self.zonesUrbaines[numZone]
                if (zone.contient(Position(i,j))):
                    zone.nbSain += 1
                    zone.nbInfecte -= 1

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
                self.matCell[posY][posX].setEtat("infecte")
                self.matCell[posY][posX].afficher(self.grille, posX, posY)
                self.nbSain = self.nbSain - 1
                self.nbInfecte = self.nbInfecte + 1
                for numZone in range (len(self.zonesUrbaines)):
                    zone = self.zonesUrbaines[numZone]
                    if (zone.contient(Position(posX,posY))):
                        zone.nbSain -= 1
                        zone.nbInfecte += 1

    # Propage le virus jour par jour automatiquement
    def propager (self):
        matDeTest = copy.deepcopy(self.matCell)
        for y in range(self.nbCelluleHauteur):
            for x in range(self.nbCelluleLargeur):
                if (self.matCell[y][x].etat == "sain"):
                    self.soumettreAuVirus(matDeTest, x, y)
                elif (self.matCell[y][x].etat == "infecte" and self.matCell[y][x].soigner == True): # Soigne les cellules infectées temporairement
                    self.matCell[y][x].soigner = False
                    self.matCell[y][x].setEtat("sain")
                    self.nbInfecte -= 1
                    self.nbSain += 1
                    self.matCell[y][x].afficher(self.grille, x, y)
        self.afficherDeplacements()
        self.lancerVoyages()

    # Propage le virus d'un jour                
    def propagerUneFois (self, event):
        self.propager()